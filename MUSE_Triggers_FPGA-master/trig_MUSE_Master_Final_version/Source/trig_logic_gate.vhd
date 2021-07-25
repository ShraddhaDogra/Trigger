----------------------------------------------------------------
------------------- Ievgen Lavrukhin ---------------------------
----- This is a trigger logic gate for a master trigger logic --
----- The gate produce AND and OR outputs of enabled channels --
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use Ieee.std_logic_UNSIGNED.all;

library work;
use work.trb_net_std.all;


entity trig_logic_gate is  
  generic(
	CH_NUMBER : integer := 32
  );
  port (
    trig_ch	: 		in std_logic_vector(CH_NUMBER - 1 downto 0);
    trig_mask 		: in std_logic_vector(CH_NUMBER - 1 downto 0); 
    trig_AND_out  	: out std_logic; 
	trig_OR_out		: out std_logic
  );
end trig_logic_gate;

architecture arch of trig_logic_gate is
  signal sig_AND_logic	: std_logic_vector(CH_NUMBER - 1 downto 0) :=(others => '0'); 
  signal sig_OR_logic	: std_logic_vector(CH_NUMBER - 1 downto 0) :=(others => '0'); 

----------------------- CODE ------------------------------------------
begin
--- AND and OR GATE LOGIC for enabled channels:
-- The truth table for this logic looks like this: 
-- |  trig_mask  |   trig_ch     |   sig_AND_logic  |  sig_OR_logic  | 
-- |      1      |       1       |        1         |       1        |
-- |      1      |       0       |        0         |       0        |
-- |      0      |       1       |        1         |       0        |
-- |      0      |       0       |        1         |       0        |
------------------------------------------------------------------------

  sig_AND_logic	<= ((trig_mask AND trig_ch) OR NOT(trig_mask));
  sig_OR_logic	<= (trig_mask AND trig_ch);
  
  trig_AND_out	<= and_all(sig_AND_logic) and or_all(trig_mask); 
  trig_OR_out	<= or_all(sig_OR_logic);
  
  
end arch;
