LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS

	COMPONENT trb_net16_ibuf
	PORT(
		CLK : IN std_logic;
		RESET : IN std_logic;
		CLK_EN : IN std_logic;
		MED_DATAREADY_IN : IN std_logic;
		MED_DATA_IN : IN std_logic_vector(15 downto 0);
		MED_PACKET_NUM_IN : IN std_logic_vector(2 downto 0);
		MED_ERROR_IN : IN std_logic_vector(2 downto 0);
		INT_INIT_READ_IN : IN std_logic;
		INT_REPLY_READ_IN : IN std_logic;
		MED_READ_OUT : OUT std_logic;
		INT_INIT_DATA_OUT : OUT std_logic_vector(15 downto 0);
		INT_INIT_PACKET_NUM_OUT : OUT std_logic_vector(2 downto 0);
		INT_INIT_DATAREADY_OUT : OUT std_logic;
		INT_REPLY_DATA_OUT : OUT std_logic_vector(15 downto 0);
		INT_REPLY_PACKET_NUM_OUT : OUT std_logic_vector(2 downto 0);
		INT_REPLY_DATAREADY_OUT : OUT std_logic;
		INT_ERROR_OUT : OUT std_logic_vector(2 downto 0);
		STAT_BUFFER_COUNTER : OUT std_logic_vector(31 downto 0);
		STAT_BUFFER : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	SIGNAL CLK :  std_logic;
	SIGNAL RESET :  std_logic;
	SIGNAL CLK_EN :  std_logic;
	SIGNAL MED_DATAREADY_IN :  std_logic;
	SIGNAL MED_DATA_IN :  std_logic_vector(15 downto 0);
	SIGNAL MED_PACKET_NUM_IN :  std_logic_vector(2 downto 0);
	SIGNAL MED_READ_OUT :  std_logic;
	SIGNAL MED_ERROR_IN :  std_logic_vector(2 downto 0);
	SIGNAL INT_INIT_DATA_OUT :  std_logic_vector(15 downto 0);
	SIGNAL INT_INIT_PACKET_NUM_OUT :  std_logic_vector(2 downto 0);
	SIGNAL INT_INIT_DATAREADY_OUT :  std_logic;
	SIGNAL INT_INIT_READ_IN :  std_logic;
	SIGNAL INT_REPLY_DATA_OUT :  std_logic_vector(15 downto 0);
	SIGNAL INT_REPLY_PACKET_NUM_OUT :  std_logic_vector(2 downto 0);
	SIGNAL INT_REPLY_DATAREADY_OUT :  std_logic;
	SIGNAL INT_REPLY_READ_IN :  std_logic;
	SIGNAL INT_ERROR_OUT :  std_logic_vector(2 downto 0);
	SIGNAL STAT_BUFFER_COUNTER :  std_logic_vector(31 downto 0);
	SIGNAL STAT_BUFFER :  std_logic_vector(31 downto 0);

BEGIN

-- Please check and add your generic clause manually
	uut: trb_net16_ibuf
 	PORT MAP(
		CLK => CLK,
		RESET => RESET,
		CLK_EN => CLK_EN,
		MED_DATAREADY_IN => MED_DATAREADY_IN,
		MED_DATA_IN => MED_DATA_IN,
		MED_PACKET_NUM_IN => MED_PACKET_NUM_IN,
		MED_READ_OUT => MED_READ_OUT,
		MED_ERROR_IN => MED_ERROR_IN,
		INT_INIT_DATA_OUT => INT_INIT_DATA_OUT,
		INT_INIT_PACKET_NUM_OUT => INT_INIT_PACKET_NUM_OUT,
		INT_INIT_DATAREADY_OUT => INT_INIT_DATAREADY_OUT,
		INT_INIT_READ_IN => INT_INIT_READ_IN,
		INT_REPLY_DATA_OUT => INT_REPLY_DATA_OUT,
		INT_REPLY_PACKET_NUM_OUT => INT_REPLY_PACKET_NUM_OUT,
		INT_REPLY_DATAREADY_OUT => INT_REPLY_DATAREADY_OUT,
		INT_REPLY_READ_IN => INT_REPLY_READ_IN,
		INT_ERROR_OUT => INT_ERROR_OUT,
		STAT_BUFFER_COUNTER => STAT_BUFFER_COUNTER,
		STAT_BUFFER => STAT_BUFFER
	);

CLOCK_GEN_PROC: process
begin
	clk <= '1'; wait for 5.0 ns;
	clk <= '0'; wait for 5.0 ns;
end process CLOCK_GEN_PROC;

THE_TESTBENCH_PROC: process
begin
	-- Setup signals
	reset <= '0';
	clk_en <= '1';
	med_dataready_in <= '0';
	med_data_in <= x"0000";
	med_packet_num_in <= b"000";
	med_error_in <= b"000";
	int_init_read_in <= '0';
	int_reply_read_in <= '0';
	wait for 33 ns;

	-- Reset the whole stuff
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '0';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);

	-- Tests may start here

	-- First packet
	wait until rising_edge(clk);
	med_data_in <= x"0002";
	med_packet_num_in <= b"100";
	med_dataready_in <= '1';
	wait until rising_edge(clk);
	med_data_in <= x"dead";
	med_packet_num_in <= b"000";
	wait until rising_edge(clk);
	med_data_in <= x"beef";
	med_packet_num_in <= b"001";
	wait until rising_edge(clk);
	med_data_in <= x"affe";
	med_packet_num_in <= b"010";
	wait until rising_edge(clk);
	med_data_in <= x"d00f";
	med_packet_num_in <= b"011";
	wait until rising_edge(clk);
	med_dataready_in <= '0';

	wait until rising_edge(clk);
	wait until rising_edge(clk);
  wait until rising_edge(clk);
  wait until rising_edge(clk);
  wait until rising_edge(clk);
  wait until rising_edge(clk);
  wait until rising_edge(clk);
  wait until rising_edge(clk);
  wait until rising_edge(clk);
	int_init_read_in <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	int_init_read_in <= '0';
  wait until rising_edge(clk);


	-- Second packet
	wait until rising_edge(clk);
	med_data_in <= x"0001";
	med_packet_num_in <= b"100";
	med_dataready_in <= '1';
	wait until rising_edge(clk);
	med_data_in <= x"dead";
	med_packet_num_in <= b"000";
	wait until rising_edge(clk);
	med_data_in <= x"beef";
	med_packet_num_in <= b"001";
	wait until rising_edge(clk);
	med_data_in <= x"affe";
	med_packet_num_in <= b"010";
	wait until rising_edge(clk);
	med_data_in <= x"d00f";
	med_packet_num_in <= b"011";
	wait until rising_edge(clk);
	med_dataready_in <= '0';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);




	-- Third packet
	wait until rising_edge(clk);
	med_data_in <= x"0001";
	med_packet_num_in <= b"100";
	med_dataready_in <= '1';
	wait until rising_edge(clk);
	med_data_in <= x"dead";
	med_packet_num_in <= b"000";
	wait until rising_edge(clk);
	med_data_in <= x"beef";
	med_packet_num_in <= b"001";
	wait until rising_edge(clk);
	med_data_in <= x"affe";
	med_packet_num_in <= b"010";
	wait until rising_edge(clk);
	med_data_in <= x"d00f";
	med_packet_num_in <= b"011";
	wait until rising_edge(clk);
	med_dataready_in <= '0';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
  int_init_read_in <= '1';

	-- Fourth packet
	wait until rising_edge(clk);
	med_data_in <= x"0009";
	med_packet_num_in <= b"100";
	med_dataready_in <= '1';
	wait until rising_edge(clk);
	med_data_in <= x"dead";
	med_packet_num_in <= b"000";
	wait until rising_edge(clk);
	med_data_in <= x"beef";
	med_packet_num_in <= b"001";
	wait until rising_edge(clk);
   int_init_read_in <= '0';
	med_data_in <= x"affe";
	med_packet_num_in <= b"010";
	wait until rising_edge(clk);
	med_data_in <= x"d00f";
	med_packet_num_in <= b"011";
	wait until rising_edge(clk);
	med_dataready_in <= '0';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	int_reply_read_in <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);


	-- Fifth packet
	wait until rising_edge(clk);
	med_data_in <= x"0009";
	med_packet_num_in <= b"100";
	med_dataready_in <= '1';
	wait until rising_edge(clk);
	med_data_in <= x"dead";
	med_packet_num_in <= b"000";
	wait until rising_edge(clk);
	med_data_in <= x"beef";
	med_packet_num_in <= b"001";
	wait until rising_edge(clk);
	med_data_in <= x"affe";
	med_packet_num_in <= b"010";
	wait until rising_edge(clk);
	med_data_in <= x"d00f";
	med_packet_num_in <= b"011";
	wait until rising_edge(clk);
	med_dataready_in <= '0';
   int_init_read_in <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);

	-- Stay a while... stay forever!!! Muhahaha!!!!
	wait;

end process THE_TESTBENCH_PROC;


END;
