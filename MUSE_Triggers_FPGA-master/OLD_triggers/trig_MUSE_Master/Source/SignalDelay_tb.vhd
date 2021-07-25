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

ENTITY tb_signal_delay IS
END tb_signal_delay;

ARCHITECTURE behavior OF tb_signal_delay IS

-- Component Declaration for the Unit Under Test (UUT)

component signal_delay is
    generic (
      Width : integer;
      Delay : integer);
    port (
      clk_in   : in  std_logic;
      write_en_in : in std_logic;
      delay_in : in  std_logic_vector(Delay - 1 downto 0);
      sig_in   : in  std_logic_vector(Width - 1 downto 0);
      sig_out  : out std_logic_vector(Width - 1 downto 0));
end component signal_delay;

--Inputs
signal clk_in 		: std_logic := '0';
signal sig_in		: std_logic	:= '0';
signal delay_value	: std_logic_vector(4 downto 0)	:= (others => '0');

--Outputs
signal sig_out : std_logic;

-- Clock period definitions
constant clock_period : time := 10 ns; -- 100MHz Clocks 
constant half_period  : time := 5 ns;
BEGIN

-- Instantiate the Unit Under Test (UUT)
uut: signal_delay generic map (
      Width => 1,
      Delay => 5)
     port map (
      clk_in   => clk_in,
      write_en_in => '1',
--      delay_in => std_logic_vector(to_unsigned(10, 5)),
	  delay_in	  =>delay_value,
	  sig_in(0)   => sig_in,
      sig_out(0)  => sig_out);
	  

-------------------- Stimulus process ----------------------------

-- Geneateration clocks for TB:
clk_in <= not clk_in after half_period;

stim_proc: process
begin
-- All channels enabled -----
delay_value <= std_logic_vector(to_unsigned(1, 5));
wait for 100 ns;
sig_in   <= '1';
wait for 10 ns;
sig_in   <= '0';
wait for 300 ns;
delay_value <= std_logic_vector(to_unsigned(0, 5));
wait for 100 ns;
sig_in   <= '1';
wait for 30 ns;
sig_in   <= '0';
wait for 300 ns;
delay_value <= std_logic_vector(to_unsigned(2, 5));
wait for 100 ns;
sig_in   <= '1';
wait for 50 ns;
sig_in   <= '0';
wait for 300 ns;
delay_value <=std_logic_vector(to_unsigned(10, 5));
wait for 100 ns;
sig_in   <= '1';
wait for 70 ns;
sig_in   <= '0';
wait for 300 ns;
sig_in   <= '0';
wait;
end process;

END;
