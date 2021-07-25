---------------------------------------------
----------- Ievgen Lavrukhin ----------------
-- This is a Master trigger logic for MUSE --
---------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use Ieee.std_logic_UNSIGNED.all;

library work;
use work.trb_net_std.all;


entity trigger_OR_enabled is	
	port (
		trig_ch 	: in std_logic_vector(47 downto 0); --trigger input channels on 4ConnBoard
		trig_mask	: in std_logic_vector(47 downto 0); --mask of connected trigger channels (each bit correspods to the channel enable/disable)
		trig_out 	: out std_logic  -- trigger logic output
	);
end trigger_OR_enabled;

architecture  trigger_OR_enabled_arch of trigger_OR_enabled is
-- Additional signals --
	signal trig_logic_in	: std_logic_vector(47 downto 0) :=(others => '0'); --initially we assigning all trigger channels to 0. 
-- Beging the trigger logic code --
begin  


-- Using 'trig_mask' we can assing a proper 'trig_logic_in' to the enabled trigger channels "trig_ch"
-- The truth table for this logic looks like this: ----------------------------------------------------
-- |  trig_mask  |   trig_ch     |   trig_logic_in | 
-- |      1      |       1       |        1        |
-- |      1      |       0       |        0        |
-- |      0      |       1       |        0        |
-- |      0      |       0       |        0        |
-------------------------------------------------------------------------------------------------------
	trig_logic_in <= (trig_mask AND trig_ch); -- only enabled channels will contribute into final OR others will be set to '0'

-- And all trigger channels togather: 'or_all' function is defined in ../../trbnet/trb_net_std.vhd file
	trig_out <= or_all(trig_logic_in); 

end trigger_OR_enabled_arch;
