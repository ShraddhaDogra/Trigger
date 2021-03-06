library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use Ieee.std_logic_UNSIGNED.all;

library work;
use work.trb_net_std.all;

entity sps_control is	
	port (
		in_sig		 	: in std_logic_vector(47 downto 0):= (others => '1'); --trigger input channels on 4ConnBoard
		bar_enable_mask	: in std_logic_vector(47 downto 0) := (others => '1'); --mask of connected trigger channels (each bit correspods to the channel enable/disable)
		out_sig 		: out std_logic_vector(47 downto 0)  -- trigger logic output
	);
end sps_control;

architecture  sps_control_arch of sps_control is

 begin 
  out_sig <= bar_enable_mask AND in_sig;
  
end sps_control_arch;