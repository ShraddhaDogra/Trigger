--Media interface for Lattice ECP2M using PCS at 2GHz

--Still missing: link reset features, fifo full error handling

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity trb_net16_med_ecp_sfp is
  generic(
    SERDES_NUM : integer range 0 to 3 := 2;
    EXT_CLOCK  : integer range 0 to 1 := c_NO
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

architecture med_ecp_sfp of trb_net16_med_ecp_sfp is


  -- Placer Directives
  attribute HGROUP : string;
  -- for whole architecture
  attribute HGROUP of med_ecp_sfp : architecture  is "media_interface_group";
  attribute syn_sharing : string;
  attribute syn_sharing of med_ecp_sfp : architecture is "off";

  component serdes_sfp_0
    port(
     core_txrefclk : in std_logic;
     core_rxrefclk : in std_logic;
      hdinp0 : in std_logic;
      hdinn0 : in std_logic;
      ff_rxiclk_ch0 : in std_logic;
      ff_txiclk_ch0 : in std_logic;
      ff_ebrd_clk_0 : in std_logic;
      ff_txdata_ch0 : in std_logic_vector(15 downto 0);
      ff_tx_k_cntrl_ch0 : in std_logic_vector(1 downto 0);
      ff_force_disp_ch0 : in std_logic_vector(1 downto 0);
      ff_disp_sel_ch0 : in std_logic_vector(1 downto 0);
      ff_correct_disp_ch0 : in std_logic_vector(1 downto 0);
      ffc_rrst_ch0 : in std_logic;
      ffc_lane_tx_rst_ch0 : in std_logic;
      ffc_lane_rx_rst_ch0 : in std_logic;
      ffc_txpwdnb_ch0 : in std_logic;
      ffc_rxpwdnb_ch0 : in std_logic;
      ffc_macro_rst : in std_logic;
      ffc_quad_rst : in std_logic;
      ffc_trst : in std_logic;
      hdoutp0 : out std_logic;
      hdoutn0 : out std_logic;
      ff_rxdata_ch0 : out std_logic_vector(15 downto 0);
      ff_rx_k_cntrl_ch0 : out std_logic_vector(1 downto 0);
      ff_rxfullclk_ch0 : out std_logic;
      ff_rxhalfclk_ch0 : out std_logic;
      ff_disp_err_ch0 : out std_logic_vector(1 downto 0);
      ff_cv_ch0 : out std_logic_vector(1 downto 0);
      ffs_rlos_lo_ch0 : out std_logic;
      ffs_ls_sync_status_ch0 : out std_logic;
      ffs_cc_underrun_ch0 : out std_logic;
      ffs_cc_overrun_ch0 : out std_logic;
      ffs_txfbfifo_error_ch0 : out std_logic;
      ffs_rxfbfifo_error_ch0 : out std_logic;
      ffs_rlol_ch0 : out std_logic;
      oob_out_ch0 : out std_logic;
      ff_txfullclk : out std_logic;
      ff_txhalfclk : out std_logic;
      refck2core : out std_logic;
      ffs_plol : out std_logic
      );
  end component;

  component serdes_sfp_0_extclock
    port(
      refclkp : in std_logic;
      refclkn : in std_logic;
      hdinp0 : in std_logic;
      hdinn0 : in std_logic;
      ff_rxiclk_ch0 : in std_logic;
      ff_txiclk_ch0 : in std_logic;
      ff_ebrd_clk_0 : in std_logic;
      ff_txdata_ch0 : in std_logic_vector(15 downto 0);
      ff_tx_k_cntrl_ch0 : in std_logic_vector(1 downto 0);
      ff_force_disp_ch0 : in std_logic_vector(1 downto 0);
      ff_disp_sel_ch0 : in std_logic_vector(1 downto 0);
      ff_correct_disp_ch0 : in std_logic_vector(1 downto 0);
      ffc_rrst_ch0 : in std_logic;
      ffc_lane_tx_rst_ch0 : in std_logic;
      ffc_lane_rx_rst_ch0 : in std_logic;
      ffc_txpwdnb_ch0 : in std_logic;
      ffc_rxpwdnb_ch0 : in std_logic;
      ffc_macro_rst : in std_logic;
      ffc_quad_rst : in std_logic;
      ffc_trst : in std_logic;
      hdoutp0 : out std_logic;
      hdoutn0 : out std_logic;
      ff_rxdata_ch0 : out std_logic_vector(15 downto 0);
      ff_rx_k_cntrl_ch0 : out std_logic_vector(1 downto 0);
      ff_rxfullclk_ch0 : out std_logic;
      ff_rxhalfclk_ch0 : out std_logic;
      ff_disp_err_ch0 : out std_logic_vector(1 downto 0);
      ff_cv_ch0 : out std_logic_vector(1 downto 0);
      ffs_rlos_lo_ch0 : out std_logic;
      ffs_ls_sync_status_ch0 : out std_logic;
      ffs_cc_underrun_ch0 : out std_logic;
      ffs_cc_overrun_ch0 : out std_logic;
      ffs_txfbfifo_error_ch0 : out std_logic;
      ffs_rxfbfifo_error_ch0 : out std_logic;
      ffs_rlol_ch0 : out std_logic;
      oob_out_ch0 : out std_logic;
      ff_txfullclk : out std_logic;
      ff_txhalfclk : out std_logic;
      refck2core : out std_logic;
      ffs_plol : out std_logic
      );
  end component;

  component serdes_sfp_1
    port(
      core_txrefclk : in std_logic;
      core_rxrefclk : in std_logic;
      hdinp1 : in std_logic;
      hdinn1 : in std_logic;
      ff_rxiclk_ch1 : in std_logic;
      ff_txiclk_ch1 : in std_logic;
      ff_ebrd_clk_1 : in std_logic;
      ff_txdata_ch1 : in std_logic_vector(15 downto 0);
      ff_tx_k_cntrl_ch1 : in std_logic_vector(1 downto 0);
      ff_force_disp_ch1 : in std_logic_vector(1 downto 0);
      ff_disp_sel_ch1 : in std_logic_vector(1 downto 0);
      ff_correct_disp_ch1 : in std_logic_vector(1 downto 0);
      ffc_rrst_ch1 : in std_logic;
      ffc_lane_tx_rst_ch1 : in std_logic;
      ffc_lane_rx_rst_ch1 : in std_logic;
      ffc_txpwdnb_ch1 : in std_logic;
      ffc_rxpwdnb_ch1 : in std_logic;
      ffc_macro_rst : in std_logic;
      ffc_quad_rst : in std_logic;
      ffc_trst : in std_logic;
      hdoutp1 : out std_logic;
      hdoutn1 : out std_logic;
      ff_rxdata_ch1 : out std_logic_vector(15 downto 0);
      ff_rx_k_cntrl_ch1 : out std_logic_vector(1 downto 0);
      ff_rxfullclk_ch1 : out std_logic;
      ff_rxhalfclk_ch1 : out std_logic;
      ff_disp_err_ch1 : out std_logic_vector(1 downto 0);
      ff_cv_ch1 : out std_logic_vector(1 downto 0);
      ffs_rlos_lo_ch1 : out std_logic;
      ffs_ls_sync_status_ch1 : out std_logic;
      ffs_cc_underrun_ch1 : out std_logic;
      ffs_cc_overrun_ch1 : out std_logic;
      ffs_txfbfifo_error_ch1 : out std_logic;
      ffs_rxfbfifo_error_ch1 : out std_logic;
      ffs_rlol_ch1 : out std_logic;
      oob_out_ch1 : out std_logic;
      ff_txfullclk : out std_logic;
      ff_txhalfclk : out std_logic;
      refck2core : out std_logic;
      ffs_plol : out std_logic
      );
  end component;


  component serdes_sfp_2
    port(
      core_txrefclk : in std_logic;
      core_rxrefclk : in std_logic;
      hdinp2 : in std_logic;
      hdinn2 : in std_logic;
      ff_rxiclk_ch2 : in std_logic;
      ff_txiclk_ch2 : in std_logic;
      ff_ebrd_clk_2 : in std_logic;
      ff_txdata_ch2 : in std_logic_vector(15 downto 0);
      ff_tx_k_cntrl_ch2 : in std_logic_vector(1 downto 0);
      ff_force_disp_ch2 : in std_logic_vector(1 downto 0);
      ff_disp_sel_ch2 : in std_logic_vector(1 downto 0);
      ff_correct_disp_ch2 : in std_logic_vector(1 downto 0);
      ffc_rrst_ch2 : in std_logic;
      ffc_lane_tx_rst_ch2 : in std_logic;
      ffc_lane_rx_rst_ch2 : in std_logic;
      ffc_txpwdnb_ch2 : in std_logic;
      ffc_rxpwdnb_ch2 : in std_logic;
      ffc_macro_rst : in std_logic;
      ffc_quad_rst : in std_logic;
      ffc_trst : in std_logic;
      hdoutp2 : out std_logic;
      hdoutn2 : out std_logic;
      ff_rxdata_ch2 : out std_logic_vector(15 downto 0);
      ff_rx_k_cntrl_ch2 : out std_logic_vector(1 downto 0);
      ff_rxfullclk_ch2 : out std_logic;
      ff_rxhalfclk_ch2 : out std_logic;
      ff_disp_err_ch2 : out std_logic_vector(1 downto 0);
      ff_cv_ch2 : out std_logic_vector(1 downto 0);
      ffs_rlos_lo_ch2 : out std_logic;
      ffs_ls_sync_status_ch2 : out std_logic;
      ffs_cc_underrun_ch2 : out std_logic;
      ffs_cc_overrun_ch2 : out std_logic;
      ffs_txfbfifo_error_ch2 : out std_logic;
      ffs_rxfbfifo_error_ch2 : out std_logic;
      ffs_rlol_ch2 : out std_logic;
      oob_out_ch2 : out std_logic;
      ff_txfullclk : out std_logic;
      ff_txhalfclk : out std_logic;
      refck2core : out std_logic;
      ffs_plol : out std_logic
      );
  end component;

  component serdes_sfp_3
    port(
      core_txrefclk : in std_logic;
      core_rxrefclk : in std_logic;
      hdinp3 : in std_logic;
      hdinn3 : in std_logic;
      ff_rxiclk_ch3 : in std_logic;
      ff_txiclk_ch3 : in std_logic;
      ff_ebrd_clk_3 : in std_logic;
      ff_txdata_ch3 : in std_logic_vector(15 downto 0);
      ff_tx_k_cntrl_ch3 : in std_logic_vector(1 downto 0);
      ff_force_disp_ch3 : in std_logic_vector(1 downto 0);
      ff_disp_sel_ch3 : in std_logic_vector(1 downto 0);
      ff_correct_disp_ch3 : in std_logic_vector(1 downto 0);
      ffc_rrst_ch3 : in std_logic;
      ffc_lane_tx_rst_ch3 : in std_logic;
      ffc_lane_rx_rst_ch3 : in std_logic;
      ffc_txpwdnb_ch3 : in std_logic;
      ffc_rxpwdnb_ch3 : in std_logic;
      ffc_macro_rst : in std_logic;
      ffc_quad_rst : in std_logic;
      ffc_trst : in std_logic;
      hdoutp3 : out std_logic;
      hdoutn3 : out std_logic;
      ff_rxdata_ch3 : out std_logic_vector(15 downto 0);
      ff_rx_k_cntrl_ch3 : out std_logic_vector(1 downto 0);
      ff_rxfullclk_ch3 : out std_logic;
      ff_rxhalfclk_ch3 : out std_logic;
      ff_disp_err_ch3 : out std_logic_vector(1 downto 0);
      ff_cv_ch3 : out std_logic_vector(1 downto 0);
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
      refck2core : out std_logic;
      ffs_plol : out std_logic
      );
  end component;



  signal refck2core             : std_logic;
--  signal clock                  : std_logic;
  --reset signals
  signal ffc_quad_rst           : std_logic;
  signal ffc_lane_tx_rst        : std_logic;
  signal ffc_lane_rx_rst        : std_logic;
  --serdes connections
  signal tx_data                : std_logic_vector(15 downto 0);
  signal tx_k                   : std_logic_vector(1 downto 0);
  signal rx_data                : std_logic_vector(15 downto 0); -- delayed signals
  signal rx_k                   : std_logic_vector(1 downto 0);  -- delayed signals
  signal comb_rx_data           : std_logic_vector(15 downto 0); -- original signals from SFP
  signal comb_rx_k              : std_logic_vector(1 downto 0);  -- original signals from SFP
  signal link_ok                : std_logic_vector(0 downto 0);
  signal link_error             : std_logic_vector(8 downto 0);
  signal ff_rxhalfclk           : std_logic;
  signal ff_txhalfclk           : std_logic;
  --rx fifo signals
  signal fifo_rx_rd_en          : std_logic;
  signal fifo_rx_wr_en          : std_logic;
  signal fifo_rx_reset          : std_logic;
  signal fifo_rx_din            : std_logic_vector(17 downto 0);
  signal fifo_rx_dout           : std_logic_vector(17 downto 0);
  signal fifo_rx_full           : std_logic;
  signal fifo_rx_empty          : std_logic;
  --tx fifo signals
  signal fifo_tx_rd_en          : std_logic;
  signal fifo_tx_wr_en          : std_logic;
  signal fifo_tx_reset          : std_logic;
  signal fifo_tx_din            : std_logic_vector(17 downto 0);
  signal fifo_tx_dout           : std_logic_vector(17 downto 0);
  signal fifo_tx_full           : std_logic;
  signal fifo_tx_empty          : std_logic;
  --rx path
  signal rx_counter             : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal buf_med_dataready_out  : std_logic;
  signal buf_med_data_out       : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal buf_med_packet_num_out : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal last_rx                : std_logic_vector(8 downto 0);
  signal last_fifo_rx_empty     : std_logic;
  --tx path
  signal last_fifo_tx_empty     : std_logic;
  --link status
  signal link_led               : std_logic;
  signal rx_k_q                 : std_logic_vector(1 downto 0);

  signal info_led               : std_logic;

  signal quad_rst               : std_logic;
  signal lane_rst               : std_logic;
  signal tx_allow               : std_logic;
  signal rx_allow               : std_logic;

  signal rx_allow_q             : std_logic; -- clock domain changed signal
  signal tx_allow_q             : std_logic;
  signal swap_bytes             : std_logic;
  signal buf_stat_debug         : std_logic_vector(31 downto 0);

  -- status inputs from SFP
  signal sfp_prsnt_n            : std_logic; -- synchronized input signals
  signal sfp_los                : std_logic; -- synchronized input signals

  signal buf_STAT_OP            : std_logic_vector(15 downto 0);

  signal led_counter            : std_logic_vector(17 downto 0);
  signal rx_led                 : std_logic;
  signal tx_led                 : std_logic;
  attribute syn_keep : boolean;
  attribute syn_keep of led_counter : signal is true;

  signal reset_i                : std_logic;
  signal pwr_up                 : std_logic;
begin

--------------------------------------------------------------------------
-- Internal Lane Resets
--------------------------------------------------------------------------

  PROC_RESET : process(SYSCLK)
    begin
      if rising_edge(SYSCLK) then
        reset_i <= RESET or CTRL_OP(14);
        pwr_up  <= '1'; --not CTRL_OP(i*16+14);
      end if;
    end process;

--------------------------------------------------------------------------
-- Synchronizer stages
--------------------------------------------------------------------------

-- Input synchronizer for SFP_PRESENT and SFP_LOS signals (external signals from SFP)
THE_SFP_STATUS_SYNC: signal_sync
  generic map(
    DEPTH => 3,
    WIDTH => 2
    )
  port map(
    RESET    => reset_i,
    D_IN(0)  => sd_prsnt_n_in,
    D_IN(1)  => sd_los_in,
    CLK0     => sysclk,
    CLK1     => sysclk,
    D_OUT(0) => sfp_prsnt_n,
    D_OUT(1) => sfp_los
    );

-- Komma delimiter transfer for training phase
THE_RX_K_SYNC: signal_sync
  generic map(
    DEPTH => 3,
    WIDTH => 2
    )
  port map(
    RESET    => reset_i,
    D_IN     => comb_rx_k, -- rx_k
    CLK0     => ff_rxhalfclk,
    CLK1     => sysclk,
    D_OUT    => rx_k_q
    );

-- delay line for RX_K and RX_DATA (directly from SFP to fabric logic)
THE_RX_DATA_DELAY: signal_sync
  generic map(
    DEPTH => 2,
    WIDTH => 16
    )
  port map(
    RESET    => reset_i,
    D_IN     => comb_rx_data,
    CLK0     => ff_rxhalfclk,
    CLK1     => ff_rxhalfclk,
    D_OUT    => rx_data
    );

THE_RX_K_DELAY: signal_sync
  generic map(
    DEPTH => 2,
    WIDTH => 2
    )
  port map(
    RESET    => reset_i,
    D_IN     => comb_rx_k,
    CLK0     => ff_rxhalfclk,
    CLK1     => ff_rxhalfclk,
    D_OUT    => rx_k
    );


-- Transfer for ALLOW signals
THE_RX_ALLOW_SYNC: signal_sync -- really needed?!?
  generic map(
    DEPTH => 2,
    WIDTH => 2
    )
  port map(
    RESET    => reset_i,
    D_IN(0)  => rx_allow,
    D_IN(1)  => tx_allow,
    CLK0     => sysclk,
    CLK1     => sysclk,
    D_OUT(0) => rx_allow_q,
    D_OUT(1) => tx_allow_q
    );

--------------------------------------------------------------------------
-- Main control state machine, startup control for SFP
--------------------------------------------------------------------------

THE_SFP_LSM: trb_net16_lsm_sfp
    port map(
      SYSCLK            => sysclk,
      RESET             => reset_i,
      CLEAR             => clear,
      SFP_MISSING_IN    => sfp_prsnt_n,
      SFP_LOS_IN        => sfp_los,
      SD_LINK_OK_IN		=> link_ok(0),
      SD_LOS_IN         => link_error(8),
      SD_TXCLK_BAD_IN   => link_error(5),
      SD_RXCLK_BAD_IN   => link_error(4),
      SD_RETRY_IN       => '0', -- '0' = handle byte swapping in logic, '1' = simply restart link and hope
      SD_ALIGNMENT_IN	=> rx_k_q,
      SD_CV_IN          => link_error(7 downto 6),
      FULL_RESET_OUT    => quad_rst,
      LANE_RESET_OUT    => lane_rst,
      TX_ALLOW_OUT      => tx_allow,
      RX_ALLOW_OUT      => rx_allow,
      SWAP_BYTES_OUT    => swap_bytes,
      STAT_OP           => buf_stat_op,
      CTRL_OP           => ctrl_op,
      STAT_DEBUG        => buf_stat_debug
      );

sd_txdis_out <= quad_rst;

--------------------------------------------------------------------------
--------------------------------------------------------------------------

ffc_quad_rst         <= quad_rst;
ffc_lane_tx_rst      <= lane_rst;
ffc_lane_rx_rst      <= lane_rst;

-- SerDes clock output to FPGA fabric
refclk2core_out <= refck2core;

-- Instantiation of serdes module
  gen_serdes_0 : if SERDES_NUM = 0 and EXT_CLOCK = c_NO generate
    THE_SERDES: serdes_sfp_0
      port map(
             core_txrefclk          => clk,
             core_rxrefclk          => clk,
              hdinp0                 => sd_rxd_p_in,
              hdinn0                 => sd_rxd_n_in,
              ff_rxiclk_ch0          => ff_rxhalfclk,
              ff_txiclk_ch0          => ff_txhalfclk,
              ff_ebrd_clk_0          => ff_rxhalfclk, -- not used, just for completeness
              ff_txdata_ch0          => tx_data,
              ff_tx_k_cntrl_ch0      => tx_k,
              ff_force_disp_ch0      => "00",
              ff_disp_sel_ch0        => "00",
              ff_correct_disp_ch0    => "00",
              ffc_rrst_ch0           => '0',
              ffc_lane_tx_rst_ch0    => ffc_lane_tx_rst,
              ffc_lane_rx_rst_ch0    => ffc_lane_rx_rst,
              ffc_txpwdnb_ch0        => '1',
              ffc_rxpwdnb_ch0        => '1',
              ffc_macro_rst          => '0',
              ffc_quad_rst           => ffc_quad_rst,
              ffc_trst               => '0',
              hdoutp0                => sd_txd_p_out,
              hdoutn0                => sd_txd_n_out,
              ff_rxdata_ch0          => comb_rx_data, --rx_data,
              ff_rx_k_cntrl_ch0      => comb_rx_k, --rx_k,
              ff_rxfullclk_ch0       => open,
              ff_rxhalfclk_ch0       => ff_rxhalfclk,
              ff_disp_err_ch0        => open,
              ff_cv_ch0              => link_error(7 downto 6),
              ffs_rlos_lo_ch0        => link_error(8),
              ffs_ls_sync_status_ch0 => link_ok(0),
              ffs_cc_underrun_ch0    => link_error(0),
              ffs_cc_overrun_ch0     => link_error(1),
              ffs_txfbfifo_error_ch0 => link_error(2),
              ffs_rxfbfifo_error_ch0 => link_error(3),
              ffs_rlol_ch0           => link_error(4),
              oob_out_ch0            => open,
              ff_txfullclk           => open,
              ff_txhalfclk           => ff_txhalfclk,
              refck2core             => refck2core,
              ffs_plol               => link_error(5)
            );
  end generate;
  gen_serdes_0_ext : if SERDES_NUM = 0 and EXT_CLOCK = c_YES generate
    THE_SERDES: serdes_sfp_0_extclock
      port map(
              refclkp          => SD_REFCLK_P_IN,
              refclkn          => SD_REFCLK_N_IN,
              hdinp0                 => sd_rxd_p_in,
              hdinn0                 => sd_rxd_n_in,
              ff_rxiclk_ch0          => ff_rxhalfclk,
              ff_txiclk_ch0          => ff_txhalfclk,
              ff_ebrd_clk_0          => ff_rxhalfclk, -- not used, just for completeness
              ff_txdata_ch0          => tx_data,
              ff_tx_k_cntrl_ch0      => tx_k,
              ff_force_disp_ch0      => "00",
              ff_disp_sel_ch0        => "00",
              ff_correct_disp_ch0    => "00",
              ffc_rrst_ch0           => '0',
              ffc_lane_tx_rst_ch0    => ffc_lane_tx_rst,
              ffc_lane_rx_rst_ch0    => ffc_lane_rx_rst,
              ffc_txpwdnb_ch0        => '1',
              ffc_rxpwdnb_ch0        => '1',
              ffc_macro_rst          => '0',
              ffc_quad_rst           => ffc_quad_rst,
              ffc_trst               => '0',
              hdoutp0                => sd_txd_p_out,
              hdoutn0                => sd_txd_n_out,
              ff_rxdata_ch0          => comb_rx_data, --rx_data,
              ff_rx_k_cntrl_ch0      => comb_rx_k, --rx_k,
              ff_rxfullclk_ch0       => open,
              ff_rxhalfclk_ch0       => ff_rxhalfclk,
              ff_disp_err_ch0        => open,
              ff_cv_ch0              => link_error(7 downto 6),
              ffs_rlos_lo_ch0        => link_error(8),
              ffs_ls_sync_status_ch0 => link_ok(0),
              ffs_cc_underrun_ch0    => link_error(0),
              ffs_cc_overrun_ch0     => link_error(1),
              ffs_txfbfifo_error_ch0 => link_error(2),
              ffs_rxfbfifo_error_ch0 => link_error(3),
              ffs_rlol_ch0           => link_error(4),
              oob_out_ch0            => open,
              ff_txfullclk           => open,
              ff_txhalfclk           => ff_txhalfclk,
              refck2core             => refck2core,
              ffs_plol               => link_error(5)
            );
  end generate;

  gen_serdes_1 : if SERDES_NUM = 1 generate
    THE_SERDES: serdes_sfp_1
      port map(
              core_txrefclk          => clk,
              core_rxrefclk          => clk,
              hdinp1                 => sd_rxd_p_in,
              hdinn1                 => sd_rxd_n_in,
              ff_rxiclk_ch1          => ff_rxhalfclk,
              ff_txiclk_ch1          => ff_txhalfclk,
              ff_ebrd_clk_1          => ff_rxhalfclk, -- not used, just for completeness
              ff_txdata_ch1          => tx_data,
              ff_tx_k_cntrl_ch1      => tx_k,
              ff_force_disp_ch1      => "00",
              ff_disp_sel_ch1        => "00",
              ff_correct_disp_ch1    => "00",
              ffc_rrst_ch1           => '0',
              ffc_lane_tx_rst_ch1    => ffc_lane_tx_rst,
              ffc_lane_rx_rst_ch1    => ffc_lane_rx_rst,
              ffc_txpwdnb_ch1        => '1',
              ffc_rxpwdnb_ch1        => '1',
              ffc_macro_rst          => '0',
              ffc_quad_rst           => ffc_quad_rst,
              ffc_trst               => '0',
              hdoutp1                => sd_txd_p_out,
              hdoutn1                => sd_txd_n_out,
              ff_rxdata_ch1          => comb_rx_data, --rx_data,
              ff_rx_k_cntrl_ch1      => comb_rx_k, --rx_k,
              ff_rxfullclk_ch1       => open,
              ff_rxhalfclk_ch1       => ff_rxhalfclk,
              ff_disp_err_ch1        => open,
              ff_cv_ch1              => link_error(7 downto 6),
              ffs_rlos_lo_ch1        => link_error(8),
              ffs_ls_sync_status_ch1 => link_ok(0),
              ffs_cc_underrun_ch1    => link_error(0),
              ffs_cc_overrun_ch1     => link_error(1),
              ffs_txfbfifo_error_ch1 => link_error(2),
              ffs_rxfbfifo_error_ch1 => link_error(3),
              ffs_rlol_ch1           => link_error(4),
              oob_out_ch1            => open,
              ff_txfullclk           => open,
              ff_txhalfclk           => ff_txhalfclk,
              refck2core             => refck2core,
              ffs_plol               => link_error(5)
            );
  end generate;
  gen_serdes_2 : if SERDES_NUM = 2 generate
    THE_SERDES: serdes_sfp_2
      port map(
              core_txrefclk          => clk,
              core_rxrefclk          => clk,
              hdinp2                 => sd_rxd_p_in,
              hdinn2                 => sd_rxd_n_in,
              ff_rxiclk_ch2          => ff_rxhalfclk,
              ff_txiclk_ch2          => ff_txhalfclk,
              ff_ebrd_clk_2          => ff_rxhalfclk, -- not used, just for completeness
              ff_txdata_ch2          => tx_data,
              ff_tx_k_cntrl_ch2      => tx_k,
              ff_force_disp_ch2      => "00",
              ff_disp_sel_ch2        => "00",
              ff_correct_disp_ch2    => "00",
              ffc_rrst_ch2           => '0',
              ffc_lane_tx_rst_ch2    => ffc_lane_tx_rst,
              ffc_lane_rx_rst_ch2    => ffc_lane_rx_rst,
              ffc_txpwdnb_ch2        => '1',
              ffc_rxpwdnb_ch2        => '1',
              ffc_macro_rst          => '0',
              ffc_quad_rst           => ffc_quad_rst,
              ffc_trst               => '0',
              hdoutp2                => sd_txd_p_out,
              hdoutn2                => sd_txd_n_out,
              ff_rxdata_ch2          => comb_rx_data, --rx_data,
              ff_rx_k_cntrl_ch2      => comb_rx_k, --rx_k,
              ff_rxfullclk_ch2       => open,
              ff_rxhalfclk_ch2       => ff_rxhalfclk,
              ff_disp_err_ch2        => open,
              ff_cv_ch2              => link_error(7 downto 6),
              ffs_rlos_lo_ch2        => link_error(8),
              ffs_ls_sync_status_ch2 => link_ok(0),
              ffs_cc_underrun_ch2    => link_error(0),
              ffs_cc_overrun_ch2     => link_error(1),
              ffs_txfbfifo_error_ch2 => link_error(2),
              ffs_rxfbfifo_error_ch2 => link_error(3),
              ffs_rlol_ch2           => link_error(4),
              oob_out_ch2            => open,
              ff_txfullclk           => open,
              ff_txhalfclk           => ff_txhalfclk,
              refck2core             => refck2core,
              ffs_plol               => link_error(5)
            );
  end generate;
  gen_serdes_3 : if SERDES_NUM = 3 generate
    THE_SERDES: serdes_sfp_3
      port map(
              core_txrefclk          => clk,
              core_rxrefclk          => clk,
              hdinp3                 => sd_rxd_p_in,
              hdinn3                 => sd_rxd_n_in,
              ff_rxiclk_ch3          => ff_rxhalfclk,
              ff_txiclk_ch3          => ff_txhalfclk,
              ff_ebrd_clk_3          => ff_rxhalfclk, -- not used, just for completeness
              ff_txdata_ch3          => tx_data,
              ff_tx_k_cntrl_ch3      => tx_k,
              ff_force_disp_ch3      => "00",
              ff_disp_sel_ch3        => "00",
              ff_correct_disp_ch3    => "00",
              ffc_rrst_ch3           => '0',
              ffc_lane_tx_rst_ch3    => ffc_lane_tx_rst,
              ffc_lane_rx_rst_ch3    => ffc_lane_rx_rst,
              ffc_txpwdnb_ch3        => '1',
              ffc_rxpwdnb_ch3        => '1',
              ffc_macro_rst          => '0',
              ffc_quad_rst           => ffc_quad_rst,
              ffc_trst               => '0',
              hdoutp3                => sd_txd_p_out,
              hdoutn3                => sd_txd_n_out,
              ff_rxdata_ch3          => comb_rx_data, --rx_data,
              ff_rx_k_cntrl_ch3      => comb_rx_k, --rx_k,
              ff_rxfullclk_ch3       => open,
              ff_rxhalfclk_ch3       => ff_rxhalfclk,
              ff_disp_err_ch3        => open,
              ff_cv_ch3              => link_error(7 downto 6),
              ffs_rlos_lo_ch3        => link_error(8),
              ffs_ls_sync_status_ch3 => link_ok(0),
              ffs_cc_underrun_ch3    => link_error(0),
              ffs_cc_overrun_ch3     => link_error(1),
              ffs_txfbfifo_error_ch3 => link_error(2),
              ffs_rxfbfifo_error_ch3 => link_error(3),
              ffs_rlol_ch3           => link_error(4),
              oob_out_ch3            => open,
              ff_txfullclk           => open,
              ff_txhalfclk           => ff_txhalfclk,
              refck2core             => refck2core,
              ffs_plol               => link_error(5)
            );
  end generate;


-------------------------------------------------------------------------
-- RX Fifo & Data output
-------------------------------------------------------------------------
THE_FIFO_SFP_TO_FPGA: trb_net_fifo_16bit_bram_dualport
generic map(
  USE_STATUS_FLAGS => c_NO
       )
port map( read_clock_in  => sysclk,
      write_clock_in     => ff_rxhalfclk,
      read_enable_in     => fifo_rx_rd_en,
      write_enable_in    => fifo_rx_wr_en,
      fifo_gsr_in        => fifo_rx_reset,
      write_data_in      => fifo_rx_din,
      read_data_out      => fifo_rx_dout,
      full_out           => fifo_rx_full,
      empty_out          => fifo_rx_empty
    );

fifo_rx_reset <= reset_i or not rx_allow_q;
fifo_rx_rd_en <= '1';

-- Received bytes need to be swapped if the SerDes is "off by one" in its internal 8bit path
THE_BYTE_SWAP_PROC: process( ff_rxhalfclk )
begin
  if( rising_edge(ff_rxhalfclk) ) then
    last_rx <= rx_k(1) & rx_data(15 downto 8);
    if( swap_bytes = '0' ) then
      fifo_rx_din   <= rx_k(1) & rx_k(0) & rx_data(15 downto 8) & rx_data(7 downto 0);
      fifo_rx_wr_en <= not rx_k(0) and rx_allow and link_ok(0);
    else
      fifo_rx_din   <= rx_k(0) & last_rx(8) & rx_data(7 downto 0) & last_rx(7 downto 0);
      fifo_rx_wr_en <= not last_rx(8) and rx_allow and link_ok(0);
    end if;
  end if;
end process THE_BYTE_SWAP_PROC;

buf_med_data_out          <= fifo_rx_dout(15 downto 0);
buf_med_dataready_out     <= not fifo_rx_dout(17) and not fifo_rx_dout(16) and not last_fifo_rx_empty and rx_allow_q;
buf_med_packet_num_out    <= rx_counter;
med_read_out              <= tx_allow_q;

THE_SYNC_PROC: process( sysclk )
begin
  if( rising_edge(sysclk) ) then
    if reset_i = '1' then
      med_dataready_out <= '0';
    else
      med_dataready_out     <= buf_med_dataready_out;
      med_data_out          <= buf_med_data_out;
      med_packet_num_out    <= buf_med_packet_num_out;
    end if;
  end if;
end process THE_SYNC_PROC;

--rx packet counter
---------------------
THE_RX_PACKETS_PROC: process( sysclk )
begin
  if( rising_edge(sysclk) ) then
    last_fifo_rx_empty <= fifo_rx_empty;
    if reset_i = '1' or rx_allow_q = '0' then
      rx_counter <= c_H0;
    else
      if( buf_med_dataready_out = '1' ) then
        if( rx_counter = c_max_word_number ) then
          rx_counter <= (others => '0');
        else
          rx_counter <= rx_counter + 1;
        end if;
      end if;
    end if;
  end if;
end process;

--TX Fifo & Data output to Serdes
---------------------
THE_FIFO_FPGA_TO_SFP: trb_net_fifo_16bit_bram_dualport
generic map(
  USE_STATUS_FLAGS => c_NO
       )
port map( read_clock_in => ff_txhalfclk,
      write_clock_in    => sysclk,
      read_enable_in    => fifo_tx_rd_en,
      write_enable_in   => fifo_tx_wr_en,
      fifo_gsr_in       => fifo_tx_reset,
      write_data_in     => fifo_tx_din,
      read_data_out     => fifo_tx_dout,
      full_out          => fifo_tx_full,
      empty_out         => fifo_tx_empty
    );

fifo_tx_reset <= reset_i or not tx_allow_q;
fifo_tx_din   <= med_packet_num_in(2) & med_packet_num_in(0)& med_data_in;
fifo_tx_wr_en <= med_dataready_in and tx_allow_q;
fifo_tx_rd_en <= tx_allow;


THE_SERDES_INPUT_PROC: process( ff_txhalfclk )
begin
  if( rising_edge(ff_txhalfclk) ) then
  last_fifo_tx_empty <= fifo_tx_empty;
    if( (last_fifo_tx_empty = '1') or (tx_allow = '0') ) then
      tx_data <= x"50bc";
      tx_k <= "01";
--    elsif send_resync = '1' then
--      tx_data <= x"7F7F";
--      tx_k <= "00";
    else
      tx_data <= fifo_tx_dout(15 downto 0);
      tx_k <= "00";
    end if;
  end if;
end process THE_SERDES_INPUT_PROC;

--


--Generate LED signals
----------------------
process(sysclk)
  begin
    if rising_edge(sysclk) then
      led_counter <= led_counter + 1;

      if buf_med_dataready_out = '1' then
        rx_led <= '1';
      elsif led_counter = 0 then
        rx_led <= '0';
      end if;

      if tx_k(0) = '0' then -- tx_k clock domain crossing!
        tx_led <= '1';
      elsif led_counter = 0 then
        tx_led <= '0';
      end if;

    end if;
  end process;

stat_op(15 downto 12) <= buf_stat_op(15 downto 12);
stat_op(11)           <= tx_led; --tx led
stat_op(10)           <= rx_led; --rx led
stat_op(9 downto 0)   <= buf_stat_op(9 downto 0);

-- Debug output
stat_debug(3 downto 0)   <= buf_stat_debug(3 downto 0); -- state_bits
stat_debug(4)            <= buf_stat_debug(4); -- alignme
stat_debug(5)            <= sfp_prsnt_n;
stat_debug(6)            <= tx_k(0);
stat_debug(7)            <= tx_k(1);
stat_debug(8)            <= rx_k_q(0);
stat_debug(9)            <= rx_k_q(1);
--stat_debug(9 downto 7)   <= (others => '0');
stat_debug(18 downto 10) <= link_error;
stat_debug(19)           <= '0';
stat_debug(20)           <= link_ok(0);
stat_debug(38 downto 21) <= fifo_rx_din;
stat_debug(39)           <= swap_bytes;
stat_debug(40)           <= buf_stat_debug(7); -- sfp_missing_in
stat_debug(41)           <= buf_stat_debug(8); -- sfp_los_in
stat_debug(42)           <= buf_stat_debug(6); -- resync
stat_debug(59 downto 43) <= (others => '0');
stat_debug(63 downto 60) <= link_error(3 downto 0);

end architecture;