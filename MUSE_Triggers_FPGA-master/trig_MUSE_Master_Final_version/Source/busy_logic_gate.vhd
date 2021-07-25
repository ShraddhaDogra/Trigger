----------------------------------------------------------------
------------------- Ievgen Lavrukhin ---------------------------
----- This is a busy logic gate for a master trigger logic --
----- The gate produce AND and OR outputs of enabled channels --
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use Ieee.std_logic_UNSIGNED.all;

library work;
use work.trb_net_std.all;


entity busy_logic_gate is  
  generic(
	CH_NUMBER : integer := 16
  );
  port (
    busy_ch			: in std_logic_vector(CH_NUMBER - 1 downto 0);
    busy_mask 		: in std_logic_vector(CH_NUMBER - 1 downto 0); 
    busy_out  		: out std_logic
  );
end busy_logic_gate;

architecture arch of busy_logic_gate is
  signal sig_AND_logic	: std_logic_vector(CH_NUMBER - 1 downto 0) :=(others => '0'); 

----------------------- CODE ------------------------------------------
begin


  sig_AND_logic	<= ((busy_mask AND busy_ch) OR NOT(busy_mask));
  
  busy_out	<= and_all(sig_AND_logic); 
  
  
end arch;
