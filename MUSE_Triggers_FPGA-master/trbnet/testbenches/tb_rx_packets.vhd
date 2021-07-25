LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT trb_net16_rx_packets
	PORT(
		CLK_IN : IN std_logic;
		SYSCLK_IN : IN std_logic;
		RESET_IN : IN std_logic;
		QUAD_RST_IN : IN std_logic;
		RX_ALLOW_IN : IN std_logic;
		RX_DATA_IN : IN std_logic_vector(7 downto 0);
		RX_K_IN : IN std_logic;       
		MED_DATA_OUT : OUT std_logic_vector(15 downto 0);
		MED_DATAREADY_OUT : OUT std_logic;
		MED_READ_IN : IN std_logic;
		MED_PACKET_NUM_OUT : OUT std_logic_vector(2 downto 0);
		SEND_RESET_WORDS_OUT : OUT std_logic;
		MAKE_TRBNET_RESET_OUT : OUT std_logic;
		LINK_BROKEN_OUT : OUT std_logic;
		BSM_OUT : OUT std_logic_vector(3 downto 0);
		DBG_OUT : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	SIGNAL CLK_IN :  std_logic;
	SIGNAL SYSCLK_IN :  std_logic;
	SIGNAL RESET_IN :  std_logic;
	SIGNAL QUAD_RST_IN :  std_logic;
	SIGNAL RX_ALLOW_IN :  std_logic;
	SIGNAL RX_DATA_IN :  std_logic_vector(7 downto 0);
	SIGNAL RX_K_IN :  std_logic;
	SIGNAL MED_DATA_OUT :  std_logic_vector(15 downto 0);
	SIGNAL MED_DATAREADY_OUT :  std_logic;
	SIGNAL MED_READ_IN :  std_logic;
	SIGNAL MED_PACKET_NUM_OUT :  std_logic_vector(2 downto 0);
	SIGNAL SEND_RESET_WORDS_OUT :  std_logic;
	SIGNAL MAKE_TRBNET_RESET_OUT :  std_logic;
	SIGNAL LINK_BROKEN_OUT :  std_logic;
	SIGNAL BSM_OUT :  std_logic_vector(3 downto 0);
	SIGNAL DBG_OUT :  std_logic_vector(15 downto 0);

BEGIN

-- Please check and add your generic clause manually
	uut: trb_net16_rx_packets PORT MAP(
		CLK_IN => CLK_IN,
		SYSCLK_IN => SYSCLK_IN,
		RESET_IN => RESET_IN,
		QUAD_RST_IN => QUAD_RST_IN,
		RX_ALLOW_IN => RX_ALLOW_IN,
		RX_DATA_IN => RX_DATA_IN,
		RX_K_IN => RX_K_IN,
		MED_DATA_OUT => MED_DATA_OUT,
		MED_DATAREADY_OUT => MED_DATAREADY_OUT,
		MED_READ_IN => MED_READ_IN,
		MED_PACKET_NUM_OUT => MED_PACKET_NUM_OUT,
		SEND_RESET_WORDS_OUT => SEND_RESET_WORDS_OUT,
		MAKE_TRBNET_RESET_OUT => MAKE_TRBNET_RESET_OUT,
		LINK_BROKEN_OUT => LINK_BROKEN_OUT,
		BSM_OUT => BSM_OUT,
		DBG_OUT => DBG_OUT
	);

-- Write clock (25MHz)
SERDES_CLOCK_GEN: process
begin
	clk_in <= '1'; wait for 20.1 ns;
	clk_in <= '0'; wait for 20.1 ns;
end process SERDES_CLOCK_GEN;

-- Read clock (100MHz)
SYS_CLOCK_GEN: process
begin
	sysclk_in <= '1'; wait for 4.9 ns;
	sysclk_in <= '0'; wait for 4.9 ns;
end process SYS_CLOCK_GEN;

-- Testbench
THE_TESTBENCH: process
begin
	-- Setup signals
	reset_in <= '0';
	quad_rst_in <= '0';
	rx_k_in <= '0';
	rx_data_in <= x"00";
	rx_allow_in <= '0';
	med_read_in <= '0';

	wait for 20 ns;
	
	-- Reset the whole stuff
	reset_in <= '1'; wait for 33 ns;
	reset_in <= '0'; wait for 55 ns;
	
	-- Tests may start now...
	
	-- TRBnet reset sequence
	wait until rising_edge(clk_in);
	rx_allow_in <= '1';
	rx_k_in <= '1';
	rx_data_in <= x"fe";
	wait for 400 ns;

	wait until rising_edge(sysclk_in);
	med_read_in <= '1';

	wait for 600 ns;
	
	THE_IDLE_LOOP: for I in 0 to 20 loop
		wait until rising_edge(clk_in);
		rx_k_in <= '1';
		rx_data_in <= x"bc";
		wait until rising_edge(clk_in);
		rx_k_in <= '0';
		rx_data_in <= x"50";
	end loop THE_IDLE_LOOP;	

	wait until rising_edge(clk_in);
	rx_k_in <= '0';
	rx_data_in <= x"a0";
	wait until rising_edge(clk_in);
	rx_data_in <= x"a1";
	wait until rising_edge(clk_in);
	rx_data_in <= x"a2";
	wait until rising_edge(clk_in);
	rx_data_in <= x"a3";
	wait until rising_edge(clk_in);
	rx_data_in <= x"a4";
	wait until rising_edge(clk_in);
	rx_data_in <= x"a5";
	wait until rising_edge(clk_in);
	rx_data_in <= x"a6";
	wait until rising_edge(clk_in);
	rx_data_in <= x"a7";
	wait until rising_edge(clk_in);
	rx_data_in <= x"a8";
	wait until rising_edge(clk_in);
	rx_data_in <= x"a9";
	wait until rising_edge(clk_in);

	rx_data_in <= x"b0";
	wait until rising_edge(clk_in);
	rx_data_in <= x"b1";
	wait until rising_edge(clk_in);
	rx_data_in <= x"b2";
	wait until rising_edge(clk_in);
	rx_data_in <= x"b3";
	wait until rising_edge(clk_in);
	rx_data_in <= x"b4";
	wait until rising_edge(clk_in);
	rx_data_in <= x"b5";
	wait until rising_edge(clk_in);
	rx_data_in <= x"b6";
	wait until rising_edge(clk_in);
	rx_data_in <= x"b7";
	wait until rising_edge(clk_in);
	rx_data_in <= x"b8";
	wait until rising_edge(clk_in);
	rx_data_in <= x"b9";
--	wait until rising_edge(clk_in);

	THE_IDLE_LOOP_2: for I in 0 to 100 loop
		wait until rising_edge(clk_in);
		rx_k_in <= '1';
		rx_data_in <= x"bc";
		wait until rising_edge(clk_in);
		rx_k_in <= '0';
		rx_data_in <= x"50";
	end loop THE_IDLE_LOOP_2;	
	
	rx_data_in <= x"c0";
	wait until rising_edge(clk_in);
	rx_data_in <= x"c1";
	wait until rising_edge(clk_in);
	rx_data_in <= x"c2";
	wait until rising_edge(clk_in);
	rx_data_in <= x"c3";
	wait until rising_edge(clk_in);
	rx_data_in <= x"c4";
	wait until rising_edge(clk_in);
	rx_data_in <= x"c5";
	wait until rising_edge(clk_in);
	rx_data_in <= x"c6";
	wait until rising_edge(clk_in);
	rx_data_in <= x"c7";

	THE_IDLE_LOOP_3: for I in 0 to 1200 loop
		wait until rising_edge(clk_in);
		rx_k_in <= '1';
		rx_data_in <= x"bc";
		wait until rising_edge(clk_in);
		rx_k_in <= '0';
		rx_data_in <= x"50";
	end loop THE_IDLE_LOOP_3;	

	wait until rising_edge(clk_in);
	rx_data_in <= x"c8";
	wait until rising_edge(clk_in);
	rx_data_in <= x"c9";
	wait until rising_edge(clk_in);

--	THE_IDLE_LOOP_3: for I in 0 to 500 loop
--		wait until rising_edge(clk_in);
--		rx_k_in <= '1';
--		rx_data_in <= x"bc";
--		wait until rising_edge(clk_in);
--		rx_k_in <= '0';
--		rx_data_in <= x"50";
--	end loop THE_IDLE_LOOP_3;	
	
	
	-- Stay a while... stay forever!!!! Muahahaha!!!!
	wait;
	
end process THE_TESTBENCH;

END;
