library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
--use work.adcmv3_components.all;

entity state_sync is
port(
	STATE_A_IN      : in    std_logic;
	RESET_B_IN      : in    std_logic;
	CLK_B_IN        : in    std_logic;
	STATE_B_OUT     : out   std_logic
);
end;

architecture behavioral of state_sync is

-- normal signals
signal sync_q           : std_logic;
signal sync_qq          : std_logic;

begin

-- synchronizing stage for clock domain B
THE_SYNC_STAGE_PROC: process( clk_b_in )
begin
	if( rising_edge(clk_b_in) ) then
		if( reset_b_in = '1' ) then
			sync_q <= '0'; sync_qq <= '0';
		else
			sync_qq  <= sync_q;
			sync_q   <= state_a_in;
		end if;
	end if;
end process THE_SYNC_STAGE_PROC;

-- output signals
state_b_out   <= sync_qq;

end behavioral;
