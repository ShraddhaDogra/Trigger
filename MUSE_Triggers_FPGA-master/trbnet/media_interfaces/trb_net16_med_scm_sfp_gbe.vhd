--Media interface for Lattice SCM using PCS at 2GHz

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity trb_net16_med_scm_sfp_gbe is
generic(
	SERDES_NUM : integer range 0 to 3 := 0;     -- DO NOT CHANGE
	EXT_CLOCK  : integer range 0 to 1 := c_NO;
	USE_200_MHZ: integer range 0 to 1 := c_YES
);
port(
    CLK                : in  std_logic; -- SerDes clock
    SYSCLK             : in  std_logic; -- fabric clock
    RESET              : in  std_logic; -- synchronous reset
    CLEAR              : in  std_logic; -- asynchronous reset
    CLK_EN             : in  std_logic;
    --Internal Connection
    MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
    MED_DATAREADY_IN   : in  std_logic;
    MED_READ_OUT       : out std_logic;
    MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
    MED_DATAREADY_OUT  : out std_logic;
    MED_READ_IN        : in  std_logic;
    REFCLK2CORE_OUT    : out std_logic;
    --SFP Connection
    SD_RXD_P_IN        : in  std_logic;
    SD_RXD_N_IN        : in  std_logic;
    SD_TXD_P_OUT       : out std_logic;
    SD_TXD_N_OUT       : out std_logic;
    SD_REFCLK_P_IN     : in  std_logic;
    SD_REFCLK_N_IN     : in  std_logic;
    SD_PRSNT_N_IN      : in  std_logic; -- SFP Present ('0' = SFP in place, '1' = no SFP mounted)
    SD_LOS_IN          : in  std_logic; -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
    SD_TXDIS_OUT       : out  std_logic; -- SFP disable
    -- Status and control port
    STAT_OP            : out  std_logic_vector (15 downto 0);
    CTRL_OP            : in  std_logic_vector (15 downto 0);
    STAT_DEBUG         : out  std_logic_vector (63 downto 0);
    CTRL_DEBUG         : in  std_logic_vector (63 downto 0)
   );
end entity;

architecture med_scm_sfp of trb_net16_med_scm_sfp_gbe is

-- Placer Directives
attribute HGROUP : string;
-- for whole architecture
attribute HGROUP of med_scm_sfp : architecture  is "media_interface_group";
attribute syn_sharing : string;
attribute syn_sharing of med_scm_sfp : architecture is "off";

-- Components

component serdes_gbe_0_100_ext is
generic(
  USER_CONFIG_FILE    :  String := "serdes_gbe_0_100_ext.txt"
);
port(
  refclkp              : in  std_logic;
  refclkn              : in  std_logic;
--   rxrefclk             : in  std_logic;
--   refclk               : in  std_logic;
  rxa_pclk             : out std_logic;
  rxb_pclk             : out std_logic;
  hdinp_0              : in  std_logic;
  hdinn_0              : in  std_logic;
  hdoutp_0             : out std_logic;
  hdoutn_0             : out std_logic;
  tclk_0               : in  std_logic;
  rclk_0               : in  std_logic;
  tx_rst_0             : in  std_logic;
  rx_rst_0             : in  std_logic;
  ref_0_sclk           : out std_logic;
  rx_0_sclk            : out std_logic;
  txd_0                : in  std_logic_vector(15 downto 0);
  tx_k_0               : in  std_logic_vector(1 downto 0);
  tx_force_disp_0      : in  std_logic_vector(1 downto 0);
  tx_disp_sel_0        : in  std_logic_vector(1 downto 0);
  rxd_0                : out std_logic_vector(15 downto 0);
  rx_k_0               : out std_logic_vector(1 downto 0);
  rx_disp_err_detect_0 : out std_logic_vector(1 downto 0);
  rx_cv_detect_0       : out std_logic_vector(1 downto 0);
  tx_crc_init_0        : in  std_logic_vector(1 downto 0);
  rx_crc_eop_0         : out std_logic_vector(1 downto 0);
  word_align_en_0      : in  std_logic;
  mca_align_en_0       : in  std_logic;
  felb_0               : in  std_logic;
  lsm_en_0             : in  std_logic;
  lsm_status_0         : out std_logic;
  mca_resync_01        : in  std_logic;
  quad_rst             : in  std_logic;
  serdes_rst           : in  std_logic;
  ref_pclk             : out std_logic
);
end component;

component serdes_200_int is
generic(
	USER_CONFIG_FILE    :  String := "serdes_200_int.txt"
);
port(
	rxrefclk             : in  std_logic;
	refclk               : in  std_logic;
	rxa_pclk             : out std_logic;
	rxb_pclk             : out std_logic;
	hdinp_0              : in  std_logic;
	hdinn_0              : in  std_logic;
	hdoutp_0             : out std_logic;
	hdoutn_0             : out std_logic;
	tclk_0               : in  std_logic;
	rclk_0               : in  std_logic;
	tx_rst_0             : in  std_logic;
	rx_rst_0             : in  std_logic;
	ref_0_sclk           : out std_logic;
	rx_0_sclk            : out std_logic;
	txd_0                : in  std_logic_vector(15 downto 0);
	tx_k_0               : in  std_logic_vector(1 downto 0);
	tx_force_disp_0      : in  std_logic_vector(1 downto 0);
	tx_disp_sel_0        : in  std_logic_vector(1 downto 0);
	rxd_0                : out std_logic_vector(15 downto 0);
	rx_k_0               : out std_logic_vector(1 downto 0);
	rx_disp_err_detect_0 : out std_logic_vector(1 downto 0);
	rx_cv_detect_0       : out std_logic_vector(1 downto 0);
	tx_crc_init_0        : in  std_logic_vector(1 downto 0);
	rx_crc_eop_0         : out std_logic_vector(1 downto 0);
	word_align_en_0      : in  std_logic;
	mca_align_en_0       : in  std_logic;
	felb_0               : in  std_logic;
	lsm_en_0             : in  std_logic;
	lsm_status_0         : out std_logic;
	mca_resync_01        : in  std_logic;
	quad_rst             : in  std_logic;
	serdes_rst           : in  std_logic;
	ref_pclk             : out std_logic
);
end component;


-- LSM state machine signals
signal swap_bytes             : std_logic; -- sysclk
signal swap_bytes_q           : std_logic; -- rx_halfclk
signal tx_allow               : std_logic; -- sysclk
signal tx_allow_delay         : std_logic; -- sysclk
signal tx_allow_q             : std_logic; -- tx_halfclk
signal rx_allow               : std_logic; -- sysclk
signal rx_allow_delay         : std_logic; -- sysclk
signal rx_allow_q             : std_logic; -- rx_halfclk
signal quad_rst               : std_logic; -- sysclk
signal lane_rst               : std_logic; -- sysclk

-- SerDes genuine signals
signal tx_data                : std_logic_vector(15 downto 0); -- tx_halfclk
signal tx_k                   : std_logic_vector(1 downto 0); -- tx_halfclk
signal rx_data                : std_logic_vector(15 downto 0); -- rx_halfclk
signal rx_k                   : std_logic_vector(1 downto 0); -- rx_halfclk
signal rx_k_q                 : std_logic_vector(1 downto 0); -- sysclk
signal link_ok                : std_logic_vector(0 downto 0);
signal link_error             : std_logic_vector(8 downto 0);
signal tx_halfclk             : std_logic; -- 100MHz clock from SerDes
signal rx_halfclk             : std_logic; -- 100MHz clock from SerDes

--rx fifo signals
signal fifo_rx_reset          : std_logic; -- async signal, does not matter
signal fifo_rx_rd_en          : std_logic; -- sysclk
signal fifo_rx_dout           : std_logic_vector(17 downto 0); -- sysclk
signal fifo_rx_empty          : std_logic; -- sysclk
signal last_fifo_rx_empty     : std_logic; -- sysclk
signal fifo_rx_wr_en          : std_logic; -- rx_halfclk
signal fifo_rx_din            : std_logic_vector(17 downto 0); -- rx_halfclk
signal fifo_rx_full           : std_logic; -- rx_halfclk

--rx path
signal rx_counter             : std_logic_vector(c_NUM_WIDTH-1 downto 0); -- sysclk
signal buf_med_dataready_out  : std_logic; -- sysclk
signal buf_med_data_out       : std_logic_vector(c_DATA_WIDTH-1 downto 0); -- sysclk
signal buf_med_packet_num_out : std_logic_vector(c_NUM_WIDTH-1 downto 0); -- sysclk
signal buf_med_read_out       : std_logic;
signal last_rx                : std_logic_vector(8 downto 0);

--tx fifo signals
signal fifo_tx_reset          : std_logic; -- async signal, does not matter
signal fifo_tx_rd_en          : std_logic; -- tx_halfclk
signal fifo_tx_dout           : std_logic_vector(17 downto 0); -- tx_halfclk
signal fifo_tx_empty          : std_logic; -- tx_halfclk
signal last_fifo_tx_empty     : std_logic; -- tx_halfclk
signal fifo_tx_wr_en          : std_logic; -- sysclk
signal fifo_tx_din            : std_logic_vector(17 downto 0); -- sysclk
signal fifo_tx_full           : std_logic; -- sysclk
signal fifo_tx_afull          : std_logic; -- sysclk


--link status
signal link_led               : std_logic;

signal info_led               : std_logic;

signal buf_stat_debug         : std_logic_vector(31 downto 0);

-- status inputs from SFP
signal sfp_prsnt_n            : std_logic; -- synchronized input signals
signal sfp_los                : std_logic; -- synchronized input signals

signal buf_STAT_OP            : std_logic_vector(15 downto 0);

signal led_counter            : std_logic_vector(16 downto 0);
signal rx_led                 : std_logic;
signal tx_led                 : std_logic;


signal tx_correct             : std_logic_vector(1 downto 0); -- GbE mode SERDES: automatic IDLE2 -> IDLE1 conversion
signal first_idle             : std_logic; -- tag the first IDLE2 after data

signal reset_word_cnt         : std_logic_vector(4 downto 0); -- sysclk
signal make_trbnet_reset      : std_logic; -- sysclk
signal send_reset_words       : std_logic; -- sysclk
signal send_reset_q           : std_logic; -- tx_halfclk
signal reset_i                : std_logic; -- sysclk

signal make_trbnet_reset_q    : std_logic;
signal send_reset_words_q     : std_logic;

attribute syn_keep : boolean;
attribute syn_preserve : boolean;
attribute syn_keep of led_counter : signal is true;
attribute syn_keep of send_reset_q : signal is true;
attribute syn_keep of reset_i : signal is true;
attribute syn_preserve of reset_i : signal is true;


begin

--------------------------------------------------------------------------
-- Synchronizer stages
--------------------------------------------------------------------------

-- Reset signal syncing
THE_RESET_DELAY: signal_sync
generic map( DEPTH => 1, WIDTH => 1 )
port map(
	RESET    => '0',
	D_IN(0)  => RESET,
	CLK0     => sysclk,
	CLK1     => sysclk,
	D_OUT(0) => reset_i
);

-- Transfer clock domain
THE_SEND_RESET_SYNC: signal_sync
generic map( DEPTH => 2, WIDTH => 1 )
port map(
	RESET    => '0',
	D_IN(0)  => CTRL_OP(15),
	CLK0     => sysclk,
	CLK1     => tx_halfclk,
	D_OUT(0) => send_reset_q
);

-- Input synchronizer for SFP_PRESENT and SFP_LOS signals (external signals from SFP)
-- DO NOT SAVE ON REGISTERS HERE!!!
THE_SFP_STATUS_SYNC: signal_sync
generic map( DEPTH => 3, WIDTH => 2 )
port map(
	RESET    => reset_i, -- OK
	D_IN(0)  => sd_prsnt_n_in,
	D_IN(1)  => sd_los_in,
	CLK0     => sysclk,
	CLK1     => sysclk,
	D_OUT(0) => sfp_prsnt_n,
	D_OUT(1) => sfp_los
);

-- receive komma character status bits for LSM
THE_RX_K_SYNC: signal_sync
generic map( DEPTH => 2, WIDTH => 4 )
port map(
	RESET               => reset_i, -- should not harm
	D_IN(1 downto 0)    => rx_k,
	D_IN(2)             => make_trbnet_reset,
	D_IN(3)             => send_reset_words,
	CLK0                => rx_halfclk,
	CLK1                => sysclk,
	D_OUT(1 downto 0)   => rx_k_q,
  D_OUT(2)            => make_trbnet_reset_q,
  D_OUT(3)            => send_reset_words_q
);

-- Delay for ALLOW signals
THE_RX_ALLOW_DELAY: signal_sync
generic map( DEPTH => 2, WIDTH => 2 )
port map(
	RESET    => reset_i, -- OK
	D_IN(0)  => rx_allow,
	D_IN(1)  => tx_allow,
	CLK0     => sysclk,
	CLK1     => sysclk,
	D_OUT(0) => rx_allow_delay,
	D_OUT(1) => tx_allow_delay
);

--------------------------------------------------------------------------
-- Main control state machine, startup control for SFP
-- SD_RETRY_IN: '0' = handle byte swapping in logic
--              '1' = simply restart link and hope
--------------------------------------------------------------------------
THE_SFP_LSM: trb_net16_lsm_sfp
port map(
	SYSCLK            => SYSCLK,
	RESET             => reset_i, -- OK
	CLEAR             => clear,
	SFP_MISSING_IN    => sfp_prsnt_n, -- OK sysclk sync'ed
	SFP_LOS_IN        => sfp_los, -- OK sysclk sync'ed
	SD_LINK_OK_IN     => link_ok(0), -- unknown sync
	SD_LOS_IN         => link_error(8), -- unknown sync
	SD_TXCLK_BAD_IN   => link_error(5), -- unknown sync
	SD_RXCLK_BAD_IN   => link_error(4), -- unknown sync
	SD_RETRY_IN       => '0', -- OK fixed
	SD_ALIGNMENT_IN	  => rx_k_q, -- OK
	SD_CV_IN          => link_error(7 downto 6), -- unknown sync
	FULL_RESET_OUT    => quad_rst, -- sysclk sync'ed
	LANE_RESET_OUT    => lane_rst, -- sysclk sync'ed
	TX_ALLOW_OUT      => tx_allow, -- sysclk sync'ed
	RX_ALLOW_OUT      => rx_allow, -- sysclk sync'ed
	SWAP_BYTES_OUT    => swap_bytes, -- sysclk sync'ed
	STAT_OP           => buf_stat_op,
	CTRL_OP           => ctrl_op,
	STAT_DEBUG        => buf_stat_debug
);

link_error(4 downto 0) <= (others => '0');
link_error(5) <= not link_ok(0);
link_error(8) <= '0';
SD_TXDIS_OUT <= quad_rst;

-- receive komma character status bits for LSM
THE_SWAPBYTES_SYNC: signal_sync
generic map( DEPTH => 2, WIDTH => 1 )
port map(
	RESET    => reset_i, -- should not harm
	D_IN(0)  => swap_bytes,
	CLK0     => sysclk,
	CLK1     => rx_halfclk,
	D_OUT(0) => swap_bytes_q
);

-- TX_ALLOW signal sync
THE_TX_ALLOW_SYNC: signal_sync
generic map( DEPTH => 2, WIDTH => 1 )
port map(
	RESET    => reset_i, -- should not harm
	D_IN(0)  => tx_allow,
	CLK0     => sysclk,
	CLK1     => tx_halfclk,
	D_OUT(0) => tx_allow_q
);

-- RX_ALLOW signal sync
THE_RX_ALLOW_SYNC: signal_sync
generic map( DEPTH => 2, WIDTH => 1 )
port map(
	RESET    => reset_i, -- should not harm
	D_IN(0)  => rx_allow,
	CLK0     => sysclk,
	CLK1     => rx_halfclk,
	D_OUT(0) => rx_allow_q
);

--------------------------------------------------------------------------
--------------------------------------------------------------------------

-- SerDes clock output to FPGA fabric
REFCLK2CORE_OUT <= tx_halfclk;

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- Instantiation of serdes module
-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- gen_serdes_0_100 : if SERDES_NUM = 0 and EXT_CLOCK = c_NO and USE_200_MHZ = c_NO generate
--   THE_SERDES: serdes_gbe_0_100
--   port map(
--     refclkp              => SD_REFCLK_P_IN, -- not used here
--     refclkn              => SD_REFCLK_N_IN, -- not used here
--     rxrefclk             => CLK, -- raw 200MHz clock
--     refclk               => CLK, -- raw 200MHz clock
--     rxa_pclk             => rx_halfclk, -- clock multiplier set by data bus width
--     rxb_pclk             => open,
--     hdinp_0              => SD_RXD_P_IN, -- SerDes I/O
--     hdinn_0              => SD_RXD_N_IN, -- SerDes I/O
--     hdoutp_0             => SD_TXD_P_OUT, -- SerDes I/O
--     hdoutn_0             => SD_TXD_N_OUT, -- SerDes I/O
--     tclk_0               => tx_halfclk, -- 100MHz
--     rclk_0               => rx_halfclk, -- 100MHz
--     tx_rst_0             => '0', --JM101206 lane_rst, -- async reset
--     rx_rst_0             => '0', --lane_rst, -- async reset  --reset when sd_los=0 and disp_err=1 or cv=1
--     ref_0_sclk           => open, --tx_halfclk,
--     rx_0_sclk            => open, --rx_halfclk,
--     txd_0                => tx_data,
--     tx_k_0               => tx_k,
--     tx_force_disp_0      => b"00", -- BUGBUG
--     tx_disp_sel_0        => b"00", -- BUGBUG
--     rxd_0                => rx_data,
--     rx_k_0               => rx_k,
--     rx_disp_err_detect_0 => open,
--     rx_cv_detect_0       => link_error(7 downto 6),
--     tx_crc_init_0        => b"00", -- CRC init (not needed)
--     rx_crc_eop_0         => open, -- (not needed)
--     word_align_en_0      => '1', -- word alignment
--     mca_align_en_0       => '0', -- (not needed)
--     felb_0               => '0', -- far end loopback disable
--     lsm_en_0             => '1', -- enable LinkStateMachine
--     lsm_status_0         => link_ok(0), -- link synchronisation successfull
--     mca_resync_01        => '0', -- not needed
--     quad_rst             => '0', -- hands off - kills registers!
--     serdes_rst           => '0', --JM101203 quad_rst, -- unknown if will work
--     ref_pclk             => tx_halfclk -- clock multiplier set by data bus width
--   );
-- end generate;

gen_serdes_0_200 : if SERDES_NUM = 0 and EXT_CLOCK = c_NO and USE_200_MHZ = c_YES generate
	THE_SERDES: serdes_200_int
	port map(
		rxrefclk             => CLK, -- raw 200MHz clock
		refclk               => CLK, -- raw 200MHz clock
		rxa_pclk             => rx_halfclk, --rx_halfclk, -- clock multiplier set by data bus width
		rxb_pclk             => open,
		hdinp_0              => SD_RXD_P_IN, -- SerDes I/O
		hdinn_0              => SD_RXD_N_IN, -- SerDes I/O
		hdoutp_0             => SD_TXD_P_OUT, -- SerDes I/O
		hdoutn_0             => SD_TXD_N_OUT, -- SerDes I/O
		tclk_0               => tx_halfclk, -- 100MHz
		rclk_0               => rx_halfclk, -- 100MHz
		tx_rst_0             => '0', --JM101206 lane_rst, -- async reset
		rx_rst_0             => '0', --lane_rst, -- async reset  --reset when sd_los=0 and disp_err=1 or cv=1
		ref_0_sclk           => open,
		rx_0_sclk            => open,
		txd_0                => tx_data,
		tx_k_0               => tx_k,
		tx_force_disp_0      => b"00", -- BUGBUG
		tx_disp_sel_0        => b"00", -- BUGBUG
		rxd_0                => rx_data,
		rx_k_0               => rx_k,
		rx_disp_err_detect_0 => open,
		rx_cv_detect_0       => link_error(7 downto 6),
		tx_crc_init_0        => b"00", -- CRC init (not needed)
		rx_crc_eop_0         => open, -- (not needed)
		word_align_en_0      => '1', -- word alignment
		mca_align_en_0       => '0', -- (not needed)
		felb_0               => '0', -- far end loopback disable
		lsm_en_0             => '1', -- enable LinkStateMachine
		lsm_status_0         => link_ok(0), -- link synchronisation successfull
		mca_resync_01        => '0', -- not needed
		quad_rst             => '0', -- hands off - kills registers!
		serdes_rst           => '0', --JM101203 quad_rst, -- unknown if will work
		ref_pclk             => tx_halfclk --tx_halfclk -- clock multiplier set by data bus width
	);
end generate;

gen_serdes_0_100_ext : if SERDES_NUM = 0 and EXT_CLOCK = c_YES and USE_200_MHZ = c_NO generate
  THE_SERDES: serdes_gbe_0_100_ext
  port map(
    refclkp              => SD_REFCLK_P_IN,
    refclkn              => SD_REFCLK_N_IN,
--     rxrefclk             => '0', -- raw 100MHz clock
--     refclk               => '0', -- raw 100MHz clock
    rxa_pclk             => rx_halfclk, -- clock multiplier set by data bus width
    rxb_pclk             => open,
    hdinp_0              => SD_RXD_P_IN, -- SerDes I/O
    hdinn_0              => SD_RXD_N_IN, -- SerDes I/O
    hdoutp_0             => SD_TXD_P_OUT, -- SerDes I/O
    hdoutn_0             => SD_TXD_N_OUT, -- SerDes I/O
    tclk_0               => tx_halfclk, -- 100MHz
    rclk_0               => rx_halfclk, -- 100MHz
    tx_rst_0             => '0', --JM101206 lane_rst, -- async reset
    rx_rst_0             => '0', --lane_rst, -- async reset  --SM: reset when sd_los=0 and disp_err=1 or cv=1
    ref_0_sclk           => open,--tx_halfclk,
    rx_0_sclk            => open,--rx_halfclk,
    txd_0                => tx_data,
    tx_k_0               => tx_k,
    tx_force_disp_0      => b"00", -- BUGBUG
    tx_disp_sel_0        => b"00", -- BUGBUG
    rxd_0                => rx_data,
    rx_k_0               => rx_k,
    rx_disp_err_detect_0 => open,
    rx_cv_detect_0       => link_error(7 downto 6),
    tx_crc_init_0        => b"00", -- CRC init (not needed)
    rx_crc_eop_0         => open, -- (not needed)
    word_align_en_0      => '1', -- word alignment
    mca_align_en_0       => '0', -- (not needed)
    felb_0               => '0', -- far end loopback disable
    lsm_en_0             => '1', -- enable LinkStateMachine
    lsm_status_0         => link_ok(0), -- link synchronisation successfull
    mca_resync_01        => '0', -- not needed
    quad_rst             => '0', -- hands off - kills registers!
    serdes_rst           => '0', --JM101203 quad_rst, -- unknown if will work
    ref_pclk             => tx_halfclk -- clock multiplier set by data bus width
  );
end generate;

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- RX path
-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- Received bytes need to be swapped if the SerDes is "off by one" in its internal 8bit path
THE_BYTE_SWAP_PROC: process( rx_halfclk )
begin
	if( rising_edge(rx_halfclk) ) then
		last_rx <= rx_k(1) & rx_data(15 downto 8); -- OK
		if( swap_bytes_q = '0' ) then
			fifo_rx_din   <= rx_k(1) & rx_k(0) & rx_data(15 downto 8) & rx_data(7 downto 0); -- OK
			fifo_rx_wr_en <= not rx_k(0) and rx_allow_q and link_ok(0); -- OK
		else
			fifo_rx_din   <= rx_k(0) & last_rx(8) & rx_data(7 downto 0) & last_rx(7 downto 0); -- OK
			fifo_rx_wr_en <= not last_rx(8) and rx_allow_q and link_ok(0); -- OK
		end if;
	end if;
end process THE_BYTE_SWAP_PROC;

-- Receive buffer FIFO
THE_FIFO_SFP_TO_FPGA: trb_net_fifo_16bit_bram_dualport
generic map(
	USE_STATUS_FLAGS => c_NO
)
port map(
	fifo_gsr_in        => fifo_rx_reset, -- async reset
	read_clock_in      => SYSCLK,
	read_enable_in     => fifo_rx_rd_en, -- OK
	read_data_out      => fifo_rx_dout, -- OK
	empty_out          => fifo_rx_empty, -- OK
	write_clock_in     => rx_halfclk,
	write_enable_in    => fifo_rx_wr_en, -- OK
	write_data_in      => fifo_rx_din, -- OK
	full_out           => fifo_rx_full -- OK
);
-- empty -> read clock
-- full  -> write clock

fifo_rx_reset <= reset_i or not rx_allow_delay; -- async reset, does not matter
fifo_rx_rd_en <= not fifo_rx_empty; -- OK

-- RX packet counter
THE_RX_PACKETS_PROC: process( SYSCLK )
begin
	if( rising_edge(SYSCLK) ) then
		last_fifo_rx_empty <= fifo_rx_empty; -- OK
		if( (reset_i = '1') or (rx_allow_delay = '0') ) then -- OK
			rx_counter <= c_H0; -- OK
		else
			if( buf_med_dataready_out = '1' ) then -- OK
				if( rx_counter = c_max_word_number ) then
					rx_counter <= (others => '0'); -- OK
				else
					rx_counter <= rx_counter + 1; -- OK
				end if;
			end if;
		end if;
	end if;
end process THE_RX_PACKETS_PROC;

buf_med_data_out          <= fifo_rx_dout(15 downto 0); -- OK
buf_med_dataready_out     <= not fifo_rx_dout(17) and not fifo_rx_dout(16) and not last_fifo_rx_empty and rx_allow_delay; -- OK
buf_med_packet_num_out    <= rx_counter; -- OK
buf_med_read_out          <= tx_allow_delay and not fifo_tx_afull; -- OK

-- Output registering
THE_SYNC_PROC: process( SYSCLK )
begin
	if( rising_edge(SYSCLK) ) then
		if( reset_i = '1' ) then -- OK
			MED_DATAREADY_OUT <= '0';
		else
			MED_DATAREADY_OUT     <= buf_med_dataready_out; -- OK
			MED_DATA_OUT          <= buf_med_data_out; -- OK
			MED_PACKET_NUM_OUT    <= buf_med_packet_num_out; -- OK
		end if;
	end if;
end process THE_SYNC_PROC;

MED_READ_OUT                  <= buf_med_read_out;

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- TX path
-------------------------------------------------------------------------
-------------------------------------------------------------------------

fifo_tx_reset <= reset_i or not tx_allow_delay; -- async signal, does not matter
fifo_tx_din   <= MED_PACKET_NUM_IN(2) & MED_PACKET_NUM_IN(0)& MED_DATA_IN; -- OK
fifo_tx_wr_en <= MED_DATAREADY_IN and buf_med_read_out; -- OK
fifo_tx_rd_en <= tx_allow_q; -- OK

--TX Fifo & Data output to Serdes
---------------------
THE_FIFO_FPGA_TO_SFP: trb_net_fifo_16bit_bram_dualport
generic map(
	USE_STATUS_FLAGS => c_NO
)
port map(
	fifo_gsr_in       => fifo_tx_reset, -- async signal, does not matter
	read_clock_in     => tx_halfclk,
	read_enable_in    => fifo_tx_rd_en, -- OK
	read_data_out     => fifo_tx_dout, -- OK
	empty_out         => fifo_tx_empty, -- OK
	write_clock_in    => sysclk,
	write_enable_in   => fifo_tx_wr_en, -- OK
	write_data_in     => fifo_tx_din, -- OK
	full_out          => fifo_tx_full, -- OK
	almost_full_out   => fifo_tx_afull
);
-- empty -> read clock
-- full  -> write clock

THE_SERDES_INPUT_PROC: process( tx_halfclk )
begin
	if( rising_edge(tx_halfclk) ) then
		last_fifo_tx_empty <= fifo_tx_empty; -- OK
		first_idle <= not last_fifo_tx_empty and fifo_tx_empty; -- OK
		if   ( send_reset_q = '1' ) then -- OK
			tx_data <= x"fefe";
			tx_k <= "11";
		elsif( (last_fifo_tx_empty = '1') or (tx_allow_q = '0') ) then -- OK
			tx_data <= x"50bc";
			tx_k <= "01";
			tx_correct <= first_idle & '0'; -- OK
		else
			tx_data <= fifo_tx_dout(15 downto 0); -- OK
			tx_k <= "00";
			tx_correct <= "00";
		end if;
	end if;
end process THE_SERDES_INPUT_PROC;

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- Reset sequencer
THE_CNT_RESET_PROC: process( rx_halfclk )
begin
	if rising_edge(rx_halfclk) then
		if( reset_i = '1' ) then -- OK
			send_reset_words  <= '0';
			make_trbnet_reset <= '0';
			reset_word_cnt    <= (others => '0');
		else
			send_reset_words   <= '0';
			make_trbnet_reset  <= '0';
			if fifo_rx_din = "11" & x"FEFE" then
				if reset_word_cnt(4) = '0' then
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


--Generate LED signals
----------------------
THE_LED_PROC: process( SYSCLK )
begin
	if( rising_edge(SYSCLK) ) then
		led_counter <= led_counter + 1;

		if   ( buf_med_dataready_out = '1' ) then
			rx_led <= '1';
		elsif( led_counter = 0 ) then
			rx_led <= '0';
		end if;

		if   (MED_DATAREADY_IN = '1' ) then
			tx_led <= '1';
		elsif( led_counter = 0 ) then
			tx_led <= '0';
		end if;

	end if;
end process THE_LED_PROC;

stat_op(15)           <= send_reset_words_q;
stat_op(14)           <= buf_stat_op(14);
stat_op(13)           <= make_trbnet_reset_q;
stat_op(12)           <= '0';
stat_op(11)           <= tx_led; --tx led
stat_op(10)           <= rx_led; --rx led
stat_op(9 downto 0)   <= buf_stat_op(9 downto 0);

-- Debug output
stat_debug(15 downto 0)  <= rx_data;
stat_debug(17 downto 16) <= rx_k;
stat_debug(18)           <= link_ok(0);
stat_debug(19)           <= quad_rst;
stat_debug(23 downto 20) <= buf_stat_debug(3 downto 0);
stat_debug(24)           <= fifo_rx_rd_en;
stat_debug(25)           <= fifo_rx_wr_en;
stat_debug(26)           <= fifo_rx_reset;
stat_debug(27)           <= fifo_rx_empty;
stat_debug(28)           <= fifo_rx_full;
stat_debug(29)           <= last_rx(8);
stat_debug(30)           <= rx_allow_delay;
stat_debug(31)           <= lane_rst;
stat_debug(41 downto 32) <= (others => '0');
stat_debug(42)           <= sysclk;
stat_debug(43)           <= '0'; --tx_halfclk;
stat_debug(44)           <= '0'; --rx_halfclk;
stat_debug(46 downto 45) <= tx_k;
stat_debug(47)           <= tx_allow;
stat_debug(59 downto 48) <= (others => '0');
stat_debug(63 downto 60) <= buf_stat_debug(3 downto 0);

end architecture;