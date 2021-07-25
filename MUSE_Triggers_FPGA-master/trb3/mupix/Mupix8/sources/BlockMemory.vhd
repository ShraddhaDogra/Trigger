library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity BlockMemory is
  generic (
    DataWidth    : integer := 10; --data width
    AddressWidth : integer := 10); --address width
  port (
    clk    : in  std_logic;-- clock
    WrEn   : in  std_logic;-- write enable
    WrAddr : in  std_logic_vector(AddressWidth - 1 downto 0);-- write address
    Din    : in  std_logic_vector(DataWidth - 1 downto 0);-- data in
    ReAddr : in  std_logic_vector(AddressWidth - 1 downto 0);--read address
    Dout   : out std_logic_vector(DataWidth - 1 downto 0));--data out (1 clock period delay)
end BlockMemory;

architecture Behavioral of BlockMemory is
  
  type   memory_type is array ((2**AddressWidth) - 1 downto 0) of std_logic_vector(DataWidth - 1 downto 0);
  signal memory : memory_type := (others => (others => '0'));

begin

  MemoryControll : process(clk)
  begin  -- process MemoryControll
    if rising_edge(clk) then
      Dout <= memory(to_integer(unsigned(ReAddr)));   --read memory
      if(WrEn = '1') then
        memory(to_integer(unsigned(WrAddr))) <= Din;  -- write memory
      end if;
    end if;
  end process MemoryControll;


end Behavioral;

