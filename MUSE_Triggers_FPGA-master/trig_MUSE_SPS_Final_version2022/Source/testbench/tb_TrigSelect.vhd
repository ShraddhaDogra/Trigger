-- This is testbench for Trig_Selector.
-- ////////////////////// Written by Shraddha Dogra.//////////



library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

library work;
use work.trb_net_std.all;

entity tb_TrigSelect is
end entity tb_TrigSelect;

architecture Behavioral of tb_TrigSelect is 

component trig_selector is
 generic(
    N : integer := 4  -- number of trig_Select inputs
        ); 
 port (
       in_trig_signal: in std_logic_vector (N-1 downto 0);
       out_trig_selector: out std_logic;
	   trig_select: in std_logic_vector (3 downto 0)
	   );
end component;

      signal tb_in_trig_signal: std_logic_vector (3 downto 0) :=(others=> '0');
      signal tb_out_trig_selector:  std_logic :='0';
	  signal tb_trig_select:  std_logic_vector (3 downto 0) :=(others=> '0');
	  signal tb_clk: std_logic:='0';


begin

test: trig_selector PORT MAP(
					--in_clk => tb_clk, 
					in_trig_signal => tb_in_trig_signal,
        			out_trig_selector => tb_out_trig_selector,		-- 0 to 17 are front, 18 to 47 are back
                    trig_select => tb_trig_select);
					   
--tb_clk <= not tb_clk after 5ns;

stim_proc:process
begin

 wait for 10 ns;
 tb_trig_select (3 downto 0) <= "0011";
 wait for 50ns;
 
 tb_in_trig_signal(0) <= '1';
 wait for 20ns; 
 tb_in_trig_signal(0) <= '0';
 
 tb_in_trig_signal(1) <= '1';
 wait for 25ns;
  tb_in_trig_signal(1) <= '0';

 
 tb_in_trig_signal(2) <= '1';
 wait for 50ns;
 tb_in_trig_signal(2) <= '0';
 
 tb_in_trig_signal(3) <= '1';
 wait for 45 ns;
 tb_in_trig_signal(3) <= '0'; 
 

 --tb_trig_select (3 downto 0) <= "0000";
 --wait for 10ns;

 
 

end process;

end Behavioral;
