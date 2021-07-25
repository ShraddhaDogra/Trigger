------------------------------------------------------------
--Simulation of mupix 6 shift register
------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MupixShiftReg is
	generic(
		pixeldac_shift_length : integer := 64
	);
	port(
		clk1 : in std_logic;
		clk2 : in std_logic;
		sin  : in std_logic;
		sout : out std_logic);
end entity MupixShiftReg;

architecture RTL of MupixShiftReg is
	
	signal pixeldac_shift_reg : std_logic_vector(pixeldac_shift_length - 1 downto 0) := (others => '0');
	signal input_register : std_logic := '0';
	
begin
	
	process(clk1)
	begin	
		if clk1'event and clk1 = '1' then
			input_register <= sin after 10 ns;
		end if;
	end process;	
		
    process(clk2)
    begin
    	if clk2'event and clk2 = '1' then
    		pixeldac_shift_reg <= pixeldac_shift_reg(pixeldac_shift_length - 2 downto 0) & input_register after 10 ns;
    	end if;
    end process;	
	
	sout <= pixeldac_shift_reg(pixeldac_shift_length - 1) after 10 ns;
	
end architecture RTL;

