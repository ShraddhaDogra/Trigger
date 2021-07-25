--------------------------------------------------------------------------------
-- Company:  GSI
-- Engineer: Davide Leoni
--
-- Create Date:    7/3/07
-- Design Name:    vulom3
-- Module Name:    one_clock_long - Behavioral
-- Project Name:   triggerbox
-- Target Device:  XC4VLX25-10SF363
-- Tool versions:  
-- Description: One clock cycle pulse shaper
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM; 
use UNISIM.vcomponents.all; 

entity one_clock_long is port (
	clk       : in  std_logic;
	en_clk    : in  std_logic;
	signal_in : in  std_logic;
	pulse     : out std_logic);
end one_clock_long;

architecture Behavioral of one_clock_long is
signal internal, signal_in_s : std_logic;

begin

	process (clk)
	begin
		if rising_edge(clk) then		
			signal_in_s <= signal_in;											

			if en_clk = '0' then													
				pulse <= '0';
			else
				internal <= signal_in_s;
				pulse <= (not internal) and signal_in_s;
			end if;
		end if;
	end process;
  
end Behavioral;

