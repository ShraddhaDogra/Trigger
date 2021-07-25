-------------------------------------------------------------------------------------
----------- Ievgen Lavrukhin --------------------------------------------------------
-- This is a Master trigger logic for MUSE ------------------------------------------
-- 48 input channels are devided into BUSY (defalut 16) and 
-------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use Ieee.std_logic_UNSIGNED.all;

library work;
use work.trb_net_std.all;
use work.basic_type_declaration.all;

entity trigger_master is
	generic(
		LOG_GATE_NUMBER : integer := 16; -- number of first input channels allocated for NOT_BUSY channel
		LATCH_WIDTH		: integer := 100; -- deadtime of number of clock cycles after successful trigger decision
		TRIG_WIDTH		: integer := 5 -- the width of the final trigger output;
	);
	port (
		--- Trigger: -------------------------------------------
		trig_in				: in std_logic_vector (31 downto 0);
		trig_delay	  	 	: in array5(31 downto 0);  --register that contains delay values
		trig_mask	     	: in array32 (LOG_GATE_NUMBER-1 downto 0);
		--- Trigger Logic Gate ---------------------------------
		trig_logic_prescaler	: in  array4(0 to LOG_GATE_NUMBER-1);  -- prescale factor for each logic gate output
		--- BUSY: ----------------------------------------------
		not_busy_in     	: in std_logic_vector(15 downto 0); 
		not_busy_mask		: in std_logic_vector(15 downto 0);
		--- OTHER inputs: ---------------------------------------
		clk_in        		: in std_logic;
		reset				: in std_logic;  -- resets all counters
		write_enable		: in std_logic;  -- this if '1' -triggers bypass the delay, if '0' no triggers path any further
		--- TRIG outputs: --------------------------------------- 
		trig_dir_out			: out std_logic;
		trig_dir_nb_out			: out std_logic;
		trig_latch_50ns_out		: out std_logic;
		trig_debug_OR_out		: out std_logic;
		--- COUNTER outputs: ------------------------------------
		trig_in_counter			: out array32 (31 downto 0); -- counter to store rates for trig_input signals
		trig_gate_counter		: out array32 (LOG_GATE_NUMBER-1 downto 0); -- counter of rates from each trigger logic output before prescaler
		trig_prescale_counter	: out array32 (LOG_GATE_NUMBER-1 downto 0); -- counter of rates from trig logic gates after prescaler
		trig_dir_counter		: out std_logic_vector(31 downto 0); -- counter to store the rate of direct trigger output;
		trig_dir_nb_counter		: out std_logic_vector(31 downto 0); -- direct & not_busy logic;
		trig_latched_counter	: out std_logic_vector(31 downto 0); -- counter to store the rate of latched trigger output after BUSY logic;
        --- Trigger TYPE identifier: ----------------------------
		trig_type				: out std_logic_vector(31 downto 0) -- this is to store trigger type.
	);
end trigger_master;

architecture  trigger_master_arch of trigger_master is
------ Signals:
	signal trig_in_delayed			: std_logic_vector(31 downto 0); -- trigger input channels after delay
	signal trig_AND_gate_out		: std_logic_vector(LOG_GATE_NUMBER-1 downto 0); -- AND outputs from logic gate
	signal trig_gate_prescale_out	: std_logic_vector(LOG_GATE_NUMBER-1 downto 0); -- AND outputs from logic gate
	signal trig_OR_gate_out			: std_logic_vector(LOG_GATE_NUMBER-1 downto 0); -- AND outputs from logic gate
	
	signal trig_OR_dir				: std_logic; -- the direct OR of ORs;
	signal trig_direct				: std_logic; -- the direct OR of ALL trig_logic_gates;
	signal trig_direct_nb			: std_logic; -- "trig_direct" and NOT_BUSY;
	signal trig_latched				: std_logic; -- "trig_direct_nb" with 1us selfclear latch;
	signal trig_latched_50ns		: std_logic; -- "trig_latched" with  50 ns stretched;
	
	signal not_busy_AND_all			: std_logic;
	signal temp_type				: std_logic_vector(LOG_GATE_NUMBER-1 downto 0):=(others =>'0'); -- temp signal to store trig_type
	
------ Components definition:
	component signal_delay is  -- delay signals by the custom delay in order to match them all in time.
		generic (
			Width : integer;
			Delay : integer
		);
		port (
			clk_in		: in  std_logic;
			write_en_in	: in std_logic;
			delay_in	: in  std_logic_vector(Delay - 1 downto 0);
			sig_in   	: in  std_logic_vector(Width - 1 downto 0);
			sig_out  	: out std_logic_vector(Width - 1 downto 0)
		);
	end component signal_delay;
  
	component signal_stretch is -- stretch the signal to match the minimal signal width 
		generic(
			Stretch : integer 
		);
		port(
			sig_in   : in  std_logic; 
			clk_in   : in  std_logic; 
			sig_out  : out std_logic 
		);
	end component signal_stretch;
  
	component signal_gated is  -- latch signal to selfclear latch of the fixed lendth
		generic(
			GateWidth: integer 
		);
		port(
			sig_in   : in  std_logic;
			clk_in   : in  std_logic;
			sig_out  : out std_logic
		);
	end component signal_gated;

	component trig_logic_gate is  -- a single logical gate that produces AND & OR outputs of enabled channels  
		generic(
			CH_NUMBER : integer 
		);
		port (
			trig_ch			: in std_logic_vector(CH_NUMBER - 1 downto 0);
			trig_mask 		: in std_logic_vector(CH_NUMBER - 1 downto 0); 
			trig_AND_out  	: out std_logic; 
			trig_OR_out		: out std_logic
		);
	end component trig_logic_gate;

	component busy_logic_gate is  -- a single logical gate that produces AND & OR outputs of enabled channels  
		generic(
			CH_NUMBER : integer 
		);
		port (
			busy_ch			: in std_logic_vector(CH_NUMBER - 1 downto 0);
			busy_mask 		: in std_logic_vector(CH_NUMBER - 1 downto 0); 
			busy_out  		: out std_logic
		);
	end component busy_logic_gate;
	
	component prescale_trig_ch is  -- prescaller trig_logic_gate outputs
		generic(
			NUMBER : integer := 10  
		);
		port(
			sig_in  	  : in  std_logic_vector(NUMBER-1 downto 0);
			clk_in		  : in  std_logic;
			prescale_ch   : in  array4(0 to NUMBER-1); 
			reset		  : in  std_logic; 
			sig_out 	  : out std_logic_vector(NUMBER-1 downto 0)  
		);
	end component prescale_trig_ch;

	component counter_32bit is  -- 32 bit counter 
		port (
			input			: in std_logic;
			reset			: in std_logic;
			write_enable	: in std_logic;
			count			: out std_logic_vector(31 downto 0) 
		);
	end component counter_32bit;	

-- Component Declaration for the Unit Under Test (UUT)
	component trigger_type_ID is
		generic(
			INP_NUMBER : integer := 16 -- number of input trigger gate cahnnels 
		);
		port (
			trig_logic_inputs	: in std_logic_vector (INP_NUMBER -1 downto 0);
			trig_final			: in std_logic; 
			clk_in				: in std_logic;
			trig_type_word		: out std_logic_vector (31 downto 0)
		);
	end component trigger_type_ID;

--------------------------------------- CODE -------------------------------------------
begin

----- Assigning delays to each triger input using trig_ch_delayed 2D vector:
GEN_DELAY:
	for i in 0 to 31 generate
	DELAY:	signal_delay
				generic map (
					Width => 1,
					Delay => 5)
				port map (
					clk_in   	=> clk_in,
					write_en_in => write_enable, 
					delay_in	=> trig_delay(i),
					sig_in(0)   => trig_in(i),
					sig_out(0)  => trig_in_delayed(i)
				);
end generate GEN_DELAY;

----  Combine ALL enabled NOT_BUSY inputs into one:
NOT_BUSY_LOGIC_GATE:
	busy_logic_gate  -- a single logical gate that produces AND & OR outputs of enabled channels  
		generic map(
			CH_NUMBER => 16 
		)
		port map(
			busy_ch		=> not_busy_in,
			busy_mask	=> not_busy_mask, 
			busy_out	=> not_busy_AND_all
		);

TRIG_GATES_ALL:
	for i in 0 to LOG_GATE_NUMBER-1 generate
	TRIG:	trig_logic_gate  -- a single logical gate that produces AND & OR outputs of enabled channels  
				generic map(
					CH_NUMBER => 32 
				)
				port map(
					trig_ch			=> trig_in_delayed,
					trig_mask		=> trig_mask(i), 
					trig_AND_out	=> trig_AND_gate_out(i), 
					trig_OR_out		=> trig_OR_gate_out(i)
				);
		
end generate TRIG_GATES_ALL;

---- Prescale trigger Logic AND Gate outputs if needed (default prescale = "2^0" = "1")
TRIG_PRESCALE: 	prescale_trig_ch  -- prescaller trig_logic_gate outputs
		generic map(
			NUMBER => LOG_GATE_NUMBER
		)
		port map(
			sig_in			=>  trig_AND_gate_out,
			clk_in			=> clk_in,
			prescale_ch		=> trig_logic_prescaler, 
			reset			=> reset, 
			sig_out 	  	=> trig_gate_prescale_out
		);

--- Direct Trigger output after all trigger gates after prescaller:
	trig_direct 	<= or_all(trig_gate_prescale_out);
	trig_OR_dir		<= or_all(trig_OR_gate_out);
	
--- Dir trigger out with NOT_BUSY logic: 
	trig_direct_nb	<= (trig_direct AND not_busy_AND_all);

--- Producing 1 us selfgated trigger output. (no other trigger during 1us after the first trigger)
TRIG_GATED:
	signal_gated generic map(
			GateWidth =>  LATCH_WIDTH --Number of clock cycled to stretch the signal 100x10ns = 1us
		)
		port map(
			sig_in	=> trig_direct_nb,   
			clk_in  => clk_in,
			sig_out => trig_latched
		);

----- Producing a Gated trigger output, 50 ns wide: 
TRIG_GATED_50ns: 
	signal_stretch generic map(
			Stretch => TRIG_WIDTH  -- stretched pulse should be 50 ns = 5 x 10 ns;
		)
		port map(
			sig_in   => trig_latched, 
			clk_in   => clk_in, 
			sig_out  => trig_latched_50ns
		);

---- Produce counter values ----------------------
SIG_IN_COUNTER:  -- 32 x 32 bit counter for input signals
	for i in 0 to 31 generate
	SIG_COUNTER:
		counter_32bit  -- 32 bit counter
			port map (
				input 		 => trig_in_delayed(i),
				reset		 => reset,
				write_enable => write_enable,
				count		 => trig_in_counter(i) 
			);
end generate SIG_IN_COUNTER;

TRIG_GATEs_COUNTER:  -- (LOG_GATE_NUMBER-1) x 32 bit counters for signals after trig_logic_gates 
	for i in 0 to LOG_GATE_NUMBER-1 generate
	TG_COUNTER:
		counter_32bit  -- 32 bit counter
			port map (
				input 		 => trig_AND_gate_out(i),
				reset	 	 => reset,
				write_enable => write_enable,
				count		 => trig_gate_counter(i) 
			);
end generate TRIG_GATEs_COUNTER;

TRIG_PSCALE_COUNTER:  -- (LOG_GATE_NUMBER-1) x 32 bit counters for signals after trig_logic_gates 
	for i in 0 to LOG_GATE_NUMBER-1 generate
	TG_COUNTER:
		counter_32bit  -- 32 bit counter
			port map (
				input 			=>  trig_gate_prescale_out(i),
				reset			=> reset,
				write_enable	=> write_enable,
				count			=> trig_prescale_counter(i) 
			);
end generate TRIG_PSCALE_COUNTER;

T_DIR_COUNTER: --counter for a direct trigger output.
		counter_32bit  -- 32 bit counter 
			port map (
				input 			=>  trig_direct,
				reset			=> reset,
				write_enable	=> write_enable,
				count			=> trig_dir_counter
			);
			
T_DIR_NB_COUNTER: --counter for a direct trigger output.
		counter_32bit  -- 32 bit counter 
			port map (
				input 			=> trig_direct_nb,
				reset			=> reset,
				write_enable	=> write_enable,
				count			=> trig_dir_nb_counter
			);

T_LATCH_COUNTER: --counter for a direct trigger output.
		counter_32bit  -- 32 bit counter 
			port map (
				input 			=> trig_latched_50ns,
				reset			=> reset,
				write_enable	=> write_enable,
				count			=> trig_latched_counter
			);
								

------ ASSING actual signals to the trigger outputs:
trig_dir_out		<= trig_direct;
trig_dir_nb_out		<= trig_direct_nb;
trig_latch_50ns_out	<= trig_latched_50ns;
trig_debug_OR_out	<= trig_OR_dir;


----- Construct the trigget type ID word:
TRIG_TYPE_PROCESS:
	trigger_type_ID 
		generic map(
			INP_NUMBER => LOG_GATE_NUMBER  -- number of input trigger gate cahnnels 
		)
		port map(
			trig_logic_inputs	=> trig_gate_prescale_out,
			trig_final			=> trig_latched_50ns,
			clk_in				=> clk_in,
			trig_type_word		=> trig_type
		);




end trigger_master_arch;
