library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
--use work.trb_net_components.all;

entity trb_net16_rx_packets is
port(
  -- Resets
  RESET_IN              : in  std_logic;
  QUAD_RST_IN           : in  std_logic;
  -- data stream from SerDes
  CLK_IN                : in  std_logic; -- SerDes RX clock
  RX_ALLOW_IN           : in  std_logic;
  RX_DATA_IN            : in  std_logic_vector(7 downto 0);
  RX_K_IN               : in  std_logic;
  -- media interface
  SYSCLK_IN             : in  std_logic; -- 100MHz master clock
  MED_DATA_OUT          : out std_logic_vector(15 downto 0);
  MED_DATAREADY_OUT     : out std_logic;
  MED_READ_IN           : in  std_logic;
  MED_PACKET_NUM_OUT    : out std_logic_vector(2 downto 0);
  -- reset handling
  SEND_RESET_WORDS_OUT  : out std_logic;
  MAKE_TRBNET_RESET_OUT : out std_logic;
  -- Status signals
  PACKET_TIMEOUT_OUT    : out std_logic;
  -- Debug signals
  BSM_OUT               : out std_logic_vector(3 downto 0);
  DBG_OUT               : out std_logic_vector(15 downto 0)
);
end entity trb_net16_rx_packets;


architecture behavioral of trb_net16_rx_packets is

-- components
component trb_net_fifo_8bit_16bit_bram_dualport is
port(
  READ_CLOCK_IN    : in  std_logic;
  WRITE_CLOCK_IN   : in  std_logic;
  READ_ENABLE_IN   : in  std_logic;
  WRITE_ENABLE_IN  : in  std_logic;
  FIFO_GSR_IN      : in  std_logic;
  WRITE_DATA_IN    : in  std_logic_vector(7 downto 0);
  READ_DATA_OUT    : out std_logic_vector(15 downto 0);
  FULL_OUT         : out std_logic;
  EMPTY_OUT        : out std_logic;
  WCNT_OUT         : out std_logic_vector(9 downto 0);
  RCNT_OUT         : out std_logic_vector(8 downto 0)
);
end component trb_net_fifo_8bit_16bit_bram_dualport;

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
signal med_data             : std_logic_vector(15 downto 0);

signal buf_rx_data          : std_logic_vector(7 downto 0);
signal buf_rx_k             : std_logic;

signal fifo_wr_en           : std_logic;
signal fifo_rd_en_x         : std_logic;
signal fifo_wr_data         : std_logic_vector(7 downto 0);
signal fifo_rd_data         : std_logic_vector(15 downto 0);
signal fifo_reset           : std_logic;
signal fifo_rcnt_stdlv      : std_logic_vector(8 downto 0);
signal fifo_rcnt            : unsigned(8 downto 0);
signal fifo_rst_x           : std_logic;
signal fifo_rst             : std_logic;

signal rx_counter           : unsigned(2 downto 0);

signal is_idle_word         : std_logic;
signal rx_starting          : std_logic;
signal send_reset_words     : std_logic;
signal make_trbnet_reset    : std_logic;
signal reset_word_cnt       : unsigned(4 downto 0);

signal timeout_ctr          : unsigned(9 downto 0);
signal rst_toc_x            : std_logic;
signal rst_toc              : std_logic;
signal ce_toc_x             : std_logic;
signal ce_toc               : std_logic;
signal toc_done_x           : std_logic;
signal toc_done             : std_logic;

signal debug                : std_logic_vector(15 downto 0);

begin

----------------------------------------------------------------------
-- FIFO write process
----------------------------------------------------------------------
THE_WRITE_RX_FIFO_PROC: process( CLK_IN )
begin
  if( rising_edge(CLK_IN) ) then
    buf_rx_data <= RX_DATA_IN;
    buf_rx_k    <= RX_K_IN;
    if( (RESET_IN = '1') or (RX_ALLOW_IN = '0') ) then
      fifo_wr_en    <= '0';
      is_idle_word  <= '1';
      rx_starting   <= '1';
    else
      fifo_wr_data <= buf_rx_data;
      if( (buf_rx_k = '0') and (is_idle_word = '0') and (rx_starting = '0') ) then
        fifo_wr_en <= '1';
      else
        fifo_wr_en <= '0';
      end if;
      if   ( buf_rx_k = '1' ) then
        is_idle_word <= '1';
        rx_starting <= '0';
      elsif( (buf_rx_k = '0') and (is_idle_word = '1') ) then
        is_idle_word <= '0';
      end if;
    end if;
  end if;
end process THE_WRITE_RX_FIFO_PROC;

----------------------------------------------------------------------
-- TRBnet reset handling
----------------------------------------------------------------------
THE_CNT_RESET_PROC: process( CLK_IN )
begin
  if( rising_edge(CLK_IN) ) then
    if( RESET_IN = '1' ) then
      send_reset_words  <= '0';
      make_trbnet_reset <= '0';
      reset_word_cnt    <= (others => '0');
    else
      send_reset_words  <= '0';
      make_trbnet_reset <= '0';
      if( (buf_rx_data = x"FE") and (buf_rx_k = '1') ) then
        if( reset_word_cnt(4) = '0' ) then
          reset_word_cnt <= reset_word_cnt + 1;
        else
          send_reset_words <= '1';
        end if;
      else
        reset_word_cnt    <= (others => '0');
        make_trbnet_reset <= reset_word_cnt(4);
      end if;
    end if;
  end if;
end process;

----------------------------------------------------------------------
-- the RX FIFO itself
----------------------------------------------------------------------
THE_RX_FIFO: trb_net_fifo_8bit_16bit_bram_dualport
port map(
  READ_CLOCK_IN    => SYSCLK_IN,
  WRITE_CLOCK_IN   => CLK_IN,
  READ_ENABLE_IN   => fifo_rd_en_x,
  WRITE_ENABLE_IN  => fifo_wr_en,
  FIFO_GSR_IN      => fifo_reset,
  WRITE_DATA_IN    => fifo_wr_data,
  READ_DATA_OUT    => fifo_rd_data,
  FULL_OUT         => open,
  EMPTY_OUT        => open,
  WCNT_OUT         => open, -- not needed
  RCNT_OUT         => fifo_rcnt_stdlv
);

fifo_reset <= RESET_IN or QUAD_RST_IN or not RX_ALLOW_IN or fifo_rst;

fifo_rcnt  <= unsigned(fifo_rcnt_stdlv);

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
      bsm           <= (others => '0');
    else
      CURRENT_STATE <= NEXT_STATE;
      med_dataready <= med_dataready_x;
      ce_toc        <= ce_toc_x;
      rst_toc       <= rst_toc_x;
      fifo_rst      <= fifo_rst_x;
      bsm           <= bsm_x;
    end if;
  end if;
end process STATE_MEM;

-- state transitions
STATE_TRANSFORM: process( CURRENT_STATE, fifo_rcnt, MED_READ_IN, med_dataready, toc_done )
begin
  NEXT_STATE      <= IDLE; -- avoid latches
  fifo_rd_en_x    <= '0';
  med_dataready_x <= '0';
  update_x        <= '0';
  ce_toc_x        <= '0';
  rst_toc_x       <= '0';
  fifo_rst_x      <= '0';
  case CURRENT_STATE is
    when IDLE   =>  if( fifo_rcnt > 0 ) then
              -- we have at least one data word in FIFO, so we prefetch it
              NEXT_STATE   <= RD1;
              fifo_rd_en_x <= '1';
              ce_toc_x     <= '1';
            else
              NEXT_STATE   <= IDLE;
            end if;
    when RD1    =>  if   ( fifo_rcnt > 1 ) then -- was 0
              -- second data word is available in FIFO, so we prefetch it and
              -- forward the first word to the output register
              NEXT_STATE   <= RD2;
              fifo_rd_en_x <= '1';
              update_x     <= '1';
              ce_toc_x     <= '1';
            elsif( toc_done = '1' ) then
              NEXT_STATE   <= TOC;
              rst_toc_x    <= '1';
              fifo_rst_x   <= '1';
            else
              NEXT_STATE   <= RD1;
              ce_toc_x     <= '1';
            end if;
    when RD2    =>  if   ( fifo_rcnt > 2 ) then
              -- at least all three missing words in FIFO... so we go ahead and notify full packet availability
              NEXT_STATE      <= RDI;
              med_dataready_x <= '1';
              rst_toc_x       <= '1';
            elsif( toc_done = '1' ) then
              NEXT_STATE   <= TOC;
              rst_toc_x    <= '1';
              fifo_rst_x   <= '1';
            else
              NEXT_STATE      <= RD2;
              ce_toc_x     <= '1';
            end if;
    when RDI  =>  med_dataready_x <= '1';
            if( MED_READ_IN = '1' ) then
              -- first word of packet has been transfered, update output register and prefetch next data word
              NEXT_STATE      <= RD3;
              fifo_rd_en_x    <= '1';
              update_x        <= '1';
            else
              NEXT_STATE <= RDI;
            end if;
    when RD3    =>  med_dataready_x <= '1';
            if( MED_READ_IN = '1' ) then
              -- second word of packet has been transfered, update output register and prefetch next data word
              NEXT_STATE      <= RD4;
              fifo_rd_en_x    <= '1';
              update_x        <= '1';
            else
              NEXT_STATE      <= RD3;
            end if;
    when RD4    =>  med_dataready_x <= '1';
              -- third word of packet has been transfered, update output register and prefetch next data word
            if( MED_READ_IN = '1' ) then
              NEXT_STATE      <= RD5;
              fifo_rd_en_x    <= '1';
              update_x        <= '1';
            else
              NEXT_STATE      <= RD4;
            end if;
    when RD5    =>  med_dataready_x <= '1';
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
            else
              NEXT_STATE      <= RD5;
            end if;
    when RDO    =>  if   ( (MED_READ_IN = '1') and (fifo_rcnt = 0) ) then
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
    when RDW    =>  if   ( (MED_READ_IN = '1') and (fifo_rcnt > 3) ) then
              -- last word of packet has been transfered, complete packet in FIFO, so we can go ahead.
              NEXT_STATE      <= RDI;
              fifo_rd_en_x    <= '1';
              update_x        <= '1';
              med_dataready_x <= '1';
            elsif( (MED_READ_IN = '1') and (fifo_rcnt < 4 ) ) then
              -- last word of packet has been transfered, but new packet not complete yet.
              NEXT_STATE      <= RD2;
              fifo_rd_en_x    <= '1';
              update_x        <= '1';
            else
              NEXT_STATE      <= RDW;
              med_dataready_x <= '1';
            end if;
    when TOC    =>  NEXT_STATE <= CLEAN;
            fifo_rst_x   <= '1';
    when CLEAN  =>  NEXT_STATE   <= IDLE;

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
    when TOC    => bsm_x <= x"9";
    when CLEAN  => bsm_x <= x"a";
    when others => bsm_x <= x"f";
  end case;
end process THE_DECODE_PROC;

THE_SYNC_PROC: process( SYSCLK_IN )
begin
  if( rising_edge(SYSCLK_IN) ) then
    if( update_x = '1' ) then
      med_data <= fifo_rd_data;
    end if;
  end if;
end process THE_SYNC_PROC;

----------------------------------------------------------------------
-- RX packet counter
----------------------------------------------------------------------
THE_RX_PACKETS_PROC: process( SYSCLK_IN )
begin
  if( rising_edge(SYSCLK_IN) ) then
    if( (RESET_IN = '1') or (RX_ALLOW_IN = '0') ) then
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

toc_done_x <= '1' when ( timeout_ctr(9 downto 2) = b"11_1111_11" ) else '0';

----------------------------------------------------------------------
-- Debug signals
----------------------------------------------------------------------
debug(15 downto 13)   <= (others => '0');
debug(12 downto 4)    <= fifo_rcnt_stdlv;
debug(3)              <= toc_done;
debug(2)              <= ce_toc;
debug(1)              <= rst_toc;
debug(0)              <= fifo_rst;

--debug(15 downto 8)   <= fifo_rcnt_stdlv(7 downto 0);
--debug(7 downto 2)    <= (others => '0');
--debug(1)             <= update_x;
--debug(0)             <= fifo_rd_en_x;

----------------------------------------------------------------------
-- Output signals
----------------------------------------------------------------------
SEND_RESET_WORDS_OUT  <= send_reset_words;
MAKE_TRBNET_RESET_OUT <= make_trbnet_reset;
PACKET_TIMEOUT_OUT    <= fifo_rst;

MED_DATAREADY_OUT     <= med_dataready;
MED_DATA_OUT          <= med_data;
MED_PACKET_NUM_OUT    <= std_logic_vector(rx_counter);

BSM_OUT               <= bsm;
DBG_OUT               <= debug;

end behavioral;