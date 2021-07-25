--Media interface for Lattice ECP2M using PCS at 2GHz


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity trb_net16_med_ecp_sfp_4 is
  generic(
    REVERSE_ORDER : integer range 0 to 1 := c_NO
  --  USED_PORTS : std_logic-vector(3 downto 0) := "1111"
    );
  port(
    CLK          : in  std_logic; -- SerDes clock
    SYSCLK       : in  std_logic; -- fabric clock
    RESET        : in  std_logic; -- synchronous reset
    CLEAR        : in  std_logic; -- asynchronous reset
    CLK_EN       : in  std_logic;
    --Internal Connection
    MED_DATA_IN        : in  std_logic_vector(4*c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN  : in  std_logic_vector(4*c_NUM_WIDTH-1 downto 0);
    MED_DATAREADY_IN   : in  std_logic_vector(3 downto 0);
    MED_READ_OUT       : out std_logic_vector(3 downto 0);
    MED_DATA_OUT       : out std_logic_vector(4*c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT : out std_logic_vector(4*c_NUM_WIDTH-1 downto 0);
    MED_DATAREADY_OUT  : out std_logic_vector(3 downto 0);
    MED_READ_IN        : in  std_logic_vector(3 downto 0);
    REFCLK2CORE_OUT    : out std_logic;
    --SFP Connection
    SD_RXD_P_IN        : in  std_logic_vector(3 downto 0);
    SD_RXD_N_IN        : in  std_logic_vector(3 downto 0);
    SD_TXD_P_OUT       : out std_logic_vector(3 downto 0);
    SD_TXD_N_OUT       : out std_logic_vector(3 downto 0);
    SD_REFCLK_P_IN     : in  std_logic;
    SD_REFCLK_N_IN     : in  std_logic;
    SD_PRSNT_N_IN      : in  std_logic_vector(3 downto 0); -- SFP Present ('0' = SFP in place, '1' = no SFP mounted)
    SD_LOS_IN          : in  std_logic_vector(3 downto 0); -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
    SD_TXDIS_OUT       : out  std_logic; -- SFP disable
    -- Status and control port
    STAT_OP            : out  std_logic_vector (4*16-1 downto 0);
    CTRL_OP            : in  std_logic_vector (4*16-1 downto 0);
    STAT_DEBUG         : out  std_logic_vector (64*4-1 downto 0);
    CTRL_DEBUG         : in  std_logic_vector (63 downto 0)
   );
end entity;

architecture med_ecp_sfp_4 of trb_net16_med_ecp_sfp_4 is

  -- Placer Directives
  attribute HGROUP : string;
  -- for whole architecture
  attribute HGROUP of med_ecp_sfp_4 : architecture  is "media_interface_group";
  attribute syn_sharing : string;
  attribute syn_sharing of med_ecp_sfp_4 : architecture is "off";

component serdes_sfp_full_quad is
  generic(
    USER_CONFIG_FILE    :  String := "serdes_sfp_full_quad.txt" );
  port(
    core_txrefclk : in std_logic;
    core_rxrefclk : in std_logic;

    hdinp0 : in std_logic;
    hdinn0 : in std_logic;
    hdoutp0 : out std_logic;
    hdoutn0 : out std_logic;
    ff_rxiclk_ch0 : in std_logic;
    ff_txiclk_ch0 : in std_logic;
    ff_ebrd_clk_0 : in std_logic;
    ff_txdata_ch0 : in std_logic_vector (15 downto 0);
    ff_rxdata_ch0 : out std_logic_vector (15 downto 0);
    ff_tx_k_cntrl_ch0 : in std_logic_vector (1 downto 0);
    ff_rx_k_cntrl_ch0 : out std_logic_vector (1 downto 0);
    ff_rxfullclk_ch0 : out std_logic;
    ff_rxhalfclk_ch0 : out std_logic;
    ff_force_disp_ch0 : in std_logic_vector (1 downto 0);
    ff_disp_sel_ch0 : in std_logic_vector (1 downto 0);
    ff_correct_disp_ch0 : in std_logic_vector (1 downto 0);
    ff_disp_err_ch0 : out std_logic_vector (1 downto 0);
    ff_cv_ch0 : out std_logic_vector (1 downto 0);
    ffc_rrst_ch0 : in std_logic;
    ffc_lane_tx_rst_ch0 : in std_logic;
    ffc_lane_rx_rst_ch0 : in std_logic;
    ffc_txpwdnb_ch0 : in std_logic;
    ffc_rxpwdnb_ch0 : in std_logic;
    ffs_rlos_lo_ch0 : out std_logic;
    ffs_ls_sync_status_ch0 : out std_logic;
    ffs_cc_underrun_ch0 : out std_logic;
    ffs_cc_overrun_ch0 : out std_logic;
    ffs_txfbfifo_error_ch0 : out std_logic;
    ffs_rxfbfifo_error_ch0 : out std_logic;
    ffs_rlol_ch0 : out std_logic;
    oob_out_ch0 : out std_logic;

    hdinp1 : in std_logic;
    hdinn1 : in std_logic;
    hdoutp1 : out std_logic;
    hdoutn1 : out std_logic;
    ff_rxiclk_ch1 : in std_logic;
    ff_txiclk_ch1 : in std_logic;
    ff_ebrd_clk_1 : in std_logic;
    ff_txdata_ch1 : in std_logic_vector (15 downto 0);
    ff_rxdata_ch1 : out std_logic_vector (15 downto 0);
    ff_tx_k_cntrl_ch1 : in std_logic_vector (1 downto 0);
    ff_rx_k_cntrl_ch1 : out std_logic_vector (1 downto 0);
    ff_rxfullclk_ch1 : out std_logic;
    ff_rxhalfclk_ch1 : out std_logic;
    ff_force_disp_ch1 : in std_logic_vector (1 downto 0);
    ff_disp_sel_ch1 : in std_logic_vector (1 downto 0);
    ff_correct_disp_ch1 : in std_logic_vector (1 downto 0);
    ff_disp_err_ch1 : out std_logic_vector (1 downto 0);
    ff_cv_ch1 : out std_logic_vector (1 downto 0);
    ffc_rrst_ch1 : in std_logic;
    ffc_lane_tx_rst_ch1 : in std_logic;
    ffc_lane_rx_rst_ch1 : in std_logic;
    ffc_txpwdnb_ch1 : in std_logic;
    ffc_rxpwdnb_ch1 : in std_logic;
    ffs_rlos_lo_ch1 : out std_logic;
    ffs_ls_sync_status_ch1 : out std_logic;
    ffs_cc_underrun_ch1 : out std_logic;
    ffs_cc_overrun_ch1 : out std_logic;
    ffs_txfbfifo_error_ch1 : out std_logic;
    ffs_rxfbfifo_error_ch1 : out std_logic;
    ffs_rlol_ch1 : out std_logic;
    oob_out_ch1 : out std_logic;

    hdinp2 : in std_logic;
    hdinn2 : in std_logic;
    hdoutp2 : out std_logic;
    hdoutn2 : out std_logic;
    ff_rxiclk_ch2 : in std_logic;
    ff_txiclk_ch2 : in std_logic;
    ff_ebrd_clk_2 : in std_logic;
    ff_txdata_ch2 : in std_logic_vector (15 downto 0);
    ff_rxdata_ch2 : out std_logic_vector (15 downto 0);
    ff_tx_k_cntrl_ch2 : in std_logic_vector (1 downto 0);
    ff_rx_k_cntrl_ch2 : out std_logic_vector (1 downto 0);
    ff_rxfullclk_ch2 : out std_logic;
    ff_rxhalfclk_ch2 : out std_logic;
    ff_force_disp_ch2 : in std_logic_vector (1 downto 0);
    ff_disp_sel_ch2 : in std_logic_vector (1 downto 0);
    ff_correct_disp_ch2 : in std_logic_vector (1 downto 0);
    ff_disp_err_ch2 : out std_logic_vector (1 downto 0);
    ff_cv_ch2 : out std_logic_vector (1 downto 0);
    ffc_rrst_ch2 : in std_logic;
    ffc_lane_tx_rst_ch2 : in std_logic;
    ffc_lane_rx_rst_ch2 : in std_logic;
    ffc_txpwdnb_ch2 : in std_logic;
    ffc_rxpwdnb_ch2 : in std_logic;
    ffs_rlos_lo_ch2 : out std_logic;
    ffs_ls_sync_status_ch2 : out std_logic;
    ffs_cc_underrun_ch2 : out std_logic;
    ffs_cc_overrun_ch2 : out std_logic;
    ffs_txfbfifo_error_ch2 : out std_logic;
    ffs_rxfbfifo_error_ch2 : out std_logic;
    ffs_rlol_ch2 : out std_logic;
    oob_out_ch2 : out std_logic;

    hdinp3 : in std_logic;
    hdinn3 : in std_logic;
    hdoutp3 : out std_logic;
    hdoutn3 : out std_logic;
    ff_rxiclk_ch3 : in std_logic;
    ff_txiclk_ch3 : in std_logic;
    ff_ebrd_clk_3 : in std_logic;
    ff_txdata_ch3 : in std_logic_vector (15 downto 0);
    ff_rxdata_ch3 : out std_logic_vector (15 downto 0);
    ff_tx_k_cntrl_ch3 : in std_logic_vector (1 downto 0);
    ff_rx_k_cntrl_ch3 : out std_logic_vector (1 downto 0);
    ff_rxfullclk_ch3 : out std_logic;
    ff_rxhalfclk_ch3 : out std_logic;
    ff_force_disp_ch3 : in std_logic_vector (1 downto 0);
    ff_disp_sel_ch3 : in std_logic_vector (1 downto 0);
    ff_correct_disp_ch3 : in std_logic_vector (1 downto 0);
    ff_disp_err_ch3 : out std_logic_vector (1 downto 0);
    ff_cv_ch3 : out std_logic_vector (1 downto 0);
    ffc_rrst_ch3 : in std_logic;
    ffc_lane_tx_rst_ch3 : in std_logic;
    ffc_lane_rx_rst_ch3 : in std_logic;
    ffc_txpwdnb_ch3 : in std_logic;
    ffc_rxpwdnb_ch3 : in std_logic;
    ffs_rlos_lo_ch3 : out std_logic;
    ffs_ls_sync_status_ch3 : out std_logic;
    ffs_cc_underrun_ch3 : out std_logic;
    ffs_cc_overrun_ch3 : out std_logic;
    ffs_txfbfifo_error_ch3 : out std_logic;
    ffs_rxfbfifo_error_ch3 : out std_logic;
    ffs_rlol_ch3 : out std_logic;
    oob_out_ch3 : out std_logic;

    ffc_macro_rst : in std_logic;
    ffc_quad_rst : in std_logic;
    ffc_trst : in std_logic;
    ff_txfullclk : out std_logic;
    ff_txhalfclk : out std_logic;
    refck2core : out std_logic;
    ffs_plol : out std_logic
    );
  end component;



  type link_error_t is array(0 to 3) of std_logic_vector(9 downto 0);
  signal link_error      : link_error_t;

  signal refck2core      : std_logic;
  signal clock           : std_logic;
  signal reset_i         : std_logic_vector(3 downto 0);
  --serdes connections
  signal tx_data        : std_logic_vector(4*16-1 downto 0);
  signal tx_k          : std_logic_vector(7 downto 0);
  signal rx_data        : std_logic_vector(4*16-1 downto 0);
  signal rx_k          : std_logic_vector(7 downto 0);
  signal link_ok        : std_logic_vector(3 downto 0);
  signal comb_rx_data           : std_logic_vector(4*16 downto 0); -- original signals from SFP
  signal comb_rx_k              : std_logic_vector(7 downto 0);  -- original signals from SFP
  signal ff_rxhalfclk      : std_logic_vector(3 downto 0);
  signal ff_rxhalfclk_falling: std_logic_vector(3 downto 0);
  signal ff_txhalfclk      : std_logic;
  --rx fifo signals
  signal fifo_rx_rd_en    : std_logic_vector(3 downto 0);
  signal fifo_rx_wr_en    : std_logic_vector(3 downto 0);
  signal fifo_rx_reset    : std_logic_vector(3 downto 0);
  signal fifo_rx_din      : std_logic_vector(4*18-1 downto 0);
  signal fifo_rx_dout      : std_logic_vector(4*18-1 downto 0);
  signal fifo_rx_full      : std_logic_vector(3 downto 0);
  signal fifo_rx_empty    : std_logic_vector(3 downto 0);
  --tx fifo signals
  signal fifo_tx_rd_en    : std_logic_vector(3 downto 0);
  signal fifo_tx_wr_en    : std_logic_vector(3 downto 0);
  signal fifo_tx_reset    : std_logic_vector(3 downto 0);
  signal fifo_tx_din      : std_logic_vector(4*18-1 downto 0);
  signal fifo_tx_dout      : std_logic_vector(4*18-1 downto 0);
  signal fifo_tx_full      : std_logic_vector(3 downto 0);
  signal fifo_tx_empty    : std_logic_vector(3 downto 0);
  --rx path
  signal rx_counter        : std_logic_vector(4*c_NUM_WIDTH-1 downto 0);
  signal buf_med_dataready_out  : std_logic_vector(3 downto 0);
  signal buf_med_data_out      : std_logic_vector(4*c_DATA_WIDTH-1 downto 0);
  signal buf_med_packet_num_out  : std_logic_vector(4*c_NUM_WIDTH-1 downto 0);
  signal last_rx          : std_logic_vector(4*9-1 downto 0);
  signal last_fifo_rx_empty    : std_logic_vector(3 downto 0);
  --tx path
  signal last_fifo_tx_empty    : std_logic_vector(3 downto 0);
  --link status
  signal rx_k_q            : std_logic_vector(4*2-1 downto 0);
  signal ffs_plol : std_logic;

  signal quad_rst      : std_logic_vector(3 downto 0);
  signal lane_rst      : std_logic_vector(3 downto 0);
  signal tx_allow      : std_logic_vector(3 downto 0);
  signal rx_allow      : std_logic_vector(3 downto 0);
  signal rx_allow_qrx  : std_logic_vector(3 downto 0);
--  signal tx_allow_qtx  : std_logic_vector(3 downto 0);

  signal rx_allow_q        : std_logic_vector(3 downto 0); -- clock domain changed signal
  signal tx_allow_q        : std_logic_vector(3 downto 0);
  signal swap_bytes        : std_logic_vector(3 downto 0);
  signal swap_bytes_qrx    : std_logic_vector(3 downto 0);
  signal FSM_STAT_DEBUG    : std_logic_vector(4*32-1 downto 0);
  signal FSM_STAT_OP       : std_logic_vector(4*16-1 downto 0);
  signal FSM_CTRL_OP       : std_logic_vector(4*16-1 downto 0);

  -- status inputs from SFP
  signal sfp_prsnt_n       : std_logic_vector(3 downto 0); -- synchronized input signals
  signal sfp_los           : std_logic_vector(3 downto 0); -- synchronized input signals
  signal pwr_up            : std_logic_vector(3 downto 0);

  signal led_counter    : std_logic_vector(16 downto 0);
  signal rx_led, tx_led       : std_logic_vector(3 downto 0);
  attribute syn_keep : boolean;
  attribute syn_keep of led_counter : signal is true;

begin

--------------------------------------------------------------------------
-- Internal Lane Resets
--------------------------------------------------------------------------

  gen_reset_i : for i in 0 to 3 generate
    PROC_RESET : process(SYSCLK)
    begin
      if rising_edge(SYSCLK) then
        reset_i(i) <= RESET or CTRL_OP(i*16+14);
        pwr_up(i)  <= '1'; --not CTRL_OP(i*16+14);
      end if;
    end process;
  end generate;


--------------------------------------------------------------------------
-- Clock Domain Transfers, Input Synchronizer
--------------------------------------------------------------------------

  gen_data_lines : for i in 0 to 3 generate

-- Input synchronizer
    THE_SFP_STATUS_SYNC: signal_sync
      generic map(
        DEPTH => 3,
        WIDTH => 2
        )
      port map(
        RESET    => reset_i(i),
        D_IN(0)  => SD_PRSNT_N_IN(i),
        D_IN(1)  => SD_LOS_IN(i),
        CLK0     => SYSCLK,
        CLK1     => SYSCLK,
        D_OUT(0) => sfp_prsnt_n(i),
        D_OUT(1) => sfp_los(i)
        );

-- Transfering the komma delimiter in the *training* phase
    THE_RX_K_SYNC: signal_sync
      generic map(
        DEPTH => 3,
        WIDTH => 2
        )
      port map(
        RESET    => reset_i(i),
        D_IN     => comb_rx_k(i*2+1 downto i*2),
        CLK0     => ff_rxhalfclk(i),
        CLK1     => SYSCLK,
        D_OUT    => rx_k_q(i*2+1 downto i*2)
        );


-- registers for RX_K and RX_DATA between serdes and internal logic
    THE_RX_DATA_DELAY: signal_sync
      generic map(
        DEPTH => 2,
        WIDTH => 18
        )
      port map(
        RESET    => reset_i(i),
        D_IN(15 downto 0) => comb_rx_data(i*16+15 downto i*16),
        D_IN(17 downto 16)=> comb_rx_k(i*2+1 downto i*2),
        CLK0     => ff_rxhalfclk(i),
        CLK1     => ff_rxhalfclk(i),
        D_OUT(15 downto 0)    => rx_data(i*16+15 downto i*16),
        D_OUT(17 downto 16)   => rx_k(i*2+1 downto i*2)
        );

--delay signals for sending and receiving data
    THE_RX_ALLOW_SYNC: signal_sync
      generic map(
        DEPTH => 2,
        WIDTH => 2
        )
      port map(
        RESET    => reset_i(i),
        D_IN(0)  => rx_allow(i),
        D_IN(1)  => tx_allow(i),
        CLK0     => sysclk,
        CLK1     => sysclk,
        D_OUT(0) => rx_allow_q(i),
        D_OUT(1) => tx_allow_q(i)
        );

--transfer rx enable signal to rx clock domain
    THE_RX_ALLOW_SYNC_RX: signal_sync
      generic map(
        DEPTH => 2,
        WIDTH => 2
        )
      port map(
        RESET    => reset_i(i),
        D_IN(0)  => rx_allow(i),
        D_IN(1)  => swap_bytes(i),
        CLK0     => ff_rxhalfclk(i),
        CLK1     => ff_rxhalfclk(i),
        D_OUT(0) => rx_allow_qrx(i),
        D_OUT(1) => swap_bytes_qrx(i)
        );




----------------------------------------------------------------------------------------------------------
-- Link State Machine: Resets for Serdes, enable signals for internal logic
----------------------------------------------------------------------------------------------------------
    THE_SFP_LSM: trb_net16_lsm_sfp
        port map(
          SYSCLK            => SYSCLK,
          RESET             => reset_i(i),
          CLEAR             => clear,
          SFP_MISSING_IN    => sfp_prsnt_n(i),
          SFP_LOS_IN        => sfp_los(i),
          SD_LINK_OK_IN     => link_ok(i),
          SD_LOS_IN         => link_error(i)(2),
          SD_TXCLK_BAD_IN   => ffs_plol,
          SD_RXCLK_BAD_IN   => link_error(i)(7),
          SD_RETRY_IN       => '0', -- '0' = handle byte swapping in logic, '1' = simply restart link and hope
          SD_ALIGNMENT_IN   => rx_k_q(i*2+1 downto i*2),
          SD_CV_IN          => link_error(i)(1 downto 0),
          FULL_RESET_OUT    => quad_rst(i),
          LANE_RESET_OUT    => lane_rst(i),
          TX_ALLOW_OUT      => tx_allow(i),
          RX_ALLOW_OUT      => rx_allow(i),
          SWAP_BYTES_OUT    => swap_bytes(i),
          STAT_OP           => FSM_STAT_OP(i*16+15 downto i*16),
          CTRL_OP           => FSM_CTRL_OP(i*16+15 downto i*16),
          STAT_DEBUG        => FSM_STAT_DEBUG(i*32+31 downto i*32)
          );


    sd_txdis_out <= quad_rst(0);

  end generate;



---------------------------------------------------------------------
-- Instantiation of serdes module
-- two different connection schemes to adapt to pcb layouts
---------------------------------------------------------------------

  gen_normal_serdes : if REVERSE_ORDER = c_NO generate
    THE_SERDES: serdes_sfp_full_quad
      port map(
        core_txrefclk        => clk,
        core_rxrefclk        => clk,
        hdinp0               => SD_RXD_P_IN(0),
        hdinn0               => SD_RXD_N_IN(0),
        hdoutp0              => SD_TXD_P_OUT(0),
        hdoutn0              => SD_TXD_N_OUT(0),
        ff_rxiclk_ch0        => ff_rxhalfclk(0),
        ff_txiclk_ch0        => ff_txhalfclk,
        ff_ebrd_clk_0        => ff_rxhalfclk(0),
        ff_txdata_ch0        => tx_data(15 downto 0),
        ff_rxdata_ch0        => comb_rx_data(15 downto 0),
        ff_tx_k_cntrl_ch0    => tx_k(1 downto 0),
        ff_rx_k_cntrl_ch0    => comb_rx_k(1 downto 0),
        ff_rxhalfclk_ch0     => ff_rxhalfclk(0),
        ff_force_disp_ch0    => "00",
        ff_disp_sel_ch0      => "00",
        ff_correct_disp_ch0  => "00",
        ff_disp_err_ch0      => link_error(0)(9 downto 8),
        ff_cv_ch0            => link_error(0)(1 downto 0),
        ffc_rrst_ch0         => '0',
        ffc_lane_tx_rst_ch0  => lane_rst(0), --lane_rst(0),
        ffc_lane_rx_rst_ch0  => lane_rst(0),
        ffc_txpwdnb_ch0      => pwr_up(0),
        ffc_rxpwdnb_ch0      => pwr_up(0),
        ffs_rlos_lo_ch0      => link_error(0)(2),
        ffs_ls_sync_status_ch0 => link_ok(0),
        ffs_cc_underrun_ch0  => link_error(0)(3),
        ffs_cc_overrun_ch0   => link_error(0)(4),
        ffs_txfbfifo_error_ch0 => link_error(0)(5),
        ffs_rxfbfifo_error_ch0 => link_error(0)(6),
        ffs_rlol_ch0         => link_error(0)(7),
        oob_out_ch0          => open,

        hdinp1               => SD_RXD_P_IN(1),
        hdinn1               => SD_RXD_N_IN(1),
        hdoutp1              => SD_TXD_P_OUT(1),
        hdoutn1              => SD_TXD_N_OUT(1),
        ff_rxiclk_ch1        => ff_rxhalfclk(1),
        ff_txiclk_ch1        => ff_txhalfclk,
        ff_ebrd_clk_1        => ff_rxhalfclk(1),
        ff_txdata_ch1        => tx_data(31 downto 16),
        ff_rxdata_ch1        => comb_rx_data(31 downto 16),
        ff_tx_k_cntrl_ch1    => tx_k(3 downto 2),
        ff_rx_k_cntrl_ch1    => comb_rx_k(3 downto 2),
        ff_rxhalfclk_ch1     => ff_rxhalfclk(1),
        ff_force_disp_ch1    => "00",
        ff_disp_sel_ch1      => "00",
        ff_correct_disp_ch1  => "00",
        ff_disp_err_ch1      => link_error(1)(9 downto 8),
        ff_cv_ch1            => link_error(1)(1 downto 0),
        ffc_rrst_ch1         => '0',
        ffc_lane_tx_rst_ch1  => lane_rst(1), --lane_rst(1),
        ffc_lane_rx_rst_ch1  => lane_rst(1),
        ffc_txpwdnb_ch1      => pwr_up(1),
        ffc_rxpwdnb_ch1      => pwr_up(1),
        ffs_rlos_lo_ch1      => link_error(1)(2),
        ffs_ls_sync_status_ch1 => link_ok(1),
        ffs_cc_underrun_ch1  => link_error(1)(3),
        ffs_cc_overrun_ch1   => link_error(1)(4),
        ffs_txfbfifo_error_ch1 => link_error(1)(5),
        ffs_rxfbfifo_error_ch1 => link_error(1)(6),
        ffs_rlol_ch1         => link_error(1)(7),
        oob_out_ch1          => open,

        hdinp2               => SD_RXD_P_IN(2),
        hdinn2               => SD_RXD_N_IN(2),
        hdoutp2              => SD_TXD_P_OUT(2),
        hdoutn2              => SD_TXD_N_OUT(2),
        ff_rxiclk_ch2        => ff_rxhalfclk(2),
        ff_txiclk_ch2        => ff_txhalfclk,
        ff_ebrd_clk_2        => ff_rxhalfclk(2),
        ff_txdata_ch2        => tx_data(47 downto 32),
        ff_rxdata_ch2        => comb_rx_data(47 downto 32),
        ff_tx_k_cntrl_ch2    => tx_k(5 downto 4),
        ff_rx_k_cntrl_ch2    => comb_rx_k(5 downto 4),
        ff_rxhalfclk_ch2     => ff_rxhalfclk(2),
        ff_force_disp_ch2    => "00",
        ff_disp_sel_ch2      => "00",
        ff_correct_disp_ch2  => "00",
        ff_disp_err_ch2      => link_error(2)(9 downto 8),
        ff_cv_ch2            => link_error(2)(1 downto 0),
        ffc_rrst_ch2         => '0',
        ffc_lane_tx_rst_ch2  => lane_rst(2), --lane_rst(2),
        ffc_lane_rx_rst_ch2  => lane_rst(2),
        ffc_txpwdnb_ch2      => pwr_up(2),
        ffc_rxpwdnb_ch2      => pwr_up(2),
        ffs_rlos_lo_ch2      => link_error(2)(2),
        ffs_ls_sync_status_ch2 => link_ok(2),
        ffs_cc_underrun_ch2  => link_error(2)(3),
        ffs_cc_overrun_ch2   => link_error(2)(4),
        ffs_txfbfifo_error_ch2 => link_error(2)(5),
        ffs_rxfbfifo_error_ch2 => link_error(2)(6),
        ffs_rlol_ch2         => link_error(2)(7),
        oob_out_ch2          => open,

        hdinp3               => SD_RXD_P_IN(3),
        hdinn3               => SD_RXD_N_IN(3),
        hdoutp3              => SD_TXD_P_OUT(3),
        hdoutn3              => SD_TXD_N_OUT(3),
        ff_rxiclk_ch3        => ff_rxhalfclk(3),
        ff_txiclk_ch3        => ff_txhalfclk,
        ff_ebrd_clk_3        => ff_rxhalfclk(3),
        ff_txdata_ch3        => tx_data(63 downto 48),
        ff_rxdata_ch3        => comb_rx_data(63 downto 48),
        ff_tx_k_cntrl_ch3    => tx_k(7 downto 6),
        ff_rx_k_cntrl_ch3    => comb_rx_k(7 downto 6),
        ff_rxhalfclk_ch3     => ff_rxhalfclk(3),
        ff_force_disp_ch3    => "00",
        ff_disp_sel_ch3      => "00",
        ff_correct_disp_ch3  => "00",
        ff_disp_err_ch3      => link_error(3)(9 downto 8),
        ff_cv_ch3            => link_error(3)(1 downto 0),
        ffc_rrst_ch3         => '0',
        ffc_lane_tx_rst_ch3  => lane_rst(3), --lane_rst(3),
        ffc_lane_rx_rst_ch3  => lane_rst(3),
        ffc_txpwdnb_ch3      => pwr_up(3),
        ffc_rxpwdnb_ch3      => pwr_up(3),
        ffs_rlos_lo_ch3      => link_error(3)(2),
        ffs_ls_sync_status_ch3 => link_ok(3),
        ffs_cc_underrun_ch3  => link_error(3)(3),
        ffs_cc_overrun_ch3   => link_error(3)(4),
        ffs_txfbfifo_error_ch3 => link_error(3)(5),
        ffs_rxfbfifo_error_ch3 => link_error(3)(6),
        ffs_rlol_ch3         => link_error(3)(7),
        oob_out_ch3          => open,

        ffc_macro_rst        => '0',
        ffc_quad_rst         => quad_rst(0),
        ffc_trst             => '0',
        ff_txhalfclk         => ff_txhalfclk,
        refck2core           => REFCLK2CORE_OUT,
        ffs_plol             => ffs_plol
        );
  end generate;

  gen_twisted_serdes : if REVERSE_ORDER = c_YES generate
    THE_SERDES: serdes_sfp_full_quad
      port map(
        core_txrefclk        => clk,
        core_rxrefclk        => clk,
        hdinp0               => SD_RXD_P_IN(0),
        hdinn0               => SD_RXD_N_IN(0),
        hdoutp0              => SD_TXD_P_OUT(0),
        hdoutn0              => SD_TXD_N_OUT(0),
        ff_rxiclk_ch0        => ff_rxhalfclk(3),
        ff_txiclk_ch0        => ff_txhalfclk,
        ff_ebrd_clk_0        => ff_rxhalfclk(3),
        ff_txdata_ch0        => tx_data(63 downto 48),
        ff_rxdata_ch0        => comb_rx_data(63 downto 48),
        ff_tx_k_cntrl_ch0    => tx_k(7 downto 6),
        ff_rx_k_cntrl_ch0    => comb_rx_k(7 downto 6),
        ff_rxhalfclk_ch0     => ff_rxhalfclk(3),
        ff_force_disp_ch0    => "00",
        ff_disp_sel_ch0      => "00",
        ff_correct_disp_ch0  => "00",
        ff_disp_err_ch0      => link_error(3)(9 downto 8),
        ff_cv_ch0            => link_error(3)(1 downto 0),
        ffc_rrst_ch0         => '0',
        ffc_lane_tx_rst_ch0  => lane_rst(3), --lane_rst(0),
        ffc_lane_rx_rst_ch0  => lane_rst(3),
        ffc_txpwdnb_ch0      => pwr_up(3),
        ffc_rxpwdnb_ch0      => pwr_up(3),
        ffs_rlos_lo_ch0      => link_error(3)(2),
        ffs_ls_sync_status_ch0 => link_ok(3),
        ffs_cc_underrun_ch0  => link_error(3)(3),
        ffs_cc_overrun_ch0   => link_error(3)(4),
        ffs_txfbfifo_error_ch0 => link_error(3)(5),
        ffs_rxfbfifo_error_ch0 => link_error(3)(6),
        ffs_rlol_ch0         => link_error(3)(7),
        oob_out_ch0          => open,

        hdinp1               => SD_RXD_P_IN(1),
        hdinn1               => SD_RXD_N_IN(1),
        hdoutp1              => SD_TXD_P_OUT(1),
        hdoutn1              => SD_TXD_N_OUT(1),
        ff_rxiclk_ch1        => ff_rxhalfclk(2),
        ff_txiclk_ch1        => ff_txhalfclk,
        ff_ebrd_clk_1        => ff_rxhalfclk(2),
        ff_txdata_ch1        => tx_data(47 downto 32),
        ff_rxdata_ch1        => comb_rx_data(47 downto 32),
        ff_tx_k_cntrl_ch1    => tx_k(5 downto 4),
        ff_rx_k_cntrl_ch1    => comb_rx_k(5 downto 4),
        ff_rxhalfclk_ch1     => ff_rxhalfclk(2),
        ff_force_disp_ch1    => "00",
        ff_disp_sel_ch1      => "00",
        ff_correct_disp_ch1  => "00",
        ff_disp_err_ch1      => link_error(2)(9 downto 8),
        ff_cv_ch1            => link_error(2)(1 downto 0),
        ffc_rrst_ch1         => '0',
        ffc_lane_tx_rst_ch1  => lane_rst(2), --lane_rst(1),
        ffc_lane_rx_rst_ch1  => lane_rst(2),
        ffc_txpwdnb_ch1      => pwr_up(2),
        ffc_rxpwdnb_ch1      => pwr_up(2),
        ffs_rlos_lo_ch1      => link_error(2)(2),
        ffs_ls_sync_status_ch1 => link_ok(2),
        ffs_cc_underrun_ch1  => link_error(2)(3),
        ffs_cc_overrun_ch1   => link_error(2)(4),
        ffs_txfbfifo_error_ch1 => link_error(2)(5),
        ffs_rxfbfifo_error_ch1 => link_error(2)(6),
        ffs_rlol_ch1         => link_error(2)(7),
        oob_out_ch1          => open,

        hdinp2               => SD_RXD_P_IN(2),
        hdinn2               => SD_RXD_N_IN(2),
        hdoutp2              => SD_TXD_P_OUT(2),
        hdoutn2              => SD_TXD_N_OUT(2),
        ff_rxiclk_ch2        => ff_rxhalfclk(1),
        ff_txiclk_ch2        => ff_txhalfclk,
        ff_ebrd_clk_2        => ff_rxhalfclk(1),
        ff_txdata_ch2        => tx_data(31 downto 16),
        ff_rxdata_ch2        => comb_rx_data(31 downto 16),
        ff_tx_k_cntrl_ch2    => tx_k(3 downto 2),
        ff_rx_k_cntrl_ch2    => comb_rx_k(3 downto 2),
        ff_rxhalfclk_ch2     => ff_rxhalfclk(1),
        ff_force_disp_ch2    => "00",
        ff_disp_sel_ch2      => "00",
        ff_correct_disp_ch2  => "00",
        ff_disp_err_ch2      => link_error(1)(9 downto 8),
        ff_cv_ch2            => link_error(1)(1 downto 0),
        ffc_rrst_ch2         => '0',
        ffc_lane_tx_rst_ch2  => lane_rst(1), --lane_rst(2),
        ffc_lane_rx_rst_ch2  => lane_rst(1),
        ffc_txpwdnb_ch2      => pwr_up(1),
        ffc_rxpwdnb_ch2      => pwr_up(1),
        ffs_rlos_lo_ch2      => link_error(1)(2),
        ffs_ls_sync_status_ch2 => link_ok(1),
        ffs_cc_underrun_ch2  => link_error(1)(3),
        ffs_cc_overrun_ch2   => link_error(1)(4),
        ffs_txfbfifo_error_ch2 => link_error(1)(5),
        ffs_rxfbfifo_error_ch2 => link_error(1)(6),
        ffs_rlol_ch2         => link_error(1)(7),
        oob_out_ch2          => open,

        hdinp3               => SD_RXD_P_IN(3),
        hdinn3               => SD_RXD_N_IN(3),
        hdoutp3              => SD_TXD_P_OUT(3),
        hdoutn3              => SD_TXD_N_OUT(3),
        ff_rxiclk_ch3        => ff_rxhalfclk(0),
        ff_txiclk_ch3        => ff_txhalfclk,
        ff_ebrd_clk_3        => ff_rxhalfclk(0),
        ff_txdata_ch3        => tx_data(15 downto 0),
        ff_rxdata_ch3        => comb_rx_data(15 downto 0),
        ff_tx_k_cntrl_ch3    => tx_k(1 downto 0),
        ff_rx_k_cntrl_ch3    => comb_rx_k(1 downto 0),
        ff_rxhalfclk_ch3     => ff_rxhalfclk(0),
        ff_force_disp_ch3    => "00",
        ff_disp_sel_ch3      => "00",
        ff_correct_disp_ch3  => "00",
        ff_disp_err_ch3      => link_error(0)(9 downto 8),
        ff_cv_ch3            => link_error(0)(1 downto 0),
        ffc_rrst_ch3         => '0',
        ffc_lane_tx_rst_ch3  => lane_rst(0), --lane_rst(3),
        ffc_lane_rx_rst_ch3  => lane_rst(0),
        ffc_txpwdnb_ch3      => pwr_up(0),
        ffc_rxpwdnb_ch3      => pwr_up(0),
        ffs_rlos_lo_ch3      => link_error(0)(2),
        ffs_ls_sync_status_ch3 => link_ok(0),
        ffs_cc_underrun_ch3  => link_error(0)(3),
        ffs_cc_overrun_ch3   => link_error(0)(4),
        ffs_txfbfifo_error_ch3 => link_error(0)(5),
        ffs_rxfbfifo_error_ch3 => link_error(0)(6),
        ffs_rlol_ch3         => link_error(0)(7),
        oob_out_ch3          => open,

        ffc_macro_rst        => '0',
        ffc_quad_rst         => quad_rst(0),
        ffc_trst             => '0',
        ff_txhalfclk         => ff_txhalfclk,
        refck2core           => REFCLK2CORE_OUT,
        ffs_plol             => ffs_plol
        );
  end generate;

-------------------------------------------------------------------------
-- RX Fifo & Data output
-------------------------------------------------------------------------
  gen_rx_logic : for i in 0 to 3 generate
    THE_FIFO_SFP_TO_FPGA: trb_net_fifo_16bit_bram_dualport
      generic map(
        USE_STATUS_FLAGS => c_NO
        )
      port map(
        read_clock_in   => SYSCLK,
        write_clock_in  => ff_rxhalfclk(i),
        read_enable_in  => fifo_rx_rd_en(i),
        write_enable_in => fifo_rx_wr_en(i),
        fifo_gsr_in     => fifo_rx_reset(i),
        write_data_in   => fifo_rx_din(18*i+17 downto 18*i),
        read_data_out   => fifo_rx_dout(18*i+17 downto 18*i),
        full_out        => fifo_rx_full(i),
        empty_out       => fifo_rx_empty(i)
        );

    fifo_rx_reset(i) <= reset_i(i) or not rx_allow_q(i);
    fifo_rx_rd_en(i) <= '1';

---------------------------------------------------------------------
-- Received bytes need to be swapped if the SerDes is "off by one" in its internal 8bit path
---------------------------------------------------------------------

    THE_BYTE_SWAP_PROC: process( ff_rxhalfclk )
      begin
        if( rising_edge(ff_rxhalfclk(i)) ) then
          last_rx(9*i+8 downto 9*i) <= rx_k(i*2+1) & rx_data(i*16+15 downto i*16+8);
          if( swap_bytes_qrx(i) = '0' ) then
            fifo_rx_din(i*18+17 downto i*18) <= rx_k(i*2+1) & rx_k(i*2) & rx_data(i*16+15 downto i*16+8)
                                                            & rx_data(i*16+7 downto i*16);
            fifo_rx_wr_en(i) <= not rx_k(i*2) and rx_allow_qrx(i) and link_ok(i);
          else
            fifo_rx_din(i*18+17 downto i*18) <= rx_k(i*2+0) & last_rx(i*9+8) & rx_data(i*16+7 downto i*16+0)
                                                            & last_rx(i*9+7 downto i*9+0);
            fifo_rx_wr_en(i) <= not last_rx(i*9+8) and rx_allow_qrx(i) and link_ok(i);
          end if;
        end if;
      end process;


---------------------------------------------------------------------
--Output to Internal Logic)
---------------------------------------------------------------------

    buf_med_data_out(i*16+15 downto i*16)       <= fifo_rx_dout(i*18+15 downto i*18);
    buf_med_dataready_out(i)                    <= not fifo_rx_dout(i*18+17) and not fifo_rx_dout(i*18+16)
                                                   and not last_fifo_rx_empty(i) and rx_allow_q(i);
    buf_med_packet_num_out(i*3+2 downto i*3)    <= rx_counter(i*3+2 downto i*3);
    med_read_out(i)                             <= tx_allow_q(i);

    THE_SYNC_PROC: process( SYSCLK )
      begin
        if( rising_edge(SYSCLK) ) then
          if reset_i(i) = '1' then
            med_dataready_out(i) <= '0';
          else
            med_dataready_out(i)                  <= buf_med_dataready_out(i);
            med_data_out(i*16+15 downto i*16)     <= buf_med_data_out(i*16+15 downto i*16);
            med_packet_num_out(i*3+2 downto i*3)  <= buf_med_packet_num_out(i*3+2 downto i*3);
          end if;
        end if;
      end process;


---------------------------------------------------------------------
--rx packet counter
---------------------------------------------------------------------
    THE_RX_PACKETS_PROC: process( SYSCLK )
      begin
        if( rising_edge(SYSCLK) ) then
          last_fifo_rx_empty(i) <= fifo_rx_empty(i);
          if reset_i(i) = '1' or rx_allow_q(i) = '0' then
            rx_counter(i*3+2 downto i*3) <= c_H0;
          else
            if( buf_med_dataready_out(i) = '1' ) then
              if( rx_counter(i*3+2 downto i*3) = c_max_word_number ) then
                rx_counter(i*3+2 downto i*3) <= (others => '0');
              else
                rx_counter(i*3+2 downto i*3) <= rx_counter(i*3+2 downto i*3) + 1;
              end if;
            end if;
          end if;
        end if;
      end process;

---------------------------------------------------------------------
--TX Fifo & Data output to Serdes
---------------------------------------------------------------------

    THE_FIFO_FPGA_TO_SFP: trb_net_fifo_16bit_bram_dualport
      generic map(
        USE_STATUS_FLAGS => c_NO
        )
      port map(
        read_clock_in   => ff_txhalfclk,
        write_clock_in  => SYSCLK,
        read_enable_in  => fifo_tx_rd_en(i),
        write_enable_in => fifo_tx_wr_en(i),
        fifo_gsr_in     => fifo_tx_reset(i),
        write_data_in   => fifo_tx_din(i*18+17 downto i*18),
        read_data_out   => fifo_tx_dout(i*18+17 downto i*18),
        full_out        => fifo_tx_full(i),
        empty_out       => fifo_tx_empty(i)
        );

    fifo_tx_reset(i) <= reset_i(i) or not tx_allow_q(i);
    fifo_tx_din(i*18+17 downto i*18)   <= med_packet_num_in(i*3+2) & med_packet_num_in(i*3+0)& med_data_in(i*16+15 downto i*16);
    fifo_tx_wr_en(i) <= med_dataready_in(i) and tx_allow(i);
    fifo_tx_rd_en(i) <= '1';



    THE_SERDES_INPUT_PROC: process( ff_txhalfclk )
      begin
        if( rising_edge(ff_txhalfclk) ) then
        last_fifo_tx_empty(i) <= fifo_tx_empty(i);
          if( (last_fifo_tx_empty(i) = '1') ) then -- or (tx_allow_qtx(i) = '0')
            tx_data(i*16+15 downto i*16) <= x"c5bc";
            tx_k(i*2+1 downto i*2) <= "01";
          else
            tx_data(i*16+15 downto i*16) <= fifo_tx_dout(i*18+15 downto i*18+0);
            tx_k(i*2+1 downto i*2) <= "00";
          end if;
        end if;
      end process;



---------------------------------------------------------------------
--LED Signals
---------------------------------------------------------------------

    THE_TX_RX_LED_PROC: process( SYSCLK )
      begin
        if( rising_edge(SYSCLK) ) then
          if   ( buf_med_dataready_out(i) = '1' ) then
            rx_led(i) <= '1';
          elsif( led_counter = 0 ) then
            rx_led(i) <= '0';
          end if;
          if( fifo_tx_wr_en(i) = '1') then
            tx_led(i) <= '1';
          elsif led_counter = 0 then
            tx_led(i) <= '0';
          end if;
        end if;
      end process;

---------------------------------------------------------------------
--Status Information
---------------------------------------------------------------------


    STAT_OP(i*16+9 downto i*16+0)   <= FSM_STAT_OP(i*16+9 downto i*16+0);
    STAT_OP(i*16+10) <= rx_led(i);
    STAT_OP(i*16+11) <= tx_led(i);
    STAT_OP(i*16+15 downto i*16+12) <= FSM_STAT_OP(i*16+15 downto i*16+12);
    FSM_CTRL_OP(i*16+15 downto i*16+0) <= CTRL_OP(i*16+15 downto i*16+0);

    STAT_DEBUG(i*64+31 downto i*64+0) <= FSM_STAT_DEBUG(i*32+31 downto i*32);
    STAT_DEBUG(i*64+47 downto i*64+32) <= rx_data(i*16+15 downto i*16);
    STAT_DEBUG(i*64+57 downto i*64+48) <= link_error(i);
    STAT_DEBUG(i*64+58)                <= ffs_plol;
    STAT_DEBUG(i*64+60 downto i*64+59) <= rx_k_q(i*2+1 downto i*2);
    STAT_DEBUG(i*64+63 downto i*64+61) <= (others => '0');

  end generate;


  PROC_LED_COUNTER : process(SYSCLK)
    begin
      if rising_edge(SYSCLK) then
          led_counter <= led_counter + 1;
      end if;
    end process;

-- fsm_stat_debug(3 downto 0)   <= state_bits;
-- fsm_stat_debug(4)            <= align_me;
-- fsm_stat_debug(5)            <= buf_swap_bytes;
-- fsm_stat_debug(6)            <= resync;
-- fsm_stat_debug(7)            <= sfp_missing_in;
-- fsm_stat_debug(8)            <= sfp_los_in;
-- STAT_DEBUG(i*64+47 downto i*64+32) <= rx_data(i*16+15 downto i*16);
--         ff_cv_ch3            => link_error(0)(1 downto 0),
--         ffs_rlos_lo_ch3      => link_error(0)(2),
--         ffs_cc_underrun_ch3  => link_error(0)(3),
--         ffs_cc_overrun_ch3   => link_error(0)(4),
--         ffs_txfbfifo_error_ch3 => link_error(0)(5),
--         ffs_rxfbfifo_error_ch3 => link_error(0)(6),
--         ffs_rlol_ch3         => link_error(0)(7),
--         ff_disp_err_ch3      => link_error(0)(9 downto 8),

end architecture;