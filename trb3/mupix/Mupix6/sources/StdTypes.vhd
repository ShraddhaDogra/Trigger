------------------------------------------------------------
--! @file
--! @brief definition of types used in Readout for Mupix 6
--! @author Tobias Weber
--! @date August 2017
------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package StdTypes is

  type MupixReadoutCtrl is record  --control signals for mupix readout state machine
    ldpix      : std_logic;             --load pixel
    ldcol      : std_logic;             --load column
    rdcol      : std_logic;             --read column
    pulldown   : std_logic;             --pull down
    timestamps : std_logic_vector(7 downto 0);  --timestamps to chip
  end record MupixReadoutCtrl;

  type MupixReadoutData is record       --readout data from the mupix chip
    priout   : std_logic;               --priority out
    hit_col  : std_logic_vector(5 downto 0);  --hit column
    hit_row  : std_logic_vector(5 downto 0);  --hit row
    hit_time : std_logic_vector(7 downto 0);  --hit time
  end record MupixReadoutData;

  type MupixSlowControl is record       --slow control signals for mupix chip
    ck_d : std_logic;                   --clock d
    ck_c : std_logic;                   --clock c
    ld_c : std_logic;                   --load c
    sin  : std_logic;                   --serial data in
  end record MupixSlowControl;

  constant MuPixSlowControlInit : MupixSlowControl := (ck_d => '0', ck_c => '0', ld_c => '0', sin => '0');
  
end package StdTypes;
