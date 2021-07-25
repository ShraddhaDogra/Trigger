--------------------------------------------------------------------------------
-- Company:  GSI
-- Engineer: Davide Leoni
--
-- Create Date:    8/3/07
-- Design Name:    vulom3
-- Module Name:    scaler_s - Behavioral
-- Project Name:   triggerbox
-- Target Device:  XC4VLX25-10SF363 
-- Tool versions:  
-- Description:    32 bit counter with reset
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity scaler_s is port (
	clk_300MHz : in std_logic;
	clk_100MHz : in std_logic;
	input_pulse : in std_logic;
	scaler_reset : in std_logic;
	scaler_value : out std_logic_vector(31 downto 0));
end scaler_s;

architecture Behavioral of scaler_s is
signal scaled : std_logic_vector(31 downto 0) := x"00000000";
signal  r, q : std_logic;
signal input_pulse_d, shaped_input, scaler_reset_d, shaped_reset : std_logic;

begin

	process(clk_300MHz)
	begin	
		if rising_edge(clk_300MHz) then		
			input_pulse_d <= input_pulse;										
			shaped_input <= input_pulse and not input_pulse_d;					-- 1 ck shaper 
			
			if r = '1' then																	-- flip-flop
				q <= '0';
			elsif shaped_input = '1' then
				q <= '1';
			end if;			
		end if;
	end process;

	process(clk_100MHz)
	begin
		if rising_edge(clk_100MHz) then		
			scaler_reset_d <= scaler_reset;												-- 1 ck shaper
			shaped_reset <= scaler_reset and not scaler_reset_d;
			
			if shaped_reset = '1' then
				scaled <= x"00000000";
				scaler_value <= scaled;
			elsif r = '1' then
				r <= '0';
			elsif q = '1' then
				scaled <= scaled + 1;
				r <= '1';
			end if;			
		end if;
	end process;

end Behavioral;
