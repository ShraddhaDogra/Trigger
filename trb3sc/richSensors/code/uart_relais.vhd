library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.version.all;

library machxo2;
use machxo2.all;


entity uart_relais is
  generic(
    OUTPUTS : integer := 1;
    BAUD    : integer := 19200
    );
  port(
    CLK     : in  std_logic;
    RESET   : in  std_logic; -- Setze alle Werte zurück
    UART_TX : out std_logic_vector(OUTPUTS-1 downto 0); -- Daten an Board schicken 
    
    BUS_RX  : in CTRLBUS_RX; -- Was User an FPGA schickt
    BUS_TX  : out CTRLBUS_TX -- Was FPGA an User schickt
    );
end entity;


architecture uart_arch of uart_relais is

signal rx_data   : std_logic_vector(7 downto 0);
signal rx_ready  : std_logic;
signal tx_send   : std_logic;
signal tx_ready  : std_logic;
signal out_sel   : integer range 0 to OUTPUTS-1 := 0;
signal uart_sel_rx : std_logic;
signal uart_sel_tx : std_logic;

signal clk_div   : integer := 100000000/BAUD;

--signal rx_fifo_out   : std_logic_vector(8 downto 0);
--signal rx_fifo_empty : std_logic;
--signal rx_fifo_full  : std_logic;
--signal rx_fifo_read  : std_logic;
signal tx_fifo_out   : std_logic_vector(8 downto 0);
signal tx_fifo_empty : std_logic;
signal tx_fifo_full  : std_logic;
signal tx_fifo_read  : std_logic;
signal tx_fifo_write : std_logic;

signal next2_tx_send, next_tx_send : std_logic;
signal last2_rx_read, last_rx_read : std_logic;
signal tx_debug : std_logic_vector(3 downto 0);

signal switch_cnt	: unsigned( 4 downto 0) := "00000";
signal tx_fifo_in 	: std_logic_vector(8 downto 0);
signal switch_pwr	: std_logic_vector(11 downto 0):= x"000";
signal switch_use	: std_logic := '0';

signal manual_send	: std_logic_vector(7 downto 0);
signal manual_tx_fifo_write,tx_fifo_write_FIFO : std_logic;
signal debug_sig	: std_logic_vector(39 downto 0):=x"0000000000";
signal time_cnt		: unsigned(3 downto 0);

begin


THE_TX_FIFO : entity work.fifo_9x2k_oreg
  port map(
    Clock => CLK,
    Data  => tx_fifo_in,--BUS_RX.data(8 downto 0),
    WrEn  => tx_fifo_write_FIFO,--tx_fifo_write,
    RdEn  => tx_fifo_read,
    Reset => RESET,
    Q     => tx_fifo_out,
    Empty => tx_fifo_empty,
    Full  => tx_fifo_full
    );

THE_TX : entity work.uart_trans
  port map(
    CLK_DIV      => clk_div,
    CLK          => CLK,
    RST          => RESET,
    DATA_IN      => tx_fifo_out(7 downto 0),
    SEND         => tx_send,
    READY        => tx_ready,
    TX           => UART_TX(0),--uart_sel_tx,
    DEBUG        => tx_debug
    );


PROC_SWITCH_PWR : process begin
  wait until rising_edge(CLK);

  tx_fifo_in(8) <= '0';
  --tx_fifo_in(7 downto 0) <= x"00";
  tx_fifo_write <= '0';
  tx_fifo_write_FIFO <= tx_fifo_write;
  if manual_tx_fifo_write = '1' then
      tx_fifo_in(7 downto 0) <= manual_send;--BUS_RX.data(7 downto 0);
      tx_fifo_write <= '1';
  else 
    if switch_use = '1' and switch_cnt = 0 then
      switch_cnt <= 1;	
    else 
      if switch_cnt > 0  then
	case switch_cnt is
	  when 1 => tx_fifo_in(7 downto 0) <= x"53";	-- S  
		    if time_cnt = 3 then tx_fifo_write <= '1'; end if;
		    if time_cnt = 7 then switch_cnt <= switch_cnt + 1; end if;
		    debug_sig(39 downto 32) <= x"53";
		    
	  when 2 => tx_fifo_in(7 downto 0) <= x"30"; --& switch_pwr(11 downto 8);	-- ch_0  
		    if time_cnt = 3 then tx_fifo_write <= '1'; end if;
		    if time_cnt = 7 then switch_cnt <= switch_cnt + 1; end if;
		    debug_sig(31 downto 24) <= x"30";
	  
	  when 3 => tx_fifo_in(7 downto 0) <= x"33";-- & switch_pwr(7 downto 4);	-- ch_1  
		    if time_cnt = 3 then tx_fifo_write <= '1'; end if;
		    if time_cnt = 7 then switch_cnt <= switch_cnt + 1; end if;
		    debug_sig(23 downto 16) <= x"33";
	  
	  when 4 => tx_fifo_in(7 downto 0) <= x"31";-- & switch_pwr(3 downto 0);	-- off|on|toggle
		    if time_cnt = 3 then tx_fifo_write <= '1'; end if;
		    if time_cnt = 7 then switch_cnt <= switch_cnt + 1; end if;	
		    debug_sig(15 downto 8) <= x"31";
	  
	  when 5 => tx_fifo_in(7 downto 0) <= x"0A"; -- \n
		    if time_cnt = 3 then tx_fifo_write <= '1'; end if;
		    if time_cnt = 7 then switch_cnt <= 0; end if;
		    debug_sig(7 downto 0) <= x"0A";
		    
	  when others => tx_fifo_write <= '0';
			 switch_cnt    <= 0;

	end case;

      end if;
    end if;
  end if;
end process;


PROC_REGS : process begin
  wait until rising_edge(CLK);
  BUS_TX.unknown <= '0';
  BUS_TX.ack     <= '0';	
  BUS_TX.nack    <= '0';
  BUS_TX.data    <= (others => '0');
  switch_use	 <= '0';
  manual_tx_fifo_write <= '0';

  if BUS_RX.write = '1' then
    if BUS_RX.addr(3 downto 0) = x"0" then
      --tx_fifo_write <= not tx_fifo_full;
      --BUS_TX.ack    <= not tx_fifo_full;
      --BUS_TX.nack   <=     tx_fifo_full;
      manual_send   	   <= BUS_RX.data(7 downto 0);
      manual_tx_fifo_write <= not tx_fifo_full;
      BUS_TX.ack    	   <= not tx_fifo_full;
      BUS_TX.nack   	   <= tx_fifo_full;
    elsif BUS_RX.addr(3 downto 0) = x"1" then
      clk_div  <= to_integer(unsigned(BUS_RX.data));
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"2" then
      out_sel  <= to_integer(unsigned(BUS_RX.data(3 downto 0)));
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"3" then
      switch_pwr <= BUS_RX.data(11 downto 0);
      switch_use <= '1';
      BUS_TX.ack <= '1';
    else
      BUS_TX.unknown <= '1';
    end if;
  
  elsif BUS_RX.read = '1' then
    --if BUS_RX.addr(3 downto 0) = x"0" then
      --BUS_TX.data <= x"00000001";
      --rx_fifo_read <= not rx_fifo_empty;
      --BUS_TX.nack  <=     rx_fifo_empty;
    --els
    if BUS_RX.addr(3 downto 0) = x"0" then
      BUS_TX.data <= std_logic_vector(to_unsigned(clk_div,32));
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"1" then
      BUS_TX.data <= debug_sig(31 downto 0); --Wert von 31-0
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"2" then
      BUS_TX.data(7 downto 0) <= debug_sig(39 downto 32); --Wert von 31-0
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


PROC_CNT : process begin
  wait until rising_edge(CLk);
  if time_cnt = 7 then
    time_cnt <= 0;
  else
    time_cnt <= time_cnt + 1;
  end if;
  
end process;

    
end architecture;





