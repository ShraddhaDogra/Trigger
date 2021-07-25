library ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


package fifo_package is


component virtex4_fifo_16x1024 IS
  port (
  clk: IN std_logic;
  din: IN std_logic_VECTOR(15 downto 0);
  rd_en: IN std_logic;
  rst: IN std_logic;
  wr_en: IN std_logic;
  data_count: OUT std_logic_VECTOR(9 downto 0);
  dout: OUT std_logic_VECTOR(15 downto 0);
  empty: OUT std_logic;
  full: OUT std_logic;
  valid: OUT std_logic);
END component;

component virtex4_fifo_32x512 IS
  port (
  clk: IN std_logic;
  din: IN std_logic_VECTOR(31 downto 0);
  rd_en: IN std_logic;
  rst: IN std_logic;
  wr_en: IN std_logic;
  data_count: OUT std_logic_VECTOR(8 downto 0);
  dout: OUT std_logic_VECTOR(31 downto 0);
  empty: OUT std_logic;
  full: OUT std_logic;
  valid: OUT std_logic);
END component;




end package fifo_package;



package body fifo_package is

end package body fifo_package;
