
--/////This is a testbench for Veto_BM trigger code.
---/// 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use std.env.stop;


entity tb_BMControl is	
end tb_BMControl;


architecture archDB of tb_BMControl is  -- architechture name of tb entity.
--Component name and original_entity's name must be the same
--ports must be same 
component BM_control is	
	port (
		in_sig		 	: in std_logic_vector(7 downto 0):= (others => '1'); --trigger input channels on 4ConnBoard
		bar_enable_mask	: in std_logic_vector(7 downto 0) := (others => '1'); --mask of connected trigger channels (each bit correspods to the channel enable/disable)
		out_sig 		: out std_logic_vector(7 downto 0)  -- trigger logic output
	);
end component BM_control;

 signal tb_input: std_logic_vector (7 downto 0);
 signal tb_output: std_logic_vector(7 downto 0); 
 signal tb_bar_enable: std_logic_vector(7 downto 0); 

begin
-- we assign actual module I/P, O/P => tb_module I/P, O/P.
 test_name: BM_control PORT MAP(
                             in_sig	=> tb_input,
							 bar_enable_mask=> tb_bar_enable, 
                             out_sig=>tb_output
							 );
					  

stim_proc:process
begin

wait for 10ns;
tb_bar_enable   <= "11000011"; 

tb_input(7 downto 0) <= "11111111";


end process;
end archDB;