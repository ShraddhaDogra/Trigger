-------------------------------------------------------------
------------------- Ievgen Lavrukhin ------------------------
-- This is a test bench for  Master trigger logic for MUSE --
-------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY tb_trigger_type_ID  IS
END tb_trigger_type_ID ;

ARCHITECTURE behavior OF tb_trigger_type_ID  IS

-- Component Declaration for the Unit Under Test (UUT)
component trigger_type_ID is
	generic(
		INP_NUMBER : integer := 16 -- number of input trigger gate cahnnels 
	);
	port (
		trig_logic_inputs	: in std_logic_vector (INP_NUMBER -1 downto 0);
		trig_final			: in std_logic; 
		clk_in				: in std_logic;
		trig_type_word		: out std_logic_vector (31 downto 0)
	);
end component trigger_type_ID;

signal trig_logic_inputs_tb	: std_logic_vector(3 downto 0) :=(others => '0'); 
signal temp					: unsigned (3 downto 0) :=(others => '0');
signal trig_final_tb		: std_logic := '0';
signal clk_in_tb			: std_logic	:= '0';	   
signal check				: std_logic	:= '0';
signal trig_type_word		: std_logic_vector(31 downto 0) := (others => '0');


BEGIN

-- Instantiate the Unit Under Test (UUT)
uut: trigger_type_ID 
	generic map(
		INP_NUMBER => 4 -- number of input trigger gate cahnnels 
	)
	port map(
		trig_logic_inputs	=> trig_logic_inputs_tb,
		trig_final			=> trig_final_tb,
		clk_in				=> clk_in_tb,
		trig_type_word		=> trig_type_word
	);
	
clk_in_tb <= not clk_in_tb after 5ns;
check <= not check after 200 ns;

trig_logic_inputs_tb <= std_logic_vector(temp);
trig_final_tb <= or_all(trig_logic_inputs_tb) and check;	

-------------------- Stimulus process ----------------------------

stim_proc: process
begin

-- Geneateration input for TB:	 	 
	for i in 0 to 10 loop	  
		for j in 0 to 15 loop	 
			wait for 150 ns;  
			temp <= temp + 1*j;	 
			wait for 30 ns;	  
			temp <=(others => '0');	 
		end loop;
	end loop;		 




wait for 2000 ns;
wait;
end process;

END;