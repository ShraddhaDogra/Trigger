-- ***********************************************************************************
-- ***********************************************************************************
--
--   The REG MUX
--   -----------
--
--
--
-- ***********************************************************************************
-- ***********************************************************************************


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

library work;
use work.monitor_config.all;


entity reg_mux is
	port(
	  CLK        : in std_logic;
	  RESET      : in std_logic;
	  CLK_EN     : in std_logic;

    READ_IN    : in std_logic;
    ADDR_IN    : in std_logic_vector(7 downto 0);
    DATA_IN    : in std_logic_vector( (REG_NUM*REG_BUS)-1 downto 0);

    DATA_OUT   : out std_logic_vector(REG_BUS-1 downto 0);
    VALID_OUT  : out std_logic;

    STATUS_OUT : out std_logic_vector(7 downto 0) := "00000000"
	);
end entity;

architecture basic of reg_mux is

signal buf_reg, next_buf_reg : std_logic_vector(REG_BUS-1 downto 0) := (others => '0');
signal val, next_val : std_logic := '0';
signal stat, next_stat : std_logic_vector(7 downto 0) := (others => '0');

begin

  DATA_OUT   <= buf_reg;
  VALID_OUT  <= val;
  STATUS_OUT <= stat;

  p_register:process(CLK)
  begin
  if rising_edge(CLK) then
    buf_reg <= next_buf_reg;
    val     <= next_val;
    stat    <= next_stat;
  end if;
  end process;

  proc_MUX : process(ADDR_IN, READ_IN, DATA_IN, RESET, buf_reg)
  variable handle : integer  range 0 to 255 := 0;
  begin
  handle := to_integer(unsigned(ADDR_IN));
  next_stat(0)  <= '0'; -- UNKNOWN ADDRESS
  next_val      <= '0';
  next_buf_reg  <= buf_reg;
  if READ_IN = '1' then
    if handle < REG_NUM then
      next_buf_reg <= DATA_IN(REG_BUS*handle+REG_BUS-1 downto REG_BUS*handle);
      next_val     <= '1';
    else
      next_stat(0) <= '1'; -- UNKNOWN ADDRESS True
    end if;
  end if;
  if RESET = '1' then
    next_stat(0) <= '0';
    next_val     <= '0';
    next_buf_reg <= (others => '0');
  end if;
  end process;

end architecture;