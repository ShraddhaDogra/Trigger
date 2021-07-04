------------------------------------------------------------

------------------- Ievgen Lavrukhin ------------------------

-- This is a test bench for  Master trigger logic for MUSE --

-------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



-- Uncomment the following library declaration if using

-- arithmetic functions with Signed or Unsigned values

--USE ieee.numeric_std.ALL;



ENTITY tb_trig_logic_gate IS

END tb_trig_logic_gate;



ARCHITECTURE behavior OF tb_trig_logic_gate IS
-- Component Declaration for the Unit Under Test (UUT)
COMPONENT trig_logic_gate is
 generic(
	CH_NUMBER : integer
 );
 port (
	 trig_ch 		: in std_logic_vector(CH_NUMBER - 1 downto 0);
	 trig_mask		: in std_logic_vector(CH_NUMBER - 1 downto 0);
	 trig_AND_out 	: out std_logic;
	 trig_OR_out	: out std_logic
 );
 
 
end COMPONENT;

--Inputs
signal trig_ch_tb		: std_logic_vector(3 downto 0);
signal trig_mask_tb		: std_logic_vector(3 downto 0);
--Outputs
signal trig_AND_out_tb	: std_logic;
signal trig_OR_out_tb	: std_logic;



BEGIN
-- Instantiate the Unit Under Test (UUT)
uut: trig_logic_gate 
	GENERIC MAP(
			CH_NUMBER => 4
	)
	PORT MAP (
			trig_ch => trig_ch_tb,
			trig_mask=> trig_mask_tb,
			trig_AND_out => trig_AND_out_tb,
			trig_OR_out => trig_OR_out_tb
	);


-- Stimulus process
stim_proc: process

begin
-- Check all possible configurations: -----
for j in 0 to 15 loop  -- loop over all trigger masks	
	trig_mask_tb <= std_logic_vector(to_unsigned(j,4));
	wait for 20 ns;
	for i in 0 to 15 loop  -- loop over all trigger inputs configurations
		wait for 20 ns;
		trig_ch_tb	<= "0000";
		wait for 50 ns;
		trig_ch_tb	<= std_logic_vector(to_unsigned(i,4));
	end loop;
end loop;

wait;

end process;



END;