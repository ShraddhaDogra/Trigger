-- This code is a 48 bit implementation of 1-bit signal_stretch code written by Ievgen.
---/// Written by Shraddha Dogra.



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity tb_sig_stretch48 is   
 --();
end tb_sig_stretch48;
	 
ARCHITECTURE archDB OF tb_sig_stretch48 IS

signal tb_In: std_logic_vector (47 downto 0):=(others=> '0');
signal tb_clk: std_logic:='0';
signal tb_Out: std_logic_vector (47 downto 0);

-- Component Declaration for the Unit Under Test (UUT)

component signal_stretch_48 is 
  port(
     input :  in std_logic_vector(47 downto 0);
     clk_in   : in  std_logic; -- 100 MHz clocks;
     output  : out std_logic_vector (47 downto 0)
	);
end component signal_stretch_48;

begin
-- we assign actual module I/P, O/P => tb_module I/P, O/P.
test_name: signal_stretch_48 PORT MAP(clk_in=> tb_clk, input => tb_In, 
                       output=>tb_Out);
					   
tb_clk <= not tb_clk after 5ns;

stim_proc:process
begin

wait for 40ns;

tb_In(0) <='1';
wait for 10ns;

tb_In(0)<= '0';
wait for 80ns;

tb_In(2)<= '1';
wait for 10ns;

tb_In(2)<= '0';
wait for 80ns;

tb_In(0)<= '1';
wait for 10ns;

tb_In(0)<= '0';
wait for 80ns;

--tb_In(0)<= '1';
--wait for 5ns;

--tb_In(5)<= '1';
--wait for 5ns;

--tb_In(5)<= '0';
--wait for 30ns;

--tb_In(5)<='0';
--wait for 30ns;

--tb_clk <='0';  --wait for 5ns; 

--tb_In(5) <='1';


end process;
end archDB;