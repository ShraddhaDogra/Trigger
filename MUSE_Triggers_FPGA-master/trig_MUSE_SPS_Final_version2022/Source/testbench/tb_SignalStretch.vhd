-------------------------------------------------------------
------------------- Ievgen Lavrukhin ------------------------
-- This is a test bench for  Master trigger logic for MUSE --
-------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY tb_signal_stretch IS
END tb_signal_stretch;

ARCHITECTURE behavior OF tb_signal_stretch IS

-- Component Declaration for the Unit Under Test (UUT)

component signal_stretch is
    generic (
      Stretch : integer);
    port (
      sig_in   : in  std_logic;
      clk_in : in std_logic;
      sig_out  : out std_logic
	);
end component signal_stretch;

--Inputs
signal clk_in 		: std_logic := '0';
signal sig_in		: std_logic := '0';

--Outputs
signal sig_out : std_logic;

-- Clock period definitions
constant clock_period : time := 10 ns; -- 100MHz Clocks 
constant half_period  : time := 5 ns;
BEGIN

-- Instantiate the Unit Under Test (UUT)
uut: signal_stretch generic map (
      Stretch => 10
     )
     port map (
      sig_in   => sig_in,
      clk_in   => clk_in,
      sig_out  => sig_out);
	  

-------------------- Stimulus process ----------------------------

-- Geneateration clocks for TB:
clk_in <= not clk_in after half_period;

stim_proc: process
begin
-- All channels enabled -----
wait for 15 ns;
sig_in   <= '1';
wait for 10 ns;
sig_in   <= '0';
wait for 200 ns;
sig_in   <= '1';
wait for 20 ns;
sig_in   <= '0';
wait for 200 ns;
sig_in   <= '1';
wait for 30 ns;
sig_in   <= '0';
wait for 180 ns;
sig_in   <= '1';
wait for 40 ns;
sig_in   <= '0';
wait for 200 ns;
sig_in   <= '1';
wait for 50 ns;
sig_in   <= '0';
wait;
end process;

END;
