-- This is testbench for sps_COntrol.
-- ////////////////////// Written by Shraddha Dogra.//////////



library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

library work;
use work.trb_net_std.all;

entity tb_spsControl is
end entity tb_spsControl;

architecture Behavioral of tb_spsControl is 

component sps_control is
port(
        in_sig 	: in std_logic_vector(47 downto 0):= (others => '1'); --trigger input channels on 4ConnBoard
		bar_enable_mask	: in std_logic_vector(47 downto 0) := (others => '1'); --mask of connected trigger channels (each bit correspods to the channel enable/disable)
		out_sig 	: out std_logic_vector(47 downto 0) 
     );		-- trigger logic output;
end component;

      signal tb_trig_ch: std_logic_vector (47 downto 0) :=(others=> '1');
      signal tb_bar_enable_mask:  std_logic_vector (47 downto 0):= (others=> '1');
	  signal tb_trig_out:  std_logic_vector (47 downto 0) :=(others=> '1');
	  --signal tb_clk: std_logic:='0';


begin
 
test: sps_control PORT MAP(
					in_sig => tb_trig_ch,
        			bar_enable_mask => tb_bar_enable_mask,		-- 0 to 17 are front, 18 to 47 are back
                    out_sig => tb_trig_out);
					   

stim_proc:process
begin

 wait for 10 ns;
 
 tb_bar_enable_mask (3 downto 0) <= "0000";
 wait for 30ns;
 
 tb_bar_enable_mask (3 downto 0) <= "1111";
 wait for 30ns;
 
 
 
 tb_bar_enable_mask(5) <= '0';
 wait for 20ns;
 
 tb_bar_enable_mask(5) <= '1';
 
 tb_bar_enable_mask(32) <= '0';
 wait for 25ns;
 
 tb_bar_enable_mask(32) <= '1';
 wait for 10 ns;
 
 tb_bar_enable_mask (20 downto 0) <= "000000001100010001010";
 wait for 30ns;
 
  tb_bar_enable_mask (20 downto 0) <= "010101011111111111111"; 
 
 
end process;

end Behavioral;
