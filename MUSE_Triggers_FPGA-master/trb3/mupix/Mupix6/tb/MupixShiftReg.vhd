------------------------------------------------------------
--Simulation of mupix 6 shift register
------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MupixShiftReg is
	generic(
		pixeldac_shift_length : integer := 64;
		chipdac_shift_length : integer := 16
	);
	port(
		ck_c : in std_logic;
		ck_d : in std_logic;
		sin  : in std_logic;
		sout_c : out std_logic;
		sout_d : out std_logic);
end entity MupixShiftReg;

architecture RTL of MupixShiftReg is
	
	signal pixeldac_shift_reg : std_logic_vector(pixeldac_shift_length - 1 downto 0) := (others => '0');
	signal chipdac_shift_reg : std_logic_vector(chipdac_shift_length - 1 downto 0) := (others => '0');
	
begin
	
	process(ck_c)
	begin	
		if ck_c'event and ck_c = '1' then
			pixeldac_shift_reg <= pixeldac_shift_reg(pixeldac_shift_length - 2 downto 0) & sin;
		end if;
	end process;	
		
    process(ck_d)
    begin
    	if ck_d'event and ck_d = '1' then
    		chipdac_shift_reg <= chipdac_shift_reg(chipdac_shift_length - 2 downto 0) & sin;
    	end if;
    end process;	
	
	sout_c <= pixeldac_shift_reg(pixeldac_shift_length - 1);
	sout_d <= chipdac_shift_reg(chipdac_shift_length - 1);
	
end architecture RTL;

