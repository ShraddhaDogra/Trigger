--------------------------------------------------------------------------------
-- Company: 	GSI
-- Engineer:	Davide Leoni
--
-- Create Date:   8/3/07
-- Design Name:   vulom3 
-- Module Name:   set_width - Behavioral
-- Project Name:  triggerbox 
-- Target Device:	XC4VLX25-10SF363  
-- Tool versions:  		
-- Description: 16 clock cycle programmable pulse shaper			
--								
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.vcomponents.all;

entity set_width is port (
	clk : in std_logic;
   to_be_set : in std_logic;
   width_value : in std_logic_vector(3 downto 0);
   width_adjusted_pulse : out std_logic);
end set_width;

architecture Behavioral of set_width is
signal reset, to_be_set_delayed, q : std_logic;
signal shift :std_logic_vector (15 downto 0);

begin

	process (clk)
	begin

		if rising_edge(clk) then				
			shift <= shift (14 downto 0) & to_be_set;
			to_be_set_delayed <= to_be_set;

			case width_value is
				when "0000" => reset <= shift(0);		
				when "0001" => reset <= shift(1);
				when "0010" => reset <= shift(2);
				when "0011" => reset <= shift(3);
				when "0100" => reset <= shift(4);		
				when "0101" => reset <= shift(5);
				when "0110" => reset <= shift(6);
				when "0111" => reset <= shift(7);
				when "1000" => reset <= shift(8);		
				when "1001" => reset <= shift(9);
				when "1010" => reset <= shift(10);
				when "1011" => reset <= shift(11);
				when "1100" => reset <= shift(12);		
				when "1101" => reset <= shift(13);
				when "1110" => reset <= shift(14);
				when "1111" => reset <= shift(15);
				when others => reset <= 'X';
			end case;

			if (to_be_set_delayed = '0' and reset ='1') then			
				width_adjusted_pulse <= '0';
			elsif (to_be_set_delayed = '1' and reset ='0') then
				width_adjusted_pulse <= '1';
			end if;			
		end if;
	end process;

end Behavioral;
