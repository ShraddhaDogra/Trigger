-- ***********************************************************************************
-- ***********************************************************************************
--
--	 REG storage cell
--   -----------------
--
-- ***********************************************************************************
-- ***********************************************************************************


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

-- Import monitor_config.vhd 
-- with all its constants and components
library work;
use work.monitor_config.all;



entity REG_cell is
	generic(
		width : integer range 1 to 32 := 32   -- only 32 bit in the current version due to the readout bus
	);
	port(
	  CLK       : in  std_logic;
	  RESET     : in  std_logic;
	  CLK_EN    : in  std_logic;

		DATA_IN   : in  std_logic_vector(REG_BUS-1 downto 0);                       -- REG_BUS is currently a constant set to 32
		DATA_OUT  : out std_logic_vector(REG_BUS-1 downto 0) := (others => '0')     -- it is defined in monitor_config.vhd which is imported
	);
end entity;

architecture basic of REG_cell is

signal data, next_data : std_logic_vector(width-1 downto 0) := (others => '0');

begin

  -- Define the output port
  DATA_OUT(width-1 downto 0) <= data;

  -- Calculate the cell contents based on RESET and input port
  p_input:process(DATA_IN, RESET)
  begin
  if RESET = '0' then
    next_data <= DATA_IN(width-1 downto 0);
  else
    next_data <= (others => '0');
  end if;
  end process;

  -- Take the input into the D flipflop at rising clock edge
  p_register : process(CLK)
  begin
    if rising_edge(CLK) then
      data <= next_data;
    end if;
  end process;

end architecture;