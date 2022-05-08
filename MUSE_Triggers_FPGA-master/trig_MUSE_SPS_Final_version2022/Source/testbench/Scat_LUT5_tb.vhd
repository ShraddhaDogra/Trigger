--- tHIS IS  a testbench for Scat_LUT5 trigger.
---// Written by Win Lin. /////------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use std.env.stop;

entity Scat_LUT5_tb is 
end Scat_LUT5_tb;

architecture Behavioral of Scat_LUT5_tb is 

component Scat_LUT5 is
port(
     in_clk: in std_logic;
	 in_front_bars: in std_logic_vector (17 downto 0);
	 in_back_bars: in std_logic_vector (45 downto 18);
	 out_scat_LUT5: out std_logic);
end component Scat_LUT5;

signal tb_input_front: std_logic_vector (17 downto 0):=(others=> '0');
signal tb_input_back: std_logic_vector (45 downto 18):=(others=> '0');
signal tb_clk: std_logic:='0';
signal tb_output: std_logic:='0';

begin

test: Scat_LUT5 PORT MAP(
					in_clk => tb_clk, 
					in_front_bars => tb_input_front,
        			in_back_bars => tb_input_back,		-- 0 to 17 are front, 18 to 47 are back
                    out_scat_LUT5 => tb_output);
					   
tb_clk <= not tb_clk after 5ns;

stim_proc:process
begin

wait for 10 ns;
tb_input_front(0) <= '1';
wait for 1.2 ns;
tb_input_back(18) <= '1';

wait for 8.8 ns;
tb_input_front(0) <= '0';
wait for 1.2 ns;
tb_input_back(18) <= '0';

wait for 100 ns;

front_loop:
 for i in 0 to 17 loop
	back_loop:
	 for j in 18 to 45 loop
		wait for 10 ns;
		tb_input_front(i) <= '1';
		tb_input_back(j) <= '1';
		wait for 10ns;
		tb_input_front(i) <= '0';
		tb_input_back(j) <= '0';
		wait for 100 ns;
	end loop back_loop;
end loop front_loop;

--std.env.stop;

end process;

end Behavioral;
