library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
--use work.trb_net_components.all;

entity trb_net16_rx_full_packets is
port(
  -- Resets & clocks
  SYSCLK_IN             : in  std_logic;
  RESET_IN              : in  std_logic;
  -- FIFO signals
  FIFO_READ_OUT         : out std_logic;
  FIFO_RCNT_IN          : in  std_logic_vector(9 downto 0);
  FIFO_RESET_OUT        : out std_logic;
  -- Media Interface
  MED_READ_IN           : in  std_logic;
  MED_DATAREADY_OUT     : out std_logic;
  MED_PACKET_NUM_OUT    : out std_logic_vector(2 downto 0);
  UPDATE_OUT            : out std_logic;
	PKT_IN_TRANSIT_OUT    : out std_logic; -- full packet received and in transmission to media interface
  -- Status signals
	RX_ALLOW_IN           : in  std_logic;
	RX_RESUME_IN          : in  std_logic;
	RX_LD_DATA_CTR_IN     : in  std_logic;
	RX_DATA_CTR_VAL_IN    : in  std_logic_vector(7 downto 0);
	RX_DATA_CTR_OUT       : out std_logic_vector(7 downto 0);
  PACKET_TIMEOUT_OUT    : out std_logic;
  ENABLE_CORRECTION_IN  : in  std_logic;
  -- Debug signals
  STAT_REG_OUT          : out std_logic_vector(15 downto 0);
  DBG_OUT               : out std_logic_vector(15 downto 0)
);
end entity trb_net16_rx_full_packets;


architecture behavioral of trb_net16_rx_full_packets is

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

-- state declarations
type STATES is (IDLE, RD1, RD2, RDI, RD3, RD4, RD5, RDO, RDW, TOC, CLEAN);
signal CURRENT_STATE, NEXT_STATE: STATES;

-- normal signals
signal bsm_x                : std_logic_vector(3 downto 0);
signal bsm                  : std_logic_vector(3 downto 0);
signal update_x             : std_logic;
signal med_dataready_x      : std_logic;
signal med_dataready        : std_logic;
signal pkt_timeout_x        : std_logic;
signal pkt_timeout          : std_logic;
signal inc_data_x           : std_logic;
signal inc_data             : std_logic;
signal transit_x            : std_logic;
signal transit              : std_logic;

signal fifo_rd_en_x         : std_logic;
signal fifo_rcnt            : unsigned(9 downto 0);
signal fifo_rst_x           : std_logic;
signal fifo_rst             : std_logic;

signal rx_counter           : unsigned(2 downto 0);

signal timeout_ctr          : unsigned(9 downto 0);
signal rst_toc_x            : std_logic;
signal rst_toc              : std_logic;
signal ce_toc_x             : std_logic;
signal ce_toc               : std_logic;
signal toc_done_x           : std_logic;
signal toc_done             : std_logic;

signal rx_data_ctr          : unsigned(7 downto 0);

signal debug                : std_logic_vector(15 downto 0);


attribute syn_keep  : boolean;
attribute syn_preserve : boolean;
attribute NOMERGE   : string;
attribute NOCLIP    : string;

attribute syn_keep  of bsm : signal is true;
attribute syn_preserve of bsm : signal is true;
attribute NOMERGE   of bsm : signal is "ON";
attribute NOCLIP    of bsm : signal is "ON";
attribute syn_keep  of bsm_x : signal is true;
attribute syn_preserve of bsm_x : signal is true;
attribute NOMERGE   of bsm_x : signal is "ON";
attribute NOCLIP    of bsm_x : signal is "ON";

begin

----------------------------------------------------------------------
-- convert RCNT to unsigned for state machine
----------------------------------------------------------------------
fifo_rcnt <= unsigned(FIFO_RCNT_IN);

----------------------------------------------------------------------
-- data counter for retransmission
----------------------------------------------------------------------
THE_DATA_CTR_PROC: process( SYSCLK_IN )
begin
	if( rising_edge(SYSCLK_IN) ) then
		if   ( RESET_IN = '1' ) then
			rx_data_ctr <= (others => '0');
		elsif( RX_LD_DATA_CTR_IN = '1' ) then
			rx_data_ctr <= unsigned(RX_DATA_CTR_VAL_IN);
		elsif( inc_data = '1' ) then
			rx_data_ctr <= rx_data_ctr + 5;
		end if;
	end if;
end process THE_DATA_CTR_PROC;

----------------------------------------------------------------------
-- RX packet state machine
----------------------------------------------------------------------
-- state registers
STATE_MEM: process( SYSCLK_IN )
begin
  if( rising_edge(SYSCLK_IN) ) then
    if( RESET_IN = '1' ) then
      CURRENT_STATE <= IDLE;
      med_dataready <= '0';
      ce_toc        <= '0';
      rst_toc       <= '0';
      fifo_rst      <= '0';
			inc_data      <= '0';
			transit       <= '0';
      pkt_timeout   <= '0';
      bsm           <= (others => '0');
    else
      CURRENT_STATE <= NEXT_STATE;
      med_dataready <= med_dataready_x;
      ce_toc        <= ce_toc_x;
      rst_toc       <= rst_toc_x;
      fifo_rst      <= fifo_rst_x;
			inc_data      <= inc_data_x;
			transit       <= transit_x;
      pkt_timeout   <= pkt_timeout_x;
      bsm           <= bsm_x;
    end if;
  end if;
end process STATE_MEM;

-- state transitions
STATE_TRANSFORM: process( CURRENT_STATE, fifo_rcnt, RX_RESUME_IN, MED_READ_IN, med_dataready, toc_done )
begin
  NEXT_STATE      <= IDLE; -- avoid latches
  fifo_rd_en_x    <= '0';
  med_dataready_x <= '0';
  update_x        <= '0';
  ce_toc_x        <= '0';
  rst_toc_x       <= '0';
  fifo_rst_x      <= '0';
	inc_data_x      <= '0';
	transit_x       <= '0';
  pkt_timeout_x   <= '0';
  case CURRENT_STATE is
    when IDLE   =>
            if( fifo_rcnt > 0 ) then
              -- we have at least one data word in FIFO, so we prefetch it
              NEXT_STATE    <= RD1;
              fifo_rd_en_x  <= '1';
              ce_toc_x      <= '1';
            else
              NEXT_STATE    <= IDLE;
            end if;
    when RD1    =>
            if   ( fifo_rcnt > 1 ) then -- was 0
              -- second data word is available in FIFO, so we prefetch it and
              -- forward the first word to the output register
              NEXT_STATE    <= RD2;
              fifo_rd_en_x  <= '1';
              update_x      <= '1';
              ce_toc_x      <= '1';
            elsif( toc_done = '1' ) then
              NEXT_STATE    <= TOC;
              pkt_timeout_x <= '1';
							rst_toc_x     <= '1';
              fifo_rst_x    <= '1';
						elsif( RX_RESUME_IN = '1' ) then -- NEW
							NEXT_STATE    <= IDLE; -- NEW
							rst_toc_x     <= '1'; -- NEW
            else
              NEXT_STATE    <= RD1;
              ce_toc_x      <= '1';
            end if;
    when RD2    =>
            if   ( fifo_rcnt > 2 ) then
              -- at least all three missing words in FIFO... so we go ahead and notify full packet availability
              NEXT_STATE      <= RDI;
              med_dataready_x <= '1';
							inc_data_x      <= '1';
              rst_toc_x       <= '1';
							transit_x       <= '1';
            elsif( toc_done = '1' ) then
              NEXT_STATE    <= TOC;
							pkt_timeout_x <= '1';
              rst_toc_x     <= '1';
              fifo_rst_x    <= '1';
						elsif( RX_RESUME_IN = '1' ) then -- NEW
							NEXT_STATE    <= IDLE; -- NEW
							rst_toc_x     <= '1'; -- NEW
            else
              NEXT_STATE    <= RD2;
              ce_toc_x      <= '1';
            end if;
    when RDI  =>
            med_dataready_x <= '1';
						transit_x       <= '1';
            if( MED_READ_IN = '1' ) then
              -- first word of packet has been transfered, update output register and prefetch next data word
              NEXT_STATE      <= RD3;
              fifo_rd_en_x    <= '1';
              update_x        <= '1';
            else
              NEXT_STATE <= RDI;
            end if;
    when RD3    =>
            med_dataready_x <= '1';
						transit_x       <= '1';
            if( MED_READ_IN = '1' ) then
              -- second word of packet has been transfered, update output register and prefetch next data word
              NEXT_STATE      <= RD4;
              fifo_rd_en_x    <= '1';
              update_x        <= '1';
            else
              NEXT_STATE      <= RD3;
            end if;
    when RD4    =>
            med_dataready_x <= '1';
						transit_x       <= '1';
            -- third word of packet has been transfered, update output register and prefetch next data word
            if( MED_READ_IN = '1' ) then
              NEXT_STATE      <= RD5;
              fifo_rd_en_x    <= '1';
              update_x        <= '1';
            else
              NEXT_STATE      <= RD4;
            end if;
    when RD5    =>
            med_dataready_x <= '1';
            -- DANGER. This is the key state for decisions here.
            -- There are many ways to do it the wrong way, depending on the FIFO fill level.
            if   ( (MED_READ_IN = '1') and (fifo_rcnt < 3) ) then -- was 2, changed due to RCNT latency
              -- fourth word of packet has been transfered, and FIFO has not seen any new packet word.
              -- so we update output register only, no prefetch
              NEXT_STATE      <= RDO;
              update_x        <= '1';
            elsif( (MED_READ_IN = '1') and (fifo_rcnt > 2) ) then -- was 1, changed due to RCNT latency
              -- fourth word of packet DONE, new packet data already in the FIFO
              -- so we can prefetch on data word already and update the output register
              NEXT_STATE      <= RDW;
              fifo_rd_en_x    <= '1';
              update_x        <= '1';
							transit_x       <= '1';
            else
              NEXT_STATE      <= RD5;
            end if;
    when RDO    =>
            if   ( (MED_READ_IN = '1') and (fifo_rcnt = 0) ) then
              -- last word of packet has been transfered, and no new data words to handle.
              -- we keep the last transfered word in the output register and wait for new packets to arrive.
              NEXT_STATE      <= IDLE;
            elsif( (MED_READ_IN = '1') and (fifo_rcnt > 0) ) then
              -- last word of packet has been transfered, and a new packet data available.
              -- so we enter the prefetch phase again.
              NEXT_STATE      <= RD1;
              fifo_rd_en_x    <= '1';
            else
              NEXT_STATE      <= RDO;
              med_dataready_x <= '1';
            end if;
    when RDW    =>
            if   ( (MED_READ_IN = '1') and (fifo_rcnt > 3) ) then
              -- last word of packet has been transfered, complete packet in FIFO, so we can go ahead.
              NEXT_STATE      <= RDI;
              fifo_rd_en_x    <= '1';
              update_x        <= '1';
              med_dataready_x <= '1';
							transit_x       <= '1';
            elsif( (MED_READ_IN = '1') and (fifo_rcnt < 4 ) ) then
              -- last word of packet has been transfered, but new packet not complete yet.
              NEXT_STATE      <= RD2;
              fifo_rd_en_x    <= '1';
              update_x        <= '1';
            else
              NEXT_STATE      <= RDW;
              med_dataready_x <= '1';
            end if;
    when TOC    =>
						if( RX_RESUME_IN = '1' ) then
							NEXT_STATE    <= CLEAN;
						else
							NEXT_STATE    <= TOC;
							pkt_timeout_x <= '1';
							fifo_rst_x    <= '1';
						end if;
    when CLEAN  =>
            NEXT_STATE   <= IDLE; -- not really necessary?

    when others =>
            NEXT_STATE <= IDLE;
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
    when TOC    => bsm_x <= x"9";
    when CLEAN  => bsm_x <= x"a";
    when others => bsm_x <= x"f";
  end case;
end process THE_DECODE_PROC;

----------------------------------------------------------------------
-- RX packet counter
----------------------------------------------------------------------
THE_RX_PACKETS_PROC: process( SYSCLK_IN )
begin
  if( rising_edge(SYSCLK_IN) ) then
    if( (RESET_IN = '1') or (RX_ALLOW_IN = '0') or (pkt_timeout = '1') ) then
      rx_counter <= unsigned(c_H0);
    else
      if( (med_dataready = '1') and (MED_READ_IN = '1') ) then -- modified
        if( rx_counter = unsigned(c_max_word_number) ) then
          rx_counter <= (others => '0');
        else
          rx_counter <= rx_counter + 1;
        end if;
      end if;
    end if;
  end if;
end process THE_RX_PACKETS_PROC;

----------------------------------------------------------------------
-- Timeout counter
----------------------------------------------------------------------
THE_TOC_PROC: process( SYSCLK_IN )
begin
  if( rising_edge(SYSCLK_IN) ) then
    toc_done <= toc_done_x;
    if   ( (RESET_IN = '1') or (rst_toc = '1') ) then
      timeout_ctr <= (others => '0');
    elsif( (ce_toc = '1') and (toc_done = '0') ) then
      timeout_ctr <= timeout_ctr + 1;
    end if;
  end if;
end process THE_TOC_PROC;

toc_done_x <= '1' when ( timeout_ctr(5 downto 2) = b"11_11" and ENABLE_CORRECTION_IN = '1') else '0';

----------------------------------------------------------------------
-- Debug signals
----------------------------------------------------------------------
debug(15 downto 12)  <= bsm;
debug(11)            <= toc_done;
debug(10)            <= ce_toc;
debug(9)             <= rst_toc;
debug(8 downto 0)    <= (others => '0');

STAT_REG_OUT(3 downto 0)  <= bsm;
STAT_REG_OUT(4)           <= toc_done;
STAT_REG_OUT(5)           <= transit;
STAT_REG_OUT(6)           <= pkt_timeout;
STAT_REG_OUT(7)           <= ce_toc;
STAT_REG_OUT(10 downto 8) <= std_logic_vector(rx_counter);
STAT_REG_OUT(15 downto 11)<= (others => '0');


----------------------------------------------------------------------
-- Output signals
----------------------------------------------------------------------
UPDATE_OUT            <= update_x;
FIFO_READ_OUT         <= fifo_rd_en_x;
FIFO_RESET_OUT        <= fifo_rst;
RX_DATA_CTR_OUT       <= std_logic_vector(rx_data_ctr);
PACKET_TIMEOUT_OUT    <= pkt_timeout;
PKT_IN_TRANSIT_OUT    <= transit;

MED_DATAREADY_OUT     <= med_dataready;
MED_PACKET_NUM_OUT    <= std_logic_vector(rx_counter);

DBG_OUT               <= debug;

end behavioral;