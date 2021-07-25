LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS

	COMPONENT trb_net_sbuf5
	PORT(
		CLK : IN std_logic;
		RESET : IN std_logic;
		CLK_EN : IN std_logic;
		COMB_DATAREADY_IN : IN std_logic;
		COMB_DATA_IN : IN std_logic_vector(18 downto 0);
		SYN_READ_IN : IN std_logic;
		COMB_next_READ_OUT : OUT std_logic;
		SYN_DATAREADY_OUT : OUT std_logic;
		SYN_DATA_OUT : OUT std_logic_vector(18 downto 0);
		DEBUG : OUT std_logic_vector(7 downto 0);
		DEBUG_BSM : OUT std_logic_vector(3 downto 0);
		DEBUG_WCNT : OUT std_logic_vector(4 downto 0);
		STAT_BUFFER : OUT std_logic
		);
	END COMPONENT;

	SIGNAL CLK :  std_logic;
	SIGNAL RESET :  std_logic;
	SIGNAL CLK_EN :  std_logic;
	SIGNAL COMB_DATAREADY_IN :  std_logic;
	SIGNAL COMB_next_READ_OUT :  std_logic;
	SIGNAL COMB_DATA_IN :  std_logic_vector(18 downto 0);
	SIGNAL SYN_DATAREADY_OUT :  std_logic;
	SIGNAL SYN_DATA_OUT :  std_logic_vector(18 downto 0);
	SIGNAL SYN_READ_IN :  std_logic;
	SIGNAL STAT_BUFFER :  std_logic;
	SIGNAL DEBUG_BSM :  std_logic_vector(3 downto 0);
	SIGNAL DEBUG_WCNT :  std_logic_vector(4 downto 0);
	SIGNAL DEBUG :  std_logic_vector(7 downto 0);
	SIGNAL last_comb_next_read_out : std_logic;

BEGIN

-- Please check and add your generic clause manually
	uut: trb_net_sbuf5 PORT MAP(
		CLK => CLK,
		RESET => RESET,
		CLK_EN => CLK_EN,
		COMB_DATAREADY_IN => COMB_DATAREADY_IN,
		COMB_next_READ_OUT => COMB_next_READ_OUT,
		COMB_DATA_IN => COMB_DATA_IN,
		SYN_DATAREADY_OUT => SYN_DATAREADY_OUT,
		SYN_DATA_OUT => SYN_DATA_OUT,
		SYN_READ_IN => SYN_READ_IN,
		DEBUG => DEBUG,
		DEBUG_BSM => DEBUG_BSM,
		DEBUG_WCNT => DEBUG_WCNT,
		STAT_BUFFER => STAT_BUFFER
	);

-- Generate a free running 100MHz clock
THE_CLOCK_GEN: process
begin
	clk <= '0'; wait for 5.0 ns;
	clk <= '1'; wait for 5.0 ns;
end process THE_CLOCK_GEN;

-- Generate a data input stream
--THE_DATA_IN_GEN: process
--variable packet_data : unsigned(15 downto 0) := x"0000";
--variable packet_num  : unsigned(3 downto 0)  := x"0";
--variable start_data  : std_logic := '0';
--variable end_data    : std_logic := '0';
--begin
--	wait until rising_edge(clk);
--	wait for 1.0 ns;
--
--	comb_dataready_in <= '0';
--	if   ( reset = '1' ) then
--		start_data := '1';
--		end_data   := '0';
--	elsif( (start_data = '1') and (end_data = '0') ) then
--		comb_data_in(15 downto 0) <= std_logic_vector(packet_data);
--		comb_dataready_in         <= last_comb_next_read_out;
--		if( packet_num = x"0" ) then
--			comb_data_in(18 downto 16) <= b"111";
--		else
--			comb_data_in(18 downto 16) <= b"000";
--		end if;
--		if( COMB_next_READ_OUT = '1' ) then
--			packet_num  := packet_num + 1;
--			packet_data := packet_data + 1;
--			if( packet_num = x"5") then
--				packet_num := x"0";
--			end if;
--			if( packet_data = x"0096" ) then -- !!! +1 !!!
--				end_data := '1';
--			end if;
--		end if;
--	end if;
--end process THE_DATA_IN_GEN;

THE_SYNC_PROC: process( clk )
begin
	if( rising_edge(clk) ) then
		last_comb_next_read_out <= COMB_next_READ_OUT;
	end if;
end process THE_SYNC_PROC;

-- The testbench itself
THE_TESTBENCH: process
begin
	-- Setup signals
	clk_en <= '1';
	reset <= '0';
	syn_read_in <= '0';
	comb_dataready_in <= '0';
	comb_data_in <= b"000_0000_0000_0000_0000";
	wait for 30 ns;

	-- Reset the whole stuff
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	reset <= '0';
	wait for 100 ns;

	-- Tests may start now

-- Now we stream in, with some random breaks
	wait until rising_edge(clk);
	syn_read_in <= '0';

	wait until rising_edge(clk);
	comb_dataready_in <= '1';

	-- Packet
	comb_data_in(18 downto 16) <= b"111";
	comb_data_in(15 downto 0)  <= x"0000";
	wait until rising_edge(clk);
	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"0001";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"0002";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"0003";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"0004";
	wait until rising_edge(clk);

	-- Packet
	comb_data_in(18 downto 16) <= b"111";
	comb_data_in(15 downto 0)  <= x"1000";
	wait until rising_edge(clk);
	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"1001";
	syn_read_in <= '1';

	comb_dataready_in <= '0';
	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"0000";
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	comb_dataready_in <= '1';

	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"1002";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"1003";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"1004";
	wait until rising_edge(clk);

	-- Packet
	comb_data_in(18 downto 16) <= b"111";
	comb_data_in(15 downto 0)  <= x"2000";
	wait until rising_edge(clk);
	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"2001";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"2002";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"2003";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"2004";
	wait until rising_edge(clk);

	-- Packet
	comb_data_in(18 downto 16) <= b"111";
	comb_data_in(15 downto 0)  <= x"3000";
	wait until rising_edge(clk);
	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"3001";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"3002";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"3003";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"3004";
	wait until rising_edge(clk);

	-- Packet
	comb_data_in(18 downto 16) <= b"111";
	comb_data_in(15 downto 0)  <= x"4000";
	wait until rising_edge(clk);
	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"4001";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"4002";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"4003";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"4004";
	wait until rising_edge(clk);

	-- Packet
	comb_data_in(18 downto 16) <= b"111";
	comb_data_in(15 downto 0)  <= x"5000";
	wait until rising_edge(clk);
	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"5001";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"5002";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"5003";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"5004";
	wait until rising_edge(clk);

	-- Packet
	comb_data_in(18 downto 16) <= b"111";
	comb_data_in(15 downto 0)  <= x"6000";
	wait until rising_edge(clk);
	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"6001";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"6002";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"6003";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"6004";
	wait until rising_edge(clk);

	-- Packet
	comb_data_in(18 downto 16) <= b"111";
	comb_data_in(15 downto 0)  <= x"7000";
	wait until rising_edge(clk);
	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"7001";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"7002";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"7003";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"7004";
	wait until rising_edge(clk);



	-- Packet
	comb_data_in(18 downto 16) <= b"111";
	comb_data_in(15 downto 0)  <= x"8000";
	wait until rising_edge(clk);


  comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"8001";
	wait until rising_edge(clk);

  comb_data_in(15 downto 0)  <= x"8002";
	wait until rising_edge(clk);

  comb_dataready_in <= '0';
  wait until rising_edge(clk);
  comb_dataready_in <= '1';

  comb_data_in(15 downto 0)  <= x"8003";
	wait until rising_edge(clk);

	comb_data_in(15 downto 0)  <= x"8004";
	wait until rising_edge(clk);

  comb_dataready_in <= '0';
  wait until rising_edge(clk);
  comb_dataready_in <= '1';


  --Packet
  comb_data_in(18 downto 16) <= b"111";
  comb_data_in(15 downto 0)  <= x"9000";
  wait until rising_edge(clk);

  comb_data_in(18 downto 16) <= b"000";
  comb_data_in(15 downto 0)  <= x"9001";
  wait until rising_edge(clk);

	comb_dataready_in <= '0';

	wait;

------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------

	-- First packet in stop&go mode, delayed syn_read_in
	wait until rising_edge(clk);
	comb_dataready_in <= '1';
	comb_data_in <= b"111_0000_0000_0000_0000";
	wait until rising_edge(clk);
	comb_dataready_in <= '0';
	wait until rising_edge(clk);
	comb_dataready_in <= '1';
	comb_data_in <= b"000_0000_0000_0000_0001";
	wait until rising_edge(clk);
	comb_dataready_in <= '0';
	wait until rising_edge(clk);
	comb_dataready_in <= '1';
	comb_data_in <= b"000_0000_0000_0000_0010";
	wait until rising_edge(clk);
	comb_dataready_in <= '0';
	wait until rising_edge(clk);
	comb_dataready_in <= '1';
	comb_data_in <= b"000_0000_0000_0000_0011";
	wait until rising_edge(clk);
	comb_dataready_in <= '0';
	wait until rising_edge(clk);
	comb_dataready_in <= '1';
	comb_data_in <= b"000_0000_0000_0000_0100";
	wait until rising_edge(clk);
	comb_dataready_in <= '0';

	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	syn_read_in <= '1';

	wait until falling_edge(syn_dataready_out);
	wait until rising_edge(clk);
	syn_read_in <= '0';
	wait until rising_edge(clk);

	wait for 55 ns;

	-- Second packet in alltogether mode, delayed syn_read_in
	wait until rising_edge(clk);
	comb_dataready_in <= '1';
	comb_data_in <= b"111_0000_0000_0000_0101";
	wait until rising_edge(clk);
	comb_data_in <= b"000_0000_0000_0000_0110";
	wait until rising_edge(clk);
	comb_data_in <= b"000_0000_0000_0000_0111";
	wait until rising_edge(clk);
	comb_data_in <= b"000_0000_0000_0000_1000";
	wait until rising_edge(clk);
	comb_data_in <= b"000_0000_0000_0000_1001";
	wait until rising_edge(clk);
	comb_dataready_in <= '0';

	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	syn_read_in <= '1';

	wait until falling_edge(syn_dataready_out);
	wait until rising_edge(clk);
	syn_read_in <= '0';
	wait until rising_edge(clk);

	wait for 55 ns;

	-- Third packet in stop&go mode, syn_read_in active
	wait until rising_edge(clk);
	syn_read_in <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);

	wait until rising_edge(clk);
	comb_dataready_in <= '1';
	comb_data_in <= b"111_0000_0000_0000_1010";
	wait until rising_edge(clk);
	comb_dataready_in <= '0';
	wait until rising_edge(clk);
	comb_dataready_in <= '1';
	comb_data_in <= b"000_0000_0000_0000_1011";
	wait until rising_edge(clk);
	comb_dataready_in <= '0';
	wait until rising_edge(clk);
	comb_dataready_in <= '1';
	comb_data_in <= b"000_0000_0000_0000_1100";
	wait until rising_edge(clk);
	comb_dataready_in <= '0';
	wait until rising_edge(clk);
	comb_dataready_in <= '1';
	comb_data_in <= b"000_0000_0000_0000_1101";
	wait until rising_edge(clk);
	comb_dataready_in <= '0';
	wait until rising_edge(clk);
	comb_dataready_in <= '1';
	comb_data_in <= b"000_0000_0000_0000_1110";
	wait until rising_edge(clk);
	comb_dataready_in <= '0';

	wait until falling_edge(syn_dataready_out);
	wait until rising_edge(clk);
	syn_read_in <= '0';
	wait until rising_edge(clk);

	wait for 55 ns;

	-- Fourth packet in alltogether mode, syn_read_in active
	wait until rising_edge(clk);
	syn_read_in <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);

	wait until rising_edge(clk);
	comb_dataready_in <= '1';
	comb_data_in <= b"111_0000_0000_0000_1111";
	wait until rising_edge(clk);
	comb_data_in <= b"000_0000_0000_0001_0001";
	wait until rising_edge(clk);
	comb_data_in <= b"000_0000_0000_0001_0010";
	wait until rising_edge(clk);
	comb_data_in <= b"000_0000_0000_0001_0011";
	wait until rising_edge(clk);
	comb_data_in <= b"000_0000_0000_0001_0100";
	wait until rising_edge(clk);
	comb_dataready_in <= '0';

	wait until falling_edge(syn_dataready_out);
	wait until rising_edge(clk);
	syn_read_in <= '0';
	wait until rising_edge(clk);

	wait for 55 ns;

	-- Fifth and sixth packet in alltogether mode, syn_read_in active
	wait until rising_edge(clk);
	syn_read_in <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);

	wait until rising_edge(clk);
	comb_dataready_in <= '1';
	comb_data_in <= b"111_0000_0000_0001_0101";
	wait until rising_edge(clk);
	comb_data_in <= b"000_0000_0000_0001_0110";
	wait until rising_edge(clk);
	comb_data_in <= b"000_0000_0000_0001_0111";
	wait until rising_edge(clk);
	comb_data_in <= b"000_0000_0000_0001_1000";
	wait until rising_edge(clk);
	comb_data_in <= b"000_0000_0000_0001_1001";
	wait until rising_edge(clk);
	comb_data_in <= b"111_0000_0000_0000_1010";
	wait until rising_edge(clk);
	comb_data_in <= b"000_0000_0000_0001_1011";
	wait until rising_edge(clk);
	comb_data_in <= b"000_0000_0000_0001_1100";
	wait until rising_edge(clk);
	comb_data_in <= b"000_0000_0000_0001_1101";
	wait until rising_edge(clk);
	comb_data_in <= b"000_0000_0000_0001_1110";
	wait until rising_edge(clk);
	comb_dataready_in <= '0';

	wait until falling_edge(syn_dataready_out);
	wait until rising_edge(clk);
	syn_read_in <= '0';
	wait until rising_edge(clk);

	wait for 55 ns;

-- Now we stream in, with some random breaks
	wait until rising_edge(clk);
	syn_read_in <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);

	wait until rising_edge(clk);
	comb_dataready_in <= '1';
	-- Packet
	comb_data_in(18 downto 16) <= b"111";
	comb_data_in(15 downto 0)  <= x"001f";
	wait until rising_edge(clk);
	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"0020";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"0021";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"0022";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"0023";
	wait until rising_edge(clk);
	-- Packet
	comb_data_in(18 downto 16) <= b"111";
	comb_data_in(15 downto 0)  <= x"0024";
	wait until rising_edge(clk);
	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"0025";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"0026";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"0027";
	wait until rising_edge(clk);

	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0) <= x"0000";
	comb_dataready_in <= '0';
--	wait;
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	comb_data_in(18 downto 16) <= b"000";
	comb_dataready_in <= '1';

	comb_data_in(15 downto 0)  <= x"0028";
	wait until rising_edge(clk);
	-- Packet
	comb_data_in(18 downto 16) <= b"111";
	comb_data_in(15 downto 0)  <= x"0029";
	wait until rising_edge(clk);
	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"002a";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"002b";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"002c";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"002d";
	wait until rising_edge(clk);
	-- Packet
	comb_data_in(18 downto 16) <= b"111";
	comb_data_in(15 downto 0)  <= x"002e";
	wait until rising_edge(clk);
	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"002f";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"0030";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"0031";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"0032";
	wait until rising_edge(clk);
	-- Packet
	comb_data_in(18 downto 16) <= b"111";
	comb_data_in(15 downto 0)  <= x"0033";
	wait until rising_edge(clk);
	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"0034";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"0035";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"0036";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"0037";
	wait until rising_edge(clk);
	-- Packet
	comb_data_in(18 downto 16) <= b"111";
	comb_data_in(15 downto 0)  <= x"0038";
	wait until rising_edge(clk);
	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"0039";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"003a";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"003b";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"003c";
	wait until rising_edge(clk);
	-- Packet
	comb_data_in(18 downto 16) <= b"111";
	comb_data_in(15 downto 0)  <= x"003d";
	wait until rising_edge(clk);
	comb_data_in(18 downto 16) <= b"000";
	comb_data_in(15 downto 0)  <= x"003e";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"003f";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"0040";
	wait until rising_edge(clk);
	comb_data_in(15 downto 0)  <= x"0041";
	wait until rising_edge(clk);

	comb_dataready_in <= '0';

	wait until falling_edge(syn_dataready_out);
	wait until rising_edge(clk);
	syn_read_in <= '0';
	wait until rising_edge(clk);

	wait for 55 ns;


	wait;


	-- Stay a while.... stay forever!!!
	wait;

end process THE_TESTBENCH;


END;
