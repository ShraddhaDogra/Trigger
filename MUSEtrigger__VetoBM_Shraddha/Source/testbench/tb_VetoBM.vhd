
--/////This is a testbench for Veto_BM trigger code.
---/// 



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use std.env.stop;
entity tb_VetoBM is  -- Name of tb entity
--  Port ( );
end tb_VetoBM;

architecture archDB of tb_VetoBM is  -- architechture name of tb entity.
--Component name and original_entity's name must be the same
--ports must be same 
component Veto_BM is
port(
	   INP 			    : in std_logic_vector(47 downto 0); --using only first 16.
	  bar_enable_mask   : in std_logic_vector (7 downto 0);
	  CLK_PCLK_RIGHT	: in std_logic;
	  OutpA				: out std_logic_vector(2 downto 0);
	  OutpB				: out std_logic_vector(2 downto 0);
	  OutpC				: out std_logic_vector(2 downto 0)
	  );
end component Veto_BM;

 signal tb_input: std_logic_vector (47 downto 0);
 signal out_trig_tb1: std_logic_vector(2 downto 0); 
 signal out_trig_tb2: std_logic_vector(2 downto 0); 
 signal out_trig_tb3: std_logic_vector(2 downto 0); 
 signal tb_clk: std_logic:='0';
 signal tb_bar_enable: std_logic_vector(7 downto 0); 

begin
-- we assign actual module I/P, O/P => tb_module I/P, O/P.
 test_name: Veto_BM PORT MAP(CLK_PCLK_RIGHT => tb_clk,
                             INP => tb_input,
							 bar_enable_mask=> tb_bar_enable, 
                             OutpA=>out_trig_tb1,
							 OutpB=>out_trig_tb2, 
							 OutpC=>out_trig_tb3);
					   
tb_clk <= not tb_clk after 3ns;

stim_proc:process
begin

wait for 10ns;
tb_bar_enable   <= "00000000"; 
tb_input(15 downto 8) <= "11001100";


wait for 10ns;
tb_input(7 downto 0) <= "11111001";


--tb_input(8) <= '1';
--tb_input(9) <= '0';
--tb_input(0) <= '0';
--tb_input(1) <= '0';


--wait for 5ns;
--tb_input(7 downto 0) <= "00000000";



--tb_input(0) <= '1';

--tb_input(2) <= '1';
--wait for 20ns;

--tb_input(7 downto 0) <= "00000000";

wait for 5ns; 
tb_input(15 downto 8) <= "11111111";

--in_trig_tb(7 downto 5) <= "111";
--wait for 5ns;

--in_trig_tb(7 downto 5) <= "000";
--wait for 5ns;

--in_trig_tb(9 downto 4) <= "111111"; 
--wait for 10ns;

--in_trig_tb(9 downto 4) <= "000000";
--wait for 10ns;


--std.env.stop;

end process;
end archDB;