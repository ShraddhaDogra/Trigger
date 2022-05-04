--/////This is a testbench for SPS trigger code that Ands 6 adjacent bars and Or all of the 
-- outputs. 
---/// Written by Shraddha Dogra, 4/5/2019.



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use std.env.stop;
entity tb_BMLogic is  -- Name of tb entity
--  Port ( );
end tb_BMLogic;

architecture archDB of tb_BMLogic is  -- architechture name of tb entity.
--Component name and original_entity's name must be the same
--ports must be same 
component BM_Trig_Logic is
port(
	  in_clk: in std_logic;
	  in_BM: in std_logic_vector (7 downto 0);
	  out_BM: out std_logic_vector(3 downto 0));
end component BM_Trig_Logic;

--inputs and outputs for itb_module the names are different from module I/p and O/p.

 signal in_BM_tb: std_logic_vector (7 downto 0):=(others=> '0');
 signal out_BM_tb: std_logic_vector(3 downto 0):=(others =>'0');
 signal tb_clk: std_logic:='0';

begin
-- we assign actual module I/P, O/P => tb_module I/P, O/P.
 test_name: BM_Trig_Logic PORT MAP(in_clk => tb_clk, in_BM => in_BM_tb,
                       out_BM=>out_BM_tb); 
					   
tb_clk <= not tb_clk after 3ns;

stim_proc:process
begin
wait for 10ns;

in_BM_tb(7 downto 5) <= "111";
wait for 5ns;

in_BM_tb(7 downto 5) <= "000";
wait for 5ns;

in_BM_tb(3 downto 2) <= "11";
wait for 10 ns;

in_BM_tb(3 downto 2) <= "00";
wait for 10 ns;

in_BM_tb(4) <= '1';
wait for 10ns;


--std.env.stop;

end process;
end archDB;