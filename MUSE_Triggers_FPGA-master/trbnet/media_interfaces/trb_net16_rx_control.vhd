library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity trb_net16_rx_control is
port(
  RESET_IN                       : in  std_logic;
  QUAD_RST_IN                    : in  std_logic;
  -- raw data from SerDes receive path
  CLK_IN                         : in  std_logic;
  RX_DATA_IN                     : in  std_logic_vector(7 downto 0);
  RX_K_IN                        : in  std_logic;
  RX_CV_IN                       : in  std_logic;
  RX_DISP_ERR_IN                 : in  std_logic;
  RX_ALLOW_IN                    : in  std_logic;
  -- media interface
  SYSCLK_IN                      : in  std_logic; -- 100MHz master clock
  MED_DATA_OUT                   : out std_logic_vector(15 downto 0);
  MED_DATAREADY_OUT              : out std_logic;
  MED_READ_IN                    : in  std_logic;
  MED_PACKET_NUM_OUT             : out std_logic_vector(2 downto 0);
  -- request retransmission in case of error while receiving
  REQUEST_RETRANSMIT_OUT         : out std_logic; -- one pulse
  REQUEST_POSITION_OUT           : out std_logic_vector( 7 downto 0);
  -- command decoding
  START_RETRANSMIT_OUT           : out std_logic;
  START_POSITION_OUT             : out std_logic_vector( 7 downto 0);
  -- reset handling
  SEND_RESET_WORDS_OUT           : out std_logic;
  MAKE_TRBNET_RESET_OUT          : out std_logic;
  -- Status signals
  PACKET_TIMEOUT_OUT             : out std_logic;
	COMMA_LOCKED_OUT               : out std_logic;
  -- Debugging
  ENABLE_CORRECTION_IN           : in  std_logic;
  DEBUG_OUT                      : out std_logic_vector(31 downto 0);
  STAT_REG_OUT                   : out std_logic_vector(95 downto 0)
  );
end entity;



architecture arch of trb_net16_rx_control is

-- components
component trb_net16_rx_comma_handler is
port(
  SYSCLK_IN                      : in  std_logic;
  RESET_IN                       : in  std_logic;
  QUAD_RST_IN                    : in  std_logic;
  -- raw data from SerDes receive path
  CLK_IN                         : in  std_logic;
  RX_DATA_IN                     : in  std_logic_vector(7 downto 0);
  RX_K_IN                        : in  std_logic;
  RX_CV_IN                       : in  std_logic;
  RX_DISP_ERR_IN                 : in  std_logic;
  RX_ALLOW_IN                    : in  std_logic;
	-- FIFO interface
	FIFO_DATA_OUT                  : out std_logic_vector(15 downto 0);
	FIFO_WR_OUT                    : out std_logic;
	FIFO_INHIBIT_OUT               : out std_logic;
	-- Special comma actions
	LD_RX_POSITION_OUT             : out std_logic;
	RX_POSITION_OUT                : out std_logic_vector(7 downto 0);
	LD_START_POSITION_OUT          : out std_logic;
	START_POSITION_OUT             : out std_logic_vector(7 downto 0);
  START_GONE_WRONG_IN            : in  std_logic;
  START_TIMEOUT_OUT              : out std_logic;
  RX_RESET_IN                    : in  std_logic;
	-- Check
	COMMA_LOCKED_OUT               : out std_logic;
  -- reset handling
  SEND_RESET_WORDS_OUT           : out std_logic;
  MAKE_TRBNET_RESET_OUT          : out std_logic;
  ENABLE_CORRECTION_IN           : in  std_logic;
  -- Debugging
  STAT_REG_OUT                   : out std_logic_vector(39 downto 0);
  DEBUG_OUT                      : out std_logic_vector(15 downto 0)
);
end component trb_net16_rx_comma_handler;

component trb_net16_rx_full_packets is
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
	PKT_IN_TRANSIT_OUT    : out std_logic;
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
end component trb_net16_rx_full_packets;

component trb_net16_rx_checker is
port(
  -- Resets & clocks
  SYSCLK_IN             : in  std_logic;
  RESET_IN              : in  std_logic;
	-- error detection and status signals
	PKT_TOC_IN            : in  std_logic; -- full packet RX timeout
	RX_IC_IN              : in  std_logic; -- illegal comma or CodeViolation on RX
	STX_FND_IN            : in  std_logic; -- StartOfTransmission found on RX
  STX_TOC_IN            : in  std_logic; -- timeout waiting for StartOfTransmission
	PKT_IN_TRANS_IN       : in  std_logic; -- paket in transmission to media interface
	-- control signals
	FIFO_RST_OUT          : out std_logic; -- clear RX FIFO
	RESUME_OUT            : out std_logic; -- full packet RX resume signal
	REQ_RETRANS_OUT       : out std_logic; -- request retransmission
  -- Debug signals
  STAT_REG_OUT          : out std_logic_vector(15 downto 0);
  DBG_OUT               : out std_logic_vector(15 downto 0)
);
end component trb_net16_rx_checker;

component trb_net_fifo_16bit_16bit_bram_dualport is
port(
  READ_CLOCK_IN    : in  std_logic;
  WRITE_CLOCK_IN   : in  std_logic;
  READ_ENABLE_IN   : in  std_logic;
  WRITE_ENABLE_IN  : in  std_logic;
  FIFO_GSR_IN      : in  std_logic;
  WRITE_DATA_IN    : in  std_logic_vector(15 downto 0);
  READ_DATA_OUT    : out std_logic_vector(15 downto 0);
  FULL_OUT         : out std_logic;
  EMPTY_OUT        : out std_logic;
  WCNT_OUT         : out std_logic_vector(9 downto 0);
  RCNT_OUT         : out std_logic_vector(9 downto 0)
);
end component trb_net_fifo_16bit_16bit_bram_dualport;

component pulse_sync is
port(
	CLK_A_IN        : in    std_logic;
	RESET_A_IN      : in    std_logic;
	PULSE_A_IN      : in    std_logic;
	CLK_B_IN        : in    std_logic;
	RESET_B_IN      : in    std_logic;
	PULSE_B_OUT     : out   std_logic
);
end component pulse_sync;

component state_sync is
port(
	STATE_A_IN      : in    std_logic;
	RESET_B_IN      : in    std_logic;
	CLK_B_IN        : in    std_logic;
	STATE_B_OUT     : out   std_logic
);
end component state_sync;

-- normal signals
signal update               : std_logic;
signal med_dataready        : std_logic;
signal med_data             : std_logic_vector(15 downto 0);
signal med_packet_num       : std_logic_vector(2 downto 0);
signal packet_timeout       : std_logic;
signal debug_rfp            : std_logic_vector(15 downto 0);
signal debug_rxc            : std_logic_vector(15 downto 0);
signal debug_rch            : std_logic_vector(15 downto 0);

signal fifo_wr_en           : std_logic;
signal fifo_rd_en           : std_logic;
signal fifo_wr_data         : std_logic_vector(15 downto 0);
signal fifo_rd_data         : std_logic_vector(15 downto 0);
signal fifo_reset           : std_logic;
signal fifo_rcnt            : std_logic_vector(9 downto 0);
signal fifo_rst             : std_logic;

signal send_reset_words     : std_logic;
signal make_trbnet_reset    : std_logic;

signal request_retransmit   : std_logic;
signal request_position     : std_logic_vector(7 downto 0);

signal start_retransmit_x   : std_logic;
signal start_retransmit     : std_logic;
signal start_position       : std_logic_vector(7 downto 0);

signal ld_rx_position_x     : std_logic;
signal ld_rx_position       : std_logic;
signal rx_position          : std_logic_vector(7 downto 0);

signal pkt_in_transit       : std_logic;
signal rx_resume            : std_logic;

signal rx_gone_wrong_x      : std_logic;
signal rx_gone_wrong        : std_logic;
signal rx_allow_qrx         : std_logic;
signal enable_correction_qrx: std_logic;

signal comma_locked         : std_logic;

signal debug                : std_logic_vector(31 downto 0);

signal statreg_rxfullpackets     : std_logic_vector(15 downto 0);
signal statreg_rxcommahandler    : std_logic_vector(39 downto 0);
signal statreg_rxchecker         : std_logic_vector(15 downto 0);

signal start_position_mismatch   : std_logic;
signal start_position_mismatch_x : std_logic;
signal req_position_buffer       : std_logic_vector(7 downto 0);

signal stx_toc_found_x           : std_logic;
signal stx_toc_found             : std_logic;
signal request_retransmit_q      : std_logic;

begin

----------------------------------------------------------------------
-- decoding of raw commas
----------------------------------------------------------------------
THE_COMMA_HANDLER: trb_net16_rx_comma_handler
port map(
  SYSCLK_IN                      => SYSCLK_IN,
  RESET_IN                       => RESET_IN,
	QUAD_RST_IN                    => QUAD_RST_IN,
  -- raw data from SerDes receive path
  CLK_IN                         => CLK_IN,
  RX_DATA_IN                     => RX_DATA_IN,
  RX_K_IN                        => RX_K_IN,
  RX_CV_IN                       => RX_CV_IN,
  RX_DISP_ERR_IN                 => RX_DISP_ERR_IN,
  RX_ALLOW_IN                    => rx_allow_qrx,
	-- FIFO interface
	FIFO_DATA_OUT                  => fifo_wr_data,
	FIFO_WR_OUT                    => fifo_wr_en,
	FIFO_INHIBIT_OUT               => rx_gone_wrong_x,
	-- Special comma actions
	LD_RX_POSITION_OUT             => ld_rx_position_x,
	RX_POSITION_OUT                => rx_position,
	LD_START_POSITION_OUT          => start_retransmit_x,
	START_POSITION_OUT             => start_position,
  START_GONE_WRONG_IN            => start_position_mismatch,
  START_TIMEOUT_OUT              => stx_toc_found_x,
  RX_RESET_IN                    => request_retransmit_q,  --fifo is resetted, needed to handle single TOC
	-- Check
	COMMA_LOCKED_OUT               => comma_locked,
  -- reset handling
  SEND_RESET_WORDS_OUT           => send_reset_words,
  MAKE_TRBNET_RESET_OUT          => make_trbnet_reset,
  ENABLE_CORRECTION_IN           => enable_correction_qrx,
  -- Debugging
  STAT_REG_OUT                   => statreg_rxcommahandler,
  DEBUG_OUT                      => debug_rch
);

-- clock domain transfer for restart gone wrong
THE_STX_PULSE_SYNC: pulse_sync
port map(
  CLK_A_IN        => SYSCLK_IN,
  RESET_A_IN      => RESET_IN,
  PULSE_A_IN      => start_position_mismatch_x,
  CLK_B_IN        => CLK_IN,
  RESET_B_IN      => RESET_IN,
  PULSE_B_OUT     => start_position_mismatch
);

-- clock domain transfer for internal RX data counter
THE_STX_TOC_PULSE_SYNC: pulse_sync
port map(
  CLK_A_IN        => CLK_IN,
  RESET_A_IN      => RESET_IN,
  PULSE_A_IN      => stx_toc_found_x,
  CLK_B_IN        => SYSCLK_IN,
  RESET_B_IN      => RESET_IN,
  PULSE_B_OUT     => stx_toc_found
);

THE_REQUEST_PULSE_SYNC: pulse_sync
port map(
  CLK_A_IN        => SYSCLK_IN,
  RESET_A_IN      => RESET_IN,
  PULSE_A_IN      => request_retransmit,
  CLK_B_IN        => CLK_IN,
  RESET_B_IN      => RESET_IN,
  PULSE_B_OUT     => request_retransmit_q
);

-- clock domain transfer for internal RX data counter
THE_LD_PULSE_SYNC: pulse_sync
port map(
	CLK_A_IN        => CLK_IN,
	RESET_A_IN      => RESET_IN,
	PULSE_A_IN      => ld_rx_position_x,
	CLK_B_IN        => SYSCLK_IN,
	RESET_B_IN      => RESET_IN,
	PULSE_B_OUT     => ld_rx_position
);

-- clock domain transfer for internal RX data counter
THE_RT_PULSE_SYNC: pulse_sync
port map(
	CLK_A_IN        => CLK_IN,
	RESET_A_IN      => RESET_IN,
	PULSE_A_IN      => start_retransmit_x,
	CLK_B_IN        => SYSCLK_IN,
	RESET_B_IN      => RESET_IN,
	PULSE_B_OUT     => start_retransmit
);

-- clock domain transfer for RX problems
THE_GONE_WRONG_SYNC: state_sync
port map(
	STATE_A_IN      => rx_gone_wrong_x,
	RESET_B_IN      => RESET_IN,
	CLK_B_IN        => SYSCLK_IN,
	STATE_B_OUT     => rx_gone_wrong
);

-- clock domain transfer for RX problems
THE_RX_ALLOW_SYNC: signal_sync
generic map(
  DEPTH => 2,
  WIDTH => 2
)
port map(
  RESET           => '0',
  D_IN(0)         => RX_ALLOW_IN,
  D_IN(1)         => ENABLE_CORRECTION_IN,
  CLK0            => CLK_IN,
  CLK1            => CLK_IN,
  D_OUT(0)        => rx_allow_qrx,
  D_OUT(1)        => enable_correction_qrx
);

-- THE_RX_ALLOW_SYNC: signal_sync
-- generic map(
--   DEPTH => 2,
--   WIDTH => 1
-- )
-- port map(
--   RESET           => '0',
--   D_IN(0)         => RX_ALLOW_IN,
--   CLK0            => SYSCLK_IN,
--   CLK1            => SYSCLK_IN,
--   D_OUT(0)     => rx_allow_qrx
-- );



----------------------------------------------------------------------
-- the RX FIFO itself
----------------------------------------------------------------------
THE_RX_FIFO: trb_net_fifo_16bit_16bit_bram_dualport
port map(
  READ_CLOCK_IN    => SYSCLK_IN,
  WRITE_CLOCK_IN   => CLK_IN,
  READ_ENABLE_IN   => fifo_rd_en,
  WRITE_ENABLE_IN  => fifo_wr_en,
  FIFO_GSR_IN      => fifo_reset,
  WRITE_DATA_IN    => fifo_wr_data,
  READ_DATA_OUT    => fifo_rd_data,
  FULL_OUT         => open,
  EMPTY_OUT        => open,
  WCNT_OUT         => open, -- not needed
  RCNT_OUT         => fifo_rcnt
);

fifo_reset <= RESET_IN or QUAD_RST_IN or not RX_ALLOW_IN or fifo_rst;

----------------------------------------------------------------------
-- RX packet state machine
----------------------------------------------------------------------
THE_RX_FULL_PACKETS: trb_net16_rx_full_packets
port map(
  -- Resets & clocks
  SYSCLK_IN             => SYSCLK_IN,
  RESET_IN              => RESET_IN,
  -- FIFO signals
  FIFO_READ_OUT         => fifo_rd_en,
  FIFO_RCNT_IN          => fifo_rcnt,
  FIFO_RESET_OUT        => open, -- not used anymore
  -- Media Interface
  MED_READ_IN           => MED_READ_IN,
  MED_DATAREADY_OUT     => med_dataready,
  MED_PACKET_NUM_OUT    => med_packet_num,
  UPDATE_OUT            => update,
	PKT_IN_TRANSIT_OUT    => pkt_in_transit,
  -- Status signals
	RX_ALLOW_IN           => RX_ALLOW_IN,
	RX_RESUME_IN          => rx_resume,
	RX_LD_DATA_CTR_IN     => '0', --ld_rx_position,
	RX_DATA_CTR_VAL_IN    => rx_position,
	RX_DATA_CTR_OUT       => request_position,
	PACKET_TIMEOUT_OUT    => packet_timeout,
  ENABLE_CORRECTION_IN  => ENABLE_CORRECTION_IN,
  -- Debug signals
  STAT_REG_OUT          => statreg_rxfullpackets,
  DBG_OUT               => debug_rfp
);

THE_SYNC_SYSCLK_PROC: process( SYSCLK_IN )
begin
  if( rising_edge(SYSCLK_IN) ) then
    if( update = '1' ) then
      med_data <= fifo_rd_data;
    end if;
  end if;
end process THE_SYNC_SYSCLK_PROC;

----------------------------------------------------------------------
-- RX checker state machine, does NOT include CRC checking!
----------------------------------------------------------------------
THE_RX_CHECKER: trb_net16_rx_checker
port map(
  -- Resets & clocks
  SYSCLK_IN             => SYSCLK_IN,
	RESET_IN              => RESET_IN,
	-- error detection and status signals
	PKT_TOC_IN            => packet_timeout,
	RX_IC_IN              => rx_gone_wrong,
	STX_FND_IN            => ld_rx_position,
	PKT_IN_TRANS_IN       => pkt_in_transit,
  STX_TOC_IN            => stx_toc_found,
	-- control signals
	FIFO_RST_OUT          => fifo_rst,
	RESUME_OUT            => rx_resume,
	REQ_RETRANS_OUT       => request_retransmit,
	-- Debug signals
  STAT_REG_OUT          => statreg_rxchecker,
	DBG_OUT               => debug_rxc
);


----------------------------------------------------------------------
-- Check start
----------------------------------------------------------------------
process(SYSCLK_IN)
  begin
    if rising_edge(SYSCLK_IN) then
      start_position_mismatch_x <= '0';
      if request_retransmit = '1' then
        req_position_buffer <= request_position;
      elsif ld_rx_position = '1' then
        if req_position_buffer /= rx_position then
          start_position_mismatch_x <= '1';
        end if;
      end if;
    end if;
  end process;

----------------------------------------------------------------------
-- Debug signals
----------------------------------------------------------------------
debug(31 downto 16)  <= debug_rfp;
-- debug(15 downto 0)   <= debug_rch; --(others => '0');

debug(0)             <= packet_timeout;
debug(1)             <= rx_gone_wrong;
debug(2)             <= pkt_in_transit;
debug(3)             <= comma_locked;
debug(4)             <= debug_rch(11);
debug(5)             <= debug_rch(12);
debug(15 downto 6)   <= debug_rch(15 downto 6);


STAT_REG_OUT(15 downto 0)   <= statreg_rxfullpackets;
STAT_REG_OUT(23 downto 16)  <= statreg_rxcommahandler(7 downto 0);
STAT_REG_OUT(31 downto 24)  <= (others => '0'); --rx_position;        --load RX buffer position
STAT_REG_OUT(39 downto 32)  <= statreg_rxchecker(7 downto 0);
STAT_REG_OUT(47 downto 40)  <= start_position;     --restart sending from this position
STAT_REG_OUT(48)            <= packet_timeout;
STAT_REG_OUT(49)            <= rx_gone_wrong;
STAT_REG_OUT(50)            <= pkt_in_transit;
STAT_REG_OUT(55 downto 51)  <= (others => '0');
STAT_REG_OUT(63 downto 56)  <= request_position;   --make request for resending
STAT_REG_OUT(95 downto 64)  <= statreg_rxcommahandler(39 downto 8);

----------------------------------------------------------------------
-- Output signals
----------------------------------------------------------------------
SEND_RESET_WORDS_OUT   <= send_reset_words;
MAKE_TRBNET_RESET_OUT  <= make_trbnet_reset;
PACKET_TIMEOUT_OUT     <= packet_timeout;
COMMA_LOCKED_OUT       <= comma_locked;

MED_DATAREADY_OUT      <= med_dataready;
MED_DATA_OUT           <= med_data;
MED_PACKET_NUM_OUT     <= med_packet_num;

-- used by internal logic
REQUEST_RETRANSMIT_OUT <= request_retransmit;
REQUEST_POSITION_OUT   <= request_position;

-- forwarding of retransmit request
START_RETRANSMIT_OUT   <= start_retransmit;
START_POSITION_OUT     <= start_position;

DEBUG_OUT              <= debug;

end architecture;