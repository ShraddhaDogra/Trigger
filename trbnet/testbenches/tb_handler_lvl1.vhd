LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT handler_lvl1
	GENERIC(
		TIMING_TRIGGER_RAW           : integer range 0 to 1 := c_YES
	);
	PORT(
		RESET : IN std_logic;
		CLOCK : IN std_logic;
		LVL1_TIMING_TRG_IN : IN std_logic;
		LVL1_PSEUDO_TMG_TRG_IN : IN std_logic;
		LVL1_TRG_RECEIVED_IN : IN std_logic;
		LVL1_TRG_TYPE_IN : IN std_logic_vector(3 downto 0);
		LVL1_TRG_NUMBER_IN : IN std_logic_vector(15 downto 0);
		LVL1_TRG_CODE_IN : IN std_logic_vector(7 downto 0);
		LVL1_TRG_INFORMATION_IN : IN std_logic_vector(23 downto 0);
		LVL1_INT_TRG_RESET_IN : IN std_logic;
		LVL1_INT_TRG_LOAD_IN : IN std_logic;
		LVL1_INT_TRG_COUNTER_IN : IN std_logic_vector(15 downto 0);
		LVL1_ERROR_PATTERN_IN : IN std_logic_vector(31 downto 0);
		LVL1_TRG_RELEASE_IN : IN std_logic;
		TRG_ENABLE_IN : IN std_logic;
		TRG_INVERT_IN : IN std_logic;          
		LVL1_ERROR_PATTERN_OUT : OUT std_logic_vector(31 downto 0);
		LVL1_TRG_RELEASE_OUT : OUT std_logic;
		LVL1_INT_TRG_NUMBER_OUT : OUT std_logic_vector(15 downto 0);
		LVL1_TRG_DATA_VALID_OUT : OUT std_logic;
		LVL1_VALID_TIMING_TRG_OUT : OUT std_logic;
		LVL1_VALID_NOTIMING_TRG_OUT : OUT std_logic;
		LVL1_INVALID_TRG_OUT : OUT std_logic;
		LVL1_MULTIPLE_TRG_OUT : OUT std_logic;
		LVL1_DELAY_OUT : OUT std_logic_vector(15 downto 0);
		STATUS_OUT : OUT std_logic_vector(31 downto 0);
		DEBUG_OUT : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	SIGNAL RESET :  std_logic;
	SIGNAL CLOCK :  std_logic;
	SIGNAL LVL1_TIMING_TRG_IN :  std_logic;
	SIGNAL LVL1_PSEUDO_TMG_TRG_IN :  std_logic;
	SIGNAL LVL1_TRG_RECEIVED_IN :  std_logic;
	SIGNAL LVL1_TRG_TYPE_IN :  std_logic_vector(3 downto 0);
	SIGNAL LVL1_TRG_NUMBER_IN :  std_logic_vector(15 downto 0);
	SIGNAL LVL1_TRG_CODE_IN :  std_logic_vector(7 downto 0);
	SIGNAL LVL1_TRG_INFORMATION_IN :  std_logic_vector(23 downto 0);
	SIGNAL LVL1_ERROR_PATTERN_OUT :  std_logic_vector(31 downto 0);
	SIGNAL LVL1_TRG_RELEASE_OUT :  std_logic;
	SIGNAL LVL1_INT_TRG_NUMBER_OUT :  std_logic_vector(15 downto 0);
	SIGNAL LVL1_INT_TRG_RESET_IN :  std_logic;
	SIGNAL LVL1_INT_TRG_LOAD_IN :  std_logic;
	SIGNAL LVL1_INT_TRG_COUNTER_IN :  std_logic_vector(15 downto 0);
	SIGNAL LVL1_TRG_DATA_VALID_OUT :  std_logic;
	SIGNAL LVL1_VALID_TIMING_TRG_OUT :  std_logic;
	SIGNAL LVL1_VALID_NOTIMING_TRG_OUT :  std_logic;
	SIGNAL LVL1_INVALID_TRG_OUT :  std_logic;
	SIGNAL LVL1_MULTIPLE_TRG_OUT :  std_logic;
	SIGNAL LVL1_DELAY_OUT :  std_logic_vector(15 downto 0);
	SIGNAL LVL1_ERROR_PATTERN_IN :  std_logic_vector(31 downto 0);
	SIGNAL LVL1_TRG_RELEASE_IN :  std_logic;
	SIGNAL STATUS_OUT :  std_logic_vector(31 downto 0);
	SIGNAL TRG_ENABLE_IN :  std_logic;
	SIGNAL TRG_INVERT_IN :  std_logic;
	SIGNAL DEBUG_OUT :  std_logic_vector(15 downto 0);

BEGIN

-- Please check and add your generic clause manually
	uut: handler_lvl1 
	GENERIC MAP(
		TIMING_TRIGGER_RAW => 1
	)
	PORT MAP(
		RESET => RESET,
		CLOCK => CLOCK,
		LVL1_TIMING_TRG_IN => LVL1_TIMING_TRG_IN,
		LVL1_PSEUDO_TMG_TRG_IN => LVL1_PSEUDO_TMG_TRG_IN,
		LVL1_TRG_RECEIVED_IN => LVL1_TRG_RECEIVED_IN,
		LVL1_TRG_TYPE_IN => LVL1_TRG_TYPE_IN,
		LVL1_TRG_NUMBER_IN => LVL1_TRG_NUMBER_IN,
		LVL1_TRG_CODE_IN => LVL1_TRG_CODE_IN,
		LVL1_TRG_INFORMATION_IN => LVL1_TRG_INFORMATION_IN,
		LVL1_ERROR_PATTERN_OUT => LVL1_ERROR_PATTERN_OUT,
		LVL1_TRG_RELEASE_OUT => LVL1_TRG_RELEASE_OUT,
		LVL1_INT_TRG_NUMBER_OUT => LVL1_INT_TRG_NUMBER_OUT,
		LVL1_INT_TRG_RESET_IN => LVL1_INT_TRG_RESET_IN,
		LVL1_INT_TRG_LOAD_IN => LVL1_INT_TRG_LOAD_IN,
		LVL1_INT_TRG_COUNTER_IN => LVL1_INT_TRG_COUNTER_IN,
		LVL1_TRG_DATA_VALID_OUT => LVL1_TRG_DATA_VALID_OUT,
		LVL1_VALID_TIMING_TRG_OUT => LVL1_VALID_TIMING_TRG_OUT,
		LVL1_VALID_NOTIMING_TRG_OUT => LVL1_VALID_NOTIMING_TRG_OUT,
		LVL1_INVALID_TRG_OUT => LVL1_INVALID_TRG_OUT,
		LVL1_MULTIPLE_TRG_OUT => LVL1_MULTIPLE_TRG_OUT,
		LVL1_ERROR_PATTERN_IN => LVL1_ERROR_PATTERN_IN,
		LVL1_TRG_RELEASE_IN => LVL1_TRG_RELEASE_IN,
		LVL1_DELAY_OUT => LVL1_DELAY_OUT,
		STATUS_OUT => STATUS_OUT,
		TRG_ENABLE_IN => TRG_ENABLE_IN,
		TRG_INVERT_IN => TRG_INVERT_IN,
		DEBUG_OUT => DEBUG_OUT
	);

THE_CLOCK_GEN: process
begin
	CLOCK <= '0'; wait for 5.0 ns;
	CLOCK <= '1'; wait for 5.0 ns;
end process THE_CLOCK_GEN;

THE_TESTBENCH: process
begin
	-----------------------------------------------------------
	-- Setup signals
	-----------------------------------------------------------
	reset <= '0';
	lvl1_timing_trg_in <= '0'; -- real timing trigger
	lvl1_pseudo_tmg_trg_in <= '0'; -- one clock pulse form TRB 
	lvl1_trg_received_in <= '0';
	lvl1_trg_type_in <= x"0";
	lvl1_trg_number_in <= x"0000";
	lvl1_trg_code_in <= x"00";
	lvl1_trg_information_in <= x"000000";
	lvl1_int_trg_reset_in <= '0';
	lvl1_int_trg_load_in <= '0';
	lvl1_int_trg_counter_in <= x"0000";
	lvl1_error_pattern_in <= x"0000_0000";
	lvl1_trg_release_in <= '0';
	trg_enable_in <= '0';
	trg_invert_in <= '0';

	-----------------------------------------------------------
	-- Reset the whole stuff
	-----------------------------------------------------------
	wait until rising_edge(clock);
	reset <= '1';
	wait until rising_edge(clock);
	wait until rising_edge(clock);
	reset <= '0';
	wait for 100 ns;
	
	-----------------------------------------------------------
	-- Tests may start now
	-----------------------------------------------------------

	-- enable trigger
	wait until rising_edge(clock);
	trg_enable_in <= '1';
	wait for 100 ns;

	-----------------------------------------------------------

	-- ONE TRIGGER (timing)

	-- receive one normal timing trigger
	wait for 3 ns;
	lvl1_timing_trg_in <= '1';
	wait for 111 ns;
	lvl1_timing_trg_in <= '0';	
	wait for 1000 ns;

	-- LVL1 packet is there
	wait until rising_edge(clock);
	lvl1_trg_type_in <= x"1";
	lvl1_trg_number_in <= x"0000";
	lvl1_trg_code_in <= x"ab";
	lvl1_trg_information_in <= x"000000";
	wait until rising_edge(clock);
	lvl1_trg_received_in <= '1';

	wait for 211 ns;	
	wait until rising_edge(clock);
	lvl1_trg_release_in <= '1';	
	wait until rising_edge(clock);
	lvl1_trg_release_in <= '0';	

	wait until falling_edge(lvl1_trg_release_out);
	wait until rising_edge(clock);
	lvl1_trg_received_in <= '0';
	lvl1_trg_type_in <= x"0";
	lvl1_trg_number_in <= x"0000";
	lvl1_trg_code_in <= x"00";
	lvl1_trg_information_in <= x"000000";

	wait for 555 ns;

	-----------------------------------------------------------

	-- ONE TRIGGER (timing)

	-- receive one normal timing trigger
	wait for 3 ns;
	lvl1_timing_trg_in <= '1';
	wait for 111 ns;
	lvl1_timing_trg_in <= '0';	
	
	wait for 300 ns;
	lvl1_timing_trg_in <= '1';
	wait for 111 ns;
	lvl1_timing_trg_in <= '0';	
	wait for 200 ns;

	-- LVL1 packet is there
	wait until rising_edge(clock);
	lvl1_trg_type_in <= x"1";
	lvl1_trg_number_in <= x"0001";
	lvl1_trg_code_in <= x"71";
	lvl1_trg_information_in <= x"000000";
	wait until rising_edge(clock);
	lvl1_trg_received_in <= '1';

	wait for 211 ns;	
	wait until rising_edge(clock);
	lvl1_trg_release_in <= '1';	
	wait until rising_edge(clock);
	lvl1_trg_release_in <= '0';	

	wait until falling_edge(lvl1_trg_release_out);
	wait until rising_edge(clock);
	lvl1_trg_received_in <= '0';
	lvl1_trg_type_in <= x"0";
	lvl1_trg_number_in <= x"0000";
	lvl1_trg_code_in <= x"00";
	lvl1_trg_information_in <= x"000000";

	wait for 555 ns;

	-----------------------------------------------------------
	-- ONE TRIGGER (timing, wrong counter on LVL1)

	-- receive one normal timing trigger
	wait for 3 ns;
	lvl1_timing_trg_in <= '1';
	wait for 111 ns;
	lvl1_timing_trg_in <= '0';	
	wait for 1000 ns;

	-- LVL1 packet is there
	wait until rising_edge(clock);
	lvl1_trg_type_in <= x"1";
	lvl1_trg_number_in <= x"dead";
	lvl1_trg_code_in <= x"cc";
	lvl1_trg_information_in <= x"000000";
	wait until rising_edge(clock);
	lvl1_trg_received_in <= '1';

	wait for 211 ns;	
	wait until rising_edge(clock);
	lvl1_trg_release_in <= '1';	
	wait until rising_edge(clock);
	lvl1_trg_release_in <= '0';	

	wait until falling_edge(lvl1_trg_release_out);
	wait until rising_edge(clock);
	lvl1_trg_received_in <= '0';
	lvl1_trg_type_in <= x"0";
	lvl1_trg_number_in <= x"0000";
	lvl1_trg_code_in <= x"00";
	lvl1_trg_information_in <= x"000000";

	wait for 555 ns;

	-----------------------------------------------------------
	-- ONE TRIGGER (timing, missing LVL1)

	-- receive one normal timing trigger
	wait for 3 ns;
	lvl1_timing_trg_in <= '1';
	wait for 111 ns;
	lvl1_timing_trg_in <= '0';	
	wait for 1000 ns;

	wait for 6 us;

	-----------------------------------------------------------

	-- ONE TRIGGER (timingtriggerless)
	
	-- LVL1 packet is there
	wait until rising_edge(clock);
	lvl1_trg_type_in <= x"9";
	lvl1_trg_number_in <= x"0002";
	lvl1_trg_code_in <= x"f0";
	lvl1_trg_information_in <= x"000080";
	wait until rising_edge(clock);
	lvl1_trg_received_in <= '1';

	wait for 211 ns;	
	wait until rising_edge(clock);
	lvl1_trg_release_in <= '1';	
	wait until rising_edge(clock);
	lvl1_trg_release_in <= '0';	

	wait until falling_edge(lvl1_trg_release_out);
	wait until rising_edge(clock);
	lvl1_trg_received_in <= '0';
	lvl1_trg_type_in <= x"0";
	lvl1_trg_number_in <= x"0000";
	lvl1_trg_code_in <= x"00";
	lvl1_trg_information_in <= x"000000";

	wait for 555 ns;

	-----------------------------------------------------------

	wait;
	
	-----------------------------------------------------------
		
	-- receive one TRB fake trigger
	wait until rising_edge(clock);
	lvl1_pseudo_tmg_trg_in <= '1';
	wait until rising_edge(clock);
	lvl1_pseudo_tmg_trg_in <= '0';
	wait for 300 ns;

	-- receive one spike
	wait for 3 ns;
	lvl1_timing_trg_in <= '1';
	wait for 17 ns;
	lvl1_timing_trg_in <= '0';	
	wait for 300 ns;
	
	-- Stay a while.... stay forever!!! Muahahah!!!!
	wait;
end process THE_TESTBENCH;

END;
