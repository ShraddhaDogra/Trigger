--------------------------------------------------------------------------------
-- Company:  GSI
-- Engineer: Davide Leoni
--
-- Create Date:    7/3/07
-- Design Name:    vulom3
-- Module Name:    downscale - Behavioral
-- Project Name:   triggerbox
-- Target Device:  XC4VLX25-10SF363
-- Tool versions:  
-- Description: 2^16 programmable divider with output shaper
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.vcomponents.all;
--library UNISIM;
--use UNISIM.VComponents.all;

entity downscale is port (
	disable : in std_logic;
	to_be_downscaled : in std_logic;	
   downscale_value : in std_logic_vector(3 downto 0);
	clk : in std_logic;
   downscaled : out std_logic);
end downscale;

architecture Behavioral of downscale is
signal reset, internal, to_be_downscaled_d : std_logic := '0';
signal accu : std_logic_vector (15 downto 0) := x"0000";

begin

	process(clk)	
	begin
		if rising_edge(clk) then
			if disable = '0' then
				to_be_downscaled_d <= to_be_downscaled;			
			else to_be_downscaled_d <= '0';
			end if;
			
			if to_be_downscaled_d = '1' then
				accu <= accu + 1;
			end if;
							
			case downscale_value is
				when "0000" => reset <= to_be_downscaled_d;		--bypass	
				when "0001" => reset <= accu(0);
				when "0010" => reset <= accu(1);
				when "0011" => reset <= accu(2);
				when "0100" => reset <= accu(3);
				when "0101" => reset <= accu(4);
				when "0110" => reset <= accu(5);
				when "0111" => reset <= accu(6);
				when "1000" => reset <= accu(7);
				when "1001" => reset <= accu(8);
				when "1010" => reset <= accu(9);
				when "1011" => reset <= accu(10);
				when "1100" => reset <= accu(11);
				when "1101" => reset <= accu(12);
				when "1110" => reset <= accu(13);
				when "1111" => reset <= accu(14);
				when others => reset <= 'X';			
			end case;

			internal <= reset;
			downscaled <= (not internal) and reset;
		end if;
	end process;

end Behavioral;
