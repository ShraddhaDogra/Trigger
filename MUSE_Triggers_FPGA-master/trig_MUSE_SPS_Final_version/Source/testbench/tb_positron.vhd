-- This is testbench for positron absorption.
-- ////////////////////// Written by Shraddha Dogra.//////////



library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

library work;
use work.trb_net_std.all;

entity tb_positron is
end entity tb_positron; -- 

architecture Behavioral of tb_positron is 

component positron_absorption is
 port (--in_clk: in std_logic;
	  in_front_bars: in std_logic_vector (17 downto 0);
	  in_back_bars: in std_logic_vector (27 downto 0);
	  Out_positron_absorption: out std_logic); 
end component;

      signal tb_in_front_bars: std_logic_vector (17 downto 0) :=(others=> '0');
      signal tb_in_back_bars:  std_logic_vector (27 downto 0) :=(others => '0');
	  signal tb_Out_positron_absorption:  std_logic := '0';
	  signal tb_clk: std_logic:='0';


begin

test: positron_absorption PORT MAP(
					--in_clk => tb_clk, 
					in_front_bars => tb_in_front_bars,
        			in_back_bars => tb_in_back_bars,		-- 0 to 17 are front, 18 to 47 are back
                    Out_positron_absorption => tb_Out_positron_absorption);
					   
--tb_clk <= not tb_clk after 5ns;

stim_proc:process
begin
wait for 10ns;


 tb_in_front_bars (0) <= '1';
 wait for  5ns;
 tb_in_back_bars (0) <= '1';
 wait for 10ns;
 
 tb_in_front_bars (0) <= '0';
 tb_in_back_bars (0) <= '0';
 wait for 10 ns;
 
 tb_in_front_bars (7 downto 0) <= "00111110";
 wait for 15ns;
 tb_in_back_bars (7 downto 0) <= "01111110";
 wait for 10ns;
 
 tb_in_front_bars (7 downto 0) <= "00000000";
  wait for 10ns;
  

  
 --tb_in_front_bars (7 downto 0) <= "01111110";
 --wait for 50ns;
 
  tb_in_front_bars (7 downto 0) <= "00000000";
  wait for 20ns;
  
  tb_in_back_bars (7 downto 0) <= "00000000";
  wait for 20ns;

end process;

end Behavioral;
