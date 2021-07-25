-- sbuf5: sends only full packets.
-- This version is optimized for safety, not speed.
-- Speed can be gained by "looking ahead" on the write side of FIFO, especially by
-- monitoring the comb_dataready_in signal to gain one clock cycle.
-- If optimizing is needed, be careful: RD5 state needs to be handled correctly,
-- as it can easily end up in scrambled data and loads of problems in the network.
-- 25.06.2010 MB

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

library work;
--use work.trb_net_std.all;
--use work.lattice_ecp2m_fifo.all;
--use work.trb_net_components.all;

entity trb_net_sbuf5 is
port(
	--  Misc
	CLK                : in  std_logic;
	RESET              : in  std_logic;
	CLK_EN             : in  std_logic;
	-- input
	COMB_DATAREADY_IN  : in  std_logic;
	COMB_next_READ_OUT : out std_logic;
	COMB_DATA_IN       : in  std_logic_vector(18 downto 0);
	-- output
	SYN_DATAREADY_OUT  : out std_logic;
	SYN_DATA_OUT       : out std_logic_vector(18 downto 0);
	SYN_READ_IN        : in  std_logic;
	-- Status and control port
	DEBUG              : out std_logic_vector(7 downto 0);
	DEBUG_BSM          : out std_logic_vector(3 downto 0);
	DEBUG_WCNT         : out std_logic_vector(4 downto 0);
	STAT_BUFFER        : out std_logic
);
end entity;

architecture trb_net_sbuf5_arch of trb_net_sbuf5 is

-- FIFO for buffering at least two packets
component fifo_19x16_obuf is
port(
	Data          : in  std_logic_vector(18 downto 0);
	Clock         : in  std_logic;
	WrEn          : in  std_logic;
	RdEn          : in  std_logic;
	Reset         : in  std_logic;
	AmFullThresh  : in  std_logic_vector(3 downto 0);
	Q             : out std_logic_vector(18 downto 0);
	WCNT          : out std_logic_vector(4 downto 0);
	Empty         : out std_logic;
	Full          : out std_logic;
	AlmostFull    : out std_logic
);
end component fifo_19x16_obuf;



-- State description:
--
-- IDLE: wait for any data to be written into the FIFO
-- RD1 : first word prefetch
-- RD2 : first word output reg, second word prefetch, wait state for full packet in FIFO
-- RDI : generates initial dataready_out, wait state for handshake of first data word
-- RD3 : second word output reg, third word prefetch, wait state for handshake of second data word
-- RD4 : third word output reg, fourth word prefetch, wait state for handshake of third data word
-- RD5 : fourth word output reg, fifth word prefetch, wait state for handshake of forth data word
--       => decision: continous data stream or stalling as FIFO runs empty!
-- RDO : fifth word output reg, wait state for handshake of fifth data word, can also resume transmission
--       if new data is available in FIFO
-- RDW : fifth word output reg, first word prefetch, wait state for handshake of fifth data word,
--       continue data stream or stall if for complete packet

type STATES is (IDLE, RD1, RD2, RDI, RD3, RD4, RD5, RDO, RDW);
signal CURRENT_STATE, NEXT_STATE: STATES;
signal bsm_x                 : std_logic_vector(3 downto 0);
signal bsm                   : std_logic_vector(3 downto 0);
signal update_x              : std_logic; -- load FIFO data into output register

signal syn_dataready_x       : std_logic;
signal syn_dataready         : std_logic; -- must be registered
signal syn_data              : std_logic_vector(18 downto 0); -- output register

signal fifo_data_i           : std_logic_vector(18 downto 0);
signal fifo_data_o           : std_logic_vector(18 downto 0);
signal fifo_wr_en            : std_logic;
signal fifo_rd_en_x          : std_logic;
signal fifo_reset            : std_logic;
signal fifo_wcnt_stdlv       : std_logic_vector(4 downto 0);
signal fifo_wcnt             : unsigned(4 downto 0);
signal fifo_full             : std_logic;
signal fifo_almostfull       : std_logic;

signal debug_x               : std_logic_vector(7 downto 0);

attribute syn_preserve : boolean;
attribute syn_noprune  : boolean;
attribute syn_keep     : boolean;
--attribute syn_preserve of fifo_wcnt       : signal is true;
--attribute syn_keep of fifo_wcnt           : signal is true;
--attribute syn_noprune of fifo_wcnt        : signal is true;
--attribute syn_preserve of bsm             : signal is true;
--attribute syn_keep of bsm                 : signal is true;
--attribute syn_noprune of bsm              : signal is true;

attribute syn_preserve of syn_data        : signal is true;
attribute syn_keep of syn_data            : signal is true;
attribute syn_preserve of syn_dataready   : signal is true;
attribute syn_keep of syn_dataready       : signal is true;

attribute syn_hier : string;
attribute syn_hier of trb_net_sbuf5_arch : architecture is "flatten, firm";

begin

---------------------------------------------------------------------
-- I/O
---------------------------------------------------------------------
fifo_data_i        <= COMB_DATA_IN;
fifo_wr_en         <= COMB_DATAREADY_IN; -- mind the special nature of SBUF!
fifo_reset         <= RESET;
COMB_next_READ_OUT <= not fifo_almostfull;

DEBUG              <= debug_x;
DEBUG_BSM          <= bsm;
DEBUG_WCNT         <= fifo_wcnt_stdlv;
STAT_BUFFER        <= fifo_full;

SYN_DATA_OUT       <= syn_data;
SYN_DATAREADY_OUT  <= syn_dataready;

---------------------------------------------------------------------
-- Fifo
---------------------------------------------------------------------
THE_FIFO: fifo_19x16_obuf
port map(
	Data           => fifo_data_i,
	Clock          => CLK,
	WrEn           => fifo_wr_en,
	RdEn           => fifo_rd_en_x,
	Reset          => fifo_reset,
	AmFullThresh   => x"b",
	Q              => fifo_data_o,
	WCNT           => fifo_wcnt_stdlv,
	Empty          => open,
	Full           => fifo_full,
	AlmostFull     => fifo_almostfull
);

fifo_wcnt <= unsigned(fifo_wcnt_stdlv);


---------------------------------------------------------------------
-- State machine
---------------------------------------------------------------------
-- state registers
STATE_MEM: process( CLK )
begin
	if( rising_edge(CLK) ) then
		if( RESET = '1' ) then
			CURRENT_STATE <= IDLE;
			syn_dataready <= '0';
			bsm           <= x"0";
		else
			CURRENT_STATE <= NEXT_STATE;
			syn_dataready <= syn_dataready_x;
			bsm           <= bsm_x;
		end if;
	end if;
end process STATE_MEM;

-- state transitions
STATE_TRANSFORM: process( CURRENT_STATE, fifo_wcnt, SYN_READ_IN, syn_dataready, COMB_DATAREADY_IN )
begin
	NEXT_STATE      <= IDLE; -- avoid latches
	fifo_rd_en_x    <= '0';
	syn_dataready_x <= '0';
	update_x        <= '0';
	case CURRENT_STATE is
		when IDLE   =>  if( fifo_wcnt > 0 ) then
							-- we have at least one data word in FIFO, so we prefetch it
							NEXT_STATE   <= RD1;
							fifo_rd_en_x <= '1';
						else
							NEXT_STATE   <= IDLE;
						end if;
		when RD1    =>  if( fifo_wcnt > 0 ) then
							-- second data word is available in FIFO, so we prefetch it and
							-- forward the first word to the output register
							NEXT_STATE   <= RD2;
							fifo_rd_en_x <= '1';
							update_x     <= '1';
						else
							NEXT_STATE   <= RD1;
						end if;
		when RD2    =>  if   ( fifo_wcnt > 2 ) then
							-- at least all three missing words in FIFO... so we go ahead and notify full packet availability
							NEXT_STATE      <= RDI;
							syn_dataready_x <= '1';
						else
							NEXT_STATE      <= RD2;
						end if;
		when RDI	=>  syn_dataready_x <= '1';
						if( SYN_READ_IN = '1' ) then
							-- first word of packet has been transfered, update output register and prefetch next data word
							NEXT_STATE      <= RD3;
							fifo_rd_en_x    <= '1';
							update_x        <= '1';
						else
							NEXT_STATE <= RDI;
						end if;
		when RD3    =>  syn_dataready_x <= '1';
						if( SYN_READ_IN = '1' ) then
							-- second word of packet has been transfered, update output register and prefetch next data word
							NEXT_STATE      <= RD4;
							fifo_rd_en_x    <= '1';
							update_x        <= '1';
						else
							NEXT_STATE      <= RD3;
						end if;
		when RD4    =>  syn_dataready_x <= '1';
							-- third word of packet has been transfered, update output register and prefetch next data word
						if( SYN_READ_IN = '1' ) then
							NEXT_STATE      <= RD5;
							fifo_rd_en_x    <= '1';
							update_x        <= '1';
						else
							NEXT_STATE      <= RD4;
						end if;
		when RD5    =>  syn_dataready_x <= '1';
						-- DANGER. This is the key state for decisions here.
						-- There are many ways to do it the wrong way, depending on the FIFO fill level.
						if   ( (SYN_READ_IN = '1') and (fifo_wcnt < 2) ) then
							-- fourth word of packet has been transfered, and FIFO has not seen any new packet word.
							-- so we update output register only, no prefetch
							NEXT_STATE      <= RDO;
							update_x        <= '1';
						elsif( (SYN_READ_IN = '1') and (fifo_wcnt > 1) ) then
							-- fourth word of packet DONE, new packet data already in the FIFO
							-- so we can prefetch on data word already and update the output register
							NEXT_STATE      <= RDW;
							fifo_rd_en_x    <= '1';
							update_x        <= '1';
						else
							NEXT_STATE      <= RD5;
						end if;
		when RDO    =>  if   ( (SYN_READ_IN = '1') and (fifo_wcnt = 0) ) then
							-- last word of packet has been transfered, and no new data words to handle.
							-- we keep the last transfered word in the output register and wait for new packets to arrive.
							NEXT_STATE      <= IDLE;
						elsif( (SYN_READ_IN = '1') and (fifo_wcnt > 0) ) then
							-- last word of packet has been transfered, and a new packet data available.
							-- so we enter the prefetch phase again.
							NEXT_STATE      <= RD1;
							fifo_rd_en_x    <= '1';
						else
							NEXT_STATE      <= RDO;
							syn_dataready_x <= '1';
						end if;
		when RDW    =>  if   ( (SYN_READ_IN = '1') and (fifo_wcnt > 3) ) then
							-- last word of packet has been transfered, complete packet in FIFO, so we can go ahead.
							NEXT_STATE      <= RDI;
							fifo_rd_en_x    <= '1';
							update_x        <= '1';
							syn_dataready_x <= '1';
						elsif( (SYN_READ_IN = '1') and (fifo_wcnt < 4 ) ) then
							-- last word of packet has been transfered, but new packet not complete yet.
							NEXT_STATE      <= RD2;
							fifo_rd_en_x    <= '1';
							update_x        <= '1';
						else
							NEXT_STATE      <= RDW;
							syn_dataready_x <= '1';
						end if;
		when others =>  NEXT_STATE <= IDLE;
	end case;
end process STATE_TRANSFORM;

-- just for debugging
THE_DECODE_PROC: process( NEXT_STATE )
begin
	case NEXT_STATE is
		when IDLE   => bsm_x <= x"0";
		when RD1    => bsm_x <= x"1";
		when RD2    => bsm_x <= x"2";
		when RDI    => bsm_x <= x"3";
		when RD3    => bsm_x <= x"4";
		when RD4    => bsm_x <= x"5";
		when RD5    => bsm_x <= x"6";
		when RDO    => bsm_x <= x"7";
		when RDW    => bsm_x <= x"8";
		when others => bsm_x <= x"f";
	end case;
end process THE_DECODE_PROC;

THE_SYNC_PROC: process( CLK )
begin
	if( rising_edge(CLK) ) then
		if( update_x = '1' ) then
			syn_data <= fifo_data_o;
		end if;
	end if;
end process THE_SYNC_PROC;

---------------------------------------------------------------------
-- DEBUG
---------------------------------------------------------------------
debug_x(7 downto 4)  <= x"0";
debug_x(3)           <= COMB_DATAREADY_IN;
debug_x(2)           <= '0';
debug_x(1)           <= '0';
debug_x(0)           <= fifo_rd_en_x;

end architecture;