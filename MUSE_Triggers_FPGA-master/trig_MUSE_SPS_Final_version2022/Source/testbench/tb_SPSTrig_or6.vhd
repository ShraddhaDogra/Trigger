--/////This is a testbench for SPS trigger code that Ands 6 adjacent bars and Or all of the 
-- outputs. 
---/// Written by Shraddha Dogra, 4/5/2019.



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use std.env.stop;


entity tb_SPSTrig_or6 is  -- Name of tb entity
--  Port ( );
end tb_SPSTrig_or6;

architecture archDB of tb_SPSTrig_or6 is  -- architechture name of tb entity.
--Component name and original_entity's name must be the same
--ports must be same 
component Cosmic_and6 is
port(
     in_clk: in std_logic;
	  in_front_bars: in std_logic_vector (17 downto 0);
	  in_back_bars: in std_logic_vector (27 downto 0);
	  out_cosmic_and6: out std_logic);
end component Cosmic_and6;

--inputs and outputs for itb_module the names are different from module I/p and O/p.

 signal front_input_tb: std_logic_vector (17 downto 0):=(others=> '0');
 signal back_input_tb: std_logic_vector (27 downto 0):=(others=> '0');
 

 signal tb_clk: std_logic:='0';
 signal tb_Out: std_logic:='0';


begin
-- we assign actual module I/P, O/P => tb_module I/P, O/P.
 test_name: Cosmic_and6 PORT MAP(in_clk => tb_clk, in_front_bars => front_input_tb, in_back_bars => back_input_tb, 
                       out_cosmic_and6=>tb_Out);
					   
tb_clk <= not tb_clk after 5ns;

stim_proc:process
begin
wait for 10ns;

front_input_tb(17 downto 16) <= "11";
wait for 5ns;

back_input_tb(3 downto 0) <= "1111";
wait for 10 ns;

front_input_tb(17 downto 16) <= "00";
wait for 10ns;

back_input_tb(3 downto 0) <= "0000";
wait for 10ns;

Six_inputs_front:
for i in 0 to 12 loop
	wait for 10 ns;
	front_input_tb((5+i) downto i) <= "111111";
	wait for 10ns;
	front_input_tb((5+i) downto i) <= "000000";
	wait for  100ns;
end loop Six_inputs_front;

six_inputs_back:
for i  in 0 to 22 loop
wait for 10 ns;
	back_input_tb((5+i) downto i) <= "111111";
	wait for 10ns;
	back_input_tb((5+i) downto i) <= "000000";
	wait for  100ns;
end loop six_inputs_back;

--seven_inputs:
--for i in 0 to 41 loop
	--wait for 10 ns;
	--front_input_tb((6+i) downto i) <= "111111";
	--wait for 10ns;
	--front_input_tb((6+i) downto i) <= "000000";
	--wait for  100ns;		   
--end loop seven_inputs;

--eight_inputs:
--for i in 0 to 40 loop
--	wait for 10 ns;
--	front_input_tb((7+i) downto i) <= "111111";
	--wait for 10ns;
	--front_input_tb((7+i) downto i) <= "000000";
	--wait for  100ns;		   
--end loop eight_inputs;

--ten_inputs:
--for i in 0 to 37 loop
--	wait for 10 ns;
--	front_input_tb((10+i) downto i) <= "111111";
--	wait for 10ns;
--	front_input_tb((10+i) downto i) <= "000000";
--	wait for  100ns;		   
--end loop ten_inputs;

--three_inputs:
--for i in 0 to 44 loop
--	wait for 10 ns;
--	front_input_tb((3+i) downto i) <= "111111";
--	wait for 10ns;
--	front_input_tb((3+i) downto i) <= "000000";
--	wait for  100ns;		   
--
--end loop three_inputs;

--std.env.stop;

end process;
end archDB;