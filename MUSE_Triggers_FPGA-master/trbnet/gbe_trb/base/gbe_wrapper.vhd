library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_ARITH.all;
use IEEE.std_logic_UNSIGNED.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

use work.trb_net_gbe_components.all;
use work.trb_net_gbe_protocols.all;


entity gbe_wrapper is
	generic(
		DO_SIMULATION             : integer range 0 to 1         := 0;
		INCLUDE_DEBUG             : integer range 0 to 1         := 0;
		USE_INTERNAL_TRBNET_DUMMY : integer range 0 to 1         := 0;
		USE_EXTERNAL_TRBNET_DUMMY : integer range 0 to 1         := 0;
		RX_PATH_ENABLE            : integer range 0 to 1         := 1;
		FIXED_SIZE_MODE           : integer range 0 to 1         := 1;
		INCREMENTAL_MODE          : integer range 0 to 1         := 0;
		FIXED_SIZE                : integer range 0 to 65535     := 10;
		FIXED_DELAY_MODE          : integer range 0 to 1         := 1;
		UP_DOWN_MODE              : integer range 0 to 1         := 0;
		UP_DOWN_LIMIT             : integer range 0 to 16777215  := 0;
		FIXED_DELAY               : integer range 0 to 16777215  := 16777215;
		NUMBER_OF_GBE_LINKS       : integer range 1 to 4         := 4;
		LINKS_ACTIVE              : std_logic_vector(3 downto 0) := "1111";
		LINK_HAS_PING             : std_logic_vector(3 downto 0) := "1111";
		LINK_HAS_ARP              : std_logic_vector(3 downto 0) := "1111";
		LINK_HAS_DHCP             : std_logic_vector(3 downto 0) := "1111";
		LINK_HAS_READOUT          : std_logic_vector(3 downto 0) := "1111";
		LINK_HAS_SLOWCTRL         : std_logic_vector(3 downto 0) := "1111";
		LINK_HAS_FWD              : std_logic_vector(3 downto 0) := "1111"
	);
	port(
		CLK_SYS_IN               : in  std_logic;
		CLK_125_IN               : in  std_logic;
		RESET                    : in  std_logic;
		GSR_N                    : in  std_logic;
		SD_PRSNT_N_IN            : in  std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
		SD_LOS_IN                : in  std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0); -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
		SD_TXDIS_OUT             : out std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0); -- SFP disable

		TRIGGER_IN               : in  std_logic; -- for debug purpose only
		-- CTS interface
		CTS_NUMBER_IN            : in  std_logic_vector(15 downto 0);
		CTS_CODE_IN              : in  std_logic_vector(7 downto 0);
		CTS_INFORMATION_IN       : in  std_logic_vector(7 downto 0);
		CTS_READOUT_TYPE_IN      : in  std_logic_vector(3 downto 0);
		CTS_START_READOUT_IN     : in  std_logic;
		CTS_DATA_OUT             : out std_logic_vector(31 downto 0);
		CTS_DATAREADY_OUT        : out std_logic;
		CTS_READOUT_FINISHED_OUT : out std_logic;
		CTS_READ_IN              : in  std_logic;
		CTS_LENGTH_OUT           : out std_logic_vector(15 downto 0);
		CTS_ERROR_PATTERN_OUT    : out std_logic_vector(31 downto 0);
		-- Data payload interface
		FEE_DATA_IN              : in  std_logic_vector(15 downto 0);
		FEE_DATAREADY_IN         : in  std_logic;
		FEE_READ_OUT             : out std_logic;
		FEE_STATUS_BITS_IN       : in  std_logic_vector(31 downto 0);
		FEE_BUSY_IN              : in  std_logic;
		-- SlowControl
		MY_TRBNET_ADDRESS_IN	 : in std_logic_vector(15 downto 0);
		ISSUE_REBOOT_OUT : out std_logic;
		MC_UNIQUE_ID_IN          : in  std_logic_vector(63 downto 0);
		GSC_CLK_IN               : in  std_logic;
		GSC_INIT_DATAREADY_OUT   : out std_logic;
		GSC_INIT_DATA_OUT        : out std_logic_vector(15 downto 0);
		GSC_INIT_PACKET_NUM_OUT  : out std_logic_vector(2 downto 0);
		GSC_INIT_READ_IN         : in  std_logic;
		GSC_REPLY_DATAREADY_IN   : in  std_logic;
		GSC_REPLY_DATA_IN        : in  std_logic_vector(15 downto 0);
		GSC_REPLY_PACKET_NUM_IN  : in  std_logic_vector(2 downto 0);
		GSC_REPLY_READ_OUT       : out std_logic;
		GSC_BUSY_IN              : in  std_logic;
		-- IP configuration
		BUS_IP_RX                : in  CTRLBUS_RX;
		BUS_IP_TX                : out CTRLBUS_TX;
		-- Registers config
		BUS_REG_RX               : in  CTRLBUS_RX;
		BUS_REG_TX               : out CTRLBUS_TX;

-- Forwarder
    FWD_DST_MAC_IN : in	std_logic_vector(48 * NUMBER_OF_GBE_LINKS - 1 downto 0) := (others => '0');
    FWD_DST_IP_IN : in	std_logic_vector(32 * NUMBER_OF_GBE_LINKS - 1 downto 0) := (others => '0');
    FWD_DST_UDP_IN : in	std_logic_vector(16 * NUMBER_OF_GBE_LINKS - 1 downto 0) := (others => '0');
    FWD_DATA_IN : in std_logic_vector(NUMBER_OF_GBE_LINKS * 8 - 1 downto 0) := (others => '0');
    FWD_DATA_VALID_IN : in std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0) := (others => '0');
    FWD_SOP_IN : in std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0) := (others => '0');
    FWD_EOP_IN : in std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0) := (others => '0');
    FWD_READY_OUT : out std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
    FWD_FULL_OUT : out std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);

		MAKE_RESET_OUT           : out std_logic;
		DEBUG_OUT                : out std_logic_vector(127 downto 0)
	);
end entity gbe_wrapper;

architecture RTL of gbe_wrapper is
	signal mac_ready_conf  : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mac_reconf      : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mac_an_ready    : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mac_fifoavail   : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mac_fifoeof     : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mac_fifoempty   : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mac_rx_fifofull : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mac_tx_data     : std_logic_vector(NUMBER_OF_GBE_LINKS * 8 - 1 downto 0);
	signal mac_tx_read     : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mac_tx_discrfrm : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mac_tx_stat_en  : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mac_tx_stats    : std_logic_vector(NUMBER_OF_GBE_LINKS * 31 - 1 downto 0);
	signal mac_tx_done     : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mac_rx_fifo_err : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mac_rx_stats    : std_logic_vector(NUMBER_OF_GBE_LINKS * 32 - 1 downto 0);
	signal mac_rx_data     : std_logic_vector(NUMBER_OF_GBE_LINKS * 8 - 1 downto 0);
	signal mac_rx_write    : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mac_rx_stat_en  : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mac_rx_eof      : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mac_rx_err      : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);

	signal clk_125_from_pcs    : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal clk_125_rx_from_pcs : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);

	signal cfg_gbe_enable        : std_logic;
	signal cfg_ipu_enable        : std_logic;
	signal cfg_mult_enable       : std_logic;
	signal cfg_subevent_id       : std_logic_vector(31 downto 0);
	signal cfg_subevent_dec      : std_logic_vector(31 downto 0);
	signal cfg_queue_dec         : std_logic_vector(31 downto 0);
	signal cfg_readout_ctr       : std_logic_vector(23 downto 0);
	signal cfg_readout_ctr_valid : std_logic;
	signal cfg_insert_ttype      : std_logic;
	signal cfg_max_sub           : std_logic_vector(15 downto 0);
	signal cfg_max_queue         : std_logic_vector(15 downto 0);
	signal cfg_max_subs_in_queue : std_logic_vector(15 downto 0);
	signal cfg_max_single_sub    : std_logic_vector(15 downto 0);
	signal cfg_additional_hdr    : std_logic;
	signal cfg_soft_rst          : std_logic;
	signal cfg_allow_rx          : std_logic;
	signal cfg_max_frame         : std_logic_vector(15 downto 0);

	signal dbg_hist, dbg_hist2 : hist_array;

	signal mac_0, mac_1, mac_2, mac_3 : std_logic_vector(47 downto 0);
	signal cfg_max_reply              : std_logic_vector(31 downto 0);

	signal mlt_cts_number           : std_logic_vector(16 * NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_cts_code             : std_logic_vector(8 * NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_cts_information      : std_logic_vector(8 * NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_cts_readout_type     : std_logic_vector(4 * NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_cts_start_readout    : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_cts_data             : std_logic_vector(32 * NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_cts_dataready        : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_cts_readout_finished : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_cts_read             : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_cts_length           : std_logic_vector(16 * NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_cts_error_pattern    : std_logic_vector(32 * NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_fee_data             : std_logic_vector(16 * NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_fee_dataready        : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_fee_read             : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_fee_status           : std_logic_vector(32 * NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_fee_busy             : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);

	signal mlt_gsc_clk             : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_gsc_init_dataready  : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_gsc_init_data       : std_logic_vector(16 * NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_gsc_init_packet     : std_logic_vector(3 * NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_gsc_init_read       : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_gsc_reply_dataready : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_gsc_reply_data      : std_logic_vector(16 * NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_gsc_reply_packet    : std_logic_vector(3 * NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_gsc_reply_read      : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	signal mlt_gsc_busy            : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);

	signal local_cts_number                                                                                              : std_logic_vector(15 downto 0);
	signal local_cts_code                                                                                                : std_logic_vector(7 downto 0);
	signal local_cts_information                                                                                         : std_logic_vector(7 downto 0);
	signal local_cts_readout_type                                                                                        : std_logic_vector(3 downto 0);
	signal local_cts_start_readout                                                                                       : std_logic;
	signal local_cts_readout_finished                                                                                    : std_logic;
	signal local_cts_status_bits                                                                                         : std_logic_vector(31 downto 0);
	signal local_fee_data                                                                                                : std_logic_vector(15 downto 0);
	signal local_fee_dataready                                                                                           : std_logic;
	signal local_fee_read                                                                                                : std_logic;
	signal local_fee_status_bits                                                                                         : std_logic_vector(31 downto 0);
	signal local_fee_busy                                                                                                : std_logic;
	signal dhcp_done                                                                                                     : std_logic_vector(3 downto 0);
	signal all_links_ready                                                                                               : std_logic;
	signal monitor_rx_frames, monitor_rx_bytes, monitor_tx_frames, monitor_tx_bytes, monitor_tx_packets, monitor_dropped : std_logic_vector(4 * 32 - 1 downto 0);
	signal sum_rx_frames, sum_rx_bytes, sum_tx_frames, sum_tx_bytes, sum_tx_packets, sum_dropped                         : std_logic_vector(31 downto 0);

	signal busip0, busip1, busip2, busip3                       : CTRLBUS_TX;
	signal SD_RXD_P_IN, SD_RXD_N_IN, SD_TXD_P_OUT, SD_TXD_N_OUT : std_logic_vector(NUMBER_OF_GBE_LINKS - 1 downto 0);
	--attribute nopad : string;
	--attribute nopad of SD_RXD_P_IN, SD_RXD_N_IN, SD_TXD_P_OUT, SD_TXD_N_OUT : signal is "true";

	signal dummy_event                                        : std_logic_vector(15 downto 0);
	signal dummy_mode                                         : std_logic;
	signal make_reset0, make_reset1, make_reset2, make_reset3 : std_logic := '0';
	signal monitor_gen_dbg                                    : std_logic_vector(c_MAX_PROTOCOLS * 64 - 1 downto 0);

	signal cfg_autothrottle   : std_logic;
	signal cfg_throttle_pause : std_logic_vector(15 downto 0);
	
	signal issue_reboot : std_logic_vector(3 downto 0);

begin
	mac_impl_gen : if DO_SIMULATION = 0 generate
		mac_0 <= MC_UNIQUE_ID_IN(15 downto 8) & MC_UNIQUE_ID_IN(23 downto 16) & MC_UNIQUE_ID_IN(31 downto 24) & x"0" & MC_UNIQUE_ID_IN(35 downto 32) & x"7ada";
		mac_1 <= MC_UNIQUE_ID_IN(15 downto 8) & MC_UNIQUE_ID_IN(23 downto 16) & MC_UNIQUE_ID_IN(31 downto 24) & x"1" & MC_UNIQUE_ID_IN(35 downto 32) & x"7ada";
		mac_2 <= MC_UNIQUE_ID_IN(15 downto 8) & MC_UNIQUE_ID_IN(23 downto 16) & MC_UNIQUE_ID_IN(31 downto 24) & x"2" & MC_UNIQUE_ID_IN(35 downto 32) & x"7ada";
		mac_3 <= MC_UNIQUE_ID_IN(15 downto 8) & MC_UNIQUE_ID_IN(23 downto 16) & MC_UNIQUE_ID_IN(31 downto 24) & x"3" & MC_UNIQUE_ID_IN(35 downto 32) & x"7ada";
	end generate mac_impl_gen;

	mac_sim_gen : if DO_SIMULATION = 1 generate
		mac_0 <= x"ffffffffffff";
		mac_1 <= x"ffffffffffff";
		mac_2 <= x"ffffffffffff";
		mac_3 <= x"ffffffffffff";
	end generate mac_sim_gen;

	all_links_ready <= '1' when dhcp_done = x"f" else '0';

	MAKE_RESET_OUT <= '1' when make_reset3 = '1' or make_reset2 = '1' or make_reset1 = '1' or make_reset0 = '1' else '0';
	
	ISSUE_REBOOT_OUT <= '0' when issue_reboot = "0000" else '1';

	physical_impl_gen : if DO_SIMULATION = 0 generate
		physical : entity work.gbe_med_interface
			generic map(DO_SIMULATION       => DO_SIMULATION,
				        NUMBER_OF_GBE_LINKS => NUMBER_OF_GBE_LINKS,
				        LINKS_ACTIVE        => LINKS_ACTIVE)
			port map(
				RESET               => RESET,
				GSR_N               => GSR_N,
				CLK_SYS_IN          => CLK_SYS_IN,
				CLK_125_OUT         => clk_125_from_pcs,
				CLK_125_IN          => CLK_125_IN,
				CLK_125_RX_OUT      => clk_125_rx_from_pcs,
				MAC_READY_CONF_OUT  => mac_ready_conf,
				MAC_RECONF_IN       => mac_reconf,
				MAC_AN_READY_OUT    => mac_an_ready,
				MAC_FIFOAVAIL_IN    => mac_fifoavail,
				MAC_FIFOEOF_IN      => mac_fifoeof,
				MAC_FIFOEMPTY_IN    => mac_fifoempty,
				MAC_RX_FIFOFULL_IN  => mac_rx_fifofull,
				MAC_TX_DATA_IN      => mac_tx_data,
				MAC_TX_READ_OUT     => mac_tx_read,
				MAC_TX_DISCRFRM_OUT => mac_tx_discrfrm,
				MAC_TX_STAT_EN_OUT  => mac_tx_stat_en,
				MAC_TX_STATS_OUT    => mac_tx_stats,
				MAC_TX_DONE_OUT     => mac_tx_done,
				MAC_RX_FIFO_ERR_OUT => mac_rx_fifo_err,
				MAC_RX_STATS_OUT    => mac_rx_stats,
				MAC_RX_DATA_OUT     => mac_rx_data,
				MAC_RX_WRITE_OUT    => mac_rx_write,
				MAC_RX_STAT_EN_OUT  => mac_rx_stat_en,
				MAC_RX_EOF_OUT      => mac_rx_eof,
				MAC_RX_ERROR_OUT    => mac_rx_err,
				SD_RXD_P_IN         => SD_RXD_P_IN,
				SD_RXD_N_IN         => SD_RXD_N_IN,
				SD_TXD_P_OUT        => SD_TXD_P_OUT,
				SD_TXD_N_OUT        => SD_TXD_N_OUT,
				SD_PRSNT_N_IN       => SD_PRSNT_N_IN,
				SD_LOS_IN           => SD_LOS_IN,
				SD_TXDIS_OUT        => SD_TXDIS_OUT,
				DEBUG_OUT           => open
			);
	end generate physical_impl_gen;

	-- sfp8
	GEN_LINK_3 : if (LINKS_ACTIVE(3) = '1') generate
		gbe_inst3 : entity work.gbe_logic_wrapper
			generic map(DO_SIMULATION             => DO_SIMULATION,
				        INCLUDE_DEBUG             => INCLUDE_DEBUG,
				        USE_INTERNAL_TRBNET_DUMMY => USE_INTERNAL_TRBNET_DUMMY,
				        RX_PATH_ENABLE            => RX_PATH_ENABLE,
				        INCLUDE_READOUT           => LINK_HAS_READOUT(3),
				        INCLUDE_SLOWCTRL          => LINK_HAS_SLOWCTRL(3),
				        INCLUDE_DHCP              => LINK_HAS_DHCP(3),
				        INCLUDE_ARP               => LINK_HAS_ARP(3),
				        INCLUDE_PING              => LINK_HAS_PING(3),
                INCLUDE_FWD               => LINK_HAS_FWD(3),
				        FRAME_BUFFER_SIZE         => 1,
				        READOUT_BUFFER_SIZE       => 4,
				        SLOWCTRL_BUFFER_SIZE      => 2,
				        FIXED_SIZE_MODE           => FIXED_SIZE_MODE,
				        INCREMENTAL_MODE          => INCREMENTAL_MODE,
				        FIXED_SIZE                => FIXED_SIZE,
				        FIXED_DELAY_MODE          => FIXED_DELAY_MODE,
				        UP_DOWN_MODE              => UP_DOWN_MODE,
				        UP_DOWN_LIMIT             => UP_DOWN_LIMIT,
				        FIXED_DELAY               => FIXED_DELAY)
			port map(
				CLK_SYS_IN               => CLK_SYS_IN,
				CLK_125_IN               => CLK_125_IN,
				CLK_RX_125_IN            => clk_125_rx_from_pcs(3),
				RESET                    => RESET,
				GSR_N                    => GSR_N,
				MY_MAC_IN                => mac_3,
				DHCP_DONE_OUT            => dhcp_done(3),
				MY_TRBNET_ADDRESS_IN	 => MY_TRBNET_ADDRESS_IN,
				ISSUE_REBOOT_OUT		 => issue_reboot(3),
				MAC_READY_CONF_IN        => mac_ready_conf(3),
				MAC_RECONF_OUT           => mac_reconf(3),
				MAC_AN_READY_IN          => mac_an_ready(3),
				MAC_FIFOAVAIL_OUT        => mac_fifoavail(3),
				MAC_FIFOEOF_OUT          => mac_fifoeof(3),
				MAC_FIFOEMPTY_OUT        => mac_fifoempty(3),
				MAC_RX_FIFOFULL_OUT      => mac_rx_fifofull(3),
				MAC_TX_DATA_OUT          => mac_tx_data(4 * 8 - 1 downto 3 * 8),
				MAC_TX_READ_IN           => mac_tx_read(3),
				MAC_TX_DISCRFRM_IN       => mac_tx_discrfrm(3),
				MAC_TX_STAT_EN_IN        => mac_tx_stat_en(3),
				MAC_TX_STATS_IN          => mac_tx_stats(4 * 31 - 1 downto 3 * 31),
				MAC_TX_DONE_IN           => mac_tx_done(3),
				MAC_RX_FIFO_ERR_IN       => mac_rx_fifo_err(3),
				MAC_RX_STATS_IN          => mac_rx_stats(4 * 32 - 1 downto 3 * 32),
				MAC_RX_DATA_IN           => mac_rx_data(4 * 8 - 1 downto 3 * 8),
				MAC_RX_WRITE_IN          => mac_rx_write(3),
				MAC_RX_STAT_EN_IN        => mac_rx_stat_en(3),
				MAC_RX_EOF_IN            => mac_rx_eof(3),
				MAC_RX_ERROR_IN          => mac_rx_err(3),
				CTS_NUMBER_IN            => mlt_cts_number(4 * 16 - 1 downto 3 * 16),
				CTS_CODE_IN              => mlt_cts_code(4 * 8 - 1 downto 3 * 8),
				CTS_INFORMATION_IN       => mlt_cts_information(4 * 8 - 1 downto 3 * 8),
				CTS_READOUT_TYPE_IN      => mlt_cts_readout_type(4 * 4 - 1 downto 3 * 4),
				CTS_START_READOUT_IN     => mlt_cts_start_readout(3),
				CTS_DATA_OUT             => mlt_cts_data(4 * 32 - 1 downto 3 * 32),
				CTS_DATAREADY_OUT        => mlt_cts_dataready(3),
				CTS_READOUT_FINISHED_OUT => mlt_cts_readout_finished(3),
				CTS_READ_IN              => mlt_cts_read(3),
				CTS_LENGTH_OUT           => mlt_cts_length(4 * 16 - 1 downto 3 * 16),
				CTS_ERROR_PATTERN_OUT    => mlt_cts_error_pattern(4 * 32 - 1 downto 3 * 32),
				FEE_DATA_IN              => mlt_fee_data(4 * 16 - 1 downto 3 * 16),
				FEE_DATAREADY_IN         => mlt_fee_dataready(3),
				FEE_READ_OUT             => mlt_fee_read(3),
				FEE_STATUS_BITS_IN       => mlt_fee_status(4 * 32 - 1 downto 3 * 32),
				FEE_BUSY_IN              => mlt_fee_busy(3),
				GSC_CLK_IN               => mlt_gsc_clk(3),
				GSC_INIT_DATAREADY_OUT   => mlt_gsc_init_dataready(3),
				GSC_INIT_DATA_OUT        => mlt_gsc_init_data(4 * 16 - 1 downto 3 * 16),
				GSC_INIT_PACKET_NUM_OUT  => mlt_gsc_init_packet(4 * 3 - 1 downto 3 * 3),
				GSC_INIT_READ_IN         => mlt_gsc_init_read(3),
				GSC_REPLY_DATAREADY_IN   => mlt_gsc_reply_dataready(3),
				GSC_REPLY_DATA_IN        => mlt_gsc_reply_data(4 * 16 - 1 downto 3 * 16),
				GSC_REPLY_PACKET_NUM_IN  => mlt_gsc_reply_packet(4 * 3 - 1 downto 3 * 3),
				GSC_REPLY_READ_OUT       => mlt_gsc_reply_read(3),
				GSC_BUSY_IN              => mlt_gsc_busy(3),
				SLV_ADDR_IN              => BUS_IP_RX.addr(7 downto 0),
				SLV_READ_IN              => BUS_IP_RX.read,
				SLV_WRITE_IN             => BUS_IP_RX.write,
				SLV_BUSY_OUT             => busip3.nack,
				SLV_ACK_OUT              => busip3.ack,
				SLV_DATA_IN              => BUS_IP_RX.data,
				SLV_DATA_OUT             => busip3.data,
				CFG_GBE_ENABLE_IN        => cfg_gbe_enable,
				CFG_IPU_ENABLE_IN        => cfg_ipu_enable,
				CFG_MULT_ENABLE_IN       => cfg_mult_enable,
				CFG_MAX_FRAME_IN         => cfg_max_frame,
				CFG_ALLOW_RX_IN          => cfg_allow_rx,
				CFG_SOFT_RESET_IN        => cfg_soft_rst,
				CFG_SUBEVENT_ID_IN       => cfg_subevent_id,
				CFG_SUBEVENT_DEC_IN      => cfg_subevent_dec,
				CFG_QUEUE_DEC_IN         => cfg_queue_dec,
				CFG_READOUT_CTR_IN       => cfg_readout_ctr,
				CFG_READOUT_CTR_VALID_IN => cfg_readout_ctr_valid,
				CFG_INSERT_TTYPE_IN      => cfg_insert_ttype,
				CFG_MAX_SUB_IN           => cfg_max_sub,
				CFG_MAX_QUEUE_IN         => cfg_max_queue,
				CFG_MAX_SUBS_IN_QUEUE_IN => cfg_max_subs_in_queue,
				CFG_MAX_SINGLE_SUB_IN    => cfg_max_single_sub,
				CFG_ADDITIONAL_HDR_IN    => cfg_additional_hdr,
				CFG_MAX_REPLY_SIZE_IN    => cfg_max_reply,
				CFG_AUTO_THROTTLE_IN     => cfg_autothrottle,
				CFG_THROTTLE_PAUSE_IN    => cfg_throttle_pause,

        FWD_DST_MAC_IN => FWD_DST_MAC_IN(4 * 48 - 1 downto 3 * 48),
        FWD_DST_IP_IN => FWD_DST_IP_IN(4 * 32 - 1 downto 3 * 32),
        FWD_DST_UDP_IN => FWD_DST_UDP_IN(4 * 16 - 1 downto 3 * 16),
        FWD_DATA_IN => FWD_DATA_IN(4 * 8 - 1 downto 3 * 8),
        FWD_DATA_VALID_IN => FWD_DATA_VALID_IN(3),
        FWD_SOP_IN => FWD_SOP_IN(3),
        FWD_EOP_IN => FWD_EOP_IN(3),
        FWD_READY_OUT => FWD_READY_OUT(3),
        FWD_FULL_OUT => FWD_FULL_OUT(3),

				MONITOR_RX_FRAMES_OUT    => monitor_rx_frames(4 * 32 - 1 downto 3 * 32),
				MONITOR_RX_BYTES_OUT     => monitor_rx_bytes(4 * 32 - 1 downto 3 * 32),
				MONITOR_TX_FRAMES_OUT    => monitor_tx_frames(4 * 32 - 1 downto 3 * 32),
				MONITOR_TX_BYTES_OUT     => monitor_tx_bytes(4 * 32 - 1 downto 3 * 32),
				MONITOR_TX_PACKETS_OUT   => monitor_tx_packets(4 * 32 - 1 downto 3 * 32),
				MONITOR_DROPPED_OUT      => monitor_dropped(4 * 32 - 1 downto 3 * 32),
				MONITOR_GEN_DBG_OUT      => monitor_gen_dbg,
				MAKE_RESET_OUT           => make_reset3
			);
	end generate GEN_LINK_3;

	NO_LINK3_GEN : if (LINKS_ACTIVE(3) = '0') generate
		make_reset3 <= '0';
		busip3.data <= (others => '0');
		busip3.ack  <= '0';
		busip3.nack <= '0';
		monitor_rx_frames(4 * 32 - 1 downto 3 * 32) <= (others => '0');
    monitor_rx_bytes(4 * 32 - 1 downto 3 * 32) <= (others => '0');
    monitor_tx_frames(4 * 32 - 1 downto 3 * 32) <= (others => '0');
    monitor_tx_bytes(4 * 32 - 1 downto 3 * 32) <= (others => '0');
    monitor_tx_packets(4 * 32 - 1 downto 3 * 32) <= (others => '0');
    monitor_dropped(4 * 32 - 1 downto 3 * 32) <= (others => '0');
    monitor_gen_dbg  <= (others => '0');
    make_reset3 <= '0';
    FWD_READY_OUT(3) <= '0';
    FWD_FULL_OUT(3) <= '1';
    mlt_cts_data(4 * 32 - 1 downto 3 * 32) <= (others => '0');
    mlt_cts_dataready(3) <= '0';
    mlt_cts_readout_finished(3) <= '0';
    mlt_cts_length(4 * 16 - 1 downto 3 * 16) <= (others => '0');
    mlt_cts_error_pattern(4 * 32 - 1 downto 3 * 32) <= (others => '0');
	end generate NO_LINK3_GEN;

	-- sfp7
	GEN_LINK_2 : if (LINKS_ACTIVE(2) = '1') generate
		gbe_inst2 : entity work.gbe_logic_wrapper
			generic map(DO_SIMULATION             => DO_SIMULATION,
				        INCLUDE_DEBUG             => INCLUDE_DEBUG,
				        USE_INTERNAL_TRBNET_DUMMY => USE_INTERNAL_TRBNET_DUMMY,
				        RX_PATH_ENABLE            => 1,
				        INCLUDE_READOUT           => LINK_HAS_READOUT(2),
				        INCLUDE_SLOWCTRL          => LINK_HAS_SLOWCTRL(2),
				        INCLUDE_DHCP              => LINK_HAS_DHCP(2),
				        INCLUDE_ARP               => LINK_HAS_ARP(2),
				        INCLUDE_PING              => LINK_HAS_PING(2),
					INCLUDE_FWD               => LINK_HAS_FWD(2),
				        FRAME_BUFFER_SIZE         => 1,
				        READOUT_BUFFER_SIZE       => 4,
				        SLOWCTRL_BUFFER_SIZE      => 2,
				        FIXED_SIZE_MODE           => FIXED_SIZE_MODE,
				        INCREMENTAL_MODE          => INCREMENTAL_MODE,
				        FIXED_SIZE                => FIXED_SIZE,
				        FIXED_DELAY_MODE          => FIXED_DELAY_MODE,
				        UP_DOWN_MODE              => UP_DOWN_MODE,
				        UP_DOWN_LIMIT             => UP_DOWN_LIMIT,
				        FIXED_DELAY               => FIXED_DELAY)
			port map(
				CLK_SYS_IN               => CLK_SYS_IN,
				CLK_125_IN               => CLK_125_IN,
				CLK_RX_125_IN            => clk_125_rx_from_pcs(2),
				RESET                    => RESET,
				GSR_N                    => GSR_N,
				MY_MAC_IN                => mac_2,
				DHCP_DONE_OUT            => dhcp_done(2),
				MY_TRBNET_ADDRESS_IN	 => MY_TRBNET_ADDRESS_IN,
				ISSUE_REBOOT_OUT		 => issue_reboot(2),
				MAC_READY_CONF_IN        => mac_ready_conf(2),
				MAC_RECONF_OUT           => mac_reconf(2),
				MAC_AN_READY_IN          => mac_an_ready(2),
				MAC_FIFOAVAIL_OUT        => mac_fifoavail(2),
				MAC_FIFOEOF_OUT          => mac_fifoeof(2),
				MAC_FIFOEMPTY_OUT        => mac_fifoempty(2),
				MAC_RX_FIFOFULL_OUT      => mac_rx_fifofull(2),
				MAC_TX_DATA_OUT          => mac_tx_data(3 * 8 - 1 downto 2 * 8),
				MAC_TX_READ_IN           => mac_tx_read(2),
				MAC_TX_DISCRFRM_IN       => mac_tx_discrfrm(2),
				MAC_TX_STAT_EN_IN        => mac_tx_stat_en(2),
				MAC_TX_STATS_IN          => mac_tx_stats(3 * 31 - 1 downto 2 * 31),
				MAC_TX_DONE_IN           => mac_tx_done(2),
				MAC_RX_FIFO_ERR_IN       => mac_rx_fifo_err(2),
				MAC_RX_STATS_IN          => mac_rx_stats(3 * 32 - 1 downto 2 * 32),
				MAC_RX_DATA_IN           => mac_rx_data(3 * 8 - 1 downto 2 * 8),
				MAC_RX_WRITE_IN          => mac_rx_write(2),
				MAC_RX_STAT_EN_IN        => mac_rx_stat_en(2),
				MAC_RX_EOF_IN            => mac_rx_eof(2),
				MAC_RX_ERROR_IN          => mac_rx_err(2),
				CTS_NUMBER_IN            => mlt_cts_number(3 * 16 - 1 downto 2 * 16),
				CTS_CODE_IN              => mlt_cts_code(3 * 8 - 1 downto 2 * 8),
				CTS_INFORMATION_IN       => mlt_cts_information(3 * 8 - 1 downto 2 * 8),
				CTS_READOUT_TYPE_IN      => mlt_cts_readout_type(3 * 4 - 1 downto 2 * 4),
				CTS_START_READOUT_IN     => mlt_cts_start_readout(2),
				CTS_DATA_OUT             => mlt_cts_data(3 * 32 - 1 downto 2 * 32),
				CTS_DATAREADY_OUT        => mlt_cts_dataready(2),
				CTS_READOUT_FINISHED_OUT => mlt_cts_readout_finished(2),
				CTS_READ_IN              => mlt_cts_read(2),
				CTS_LENGTH_OUT           => mlt_cts_length(3 * 16 - 1 downto 2 * 16),
				CTS_ERROR_PATTERN_OUT    => mlt_cts_error_pattern(3 * 32 - 1 downto 2 * 32),
				FEE_DATA_IN              => mlt_fee_data(3 * 16 - 1 downto 2 * 16),
				FEE_DATAREADY_IN         => mlt_fee_dataready(2),
				FEE_READ_OUT             => mlt_fee_read(2),
				FEE_STATUS_BITS_IN       => mlt_fee_status(3 * 32 - 1 downto 2 * 32),
				FEE_BUSY_IN              => mlt_fee_busy(2),
				GSC_CLK_IN               => mlt_gsc_clk(2),
				GSC_INIT_DATAREADY_OUT   => mlt_gsc_init_dataready(2),
				GSC_INIT_DATA_OUT        => mlt_gsc_init_data(3 * 16 - 1 downto 2 * 16),
				GSC_INIT_PACKET_NUM_OUT  => mlt_gsc_init_packet(3 * 3 - 1 downto 2 * 3),
				GSC_INIT_READ_IN         => mlt_gsc_init_read(2),
				GSC_REPLY_DATAREADY_IN   => mlt_gsc_reply_dataready(2),
				GSC_REPLY_DATA_IN        => mlt_gsc_reply_data(3 * 16 - 1 downto 2 * 16),
				GSC_REPLY_PACKET_NUM_IN  => mlt_gsc_reply_packet(3 * 3 - 1 downto 2 * 3),
				GSC_REPLY_READ_OUT       => mlt_gsc_reply_read(2),
				GSC_BUSY_IN              => mlt_gsc_busy(2),
				SLV_ADDR_IN              => BUS_IP_RX.addr(7 downto 0),
				SLV_READ_IN              => BUS_IP_RX.read,
				SLV_WRITE_IN             => BUS_IP_RX.write,
				SLV_BUSY_OUT             => busip2.nack,
				SLV_ACK_OUT              => busip2.ack,
				SLV_DATA_IN              => BUS_IP_RX.data,
				SLV_DATA_OUT             => busip2.data,
				CFG_GBE_ENABLE_IN        => cfg_gbe_enable,
				CFG_IPU_ENABLE_IN        => cfg_ipu_enable,
				CFG_MULT_ENABLE_IN       => cfg_mult_enable,
				CFG_MAX_FRAME_IN         => cfg_max_frame,
				CFG_ALLOW_RX_IN          => cfg_allow_rx,
				CFG_SOFT_RESET_IN        => cfg_soft_rst,
				CFG_SUBEVENT_ID_IN       => cfg_subevent_id,
				CFG_SUBEVENT_DEC_IN      => cfg_subevent_dec,
				CFG_QUEUE_DEC_IN         => cfg_queue_dec,
				CFG_READOUT_CTR_IN       => cfg_readout_ctr,
				CFG_READOUT_CTR_VALID_IN => cfg_readout_ctr_valid,
				CFG_INSERT_TTYPE_IN      => cfg_insert_ttype,
				CFG_MAX_SUB_IN           => cfg_max_sub,
				CFG_MAX_QUEUE_IN         => cfg_max_queue,
				CFG_MAX_SUBS_IN_QUEUE_IN => cfg_max_subs_in_queue,
				CFG_MAX_SINGLE_SUB_IN    => cfg_max_single_sub,
				CFG_ADDITIONAL_HDR_IN    => cfg_additional_hdr,
				CFG_MAX_REPLY_SIZE_IN    => cfg_max_reply,
				CFG_AUTO_THROTTLE_IN     => cfg_autothrottle,
				CFG_THROTTLE_PAUSE_IN    => cfg_throttle_pause,
FWD_DST_MAC_IN => FWD_DST_MAC_IN(3 * 48 - 1 downto 2 * 48),
FWD_DST_IP_IN => FWD_DST_IP_IN(3 * 32 - 1 downto 2 * 32),
FWD_DST_UDP_IN => FWD_DST_UDP_IN(3 * 16 - 1 downto 2 * 16),
FWD_DATA_IN => FWD_DATA_IN(3 * 8 - 1 downto 2 * 8),
FWD_DATA_VALID_IN => FWD_DATA_VALID_IN(2),
FWD_SOP_IN => FWD_SOP_IN(2),
FWD_EOP_IN => FWD_EOP_IN(2),
FWD_READY_OUT => FWD_READY_OUT(2),
FWD_FULL_OUT => FWD_FULL_OUT(2),

				MONITOR_RX_FRAMES_OUT    => monitor_rx_frames(3 * 32 - 1 downto 2 * 32),
				MONITOR_RX_BYTES_OUT     => monitor_rx_bytes(3 * 32 - 1 downto 2 * 32),
				MONITOR_TX_FRAMES_OUT    => monitor_tx_frames(3 * 32 - 1 downto 2 * 32),
				MONITOR_TX_BYTES_OUT     => monitor_tx_bytes(3 * 32 - 1 downto 2 * 32),
				MONITOR_TX_PACKETS_OUT   => monitor_tx_packets(3 * 32 - 1 downto 2 * 32),
				MONITOR_DROPPED_OUT      => monitor_dropped(3 * 32 - 1 downto 2 * 32),
				MONITOR_GEN_DBG_OUT      => open,
				MAKE_RESET_OUT           => make_reset2
			);
	end generate GEN_LINK_2;

	NO_LINK2_GEN : if (LINKS_ACTIVE(2) = '0') generate
		make_reset2 <= '0';
		busip2.data <= (others => '0');
		busip2.ack  <= '0';
		busip2.nack <= '0';
		
		monitor_rx_frames(3 * 32 - 1 downto 2 * 32) <= (others => '0');
    monitor_rx_bytes(3 * 32 - 1 downto 2 * 32) <= (others => '0');
    monitor_tx_frames(3 * 32 - 1 downto 2 * 32) <= (others => '0');
    monitor_tx_bytes(3 * 32 - 1 downto 2 * 32) <= (others => '0');
    monitor_tx_packets(3 * 32 - 1 downto 2 * 32) <= (others => '0');
    monitor_dropped(3 * 32 - 1 downto 2 * 32) <= (others => '0');
    monitor_gen_dbg  <= (others => '0');
    make_reset2 <= '0';
    FWD_READY_OUT(2) <= '0';
    FWD_FULL_OUT(2) <= '1';
    mlt_cts_data(3 * 32 - 1 downto 2 * 32) <= (others => '0');
    mlt_cts_dataready(2) <= '0';
    mlt_cts_readout_finished(2) <= '0';
    mlt_cts_length(3 * 16 - 1 downto 2 * 16) <= (others => '0');
    mlt_cts_error_pattern(3 * 32 - 1 downto 2 * 32) <= (others => '0');		
	end generate NO_LINK2_GEN;

	-- sfp6
	GEN_LINK_1 : if (LINKS_ACTIVE(1) = '1') generate
		gbe_inst1 : entity work.gbe_logic_wrapper
			generic map(DO_SIMULATION             => DO_SIMULATION,
				        INCLUDE_DEBUG             => INCLUDE_DEBUG,
				        USE_INTERNAL_TRBNET_DUMMY => USE_INTERNAL_TRBNET_DUMMY,
				        RX_PATH_ENABLE            => 1,
				        INCLUDE_READOUT           => LINK_HAS_READOUT(1),
				        INCLUDE_SLOWCTRL          => LINK_HAS_SLOWCTRL(1),
				        INCLUDE_DHCP              => LINK_HAS_DHCP(1),
				        INCLUDE_ARP               => LINK_HAS_ARP(1),
				        INCLUDE_PING              => LINK_HAS_PING(1),
					INCLUDE_FWD               => LINK_HAS_FWD(1),
				        FRAME_BUFFER_SIZE         => 1,
				        READOUT_BUFFER_SIZE       => 4,
				        SLOWCTRL_BUFFER_SIZE      => 2,
				        FIXED_SIZE_MODE           => FIXED_SIZE_MODE,
				        INCREMENTAL_MODE          => INCREMENTAL_MODE,
				        FIXED_SIZE                => FIXED_SIZE,
				        FIXED_DELAY_MODE          => FIXED_DELAY_MODE,
				        UP_DOWN_MODE              => UP_DOWN_MODE,
				        UP_DOWN_LIMIT             => UP_DOWN_LIMIT,
				        FIXED_DELAY               => FIXED_DELAY)
			port map(
				CLK_SYS_IN               => CLK_SYS_IN,
				CLK_125_IN               => CLK_125_IN,
				CLK_RX_125_IN            => clk_125_rx_from_pcs(1),
				RESET                    => RESET,
				GSR_N                    => GSR_N,
				MY_MAC_IN                => mac_1,
				DHCP_DONE_OUT            => dhcp_done(1),
				MY_TRBNET_ADDRESS_IN	 => MY_TRBNET_ADDRESS_IN,
				ISSUE_REBOOT_OUT		 => issue_reboot(1),
				MAC_READY_CONF_IN        => mac_ready_conf(1),
				MAC_RECONF_OUT           => mac_reconf(1),
				MAC_AN_READY_IN          => mac_an_ready(1),
				MAC_FIFOAVAIL_OUT        => mac_fifoavail(1),
				MAC_FIFOEOF_OUT          => mac_fifoeof(1),
				MAC_FIFOEMPTY_OUT        => mac_fifoempty(1),
				MAC_RX_FIFOFULL_OUT      => mac_rx_fifofull(1),
				MAC_TX_DATA_OUT          => mac_tx_data(2 * 8 - 1 downto 1 * 8),
				MAC_TX_READ_IN           => mac_tx_read(1),
				MAC_TX_DISCRFRM_IN       => mac_tx_discrfrm(1),
				MAC_TX_STAT_EN_IN        => mac_tx_stat_en(1),
				MAC_TX_STATS_IN          => mac_tx_stats(2 * 31 - 1 downto 1 * 31),
				MAC_TX_DONE_IN           => mac_tx_done(1),
				MAC_RX_FIFO_ERR_IN       => mac_rx_fifo_err(1),
				MAC_RX_STATS_IN          => mac_rx_stats(2 * 32 - 1 downto 1 * 32),
				MAC_RX_DATA_IN           => mac_rx_data(2 * 8 - 1 downto 1 * 8),
				MAC_RX_WRITE_IN          => mac_rx_write(1),
				MAC_RX_STAT_EN_IN        => mac_rx_stat_en(1),
				MAC_RX_EOF_IN            => mac_rx_eof(1),
				MAC_RX_ERROR_IN          => mac_rx_err(1),
				CTS_NUMBER_IN            => mlt_cts_number(2 * 16 - 1 downto 1 * 16),
				CTS_CODE_IN              => mlt_cts_code(2 * 8 - 1 downto 1 * 8),
				CTS_INFORMATION_IN       => mlt_cts_information(2 * 8 - 1 downto 1 * 8),
				CTS_READOUT_TYPE_IN      => mlt_cts_readout_type(2 * 4 - 1 downto 1 * 4),
				CTS_START_READOUT_IN     => mlt_cts_start_readout(1),
				CTS_DATA_OUT             => mlt_cts_data(2 * 32 - 1 downto 1 * 32),
				CTS_DATAREADY_OUT        => mlt_cts_dataready(1),
				CTS_READOUT_FINISHED_OUT => mlt_cts_readout_finished(1),
				CTS_READ_IN              => mlt_cts_read(1),
				CTS_LENGTH_OUT           => mlt_cts_length(2 * 16 - 1 downto 1 * 16),
				CTS_ERROR_PATTERN_OUT    => mlt_cts_error_pattern(2 * 32 - 1 downto 1 * 32),
				FEE_DATA_IN              => mlt_fee_data(2 * 16 - 1 downto 1 * 16),
				FEE_DATAREADY_IN         => mlt_fee_dataready(1),
				FEE_READ_OUT             => mlt_fee_read(1),
				FEE_STATUS_BITS_IN       => mlt_fee_status(2 * 32 - 1 downto 1 * 32),
				FEE_BUSY_IN              => mlt_fee_busy(1),
				GSC_CLK_IN               => mlt_gsc_clk(1),
				GSC_INIT_DATAREADY_OUT   => mlt_gsc_init_dataready(1),
				GSC_INIT_DATA_OUT        => mlt_gsc_init_data(2 * 16 - 1 downto 1 * 16),
				GSC_INIT_PACKET_NUM_OUT  => mlt_gsc_init_packet(2 * 3 - 1 downto 1 * 3),
				GSC_INIT_READ_IN         => mlt_gsc_init_read(1),
				GSC_REPLY_DATAREADY_IN   => mlt_gsc_reply_dataready(1),
				GSC_REPLY_DATA_IN        => mlt_gsc_reply_data(2 * 16 - 1 downto 1 * 16),
				GSC_REPLY_PACKET_NUM_IN  => mlt_gsc_reply_packet(2 * 3 - 1 downto 1 * 3),
				GSC_REPLY_READ_OUT       => mlt_gsc_reply_read(1),
				GSC_BUSY_IN              => mlt_gsc_busy(1),
				SLV_ADDR_IN              => BUS_IP_RX.addr(7 downto 0),
				SLV_READ_IN              => BUS_IP_RX.read,
				SLV_WRITE_IN             => BUS_IP_RX.write,
				SLV_BUSY_OUT             => busip1.nack,
				SLV_ACK_OUT              => busip1.ack,
				SLV_DATA_IN              => BUS_IP_RX.data,
				SLV_DATA_OUT             => busip1.data,
				CFG_GBE_ENABLE_IN        => cfg_gbe_enable,
				CFG_IPU_ENABLE_IN        => cfg_ipu_enable,
				CFG_MULT_ENABLE_IN       => cfg_mult_enable,
				CFG_MAX_FRAME_IN         => cfg_max_frame,
				CFG_ALLOW_RX_IN          => cfg_allow_rx,
				CFG_SOFT_RESET_IN        => cfg_soft_rst,
				CFG_SUBEVENT_ID_IN       => cfg_subevent_id,
				CFG_SUBEVENT_DEC_IN      => cfg_subevent_dec,
				CFG_QUEUE_DEC_IN         => cfg_queue_dec,
				CFG_READOUT_CTR_IN       => cfg_readout_ctr,
				CFG_READOUT_CTR_VALID_IN => cfg_readout_ctr_valid,
				CFG_INSERT_TTYPE_IN      => cfg_insert_ttype,
				CFG_MAX_SUB_IN           => cfg_max_sub,
				CFG_MAX_QUEUE_IN         => cfg_max_queue,
				CFG_MAX_SUBS_IN_QUEUE_IN => cfg_max_subs_in_queue,
				CFG_MAX_SINGLE_SUB_IN    => cfg_max_single_sub,
				CFG_ADDITIONAL_HDR_IN    => cfg_additional_hdr,
				CFG_MAX_REPLY_SIZE_IN    => cfg_max_reply,
				CFG_AUTO_THROTTLE_IN     => cfg_autothrottle,
				CFG_THROTTLE_PAUSE_IN    => cfg_throttle_pause,

FWD_DST_MAC_IN => FWD_DST_MAC_IN(2 * 48 - 1 downto 1 * 48),
FWD_DST_IP_IN => FWD_DST_IP_IN(2 * 32 - 1 downto 1 * 32),
FWD_DST_UDP_IN => FWD_DST_UDP_IN(2 * 16 - 1 downto 1 * 16),
FWD_DATA_IN => FWD_DATA_IN(2 * 8 - 1 downto 1 * 8),
FWD_DATA_VALID_IN => FWD_DATA_VALID_IN(1),
FWD_SOP_IN => FWD_SOP_IN(1),
FWD_EOP_IN => FWD_EOP_IN(1),
FWD_READY_OUT => FWD_READY_OUT(1),
FWD_FULL_OUT => FWD_FULL_OUT(1),

				MONITOR_RX_FRAMES_OUT    => monitor_rx_frames(2 * 32 - 1 downto 1 * 32),
				MONITOR_RX_BYTES_OUT     => monitor_rx_bytes(2 * 32 - 1 downto 1 * 32),
				MONITOR_TX_FRAMES_OUT    => monitor_tx_frames(2 * 32 - 1 downto 1 * 32),
				MONITOR_TX_BYTES_OUT     => monitor_tx_bytes(2 * 32 - 1 downto 1 * 32),
				MONITOR_TX_PACKETS_OUT   => monitor_tx_packets(2 * 32 - 1 downto 1 * 32),
				MONITOR_DROPPED_OUT      => monitor_dropped(2 * 32 - 1 downto 1 * 32),
				MONITOR_GEN_DBG_OUT      => open,
				MAKE_RESET_OUT           => make_reset1
			);
	end generate GEN_LINK_1;

	NO_LINK1_GEN : if (LINKS_ACTIVE(1) = '0') generate
		make_reset1 <= '0';
		busip1.data <= (others => '0');
		busip1.ack  <= '0';
		busip1.nack <= '0';
		
		monitor_rx_frames(2 * 32 - 1 downto 1 * 32) <= (others => '0');
    monitor_rx_bytes(2 * 32 - 1 downto 1 * 32) <= (others => '0');
    monitor_tx_frames(2 * 32 - 1 downto 1 * 32) <= (others => '0');
    monitor_tx_bytes(2 * 32 - 1 downto 1 * 32) <= (others => '0');
    monitor_tx_packets(2 * 32 - 1 downto 1 * 32) <= (others => '0');
    monitor_dropped(2 * 32 - 1 downto 1 * 32) <= (others => '0');
    monitor_gen_dbg  <= (others => '0');
    make_reset1 <= '0';
    FWD_READY_OUT(1) <= '0';
    FWD_FULL_OUT(1) <= '1';
    mlt_cts_data(2 * 32 - 1 downto 1 * 32) <= (others => '0');
    mlt_cts_dataready(1) <= '0';
    mlt_cts_readout_finished(1) <= '0';
    mlt_cts_length(2 * 16 - 1 downto 1 * 16) <= (others => '0');
    mlt_cts_error_pattern(2 * 32 - 1 downto 1 * 32) <= (others => '0');		
	end generate NO_LINK1_GEN;

	-- sfp5
	GEN_LINK_0 : if (LINKS_ACTIVE(0) = '1') generate
		gbe_inst0 : entity work.gbe_logic_wrapper
			generic map(DO_SIMULATION             => DO_SIMULATION,
				        INCLUDE_DEBUG             => INCLUDE_DEBUG,
				        USE_INTERNAL_TRBNET_DUMMY => USE_INTERNAL_TRBNET_DUMMY,
				        RX_PATH_ENABLE            => 1,
				        INCLUDE_READOUT           => LINK_HAS_READOUT(0),
				        INCLUDE_SLOWCTRL          => LINK_HAS_SLOWCTRL(0),
				        INCLUDE_DHCP              => LINK_HAS_DHCP(0),
				        INCLUDE_ARP               => LINK_HAS_ARP(0),
				        INCLUDE_PING              => LINK_HAS_PING(0),
					INCLUDE_FWD               => LINK_HAS_FWD(0),
				        FRAME_BUFFER_SIZE         => 1,
				        READOUT_BUFFER_SIZE       => 4,
				        SLOWCTRL_BUFFER_SIZE      => 2,
				        FIXED_SIZE_MODE           => FIXED_SIZE_MODE,
				        INCREMENTAL_MODE          => INCREMENTAL_MODE,
				        FIXED_SIZE                => FIXED_SIZE,
				        FIXED_DELAY_MODE          => FIXED_DELAY_MODE,
				        UP_DOWN_MODE              => UP_DOWN_MODE,
				        UP_DOWN_LIMIT             => UP_DOWN_LIMIT,
				        FIXED_DELAY               => FIXED_DELAY)
			port map(
				CLK_SYS_IN               => CLK_SYS_IN,
				CLK_125_IN               => CLK_125_IN,
				CLK_RX_125_IN            => clk_125_rx_from_pcs(0),
				RESET                    => RESET,
				GSR_N                    => GSR_N,
				MY_MAC_IN                => mac_0,
				DHCP_DONE_OUT            => dhcp_done(0),
				MY_TRBNET_ADDRESS_IN	 => MY_TRBNET_ADDRESS_IN,
				ISSUE_REBOOT_OUT		 => issue_reboot(0),
				MAC_READY_CONF_IN        => mac_ready_conf(0),
				MAC_RECONF_OUT           => mac_reconf(0),
				MAC_AN_READY_IN          => mac_an_ready(0),
				MAC_FIFOAVAIL_OUT        => mac_fifoavail(0),
				MAC_FIFOEOF_OUT          => mac_fifoeof(0),
				MAC_FIFOEMPTY_OUT        => mac_fifoempty(0),
				MAC_RX_FIFOFULL_OUT      => mac_rx_fifofull(0),
				MAC_TX_DATA_OUT          => mac_tx_data(1 * 8 - 1 downto 0 * 8),
				MAC_TX_READ_IN           => mac_tx_read(0),
				MAC_TX_DISCRFRM_IN       => mac_tx_discrfrm(0),
				MAC_TX_STAT_EN_IN        => mac_tx_stat_en(0),
				MAC_TX_STATS_IN          => mac_tx_stats(1 * 31 - 1 downto 0 * 31),
				MAC_TX_DONE_IN           => mac_tx_done(0),
				MAC_RX_FIFO_ERR_IN       => mac_rx_fifo_err(0),
				MAC_RX_STATS_IN          => mac_rx_stats(1 * 32 - 1 downto 0 * 32),
				MAC_RX_DATA_IN           => mac_rx_data(1 * 8 - 1 downto 0 * 8),
				MAC_RX_WRITE_IN          => mac_rx_write(0),
				MAC_RX_STAT_EN_IN        => mac_rx_stat_en(0),
				MAC_RX_EOF_IN            => mac_rx_eof(0),
				MAC_RX_ERROR_IN          => mac_rx_err(0),
				CTS_NUMBER_IN            => mlt_cts_number(1 * 16 - 1 downto 0 * 16),
				CTS_CODE_IN              => mlt_cts_code(1 * 8 - 1 downto 0 * 8),
				CTS_INFORMATION_IN       => mlt_cts_information(1 * 8 - 1 downto 0 * 8),
				CTS_READOUT_TYPE_IN      => mlt_cts_readout_type(1 * 4 - 1 downto 0 * 4),
				CTS_START_READOUT_IN     => mlt_cts_start_readout(0),
				CTS_DATA_OUT             => mlt_cts_data(1 * 32 - 1 downto 0 * 32),
				CTS_DATAREADY_OUT        => mlt_cts_dataready(0),
				CTS_READOUT_FINISHED_OUT => mlt_cts_readout_finished(0),
				CTS_READ_IN              => mlt_cts_read(0),
				CTS_LENGTH_OUT           => mlt_cts_length(1 * 16 - 1 downto 0 * 16),
				CTS_ERROR_PATTERN_OUT    => mlt_cts_error_pattern(1 * 32 - 1 downto 0 * 32),
				FEE_DATA_IN              => mlt_fee_data(1 * 16 - 1 downto 0 * 16),
				FEE_DATAREADY_IN         => mlt_fee_dataready(0),
				FEE_READ_OUT             => mlt_fee_read(0),
				FEE_STATUS_BITS_IN       => mlt_fee_status(1 * 32 - 1 downto 0 * 32),
				FEE_BUSY_IN              => mlt_fee_busy(0),
				GSC_CLK_IN               => mlt_gsc_clk(0),
				GSC_INIT_DATAREADY_OUT   => mlt_gsc_init_dataready(0),
				GSC_INIT_DATA_OUT        => mlt_gsc_init_data(1 * 16 - 1 downto 0 * 16),
				GSC_INIT_PACKET_NUM_OUT  => mlt_gsc_init_packet(1 * 3 - 1 downto 0 * 3),
				GSC_INIT_READ_IN         => mlt_gsc_init_read(0),
				GSC_REPLY_DATAREADY_IN   => mlt_gsc_reply_dataready(0),
				GSC_REPLY_DATA_IN        => mlt_gsc_reply_data(1 * 16 - 1 downto 0 * 16),
				GSC_REPLY_PACKET_NUM_IN  => mlt_gsc_reply_packet(1 * 3 - 1 downto 0 * 3),
				GSC_REPLY_READ_OUT       => mlt_gsc_reply_read(0),
				GSC_BUSY_IN              => mlt_gsc_busy(0),
				SLV_ADDR_IN              => BUS_IP_RX.addr(7 downto 0),
				SLV_READ_IN              => BUS_IP_RX.read,
				SLV_WRITE_IN             => BUS_IP_RX.write,
				SLV_BUSY_OUT             => busip0.nack,
				SLV_ACK_OUT              => busip0.ack,
				SLV_DATA_IN              => BUS_IP_RX.data,
				SLV_DATA_OUT             => busip0.data,
				CFG_GBE_ENABLE_IN        => cfg_gbe_enable,
				CFG_IPU_ENABLE_IN        => cfg_ipu_enable,
				CFG_MULT_ENABLE_IN       => cfg_mult_enable,
				CFG_MAX_FRAME_IN         => cfg_max_frame,
				CFG_ALLOW_RX_IN          => cfg_allow_rx,
				CFG_SOFT_RESET_IN        => cfg_soft_rst,
				CFG_SUBEVENT_ID_IN       => cfg_subevent_id,
				CFG_SUBEVENT_DEC_IN      => cfg_subevent_dec,
				CFG_QUEUE_DEC_IN         => cfg_queue_dec,
				CFG_READOUT_CTR_IN       => cfg_readout_ctr,
				CFG_READOUT_CTR_VALID_IN => cfg_readout_ctr_valid,
				CFG_INSERT_TTYPE_IN      => cfg_insert_ttype,
				CFG_MAX_SUB_IN           => cfg_max_sub,
				CFG_MAX_QUEUE_IN         => cfg_max_queue,
				CFG_MAX_SUBS_IN_QUEUE_IN => cfg_max_subs_in_queue,
				CFG_MAX_SINGLE_SUB_IN    => cfg_max_single_sub,
				CFG_ADDITIONAL_HDR_IN    => cfg_additional_hdr,
				CFG_MAX_REPLY_SIZE_IN    => cfg_max_reply,
				CFG_AUTO_THROTTLE_IN     => cfg_autothrottle,
				CFG_THROTTLE_PAUSE_IN    => cfg_throttle_pause,

FWD_DST_MAC_IN => FWD_DST_MAC_IN(1 * 48 - 1 downto 0 * 48),
FWD_DST_IP_IN => FWD_DST_IP_IN(1 * 32 - 1 downto 0 * 32),
FWD_DST_UDP_IN => FWD_DST_UDP_IN(1 * 16 - 1 downto 0 * 16),
FWD_DATA_IN => FWD_DATA_IN(1 * 8 - 1 downto 0 * 8),
FWD_DATA_VALID_IN => FWD_DATA_VALID_IN(0),
FWD_SOP_IN => FWD_SOP_IN(0),
FWD_EOP_IN => FWD_EOP_IN(0),
FWD_READY_OUT => FWD_READY_OUT(0),
FWD_FULL_OUT => FWD_FULL_OUT(0),

				MONITOR_RX_FRAMES_OUT    => monitor_rx_frames(1 * 32 - 1 downto 0 * 32),
				MONITOR_RX_BYTES_OUT     => monitor_rx_bytes(1 * 32 - 1 downto 0 * 32),
				MONITOR_TX_FRAMES_OUT    => monitor_tx_frames(1 * 32 - 1 downto 0 * 32),
				MONITOR_TX_BYTES_OUT     => monitor_tx_bytes(1 * 32 - 1 downto 0 * 32),
				MONITOR_TX_PACKETS_OUT   => monitor_tx_packets(1 * 32 - 1 downto 0 * 32),
				MONITOR_DROPPED_OUT      => monitor_dropped(1 * 32 - 1 downto 0 * 32),
				MONITOR_GEN_DBG_OUT      => open,
				MAKE_RESET_OUT           => make_reset0
			);
	end generate GEN_LINK_0;

	NO_LINK0_GEN : if (LINKS_ACTIVE(0) = '0') generate
		make_reset0 <= '0';
		busip0.data <= (others => '0');
		busip0.ack  <= '0';
		busip0.nack <= '0';
		monitor_rx_frames(1 * 32 - 1 downto 0 * 32) <= (others => '0');
    monitor_rx_bytes(1 * 32 - 1 downto 0 * 32) <= (others => '0');
    monitor_tx_frames(1 * 32 - 1 downto 0 * 32) <= (others => '0');
    monitor_tx_bytes(1 * 32 - 1 downto 0 * 32) <= (others => '0');
    monitor_tx_packets(1 * 32 - 1 downto 0 * 32) <= (others => '0');
    monitor_dropped(1 * 32 - 1 downto 0 * 32) <= (others => '0');
    monitor_gen_dbg  <= (others => '0');
    make_reset0 <= '0';
    FWD_READY_OUT(0) <= '0';
    FWD_FULL_OUT(0) <= '1';
    mlt_cts_data(1 * 32 - 1 downto 0 * 32) <= (others => '0');
    mlt_cts_dataready(0) <= '0';
    mlt_cts_readout_finished(0) <= '0';
    mlt_cts_length(1 * 16 - 1 downto 0 * 16) <= (others => '0');
    mlt_cts_error_pattern(1 * 32 - 1 downto 0 * 32) <= (others => '0');		
	end generate NO_LINK0_GEN;

	BUS_IP_TX.ack  <= busip0.ack or busip1.ack or busip2.ack or busip3.ack when rising_edge(CLK_SYS_IN);
	BUS_IP_TX.nack <= busip0.nack or busip1.nack or busip2.nack or busip3.nack when rising_edge(CLK_SYS_IN);
	BUS_IP_TX.data <= busip0.data or busip1.data or busip2.data or busip3.data when rising_edge(CLK_SYS_IN);

	real_ipu_gen : if USE_EXTERNAL_TRBNET_DUMMY = 0 generate
		ipu_mult : entity work.gbe_ipu_multiplexer
			generic map(
				DO_SIMULATION       => DO_SIMULATION,
				INCLUDE_DEBUG       => INCLUDE_DEBUG,
				LINK_HAS_READOUT    => LINK_HAS_READOUT,
				NUMBER_OF_GBE_LINKS => NUMBER_OF_GBE_LINKS
			)
			port map(
				CLK_SYS_IN                  => CLK_SYS_IN,
				RESET                       => RESET,
				CTS_NUMBER_IN               => CTS_NUMBER_IN,
				CTS_CODE_IN                 => CTS_CODE_IN,
				CTS_INFORMATION_IN          => CTS_INFORMATION_IN,
				CTS_READOUT_TYPE_IN         => CTS_READOUT_TYPE_IN,
				CTS_START_READOUT_IN        => CTS_START_READOUT_IN,
				CTS_DATA_OUT                => CTS_DATA_OUT,
				CTS_DATAREADY_OUT           => CTS_DATAREADY_OUT,
				CTS_READOUT_FINISHED_OUT    => CTS_READOUT_FINISHED_OUT,
				CTS_READ_IN                 => CTS_READ_IN,
				CTS_LENGTH_OUT              => CTS_LENGTH_OUT,
				CTS_ERROR_PATTERN_OUT       => CTS_ERROR_PATTERN_OUT,
				FEE_DATA_IN                 => FEE_DATA_IN,
				FEE_DATAREADY_IN            => FEE_DATAREADY_IN,
				FEE_READ_OUT                => FEE_READ_OUT,
				FEE_STATUS_BITS_IN          => FEE_STATUS_BITS_IN,
				FEE_BUSY_IN                 => FEE_BUSY_IN,
				MLT_CTS_NUMBER_OUT          => mlt_cts_number,
				MLT_CTS_CODE_OUT            => mlt_cts_code,
				MLT_CTS_INFORMATION_OUT     => mlt_cts_information,
				MLT_CTS_READOUT_TYPE_OUT    => mlt_cts_readout_type,
				MLT_CTS_START_READOUT_OUT   => mlt_cts_start_readout,
				MLT_CTS_DATA_IN             => mlt_cts_data,
				MLT_CTS_DATAREADY_IN        => mlt_cts_dataready,
				MLT_CTS_READOUT_FINISHED_IN => mlt_cts_readout_finished,
				MLT_CTS_READ_OUT            => mlt_cts_read,
				MLT_CTS_LENGTH_IN           => mlt_cts_length,
				MLT_CTS_ERROR_PATTERN_IN    => mlt_cts_error_pattern,
				MLT_FEE_DATA_OUT            => mlt_fee_data,
				MLT_FEE_DATAREADY_OUT       => mlt_fee_dataready,
				MLT_FEE_READ_IN             => mlt_fee_read,
				MLT_FEE_STATUS_BITS_OUT     => mlt_fee_status,
				MLT_FEE_BUSY_OUT            => mlt_fee_busy,
				DEBUG_OUT                   => open
			);
	end generate real_ipu_gen;

	dummy_ipu_gen : if (USE_EXTERNAL_TRBNET_DUMMY = 1) generate
		ipu_mult : entity work.gbe_ipu_multiplexer
			generic map(
				DO_SIMULATION       => DO_SIMULATION,
				INCLUDE_DEBUG       => INCLUDE_DEBUG,
				LINK_HAS_READOUT    => LINK_HAS_READOUT,
				NUMBER_OF_GBE_LINKS => NUMBER_OF_GBE_LINKS
			)
			port map(
				CLK_SYS_IN                  => CLK_SYS_IN,
				RESET                       => RESET,
				CTS_NUMBER_IN               => local_cts_number,
				CTS_CODE_IN                 => local_cts_code,
				CTS_INFORMATION_IN          => local_cts_information,
				CTS_READOUT_TYPE_IN         => local_cts_readout_type,
				CTS_START_READOUT_IN        => local_cts_start_readout,
				CTS_DATA_OUT                => open,
				CTS_DATAREADY_OUT           => open,
				CTS_READOUT_FINISHED_OUT    => local_cts_readout_finished,
				CTS_READ_IN                 => '1',
				CTS_LENGTH_OUT              => open,
				CTS_ERROR_PATTERN_OUT       => local_cts_status_bits,
				FEE_DATA_IN                 => local_fee_data,
				FEE_DATAREADY_IN            => local_fee_dataready,
				FEE_READ_OUT                => local_fee_read,
				FEE_STATUS_BITS_IN          => local_fee_status_bits,
				FEE_BUSY_IN                 => local_fee_busy,
				MLT_CTS_NUMBER_OUT          => mlt_cts_number,
				MLT_CTS_CODE_OUT            => mlt_cts_code,
				MLT_CTS_INFORMATION_OUT     => mlt_cts_information,
				MLT_CTS_READOUT_TYPE_OUT    => mlt_cts_readout_type,
				MLT_CTS_START_READOUT_OUT   => mlt_cts_start_readout,
				MLT_CTS_DATA_IN             => mlt_cts_data,
				MLT_CTS_DATAREADY_IN        => mlt_cts_dataready,
				MLT_CTS_READOUT_FINISHED_IN => mlt_cts_readout_finished,
				MLT_CTS_READ_OUT            => mlt_cts_read,
				MLT_CTS_LENGTH_IN           => mlt_cts_length,
				MLT_CTS_ERROR_PATTERN_IN    => mlt_cts_error_pattern,
				MLT_FEE_DATA_OUT            => mlt_fee_data,
				MLT_FEE_DATAREADY_OUT       => mlt_fee_dataready,
				MLT_FEE_READ_IN             => mlt_fee_read,
				MLT_FEE_STATUS_BITS_OUT     => mlt_fee_status,
				MLT_FEE_BUSY_OUT            => mlt_fee_busy,
				DEBUG_OUT                   => open
			);

		dummy : entity work.gbe_ipu_dummy
			generic map(
				DO_SIMULATION    => DO_SIMULATION,
				FIXED_SIZE_MODE  => FIXED_SIZE_MODE,
				INCREMENTAL_MODE => INCREMENTAL_MODE,
				FIXED_SIZE       => FIXED_SIZE,
				UP_DOWN_MODE     => UP_DOWN_MODE,
				UP_DOWN_LIMIT    => UP_DOWN_LIMIT,
				FIXED_DELAY_MODE => FIXED_DELAY_MODE,
				FIXED_DELAY      => FIXED_DELAY
			)
			port map(
				clk                     => CLK_SYS_IN,
				rst                     => RESET,
				GBE_READY_IN            => all_links_ready,
				CFG_EVENT_SIZE_IN       => dummy_event,
				CFG_TRIGGERED_MODE_IN   => '0',
				TRIGGER_IN              => TRIGGER_IN,
				CTS_NUMBER_OUT          => local_cts_number,
				CTS_CODE_OUT            => local_cts_code,
				CTS_INFORMATION_OUT     => local_cts_information,
				CTS_READOUT_TYPE_OUT    => local_cts_readout_type,
				CTS_START_READOUT_OUT   => local_cts_start_readout,
				CTS_DATA_IN             => (others => '0'),
				CTS_DATAREADY_IN        => '0',
				CTS_READOUT_FINISHED_IN => local_cts_readout_finished,
				CTS_READ_OUT            => open,
				CTS_LENGTH_IN           => (others => '0'),
				CTS_ERROR_PATTERN_IN    => local_cts_status_bits,
				-- Data payload interface
				FEE_DATA_OUT            => local_fee_data,
				FEE_DATAREADY_OUT       => local_fee_dataready,
				FEE_READ_IN             => local_fee_read,
				FEE_STATUS_BITS_OUT     => local_fee_status_bits,
				FEE_BUSY_OUT            => local_fee_busy
			);

		-- handler for triggers
		DUMMY_HANDLER : entity work.trb_net16_gbe_ipu_interface
			port map(
				CLK_IPU                  => CLK_SYS_IN,
				CLK_GBE                  => CLK_125_IN,
				RESET                    => RESET,
				--Event information coming from CTS
				CTS_NUMBER_IN            => CTS_NUMBER_IN,
				CTS_CODE_IN              => CTS_CODE_IN,
				CTS_INFORMATION_IN       => CTS_INFORMATION_IN,
				CTS_READOUT_TYPE_IN      => CTS_READOUT_TYPE_IN,
				CTS_START_READOUT_IN     => CTS_START_READOUT_IN,
				--Information sent to CTS
				--status data, equipped with DHDR
				CTS_DATA_OUT             => CTS_DATA_OUT,
				CTS_DATAREADY_OUT        => CTS_DATAREADY_OUT,
				CTS_READOUT_FINISHED_OUT => CTS_READOUT_FINISHED_OUT,
				CTS_READ_IN              => CTS_READ_IN,
				CTS_LENGTH_OUT           => CTS_LENGTH_OUT,
				CTS_ERROR_PATTERN_OUT    => CTS_ERROR_PATTERN_OUT,
				-- Data from Frontends
				FEE_DATA_IN              => FEE_DATA_IN,
				FEE_DATAREADY_IN         => FEE_DATAREADY_IN,
				FEE_READ_OUT             => FEE_READ_OUT,
				FEE_STATUS_BITS_IN       => FEE_STATUS_BITS_IN,
				FEE_BUSY_IN              => FEE_BUSY_IN,
				-- slow control interface
				START_CONFIG_OUT         => open,
				BANK_SELECT_OUT          => open,
				CONFIG_DONE_IN           => '1',
				DATA_GBE_ENABLE_IN       => '1',
				DATA_IPU_ENABLE_IN       => '1',
				MULT_EVT_ENABLE_IN       => '1',
				MAX_SUBEVENT_SIZE_IN     => (others => '0'),
				MAX_QUEUE_SIZE_IN        => (others => '0'),
				MAX_SUBS_IN_QUEUE_IN     => (others => '0'),
				MAX_SINGLE_SUB_SIZE_IN   => (others => '0'),
				READOUT_CTR_IN           => (others => '0'),
				READOUT_CTR_VALID_IN     => '0',
				CFG_AUTO_THROTTLE_IN     => '0',
				CFG_THROTTLE_PAUSE_IN    => (others => '0'),
				-- PacketConstructor interface
				PC_WR_EN_OUT             => open,
				PC_DATA_OUT              => open,
				PC_READY_IN              => '1',
				PC_SOS_OUT               => open,
				PC_EOS_OUT               => open,
				PC_EOQ_OUT               => open,
				PC_SUB_SIZE_OUT          => open,
				PC_TRIG_NR_OUT           => open,
				PC_TRIGGER_TYPE_OUT      => open,
				MONITOR_OUT              => open,
				DEBUG_OUT                => open
			);
	end generate dummy_ipu_gen;

	setup_imp_gen : if (DO_SIMULATION = 0) generate
		SETUP : gbe_setup
			port map(
				CLK                          => CLK_SYS_IN,
				RESET                        => RESET,

				-- interface to regio bus
				BUS_ADDR_IN                  => BUS_REG_RX.addr(7 downto 0),
				BUS_DATA_IN                  => BUS_REG_RX.data,
				BUS_DATA_OUT                 => BUS_REG_TX.data,
				BUS_WRITE_EN_IN              => BUS_REG_RX.write,
				BUS_READ_EN_IN               => BUS_REG_RX.read,
				BUS_ACK_OUT                  => BUS_REG_TX.ack,

				-- output to gbe_buf
				GBE_SUBEVENT_ID_OUT          => cfg_subevent_id,
				GBE_SUBEVENT_DEC_OUT         => cfg_subevent_dec,
				GBE_QUEUE_DEC_OUT            => cfg_queue_dec,
				GBE_MAX_FRAME_OUT            => cfg_max_frame,
				GBE_USE_GBE_OUT              => cfg_gbe_enable,
				GBE_USE_TRBNET_OUT           => cfg_ipu_enable,
				GBE_USE_MULTIEVENTS_OUT      => cfg_mult_enable,
				GBE_READOUT_CTR_OUT          => cfg_readout_ctr,
				GBE_READOUT_CTR_VALID_OUT    => cfg_readout_ctr_valid,
				GBE_ALLOW_RX_OUT             => cfg_allow_rx,
				GBE_ADDITIONAL_HDR_OUT       => cfg_additional_hdr,
				GBE_INSERT_TTYPE_OUT         => cfg_insert_ttype,
				GBE_SOFT_RESET_OUT           => cfg_soft_rst,
				GBE_MAX_REPLY_OUT            => cfg_max_reply,
				GBE_MAX_SUB_OUT              => cfg_max_sub,
				GBE_MAX_QUEUE_OUT            => cfg_max_queue,
				GBE_MAX_SUBS_IN_QUEUE_OUT    => cfg_max_subs_in_queue,
				GBE_MAX_SINGLE_SUB_OUT       => cfg_max_single_sub,
				GBE_AUTOTHROTTLE_OUT         => cfg_autothrottle,
				GBE_THROTTLE_PAUSE_OUT       => cfg_throttle_pause,
				MONITOR_RX_BYTES_IN          => sum_rx_bytes,
				MONITOR_RX_FRAMES_IN         => sum_rx_frames,
				MONITOR_TX_BYTES_IN          => sum_tx_bytes,
				MONITOR_TX_FRAMES_IN         => sum_tx_frames,
				MONITOR_TX_PACKETS_IN        => sum_tx_packets,
				MONITOR_DROPPED_IN           => sum_dropped,
				MONITOR_SELECT_REC_IN        => (others => '0'), --dbg_select_rec,
				MONITOR_SELECT_REC_BYTES_IN  => (others => '0'), --dbg_select_rec_bytes,
				MONITOR_SELECT_SENT_BYTES_IN => (others => '0'), --dbg_select_sent_bytes,
				MONITOR_SELECT_SENT_IN       => (others => '0'), --dbg_select_sent,
				MONITOR_SELECT_DROP_IN_IN    => (others => '0'), --dbg_select_drop_in,
				MONITOR_SELECT_DROP_OUT_IN   => (others => '0'), --dbg_select_drop_out,
				MONITOR_SELECT_GEN_DBG_IN    => monitor_gen_dbg, --dbg_select_gen,

				DUMMY_EVENT_SIZE_OUT         => dummy_event,
				DUMMY_TRIGGERED_MODE_OUT     => dummy_mode,
				DATA_HIST_IN                 => (others => (others => '0')), --dbg_hist,
				SCTRL_HIST_IN                => (others => (others => '0')) --dbg_hist2
			);
	end generate;

	setup_sim_gen : if (DO_SIMULATION = 1) generate
		cfg_subevent_id       <= x"12345678";
		cfg_subevent_dec      <= x"00010002";
		cfg_queue_dec         <= x"00030004";
		cfg_max_frame         <= x"0578";
		cfg_gbe_enable        <= '1';
		cfg_ipu_enable        <= '1';
		cfg_mult_enable       <= '0';
		cfg_readout_ctr       <= x"000000";
		cfg_readout_ctr_valid <= '0';
		cfg_allow_rx          <= '1';
		cfg_additional_hdr    <= '0';
		cfg_insert_ttype      <= '0';
		cfg_soft_rst          <= '0';
		cfg_max_reply         <= x"0000fff0";
		cfg_max_sub           <= x"fff0";
		cfg_max_queue         <= x"fff0";
		cfg_max_subs_in_queue <= x"0001";
		cfg_max_single_sub    <= x"fff0";
		cfg_throttle_pause <= x"0000";

	end generate;

	NOSCTRL_MAP_GEN : if (LINK_HAS_SLOWCTRL = "0000") generate
		GSC_INIT_DATAREADY_OUT  <= '0';
		GSC_INIT_DATA_OUT       <= (others => '0');
		GSC_INIT_PACKET_NUM_OUT <= (others => '0');
		GSC_REPLY_READ_OUT      <= '1';
		mlt_gsc_clk             <= (others => '0');
		mlt_gsc_init_read       <= (others => '0');
		mlt_gsc_reply_dataready <= (others => '0');
		mlt_gsc_reply_data      <= (others => '0');
		mlt_gsc_reply_packet    <= (others => '0');
		mlt_gsc_busy            <= (others => '0');
	end generate NOSCTRL_MAP_GEN;

	SCTRL_MAP_GEN : if (LINK_HAS_SLOWCTRL /= "0000") generate
		SCTRL_LOOP_GEN : for i in 0 to NUMBER_OF_GBE_LINKS - 1 generate
			ACTIVE_MAP_GEN : if (LINK_HAS_SLOWCTRL(i) = '1') generate
				mlt_gsc_clk(i)                                     <= GSC_CLK_IN;
				GSC_INIT_DATAREADY_OUT                             <= mlt_gsc_init_dataready(i);
				GSC_INIT_DATA_OUT                                  <= mlt_gsc_init_data((i + 1) * 16 - 1 downto i * 16);
				GSC_INIT_PACKET_NUM_OUT                            <= mlt_gsc_init_packet((i + 1) * 3 - 1 downto i * 3);
				mlt_gsc_init_read(i)                               <= GSC_INIT_READ_IN;
				mlt_gsc_reply_dataready(i)                         <= GSC_REPLY_DATAREADY_IN;
				mlt_gsc_reply_data((i + 1) * 16 - 1 downto i * 16) <= GSC_REPLY_DATA_IN;
				mlt_gsc_reply_packet((i + 1) * 3 - 1 downto i * 3) <= GSC_REPLY_PACKET_NUM_IN;
				GSC_REPLY_READ_OUT                                 <= mlt_gsc_reply_read(i);
				mlt_gsc_busy(i)                                    <= GSC_BUSY_IN;
			end generate ACTIVE_MAP_GEN;

			INACTIVE_MAP_GEN : if (LINK_HAS_SLOWCTRL(i) = '0') generate
				mlt_gsc_clk(i)                                     <= '0';
				mlt_gsc_init_read(i)                               <= '0';
				mlt_gsc_reply_dataready(i)                         <= '0';
				mlt_gsc_reply_data((i + 1) * 16 - 1 downto i * 16) <= (others => '0');
				mlt_gsc_reply_packet((i + 1) * 3 - 1 downto i * 3) <= (others => '0');
				mlt_gsc_busy(i)                                    <= '0';
			end generate INACTIVE_MAP_GEN;
		end generate SCTRL_LOOP_GEN;
	end generate SCTRL_MAP_GEN;

	sum_rx_bytes   <= monitor_rx_bytes(4 * 32 - 1 downto 3 * 32) + monitor_rx_bytes(3 * 32 - 1 downto 2 * 32) + monitor_rx_bytes(2 * 32 - 1 downto 1 * 32) + monitor_rx_bytes(1 * 32 - 1 downto 0 * 32);
	sum_rx_frames  <= monitor_rx_frames(4 * 32 - 1 downto 3 * 32) + monitor_rx_frames(3 * 32 - 1 downto 2 * 32) + monitor_rx_frames(2 * 32 - 1 downto 1 * 32) + monitor_rx_frames(1 * 32 - 1 downto 0 * 32);
	sum_tx_bytes   <= monitor_tx_bytes(4 * 32 - 1 downto 3 * 32) + monitor_tx_bytes(3 * 32 - 1 downto 2 * 32) + monitor_tx_bytes(2 * 32 - 1 downto 1 * 32) + monitor_tx_bytes(1 * 32 - 1 downto 0 * 32);
	sum_tx_frames  <= monitor_tx_frames(4 * 32 - 1 downto 3 * 32) + monitor_tx_frames(3 * 32 - 1 downto 2 * 32) + monitor_tx_frames(2 * 32 - 1 downto 1 * 32) + monitor_tx_frames(1 * 32 - 1 downto 0 * 32);
	sum_tx_packets <= monitor_tx_packets(4 * 32 - 1 downto 3 * 32) + monitor_tx_packets(3 * 32 - 1 downto 2 * 32) + monitor_tx_packets(2 * 32 - 1 downto 1 * 32) + monitor_tx_packets(1 * 32 - 1 downto 0 * 32);
	sum_dropped    <= monitor_dropped(4 * 32 - 1 downto 3 * 32) + monitor_dropped(3 * 32 - 1 downto 2 * 32) + monitor_dropped(2 * 32 - 1 downto 1 * 32) + monitor_dropped(1 * 32 - 1 downto 0 * 32);

	include_debug_gen : if (INCLUDE_DEBUG = 1) generate
		DEBUG_OUT(63 downto 0)   <= monitor_gen_dbg(4 * 64 - 1 downto 3 * 64);
		DEBUG_OUT(127 downto 65) <= (others => '0');
	end generate;

	testbench_sim : if DO_SIMULATION = 1 generate
		clk_125_rx_from_pcs(0) <= CLK_125_IN;
		clk_125_rx_from_pcs(1) <= CLK_125_IN;
		clk_125_rx_from_pcs(2) <= CLK_125_IN;
		clk_125_rx_from_pcs(3) <= CLK_125_IN;

		done_generate : for i in 0 to 3 generate
			process
			begin
				mac_tx_done(i) <= '0';
				wait until rising_edge(mac_fifoeof(i));
				wait until rising_edge(clk_125_rx_from_pcs(i));
				wait until rising_edge(clk_125_rx_from_pcs(i));
				wait until rising_edge(clk_125_rx_from_pcs(i));
				wait until rising_edge(clk_125_rx_from_pcs(i));
				wait until rising_edge(clk_125_rx_from_pcs(i));
				wait until rising_edge(clk_125_rx_from_pcs(i));
				mac_tx_done(i) <= '1';
				wait until rising_edge(clk_125_rx_from_pcs(i));
			end process;
		end generate done_generate;

		process
		begin
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_tx_read(0) <= mac_fifoavail(0);
			mac_tx_read(1) <= mac_fifoavail(1);
			mac_tx_read(2) <= mac_fifoavail(2);
			mac_tx_read(3) <= mac_fifoavail(3);
		end process;

		mac_rx_eof(1)                       <= mac_rx_eof(0);
		mac_rx_eof(2)                       <= mac_rx_eof(0);
		mac_rx_eof(3)                       <= mac_rx_eof(0);
		mac_rx_write(1)                     <= mac_rx_write(0);
		mac_rx_write(2)                     <= mac_rx_write(0);
		mac_rx_write(3)                     <= mac_rx_write(0);
		mac_rx_data(2 * 8 - 1 downto 1 * 8) <= mac_rx_data(1 * 8 - 1 downto 0 * 8);
		mac_rx_data(3 * 8 - 1 downto 2 * 8) <= mac_rx_data(1 * 8 - 1 downto 0 * 8);
		mac_rx_data(4 * 8 - 1 downto 3 * 8) <= mac_rx_data(1 * 8 - 1 downto 0 * 8);

		testbench_proc : process
		begin

			--trigger <= '0';
			--gbe_ready <= '0';
			mac_rx_write(0)                     <= '0';
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			mac_rx_eof(0)                       <= '0';

			wait for 5 us;

			-- FIRST FRAME UDP - DHCP Offer
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_write(0)                     <= '1';
			-- dest mac
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			-- src mac
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"aa";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"bb";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"cc";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"dd";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ee";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			-- frame type
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"08";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			-- ip headers
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"45";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"10";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"01";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"5a";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"49";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"11"; -- udp
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"cc";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"cc";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"c0";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"a8";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"01";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"c0";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"a8";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"02";
			-- udp headers
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"43";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"44";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"02";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"2c";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"aa";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"bb";
			-- dhcp data
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"02";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"01";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"06";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff"; --transcation id
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff"; --transcation id
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"fa"; --transcation id
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ce"; --transcation id
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"c0";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"a8";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"10";

			for i in 0 to 219 loop
				wait until rising_edge(clk_125_rx_from_pcs(0));
				mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			end loop;

			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"35";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"01";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"02";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_eof(0) <= '1';

			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_write(0) <= '0';
			mac_rx_eof(0)   <= '0';

			wait for 6 us;

			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_write(0)                     <= '1';
			-- dest mac
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			-- src mac
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"aa";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"bb";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"cc";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"dd";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ee";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			-- frame type
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"08";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			-- ip headers
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"45";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"10";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"01";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"5a";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"49";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"11"; -- udp
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"cc";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"cc";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"c0";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"a8";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"01";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"c0";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"a8";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"02";
			-- udp headers
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"43";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"44";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"02";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"2c";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"aa";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"bb";
			-- dhcp data
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"02";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"01";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"06";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ff";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"fa";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"ce";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"c0";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"a8";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"10";

			for i in 0 to 219 loop
				wait until rising_edge(clk_125_rx_from_pcs(0));
				mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			end loop;

			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"35";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"01";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"05";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_data(1 * 8 - 1 downto 0 * 8) <= x"00";
			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_eof(0) <= '1';

			wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_write(0) <= '0';
			mac_rx_eof(0)   <= '0';

			wait for 5 us;

			wait for 2 us;

			--gbe_ready <= '1';

			wait for 1 us;

			--trigger <= '1';
			
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_write(0) <= '1';
	-- dest mac
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"ff";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"ff";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"ff";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"ff";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"ff";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"ff";
		wait until rising_edge(clk_125_rx_from_pcs(0));
	-- src mac
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"00";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"aa";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"bb";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"cc";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"dd";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"ee";
		wait until rising_edge(clk_125_rx_from_pcs(0));
	-- frame type
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"08";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"00";
		wait until rising_edge(clk_125_rx_from_pcs(0));
	-- ip headers
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"45";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"10";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"01";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"5a";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"49";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"00";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"00";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"00";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"ff";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"01";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"cc";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"cc";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"c0";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"a8";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"00";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"01";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"c0";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"a8";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"00";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"02";
	-- ping headers
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"08";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"00";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"47";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"d3";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"0d";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"3c";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"00";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"01";
		wait until rising_edge(clk_125_rx_from_pcs(0));
	-- ping data
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"8c";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"da";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"e7";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"4d";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"36";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"c4";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"0d";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"00";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"01";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"02";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"03";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"04";	
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"05";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"06";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"07";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"08";
		
		-- ping data
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"e0";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"01";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"e0";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"01";	
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"e0";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"01";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"e0";
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"01";
		
		wait until rising_edge(clk_125_rx_from_pcs(0));
			mac_rx_eof(0) <= '1';
				mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"aa";
		
		wait until rising_edge(clk_125_rx_from_pcs(0));
		mac_rx_write(0) <='0';
		mac_rx_eof(0) <= '0';


		wait for 10 us;

-- ETHERNET PAUSE FRAME


-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		mac_rx_write(0) <= '1';
-- 	-- dest mac
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"01";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"80";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"c2";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"00";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"00";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"01";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 	-- src mac
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"00";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"aa";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"bb";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"cc";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"dd";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"ee";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 	-- frame type
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"88";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"08";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));	
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"00";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"01";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"ff";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"ff";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 
-- 		for empty_b_ctr in 0 to 40 loop
-- 		  mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"00";
-- 		  wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		end loop;
-- 		mac_rx_eof(0) <= '1';
-- 		mac_rx_data(1 * 8 - 1 downto 0 * 8)		<= x"00";
-- 		wait until rising_edge(clk_125_rx_from_pcs(0));
-- 		mac_rx_write(0) <='0';
-- 		mac_rx_eof(0) <= '0';

			wait;

		end process testbench_proc;

	end generate testbench_sim;

end architecture RTL;
