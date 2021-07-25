-- ***********************************************************************************
-- ***********************************************************************************
--
--   CFG cell DEMUX
--	 --------------
--
--
-- ***********************************************************************************
-- ***********************************************************************************


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

library work;
use work.monitor_config.all;


entity cfg_mux is
	port(
	  CLK        : in std_logic;
	  RESET      : in std_logic;
	  CLK_EN     : in std_logic;

    WRITE_IN   : in std_logic;
    DATA_IN    : in std_logic_vector(7 downto 0);
    ADDR_IN    : in std_logic_vector(7 downto 0);

    DATA_OUT   : out std_logic_vector(8*FIFO_NUM-1 downto 0);
    WRITE_OUT  : out std_logic_vector(  FIFO_NUM-1 downto 0);

    STATUS_OUT : out std_logic_vector(7 downto 0) := "00000000"
	);
end entity;

architecture basic of cfg_mux is

signal stat, next_stat : std_logic_vector(7 downto 0) := (others => '0');
signal buf_data_out, next_buf_data_out : std_logic_vector(8*FIFO_NUM-1 downto 0) := (others => '0');
signal buf_write_out, next_buf_write_out : std_logic_vector(FIFO_NUM-1 downto 0) := (others => '0');

begin

  STATUS_OUT <= stat;
  DATA_OUT   <= buf_data_out;
  WRITE_OUT  <= buf_write_out;

  proc_register : process(CLK)
  begin
  if rising_edge(CLK) then
    buf_data_out  <= next_buf_data_out;
    buf_write_out <= next_buf_write_out;
    stat          <= next_stat;
  end if;
  end process;

  proc_MUX : process(ADDR_IN, WRITE_IN, DATA_IN, RESET)
	variable handle : integer range 0 to 255:= 0;
	begin
  handle := to_integer(unsigned(ADDR_IN));
  next_buf_write_out  <= (others => '0');
  next_stat(0) <= '0';  -- UNKNOWN ADDRESS
  next_stat(1) <= '0';  -- ACK
  next_buf_data_out <= (others => '0');
  if WRITE_IN = '1' then
    if handle < FIFO_NUM then
      next_buf_data_out(8*(handle+1)-1 downto 8*handle) <= DATA_IN;
      next_buf_write_out <= (others => '0');
      next_buf_write_out(handle) <= '1';
      next_stat(1) <= '1';
    else
      next_stat(0) <= '1';
    end if;
  end if;
  if RESET = '1' then
    next_stat(0) <= '0';
    next_stat(1) <= '0';
    next_buf_data_out  <= (others => '0');
    next_buf_write_out <= (others => '0');
  end if;
	end process;

end architecture;