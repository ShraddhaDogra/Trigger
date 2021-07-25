--------------------------------------------------------------------------------
-- Company: GSI
-- Engineer:	Davide Leoni
--
-- Create Date:    8/3/07
-- Design Name:    vulom3
-- Module Name:    scaler - Behavioral
-- Project Name:   triggerbox
-- Target Device:  XC4VLX25-10SF363
-- Tool versions:  
-- Description: 20 bit counter with reset
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity scaler is
    Port ( 	clk : in std_logic;
				input_pulse : in std_logic;
				scaler_reset : in std_logic;
				scaler_value : out std_logic_vector(19 downto 0));
end scaler;

architecture Behavioral of scaler is
signal scaled : std_logic_vector(19 downto 0) := x"00000";

begin
process(clk)
begin
	if rising_edge(clk) then
		if scaler_reset = '1' then
			scaled <= x"00000";
		elsif (input_pulse = '1' and scaler_reset = '0') then
			scaled <= scaled + 1;
		end if;
	end if;


--	if rising_edge(clk) then
--		if (input_pulse = '1' and scaler_reset = '0') then
--			scaled <= scaled + 1;
--		elsif scaler_reset = '1' then
--			scaled <= x"00000";
--		end if;
--	end if;

scaler_value <= scaled;
	
end process;


end Behavioral;
