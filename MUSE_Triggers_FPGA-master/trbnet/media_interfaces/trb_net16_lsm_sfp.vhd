-- LinkStateMachine for SFPs (2GBit)

-- Still missing: link reset features, fifo full error handling, signals on stat_op
-- Take care: all input signals must be synchronous to SYSCLK,
--            all output signals are synchronous to SYSCLK.
-- Clock Domain Crossing is in your responsibility!

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity trb_net16_lsm_sfp is
  generic(
    CHECK_FOR_CV : integer := c_YES;
    HIGHSPEED_STARTUP : integer := c_NO
    );
  port(
    SYSCLK      : in  std_logic; -- fabric clock (100MHz)
    RESET        : in  std_logic; -- synchronous reset
    CLEAR        : in  std_logic; -- asynchronous reset, connect to '0' if not needed / available
    -- status signals
    SFP_MISSING_IN  : in  std_logic; -- SFP Missing ('1' = no SFP mounted, '0' = SFP in place)
    SFP_LOS_IN    : in  std_logic; -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
    SD_LINK_OK_IN    : in  std_logic; -- SerDes Link OK ('0' = not linked, '1' link established)
    SD_LOS_IN      : in  std_logic; -- SerDes Loss Of Signal ('0' = OK, '1' = signal lost)
    SD_TXCLK_BAD_IN  : in  std_logic; -- SerDes Tx Clock locked ('0' = locked, '1' = not locked)
    SD_RXCLK_BAD_IN  : in  std_logic; -- SerDes Rx Clock locked ('0' = locked, '1' = not locked)
    SD_RETRY_IN    : in  std_logic; -- '0' = handle byte swapping in logic, '1' = simply restart link and hope
    SD_ALIGNMENT_IN  : in  std_logic_vector(1 downto 0); -- SerDes Byte alignment ("10" = swapped, "01" = correct)
    SD_CV_IN      : in  std_logic_vector(1 downto 0); -- SerDes Code Violation ("00" = OK, everything else = BAD)
    -- control signals
    FULL_RESET_OUT  : out std_logic; -- full reset AKA quad_reset
    LANE_RESET_OUT  : out std_logic; -- partial reset AKA lane_reset
    TX_ALLOW_OUT    : out std_logic; -- allow normal transmit operation
    RX_ALLOW_OUT    : out std_logic; -- allow normal receive operation
    SWAP_BYTES_OUT  : out std_logic; -- bytes need swapping ('0' = correct order, '1' = swapped order)
    -- debug signals
    STAT_OP      : out std_logic_vector(15 downto 0);
    CTRL_OP      : in  std_logic_vector(15 downto 0);
    STAT_DEBUG    : out std_logic_vector(31 downto 0)
   );
end entity;

architecture lsm_sfp of trb_net16_lsm_sfp is

-- state machine signals
type STATES is ( QRST, SLEEP, WPAR, WLOS, ALIGN, WRXA, WTXA, LINK, CVFND, CVBAD );
signal CURRENT_STATE, NEXT_STATE: STATES;

signal state_bits      : std_logic_vector(3 downto 0);

signal next_med_error    : std_logic_vector(2 downto 0);
signal med_error      : std_logic_vector(2 downto 0);
signal next_ce_tctr      : std_logic;
signal ce_tctr        : std_logic;
signal next_rst_tctr    : std_logic;
signal rst_tctr        : std_logic;
signal next_quad_rst    : std_logic;
signal quad_rst        : std_logic;
signal next_lane_rst    : std_logic;
signal lane_rst        : std_logic;
signal next_rx_allow    : std_logic;
signal rx_allow        : std_logic;
signal next_tx_allow    : std_logic;
signal tx_allow        : std_logic;
signal next_align_me    : std_logic;
signal align_me        : std_logic;
signal next_resync      : std_logic;
signal resync        : std_logic;
signal next_reset_me    : std_logic;
signal reset_me        : std_logic;
signal next_ce_cctr      : std_logic;
signal ce_cctr        : std_logic;
signal next_rst_cctr    : std_logic;
signal rst_cctr        : std_logic;

signal buf_swap_bytes    : std_logic;

signal timing_ctr      : std_logic_vector(28 downto 0);
signal cv_ctr        : std_logic_vector(3 downto 0);

signal link_status_led    : std_logic;

begin

--------------------------------------------------------------------------
-- Main control state machine, startup control for SFP
--------------------------------------------------------------------------

-- "Swap Bytes" indicator
THE_SWAP_BYTES_PROC: process( sysclk, clear )
begin
  if( clear = '1' ) then
    buf_swap_bytes <= '0';
  elsif( rising_edge(sysclk) ) then
    if   ( (align_me = '1') and (sd_alignment_in = "10") ) then
      buf_swap_bytes <= '1';
    elsif( (align_me = '1') and (sd_alignment_in = "01") ) then
      buf_swap_bytes <= '0';
    end if;
  end if;
end process THE_SWAP_BYTES_PROC;

-- Timing counter for reset sequencing
THE_TIMING_COUNTER_PROC: process( sysclk, clear )
begin
  if( clear = '1' ) then
    timing_ctr <= (others => '0');
  elsif( rising_edge(sysclk) ) then
    if   ( rst_tctr = '1' ) then
      timing_ctr <= (others => '0');
    elsif( ce_tctr = '1' ) then
      if HIGHSPEED_STARTUP = c_NO then
        timing_ctr <= timing_ctr + 1;
      else
        timing_ctr <= timing_ctr + 4;
      end if;
    end if;
  end if;
end process THE_TIMING_COUNTER_PROC;

-- CodeViolation counter for Michael Traxler
THE_CV_COUNTER_PROC: process( sysclk, clear )
begin
  if( clear = '1' ) then
    cv_ctr <= (others => '0');
  elsif( rising_edge(sysclk) ) then
    if   ( rst_cctr = '1' or timing_ctr(9 downto 0) = 0) then
      cv_ctr <= (others => '0');
    elsif( ce_cctr = '1' ) then
      cv_ctr <= cv_ctr + 1;
    end if;
  end if;
end process THE_CV_COUNTER_PROC;

-- State machine
-- state registers
STATE_MEM: process( sysclk, clear )
begin
  if( clear = '1' ) then
    CURRENT_STATE  <= QRST;
    ce_tctr        <= '0';
    rst_tctr       <= '0';
    ce_cctr        <= '0';
    rst_cctr       <= '0';
    quad_rst       <= '1';
    lane_rst       <= '1';
    rx_allow       <= '0';
    tx_allow       <= '0';
    align_me       <= '0';
    reset_me       <= '1';
    resync         <= '1';
    med_error      <= ERROR_NC;
  elsif( rising_edge(sysclk) ) then
    CURRENT_STATE  <= NEXT_STATE;
    ce_tctr        <= next_ce_tctr;
    rst_tctr       <= next_rst_tctr;
    ce_cctr        <= next_ce_cctr;
    rst_cctr       <= next_rst_cctr;
    quad_rst       <= next_quad_rst;
    lane_rst       <= next_lane_rst;
    rx_allow       <= next_rx_allow;
    tx_allow       <= next_tx_allow;
    align_me       <= next_align_me;
    reset_me       <= next_reset_me;
    resync         <= next_resync;
    med_error      <= next_med_error;
  end if;
end process STATE_MEM;

-- state transitions
PROC_STATE_TRANSFORM: process( CURRENT_STATE, sfp_missing_in, sfp_los_in,
                               timing_ctr, sd_alignment_in, cv_ctr,
                               sd_txclk_bad_in, sd_rxclk_bad_in, sd_retry_in,
                               rst_tctr, reset, sd_cv_in )
begin
  NEXT_STATE     <= QRST; -- avoid latches
  next_ce_tctr   <= '0';
  next_rst_tctr  <= '0';
  next_ce_cctr   <= '0';
  next_rst_cctr  <= '0';
  next_quad_rst  <= '0';
  next_lane_rst  <= '0';
  next_rx_allow  <= '0';
  next_tx_allow  <= '0';
  next_align_me  <= '0';
  next_reset_me  <= '1';
  next_resync    <= '1';
  next_med_error <= ERROR_NC;
  case CURRENT_STATE is
    when QRST  =>
      if( (timing_ctr(4) = '1') and (rst_tctr = '0') ) then
        NEXT_STATE    <= SLEEP; -- release QUAD_RST, wait for lock of RxClock and TxClock
        next_lane_rst <= '1';
      else
        NEXT_STATE    <= QRST; -- count delay
        next_ce_tctr  <= '1';
        next_quad_rst <= '1';
        next_lane_rst <= '1';
      end if;
    when SLEEP  =>
      if( (sfp_missing_in = '0') and (sfp_los_in = '0') ) then
        NEXT_STATE    <= WPAR; -- do a correctly timed QUAD reset (about 150ns)
        next_rst_tctr <= '1';
        next_lane_rst <= '1';
        next_rst_cctr <= '1'; -- if we start the link, we clear the CV counter
      else
        NEXT_STATE    <= SLEEP; -- wait for SFP present signal
        next_ce_tctr  <= '1';
        next_rst_tctr <= '1';
        next_lane_rst <= '1';
      end if;
    when WPAR  =>
      if( (sd_rxclk_bad_in = '0') and (sd_txclk_bad_in = '0') ) then  --
        NEXT_STATE    <= WLOS; -- PLLs locked, signal present
        next_rst_tctr <= '1';
      else
        NEXT_STATE    <= WPAR; -- wait for RLOL and PLOL and incoming signal from SFP
        next_lane_rst <= '1';
        next_ce_tctr  <= '1';
      end if;
    when WLOS  =>
      if   ( (timing_ctr(27) = '0') and (timing_ctr(26) = '0') and (rst_tctr = '0') ) then
        NEXT_STATE    <= WLOS;
        next_resync   <= '0';
        next_ce_tctr  <= '1';
      elsif( (timing_ctr(27) = '1') and (rst_tctr = '0') ) then
        NEXT_STATE    <= ALIGN; -- debounce before aligning
        next_align_me <= '1';
        next_reset_me <= '0';
        next_ce_tctr  <= '1';
      else
        NEXT_STATE    <= WLOS; -- no alignment found yet
        next_ce_tctr  <= '1';
      end if;
    when ALIGN  =>
      if   ( sd_cv_in /= "00" ) then
        NEXT_STATE     <= ALIGN;
        next_ce_cctr   <= '1'; -- increment CV counter
        next_ce_tctr   <= '1';
        next_align_me  <= '1';
        next_reset_me  <= '0';
        next_med_error <= ERROR_WAIT;
      elsif( (sd_retry_in = '0') and ((sd_alignment_in = "10") or (sd_alignment_in = "01")) ) then
        NEXT_STATE     <= WRXA; -- one komma character has been received
        next_reset_me  <= '0';
        next_med_error <= ERROR_WAIT;
      elsif( (sd_retry_in = '1') and (sd_alignment_in = "10")) then
        NEXT_STATE    <= SLEEP; -- MAREK STYLE - CORRECT?
        next_rst_tctr <= '1';
        next_lane_rst <= '1';
      else
        NEXT_STATE     <= ALIGN; -- wait for komma character
        next_ce_tctr   <= '1';
        next_align_me  <= '1';
        next_reset_me  <= '0';
        next_med_error <= ERROR_WAIT;
      end if;
    when WRXA  =>
      if   ( sd_cv_in /= "00" ) then
        NEXT_STATE     <= WRXA;
        next_ce_cctr   <= '1'; -- increment CV counter
        next_ce_tctr   <= '1';
        next_reset_me  <= '0';
        next_med_error <= ERROR_WAIT;
        elsif( (timing_ctr(28) = '1') and (rst_tctr = '0') ) then
        NEXT_STATE     <= WTXA; -- wait cycle done, allow reception of data
        next_rst_tctr  <= '1';
        next_rx_allow  <= '1';
        next_reset_me  <= '0';
        next_med_error <= ERROR_WAIT;
      else
        NEXT_STATE     <= WRXA; -- wait one complete cycle (2^27 x 10ns = 1.3s)
        next_ce_tctr   <= '1';
        next_reset_me  <= '0';
        next_med_error <= ERROR_WAIT;
      end if;
    when WTXA  =>
      if   ( sd_cv_in /= "00" ) then
        NEXT_STATE     <= WTXA;
        next_ce_cctr   <= '1'; -- increment CV counter
        next_ce_tctr   <= '1';
        next_rx_allow  <= '1';
        next_reset_me  <= '0';
        next_med_error <= ERROR_WAIT;
      elsif( (timing_ctr(28) = '1') and (rst_tctr = '0') ) then -- we could use [29:0] as counter and use [29] here
        NEXT_STATE     <= LINK; -- wait cycle done, allow transmission of data
        next_rst_tctr  <= '1';
        next_rx_allow  <= '1';
        next_tx_allow  <= '1';
        next_ce_tctr   <= '1';
        next_reset_me  <= '0';
        next_med_error <= ERROR_OK;
      else
        NEXT_STATE     <= WTXA; -- wait one complete cycle (2^27 x 10ns = 1.3s)
        next_ce_tctr   <= '1';
        next_rx_allow  <= '1';
        next_reset_me  <= '0';
        next_med_error <= ERROR_WAIT;
      end if;
    when LINK  =>
--       if   ( (sfp_missing_in = '1') or (sfp_los_in = '1') ) then
--         NEXT_STATE     <= SLEEP;
--         next_lane_rst  <= '1';
--         next_rst_tctr  <= '1';
--       els
      if( sd_cv_in /= "00" ) and CHECK_FOR_CV = c_YES then
        NEXT_STATE     <= CVFND;
        next_ce_cctr   <= '1'; -- increment CV counter
        next_rx_allow  <= '1';
        next_tx_allow  <= '1';
        next_ce_tctr   <= '1';
        next_reset_me  <= '0';
        next_med_error <= ERROR_OK;
      else
        NEXT_STATE     <= LINK;
        next_rx_allow  <= '1';
        next_tx_allow  <= '1';
        next_ce_tctr   <= '1';
        next_reset_me  <= '0';
        next_med_error <= ERROR_OK;
      end if;
    when CVFND  =>
      if( cv_ctr(1) = '0' ) then
        NEXT_STATE     <= LINK; -- try again (?)
        next_rx_allow  <= '1';
        next_tx_allow  <= '1';
        next_ce_tctr   <= '1';
        next_reset_me  <= '0';
        next_med_error <= ERROR_OK;
      else
        NEXT_STATE     <= CVBAD;
        next_ce_tctr   <= '1';
        next_med_error <= ERROR_FATAL;
      end if;
    when CVBAD  =>
--       if   ( (sfp_missing_in = '1') or (sfp_los_in = '1') ) then
--         NEXT_STATE     <= SLEEP;
--         next_lane_rst  <= '1';
--         next_rst_tctr  <= '1';
--       else
        NEXT_STATE     <= CVBAD;
        next_ce_tctr   <= '1';
        next_med_error <= ERROR_FATAL;
--       end if;
    when others  =>  NEXT_STATE <= QRST;
  end case;
  if  ( (sfp_missing_in = '1') or (sfp_los_in = '1') or RESET = '1' or CTRL_OP(13) = '1') and CURRENT_STATE /= QRST then
    NEXT_STATE    <= SLEEP; -- wait for SFP present signal
    next_ce_tctr  <= '1';
    next_rst_tctr <= '1';
    next_lane_rst <= '1';
  end if;
end process;

THE_DECODE_PROC: process( CURRENT_STATE, timing_ctr )
begin
  case CURRENT_STATE is
    when QRST =>  state_bits    <= "0000";
            link_status_led <= '0';
    when SLEEP  =>  state_bits    <= "0001";
            link_status_led  <= '0';
    when WPAR  =>  state_bits    <= "0010";
            link_status_led <= timing_ctr(23) and timing_ctr(24); -- nice frequency for human eye
    when WLOS  =>  state_bits    <= "0011";
            link_status_led  <= timing_ctr(22);
    when ALIGN  =>  state_bits    <= "0100";
            link_status_led  <= timing_ctr(23);
    when WRXA  =>  state_bits    <= "0101";
            link_status_led  <= timing_ctr(24);
    when WTXA  =>  state_bits    <= "0110";
            link_status_led  <= timing_ctr(25);
    when CVFND  =>  state_bits    <= "0111";
            link_status_led  <= timing_ctr(25) and timing_ctr(23);
    when LINK  =>  state_bits    <= "1000";
            link_status_led  <= '1';
    when CVBAD  =>  state_bits    <= "1001";
            link_status_led  <= timing_ctr(25) and timing_ctr(24) and timing_ctr(23);
    when others  =>  state_bits    <= "1111";
            link_status_led  <= '0';
  end case;
end process THE_DECODE_PROC;

--------------------------------------------------------------------------
-- Output signals
--------------------------------------------------------------------------
swap_bytes_out  <= buf_swap_bytes;
full_reset_out  <= quad_rst;
lane_reset_out  <= lane_rst;
tx_allow_out    <= tx_allow;
rx_allow_out    <= rx_allow;

--------------------------------------------------------------------------
-- Status output signaled (normed)
--------------------------------------------------------------------------
stat_op(2 downto 0)  <= med_error;
stat_op(3)           <= '0';
stat_op(7 downto 4)  <= state_bits;
stat_op(8)           <= '0';
stat_op(9)           <= link_status_led;
stat_op(10)          <= '0'; -- Rx LED, made outside LSM
stat_op(11)          <= '0'; -- Tx LED, made outside LSM
stat_op(12)          <= '1' when sd_cv_in /= "00" and CURRENT_STATE = LINK else '0'; -- CV found when in link state
stat_op(13)          <= '0';
stat_op(14)          <= reset_me; -- reset out
stat_op(15)          <= '0'; -- protocol error

--------------------------------------------------------------------------
-- Debug output
--------------------------------------------------------------------------
stat_debug(3 downto 0)   <= state_bits;
stat_debug(4)            <= align_me;
stat_debug(5)            <= buf_swap_bytes;
stat_debug(6)            <= resync;
stat_debug(7)            <= sfp_missing_in;
stat_debug(8)            <= sfp_los_in;
stat_debug(31 downto 9)  <= (others => '0');


--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Code prions below
--------------------------------------------------------------------------
--------------------------------------------------------------------------

--Generate LED signals
----------------------
--process(clock)
--  begin
--    if rising_edge(clock) then
--      led_counter <= led_counter + 1;
--
--      if buf_med_dataready_out = '1' then
--        rx_led <= '1';
--      elsif led_counter = 0 then
--        rx_led <= '0';
--      end if;
--
--      if tx_k(0) = '0' then
--        tx_led <= '1';
--      elsif led_counter = 0 then
--        tx_led <= '0';
--      end if;
--
--    end if;
--  end process;

end architecture;