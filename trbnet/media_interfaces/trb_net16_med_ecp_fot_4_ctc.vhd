LIBRARY ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity trb_net16_med_ecp_fot_4_ctc is
  generic(
    REVERSE_ORDER : integer range 0 to 1 := c_NO
    );
  port(
    CLK    : in std_logic;
    CLK_25 : in std_logic;
    CLK_EN : in std_logic;
    RESET  : in std_logic;
    CLEAR  : in std_logic;

    --Internal Connection
    MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH*4-1 downto 0);
    MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH*4-1 downto 0);
    MED_DATAREADY_IN   : in  std_logic_vector(3 downto 0);
    MED_READ_OUT       : out std_logic_vector(3 downto 0);
    MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH*4-1 downto 0);
    MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH*4-1 downto 0);
    MED_DATAREADY_OUT  : out std_logic_vector(3 downto 0);
    MED_READ_IN        : in  std_logic_vector(3 downto 0);

    --SFP Connection
    TXP : out std_logic_vector(3 downto 0);
    TXN : out std_logic_vector(3 downto 0);
    RXP : in  std_logic_vector(3 downto 0);
    RXN : in  std_logic_vector(3 downto 0);
    SD  : in  std_logic_vector(3 downto 0);

    -- Status and control port
    STAT_OP            : out std_logic_vector (63 downto 0);
    CTRL_OP            : in  std_logic_vector (63 downto 0);
    STAT_REG_OUT       : out std_logic_vector (511 downto 0);
    STAT_DEBUG         : out std_logic_vector (255 downto 0);
    CTRL_DEBUG         : in  std_logic_vector (63 downto 0)
    );
end entity;

architecture trb_net16_med_ecp_fot_4_ctc_arch of trb_net16_med_ecp_fot_4_ctc is

component serdes_fot_full_quad_ctc is
generic(
	USER_CONFIG_FILE    :  String := "serdes_fot_full_quad_ctc.txt" );
port(
    core_txrefclk : in std_logic;
    core_rxrefclk : in std_logic;
    hdinp0 : in std_logic;
    hdinn0 : in std_logic;
    ff_rxiclk_ch0 : in std_logic;
    ff_txiclk_ch0 : in std_logic;
    ff_ebrd_clk_0 : in std_logic;
    ff_txdata_ch0 : in std_logic_vector(7 downto 0);
    ff_tx_k_cntrl_ch0 : in std_logic;
    ff_xmit_ch0 : in std_logic;
    ff_correct_disp_ch0 : in std_logic;
    ffc_rrst_ch0 : in std_logic;
    ffc_lane_tx_rst_ch0 : in std_logic;
    ffc_lane_rx_rst_ch0 : in std_logic;
    ffc_txpwdnb_ch0 : in std_logic;
    ffc_rxpwdnb_ch0 : in std_logic;
    hdinp1 : in std_logic;
    hdinn1 : in std_logic;
    ff_rxiclk_ch1 : in std_logic;
    ff_txiclk_ch1 : in std_logic;
    ff_ebrd_clk_1 : in std_logic;
    ff_txdata_ch1 : in std_logic_vector(7 downto 0);
    ff_tx_k_cntrl_ch1 : in std_logic;
    ff_xmit_ch1 : in std_logic;
    ff_correct_disp_ch1 : in std_logic;
    ffc_rrst_ch1 : in std_logic;
    ffc_lane_tx_rst_ch1 : in std_logic;
    ffc_lane_rx_rst_ch1 : in std_logic;
    ffc_txpwdnb_ch1 : in std_logic;
    ffc_rxpwdnb_ch1 : in std_logic;
    hdinp2 : in std_logic;
    hdinn2 : in std_logic;
    ff_rxiclk_ch2 : in std_logic;
    ff_txiclk_ch2 : in std_logic;
    ff_ebrd_clk_2 : in std_logic;
    ff_txdata_ch2 : in std_logic_vector(7 downto 0);
    ff_tx_k_cntrl_ch2 : in std_logic;
    ff_xmit_ch2 : in std_logic;
    ff_correct_disp_ch2 : in std_logic;
    ffc_rrst_ch2 : in std_logic;
    ffc_lane_tx_rst_ch2 : in std_logic;
    ffc_lane_rx_rst_ch2 : in std_logic;
    ffc_txpwdnb_ch2 : in std_logic;
    ffc_rxpwdnb_ch2 : in std_logic;
    hdinp3 : in std_logic;
    hdinn3 : in std_logic;
    ff_rxiclk_ch3 : in std_logic;
    ff_txiclk_ch3 : in std_logic;
    ff_ebrd_clk_3 : in std_logic;
    ff_txdata_ch3 : in std_logic_vector(7 downto 0);
    ff_tx_k_cntrl_ch3 : in std_logic;
    ff_xmit_ch3 : in std_logic;
    ff_correct_disp_ch3 : in std_logic;
    ffc_rrst_ch3 : in std_logic;
    ffc_lane_tx_rst_ch3 : in std_logic;
    ffc_lane_rx_rst_ch3 : in std_logic;
    ffc_txpwdnb_ch3 : in std_logic;
    ffc_rxpwdnb_ch3 : in std_logic;
    ffc_macro_rst : in std_logic;
    ffc_quad_rst : in std_logic;
    ffc_trst : in std_logic;
    hdoutp0 : out std_logic;
    hdoutn0 : out std_logic;
    ff_rxdata_ch0 : out std_logic_vector(7 downto 0);
    ff_rx_k_cntrl_ch0 : out std_logic;
    ff_rxfullclk_ch0 : out std_logic;
    ff_disp_err_ch0 : out std_logic;
    ff_cv_ch0 : out std_logic;
    ff_rx_even_ch0 : out std_logic;
    ffs_rlos_lo_ch0 : out std_logic;
    ffs_ls_sync_status_ch0 : out std_logic;
    ffs_cc_underrun_ch0 : out std_logic;
    ffs_cc_overrun_ch0 : out std_logic;
    ffs_txfbfifo_error_ch0 : out std_logic;
    ffs_rxfbfifo_error_ch0 : out std_logic;
    ffs_rlol_ch0 : out std_logic;
    oob_out_ch0 : out std_logic;
    hdoutp1 : out std_logic;
    hdoutn1 : out std_logic;
    ff_rxdata_ch1 : out std_logic_vector(7 downto 0);
    ff_rx_k_cntrl_ch1 : out std_logic;
    ff_rxfullclk_ch1 : out std_logic;
    ff_disp_err_ch1 : out std_logic;
    ff_cv_ch1 : out std_logic;
    ff_rx_even_ch1 : out std_logic;
    ffs_rlos_lo_ch1 : out std_logic;
    ffs_ls_sync_status_ch1 : out std_logic;
    ffs_cc_underrun_ch1 : out std_logic;
    ffs_cc_overrun_ch1 : out std_logic;
    ffs_txfbfifo_error_ch1 : out std_logic;
    ffs_rxfbfifo_error_ch1 : out std_logic;
    ffs_rlol_ch1 : out std_logic;
    oob_out_ch1 : out std_logic;
    hdoutp2 : out std_logic;
    hdoutn2 : out std_logic;
    ff_rxdata_ch2 : out std_logic_vector(7 downto 0);
    ff_rx_k_cntrl_ch2 : out std_logic;
    ff_rxfullclk_ch2 : out std_logic;
    ff_disp_err_ch2 : out std_logic;
    ff_cv_ch2 : out std_logic;
    ff_rx_even_ch2 : out std_logic;
    ffs_rlos_lo_ch2 : out std_logic;
    ffs_ls_sync_status_ch2 : out std_logic;
    ffs_cc_underrun_ch2 : out std_logic;
    ffs_cc_overrun_ch2 : out std_logic;
    ffs_txfbfifo_error_ch2 : out std_logic;
    ffs_rxfbfifo_error_ch2 : out std_logic;
    ffs_rlol_ch2 : out std_logic;
    oob_out_ch2 : out std_logic;
    hdoutp3 : out std_logic;
    hdoutn3 : out std_logic;
    ff_rxdata_ch3 : out std_logic_vector(7 downto 0);
    ff_rx_k_cntrl_ch3 : out std_logic;
    ff_rxfullclk_ch3 : out std_logic;
    ff_disp_err_ch3 : out std_logic;
    ff_cv_ch3 : out std_logic;
    ff_rx_even_ch3 : out std_logic;
    ffs_rlos_lo_ch3 : out std_logic;
    ffs_ls_sync_status_ch3 : out std_logic;
    ffs_cc_underrun_ch3 : out std_logic;
    ffs_cc_overrun_ch3 : out std_logic;
    ffs_txfbfifo_error_ch3 : out std_logic;
    ffs_rxfbfifo_error_ch3 : out std_logic;
    ffs_rlol_ch3 : out std_logic;
    oob_out_ch3 : out std_logic;
    ff_txfullclk : out std_logic;
    ff_txhalfclk : out std_logic;
    ffs_plol : out std_logic
    );
end component;


component lattice_ecp2m_fifo_8x8_dualport
port(
	Data     : in  std_logic_vector(7 downto 0);
	WrClock  : in  std_logic;
	RdClock  : in  std_logic;
	WrEn     : in  std_logic;
	RdEn     : in  std_logic;
	Reset    : in  std_logic;
	RPReset  : in  std_logic;
	Q        : out std_logic_vector(7 downto 0);
	Empty    : out std_logic;
	Full     : out std_logic
);
end component;


component lattice_ecp2m_fifo_16x8_dualport
port(
	Data     : in  std_logic_vector(15 downto 0);
	WrClock  : in  std_logic;
	RdClock  : in  std_logic;
	WrEn     : in  std_logic;
	RdEn     : in  std_logic;
	Reset    : in  std_logic;
	RPReset  : in  std_logic;
	Q        : out std_logic_vector(15 downto 0);
	Empty    : out std_logic;
	Full     : out std_logic
);
end component;

component trb_net16_rx_packets is
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
end component trb_net16_rx_packets;

type link_error_t is array(0 to 3) of std_logic_vector(7 downto 0);
signal link_error                : link_error_t;
signal link_error_q              : link_error_t;
signal ffs_plol                  : std_logic;
signal link_ok                   : std_logic_vector(3 downto 0);
signal link_ok_q                 : std_logic_vector(3 downto 0);
signal tx_data                   : std_logic_vector(8*4-1 downto 0);
signal rx_data                   : std_logic_vector(8*4-1 downto 0);
signal ff_txfullclk              : std_logic;
signal rx_k                      : std_logic_vector(3 downto 0);
signal tx_k                      : std_logic_vector(3 downto 0);
signal lane_rst                  : std_logic_vector(3 downto 0);
signal lane_rst_qtx              : std_logic_vector(3 downto 0);
signal quad_rst                  : std_logic_vector(3 downto 0);
signal reset_rx_control          : std_logic_vector(3 downto 0);

signal tx_allow                  : std_logic_vector(3 downto 0);
signal rx_allow                  : std_logic_vector(3 downto 0);
signal sd_q                      : std_logic_vector(3 downto 0);
signal sfp_los                   : std_logic_vector(3 downto 0);

signal buf_med_dataready_out     : std_logic_vector(3 downto 0);
signal buf_med_data_out          : std_logic_vector(63 downto 0);
signal buf_med_packet_num_out    : std_logic_vector(11 downto 0);

signal delay_counter             : std_logic_vector(7 downto 0);
signal led_counter               : std_logic_vector(15 downto 0);
signal rx_led                    : std_logic_vector(3 downto 0);
signal tx_led                    : std_logic_vector(3 downto 0);

signal med_state_shift_i         : std_logic_vector(3 downto 0);
signal med_state_shift_ii        : std_logic_vector(3 downto 0);
signal med_state_i               : std_logic_vector(11 downto 0);

signal FSM_STAT_OP               : std_logic_vector(4*16-1 downto 0);
signal FSM_STAT_DEBUG            : std_logic_vector(4*32-1 downto 0);
signal FSM_CTRL_OP               : std_logic_vector(4*16-1 downto 0);

signal send_reset_words          : std_logic_vector(3 downto 0);
signal make_trbnet_reset         : std_logic_vector(3 downto 0);

signal packet_timeout            : std_logic_vector(3 downto 0);
signal rx_bsm                    : std_logic_vector(15 downto 0);
signal debug_rxcontrol_i         : std_logic_vector(127 downto 0);

signal request_retransmit_i      : std_logic_vector(3 downto 0);
signal request_position_i        : std_logic_vector(31 downto 0);
signal start_retransmit_i        : std_logic_vector(3 downto 0);
signal start_position_i          : std_logic_vector(31 downto 0);
signal debug_txcontrol_i         : std_logic_vector(127 downto 0);

signal tx_lane_reset             : std_logic;
signal ffs_plol_counter          : std_logic_vector(18 downto 0);
signal ffs_plol_low_stable       : std_logic;

signal statreg_rxcontrol_i       : std_logic_vector(96*4-1 downto 0);
signal statreg_txcontrol_i       : std_logic_vector(127 downto 0);


attribute HGROUP       : string;
attribute syn_sharing  : string;
attribute syn_keep     : boolean;
attribute syn_preserve : boolean;

attribute HGROUP of trb_net16_med_ecp_fot_4_ctc_arch : architecture  is "GROUP_PCS";
attribute syn_sharing of trb_net16_med_ecp_fot_4_ctc_arch : architecture is "false";
attribute syn_keep of led_counter : signal is true;
attribute syn_preserve of led_counter : signal is true;


begin
gen_normal_serdes : if REVERSE_ORDER = c_NO generate
	THE_SERDES: serdes_fot_full_quad_ctc
	port map(
		core_txrefclk          => CLK_25,
		core_rxrefclk          => CLK_25,

		hdinp0                 => RXP(0),
		hdinn0                 => RXN(0),
		hdoutp0                => TXP(0),
		hdoutn0                => TXN(0),
		ff_rxiclk_ch0          => CLK_25,
		ff_txiclk_ch0          => CLK_25,
		ff_ebrd_clk_0          => CLK_25,
		ff_txdata_ch0          => tx_data(7 downto 0),
		ff_rxdata_ch0          => rx_data(7 downto 0),
		ff_tx_k_cntrl_ch0      => tx_k(0),
		ff_rx_k_cntrl_ch0      => rx_k(0),
		ff_xmit_ch0            => '0',
		ff_correct_disp_ch0    => '0',
		ff_disp_err_ch0        => link_error(0)(0),
		ff_cv_ch0              => link_error(0)(1),
		ffc_rrst_ch0           => '0',
		ffc_lane_tx_rst_ch0    => tx_lane_reset, --lane_rst(0),
		ffc_lane_rx_rst_ch0    => lane_rst_qtx(0),
		ffc_txpwdnb_ch0        => '1',
		ffc_rxpwdnb_ch0        => '1',
		ffs_rlos_lo_ch0        => link_error(0)(2),
		ffs_ls_sync_status_ch0 => link_ok(0),
		ffs_cc_underrun_ch0    => link_error(0)(3),
		ffs_cc_overrun_ch0     => link_error(0)(4),
		ffs_txfbfifo_error_ch0 => link_error(0)(5),
		ffs_rxfbfifo_error_ch0 => link_error(0)(6),
		ffs_rlol_ch0           => link_error(0)(7),
		oob_out_ch0            => open,

		hdinp1                 => rxp(1),
		hdinn1                 => rxn(1),
		hdoutp1                => txp(1),
		hdoutn1                => txn(1),
		ff_rxiclk_ch1          => CLK_25,
		ff_txiclk_ch1          => CLK_25,
		ff_ebrd_clk_1          => CLK_25,
		ff_txdata_ch1          => tx_data(15 downto 8),
		ff_rxdata_ch1          => rx_data(15 downto 8),
		ff_tx_k_cntrl_ch1      => tx_k(1),
		ff_rx_k_cntrl_ch1      => rx_k(1),
		ff_xmit_ch1            => '0',
		ff_correct_disp_ch1    => '0',
		ff_disp_err_ch1        => link_error(1)(0),
		ff_cv_ch1              => link_error(1)(1),
		ffc_rrst_ch1           => '0',
		ffc_lane_tx_rst_ch1    => tx_lane_reset, --lane_rst(1),
		ffc_lane_rx_rst_ch1    => lane_rst_qtx(1),
		ffc_txpwdnb_ch1        => '1',
		ffc_rxpwdnb_ch1        => '1',
		ffs_rlos_lo_ch1        => link_error(1)(2),
		ffs_ls_sync_status_ch1 => link_ok(1),
		ffs_cc_underrun_ch1    => link_error(1)(3),
		ffs_cc_overrun_ch1     => link_error(1)(4),
		ffs_txfbfifo_error_ch1 => link_error(1)(5),
		ffs_rxfbfifo_error_ch1 => link_error(1)(6),
		ffs_rlol_ch1           => link_error(1)(7),
		oob_out_ch1            => open,

		hdinp2                 => rxp(2),
		hdinn2                 => rxn(2),
		hdoutp2                => txp(2),
		hdoutn2                => txn(2),
		ff_rxiclk_ch2          => CLK_25,
		ff_txiclk_ch2          => CLK_25,
		ff_ebrd_clk_2          => CLK_25,
		ff_txdata_ch2          => tx_data(23 downto 16),
		ff_rxdata_ch2          => rx_data(23 downto 16),
		ff_tx_k_cntrl_ch2      => tx_k(2),
		ff_rx_k_cntrl_ch2      => rx_k(2),
		ff_xmit_ch2            => '0',
		ff_correct_disp_ch2    => '0',
		ff_disp_err_ch2        => link_error(2)(0),
		ff_cv_ch2              => link_error(2)(1),
		ffc_rrst_ch2           => '0',
		ffc_lane_tx_rst_ch2    => tx_lane_reset, --lane_rst(2),
		ffc_lane_rx_rst_ch2    => lane_rst_qtx(2),
		ffc_txpwdnb_ch2        => '1',
		ffc_rxpwdnb_ch2        => '1',
		ffs_rlos_lo_ch2        => link_error(2)(2),
		ffs_ls_sync_status_ch2 => link_ok(2),
		ffs_cc_underrun_ch2    => link_error(2)(3),
		ffs_cc_overrun_ch2     => link_error(2)(4),
		ffs_txfbfifo_error_ch2 => link_error(2)(5),
		ffs_rxfbfifo_error_ch2 => link_error(2)(6),
		ffs_rlol_ch2           => link_error(2)(7),
		oob_out_ch2            => open,

		hdinp3                 => rxp(3),
		hdinn3                 => rxn(3),
		hdoutp3                => txp(3),
		hdoutn3                => txn(3),
		ff_rxiclk_ch3          => CLK_25,
		ff_txiclk_ch3          => CLK_25,
		ff_ebrd_clk_3          => CLK_25,
		ff_txdata_ch3          => tx_data(31 downto 24),
		ff_rxdata_ch3          => rx_data(31 downto 24),
		ff_tx_k_cntrl_ch3      => tx_k(3),
		ff_rx_k_cntrl_ch3      => rx_k(3),
		ff_xmit_ch3            => '0',
		ff_correct_disp_ch3    => '0',
		ff_disp_err_ch3        => link_error(3)(0),
		ff_cv_ch3              => link_error(3)(1),
		ffc_rrst_ch3           => '0',
		ffc_lane_tx_rst_ch3    => tx_lane_reset, --lane_rst(3),
		ffc_lane_rx_rst_ch3    => lane_rst_qtx(3),
		ffc_txpwdnb_ch3        => '1',
		ffc_rxpwdnb_ch3        => '1',
		ffs_rlos_lo_ch3        => link_error(3)(2),
		ffs_ls_sync_status_ch3 => link_ok(3),
		ffs_cc_underrun_ch3    => link_error(3)(3),
		ffs_cc_overrun_ch3     => link_error(3)(4),
		ffs_txfbfifo_error_ch3 => link_error(3)(5),
		ffs_rxfbfifo_error_ch3 => link_error(3)(6),
		ffs_rlol_ch3           => link_error(3)(7),
		oob_out_ch3            => open,

		ffc_macro_rst          => '0',
		ffc_quad_rst           => quad_rst(0),
		ffc_trst               => '0',
		ff_txfullclk           => ff_txfullclk,
		ffs_plol               => ffs_plol
	);
end generate;

gen_twisted_serdes : if REVERSE_ORDER = c_YES generate
THE_SERDES: serdes_fot_full_quad_ctc
	port map(
		core_txrefclk          => CLK_25,
		core_rxrefclk          => CLK_25,

		hdinp0                 => RXP(0),
		hdinn0                 => RXN(0),
		hdoutp0                => TXP(0),
		hdoutn0                => TXN(0),
		ff_rxiclk_ch0          => CLK_25,
		ff_txiclk_ch0          => CLK_25,
		ff_ebrd_clk_0          => CLK_25,
		ff_txdata_ch0          => tx_data(31 downto 24),
		ff_rxdata_ch0          => rx_data(31 downto 24),
		ff_tx_k_cntrl_ch0      => tx_k(3),
		ff_rx_k_cntrl_ch0      => rx_k(3),
		ff_xmit_ch0            => '0',
		ff_correct_disp_ch0    => '0',
		ff_disp_err_ch0        => link_error(3)(0),
		ff_cv_ch0              => link_error(3)(1),
		ffc_rrst_ch0           => '0',
		ffc_lane_tx_rst_ch0    => tx_lane_reset, --lane_rst(3),
		ffc_lane_rx_rst_ch0    => lane_rst_qtx(3),
		ffc_txpwdnb_ch0        => '1',
		ffc_rxpwdnb_ch0        => '1',
		ffs_rlos_lo_ch0        => link_error(3)(2),
		ffs_ls_sync_status_ch0 => link_ok(3),
		ffs_cc_underrun_ch0    => link_error(3)(3),
		ffs_cc_overrun_ch0     => link_error(3)(4),
		ffs_txfbfifo_error_ch0 => link_error(3)(5),
		ffs_rxfbfifo_error_ch0 => link_error(3)(6),
		ffs_rlol_ch0           => link_error(3)(7),
		oob_out_ch0            => open,

		hdinp1                 => rxp(1),
		hdinn1                 => rxn(1),
		hdoutp1                => txp(1),
		hdoutn1                => txn(1),
		ff_rxiclk_ch1          => CLK_25,
		ff_txiclk_ch1          => CLK_25,
		ff_ebrd_clk_1          => CLK_25,
		ff_txdata_ch1          => tx_data(23 downto 16),
		ff_rxdata_ch1          => rx_data(23 downto 16),
		ff_tx_k_cntrl_ch1      => tx_k(2),
		ff_rx_k_cntrl_ch1      => rx_k(2),
		ff_xmit_ch1            => '0',
		ff_correct_disp_ch1    => '0',
		ff_disp_err_ch1        => link_error(2)(0),
		ff_cv_ch1              => link_error(2)(1),
		ffc_rrst_ch1           => '0',
		ffc_lane_tx_rst_ch1    => tx_lane_reset, --lane_rst(2),
		ffc_lane_rx_rst_ch1    => lane_rst_qtx(2),
		ffc_txpwdnb_ch1        => '1',
		ffc_rxpwdnb_ch1        => '1',
		ffs_rlos_lo_ch1        => link_error(2)(2),
		ffs_ls_sync_status_ch1 => link_ok(2),
		ffs_cc_underrun_ch1    => link_error(2)(3),
		ffs_cc_overrun_ch1     => link_error(2)(4),
		ffs_txfbfifo_error_ch1 => link_error(2)(5),
		ffs_rxfbfifo_error_ch1 => link_error(2)(6),
		ffs_rlol_ch1           => link_error(2)(7),
		oob_out_ch1            => open,

		hdinp2                 => rxp(2),
		hdinn2                 => rxn(2),
		hdoutp2                => txp(2),
		hdoutn2                => txn(2),
		ff_rxiclk_ch2          => CLK_25,
		ff_txiclk_ch2          => CLK_25,
		ff_ebrd_clk_2          => CLK_25,
		ff_txdata_ch2          => tx_data(15 downto 8),
		ff_rxdata_ch2          => rx_data(15 downto 8),
		ff_tx_k_cntrl_ch2      => tx_k(1),
		ff_rx_k_cntrl_ch2      => rx_k(1),
		ff_xmit_ch2            => '0',
		ff_correct_disp_ch2    => '0',
		ff_disp_err_ch2        => link_error(1)(0),
		ff_cv_ch2              => link_error(1)(1),
		ffc_rrst_ch2           => '0',
		ffc_lane_tx_rst_ch2    => tx_lane_reset, --lane_rst(1),
		ffc_lane_rx_rst_ch2    => lane_rst_qtx(1),
		ffc_txpwdnb_ch2        => '1',
		ffc_rxpwdnb_ch2        => '1',
		ffs_rlos_lo_ch2        => link_error(1)(2),
		ffs_ls_sync_status_ch2 => link_ok(1),
		ffs_cc_underrun_ch2    => link_error(1)(3),
		ffs_cc_overrun_ch2     => link_error(1)(4),
		ffs_txfbfifo_error_ch2 => link_error(1)(5),
		ffs_rxfbfifo_error_ch2 => link_error(1)(6),
		ffs_rlol_ch2           => link_error(1)(7),
		oob_out_ch2            => open,

		hdinp3                 => rxp(3),
		hdinn3                 => rxn(3),
		hdoutp3                => txp(3),
		hdoutn3                => txn(3),
		ff_rxiclk_ch3          => CLK_25,
		ff_txiclk_ch3          => CLK_25,
		ff_ebrd_clk_3          => CLK_25,
		ff_txdata_ch3          => tx_data(7 downto 0),
		ff_rxdata_ch3          => rx_data(7 downto 0),
		ff_tx_k_cntrl_ch3      => tx_k(0),
		ff_rx_k_cntrl_ch3      => rx_k(0),
		ff_xmit_ch3            => '0',
		ff_correct_disp_ch3    => '0',
		ff_disp_err_ch3        => link_error(0)(0),
		ff_cv_ch3              => link_error(0)(1),
		ffc_rrst_ch3           => '0',
		ffc_lane_tx_rst_ch3    => tx_lane_reset, -- lane_rst(0),
		ffc_lane_rx_rst_ch3    => lane_rst_qtx(0),
		ffc_txpwdnb_ch3        => '1',
		ffc_rxpwdnb_ch3        => '1',
		ffs_rlos_lo_ch3        => link_error(0)(2),
		ffs_ls_sync_status_ch3 => link_ok(0),
		ffs_cc_underrun_ch3    => link_error(0)(3),
		ffs_cc_overrun_ch3     => link_error(0)(4),
		ffs_txfbfifo_error_ch3 => link_error(0)(5),
		ffs_rxfbfifo_error_ch3 => link_error(0)(6),
		ffs_rlol_ch3           => link_error(0)(7),
		oob_out_ch3            => open,

		ffc_macro_rst          => '0',
		ffc_quad_rst           => quad_rst(0),
		ffc_trst               => '0',
		ff_txfullclk           => ff_txfullclk,
		ffs_plol               => ffs_plol
	);
end generate;



-----------------------------------------------------------------------
--TX Control
-----------------------------------------------------------------------
gen_tx: for i in 0 to 3 generate
  THE_TX_CONTROL : trb_net16_tx_control
    port map(
      TXCLK_IN                       => ff_txfullclk,
      RXCLK_IN                       => CLK_25,
      SYSCLK_IN                      => CLK,
      RESET_IN                       => tx_lane_reset,

      TX_DATA_IN                     => MED_DATA_IN(i*16+15 downto i*16),
      TX_PACKET_NUMBER_IN            => MED_PACKET_NUM_IN(i*3+2 downto i*3),
      TX_WRITE_IN                    => MED_DATAREADY_IN(i),
      TX_READ_OUT                    => MED_READ_OUT(i),

      TX_DATA_OUT                    => tx_data(i*8+7 downto i*8),
      TX_K_OUT                       => tx_k(i),

      REQUEST_RETRANSMIT_IN          => request_retransmit_i(i),
      REQUEST_POSITION_IN            => request_position_i(i*8+7 downto i*8),
      START_RETRANSMIT_IN            => start_retransmit_i(i),
      START_POSITION_IN              => start_position_i(i*8+7 downto i*8),
      SEND_LINK_RESET_IN             => CTRL_OP(i*16+15),
      TX_ALLOW_IN                    => tx_allow(i),

      DEBUG_OUT                      => debug_txcontrol_i(i*32+31 downto i*32),
      STAT_REG_OUT                   => statreg_txcontrol_i(i*32+31 downto i*32)
      );

end generate;

-----------------------------------------------------------------------
--RX Control
-----------------------------------------------------------------------
gen_rx: for i in 0 to 3 generate
--   THE_RX_CONTROL : trb_net16_rx_packets
--     port map(
--       -- Resets
--       RESET_IN              => reset,
--       QUAD_RST_IN           => quad_rst(0),
--       -- data stream from SerDes
--       CLK_IN                => CLK_25,
--       RX_ALLOW_IN           => rx_allow(i),
--       RX_DATA_IN            => rx_data(8*i+7 downto 8*i),
--       RX_K_IN               => rx_k(i),
--       -- media interface
--       SYSCLK_IN             => CLK,
--       MED_DATA_OUT          => MED_DATA_OUT(i*16+15 downto i*16),
--       MED_DATAREADY_OUT     => buf_MED_DATAREADY_OUT(i),
--       MED_READ_IN           => MED_READ_IN(i),
--       MED_PACKET_NUM_OUT    => MED_PACKET_NUM_OUT(i*3+2 downto i*3),
--       -- reset handling
--       SEND_RESET_WORDS_OUT  => send_reset_words(i),
--       MAKE_TRBNET_RESET_OUT => make_trbnet_reset(i),
--       -- Status signals
--       PACKET_TIMEOUT_OUT    => packet_timeout(i),
--       -- Debug signals
--       BSM_OUT               => rx_bsm(i*4+3 downto i*4),
--       DBG_OUT               => debug_rxcontrol_i(i*16+15 downto i*16)
--     );
--
--   MED_DATAREADY_OUT(i) <= buf_MED_DATAREADY_OUT(i);

  THE_RX_CONTROL : trb_net16_rx_control
    port map(
      RESET_IN                       => reset_rx_control(i),
      QUAD_RST_IN                    => lane_rst(i),
      -- raw data from SerDes receive path
      CLK_IN                         => CLK_25,
      RX_DATA_IN                     => rx_data(i*8+7 downto i*8),
      RX_K_IN                        => rx_k(i),
      RX_CV_IN                       => link_error(i)(1),
      RX_DISP_ERR_IN                 => link_error(i)(0),
      RX_ALLOW_IN                    => rx_allow(i),
      -- media interface
      SYSCLK_IN                      => CLK,
      MED_DATA_OUT                   => buf_med_data_out(i*16+15 downto i*16),
      MED_DATAREADY_OUT              => buf_med_dataready_out(i),
      MED_READ_IN                    => MED_READ_IN(i),
      MED_PACKET_NUM_OUT             => buf_med_packet_num_out(i*3+2 downto i*3),
      -- request retransmission in case of error while receiving
      REQUEST_RETRANSMIT_OUT         => request_retransmit_i(i),
      REQUEST_POSITION_OUT           => request_position_i(i*8+7 downto i*8),
      -- command decoding
      START_RETRANSMIT_OUT           => start_retransmit_i(i),
      START_POSITION_OUT             => start_position_i(i*8+7 downto i*8),
      -- reset handling
      SEND_RESET_WORDS_OUT           => send_reset_words(i),
      MAKE_TRBNET_RESET_OUT          => make_trbnet_reset(i),
      -- Status signals
      PACKET_TIMEOUT_OUT             => packet_timeout(i),
      -- Debugging
      ENABLE_CORRECTION_IN           => CTRL_OP(i*16+8),
      STAT_REG_OUT                   => statreg_rxcontrol_i(i*96+95 downto i*96),
      DEBUG_OUT                      => debug_rxcontrol_i(i*32+31 downto i*32)
      );

reset_rx_control(i)   <= RESET or lane_rst(i) or link_error_q(i)(2) or link_error_q(i)(7);

MED_DATA_OUT(i*16+15 downto i*16)       <= buf_med_data_out(i*16+15 downto i*16);
MED_DATAREADY_OUT(i)                    <= buf_med_dataready_out(i);
MED_PACKET_NUM_OUT(i*3+2 downto i*3)    <= buf_med_packet_num_out(i*3+2 downto i*3);

end generate;


-----------------------------------------------------------------------
--Synchronization
-----------------------------------------------------------------------
gen_sync: for i in 0 to 3 generate
  CLK_TO_TX_SYNC: signal_sync
    generic map(
      DEPTH => 2,
      WIDTH => 1
      )
    port map(
      RESET    => '0',
      D_IN(0)  => lane_rst(i),
      CLK0     => CLK,
      CLK1     => CLK_25,
      D_OUT(0) => lane_rst_qtx(i)
      );

  LINK_ERROR_SYNC: signal_sync
    generic map(
      DEPTH => 2,
      WIDTH => 9
      )
    port map(
      RESET             => reset,
      D_IN(7 downto 0)  => link_error(i),
      D_IN(8)           => link_ok(i),
      CLK0              => CLK_25,
      CLK1              => CLK,
      D_OUT(7 downto 0) => link_error_q(i),
      D_OUT(8)          => link_ok_q(i)
      );

  SYNC_INPUT_TO_CLK : signal_sync
    generic map(
      DEPTH => 2,
      WIDTH => 1
      )
    port map(
      RESET    => reset,
      D_IN(0)  => sd(i),
      CLK0     => CLK,
      CLK1     => CLK,
      D_OUT(0) => sd_q(i)
      );

end generate;


-----------------------------------------------------------------------
--LED Signals
-----------------------------------------------------------------------
  gen_led: for i in 0 to 3 generate
    THE_TX_RX_LED_PROC: process( clk )
      begin
        if( rising_edge(CLK) ) then
          if   ( buf_MED_DATAREADY_OUT(i) = '1' ) then
            rx_led(i) <= '1';
          elsif( led_counter = 0 ) then
            rx_led(i) <= '0';
          end if;
          if   ( MED_DATAREADY_IN(i) = '1') then
            tx_led(i) <= '1';
          elsif( led_counter = 0 ) then
            tx_led(i) <= '0';
          end if;
        end if;
      end process;
  end generate;

  proc_led_counter: process(CLK)
    begin
      if( rising_edge(CLK) ) then
        led_counter <= led_counter + 1;
        if led_counter = 0 then
          delay_counter <= delay_counter + 1;
        end if;
      end if;
    end process;

  gen_med_state : for i in 0 to 3 generate
    proc_med_state : process begin
      wait until rising_edge(CLK);
      if FSM_STAT_OP(i*16+2 downto i*16) /= "000" then
        med_state_i(i*3+2 downto i*3) <= FSM_STAT_OP(i*16+2 downto i*16);
        med_state_shift_i(i) <= '0';
        med_state_shift_ii(i) <= '0';
      elsif delay_counter = 0 then
        med_state_shift_i(i) <= '1';
        med_state_shift_ii(i) <= med_state_shift_i(i);
        if med_state_shift_ii(i) = '1' then
          med_state_i(i*3+2 downto i*3) <= ERROR_OK;
        else 
          med_state_i(i*3+2 downto i*3) <= ERROR_WAIT;
        end if;
      end if;
    end process;
  end generate;


-----------------------------------------------------------------------
--TX Reset
-----------------------------------------------------------------------

  tx_lane_reset <= not ffs_plol_low_stable or RESET;

  proc_plol_stable : process(CLEAR, CLK_25)
    begin
      if CLEAR = '1' then
        ffs_plol_low_stable    <= '0';
        ffs_plol_counter       <= (others => '0');
      elsif rising_edge(CLK_25) then
        if ffs_plol = '1' then
          ffs_plol_low_stable  <= '0';
          ffs_plol_counter     <= (others => '0');
        elsif ffs_plol_counter(18) = '1' then
          ffs_plol_low_stable  <= '1';
          ffs_plol_counter     <= ffs_plol_counter;
        else
          ffs_plol_low_stable  <= '0';
          ffs_plol_counter     <= ffs_plol_counter + 1;
        end if;
      end if;
    end process;


-----------------------------------------------------------------------
--Link State Machine
-----------------------------------------------------------------------
  gen_lsm : for i in 0 to 3 generate
    THE_SFP_LSM: trb_net16_lsm_sfp
      generic map(
        CHECK_FOR_CV => c_NO
        )
      port map(
        SYSCLK            => CLK,
        RESET             => reset,
        CLEAR             => reset,
        SFP_MISSING_IN    => '0',
        SFP_LOS_IN        => sfp_los(i),
        SD_LINK_OK_IN     => link_ok_q(i),
        SD_LOS_IN         => link_error_q(i)(2),
        SD_TXCLK_BAD_IN   => tx_lane_reset, --ffs_plol,
        SD_RXCLK_BAD_IN   => link_error_q(i)(7),
        SD_RETRY_IN       => '0', -- '0' = handle byte swapping in logic, '1' = simply restart link and hope
        SD_ALIGNMENT_IN   => "10",
        SD_CV_IN(0)       => link_error_q(i)(1),
        SD_CV_IN(1)       => '0',
        FULL_RESET_OUT    => quad_rst(i),
        LANE_RESET_OUT    => lane_rst(i),
        TX_ALLOW_OUT      => tx_allow(i),
        RX_ALLOW_OUT      => rx_allow(i),
        SWAP_BYTES_OUT    => open,
        STAT_OP           => FSM_STAT_OP(i*16+15 downto i*16),
        CTRL_OP           => FSM_CTRL_OP(i*16+15 downto i*16),
        STAT_DEBUG        => FSM_STAT_DEBUG(i*32+31 downto i*32)
        );
  end generate;

  SFP_LOS     <= not sd_q;
  FSM_CTRL_OP <= CTRL_OP;


  
-----------------------------------------------------------------------
--Status & Debug
-----------------------------------------------------------------------
  gen_stat : for i in 0 to 3 generate
    STAT_OP(i*16+2 downto i*16+0)   <= med_state_i(i*3+2 downto i*3);
    STAT_OP(i*16+7 downto i*16+3)   <= FSM_STAT_OP(i*16+7 downto i*16+3);
    STAT_OP(i*16+8)  <= start_retransmit_i(i);
    STAT_OP(i*16+9)  <= FSM_STAT_OP(i*16+9);
    STAT_OP(i*16+10) <= rx_led(i);
    STAT_OP(i*16+11) <= tx_led(i);


    process(CLK)
      begin
        if rising_edge(CLK) then
          if CTRL_OP(i*16+8) = '1' then
            STAT_OP(i*16+12) <= request_retransmit_i(i);
          else
            STAT_OP(i*16+12) <= (link_error_q(i)(1) or packet_timeout(i))
                                 and not CTRL_OP(i*16+15) and not send_reset_words(i) and tx_allow(i);
          end if;
        end if;
      end process;
    STAT_OP(i*16+13) <= make_trbnet_reset(i);
    STAT_OP(i*16+14) <= FSM_STAT_OP(i*16+14);
    STAT_OP(i*16+15) <= send_reset_words(i);

    process(CLK)
      begin
        if rising_edge(CLK) then
          STAT_DEBUG(i*64+17 downto i*64+0)  <= FSM_STAT_DEBUG(i*32+17 downto i*32);
          STAT_DEBUG(i*64+25 downto i*64+18) <= rx_data(i*8+7 downto i*8);
          STAT_DEBUG(i*64+26)                <= rx_k(i);
          STAT_DEBUG(i*64+31 downto i*64+27) <= debug_txcontrol_i(i*32+4 downto i*32);
          STAT_DEBUG(i*64+63 downto i*64+32) <= debug_rxcontrol_i(i*32+31 downto i*32+0);
        end if;
      end process;

    STAT_REG_OUT(128*i+31 downto 128*i+0)   <= statreg_txcontrol_i(32*i+31 downto 32*i);
    STAT_REG_OUT(128*i+127 downto 128*i+32) <= statreg_rxcontrol_i(96*i+95 downto 96*i);

  end generate;




end architecture;


--   THE_FIFO_RX: trb_net_fifo_16bit_bram_dualport
--   generic map(
--     USE_STATUS_FLAGS => c_NO
--   )
--   port map(
--     read_clock_in             => clk,
--     write_clock_in            => CLK_25,
--     read_enable_in            => rx_fifo_read_en(i),
--     write_enable_in           => rx_fifo_write_en(i),
--     fifo_gsr_in               => fifo_reset(i),
--     write_data_in             => "00" & x"00" & rx_data_reg((i+1)*8-1 downto i*8),
--     read_data_out(7 downto 0) => rx_fifo_dout((i+1)*8-1 downto i*8),
--     full_out                  => rx_fifo_full(i),
--     empty_out                 => rx_fifo_empty(i)
--   );
--
--   THE_WRITE_RX_FIFO_PROC: process( CLK_25 )
--   begin
--     if( rising_edge(CLK_25) ) then
--       buf_rx_data((i+1)*8-1 downto i*8) <= rx_data((i+1)*8-1 downto i*8);
--       buf_rx_k(i) <= rx_k(i);
--       if( (reset = '1') or (rx_allow_qrx(i) = '0') ) then
--         rx_fifo_write_en(i) <= '0';
--         is_idle_word(i) <= '1';
--         rx_starting(i) <= '1';
--       else
--         rx_data_reg((i+1)*8-1 downto i*8) <= buf_rx_data((i+1)*8-1 downto i*8);
--         if( (buf_rx_k(i) = '0') and (is_idle_word(i) = '0') and (rx_starting(i) = '0') ) then
--           rx_fifo_write_en(i) <= '1';
--         else
--           rx_fifo_write_en(i) <= '0';
--         end if;
--         if   ( buf_rx_k(i) = '1' ) then
--           is_idle_word(i) <= '1';
--           rx_starting(i) <= '0';
--         elsif( (buf_rx_k(i) = '0') and (is_idle_word(i) = '1') ) then
--           is_idle_word(i) <= '0';
--         end if;
--       end if;
--     end if;
--   end process THE_WRITE_RX_FIFO_PROC;
--
--   THE_CNT_RESET_PROC : process( CLK_25 )
--   begin
--     if( rising_edge(CLK_25) ) then
--       if( reset = '1' ) then
--         send_reset_words(i)  <= '0';
--         make_trbnet_reset(i) <= '0';
--         reset_word_cnt(i*5+4 downto i*5) <= (others => '0');
--       else
--         send_reset_words(i)   <= '0';
--         make_trbnet_reset(i)  <= '0';
--         if( (buf_rx_data(i*8+7 downto i*8) = x"FE") and (buf_rx_k(i) = '1') ) then
--           if( reset_word_cnt(i*5+4) = '0' ) then
--             reset_word_cnt(i*5+4 downto i*5) <= reset_word_cnt(i*5+4 downto i*5) + 1;
--           else
--             send_reset_words(i) <= '1';
--           end if;
--         else
--           reset_word_cnt(i*5+4 downto i*5)    <= (others => '0');
--           make_trbnet_reset(i) <= reset_word_cnt(i*5+4);
--         end if;
--       end if;
--     end if;
--   end process;
-- --     RX Control (100)
-- --     -------------------
--   THE_RX_CTRL_PROC: process( clk )
--   begin
--     if( rising_edge(clk) ) then
--       if( reset = '1' ) then
--         buf_med_dataready_out(i) <= '0';
--         byte_select(i)           <= '0';
--         last_rx_fifo_read_en(i)  <= '0';
--       else
--         last_rx_fifo_read_en(i)      <= rx_fifo_read_en(i);
--         last_rx_fifo_empty(i)        <= rx_fifo_empty(i);
--         last_last_rx_fifo_read_en(i) <= last_rx_fifo_read_en(i);
--         last_last_rx_fifo_empty(i)   <= last_rx_fifo_empty(i);
--         last_rx_fifo_dout(i*8+7 downto i*8) <= rx_fifo_dout(i*8+7 downto i*8);
--         buf_med_dataready_out(i)     <= '0';
--         if( (last_last_rx_fifo_empty(i) = '0') and (last_last_rx_fifo_read_en(i) = '1') ) then
--           if( byte_select(i) = '1' ) then
--             buf_MED_DATA_OUT((i+1)*16-1 downto i*16) <= last_rx_fifo_dout((i+1)*8-1 downto i*8)
--                                                         & buf_MED_DATA_OUT(i*16+7 downto i*16);
--             buf_MED_DATAREADY_OUT(i) <= '1';
--           else
--             buf_MED_DATA_OUT((i+1)*16-1 downto i*16) <= x"00" & last_rx_fifo_dout((i+1)*8-1 downto i*8);
--           end if;
--           byte_select(i) <= not byte_select(i);
--         end if;
--       end if;
--     end if;
--   end process THE_RX_CTRL_PROC;
--
--   rx_fifo_read_en(i)                                           <= rx_allow_del(i) and not rx_fifo_empty(i);
--   MED_DATA_OUT((i+1)*16-1 downto i*16)                         <= buf_MED_DATA_OUT((i+1)*16-1 downto i*16);
--   MED_DATAREADY_OUT(i)                                         <= buf_MED_DATAREADY_OUT(i);
--   MED_PACKET_NUM_OUT((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= rx_counter((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH);
--
--   --rx packet counter
--   ---------------------
--   THE_RX_PACKETS_PROC: process( clk )
--   begin
--     if( rising_edge(clk) ) then
--       if( (reset = '1') or (rx_allow(i) = '0') ) then
--         rx_counter(i*3+2 downto i*3) <= c_H0;
--       else
--         if( buf_med_dataready_out(i) = '1' ) then
--           if( rx_counter(i*3+2 downto i*3) = c_max_word_number ) then
--             rx_counter(i*3+2 downto i*3) <= (others => '0');
--           else
--             rx_counter(i*3+2 downto i*3) <= rx_counter(i*3+2 downto i*3) + 1;
--           end if;
--         end if;
--       end if;
--     end if;
--   end process THE_RX_PACKETS_PROC;





--
--  THE_TX_FIFO: trb_net_fifo_16bit_bram_dualport
--  generic map(
--    USE_STATUS_FLAGS => c_NO
--  )
--  port map(
--    read_clock_in   => CLK_25,--ff_txfullclk,
--    write_clock_in  => CLK,
--    read_enable_in  => tx_fifo_read_en(i),
--    write_enable_in => tx_fifo_write_en(i),
--    fifo_gsr_in     => fifo_reset(i),
--    write_data_in   => "00" & tx_fifo_data_in((i+1)*16-1 downto i*16),
--    read_data_out(15 downto 0)    => tx_fifo_dout((i+1)*16-1 downto i*16),
--    full_out        => tx_fifo_full(i),
--    empty_out       => tx_fifo_empty(i)
--  );
--
--
--  THE_READ_TX_FIFO_PROC: process( CLK_25 )
--  begin
--    if( rising_edge(CLK_25) ) then
--      if( reset = '1' ) then
--        byte_waiting(i)               <= '0';
--        tx_fifo_read_en(i)            <= '0';
--        tx_k(i)                       <= '1';
--        tx_data((i+1)*8-1 downto i*8) <= x"FE";
--        tx_fifo_valid_read(i)         <= '0';
--      else
--        tx_fifo_read_en(i)      <= tx_allow_qtx(i);
--        tx_fifo_valid_read(i)   <= tx_fifo_read_en(i) and not tx_fifo_empty(i);
--        if( byte_waiting(i) = '0' ) then
--          if   ( tx_fifo_valid_read(i) = '1' ) then
--            byte_buffer((i+1)*8-1 downto i*8) <= tx_fifo_dout((i)*16+15 downto i*16+8);
--            byte_waiting(i)                   <= '1';
--            tx_k(i)                           <= '0';
--            tx_data((i+1)*8-1 downto i*8)     <= tx_fifo_dout(i*16+7 downto i*16+0);
--            tx_fifo_read_en(i)                <= tx_allow_qtx(i);
--          elsif( send_reset_q(i) = '1' ) then
--            byte_buffer((i+1)*8-1 downto i*8) <= x"FE";
--            byte_waiting(i)                   <= '1';
--            tx_k(i)                           <= '1';
--            tx_data((i+1)*8-1 downto i*8)     <= x"FE";
--            tx_fifo_read_en(i)                <= '0';
--          else
--            byte_buffer((i+1)*8-1 downto i*8) <= x"50";
--            byte_waiting(i)                   <= '1';
--            tx_k(i)                           <= '1';
--            tx_data((i+1)*8-1 downto i*8)     <= x"BC";
--            tx_fifo_read_en(i)                <= tx_allow_qtx(i);
--          end if;
--        else
--          tx_data((i+1)*8-1 downto i*8)       <= byte_buffer((i+1)*8-1 downto i*8);
--          tx_k(i)                             <= send_reset_q(i);  --second byte is always data
--          byte_waiting(i)                     <= '0';
--          tx_fifo_read_en(i)                  <= '0';
--        end if;
--      end if;
--    end if;
--  end process;
--
--  fifo_reset(i) <= reset or quad_rst(0) or not rx_allow(i); --(sync with SYSCLK)

--TX Control (100)
-- ---------------------
--     buf_med_read_out(i)                  <= not tx_fifo_full(i) and tx_allow_del(i);
--     tx_fifo_write_en(i)                  <= buf_med_read_out(i) and med_dataready_in(i);
--     tx_fifo_data_in(i*16+15 downto i*16) <= med_data_in(i*16+15 downto i*16);
--     med_read_out(i)                      <= buf_med_read_out(i);



--   TX_TO_CLK_SYNC: signal_sync
--     generic map(
--       DEPTH => 2,
--       WIDTH => 1
--       )
--     port map(
--       RESET    => reset,
--       D_IN(0)  => tx_fifo_valid_read(i),
--       CLK0     => CLK_25,
--       CLK1     => CLK,
--       D_OUT(0) => tx_fifo_valid_read_q(i)
--       );
--   THE_SFP_STATUS_SYNC: signal_sync
--     generic map(
--       DEPTH => 2,
--       WIDTH => 1
--       )
--     port map(
--       RESET    => RESET,
--       D_IN(0)  => rx_allow(i),
--       CLK0     => CLK,
--       CLK1     => CLK_25,
--       D_OUT(0) => rx_allow_qrx(i)
--       );