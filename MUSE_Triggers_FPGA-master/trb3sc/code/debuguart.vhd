library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
library work;
  use work.trb_net_std.all;
  use work.config.all;


entity debuguart is
  port (
    CLK         : in  std_logic;
    RESET       : in  std_logic;
    
    RX_IN       : in  std_logic;
    TX_OUT      : out std_logic;
    
    DEBUG_ACTIVE  : out std_logic;
  
    BUS_DEBUG_TX  : in  CTRLBUS_TX := (data => (others => '0'), unknown => '1', others => '0');
    BUS_DEBUG_RX  : out CTRLBUS_RX;
    
    STATUS        : out std_logic_vector(31 downto 0)
    
    );
end entity;


architecture arch of debuguart is

constant clk_div  : integer := (CLOCK_FREQUENCY*1000000)/115200;

signal tx_data, rx_data, tx_fifo_out : std_logic_vector(7 downto 0);
signal rx_ready, tx_ready, tx_send, tx_start : std_logic;

signal tx_fifo_read, tx_fifo_write : std_logic;
signal tx_fifo_empty, tx_fifo_full : std_logic;
signal next2_tx_start, next_tx_start : std_logic;

type FSM_STATE is (IDLE, START, DO_COMMAND, WAIT_ANSWER, SEND, FINISH);
signal state     : FSM_STATE;
signal command   : std_logic;
signal bytecount : integer range 0 to 15;
signal addr_data : std_logic_vector(47 downto 0);
signal timer     : unsigned(4 downto 0);
signal timeout   : unsigned(26 downto 0);


begin



THE_RX : entity work.uart_rec
  port map(
    CLK_DIV      => clk_div,
    CLK          => CLK,
    RST          => RESET,
    RX           => RX_IN,
    DATA_OUT     => rx_data,
    DATA_WAITING => rx_ready,
    DEBUG        => open
    );

THE_TX : entity work.uart_trans
  port map(
    CLK_DIV      => clk_div,
    CLK          => CLK,
    RST          => RESET,
    DATA_IN      => tx_fifo_out(7 downto 0),
    SEND         => tx_start,
    READY        => tx_ready,
    TX           => TX_OUT,
    DEBUG        => open
    );



THE_TX_FIFO : entity work.fifo_9x2k_oreg
  port map(
    Clock => CLK,
    Data(7 downto 0)  => tx_data,
    Data(8) => '0',
    WrEn  => tx_send,
    RdEn  => tx_fifo_read,
    Reset => RESET,
    Q(7 downto 0) => tx_fifo_out,
    Q(8) => open,
    Empty => tx_fifo_empty,
    Full  => tx_fifo_full
    );    
    
PROC_SEND : process begin
  wait until rising_edge(CLK);
  tx_fifo_read  <= '0';
  next_tx_start  <= '0';
  next2_tx_start <= next_tx_start;
  tx_start       <= next2_tx_start;
  
  if tx_fifo_empty = '0' and tx_ready = '1' and next_tx_start = '0' and next2_tx_start = '0' then
    next_tx_start <= '1';  
    tx_fifo_read <= '1';
  end if;
  
end process;



PROC_CTRL : process 
  variable tmp : unsigned(7 downto 0);
begin
  wait until rising_edge(CLK);
  timeout <= timeout + 1;
  tx_send <= '0';
  BUS_DEBUG_RX.write <= '0';
  BUS_DEBUG_RX.read  <= '0';
  
  case state is 
    when IDLE =>
      command      <= '0';
      bytecount    <= 11;
      timeout      <= (others => '0');
      DEBUG_ACTIVE <= '0';
      if rx_ready = '1' then
        if rx_data = x"52" then
          command <= '1';
          state <= START;
        elsif rx_data = x"57" then
          command <= '0';
          state <= START;
        end if;  
      end if;
      
    when START =>
      if rx_ready = '1' then
        if rx_data > x"40" then  
          tmp := unsigned(rx_data) + x"09";
        else
          tmp := unsigned(rx_data);
        end if;  
        addr_data(bytecount*4+3 downto bytecount*4) <= std_logic_vector(tmp(3 downto 0));
        if (bytecount = 0 and command = '0') or (bytecount = 8 and command = '1') then
          state <= DO_COMMAND;
        else
          bytecount <= bytecount - 1;
        end if;
      end if;
      
    when DO_COMMAND =>
      DEBUG_ACTIVE       <= '1';
      BUS_DEBUG_RX.data  <= addr_data(31 downto 0);
      BUS_DEBUG_RX.addr  <= addr_data(47 downto 32);
      BUS_DEBUG_RX.write <= not command;
      BUS_DEBUG_RX.read  <=     command;
      state <= WAIT_ANSWER;
      timer <= (others => '0');
      
    when WAIT_ANSWER =>
      timer <= timer + 1;
      if BUS_DEBUG_TX.ack = '1' or BUS_DEBUG_TX.wack = '1' or BUS_DEBUG_TX.rack = '1' then
        tx_data <= x"41";
        tx_send <= '1';
        if command = '1' then
          state <= SEND;
          addr_data(31 downto 0) <= BUS_DEBUG_TX.data;
          bytecount <= 11;
        else
          state <= FINISH;
        end if;  
      elsif BUS_DEBUG_TX.nack = '1' then
        tx_data <= x"4E";
        tx_send <= '1';
        state   <= FINISH;
      elsif BUS_DEBUG_TX.unknown = '1' then  
        tx_data <= x"55";
        tx_send <= '1';
        state   <= FINISH;
      elsif timer = "11111" then
        tx_data <= x"54";
        tx_send <= '1';
        state   <= FINISH;
      end if;
      
    when SEND =>  
      DEBUG_ACTIVE <= '0';
    
      tmp := x"0" & unsigned(addr_data(bytecount*4+3 downto bytecount*4));
      if tmp > x"09" then
        tmp := tmp + x"41" - x"0a";
      else
        tmp := tmp + x"30";
      end if;
      
      tx_data <= std_logic_vector(tmp);
      tx_send <= '1';
      
      if bytecount = 0 then
        state <= FINISH;
      else
        bytecount <= bytecount - 1;
      end if;
      
    when FINISH =>
      tx_data <= x"0a";
      tx_send <= '1';
      state   <= IDLE;
  end case;
  
  if timeout(timeout'left) = '1' or RESET = '1' then
    state <= IDLE;
  end if;
  
end process;


STATUS(7 downto 0) <= rx_data;
STATUS(15 downto 8)<= tx_data;
STATUS(19 downto 16) <= std_logic_vector(to_unsigned(bytecount,4));
STATUS(20) <= command;
STATUS(21) <= rx_ready;
STATUS(22) <= tx_send;
STATUS(23) <= tx_fifo_empty;
STATUS(24) <= RX_IN;
STATUS(31 downto 25) <= std_logic_vector(timeout(26 downto 20));
    
end architecture;





  
