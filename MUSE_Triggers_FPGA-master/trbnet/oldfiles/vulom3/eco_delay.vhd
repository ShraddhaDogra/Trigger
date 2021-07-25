----------------------------------------------------------------------------------
-- Company:  GSI	
-- Engineer: Davide Leoni
-- 
-- Create Date:    17:03:24 03/27/2007 
-- Design Name: 	 vulom3
-- Module Name:    eco_delay - Behavioral 
-- Project Name: 	 triggerbox
-- Target Devices: XC4VLX25-10SF363
-- Tool versions: 
-- Description: Fixed delayer with fixed output pulse shaper 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity eco_delay is port (
	clk : in std_logic;
	signal_in : in std_logic;
	signal_out : out std_logic);
end eco_delay;

architecture Behavioral of eco_delay is
signal chain : std_logic_vector(31 downto 0);
signal internal : std_logic;
signal signal_out_s : std_logic:='0';

begin

	signal_out <= signal_out_s;

	process (clk)
	begin
		if rising_edge(clk) then
			internal <= signal_in;															
			chain <= (chain (30 downto 0) & (not internal and signal_in));	

			if (chain(15) = '1') then
				signal_out_s <= '1';
			elsif (chain(15) = '0' and chain(27) ='1') then
				signal_out_s <= '0';
			end if;	
		end if;
	end process;
		
end Behavioral;

