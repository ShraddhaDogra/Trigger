-- sbuf6: Route through without any registers

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity trb_net_sbuf6 is
port(
	--  Misc
	CLK                : in  std_logic;
	RESET              : in  std_logic;
	CLK_EN             : in  std_logic;
	-- input
	COMB_DATAREADY_IN  : in  std_logic;
	COMB_next_READ_OUT : out std_logic;
	COMB_DATA_IN       : in  std_logic_vector(18 downto 0);
	-- output
	SYN_DATAREADY_OUT  : out std_logic;
	SYN_DATA_OUT       : out std_logic_vector(18 downto 0);
	SYN_READ_IN        : in  std_logic;
	-- Status and control port
	DEBUG              : out std_logic_vector(7 downto 0);
	DEBUG_BSM          : out std_logic_vector(3 downto 0);
	DEBUG_WCNT         : out std_logic_vector(4 downto 0);
	STAT_BUFFER        : out std_logic
);
end entity;

architecture trb_net_sbuf6_arch of trb_net_sbuf6 is

begin

SYN_DATAREADY_OUT  <= COMB_DATAREADY_IN;
SYN_DATA_OUT       <= COMB_DATA_IN;
COMB_next_READ_OUT <= SYN_READ_IN;

DEBUG              <= (others => '0');
DEBUG_BSM          <= (others => '0');
DEBUG_WCNT         <= (others => '0');
STAT_BUFFER        <= '0';

end architecture;