--------------------------------------------------------------------------------
-- Company:  GSI
-- Engineer: Davide Leoni
--
-- Create Date:    7/3/07
-- Design Name:    vulom3
-- Module Name:    delay - Behavioral
-- Project Name:   triggerbox
-- Target Device:  XC4VLX25-10SF363
-- Tool versions:  
-- Description: 16 clock cycle programmable delayer
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity delay is port ( 
	clk : in std_logic;
	to_be_delayed : in std_logic;
	delay_value : in std_logic_vector(3 downto 0);
	delayed_pulse : out std_logic);
end delay;

architecture Behavioral of delay is
signal shift  : std_logic_vector (15 downto 0) := x"0000";

begin

	process (clk)
	begin
		if rising_edge(clk) then		
			shift <= shift (14 downto 0) & to_be_delayed;

			case delay_value is
				when "0000" => delayed_pulse <= shift(0);		
				when "0001" => delayed_pulse <= shift(1);
				when "0010" => delayed_pulse <= shift(2);
				when "0011" => delayed_pulse <= shift(3);
				when "0100" => delayed_pulse <= shift(4);
				when "0101" => delayed_pulse <= shift(5);
				when "0110" => delayed_pulse <= shift(6);
				when "0111" => delayed_pulse <= shift(7);
				when "1000" => delayed_pulse <= shift(8);		
				when "1001" => delayed_pulse <= shift(9);
				when "1010" => delayed_pulse <= shift(10);
				when "1011" => delayed_pulse <= shift(11);
				when "1100" => delayed_pulse <= shift(12);
				when "1101" => delayed_pulse <= shift(13);
				when "1110" => delayed_pulse <= shift(14);
				when "1111" => delayed_pulse <= shift(15);
				when others => delayed_pulse <= 'X';
			end case;
		end if;
	end process;

end Behavioral;
