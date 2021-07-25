LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT trb_net_fifo_8bit_16bit_bram_dualport
	PORT(
		READ_CLOCK_IN : IN std_logic;
		WRITE_CLOCK_IN : IN std_logic;
		READ_ENABLE_IN : IN std_logic;
		WRITE_ENABLE_IN : IN std_logic;
		FIFO_GSR_IN : IN std_logic;
		WRITE_DATA_IN : IN std_logic_vector(7 downto 0);          
		READ_DATA_OUT : OUT std_logic_vector(15 downto 0);
		FULL_OUT : OUT std_logic;
		EMPTY_OUT : OUT std_logic;
		WCNT_OUT : OUT std_logic_vector(9 downto 0);
		RCNT_OUT : OUT std_logic_vector(8 downto 0)
		);
	END COMPONENT;

	SIGNAL READ_CLOCK_IN :  std_logic;
	SIGNAL WRITE_CLOCK_IN :  std_logic;
	SIGNAL READ_ENABLE_IN :  std_logic;
	SIGNAL WRITE_ENABLE_IN :  std_logic;
	SIGNAL FIFO_GSR_IN :  std_logic;
	SIGNAL WRITE_DATA_IN :  std_logic_vector(7 downto 0);
	SIGNAL READ_DATA_OUT :  std_logic_vector(15 downto 0);
	SIGNAL FULL_OUT :  std_logic;
	SIGNAL EMPTY_OUT :  std_logic;
	SIGNAL WCNT_OUT :  std_logic_vector(9 downto 0);
	SIGNAL RCNT_OUT :  std_logic_vector(8 downto 0);

BEGIN

-- Please check and add your generic clause manually
	uut: trb_net_fifo_8bit_16bit_bram_dualport PORT MAP(
		READ_CLOCK_IN => READ_CLOCK_IN,
		WRITE_CLOCK_IN => WRITE_CLOCK_IN,
		READ_ENABLE_IN => READ_ENABLE_IN,
		WRITE_ENABLE_IN => WRITE_ENABLE_IN,
		FIFO_GSR_IN => FIFO_GSR_IN,
		WRITE_DATA_IN => WRITE_DATA_IN,
		READ_DATA_OUT => READ_DATA_OUT,
		FULL_OUT => FULL_OUT,
		EMPTY_OUT => EMPTY_OUT,
		WCNT_OUT => WCNT_OUT,
		RCNT_OUT => RCNT_OUT
	);

-- Write clock (25MHz)
WRITE_CLOCK_GEN: process
begin
	write_clock_in <= '1'; wait for 20.1 ns;
	write_clock_in <= '0'; wait for 20.1 ns;
end process WRITE_CLOCK_GEN;

-- Read clock (100MHz)
READ_CLOCK_GEN: process
begin
	read_clock_in <= '1'; wait for 4.9 ns;
	read_clock_in <= '0'; wait for 4.9 ns;
end process READ_CLOCK_GEN;

-- Testbench
THE_TESTBENCH: process
begin
	-- Setup signals
	read_enable_in <= '0';
	write_enable_in <= '0';
	fifo_gsr_in <= '0';
	write_data_in <= (others => '0');

	wait for 20 ns;
	
	-- Reset the whole stuff
	fifo_gsr_in <= '1'; wait for 33 ns;
	fifo_gsr_in <= '0'; wait for 55 ns;
	
	-- Tests may start now...
	wait until rising_edge(write_clock_in);
	write_enable_in <= '1';
	write_data_in <= x"01";
	wait until rising_edge(write_clock_in);
	write_data_in <= x"02";
	wait until rising_edge(write_clock_in);
	write_data_in <= x"03";
	wait until rising_edge(write_clock_in);
	write_data_in <= x"04";
	wait until rising_edge(write_clock_in);
	write_data_in <= x"05";
	wait until rising_edge(write_clock_in);
	write_data_in <= x"06";
	wait until rising_edge(write_clock_in);
	write_data_in <= x"07";
	wait until rising_edge(write_clock_in);
	write_data_in <= x"08";
	wait until rising_edge(write_clock_in);
	write_data_in <= x"09";
	wait until rising_edge(write_clock_in);
	write_data_in <= x"0a";
	wait until rising_edge(write_clock_in);
	write_data_in <= x"0b";
	write_enable_in <= '0';
	
	wait for 333 ns;
	
	-- Reset the whole stuff
	fifo_gsr_in <= '1'; wait for 33 ns;
	fifo_gsr_in <= '0'; wait for 55 ns;
	
	
	
	wait until rising_edge(read_clock_in);
	read_enable_in <= '1';
	wait until rising_edge(read_clock_in);
	wait until rising_edge(read_clock_in);
	read_enable_in <= '0';
	wait until rising_edge(read_clock_in);
	wait until rising_edge(read_clock_in);
	read_enable_in <= '1';
	wait until rising_edge(read_clock_in);
	wait until rising_edge(read_clock_in);
	wait until rising_edge(read_clock_in);
	read_enable_in <= '0';
	wait until rising_edge(read_clock_in);
	
	
	-- Stay a while... stay forever!!!! Muahahaha!!!!
	wait;
	
end process THE_TESTBENCH;

END;
