library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity bus_handler is
port( CLK_IN				: in	std_logic;
	  CLEAR_IN				: in	std_logic;
	  RESET_IN				: in	std_logic;
	  DAT_ADDR_IN			: in	std_logic_vector(15 downto 0); -- address bus 
	  DAT_DATA_IN			: in	std_logic_vector(31 downto 0); -- data from TRB endpoint
	  DAT_DATA_OUT			: out	std_logic_vector(31 downto 0); -- data to TRB endpoint
	  DAT_READ_ENABLE_IN	: in	std_logic; -- read pulse
	  DAT_WRITE_ENABLE_IN	: in	std_logic; -- write pulse
	  DAT_TIMEOUT_IN		: in	std_logic; -- access timed out
	  DAT_DATAREADY_OUT		: out	std_logic; -- your data, master, as requested
	  DAT_WRITE_ACK_OUT		: out	std_logic; -- data accepted
	  DAT_NO_MORE_DATA_OUT	: out	std_logic; -- don't disturb me now
	  DAT_UNKNOWN_ADDR_OUT	: out	std_logic; -- noone here to answer your request
	  SLV_SELECT_OUT		: out	std_logic_vector(47 downto 0); -- select signal for slave entities
	  SLV_READ_OUT			: out	std_logic; -- read signal for slave entities
	  SLV_WRITE_OUT			: out	std_logic; -- write signal for slave entities
	  SLV_BUSY_IN			: in	std_logic; -- wired OR busy from slave entities
	  SLV_ACK_IN			: in	std_logic; -- slave has accepted access
	  SLV_DATA_IN			: in	std_logic_vector(31 downto 0); -- read data from slaves
	  SLV_DATA_OUT			: out	std_logic_vector(31 downto 0); -- write data to slaves
	  STAT					: out	std_logic_vector(31 downto 0)
	);
end entity;

architecture Behavioral of bus_handler is

-- Signals
	type STATES is (SLEEP,RACC,WACC,RFAIL,WFAIL,ROK,WOK,STATW,STATS,STATD,NOONE,DONE);
	signal CURRENT_STATE, NEXT_STATE: STATES;
	
	signal bsm						: std_logic_vector(3 downto 0);

	signal rst_strb_x				: std_logic;
	signal rst_strb					: std_logic;
	signal buf_dat_write_ack_x		: std_logic;
	signal buf_dat_write_ack		: std_logic;
	signal buf_dat_dataready_x		: std_logic;
	signal buf_dat_dataready		: std_logic;
	signal buf_dat_no_more_data_x	: std_logic;
	signal buf_dat_no_more_data		: std_logic;
	signal buf_dat_unknown_addr_x	: std_logic;
	signal buf_dat_unknown_addr		: std_logic;

	signal buf_slv_select_x			: std_logic_vector(47 downto 0);
	signal buf_slv_select			: std_logic_vector(47 downto 0);
	signal buf_slv_read				: std_logic;
	signal buf_slv_write			: std_logic;
	signal no_slave_reg_x			: std_logic;
	signal no_slave_mem_x			: std_logic;
	signal no_slave					: std_logic;
	signal slave_busy				: std_logic;
	signal slave_ack				: std_logic;

begin

-- Memory map:
-- 80xx => single registers
-- axxx => pedestal memory APV[15:0]
-- bxxx => threshold memory APV[15:0]

------------------------------------------------------------------------------
-- This part is crucial, as ACK and BSY are tristate signals!
------------------------------------------------------------------------------
-- Slave address decoder - registers (single address decoding)
THE_ADDRESS_DEC_REG_PROC: process( dat_addr_in )
begin
	case dat_addr_in is
		when x"8083"	=>	buf_slv_select_x(15 downto 0) <= x"8000"; no_slave_reg_x <= '0'; -- trigger 3
		when x"8082"	=>	buf_slv_select_x(15 downto 0) <= x"4000"; no_slave_reg_x <= '0'; -- trigger 2
		when x"8081"	=>	buf_slv_select_x(15 downto 0) <= x"2000"; no_slave_reg_x <= '0'; -- trigger 1
		when x"8080"	=>	buf_slv_select_x(15 downto 0) <= x"1000"; no_slave_reg_x <= '0'; -- trigger 0
		when x"8040"	=>	buf_slv_select_x(15 downto 0) <= x"0800"; no_slave_reg_x <= '0'; -- I2C master
		when x"8021"	=>	buf_slv_select_x(15 downto 0) <= x"0400"; no_slave_reg_x <= '0'; -- EDS_DONE
		when x"8020"	=>	buf_slv_select_x(15 downto 0) <= x"0200"; no_slave_reg_x <= '0'; -- BUF_DONE
		when x"8001"	=>	buf_slv_select_x(15 downto 0) <= x"0100"; no_slave_reg_x <= '0'; -- test register bad
		when x"8000"	=>	buf_slv_select_x(15 downto 0) <= x"0080"; no_slave_reg_x <= '0'; -- test register good
		when x"8002"	=>	buf_slv_select_x(15 downto 0) <= x"0040"; no_slave_reg_x <= '0'; -- real test register 
		when others		=>	buf_slv_select_x(15 downto 0) <= x"0000"; no_slave_reg_x <= '1';
	end case;
end process THE_ADDRESS_DEC_REG_PROC;

-- Slave address decoder - memory (256 longwords decoding)
THE_ADDRESS_DEC_MEM_PROC: process( dat_addr_in(15 downto 8) )
begin
	case dat_addr_in(15 downto 8) is
		when x"a0"		=>	buf_slv_select_x(47 downto 16) <= x"8000_0000"; no_slave_mem_x <= '0'; -- pedestal 0
		when x"a1"		=>	buf_slv_select_x(47 downto 16) <= x"4000_0000"; no_slave_mem_x <= '0'; -- pedestal 1
		when x"a2"		=>	buf_slv_select_x(47 downto 16) <= x"2000_0000"; no_slave_mem_x <= '0'; -- pedestal 2 
		when x"a3"		=>	buf_slv_select_x(47 downto 16) <= x"1000_0000"; no_slave_mem_x <= '0'; -- pedestal 3 
		when x"a4"		=>	buf_slv_select_x(47 downto 16) <= x"0800_0000"; no_slave_mem_x <= '0'; -- pedestal 4 
		when x"a5"		=>	buf_slv_select_x(47 downto 16) <= x"0400_0000"; no_slave_mem_x <= '0'; -- pedestal 5 
		when x"a6"		=>	buf_slv_select_x(47 downto 16) <= x"0200_0000"; no_slave_mem_x <= '0'; -- pedestal 6 
		when x"a7"		=>	buf_slv_select_x(47 downto 16) <= x"0100_0000"; no_slave_mem_x <= '0'; -- pedestal 7 
		when x"a8"		=>	buf_slv_select_x(47 downto 16) <= x"0080_0000"; no_slave_mem_x <= '0'; -- pedestal 8 
		when x"a9"		=>	buf_slv_select_x(47 downto 16) <= x"0040_0000"; no_slave_mem_x <= '0'; -- pedestal 9 
		when x"aa"		=>	buf_slv_select_x(47 downto 16) <= x"0020_0000"; no_slave_mem_x <= '0'; -- pedestal 10 
		when x"ab"		=>	buf_slv_select_x(47 downto 16) <= x"0010_0000"; no_slave_mem_x <= '0'; -- pedestal 11 
		when x"ac"		=>	buf_slv_select_x(47 downto 16) <= x"0008_0000"; no_slave_mem_x <= '0'; -- pedestal 12 
		when x"ad"		=>	buf_slv_select_x(47 downto 16) <= x"0004_0000"; no_slave_mem_x <= '0'; -- pedestal 13 
		when x"ae"		=>	buf_slv_select_x(47 downto 16) <= x"0002_0000"; no_slave_mem_x <= '0'; -- pedestal 14 
		when x"af"		=>	buf_slv_select_x(47 downto 16) <= x"0001_0000"; no_slave_mem_x <= '0'; -- pedestal 15 
		when x"b0"		=>	buf_slv_select_x(47 downto 16) <= x"0000_8000"; no_slave_mem_x <= '0'; -- threshold 0
		when x"b1"		=>	buf_slv_select_x(47 downto 16) <= x"0000_4000"; no_slave_mem_x <= '0'; -- threshold 1 
		when x"b2"		=>	buf_slv_select_x(47 downto 16) <= x"0000_2000"; no_slave_mem_x <= '0'; -- threshold 2 
		when x"b3"		=>	buf_slv_select_x(47 downto 16) <= x"0000_1000"; no_slave_mem_x <= '0'; -- threshold 3 
		when x"b4"		=>	buf_slv_select_x(47 downto 16) <= x"0000_0800"; no_slave_mem_x <= '0'; -- threshold 4 
		when x"b5"		=>	buf_slv_select_x(47 downto 16) <= x"0000_0400"; no_slave_mem_x <= '0'; -- threshold 5 
		when x"b6"		=>	buf_slv_select_x(47 downto 16) <= x"0000_0200"; no_slave_mem_x <= '0'; -- threshold 6 
		when x"b7"		=>	buf_slv_select_x(47 downto 16) <= x"0000_0100"; no_slave_mem_x <= '0'; -- threshold 7 
		when x"b8"		=>	buf_slv_select_x(47 downto 16) <= x"0000_0080"; no_slave_mem_x <= '0'; -- threshold 8 
		when x"b9"		=>	buf_slv_select_x(47 downto 16) <= x"0000_0040"; no_slave_mem_x <= '0'; -- threshold 9 
		when x"ba"		=>	buf_slv_select_x(47 downto 16) <= x"0000_0020"; no_slave_mem_x <= '0'; -- threshold 10 
		when x"bb"		=>	buf_slv_select_x(47 downto 16) <= x"0000_0010"; no_slave_mem_x <= '0'; -- threshold 11 
		when x"bc"		=>	buf_slv_select_x(47 downto 16) <= x"0000_0008"; no_slave_mem_x <= '0'; -- threshold 12 
		when x"bd"		=>	buf_slv_select_x(47 downto 16) <= x"0000_0004"; no_slave_mem_x <= '0'; -- threshold 13 
		when x"be"		=>	buf_slv_select_x(47 downto 16) <= x"0000_0002"; no_slave_mem_x <= '0'; -- threshold 14
		when x"bf"		=>	buf_slv_select_x(47 downto 16) <= x"0000_0001"; no_slave_mem_x <= '0'; -- threshold 15
		when others		=>	buf_slv_select_x(47 downto 16) <= x"0000_0000"; no_slave_mem_x <= '1';
	end case;
end process THE_ADDRESS_DEC_MEM_PROC;


-- synchronize signals
THE_SYNC_PROC: process( clk_in )
begin
	if( rising_edge(clk_in) ) then
		buf_slv_select   <= buf_slv_select_x;
		no_slave         <= no_slave_reg_x and no_slave_mem_x;
	end if;
end process THE_SYNC_PROC;


-- Slave response lines
slave_ack    <= slv_ack_in  when ( no_slave = '0' ) else '0';
slave_busy   <= slv_busy_in when ( no_slave = '0' ) else '0';
dat_data_out <= slv_data_in when ( no_slave = '0' ) else (others => '0');

-- Data tunneling to slave entities
slv_data_out <= dat_data_in;

-- Read / write strobe
THE_READ_WRITE_STROBE_PROC: process( clk_in, clear_in )
begin
	if( clear_in = '1' ) then
		buf_slv_read  <= '0';
		buf_slv_write <= '0';
	elsif( rising_edge(clk_in) ) then
		if( reset_in = '1' ) then
			buf_slv_read  <= '0';
			buf_slv_write <= '0';
		elsif( (dat_read_enable_in = '1') and (dat_write_enable_in = '0') ) then
			buf_slv_read  <= '1';
			buf_slv_write <= '0';
		elsif( (dat_read_enable_in = '0') and (dat_write_enable_in = '1') ) then
			buf_slv_read  <= '0';
			buf_slv_write <= '1';
		elsif( rst_strb = '1' ) then
			buf_slv_read  <= '0';
			buf_slv_write <= '0';
		end if;
	end if;
end process THE_READ_WRITE_STROBE_PROC;



-- The main state machine
-- State memory process
STATE_MEM: process( clk_in, clear_in )
begin
	if( clear_in = '1' ) then
		CURRENT_STATE <= SLEEP;
		rst_strb              <= '0';
		buf_dat_dataready     <= '0';
		buf_dat_no_more_data  <= '0';
		buf_dat_write_ack     <= '0';
		buf_dat_unknown_addr  <= '0';
	elsif( rising_edge(clk_in) ) then
		if( reset_in = '1' ) then
			CURRENT_STATE <= SLEEP;
			rst_strb              <= '0';
			buf_dat_dataready     <= '0';
			buf_dat_no_more_data  <= '0';
			buf_dat_write_ack     <= '0';
			buf_dat_unknown_addr  <= '0';
		else
			CURRENT_STATE <= NEXT_STATE;
			rst_strb              <= rst_strb_x;
			buf_dat_dataready     <= buf_dat_dataready_x;
			buf_dat_no_more_data  <= buf_dat_no_more_data_x;
			buf_dat_write_ack     <= buf_dat_write_ack_x;
			buf_dat_unknown_addr  <= buf_dat_unknown_addr_x;
		end if;
	end if;
end process STATE_MEM;

-- Transition matrix
TRANSFORM: process(CURRENT_STATE, no_slave, buf_slv_read, buf_slv_write, slave_ack, slave_busy, dat_timeout_in )
begin
	NEXT_STATE <= SLEEP;
	rst_strb_x <= '0';
	buf_dat_dataready_x    <= '0';
	buf_dat_no_more_data_x <= '0';
	buf_dat_write_ack_x    <= '0';
	buf_dat_unknown_addr_x <= '0';
	case CURRENT_STATE is
		when SLEEP		=>	if   ( (no_slave = '1') and ((buf_slv_read = '1') or (buf_slv_write = '1')) ) then
								NEXT_STATE <= NOONE;
								buf_dat_unknown_addr_x <= '1';
							elsif( (buf_slv_read = '1') and (buf_slv_write = '0') ) then
								NEXT_STATE <= RACC;
							elsif( (buf_slv_read = '0') and (buf_slv_write = '1') ) then
								NEXT_STATE <= WACC;
							else
								NEXT_STATE <= SLEEP;
							end if;
		when RACC		=>	if   ( dat_timeout_in = '1' ) then
								NEXT_STATE <= DONE;
								rst_strb_x <= '1';
							elsif( slave_busy = '1' ) then
								NEXT_STATE <= RFAIL;
								buf_dat_no_more_data_x <= '1';
							elsif( slave_ack = '1' ) then
								NEXT_STATE <= ROK;
								buf_dat_dataready_x <= '1';
							else
								NEXT_STATE <= RACC;
							end if;
		when RFAIL		=>	NEXT_STATE <= DONE;
							rst_strb_x <= '1';
		when ROK		=>	NEXT_STATE <= DONE;
							rst_strb_x <= '1';
		when WACC		=>	if   ( dat_timeout_in = '1' ) then
								NEXT_STATE <= DONE;
								rst_strb_x <= '1';
							elsif( slave_busy = '1' ) then
								NEXT_STATE <= WFAIL;
								buf_dat_no_more_data_x <= '1';
							elsif( slave_ack = '1' ) then
								NEXT_STATE <= WOK;
								buf_dat_write_ack_x <= '1';
							else
								NEXT_STATE <= WACC;
							end if;
		when WFAIL		=>	NEXT_STATE <= DONE;
							rst_strb_x <= '1';
		when WOK		=>	NEXT_STATE <= DONE;
							rst_strb_x <= '1';
		when NOONE		=>	NEXT_STATE <= DONE;
							rst_strb_x <= '1';
		when DONE		=>	NEXT_STATE <= SLEEP; -- ?????
				-- Just in case...
		when others 	=>	NEXT_STATE <= SLEEP; 
	end case;
end process TRANSFORM;

-- Output decoding
DECODE: process(CURRENT_STATE)
begin
	case CURRENT_STATE is
		when SLEEP		=>	bsm <= x"0";
		when RACC		=>	bsm <= x"1";
		when ROK		=>	bsm <= x"2";
		when RFAIL		=>	bsm <= x"3";
		when WACC		=>	bsm <= x"4";
		when WOK		=>	bsm <= x"5";
		when NOONE		=>	bsm <= x"6";
		when DONE		=>	bsm <= x"7";
		when others		=>	bsm <= x"f";
	end case;							 
end process DECODE;

-- Outputs
dat_dataready_out    <= buf_dat_dataready;
dat_no_more_data_out <= buf_dat_no_more_data;
dat_unknown_addr_out <= buf_dat_unknown_addr;
dat_write_ack_out    <= buf_dat_write_ack;

slv_select_out  <= buf_slv_select;
slv_read_out    <= buf_slv_read;
slv_write_out   <= buf_slv_write;

stat(31 downto 9)  <= (others => '0');
stat(8)            <= rst_strb;
stat(7 downto 4)   <= (others => '0');
stat(3 downto 0)   <= bsm;

end Behavioral;
