library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ipu_dummy is
	port( CLK_IN					: in	std_logic; -- 100MHz local clock
		  CLEAR_IN					: in    std_logic;
		  RESET_IN					: in    std_logic; -- synchronous reset
		  -- Slow control signals	
		  MIN_COUNT_IN				: in	std_logic_vector(15 downto 0); -- minimum counter value
		  MAX_COUNT_IN				: in	std_logic_vector(15 downto 0); -- maximum counter value
		  CTRL_IN					: in	std_logic_vector(7 downto 0); -- control bits from slow control
		  -- IPU channel connections
		  IPU_NUMBER_IN				: in	std_logic_vector(15 downto 0); -- trigger tag
		  IPU_INFORMATION_IN		: in	std_logic_vector(7 downto 0); -- trigger information
		  IPU_START_READOUT_IN		: in	std_logic; -- gimme data!
		  IPU_DATA_OUT				: out	std_logic_vector(31 downto 0); -- detector data, equipped with DHDR
		  IPU_DATAREADY_OUT			: out	std_logic; -- data is valid
		  IPU_READOUT_FINISHED_OUT	: out	std_logic; -- no more data, end transfer, send TRM
		  IPU_READ_IN				: in	std_logic; -- read strobe, low every second cycle 
		  IPU_LENGTH_OUT			: out	std_logic_vector(15 downto 0); -- length of data packet (32bit words) (?)
		  IPU_ERROR_PATTERN_OUT		: out	std_logic_vector(31 downto 0); -- error pattern
		  -- DHDR buffer
		  LVL1_FIFO_RD_OUT			: out	std_logic;
		  LVL1_FIFO_EMPTY_IN		: in	std_logic;
		  LVL1_FIFO_NUMBER_IN		: in	std_logic_vector(15 downto 0);
		  LVL1_FIFO_CODE_IN			: in	std_logic_vector(7 downto 0);
		  LVL1_FIFO_INFORMATION_IN	: in	std_logic_vector(7 downto 0);
		  LVL1_FIFO_TYPE_IN			: in	std_logic_vector(3 downto 0);
		  -- Debug signals
		  DBG_BSM_OUT				: out	std_logic_vector(7 downto 0);
		  DBG_OUT					: out	std_logic_vector(63 downto 0)
		);
end;

architecture behavioral of ipu_dummy is

	
	-- state machine definitions
	type STATES is (SLEEP,CHKF,DELF0,DELF1,SHDR,DDATA,SDATA,DONE);	
	signal CURRENT_STATE, NEXT_STATE: STATES;

	-- signals
	signal debug				: std_logic_vector(63 downto 0);

	signal rnd_count			: std_logic_vector(15 downto 0); -- pseudo random counter for data length

	signal random				: std_logic_vector(15 downto 0); -- currently available random length

	signal data_count			: std_logic_vector(15 downto 0); -- data length to be used in this IPU readout cycle
	signal data_done_comb		: std_logic;
	signal data_done			: std_logic;

	signal ipu_data				: std_logic_vector(31 downto 0);
	signal ipu_error			: std_logic_vector(31 downto 0);

	-- state machine signals
	signal bsm_x				: std_logic_vector(7 downto 0);
	signal ld_data_count_x		: std_logic;
	signal ld_data_count		: std_logic; -- load data counter with current random
	signal ce_data_count_x		: std_logic;
	signal ce_data_count		: std_logic; -- decrement data counter
	signal rd_fifo_x			: std_logic;
	signal rd_fifo				: std_logic; -- read DHDR FIFO from LVL1
	signal send_data_x			: std_logic;
	signal send_data			: std_logic; -- packet data to be sent
	signal send_dhdr_x			: std_logic;
	signal send_dhdr			: std_logic; -- DHDR to be sent
	signal data_ready_x			: std_logic;
	signal data_ready			: std_logic; -- IPU_DATAREADY_OUT
	signal data_finished_x		: std_logic;
	signal data_finished		: std_logic; -- IPU_READOUT_FINISHED_OUT

	signal next_trgnum_match	: std_logic;
	signal trgnum_match			: std_logic;

begin

---------------------------------------------------------------------------
-- Random counter (to be improved, just a simple binary counter now)
---------------------------------------------------------------------------
THE_RND_COUNT_PROC: process( clk_in )
begin
	if   ( clear_in = '1' ) then
		rnd_count <= (others => '0');
	elsif( rising_edge(clk_in) ) then
		rnd_count <= rnd_count + 1;
		if( rnd_count = max_count_in ) then
			rnd_count <= min_count_in;
		end if;
	end if;
end process THE_RND_COUNT_PROC;

---------------------------------------------------------------------------
-- data length counter, storage register for ipu_length
---------------------------------------------------------------------------
THE_DATA_LENGTH_COUNTER: process( clear_in, clk_in )
begin
	if   ( clear_in = '1' ) then
		data_count <= (others => '0');
		data_done  <= '0';
		random     <= (others => '0');
	elsif( rising_edge(clk_in) ) then
		if   ( reset_in = '1' ) then
			data_count <= (others => '0');
			random     <= (others => '0');
		elsif( ld_data_count = '1' ) then
			data_count <= rnd_count;
			random     <= rnd_count;
		elsif( ce_data_count = '1' ) then
			data_count <= data_count - 1;
		end if;
		data_done  <= data_done_comb;
	end if;
end process THE_DATA_LENGTH_COUNTER;

data_done_comb     <= '1' when ( data_count = x"0000" ) else '0';

---------------------------------------------------------------------------
-- Statemachine
---------------------------------------------------------------------------

-- state registers
STATE_MEM: process( clk_in, clear_in ) 
begin
	if( clear_in = '1' ) then
		CURRENT_STATE    <= SLEEP;
		ld_data_count    <= '0';
		ce_data_count    <= '0';
		rd_fifo          <= '0';
		send_data        <= '0';
		send_dhdr        <= '0';
		data_ready       <= '0';
		data_finished    <= '0';
	elsif( rising_edge(clk_in) ) then
		if( reset_in = '1' ) then
			CURRENT_STATE    <= SLEEP;
			ld_data_count    <= '0';
			ce_data_count    <= '0';
			rd_fifo          <= '0';
			send_data        <= '0';
			send_dhdr        <= '0';
			data_ready       <= '0';
			data_finished    <= '0';
		else
			CURRENT_STATE    <= NEXT_STATE;
			ld_data_count    <= ld_data_count_x;
			ce_data_count    <= ce_data_count_x;
			rd_fifo          <= rd_fifo_x;
			send_data        <= send_data_x;
			send_dhdr        <= send_dhdr_x;
			data_ready       <= data_ready_x;
			data_finished    <= data_finished_x;
		end if;
	end if;
end process STATE_MEM;

-- state transitions
STATE_TRANSFORM: process( CURRENT_STATE, ipu_start_readout_in, lvl1_fifo_empty_in,
						  ipu_read_in, data_ready, data_done )
begin
	NEXT_STATE         <= SLEEP; -- avoid latches
	ld_data_count_x    <= '0';
	ce_data_count_x    <= '0';
	rd_fifo_x          <= '0';
	send_data_x        <= '0';
	send_dhdr_x        <= '0';
	data_ready_x       <= '0';
	data_finished_x    <= '0';
	case CURRENT_STATE is
		when SLEEP	=>	if( ipu_start_readout_in = '1' ) then
							NEXT_STATE      <= CHKF;
							ld_data_count_x <= '1';
							rd_fifo_x       <= '1';
						else
							NEXT_STATE      <= SLEEP;
						end if;
		when CHKF	=>	if( lvl1_fifo_empty_in = '0' ) then
							NEXT_STATE <= DELF0;
						else
							NEXT_STATE <= CHKF;
							rd_fifo_x  <= '1';
						end if;
		when DELF0	=>	NEXT_STATE  <= DELF1;
		when DELF1	=>	NEXT_STATE  <= SHDR;
						send_dhdr_x <= '1';
		when SHDR	=>	if   ( (data_ready = '1') and (ipu_read_in = '1') and (data_done = '0') ) then
							NEXT_STATE      <= DDATA;
							ce_data_count_x <= '1';
						elsif( (data_ready = '1') and (ipu_read_in = '1') and (data_done = '1') ) then
							NEXT_STATE      <= DONE;
							data_finished_x <= '1';
						else
							NEXT_STATE      <= SHDR;
							data_ready_x    <= '1';
							send_dhdr_x     <= '1';
						end if;
		when DDATA	=>	if( data_done = '0' ) then 
							NEXT_STATE      <= SDATA;
							send_data_x     <= '1';
						else
							NEXT_STATE      <= DONE;
							data_finished_x <= '1';
						end if;
		when SDATA	=>	if( (ipu_read_in = '1') and (data_ready = '1') ) then
							NEXT_STATE      <= DDATA;
							ce_data_count_x <= '1';
						else
							NEXT_STATE      <= SDATA;
							data_ready_x    <= '1';
							send_data_x     <= '1';
						end if;
		when DONE	=>	if( ipu_start_readout_in = '0' ) then
							NEXT_STATE <= SLEEP;
						else
							NEXT_STATE <= DONE;
						end if;
 
		when others	=>	NEXT_STATE <= SLEEP;
	end case;
end process STATE_TRANSFORM;

-- state decodings
STATE_DECODING: process( CURRENT_STATE )
begin
	case CURRENT_STATE is
		when SLEEP	=>	bsm_x <= x"00";
		when CHKF	=>	bsm_x <= x"01";
		when DELF0	=>	bsm_x <= x"02";
		when DELF1	=>	bsm_x <= x"03";
		when SHDR	=>	bsm_x <= x"04";
		when DDATA	=>	bsm_x <= x"05";
		when SDATA	=>	bsm_x <= x"06";
		when DONE	=>	bsm_x <= x"07";
		when others	=>	bsm_x <= x"ff";
	end case;
end process STATE_DECODING;

---------------------------------------------------------------------------
-- Data multiplexer
---------------------------------------------------------------------------
THE_DATA_MUX: process( clk_in )
begin
	if( rising_edge(clk_in) ) then
		if   ( send_dhdr = '1' ) then
			ipu_data(31 downto 29) <= b"000";               -- reserved bits
			ipu_data(28)           <= '0';                  -- was PACK_BIT
			ipu_data(27 downto 24) <= lvl1_fifo_type_in;    -- trigger type
			ipu_data(23 downto 16) <= lvl1_fifo_code_in;    -- trigger random
			ipu_data(15 downto 0)  <= lvl1_fifo_number_in;  -- trigger number  
		elsif( send_data = '1' ) then
			ipu_data(31 downto 16) <= x"dead";
			ipu_data(15 downto 0)  <= data_count;
		else
			ipu_data               <= x"affed00f";
		end if;
		trgnum_match <= next_trgnum_match;
	end if;
end process THE_DATA_MUX;

-- Check trigger number against IPU number
next_trgnum_match <= '1' when ( ipu_number_in = lvl1_fifo_number_in ) else '0';

-- IPU error pattern
ipu_error(31 downto 25) <= (others => '0');
ipu_error(24)           <= not trgnum_match;
ipu_error(23 downto 16) <= (others => '0');
ipu_error(15 downto 0)  <= (others => '0'); -- common error / status bits

---------------------------------------------------------------------------
-- DEBUG signals
---------------------------------------------------------------------------
debug(63 downto 43) <= (others => '0');

debug(42 downto 23) <= ipu_data(19 downto 0);
debug(22)           <= '0';
debug(21)           <= data_finished;
debug(20)           <= data_ready;
debug(19)           <= rd_fifo;
debug(18)           <= ipu_read_in;
debug(17)           <= ipu_start_readout_in;
debug(16)           <= ld_data_count;
debug(15)           <= send_dhdr;
debug(14)           <= send_data;
debug(13)           <= ce_data_count;
debug(12)           <= data_done;
debug(11 downto 8)  <= data_count(3 downto 0);
debug(7 downto 4)   <= rnd_count(3 downto 0);
debug(3 downto 0)   <= bsm_x(3 downto 0);

---------------------------------------------------------------------------
-- output signals
---------------------------------------------------------------------------
lvl1_fifo_rd_out         <= rd_fifo;
ipu_data_out             <= ipu_data;
ipu_dataready_out        <= data_ready;
ipu_readout_finished_out <= data_finished;
ipu_length_out           <= random;
ipu_error_pattern_out    <= ipu_error;

dbg_out          <= debug;
dbg_bsm_out      <= bsm_x;

end behavioral;
	

--THE_LVL1_INFO_FIFO : fifo_512x36
--      port map(
--        Data(15 downto 0)  => LVL1_TRG_NUMBER_OUT(i*16+15 downto i*16),
--        Data(23 downto 16) => LVL1_TRG_CODE_OUT(i*8+7 downto i*8),
--        Data(31 downto 24) => LVL1_TRG_INFORMATION_OUT(i*8+7 downto i*8),
--        Data(35 downto 32) => LVL1_TRG_TYPE_OUT(i*4+3 downto i*4),
--        Clock              => CLK,
--        WrEn               => LVL1_TRG_RECEIVED_rising(i),
--        RdEn               => trigger_information_read(i),
--        Reset              => reset,
--        Q(15 downto 0)     => trigger_number(i*16+15 downto i*16)
--        Q(23 downto 16)    => trigger_code(i*8+7 downto i*8),
--        Q(31 downto 24)    => trigger_information(i*8+7 downto i*8),
--        Q(35 downto 32)    => trigger_type(i*4+3 downto i*4),
--       Empty              => lvl1_fifo_empty(i),
--        Full               => lvl1_fifo_full(i)


