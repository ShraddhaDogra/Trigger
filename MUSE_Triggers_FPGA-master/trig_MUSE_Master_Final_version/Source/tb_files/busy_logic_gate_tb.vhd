------------------------------------------------------------

------------------- Ievgen Lavrukhin ------------------------

-- This is a test bench for busy logic for MUSE --

-------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;





ENTITY tb_busy_logic_gate IS

END tb_busy_logic_gate;



ARCHITECTURE behavior OF tb_busy_logic_gate IS
-- Component Declaration for the Unit Under Test (UUT)
COMPONENT busy_logic_gate is
 generic(
	CH_NUMBER : integer
 );
 port (
	 busy_ch 		: in std_logic_vector(CH_NUMBER - 1 downto 0);
	 busy_mask		: in std_logic_vector(CH_NUMBER - 1 downto 0);
	 busy_out 		: out std_logic
 );
 
 
end COMPONENT;

--Inputs
signal busy_ch_tb		: std_logic_vector(3 downto 0);
signal busy_mask_tb		: std_logic_vector(3 downto 0);
--Outputs
signal busy_out_tb		: std_logic;



BEGIN
-- Instantiate the Unit Under Test (UUT)
uut: busy_logic_gate 
	GENERIC MAP(
			CH_NUMBER => 4
	)
	PORT MAP (
			busy_ch => busy_ch_tb,
			busy_mask=> busy_mask_tb,
			busy_out => busy_out_tb
	);


-- Stimulus process
stim_proc: process

begin
-- Check all possible configurations: -----
for j in 0 to 15 loop  -- loop over all trigger masks	
	busy_mask_tb <= std_logic_vector(to_unsigned(j,4));
	wait for 20 ns;
	for i in 0 to 15 loop  -- loop over all trigger inputs configurations
		wait for 20 ns;
		busy_ch_tb	<= "0000";
		wait for 50 ns;
		busy_ch_tb	<= std_logic_vector(to_unsigned(i,4));
	end loop;
end loop;

wait;

end process;



END;