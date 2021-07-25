library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.version.all;

library machxo2;
use machxo2.all;


entity uart is
  generic(
    OUTPUTS : integer := 1
    );
  port(
    CLK     : in  std_logic;
    RESET   : in  std_logic;
    UART_RX : in  std_logic_vector(OUTPUTS-1 downto 0);
    UART_TX : out std_logic_vector(OUTPUTS-1 downto 0);
    
    BUS_RX  : in CTRLBUS_RX;
    BUS_TX  : out CTRLBUS_TX
    );
end entity;


architecture uart_arch of uart is

signal rx_data   : std_logic_vector(7 downto 0);
signal rx_ready  : std_logic;
signal tx_send   : std_logic;
signal tx_ready  : std_logic;
signal out_sel   : integer range 0 to OUTPUTS-1 := 0;
signal uart_sel_rx : std_logic;
signal uart_sel_tx : std_logic;

signal clk_div   : integer := 100000000/57600;

signal tx_fifo_out   : std_logic_vector(8 downto 0);
signal rx_fifo_out   : std_logic_vector(8 downto 0);
signal tx_fifo_empty : std_logic;
signal tx_fifo_full  : std_logic;
signal rx_fifo_empty : std_logic;
signal rx_fifo_full  : std_logic;
signal rx_fifo_read  : std_logic;
signal tx_fifo_read  : std_logic;
signal tx_fifo_write : std_logic;

signal next2_tx_send, next_tx_send : std_logic;
signal last2_rx_read, last_rx_read : std_logic;

signal rx_debug : std_logic_vector(3 downto 0);
signal tx_debug : std_logic_vector(3 downto 0);

begin


THE_RX : entity work.uart_rec
  port map(
    CLK_DIV      => clk_div,
    CLK          => CLK,
    RST          => RESET,
    RX           => uart_sel_rx,
    DATA_OUT     => rx_data,
    DATA_WAITING => rx_ready,
    DEBUG        => rx_debug
    );

THE_TX : entity work.uart_trans
  port map(
    CLK_DIV      => clk_div,
    CLK          => CLK,
    RST          => RESET,
    DATA_IN      => tx_fifo_out(7 downto 0),
    SEND         => tx_send,
    READY        => tx_ready,
    TX           => uart_sel_tx,
    DEBUG        => tx_debug
    );

    
THE_RX_FIFO : entity work.fifo_9x2k_oreg
  port map(
    Clock => CLK,
    Data(7 downto 0)  => rx_data,
    Data(8)           => '0',
    WrEn  => rx_ready,
    RdEn  => rx_fifo_read,
    Reset => RESET,
    Q     => rx_fifo_out,
    Empty => rx_fifo_empty,
    Full  => rx_fifo_full
    );

THE_TX_FIFO : entity work.fifo_9x2k_oreg
  port map(
    Clock => CLK,
    Data  => BUS_RX.data(8 downto 0),
    WrEn  => tx_fifo_write,
    RdEn  => tx_fifo_read,
    Reset => RESET,
    Q     => tx_fifo_out,
    Empty => tx_fifo_empty,
    Full  => tx_fifo_full
    );

PROC_REGS : process begin
  wait until rising_edge(CLK);
  BUS_TX.unknown <= '0';
  BUS_TX.ack     <= '0';
  BUS_TX.nack    <= '0';
  BUS_TX.data    <= (others => '0');
  
  tx_fifo_write <= '0';
  rx_fifo_read  <= '0';
  last_rx_read  <= rx_fifo_read;
  last2_rx_read <= last_rx_read;
  
  if last2_rx_read = '1' then
    BUS_TX.data(8 downto 0) <= rx_fifo_out;
    BUS_TX.ack              <= '1';
  elsif BUS_RX.write = '1' then
    if BUS_RX.addr(3 downto 0) = x"0" then
      tx_fifo_write <= not tx_fifo_full;
      BUS_TX.ack    <= not tx_fifo_full;
      BUS_TX.nack   <=     tx_fifo_full;
    elsif BUS_RX.addr(3 downto 0) = x"1" then
      clk_div  <= to_integer(unsigned(BUS_RX.data));
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"2" then
      out_sel  <= to_integer(unsigned(BUS_RX.data(3 downto 0)));
      BUS_TX.ack  <= '1';
    else
      BUS_TX.unknown <= '1';
    end if;
  
  elsif BUS_RX.read = '1' then
    if BUS_RX.addr(3 downto 0) = x"0" then
      rx_fifo_read <= not rx_fifo_empty;
      BUS_TX.nack  <=     rx_fifo_empty;
    elsif BUS_RX.addr(3 downto 0) = x"1" then
      BUS_TX.data <= std_logic_vector(to_unsigned(clk_div,32));
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"2" then
      BUS_TX.data(3 downto 0) <= std_logic_vector(to_unsigned(out_sel,4));
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"3" then  
      BUS_TX.data(0) <= rx_fifo_full;
      BUS_TX.data(1) <= rx_fifo_empty;
      BUS_TX.data(2) <= tx_fifo_full;
      BUS_TX.data(3) <= tx_fifo_empty;
      BUS_TX.data(7 downto 4)  <= rx_debug;
      BUS_TX.data(11 downto 8) <= tx_debug;
      BUS_TX.data(12) <= next_tx_send;
      BUS_TX.data(13) <= tx_fifo_read;
      BUS_TX.data(14) <= uart_sel_tx;
      BUS_TX.data(15) <= uart_sel_rx;
      
      BUS_TX.ack  <= '1';
    else
      BUS_TX.unknown <= '1';
    end if;
  end if;
  
end process;
    
PROC_SEND : process begin
  wait until rising_edge(CLK);
  tx_fifo_read  <= '0';
  next_tx_send  <= '0';
  next2_tx_send <= next_tx_send;
  tx_send       <= next2_tx_send;
  
  if tx_fifo_empty = '0' and tx_ready = '1' and next_tx_send = '0' and next2_tx_send = '0' then
    next_tx_send <= '1';  
    tx_fifo_read <= '1';
  end if;
  
end process;
  
proc_io : process begin
  wait until rising_edge(CLK);
  UART_TX <= (others => '1');
  UART_TX(out_sel) <= uart_sel_tx;
  uart_sel_rx <= UART_RX(out_sel);
end process;

    
end architecture;


