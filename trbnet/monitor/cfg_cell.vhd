-- ***********************************************************************************
-- ***********************************************************************************
--
--   CFG cell for FIFO controls
--   --------------------------
--
--   [0] - reset
--   [1] - ringbuffer
--   [2] - check if differing input
--   [3] - halt
--   [4] - autowrite
--
-- ***********************************************************************************
-- ***********************************************************************************


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.monitor_config.all;


entity CFG_cell is
  generic(
    init  : std_logic_vector(7 downto 0)
  );
  port(
    CLK       : in std_logic;
    RESET     : in std_logic;
    CLK_EN    : in std_logic;

    DATA_IN   : in std_logic_vector(7 downto 0);
    WRITE_IN  : in std_logic;

    DATA_OUT  : out std_logic_vector(7 downto 0) := (others => '0')
  );
end entity;

architecture basic of CFG_cell is

signal data, next_data : std_logic_vector(7 downto 0) := init;

begin

  DATA_OUT  <= data;

  p_write:process(WRITE_IN, RESET, data, DATA_IN)
  begin
  next_data <= data;
  if RESET = '0' then
    if WRITE_IN = '1' then
      next_data <= DATA_IN;
    end if;
  end if;
  end process;

  proc_cell_logic : process(CLK)
  begin
  if rising_edge(CLK) then
    data <= next_data;
  end if;
  end process;

end architecture;