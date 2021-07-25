--Media interface for Lattice ECP3 using PCS at 2GHz, RX clock == TX clock
--For fully synchronized FPGAs only!
--Either 200 MHz input for 2GBit or 125 MHz for 2.5GBit.
--system clock can be 100 MHz or 125 MHz

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb3_components.all;


entity trb_net16_med_ecp3_sfp_4_onboard is
  generic(
    REVERSE_ORDER : integer range 0 to 1 := c_NO;
    FREQUENCY     : integer range 125 to 200 := 200 --200 or 125
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
    SD_TXDIS_OUT       : out  std_logic_vector(3 downto 0); -- SFP disable
    --Control Interface
    SCI_DATA_IN        : in  std_logic_vector(7 downto 0) := (others => '0');
    SCI_DATA_OUT       : out std_logic_vector(7 downto 0) := (others => '0');
    SCI_ADDR           : in  std_logic_vector(8 downto 0) := (others => '0');
    SCI_READ           : in  std_logic := '0';
    SCI_WRITE          : in  std_logic := '0';
    SCI_ACK            : out std_logic := '0';
    -- Status and control port
    STAT_OP            : out  std_logic_vector (4*16-1 downto 0);
    CTRL_OP            : in  std_logic_vector (4*16-1 downto 0);
    STAT_DEBUG         : out  std_logic_vector (64*4-1 downto 0);
    CTRL_DEBUG         : in  std_logic_vector (63 downto 0)
   );
end entity;

architecture arch_ecp3_sfp_4_onboard of trb_net16_med_ecp3_sfp_4_onboard is

  component serdes_onboard_full
  port(
    hdinp_ch0          : in std_logic;
    hdinn_ch0          : in std_logic;
    hdinp_ch1          : in std_logic;
    hdinn_ch1          : in std_logic;
    hdinp_ch2          : in std_logic;
    hdinn_ch2          : in std_logic;
    hdinp_ch3          : in std_logic;
    hdinn_ch3          : in std_logic;
    hdoutp_ch0         : out std_logic;
    hdoutn_ch0         : out std_logic;
    hdoutp_ch1         : out std_logic;
    hdoutn_ch1         : out std_logic;
    hdoutp_ch2         : out std_logic;
    hdoutn_ch2         : out std_logic;
    hdoutp_ch3         : out std_logic;
    hdoutn_ch3         : out std_logic;

    rxiclk_ch0         : in std_logic;
    txiclk_ch0         : in std_logic;
    rxiclk_ch1         : in std_logic;
    txiclk_ch1         : in std_logic;
    rxiclk_ch2         : in std_logic;
    txiclk_ch2         : in std_logic;
    rxiclk_ch3         : in std_logic;
    txiclk_ch3         : in std_logic;
    fpga_rxrefclk_ch0  : in std_logic;
    fpga_rxrefclk_ch1  : in std_logic;
    fpga_rxrefclk_ch2  : in std_logic;
    fpga_rxrefclk_ch3  : in std_logic;
    rx_full_clk_ch0    : out std_logic;
    rx_half_clk_ch0    : out std_logic;
    tx_full_clk_ch0    : out std_logic;
    tx_half_clk_ch0    : out std_logic;
    rx_full_clk_ch1    : out std_logic;
    rx_half_clk_ch1    : out std_logic;
    tx_full_clk_ch1    : out std_logic;
    tx_half_clk_ch1    : out std_logic;
    rx_full_clk_ch2    : out std_logic;
    rx_half_clk_ch2    : out std_logic;
    tx_full_clk_ch2    : out std_logic;
    tx_half_clk_ch2    : out std_logic;
    rx_full_clk_ch3    : out std_logic;
    rx_half_clk_ch3    : out std_logic;
    tx_full_clk_ch3    : out std_logic;
    tx_half_clk_ch3    : out std_logic;
    
    txdata_ch0         : in std_logic_vector(15 downto 0);
    txdata_ch1         : in std_logic_vector(15 downto 0);
    txdata_ch2         : in std_logic_vector(15 downto 0);
    txdata_ch3         : in std_logic_vector(15 downto 0);
    tx_k_ch0           : in std_logic_vector(1 downto 0);
    tx_k_ch1           : in std_logic_vector(1 downto 0);
    tx_k_ch2           : in std_logic_vector(1 downto 0);
    tx_k_ch3           : in std_logic_vector(1 downto 0);
    tx_force_disp_ch0  : in std_logic_vector(1 downto 0);
    tx_force_disp_ch1  : in std_logic_vector(1 downto 0);
    tx_force_disp_ch2  : in std_logic_vector(1 downto 0);
    tx_force_disp_ch3  : in std_logic_vector(1 downto 0);
    tx_disp_sel_ch0    : in std_logic_vector(1 downto 0);
    tx_disp_sel_ch1    : in std_logic_vector(1 downto 0);
    tx_disp_sel_ch2    : in std_logic_vector(1 downto 0);
    tx_disp_sel_ch3    : in std_logic_vector(1 downto 0);

    sb_felb_ch0_c      : in std_logic;
    sb_felb_ch1_c      : in std_logic;
    sb_felb_ch2_c      : in std_logic;
    sb_felb_ch3_c      : in std_logic;
    sb_felb_rst_ch0_c  : in std_logic;
    sb_felb_rst_ch1_c  : in std_logic;
    sb_felb_rst_ch2_c  : in std_logic;
    sb_felb_rst_ch3_c  : in std_logic;

    tx_pwrup_ch0_c     : in std_logic;
    rx_pwrup_ch0_c     : in std_logic;
    tx_pwrup_ch1_c     : in std_logic;
    rx_pwrup_ch1_c     : in std_logic;
    tx_pwrup_ch2_c     : in std_logic;
    rx_pwrup_ch2_c     : in std_logic;
    tx_pwrup_ch3_c     : in std_logic;
    rx_pwrup_ch3_c     : in std_logic;
    tx_div2_mode_ch0_c : in std_logic;
    rx_div2_mode_ch0_c : in std_logic;
    tx_div2_mode_ch1_c : in std_logic;
    rx_div2_mode_ch1_c : in std_logic;
    tx_div2_mode_ch2_c : in std_logic;
    rx_div2_mode_ch2_c : in std_logic;
    tx_div2_mode_ch3_c : in std_logic;
    rx_div2_mode_ch3_c : in std_logic;
    
    rxdata_ch0         : out std_logic_vector(15 downto 0);
    rxdata_ch1         : out std_logic_vector(15 downto 0);
    rxdata_ch2         : out std_logic_vector(15 downto 0);
    rxdata_ch3         : out std_logic_vector(15 downto 0);
    rx_k_ch0           : out std_logic_vector(1 downto 0);
    rx_k_ch1           : out std_logic_vector(1 downto 0);
    rx_k_ch2           : out std_logic_vector(1 downto 0);
    rx_k_ch3           : out std_logic_vector(1 downto 0);
    rx_disp_err_ch0    : out std_logic_vector(1 downto 0);
    rx_disp_err_ch1    : out std_logic_vector(1 downto 0);
    rx_disp_err_ch2    : out std_logic_vector(1 downto 0);
    rx_disp_err_ch3    : out std_logic_vector(1 downto 0);
    rx_cv_err_ch0      : out std_logic_vector(1 downto 0);
    rx_cv_err_ch1      : out std_logic_vector(1 downto 0);
    rx_cv_err_ch2      : out std_logic_vector(1 downto 0);
    rx_cv_err_ch3      : out std_logic_vector(1 downto 0);
    
    rx_los_low_ch0_s   : out std_logic;
    rx_los_low_ch1_s   : out std_logic;
    rx_los_low_ch2_s   : out std_logic;
    rx_los_low_ch3_s   : out std_logic;
    lsm_status_ch0_s   : out std_logic;
    lsm_status_ch1_s   : out std_logic;
    lsm_status_ch2_s   : out std_logic;
    lsm_status_ch3_s   : out std_logic;
    rx_cdr_lol_ch0_s   : out std_logic;
    rx_cdr_lol_ch1_s   : out std_logic;
    rx_cdr_lol_ch2_s   : out std_logic;
    rx_cdr_lol_ch3_s   : out std_logic;

    fpga_txrefclk    : in std_logic;
    tx_serdes_rst_c  : in std_logic;
    tx_sync_qd_c     : in std_logic;
    tx_pll_lol_qd_s  : out std_logic;
    rst_n            : in std_logic;
    serdes_rst_qd_c  : in std_logic;          
    refclk2fpga      : out std_logic;
    
    sci_sel_ch0   : in  std_logic;
    sci_sel_ch1   : in  std_logic;
    sci_sel_ch2   : in  std_logic;
    sci_sel_ch3   : in  std_logic;
    sci_wrdata    : in  std_logic_vector(7 downto 0);
    sci_addr      : in  std_logic_vector(5 downto 0);
    sci_sel_quad  : in  std_logic;
    sci_rd        : in  std_logic;
    sci_wrn       : in  std_logic;
    sci_rddata    : out std_logic_vector(7 downto 0)

    );
  end component;

  component serdes_onboard_full_125
  port(
    hdinp_ch0          : in std_logic;
    hdinn_ch0          : in std_logic;
    hdinp_ch1          : in std_logic;
    hdinn_ch1          : in std_logic;
    hdinp_ch2          : in std_logic;
    hdinn_ch2          : in std_logic;
    hdinp_ch3          : in std_logic;
    hdinn_ch3          : in std_logic;
    hdoutp_ch0         : out std_logic;
    hdoutn_ch0         : out std_logic;
    hdoutp_ch1         : out std_logic;
    hdoutn_ch1         : out std_logic;
    hdoutp_ch2         : out std_logic;
    hdoutn_ch2         : out std_logic;
    hdoutp_ch3         : out std_logic;
    hdoutn_ch3         : out std_logic;

    rxiclk_ch0         : in std_logic;
    txiclk_ch0         : in std_logic;
    rxiclk_ch1         : in std_logic;
    txiclk_ch1         : in std_logic;
    rxiclk_ch2         : in std_logic;
    txiclk_ch2         : in std_logic;
    rxiclk_ch3         : in std_logic;
    txiclk_ch3         : in std_logic;
    fpga_rxrefclk_ch0  : in std_logic;
    fpga_rxrefclk_ch1  : in std_logic;
    fpga_rxrefclk_ch2  : in std_logic;
    fpga_rxrefclk_ch3  : in std_logic;
    rx_full_clk_ch0    : out std_logic;
    rx_half_clk_ch0    : out std_logic;
    tx_full_clk_ch0    : out std_logic;
    tx_half_clk_ch0    : out std_logic;
    rx_full_clk_ch1    : out std_logic;
    rx_half_clk_ch1    : out std_logic;
    tx_full_clk_ch1    : out std_logic;
    tx_half_clk_ch1    : out std_logic;
    rx_full_clk_ch2    : out std_logic;
    rx_half_clk_ch2    : out std_logic;
    tx_full_clk_ch2    : out std_logic;
    tx_half_clk_ch2    : out std_logic;
    rx_full_clk_ch3    : out std_logic;
    rx_half_clk_ch3    : out std_logic;
    tx_full_clk_ch3    : out std_logic;
    tx_half_clk_ch3    : out std_logic;
    
    txdata_ch0         : in std_logic_vector(15 downto 0);
    txdata_ch1         : in std_logic_vector(15 downto 0);
    txdata_ch2         : in std_logic_vector(15 downto 0);
    txdata_ch3         : in std_logic_vector(15 downto 0);
    tx_k_ch0           : in std_logic_vector(1 downto 0);
    tx_k_ch1           : in std_logic_vector(1 downto 0);
    tx_k_ch2           : in std_logic_vector(1 downto 0);
    tx_k_ch3           : in std_logic_vector(1 downto 0);
    tx_force_disp_ch0  : in std_logic_vector(1 downto 0);
    tx_force_disp_ch1  : in std_logic_vector(1 downto 0);
    tx_force_disp_ch2  : in std_logic_vector(1 downto 0);
    tx_force_disp_ch3  : in std_logic_vector(1 downto 0);
    tx_disp_sel_ch0    : in std_logic_vector(1 downto 0);
    tx_disp_sel_ch1    : in std_logic_vector(1 downto 0);
    tx_disp_sel_ch2    : in std_logic_vector(1 downto 0);
    tx_disp_sel_ch3    : in std_logic_vector(1 downto 0);

    sb_felb_ch0_c      : in std_logic;
    sb_felb_ch1_c      : in std_logic;
    sb_felb_ch2_c      : in std_logic;
    sb_felb_ch3_c      : in std_logic;
    sb_felb_rst_ch0_c  : in std_logic;
    sb_felb_rst_ch1_c  : in std_logic;
    sb_felb_rst_ch2_c  : in std_logic;
    sb_felb_rst_ch3_c  : in std_logic;

    tx_pwrup_ch0_c     : in std_logic;
    rx_pwrup_ch0_c     : in std_logic;
    tx_pwrup_ch1_c     : in std_logic;
    rx_pwrup_ch1_c     : in std_logic;
    tx_pwrup_ch2_c     : in std_logic;
    rx_pwrup_ch2_c     : in std_logic;
    tx_pwrup_ch3_c     : in std_logic;
    rx_pwrup_ch3_c     : in std_logic;
    tx_div2_mode_ch0_c : in std_logic;
    rx_div2_mode_ch0_c : in std_logic;
    tx_div2_mode_ch1_c : in std_logic;
    rx_div2_mode_ch1_c : in std_logic;
    tx_div2_mode_ch2_c : in std_logic;
    rx_div2_mode_ch2_c : in std_logic;
    tx_div2_mode_ch3_c : in std_logic;
    rx_div2_mode_ch3_c : in std_logic;
    
    rxdata_ch0         : out std_logic_vector(15 downto 0);
    rxdata_ch1         : out std_logic_vector(15 downto 0);
    rxdata_ch2         : out std_logic_vector(15 downto 0);
    rxdata_ch3         : out std_logic_vector(15 downto 0);
    rx_k_ch0           : out std_logic_vector(1 downto 0);
    rx_k_ch1           : out std_logic_vector(1 downto 0);
    rx_k_ch2           : out std_logic_vector(1 downto 0);
    rx_k_ch3           : out std_logic_vector(1 downto 0);
    rx_disp_err_ch0    : out std_logic_vector(1 downto 0);
    rx_disp_err_ch1    : out std_logic_vector(1 downto 0);
    rx_disp_err_ch2    : out std_logic_vector(1 downto 0);
    rx_disp_err_ch3    : out std_logic_vector(1 downto 0);
    rx_cv_err_ch0      : out std_logic_vector(1 downto 0);
    rx_cv_err_ch1      : out std_logic_vector(1 downto 0);
    rx_cv_err_ch2      : out std_logic_vector(1 downto 0);
    rx_cv_err_ch3      : out std_logic_vector(1 downto 0);
    
    rx_los_low_ch0_s   : out std_logic;
    rx_los_low_ch1_s   : out std_logic;
    rx_los_low_ch2_s   : out std_logic;
    rx_los_low_ch3_s   : out std_logic;
    lsm_status_ch0_s   : out std_logic;
    lsm_status_ch1_s   : out std_logic;
    lsm_status_ch2_s   : out std_logic;
    lsm_status_ch3_s   : out std_logic;
    rx_cdr_lol_ch0_s   : out std_logic;
    rx_cdr_lol_ch1_s   : out std_logic;
    rx_cdr_lol_ch2_s   : out std_logic;
    rx_cdr_lol_ch3_s   : out std_logic;

    fpga_txrefclk    : in std_logic;
    tx_serdes_rst_c  : in std_logic;
    tx_sync_qd_c     : in std_logic;
    tx_pll_lol_qd_s  : out std_logic;
    rst_n            : in std_logic;
    serdes_rst_qd_c  : in std_logic;          
    refclk2fpga      : out std_logic;
    
    sci_sel_ch0   : in  std_logic;
    sci_sel_ch1   : in  std_logic;
    sci_sel_ch2   : in  std_logic;
    sci_sel_ch3   : in  std_logic;
    sci_wrdata    : in  std_logic_vector(7 downto 0);
    sci_addr      : in  std_logic_vector(5 downto 0);
    sci_sel_quad  : in  std_logic;
    sci_rd        : in  std_logic;
    sci_wrn       : in  std_logic;
    sci_rddata    : out std_logic_vector(7 downto 0)

    );
  end component;  
  
  -- Placer Directives
  attribute HGROUP : string;
  -- for whole architecture
  attribute HGROUP of arch_ecp3_sfp_4_onboard : architecture  is "media_interface_group";
  attribute syn_sharing : string;
  attribute syn_sharing of arch_ecp3_sfp_4_onboard : architecture is "off";


  signal refck2core             : std_logic;
  --reset signals
  signal ffc_quad_rst           : std_logic;
  signal ffc_lane_tx_rst        : std_logic_vector(3 downto 0);
  signal ffc_lane_rx_rst        : std_logic_vector(3 downto 0);
  --serdes connections
  signal tx_data                : std_logic_vector(4*16-1 downto 0);
  signal tx_k                   : std_logic_vector(4*2-1 downto 0);
  signal rx_data                : std_logic_vector(4*16-1 downto 0); -- delayed signals
  signal rx_k                   : std_logic_vector(4*2-1 downto 0);  -- delayed signals
  signal comb_rx_data           : std_logic_vector(4*16-1 downto 0); -- original signals from SFP
  signal comb_rx_k              : std_logic_vector(4*2-1 downto 0);  -- original signals from SFP
  signal link_ok                : std_logic_vector(4*1-1 downto 0);
  signal link_error             : std_logic_vector(4*9-1 downto 0);
  signal ff_txhalfclk           : std_logic_vector(4*1-1 downto 0);
  signal ff_rxhalfclk           : std_logic_vector(4*1-1 downto 0);
  --rx fifo signals
  signal fifo_rx_rd_en          : std_logic_vector(4*1-1 downto 0);
  signal fifo_rx_wr_en          : std_logic_vector(4*1-1 downto 0);
  signal fifo_rx_reset          : std_logic_vector(4*1-1 downto 0);
  signal fifo_rx_din            : std_logic_vector(4*18-1 downto 0);
  signal fifo_rx_dout           : std_logic_vector(4*18-1 downto 0);
  signal fifo_rx_full           : std_logic_vector(4*1-1 downto 0);
  signal fifo_rx_empty          : std_logic_vector(4*1-1 downto 0);
  --tx fifo signals
  signal fifo_tx_rd_en          : std_logic_vector(4*1-1 downto 0);
  signal fifo_tx_wr_en          : std_logic_vector(4*1-1 downto 0);
  signal fifo_tx_reset          : std_logic_vector(4*1-1 downto 0);
  signal fifo_tx_din            : std_logic_vector(4*18-1 downto 0);
  signal fifo_tx_dout           : std_logic_vector(4*18-1 downto 0);
  signal fifo_tx_full           : std_logic_vector(4*1-1 downto 0);
  signal fifo_tx_empty          : std_logic_vector(4*1-1 downto 0);
  signal fifo_tx_almost_full    : std_logic_vector(4*1-1 downto 0);
  --rx path
  signal rx_counter             : std_logic_vector(4*3-1 downto 0);
  signal buf_med_dataready_out  : std_logic_vector(4*1-1 downto 0);
  signal buf_med_data_out       : std_logic_vector(4*16-1 downto 0);
  signal buf_med_packet_num_out : std_logic_vector(4*3-1 downto 0);
  signal last_rx                : std_logic_vector(4*9-1 downto 0);
  signal last_fifo_rx_empty     : std_logic_vector(4*1-1 downto 0);
  --tx path
  signal last_fifo_tx_empty     : std_logic_vector(4*1-1 downto 0);
  --link status
  signal rx_k_q                 : std_logic_vector(4*2-1 downto 0);

  signal quad_rst               : std_logic_vector(4*1-1 downto 0);
  signal lane_rst               : std_logic_vector(4*1-1 downto 0);
  signal tx_allow               : std_logic_vector(4*1-1 downto 0);
  signal rx_allow               : std_logic_vector(4*1-1 downto 0);
  signal tx_allow_qtx           : std_logic_vector(4*1-1 downto 0);

  signal rx_allow_q             : std_logic_vector(4*1-1 downto 0); -- clock domain changed signal
  signal tx_allow_q             : std_logic_vector(4*1-1 downto 0);
  signal swap_bytes             : std_logic_vector(4*1-1 downto 0);
  signal buf_stat_debug         : std_logic_vector(4*32-1 downto 0);

  -- status inputs from SFP
  signal sfp_prsnt_n            : std_logic_vector(4*1-1 downto 0);
  signal sfp_los                : std_logic_vector(4*1-1 downto 0);

  signal buf_STAT_OP            : std_logic_vector(4*16-1 downto 0);

  signal led_counter            : unsigned(16 downto 0);
  signal rx_led                 : std_logic_vector(4*1-1 downto 0);
  signal tx_led                 : std_logic_vector(4*1-1 downto 0);


  signal tx_correct             : std_logic_vector(4*2-1 downto 0); -- GbE mode SERDES: automatic IDLE2 -> IDLE1 conversion
  signal first_idle             : std_logic_vector(4*1-1 downto 0); -- tag the first IDLE2 after data

  type arr5_t is array (0 to 3) of unsigned(4 downto 0);
  signal reset_word_cnt    : arr5_t;
  signal make_trbnet_reset : std_logic_vector(4*1-1 downto 0);
  signal make_trbnet_reset_q : std_logic_vector(4*1-1 downto 0);
  signal send_reset_words  : std_logic_vector(4*1-1 downto 0);
  signal send_reset_words_q : std_logic_vector(4*1-1 downto 0);
  signal send_reset_in      : std_logic_vector(4*1-1 downto 0);
  signal send_reset_in_qtx  : std_logic_vector(4*1-1 downto 0);
  signal reset_i                : std_logic;
  signal reset_i_rx             : std_logic;
  signal pwr_up                 : std_logic_vector(4*1-1 downto 0);
  signal clear_n   : std_logic;

  signal clk_sys : std_logic;
  signal clk_tx  : std_logic;
  signal clk_rx  : std_logic;
  signal clk_ref : std_logic;
  
  signal sci_ch_i       : std_logic_vector(3 downto 0);
  signal sci_addr_i     : std_logic_vector(8 downto 0);
  signal sci_data_in_i  : std_logic_vector(7 downto 0);
  signal sci_data_out_i : std_logic_vector(7 downto 0);
  signal sci_read_i     : std_logic;
  signal sci_write_i    : std_logic;
  signal sci_write_shift_i : std_logic_vector(2 downto 0);
  signal sci_read_shift_i  : std_logic_vector(2 downto 0);
  
  attribute syn_keep : boolean;
  attribute syn_preserve : boolean;
  attribute syn_keep of led_counter : signal is true;
  attribute syn_keep of send_reset_in : signal is true;
  attribute syn_keep of reset_i : signal is true;
  attribute syn_preserve of reset_i : signal is true;

begin

--------------------------------------------------------------------------
-- Select proper clock configuration
--------------------------------------------------------------------------
gen_clocks_200 : if FREQUENCY = 200 generate
  clk_sys <= SYSCLK;
  clk_tx  <= SYSCLK;
  clk_rx  <= SYSCLK;
  clk_ref <= CLK;
end generate;

gen_clocks_125 : if FREQUENCY = 125 generate
  clk_sys <= SYSCLK;
  clk_tx  <= CLK;
  clk_rx  <= CLK;
  clk_ref <= CLK;
end generate;

--------------------------------------------------------------------------
-- Internal Resets
--------------------------------------------------------------------------
  clear_n <= not clear;

  PROC_RESET : process(clk_sys)
    begin
      if rising_edge(clk_sys) then
        reset_i <= RESET;
        send_reset_in(0) <= ctrl_op(15);
        send_reset_in(1) <= ctrl_op(15+16);
        send_reset_in(2) <= ctrl_op(15+32);
        send_reset_in(3) <= ctrl_op(15+48);
        pwr_up  <= x"F"; --not CTRL_OP(i*16+14);
      end if;
    end process;

--------------------------------------------------------------------------
-- Synchronizer stages
--------------------------------------------------------------------------

-- Input synchronizer for SFP_PRESENT and SFP_LOS signals (external signals from SFP)
sfp_prsnt_n <= SD_PRSNT_N_IN when rising_edge(clk_sys);
sfp_los     <= SD_LOS_IN     when rising_edge(clk_sys);
rx_k_q      <= rx_k          when rising_edge(clk_sys);

send_reset_words_q   <= send_reset_words;
make_trbnet_reset_q  <= make_trbnet_reset;
reset_i_rx           <= reset_i;    


rx_data     <= comb_rx_data  when rising_edge(clk_rx);
rx_k        <= comb_rx_k     when rising_edge(clk_rx);

rx_allow_q  <= rx_allow      when rising_edge(clk_sys);
tx_allow_q  <= tx_allow      when rising_edge(clk_sys);

send_reset_in_qtx <= send_reset_in when rising_edge(clk_tx);
tx_allow_qtx      <= tx_allow      when rising_edge(clk_tx);


--------------------------------------------------------------------------
-- Main control state machine, startup control for SFP
--------------------------------------------------------------------------
gen_LSM : for i in 0 to 3 generate
  THE_SFP_LSM: trb_net16_lsm_sfp
      generic map (
        HIGHSPEED_STARTUP => c_YES
        )  
      port map(
        SYSCLK            => clk_sys,
        RESET             => reset_i,
        CLEAR             => clear,
        SFP_MISSING_IN    => sfp_prsnt_n(i),
        SFP_LOS_IN        => sfp_los(i),
        SD_LINK_OK_IN     => link_ok(i),
        SD_LOS_IN         => link_error(i*9+8),
        SD_TXCLK_BAD_IN   => link_error(5),
        SD_RXCLK_BAD_IN   => link_error(i*9+4),
        SD_RETRY_IN       => '0', -- '0' = handle byte swapping in logic, '1' = simply restart link and hope
        SD_ALIGNMENT_IN   => rx_k_q(i*2+1 downto i*2),
        SD_CV_IN          => link_error(i*8+7 downto i*8+6),
        FULL_RESET_OUT    => quad_rst(i),
        LANE_RESET_OUT    => lane_rst(i),
        TX_ALLOW_OUT      => tx_allow(i),
        RX_ALLOW_OUT      => rx_allow(i),
        SWAP_BYTES_OUT    => swap_bytes(i),
        STAT_OP           => buf_stat_op(i*16+15 downto i*16),
        CTRL_OP           => ctrl_op(i*16+15 downto i*16),
        STAT_DEBUG        => buf_stat_debug(i*32+31 downto i*32)
        );

  sd_txdis_out(i) <= quad_rst(i) or reset_i;

  ffc_quad_rst         <= quad_rst(0);
  ffc_lane_tx_rst(i)   <= lane_rst(i);
  ffc_lane_rx_rst(i)   <= lane_rst(i);

end generate;


PROC_SCI : process begin
  wait until rising_edge(clk_sys);
  if SCI_READ = '1' or SCI_WRITE = '1' then
    sci_ch_i(0)   <= not SCI_ADDR(6) and not SCI_ADDR(7) and not SCI_ADDR(8);
    sci_ch_i(1)   <=     SCI_ADDR(6) and not SCI_ADDR(7) and not SCI_ADDR(8);
    sci_ch_i(2)   <= not SCI_ADDR(6) and     SCI_ADDR(7) and not SCI_ADDR(8);
    sci_ch_i(3)   <=     SCI_ADDR(6) and     SCI_ADDR(7) and not SCI_ADDR(8);
    sci_addr_i    <= SCI_ADDR;
    sci_data_in_i <= SCI_DATA_IN;
  end if;
  sci_read_shift_i  <= sci_read_shift_i(1 downto 0) & SCI_READ;
  sci_write_shift_i <= sci_write_shift_i(1 downto 0) & SCI_WRITE;
  SCI_DATA_OUT      <= sci_data_out_i;
end process;

sci_write_i <= or_all(sci_write_shift_i);
sci_read_i  <= or_all(sci_read_shift_i);
SCI_ACK     <= sci_write_shift_i(2) or sci_read_shift_i(2);
  
  

-- Instantiation of serdes module
gen_serdes_200 : if FREQUENCY = 200 generate
  THE_SERDES: serdes_onboard_full
    port map(
      HDINP_CH0           => sd_rxd_p_in(0),
      HDINN_CH0           => sd_rxd_n_in(0),
      HDINP_CH1           => sd_rxd_p_in(1),
      HDINN_CH1           => sd_rxd_n_in(1),
      HDINP_CH2           => sd_rxd_p_in(2),
      HDINN_CH2           => sd_rxd_n_in(2),
      HDINP_CH3           => sd_rxd_p_in(3),
      HDINN_CH3           => sd_rxd_n_in(3),
      HDOUTP_CH0          => sd_txd_p_out(0),
      HDOUTN_CH0          => sd_txd_n_out(0),
      HDOUTP_CH1          => sd_txd_p_out(1),
      HDOUTN_CH1          => sd_txd_n_out(1),
      HDOUTP_CH2          => sd_txd_p_out(2),
      HDOUTN_CH2          => sd_txd_n_out(2),
      HDOUTP_CH3          => sd_txd_p_out(3),
      HDOUTN_CH3          => sd_txd_n_out(3),

      RXICLK_CH0          => clk_rx,
      TXICLK_CH0          => clk_tx,
      RXICLK_CH1          => clk_rx,
      TXICLK_CH1          => clk_tx,
      RXICLK_CH2          => clk_rx,
      TXICLK_CH2          => clk_tx,
      RXICLK_CH3          => clk_rx,
      TXICLK_CH3          => clk_tx,
      FPGA_RXREFCLK_CH0   => clk_ref,
      FPGA_RXREFCLK_CH1   => clk_ref,
      FPGA_RXREFCLK_CH2   => clk_ref,
      FPGA_RXREFCLK_CH3   => clk_ref,
      FPGA_TXREFCLK       => clk_ref,
      RX_FULL_CLK_CH0     => open,
      RX_HALF_CLK_CH0     => open,
      TX_FULL_CLK_CH0     => open,
      TX_HALF_CLK_CH0     => open,
      RX_FULL_CLK_CH1     => open,
      RX_HALF_CLK_CH1     => open,
      TX_FULL_CLK_CH1     => open,
      TX_HALF_CLK_CH1     => open,
      RX_FULL_CLK_CH2     => open,
      RX_HALF_CLK_CH2     => open,
      TX_FULL_CLK_CH2     => open,
      TX_HALF_CLK_CH2     => open,
      RX_FULL_CLK_CH3     => open,
      RX_HALF_CLK_CH3     => open,
      TX_FULL_CLK_CH3     => open,
      TX_HALF_CLK_CH3     => open,

      TXDATA_CH0          => tx_data(15 downto  0),
      TXDATA_CH1          => tx_data(31 downto  16),
      TXDATA_CH2          => tx_data(47 downto  32),
      TXDATA_CH3          => tx_data(63 downto  48),
      TX_K_CH0            => tx_k(1 downto 0),
      TX_K_CH1            => tx_k(3 downto 2),
      TX_K_CH2            => tx_k(5 downto 4),
      TX_K_CH3            => tx_k(7 downto 6),
      TX_FORCE_DISP_CH0   => tx_correct(1 downto 0),
      TX_FORCE_DISP_CH1   => tx_correct(3 downto 2),
      TX_FORCE_DISP_CH2   => tx_correct(5 downto 4),
      TX_FORCE_DISP_CH3   => tx_correct(7 downto 6),
      TX_DISP_SEL_CH0     => "00",
      TX_DISP_SEL_CH1     => "00",
      TX_DISP_SEL_CH2     => "00",
      TX_DISP_SEL_CH3     => "00",

      SB_FELB_CH0_C       => '0', --loopback enable
      SB_FELB_CH1_C       => '0', --loopback enable
      SB_FELB_CH2_C       => '0', --loopback enable
      SB_FELB_CH3_C       => '0', --loopback enable
      SB_FELB_RST_CH0_C   => '0', --loopback reset
      SB_FELB_RST_CH1_C   => '0', --loopback reset
      SB_FELB_RST_CH2_C   => '0', --loopback reset
      SB_FELB_RST_CH3_C   => '0', --loopback reset

      TX_PWRUP_CH0_C      => '1', --tx power up
      RX_PWRUP_CH0_C      => '1', --rx power up
      TX_PWRUP_CH1_C      => '1', --tx power up
      RX_PWRUP_CH1_C      => '1', --rx power up
      TX_PWRUP_CH2_C      => '1', --tx power up
      RX_PWRUP_CH2_C      => '1', --rx power up
      TX_PWRUP_CH3_C      => '1', --tx power up
      RX_PWRUP_CH3_C      => '1', --rx power up
      TX_DIV2_MODE_CH0_C  => '0', --full rate
      RX_DIV2_MODE_CH0_C  => '0', --full rate
      TX_DIV2_MODE_CH1_C  => '0', --full rate
      RX_DIV2_MODE_CH1_C  => '0', --full rate
      TX_DIV2_MODE_CH2_C  => '0', --full rate
      RX_DIV2_MODE_CH2_C  => '0', --full rate
      TX_DIV2_MODE_CH3_C  => '0', --full rate
      RX_DIV2_MODE_CH3_C  => '0', --full rate

      SCI_WRDATA          => sci_data_in_i,
      SCI_RDDATA          => sci_data_out_i,
      SCI_ADDR            => sci_addr_i(5 downto 0),
      SCI_SEL_QUAD        => sci_addr_i(8),
      SCI_SEL_CH0         => sci_ch_i(0),
      SCI_SEL_CH1         => sci_ch_i(1),
      SCI_SEL_CH2         => sci_ch_i(2),
      SCI_SEL_CH3         => sci_ch_i(3),
      SCI_RD              => sci_read_i,
      SCI_WRN             => sci_write_i,

      TX_SERDES_RST_C     => CLEAR,
      TX_SYNC_QD_C        => '0',
      RST_N               => '1',
      SERDES_RST_QD_C     => ffc_quad_rst,

      RXDATA_CH0          => comb_rx_data(15 downto  0),
      RXDATA_CH1          => comb_rx_data(31 downto  16),
      RXDATA_CH2          => comb_rx_data(47 downto  32),
      RXDATA_CH3          => comb_rx_data(63 downto  48),
      RX_K_CH0            => comb_rx_k(1 downto 0),
      RX_K_CH1            => comb_rx_k(3 downto 2),
      RX_K_CH2            => comb_rx_k(5 downto 4),
      RX_K_CH3            => comb_rx_k(7 downto 6),    
      
      RX_DISP_ERR_CH0     => open,
      RX_DISP_ERR_CH1     => open,
      RX_DISP_ERR_CH2     => open,
      RX_DISP_ERR_CH3     => open,
      RX_CV_ERR_CH0       => link_error(0*9+7 downto 0*9+6),
      RX_CV_ERR_CH1       => link_error(1*9+7 downto 1*9+6),
      RX_CV_ERR_CH2       => link_error(2*9+7 downto 2*9+6),
      RX_CV_ERR_CH3       => link_error(3*9+7 downto 3*9+6),

      RX_LOS_LOW_CH0_S    => link_error(0*9+8),
      RX_LOS_LOW_CH1_S    => link_error(1*9+8),
      RX_LOS_LOW_CH2_S    => link_error(2*9+8),
      RX_LOS_LOW_CH3_S    => link_error(3*9+8),
      LSM_STATUS_CH0_S    => link_ok(0),
      LSM_STATUS_CH1_S    => link_ok(1),
      LSM_STATUS_CH2_S    => link_ok(2),
      LSM_STATUS_CH3_S    => link_ok(3),
      RX_CDR_LOL_CH0_S    => link_error(0*9+4),
      RX_CDR_LOL_CH1_S    => link_error(1*9+4),
      RX_CDR_LOL_CH2_S    => link_error(2*9+4),
      RX_CDR_LOL_CH3_S    => link_error(3*9+4),
      TX_PLL_LOL_QD_S     => link_error(5)    
      );
end generate;

gen_serdes_125 : if FREQUENCY = 125 generate
  THE_SERDES: serdes_onboard_full_125
    port map(
      HDINP_CH0           => sd_rxd_p_in(0),
      HDINN_CH0           => sd_rxd_n_in(0),
      HDINP_CH1           => sd_rxd_p_in(1),
      HDINN_CH1           => sd_rxd_n_in(1),
      HDINP_CH2           => sd_rxd_p_in(2),
      HDINN_CH2           => sd_rxd_n_in(2),
      HDINP_CH3           => sd_rxd_p_in(3),
      HDINN_CH3           => sd_rxd_n_in(3),
      HDOUTP_CH0          => sd_txd_p_out(0),
      HDOUTN_CH0          => sd_txd_n_out(0),
      HDOUTP_CH1          => sd_txd_p_out(1),
      HDOUTN_CH1          => sd_txd_n_out(1),
      HDOUTP_CH2          => sd_txd_p_out(2),
      HDOUTN_CH2          => sd_txd_n_out(2),
      HDOUTP_CH3          => sd_txd_p_out(3),
      HDOUTN_CH3          => sd_txd_n_out(3),

      RXICLK_CH0          => clk_rx,
      TXICLK_CH0          => clk_tx,
      RXICLK_CH1          => clk_rx,
      TXICLK_CH1          => clk_tx,
      RXICLK_CH2          => clk_rx,
      TXICLK_CH2          => clk_tx,
      RXICLK_CH3          => clk_rx,
      TXICLK_CH3          => clk_tx,
      FPGA_RXREFCLK_CH0   => clk_ref,
      FPGA_RXREFCLK_CH1   => clk_ref,
      FPGA_RXREFCLK_CH2   => clk_ref,
      FPGA_RXREFCLK_CH3   => clk_ref,
      FPGA_TXREFCLK       => clk_ref,
      RX_FULL_CLK_CH0     => open,
      RX_HALF_CLK_CH0     => open,
      TX_FULL_CLK_CH0     => open,
      TX_HALF_CLK_CH0     => open,
      RX_FULL_CLK_CH1     => open,
      RX_HALF_CLK_CH1     => open,
      TX_FULL_CLK_CH1     => open,
      TX_HALF_CLK_CH1     => open,
      RX_FULL_CLK_CH2     => open,
      RX_HALF_CLK_CH2     => open,
      TX_FULL_CLK_CH2     => open,
      TX_HALF_CLK_CH2     => open,
      RX_FULL_CLK_CH3     => open,
      RX_HALF_CLK_CH3     => open,
      TX_FULL_CLK_CH3     => open,
      TX_HALF_CLK_CH3     => open,

      TXDATA_CH0          => tx_data(15 downto  0),
      TXDATA_CH1          => tx_data(31 downto  16),
      TXDATA_CH2          => tx_data(47 downto  32),
      TXDATA_CH3          => tx_data(63 downto  48),
      TX_K_CH0            => tx_k(1 downto 0),
      TX_K_CH1            => tx_k(3 downto 2),
      TX_K_CH2            => tx_k(5 downto 4),
      TX_K_CH3            => tx_k(7 downto 6),
      TX_FORCE_DISP_CH0   => tx_correct(1 downto 0),
      TX_FORCE_DISP_CH1   => tx_correct(3 downto 2),
      TX_FORCE_DISP_CH2   => tx_correct(5 downto 4),
      TX_FORCE_DISP_CH3   => tx_correct(7 downto 6),
      TX_DISP_SEL_CH0     => "00",
      TX_DISP_SEL_CH1     => "00",
      TX_DISP_SEL_CH2     => "00",
      TX_DISP_SEL_CH3     => "00",

      SB_FELB_CH0_C       => '0', --loopback enable
      SB_FELB_CH1_C       => '0', --loopback enable
      SB_FELB_CH2_C       => '0', --loopback enable
      SB_FELB_CH3_C       => '0', --loopback enable
      SB_FELB_RST_CH0_C   => '0', --loopback reset
      SB_FELB_RST_CH1_C   => '0', --loopback reset
      SB_FELB_RST_CH2_C   => '0', --loopback reset
      SB_FELB_RST_CH3_C   => '0', --loopback reset

      TX_PWRUP_CH0_C      => '1', --tx power up
      RX_PWRUP_CH0_C      => '1', --rx power up
      TX_PWRUP_CH1_C      => '1', --tx power up
      RX_PWRUP_CH1_C      => '1', --rx power up
      TX_PWRUP_CH2_C      => '1', --tx power up
      RX_PWRUP_CH2_C      => '1', --rx power up
      TX_PWRUP_CH3_C      => '1', --tx power up
      RX_PWRUP_CH3_C      => '1', --rx power up
      TX_DIV2_MODE_CH0_C  => '0', --full rate
      RX_DIV2_MODE_CH0_C  => '0', --full rate
      TX_DIV2_MODE_CH1_C  => '0', --full rate
      RX_DIV2_MODE_CH1_C  => '0', --full rate
      TX_DIV2_MODE_CH2_C  => '0', --full rate
      RX_DIV2_MODE_CH2_C  => '0', --full rate
      TX_DIV2_MODE_CH3_C  => '0', --full rate
      RX_DIV2_MODE_CH3_C  => '0', --full rate

      SCI_WRDATA          => (others => '0'),
      SCI_RDDATA          => open,
      SCI_ADDR            => (others => '0'),
      SCI_SEL_QUAD        => '0',
      SCI_SEL_CH0         => '0',
      SCI_SEL_CH1         => '0',
      SCI_SEL_CH2         => '0',
      SCI_SEL_CH3         => '0',
      SCI_RD              => '0',
      SCI_WRN             => '0',

      TX_SERDES_RST_C     => CLEAR,
      TX_SYNC_QD_C        => '0',
      RST_N               => '1',
      SERDES_RST_QD_C     => ffc_quad_rst,

      RXDATA_CH0          => comb_rx_data(15 downto  0),
      RXDATA_CH1          => comb_rx_data(31 downto  16),
      RXDATA_CH2          => comb_rx_data(47 downto  32),
      RXDATA_CH3          => comb_rx_data(63 downto  48),
      RX_K_CH0            => comb_rx_k(1 downto 0),
      RX_K_CH1            => comb_rx_k(3 downto 2),
      RX_K_CH2            => comb_rx_k(5 downto 4),
      RX_K_CH3            => comb_rx_k(7 downto 6),    
      
      RX_DISP_ERR_CH0     => open,
      RX_DISP_ERR_CH1     => open,
      RX_DISP_ERR_CH2     => open,
      RX_DISP_ERR_CH3     => open,
      RX_CV_ERR_CH0       => link_error(0*9+7 downto 0*9+6),
      RX_CV_ERR_CH1       => link_error(1*9+7 downto 1*9+6),
      RX_CV_ERR_CH2       => link_error(2*9+7 downto 2*9+6),
      RX_CV_ERR_CH3       => link_error(3*9+7 downto 3*9+6),

      RX_LOS_LOW_CH0_S    => link_error(0*9+8),
      RX_LOS_LOW_CH1_S    => link_error(1*9+8),
      RX_LOS_LOW_CH2_S    => link_error(2*9+8),
      RX_LOS_LOW_CH3_S    => link_error(3*9+8),
      LSM_STATUS_CH0_S    => link_ok(0),
      LSM_STATUS_CH1_S    => link_ok(1),
      LSM_STATUS_CH2_S    => link_ok(2),
      LSM_STATUS_CH3_S    => link_ok(3),
      RX_CDR_LOL_CH0_S    => link_error(0*9+4),
      RX_CDR_LOL_CH1_S    => link_error(1*9+4),
      RX_CDR_LOL_CH2_S    => link_error(2*9+4),
      RX_CDR_LOL_CH3_S    => link_error(3*9+4),
      TX_PLL_LOL_QD_S     => link_error(5)    
      );
end generate;


-------------------------------------------------------------------------
-- RX Fifo & Data output
-------------------------------------------------------------------------
gen_logic : for i in 0 to 3 generate

  THE_FIFO_SFP_TO_FPGA: trb_net_fifo_16bit_bram_dualport
  generic map(
    USE_STATUS_FLAGS => c_NO
        )
  port map( read_clock_in  => clk_sys,
        write_clock_in     => clk_rx,
        read_enable_in     => fifo_rx_rd_en(i),
        write_enable_in    => fifo_rx_wr_en(i),
        fifo_gsr_in        => fifo_rx_reset(i),
        write_data_in      => fifo_rx_din(i*18+17 downto i*18),
        read_data_out      => fifo_rx_dout(i*18+17 downto i*18),
        full_out           => fifo_rx_full(i),
        empty_out          => fifo_rx_empty(i)
      );

  fifo_rx_reset(i) <= reset_i or not rx_allow_q(i);
  fifo_rx_rd_en(i) <= not fifo_rx_empty(i);

  -- Received bytes need to be swapped if the SerDes is "off by one" in its internal 8bit path
  THE_BYTE_SWAP_PROC: process
    begin
      wait until rising_edge(clk_rx);  --CHANGED sysclk
      last_rx(i*9+8 downto i*9) <= rx_k(i*2+1) & rx_data(i*16+15 downto i*16+8);
      if( swap_bytes(i) = '0' ) then
        fifo_rx_din(i*18+17 downto i*18)   <= rx_k(i*2+1) & rx_k(i*2+0) 
                                            & rx_data(i*16+15 downto i*16+8) & rx_data(i*16+7 downto i*16+0);
        fifo_rx_wr_en(i) <= not rx_k(i*2+0) and rx_allow(i) and link_ok(i);
      else
        fifo_rx_din(i*18+17 downto i*18)   <= rx_k(i*2+0) & last_rx(i*9+8) 
                                            & rx_data(i*16+7 downto i*16+0) & last_rx(i*9+7 downto i*9+0);
        fifo_rx_wr_en(i) <= not last_rx(i*9+8) and rx_allow(i) and link_ok(i);
      end if;
    end process THE_BYTE_SWAP_PROC;

  buf_med_data_out(i*16+15 downto i*16)      <= fifo_rx_dout(i*18+15 downto i*18);
  buf_med_dataready_out(i)     <= not fifo_rx_dout(i*18+17) and not fifo_rx_dout(i*18+16) 
                                  and not last_fifo_rx_empty(i) and rx_allow_q(i);
  buf_med_packet_num_out(i*3+2 downto i*3)    <= rx_counter(i*3+2 downto i*3);
  med_read_out(i)              <= tx_allow_q(i) and not fifo_tx_almost_full(i);


  THE_CNT_RESET_PROC : process
    begin
      wait until rising_edge(clk_rx); --CHANGED sysclk
      if reset_i_rx = '1' then
        send_reset_words(i)  <= '0';
        make_trbnet_reset(i) <= '0';
        reset_word_cnt(i)    <= (others => '0');
      else
        send_reset_words(i)   <= '0';
        make_trbnet_reset(i)  <= '0';
        if fifo_rx_din(i*18+17 downto i*18) = "11" & x"FEFE" then
          if reset_word_cnt(i)(4) = '0' then
            reset_word_cnt(i) <= reset_word_cnt(i) + to_unsigned(1,1);
          else
            send_reset_words(i) <= '1';
          end if;
        else
          reset_word_cnt(i)    <= (others => '0');
          make_trbnet_reset(i) <= reset_word_cnt(i)(4);
        end if;
      end if;
    end process;


  THE_SYNC_PROC: process
    begin
      wait until rising_edge(clk_sys);
      med_dataready_out(i)                   <= buf_med_dataready_out(i);
      med_data_out(i*16+15 downto i*16)      <= buf_med_data_out(i*16+15 downto i*16);
      med_packet_num_out(i*3+2 downto i*3)   <= buf_med_packet_num_out(i*3+2 downto i*3);
      if reset_i = '1' then
        med_dataready_out(i) <= '0';
      end if;
    end process;


  --rx packet counter
  ---------------------
  THE_RX_PACKETS_PROC: process( clk_sys )
    begin
      if( rising_edge(sysclk) ) then
        last_fifo_rx_empty(i) <= fifo_rx_empty(i);
        if reset_i = '1' or rx_allow_q(i) = '0' then
          rx_counter(i*3+2 downto i*3) <= c_H0;
        else
          if( buf_med_dataready_out(i) = '1' ) then
            if( rx_counter(i*3+2 downto i*3) = c_max_word_number ) then
              rx_counter(i*3+2 downto i*3) <= (others => '0');
            else
              rx_counter(i*3+2 downto i*3) <= std_logic_vector(unsigned(rx_counter(i*3+2 downto i*3)) + to_unsigned(1,1));
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
    port map( read_clock_in => clk_tx,--sysclk,
          write_clock_in    => clk_sys,
          read_enable_in    => fifo_tx_rd_en(i),
          write_enable_in   => fifo_tx_wr_en(i),
          fifo_gsr_in       => fifo_tx_reset(i),
          write_data_in     => fifo_tx_din(i*18+17 downto i*18),
          read_data_out     => fifo_tx_dout(i*18+17 downto i*18),
          full_out          => fifo_tx_full(i),
          empty_out         => fifo_tx_empty(i),
          almost_full_out   => fifo_tx_almost_full(i)
        );

  fifo_tx_reset(i) <= reset_i or not tx_allow_q(i);
  fifo_tx_din(i*18+17 downto i*18)   <= med_packet_num_in(i*3+2) & med_packet_num_in(i*3+0) & med_data_in(i*16+15 downto i*16);
  fifo_tx_wr_en(i) <= med_dataready_in(i) and tx_allow_q(i);
  fifo_tx_rd_en(i) <= tx_allow_qtx(i);


  THE_SERDES_INPUT_PROC: process begin
    wait until rising_edge(clk_tx);
    last_fifo_tx_empty(i) <= fifo_tx_empty(i);
    first_idle(i) <= not last_fifo_tx_empty(i) and fifo_tx_empty(i);
    if send_reset_in(i) = '1' then
      tx_data(i*16+15 downto i*16) <= x"FEFE";
      tx_k(i*2+1 downto i*2) <= "11";
    elsif( (last_fifo_tx_empty(i) = '1') or (tx_allow_qtx(i) = '0') ) then
      tx_data(i*16+15 downto i*16) <= x"50bc";
      tx_k(i*2+1 downto i*2) <= "01";
      tx_correct(i*2+1 downto i*2) <= first_idle(i) & '0';
    else
      tx_data(i*16+15 downto i*16) <= fifo_tx_dout(i*18+15 downto i*18);
      tx_k(i*2+1 downto i*2) <= "00";
      tx_correct(i*2+1 downto i*2) <= "00";
    end if;
  end process THE_SERDES_INPUT_PROC;

end generate;    
--------------------------------------------------------------------------
--------------------------------------------------------------------------

-- SerDes clock output to FPGA fabric
refclk2core_out <= '0';

--------------------------------------------------------------------------
--Generate LED signals
--------------------------------------------------------------------------
  PROC_LED : process begin
    wait until rising_edge(clk_sys);
    led_counter <= led_counter + to_unsigned(1,1);

    if led_counter = 0 then
      rx_led <= x"0";
    else
      rx_led <= rx_led or buf_med_dataready_out;
    end if;

    if led_counter = 0 then
      tx_led <= x"0";
    else
      tx_led <= tx_led or not (tx_k(6) & tx_k(4) & tx_k(2) & tx_k(0));
    end if;
  end process;

gen_outputs : for i in 0 to 3 generate
  stat_op(i*16+15)              <= send_reset_words_q(i);
  stat_op(i*16+14)              <= buf_stat_op(i*16+14);
  stat_op(i*16+13)              <= make_trbnet_reset_q(i);
  stat_op(i*16+12)              <= '0';
  stat_op(i*16+11)              <= tx_led(i); --tx led
  stat_op(i*16+10)              <= rx_led(I); --rx led
  stat_op(i*16+9 downto i*16+0) <= buf_stat_op(i*16+9 downto i*16+0);
                                                  
  -- Debug output                                 
  stat_debug(i*64+15 downto i*64+0)  <= rx_data(i*16+15 downto i*16);            
  stat_debug(i*64+17 downto i*64+16) <= rx_k(i*2+1 downto i*2);               
  stat_debug(i*64+19 downto i*64+18) <= (others => '0');
  stat_debug(i*64+23 downto i*64+20) <= buf_stat_debug(i*16+3 downto i*16+0);
  stat_debug(i*64+24)                <= fifo_rx_rd_en(i);
  stat_debug(i*64+25)                <= fifo_rx_wr_en(i);
  stat_debug(i*64+26)                <= fifo_rx_reset(i);
  stat_debug(i*64+27)                <= fifo_rx_empty(i);
  stat_debug(i*64+28)                <= fifo_rx_full(i);
  stat_debug(i*64+29)                <= last_rx(i*9+8);
  stat_debug(i*64+30)                <= rx_allow_q(i);
  stat_debug(i*64+41 downto i*64+31) <= (others => '0');
  stat_debug(i*64+42)                <= sysclk;
  stat_debug(i*64+43)                <= sysclk;
  stat_debug(i*64+59 downto i*64+44) <= (others => '0');
  stat_debug(i*64+63 downto i*64+60) <= buf_stat_debug(i*16+3 downto i*16+0);
end generate;

end architecture;