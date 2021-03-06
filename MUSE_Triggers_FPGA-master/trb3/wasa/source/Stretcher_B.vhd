-------------------------------------------------------------------------------
-- Title      : Stretcher_B
-- Project    : TRB3
-------------------------------------------------------------------------------
-- File       : Stretcher_B.vhd
-- Author     : Cahit Ugur  <c.ugur@gsi.de>
-- Created    : 2014-11-24
-- Last update: 2018-02-01
-------------------------------------------------------------------------------
-- Description: Jan's counting
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-11-24  1.0      cugur   Created
-------------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Stretcher_B is
  generic (
    CHANNEL : integer range 1 to 64;
    DEPTH   : integer range 1 to 64 := 3);
  port (
    PULSE_IN  : in  std_logic_vector(CHANNEL*DEPTH-1 downto 0);
    PULSE_OUT : out std_logic_vector(CHANNEL*DEPTH-1 downto 0));

end entity Stretcher_B;

architecture behavioral of Stretcher_B is

  signal pulse : std_logic_vector(CHANNEL*DEPTH-1 downto 0);

  attribute syn_keep              : boolean;
  attribute syn_keep of pulse     : signal is true;
  attribute syn_preserve          : boolean;
  attribute syn_preserve of pulse : signal is true;
  attribute NOMERGE               : string;
  attribute NOMERGE of pulse      : signal is "KEEP";

begin  -- architecture behavioral

  pulse     <= PULSE_IN;
  PULSE_OUT <= not pulse;

end architecture behavioral;
