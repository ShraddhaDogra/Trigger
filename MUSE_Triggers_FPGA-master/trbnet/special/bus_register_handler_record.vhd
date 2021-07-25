library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;

entity bus_register_handler_record is
  generic (
    BUS_LENGTH : integer range 0 to 64 := 1);
  port (
    RESET    : in  std_logic;
    CLK      : in  std_logic;

    BUS_RX   : in  CTRLBUS_RX;
    BUS_TX   : out CTRLBUS_TX;

    DATA_IN  : in  std_logic_vector_array_32(0 to BUS_LENGTH);
    DATA_OUT : out std_logic_vector_array_32(0 to BUS_LENGTH));
end entity;

architecture Behavioral of bus_register_handler_record is

  signal rx_data  : std_logic_vector(31 downto 0);
  signal rx_read  : std_logic;
  signal rx_write : std_logic;
  signal rx_addr  : std_logic_vector(6 downto 0);
  
begin

  rx_data  <= BUS_RX.data             when rising_edge(CLK);
  rx_read  <= BUS_RX.read             when rising_edge(CLK);
  rx_write <= BUS_RX.write            when rising_edge(CLK);
  rx_addr  <= BUS_RX.addr(6 downto 0) when rising_edge(CLK);

  READ_WRITE_RESPONSE : process (CLK)
  begin
    if rising_edge(CLK) then
      BUS_TX.ack     <= '0';
      BUS_TX.unknown <= '0';
      BUS_TX.nack    <= '0';
      
      if rx_read = '1' then
        if to_integer(unsigned(rx_addr)) > BUS_LENGTH then  -- if bigger than 64
          BUS_TX.unknown <= '1';
        else
          BUS_TX.data    <= DATA_IN(to_integer(unsigned(rx_addr)));
          BUS_TX.ack     <= '1';
        end if;
      elsif rx_write = '1' then
        if to_integer(unsigned(rx_addr)) > BUS_LENGTH then  -- if bigger than 64
          BUS_TX.unknown <= '1';
        else  
          DATA_OUT(to_integer(unsigned(rx_addr))) <= rx_data;
          BUS_TX.ack     <= '1';
        end if;  
      end if;
    end if;
  end process READ_WRITE_RESPONSE;

end Behavioral;

