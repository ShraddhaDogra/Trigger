-------------------------------------------------------------------------------
-- Title      : Stretcher
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Stretcher.vhd
-- Author     : cugur@gsi.de
-- Created    : 2012-11-07
-- Last update: 2018-02-01
-------------------------------------------------------------------------------
-- Description: Jan's counting
-------------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Stretcher is
  generic (
    CHANNEL : integer range 1 to 64 := 1;
    DEPTH   : integer range 1 to 64 := 3);
  port (
    PULSE_IN  : in  std_logic_vector(CHANNEL-1 downto 0);
    PULSE_OUT : out std_logic_vector(CHANNEL*DEPTH-1 downto 0));

end Stretcher;

architecture behavioral of Stretcher is

  signal pulse_a_in  : std_logic_vector(CHANNEL*DEPTH-1 downto 0);
  signal pulse_a_out : std_logic_vector(CHANNEL*DEPTH-1 downto 0);
  signal pulse_b_in  : std_logic_vector(CHANNEL*DEPTH-1 downto 0);
  signal pulse_b_out : std_logic_vector(CHANNEL*DEPTH-1 downto 0);

begin  -- behavioral

  GEN : for i in 0 to CHANNEL-1 generate
    pulse_a_in(DEPTH*i+DEPTH-1)                <= PULSE_IN(i);
    pulse_a_in(DEPTH*i+DEPTH-2 downto DEPTH*i) <= pulse_b_out(DEPTH*i+DEPTH-1 downto DEPTH*i+1);
    pulse_b_in(DEPTH*i+DEPTH-1 downto DEPTH*i+1) <= pulse_a_out(DEPTH*i+DEPTH-1 downto DEPTH*i+1);
--     PULSE_OUT(i-1)                             <= transport not pulse_a_out(DEPTH*(i-1)) after 42.186 ns;
  end generate GEN;

  PULSE_OUT <= pulse_b_out;

  Stretcher_A_1 : entity work.Stretcher_A
    generic map (
      CHANNEL => CHANNEL,
      DEPTH   => DEPTH)
    port map (
      PULSE_IN  => pulse_a_in,
      PULSE_OUT => pulse_a_out);

  Stretcher_B_1 : entity work.Stretcher_A
    generic map (
      CHANNEL => CHANNEL,
      DEPTH   => DEPTH)
    port map (
      PULSE_IN  => pulse_b_in,
      PULSE_OUT => pulse_b_out);

end behavioral;
