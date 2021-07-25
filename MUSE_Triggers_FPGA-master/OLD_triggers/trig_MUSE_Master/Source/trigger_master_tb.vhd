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

ENTITY tb_trigger_master IS
END tb_trigger_master;

ARCHITECTURE behavior OF tb_trigger_master IS

-- Component Declaration for the Unit Under Test (UUT)
COMPONENT trigger_master is
 port (
	 trig_ch 	: in std_logic_vector(47 downto 0);
	 trig_mask	: in std_logic_vector(47 downto 0);
	 trig_out 	: out std_logic
 );
end COMPONENT;


--Inputs
signal trig_ch 	: std_logic_vector(47 downto 0);
signal trig_mask: std_logic_vector(47 downto 0);

--Outputs
signal trig_out : std_logic;

-- Clock period definitions
constant clock_period : time := 20 ns;

BEGIN

-- Instantiate the Unit Under Test (UUT)
uut: trigger_master PORT MAP (
trig_ch => trig_ch,
trig_mask=> trig_mask,
trig_out => trig_out
);

-- Stimulus process
stim_proc: process
begin
-- All channels enabled -----
trig_mask <= x"ffffffffffff";
trig_ch   <= x"000000000000";
wait for 20 ns;
trig_mask <= x"ffffffffffff";
trig_ch   <= x"ffffffffffff";
wait for 20 ns;
trig_ch   <= x"000000000000";
wait for 20 ns;
trig_ch   <= x"000000ffffff";
wait for 20 ns;
trig_ch   <= x"ffffffffffff";
wait for 20 ns;
trig_ch   <= x"000000000000";
wait for 20 ns;
trig_ch   <= x"000fffffffff";
wait for 20 ns;
trig_ch   <= x"000000000000";
wait for 20 ns;
trig_ch   <= x"ffffffffffff";
wait for 20 ns;
trig_ch   <= x"000000000000";
wait for 100 ns;
trig_mask <= x"00000000ffff";
trig_ch   <= x"ffffffffffff";
wait for 20 ns;
trig_ch   <= x"000000000000";
wait for 20 ns;
trig_ch   <= x"0000000fffff";
wait for 20 ns;
trig_ch   <= x"000000000000";
wait for 20 ns;
trig_ch   <= x"000000000fff";
wait for 20 ns;
trig_ch   <= x"ffff00000000";
wait for 20 ns;
trig_ch   <= x"000000000000";
wait for 20 ns;
trig_ch   <= x"00fff0000000";
wait for 20 ns;
trig_ch   <= x"ffff0000ffff";
wait for 20 ns;
trig_ch   <= x"000000000000";
wait;
end process;

END;
