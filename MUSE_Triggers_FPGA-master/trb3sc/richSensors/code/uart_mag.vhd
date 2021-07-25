library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.version.all;

library machxo2;
use machxo2.all;


entity uart_mag is
  generic(
    OUTPUTS : integer := 1;
    BAUD    : integer := 19200
    );
  port(
    CLK     : in  std_logic;
    RESET   : in  std_logic; -- reset all values
    UART_RX : in  std_logic_vector(OUTPUTS-1 downto 0); -- incoming data which needs to be processed
    UART_TX : out std_logic_vector(OUTPUTS-1 downto 0); -- send data to board
    
    BUS_RX  : in CTRLBUS_RX; -- what user is sending to FPGA
    BUS_TX  : out CTRLBUS_TX -- what FPGA is sending to user
    );
end entity;


architecture uart_arch of uart_mag is

type parserValue_array is array (OUTPUTS - 1 downto 0) of std_logic_vector(30 downto 0);
type serialNumber_array is array (OUTPUTS - 1 downto 0) of std_logic_vector(6 downto 0);
type rxData_array is array (OUTPUTS - 1 downto 0) of std_logic_vector(7 downto 0);

signal rx_data     : rxData_array;
signal rx_ready    : std_logic_vector(OUTPUTS - 1 downto 0);
signal tx_send     : std_logic;
signal tx_ready    : std_logic;
signal out_sel     : integer range 0 to OUTPUTS - 1 := 0;
signal uart_sel_rx : std_logic;
signal uart_sel_tx : std_logic;

signal clk_div     : integer := 100000000/BAUD;

signal tx_fifo_out   : std_logic_vector(8 downto 0);
signal tx_fifo_empty : std_logic;
signal tx_fifo_full  : std_logic;
signal tx_fifo_read  : std_logic;
signal tx_fifo_write : std_logic;

signal next2_tx_send, next_tx_send : std_logic;
signal last2_rx_read, last_rx_read : std_logic;

signal rx_debug : std_logic_vector(3 downto 0);
signal tx_debug : std_logic_vector(3 downto 0);


-- signals for output result from THE_PARSER_HANDLER
signal parser_error  : std_logic_vector(OUTPUTS-  1 downto 0);
signal serialNumbers : serialNumber_array;
-- sensor0
signal values_00_00 : parserValue_array;
signal values_00_01 : parserValue_array;
signal values_00_10 : parserValue_array;
signal values_00_11 : parserValue_array;
-- sensor1
signal values_01_00 : parserValue_array;
signal values_01_01 : parserValue_array;
signal values_01_10 : parserValue_array;
signal values_01_11 : parserValue_array;
-- sensor2
signal values_10_00 : parserValue_array;
signal values_10_01 : parserValue_array;
signal values_10_10 : parserValue_array;
signal values_10_11 : parserValue_array;
-- sensor3
signal values_11_00 : parserValue_array;
signal values_11_01 : parserValue_array;
signal values_11_10 : parserValue_array;
signal values_11_11 : parserValue_array;

--signal i,j : integer;

begin

GEN_THE_PARSER_HANDLER:
for i in 0 to OUTPUTS - 1 generate
THE_PARSER_HANDLER : entity work.magnetBoardParserHandler
  port map(
    --in
    INPUT         => rx_data(i),
    CLK           => CLK,
    READY         => rx_ready(i),
    --out
    SERIAL_NUMBER => serialNumbers(i),
    VALUE_S00_A00 => values_00_00(i),
    VALUE_S00_A01 => values_00_01(i),
    VALUE_S00_A10 => values_00_10(i),
    VALUE_S00_A11 => values_00_11(i),
    VALUE_S01_A00 => values_01_00(i),
    VALUE_S01_A01 => values_01_01(i),
    VALUE_S01_A10 => values_01_10(i),
    VALUE_S01_A11 => values_01_11(i),
    VALUE_S10_A00 => values_10_00(i),
    VALUE_S10_A01 => values_10_01(i),
    VALUE_S10_A10 => values_10_10(i),
    VALUE_S10_A11 => values_10_11(i),
    VALUE_S11_A00 => values_11_00(i),
    VALUE_S11_A01 => values_11_01(i),
    VALUE_S11_A10 => values_11_10(i),
    VALUE_S11_A11 => values_11_11(i),
    ERROR_NO_DATA => parser_error(i)
  );
end generate GEN_THE_PARSER_HANDLER;

  

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

GEN_THE_RX:
for i in 0 to OUTPUTS - 1 generate
-- transfer incoming signal (uart_sel_rx) in 8bit vector.
THE_RX : entity work.uart_rec
  port map(
    CLK_DIV      => clk_div,
    CLK          => CLK,
    RST          => RESET,
    RX           => UART_RX(i), -- pass signale to sub entity (blackbox)
    DATA_OUT     => rx_data(i), -- return value
    DATA_WAITING => rx_ready(i), -- return value
    DEBUG        => rx_debug -- return value
  );
end generate GEN_THE_RX;

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


PROC_REGS : process 
  variable i,j : integer := 0;
begin
  wait until rising_edge(CLK);
  BUS_TX.unknown <= '0';
  BUS_TX.ack     <= '0';	
  BUS_TX.nack    <= '0';
  BUS_TX.data    <= (others => '0');
  
  tx_fifo_write <= '0';
  --rx_fifo_read  <= '0';
  --last_rx_read  <= rx_fifo_read;
  --last2_rx_read <= last_rx_read;
  
  --if last2_rx_read = '1' then
    --BUS_TX.data(8 downto 0) <= rx_fifo_out;
    --BUS_TX.ack              <= '1';
  --els
  if BUS_RX.write = '1' then
    if BUS_RX.addr(3 downto 0) = x"0" then
      tx_fifo_write <= not tx_fifo_full;
      BUS_TX.ack    <= not tx_fifo_full;
      BUS_TX.nack   <=     tx_fifo_full;
    elsif BUS_RX.addr(3 downto 0) = x"1" then
      clk_div     <= to_integer(unsigned(BUS_RX.data));
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"2" then
      out_sel     <= to_integer(unsigned(BUS_RX.data(3 downto 0)));
      BUS_TX.ack  <= '1';
    else
      BUS_TX.unknown <= '1';
    end if;
  
  elsif BUS_RX.read = '1' then

    i := to_integer(unsigned(BUS_RX.addr(7 downto 4)));
    j := to_integer(unsigned(BUS_RX.addr(3 downto 0)));
    if i <= OUTPUTS then
      BUS_TX.unknown <= '0';
      BUS_TX.ack  <= '1';
      if i = 0 then
        if j = 0 then
          --clock
          BUS_TX.data <= std_logic_vector(to_unsigned(clk_div,32));
        elsif j <= OUTPUTS then
          --serial number of boards and potential error
          BUS_TX.data(6 downto 0) <= serialNumbers(j - 1);
          BUS_TX.data(8) <= parser_error(j - 1);
        else
          BUS_TX.unknown <= '1'; BUS_TX.ack  <= '0';
        end if;
      else
        case BUS_RX.addr(3 downto 0) is
          -- sensor0: T, X, Y, Z
          when x"0" => BUS_TX.data(27 downto 0) <= values_00_00(i-1)(27 downto 0);
          when x"1" => BUS_TX.data(27 downto 0) <= values_00_01(i-1)(27 downto 0);
          when x"2" => BUS_TX.data(27 downto 0) <= values_00_10(i-1)(27 downto 0);
          when x"3" => BUS_TX.data(27 downto 0) <= values_00_11(i-1)(27 downto 0);
          -- sensor1: T, X, Y, Z
          when x"4" => BUS_TX.data(27 downto 0) <= values_01_00(i-1)(27 downto 0);
          when x"5" => BUS_TX.data(27 downto 0) <= values_01_01(i-1)(27 downto 0);
          when x"6" => BUS_TX.data(27 downto 0) <= values_01_10(i-1)(27 downto 0);
          when x"7" => BUS_TX.data(27 downto 0) <= values_01_11(i-1)(27 downto 0);
          -- sensor2: T, X, Y, Z
          when x"8" => BUS_TX.data(27 downto 0) <= values_10_00(i-1)(27 downto 0);
          when x"9" => BUS_TX.data(27 downto 0) <= values_10_01(i-1)(27 downto 0);
          when x"A" => BUS_TX.data(27 downto 0) <= values_10_10(i-1)(27 downto 0);
          when x"B" => BUS_TX.data(27 downto 0) <= values_10_11(i-1)(27 downto 0);
          -- sensor3: T, X, Y, Z
          when x"C" => BUS_TX.data(27 downto 0) <= values_11_00(i-1)(27 downto 0);
          when x"D" => BUS_TX.data(27 downto 0) <= values_11_01(i-1)(27 downto 0);
          when x"E" => BUS_TX.data(27 downto 0) <= values_11_10(i-1)(27 downto 0);
          when x"F" => BUS_TX.data(27 downto 0) <= values_11_11(i-1)(27 downto 0);
        
          when others => BUS_TX.unknown <= '1'; BUS_TX.ack  <= '0';
        end case;
      end if;
    else 
      BUS_TX.unknown <= '1';
    end if;
  end if;
end process;
  
  
--   elsif BUS_RX.read = '1' then
--     --if BUS_RX.addr(3 downto 0) = x"0" then
--       --BUS_TX.data <= x"00000001";
--       --rx_fifo_read <= not rx_fifo_empty;
--       --BUS_TX.nack  <=     rx_fifo_empty;
--     --els
--     for i in 0 to OUTPUTS - 1 loop
--         if BUS_RX.addr(7 downto 0) = x"00" then --clock
--           BUS_TX.data <= std_logic_vector(to_unsigned(clk_div,32));
--           BUS_TX.ack  <= '1';
--         elsif BUS_RX.addr(7 downto 0) = std_logic_vector(to_unsigned(i + 1,8)) then
--           --serial number on port x"0i"
--           BUS_TX.data(8) <= parser_error(i);
--           BUS_TX.data(6 downto 0) <= serialNumbers(i);
--           BUS_TX.ack <= '1';
--         elsif BUS_RX.addr(7 downto 4) = std_logic_vector(to_unsigned((i + 1),4)) 
--              and BUS_RX.addr(3 downto 0) = x"0" then
--           --sensor0, T Value on port x"i0"
--           BUS_TX.data(27 downto 0) <= values_00_00(i)(27 downto 0);
--           BUS_TX.ack <= '1';
--         elsif BUS_RX.addr(7 downto 4) = std_logic_vector(to_unsigned((i + 1),4)) 
--              and BUS_RX.addr(3 downto 0) = x"1" then
--           --sensor0, X Value on port x"i1"
--           BUS_TX.data(27 downto 0) <= values_00_01(i)(27 downto 0);
--           BUS_TX.ack <= '1';
--         elsif BUS_RX.addr(7 downto 4) = std_logic_vector(to_unsigned((i + 1),4)) 
--              and BUS_RX.addr(3 downto 0) = x"2" then
--           --sensor0, Y Value on port x"i2"
--           BUS_TX.data(27 downto 0) <= values_00_10(i)(27 downto 0);
--           BUS_TX.ack <= '1';
--         elsif BUS_RX.addr(7 downto 4) = std_logic_vector(to_unsigned((i + 1),4)) 
--              and BUS_RX.addr(3 downto 0) = x"3" then
--           --sensor0, Z Value on port x"i3"
--           BUS_TX.data(27 downto 0) <= values_00_11(i)(27 downto 0);
--           BUS_TX.ack <= '1';
--         elsif BUS_RX.addr(7 downto 4) = std_logic_vector(to_unsigned((i + 1),4)) 
--              and BUS_RX.addr(3 downto 0) = x"4" then
--           --sensor1, T Value on port x"i4"
--           BUS_TX.data(27 downto 0) <= values_01_00(i)(27 downto 0);
--           BUS_TX.ack <= '1';
--         elsif BUS_RX.addr(7 downto 4) = std_logic_vector(to_unsigned((i + 1),4)) 
--              and BUS_RX.addr(3 downto 0) = x"5" then
--           --sensor1, X Value on port x"i5"
--           BUS_TX.data(27 downto 0) <= values_01_01(i)(27 downto 0);
--           BUS_TX.ack <= '1';
--         elsif BUS_RX.addr(7 downto 4) = std_logic_vector(to_unsigned((i + 1),4)) 
--              and BUS_RX.addr(3 downto 0) = x"6" then
--           --sensor1, Y Value on port x"i6"
--           BUS_TX.data(27 downto 0) <= values_01_10(i)(27 downto 0);
--           BUS_TX.ack <= '1';
--         elsif BUS_RX.addr(7 downto 4) = std_logic_vector(to_unsigned((i + 1),4)) 
--              and BUS_RX.addr(3 downto 0) = x"7" then
--           --sensor1, Z Value on port x"i7"
--           BUS_TX.data(27 downto 0) <= values_01_11(i)(27 downto 0);
--           BUS_TX.ack <= '1';
--         elsif BUS_RX.addr(7 downto 4) = std_logic_vector(to_unsigned((i + 1),4)) 
--              and BUS_RX.addr(3 downto 0) = x"8" then
--           --sensor2, T Value on port x"i8"
--           BUS_TX.data(27 downto 0) <= values_10_00(i)(27 downto 0);
--           BUS_TX.ack <= '1';
--         elsif BUS_RX.addr(7 downto 4) = std_logic_vector(to_unsigned((i + 1),4)) 
--              and BUS_RX.addr(3 downto 0) = x"9" then
--           --sensor2, X Value on port x"i9"
--           BUS_TX.data(27 downto 0) <= values_10_01(i)(27 downto 0);
--           BUS_TX.ack <= '1';
--         elsif BUS_RX.addr(7 downto 4) = std_logic_vector(to_unsigned((i + 1),4)) 
--              and BUS_RX.addr(3 downto 0) = x"A" then
--           --sensor2, Y Value on port x"iA"
--           BUS_TX.data(27 downto 0) <= values_10_10(i)(27 downto 0);
--           BUS_TX.ack <= '1';
--         elsif BUS_RX.addr(7 downto 4) = std_logic_vector(to_unsigned((i + 1),4)) 
--              and BUS_RX.addr(3 downto 0) = x"B" then
--           --sensor2, Z Value on port x"iB"
--           BUS_TX.data(27 downto 0) <= values_10_11(i)(27 downto 0);
--           BUS_TX.ack <= '1';
--         elsif BUS_RX.addr(7 downto 4) = std_logic_vector(to_unsigned((i + 1),4)) 
--              and BUS_RX.addr(3 downto 0) = x"C" then
--           --sensor3, T Value on port x"iC"
--           BUS_TX.data(27 downto 0) <= values_11_00(i)(27 downto 0);
--           BUS_TX.ack <= '1';
--         elsif BUS_RX.addr(7 downto 4) = std_logic_vector(to_unsigned((i + 1),4)) 
--              and BUS_RX.addr(3 downto 0) = x"D" then
--           --sensor3, X Value on port x"iD"
--           BUS_TX.data(27 downto 0) <= values_11_01(i)(27 downto 0);
--           BUS_TX.ack <= '1';
--         elsif BUS_RX.addr(7 downto 4) = std_logic_vector(to_unsigned((i + 1),4)) 
--              and BUS_RX.addr(3 downto 0) = x"E" then
--           --sensor3, Y Value on port x"iE"
--           BUS_TX.data(27 downto 0) <= values_11_10(i)(27 downto 0);
--           BUS_TX.ack <= '1';
--         elsif BUS_RX.addr(7 downto 4) = std_logic_vector(to_unsigned((i + 1),4)) 
--              and BUS_RX.addr(3 downto 0) = x"F" then
--           --sensor3, Z Value on port x"iF"
--           BUS_TX.data(27 downto 0) <= values_11_11(i)(27 downto 0);
--           BUS_TX.ack <= '1';
--         else
--           BUS_TX.unknown <= '1';
--         end if;
--     end loop;
--   end if;
-- end process;
    
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
  UART_TX(0) <= '1';--(others => '1');
  --UART_TX(out_sel) <= uart_sel_tx;
  --uart_sel_rx <= UART_RX(out_sel);
end process;

    
end architecture;

