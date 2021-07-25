library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity pulse_stretch is
port(
	CLK_IN      : in    std_logic;
	RESET_IN    : in    std_logic;
	START_IN    : in    std_logic;
	PULSE_OUT   : out   std_logic;
	DEBUG_OUT   : out   std_logic_vector(15 downto 0)
);
end;

architecture behavioral of pulse_stretch is

-- normal signals
signal pulse_cnt        : unsigned(3 downto 0);
signal pulse_cnt_ce     : std_logic;
signal pulse_x          : std_logic;
signal pulse            : std_logic;

begin

-- Pulse length counter
THE_PULSE_LENGTH_CTR: process( CLK_IN )
begin
	if( rising_edge(CLK_IN) ) then
		if   ( RESET_IN = '1' ) then
			pulse_cnt    <= (others => '0');
		elsif( pulse_cnt_ce = '1' ) then
			pulse_cnt    <= pulse_cnt + 1;
		end if;
	end if;
end process THE_PULSE_LENGTH_CTR;

pulse_cnt_ce <= '1' when ( (START_IN = '1') or (pulse_cnt /= x"0") ) else '0';

pulse_x      <= '1' when ( (pulse_cnt(2) = '1') or (pulse_cnt(3) = '1') ) else '0';

-- Syanchronize it
THE_SYNC_PROC: process( CLK_IN )
begin
	if( rising_edge(CLK_IN) ) then
		if( RESET_IN = '1' ) then
			pulse <= '0';
		else
			pulse <= pulse_x;
		end if;
	end if;
end process THE_SYNC_PROC;


-- output signals
PULSE_OUT               <= pulse;
DEBUG_OUT(15 downto 4)  <= (others => '0');
DEBUG_OUT(3 downto 0)   <= std_logic_vector(pulse_cnt);

end behavioral;
