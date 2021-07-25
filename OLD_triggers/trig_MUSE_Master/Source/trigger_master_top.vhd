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
use work.basic_type_declaration.all; 
 
entity trigger_master_top is	
	port (
		trig_ch 			: in std_logic_vector(47 downto 0); --trigger input channels on 4ConnBoard;
		trig_mask_0			: in std_logic_vector(47 downto 0); --mask 0 of connected trigger channels (each bit correspods to the channel enable/disable);
		trig_mask_1			: in std_logic_vector(47 downto 0); --mask 1 of connected trigger channels (each bit correspods to the channel enable/disable);
		trig_ch_delay		: in array5(47 downto 0); --mask of 5 bit delays for every trigger channel; 
		clk_in				: in std_logic;
		trig_out_OR			: out std_logic;  -- debuging output for trigger OR (enabled channes only) logic;
		trig_out_dir 		: out std_logic;  -- direct trigger logic output without stretching;
		trig_out_lat		: out std_logic;  -- '1 us' latched trigger output without stretching;
		trig_out_50ns_lat	: out std_logic;  -- '1 us' latched trigger output with 50 ns  stretching; 
		trig_out_150ns_lat	: out std_logic  -- '1 us' latched trigger output with 150 ns stretching;
	);
end trigger_master_top;

architecture  trigger_master_top_arch of trigger_master_top is
-- Additional signals --
	signal trig_ch_delayed		: std_logic_vector(47 downto 0); -- trigger input channels after delay
	signal trig_logic_main		: std_logic_vector(1 downto 0); -- one output for each mask
	signal trig_logic_OR		: std_logic_vector(1 downto 0); --one for each mask
	signal trig_main_combo		: std_logic; -- combined output of all ORs from every mask
	signal trig_OR_combo		: std_logic; -- combined output of all ORs from every mask
	signal trig_logic_lat		: std_logic;
	signal trig_logic_50ns_lat	: std_logic;
	signal trig_logic_150ns_lat	: std_logic;
	
-- Component Definitions:
	-- Delay each trigger intup by the value specified in trig_ch_delay:
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
	-- Main Trigger Logic:
	component trigger_master is
		port (
			trig_ch 	: in std_logic_vector(47 downto 0);
			trig_mask	: in std_logic_vector(47 downto 0);
			trig_out 	: out std_logic
		);
	end component trigger_master;
	-- An Additional Trigger Logic that may be used to test delays and which channels are enabled:
	component trigger_OR_enabled is
		port (
			trig_ch 	: in std_logic_vector(47 downto 0);
			trig_mask	: in std_logic_vector(47 downto 0);
			trig_out 	: out std_logic
		);
	end component trigger_OR_enabled;
	-- This entity stretches the signal by a number of clock cycles:
	component signal_stretch is
		generic(
			Stretch : integer  -- number of clock cycles during which the signal will be stretched
		);
		port(
			sig_in   : in  std_logic; -- input signal should be longer that clock period;
			clk_in   : in  std_logic; -- 100 MHz clocks;
			sig_out  : out std_logic  -- stretched signal output;
		);
	end component signal_stretch;
	
	-- This is a gated trigger output:
	component signal_gated is
		generic(
			GateWidth: integer:= 100 --Number of clock cycled to stretch the signal 100x10ns = 1us
		);
		port(
			sig_in   : in  std_logic;
			clk_in   : in  std_logic;
			sig_out  : out std_logic
		);
	end component signal_gated;
	
begin  
-------------------------------------   CODE: -------------------------------------------------------
----- Assigning delays to each triger input using trig_ch_delayed 2D vector:
GEN_DELAY:
	for i in 0 to 47 generate
	DELAY:	signal_delay generic map (
				Width => 1,
				Delay => 5)
			port map (
				clk_in   => clk_in,
				write_en_in => '1',
				delay_in	  =>trig_ch_delay(i),
				sig_in(0)   => trig_ch(i),
				sig_out(0)  => trig_ch_delayed(i));
    end generate GEN_DELAY;

----- Implementing trigger logic after synchronizing trig_ch_inputs using delays:
GEN_TRIG_LOGIC_0:
	trigger_master port map (
		trig_ch => trig_ch_delayed,
		trig_mask=> trig_mask_0,
		trig_out => trig_logic_main(0)
		);

GEN_TRIG_LOGIC_1:
	trigger_master port map (
		trig_ch => trig_ch_delayed,
		trig_mask=> trig_mask_1,
		trig_out => trig_logic_main(1)
		);
----- OR all enabled channels after proper delay: (For test purposes)
GEN_TRIG_OR_0:
	trigger_OR_enabled port map (
		trig_ch => trig_ch_delayed,
		trig_mask=> trig_mask_0,
		trig_out => trig_logic_OR(0)
		);
GEN_TRIG_OR_1:
	trigger_OR_enabled port map (
		trig_ch => trig_ch_delayed,
		trig_mask=> trig_mask_1,
		trig_out => trig_logic_OR(1)
		);

    --Combine outpus from every mask:
	trig_main_combo <= trig_logic_main(1) or trig_logic_main(0);
	trig_OR_combo	<= trig_logic_OR(1)   or trig_logic_OR(0);
	
--- Producing 1 us selfgated trigger output. (no other trigger during 1us after the first trigger)
Trig_Gated:
	signal_gated generic map(
			GateWidth =>  100 --Number of clock cycled to stretch the signal 100x10ns = 1us
		)
		port map(
			sig_in	=> trig_main_combo,   
			clk_in  => clk_in,
			sig_out => trig_logic_lat
		);

----- Producing a Gated trigger output, 50 ns wide: 
Trig_Gated_50ns: 
	signal_stretch generic map(
			Stretch => 5  -- stretched pulse should be 50 ns = 5 x 10 ns;
		)
		port map(
			sig_in   => trig_logic_lat, 
			clk_in   => clk_in, 
			sig_out  => trig_logic_50ns_lat
			);
			
----- Producing a Gated trigger output, 150 ns wide: 
Trig_Gated_150ns: 
	signal_stretch generic map(
			Stretch => 20-- stretched pulse should be 150 ns = 15 x 10 ns;
		)
		port map(
			sig_in   => trig_logic_lat, 
			clk_in   => clk_in, 
			sig_out  => trig_logic_150ns_lat
			);
		
-- Assigning output channels to the trigger decisions:-------------------------------------------------
	trig_out_OR			<= trig_OR_combo;
	trig_out_dir		<= trig_main_combo;
	trig_out_lat		<= trig_logic_lat;
	trig_out_50ns_lat	<= trig_logic_50ns_lat;
	trig_out_150ns_lat	<= trig_logic_150ns_lat;
	
	
end trigger_master_top_arch;