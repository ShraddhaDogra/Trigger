--four links, all with receive buffers, as masters only. 



LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.med_sync_define.all;

entity med_ecp3_sfp_sync_4 is
  generic(
    IS_SYNC_SLAVE   : int_array_t(0 to 3) := (c_NO, c_NO, c_NO, c_NO); --select slave mode
    IS_USED         : int_array_t(0 to 3) := (c_YES,c_YES,c_YES,c_YES)
    );
  port(
    CLK_REF_FULL       : in  std_logic; -- 200 MHz reference clock
    CLK_INTERNAL_FULL  : in  std_logic; -- internal 200 MHz, always on
    SYSCLK             : in  std_logic; -- 100 MHz main clock net, synchronous to RX clock
    RESET              : in  std_logic; -- synchronous reset
    CLEAR              : in  std_logic; -- asynchronous reset
    --Internal Connection TX
    MEDIA_MED2INT      : out med2int_array_t(0 to 3);
    MEDIA_INT2MED      : in  int2med_array_t(0 to 3);
    
    --Sync operation
    RX_DLM             : out std_logic_vector(3 downto 0) := x"0";
    RX_DLM_WORD        : out std_logic_vector(4*8-1 downto 0) := (others => '0');
    TX_DLM             : in  std_logic_vector(3 downto 0) := x"0";
    TX_DLM_WORD        : in  std_logic_vector(4*8-1 downto 0) := (others => '0');
    
    --SFP Connection
    SD_REFCLK_P_IN     : in  std_logic := '0';  --not used
    SD_REFCLK_N_IN     : in  std_logic := '0';  --not used
    SD_PRSNT_N_IN      : in  std_logic_vector(3 downto 0);  -- SFP Present ('0' = SFP in place, '1' = no SFP mounted)
    SD_LOS_IN          : in  std_logic_vector(3 downto 0);  -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
    SD_TXDIS_OUT       : out std_logic_vector(3 downto 0);  -- SFP disable
    --Control Interface
    BUS_RX             : in  CTRLBUS_RX;
    BUS_TX             : out CTRLBUS_TX;

    -- Status and control port
    STAT_DEBUG         : out std_logic_vector (63 downto 0);
    CTRL_DEBUG         : in  std_logic_vector (63 downto 0) := (others => '0')
   );
end entity;


architecture med_ecp3_sfp_sync_4_arch of med_ecp3_sfp_sync_4 is

  -- Placer Directives
  attribute HGROUP : string;
  -- for whole architecture
  attribute HGROUP of med_ecp3_sfp_sync_4_arch : architecture  is "media_interface_group";
  attribute syn_sharing : string;
  attribute syn_sharing of med_ecp3_sfp_sync_4_arch : architecture is "off";
  attribute syn_hier : string;
  attribute syn_hier of med_ecp3_sfp_sync_4_arch : architecture is "hard";

signal clk_200_i         : std_logic;
signal clk_rx_full, clk_rx_half : std_logic_vector(3 downto 0);
signal clk_tx_full, clk_tx_half : std_logic_vector(3 downto 0);

signal tx_data           : std_logic_vector(4*8-1 downto 0);
signal tx_k              : std_logic_vector(3 downto 0);
signal tx_cd             : std_logic_vector(3 downto 0);
signal rx_data           : std_logic_vector(4*8-1 downto 0);
signal rx_k              : std_logic_vector(3 downto 0);
signal rx_error          : std_logic_vector(3 downto 0);

signal rst_n             : std_logic;
signal rx_serdes_rst     : std_logic_vector(3 downto 0);
signal tx_serdes_rst     : std_logic_vector(3 downto 0);
signal tx_pcs_rst        : std_logic_vector(3 downto 0);
signal rx_pcs_rst        : std_logic_vector(3 downto 0);
signal rst_qd            : std_logic_vector(3 downto 0);
signal serdes_rst_qd     : std_logic_vector(3 downto 0);

signal rx_los_low        : std_logic_vector(3 downto 0);
signal lsm_status        : std_logic_vector(3 downto 0);
signal rx_cdr_lol        : std_logic_vector(3 downto 0);
signal tx_pll_lol        : std_logic;

signal sci_ch_i          : std_logic_vector(4 downto 0);
signal sci_addr_i        : std_logic_vector(5 downto 0);
signal sci_data_in_i     : std_logic_vector(7 downto 0);
signal sci_data_out_i    : std_logic_vector(7 downto 0);
signal sci_read_i        : std_logic;
signal sci_write_i       : std_logic;

signal wa_position        : std_logic_vector(15 downto 0) := x"FFFF";
signal wa_position_sel    : std_logic_vector(3 downto 0);

signal stat_rx_control_i  : std_logic_vector(4*32-1 downto 0);
signal stat_tx_control_i  : std_logic_vector(4*32-1 downto 0);
signal debug_rx_control_i : std_logic_vector(4*32-1 downto 0);
signal debug_tx_control_i : std_logic_vector(4*32-1 downto 0);
signal stat_fsm_reset_i   : std_logic_vector(4*32-1 downto 0);

signal  hdinp, hdinn, hdoutp, hdoutn : std_logic_vector(3 downto 0);
attribute nopad : string;
attribute nopad of  hdinp, hdinn, hdoutp, hdoutn : signal is "true";

begin

-- SD_TXDIS_OUT <= (others =>'0'); --not (rx_allow_q or not IS_SLAVE);   --slave only switches on when RX is ready
SD_TXDIS_OUT <= (others => RESET);
-------------------------------------------------      
-- Serdes
-------------------------------------------------      
  THE_SERDES : entity work.serdes_sync_4 
    port map(
      hdinp_ch0            => hdinp (0),
      hdinn_ch0            => hdinn (0),
      hdoutp_ch0           => hdoutp(0),
      hdoutn_ch0           => hdoutn(0),
      txiclk_ch0           => CLK_REF_FULL, --clk_tx_full(0),
      rxiclk_ch0           => clk_rx_full(0), --CLK_REF_FULL,
      rx_full_clk_ch0      => clk_rx_full(0),
      rx_half_clk_ch0      => clk_rx_half(0),
      tx_full_clk_ch0      => clk_tx_full(0),
      tx_half_clk_ch0      => clk_tx_half(0),
      fpga_rxrefclk_ch0    => CLK_INTERNAL_FULL,
      txdata_ch0           => tx_data(0*8+7 downto 0*8),
      tx_k_ch0             => tx_k(0),
      tx_force_disp_ch0    => tx_cd(0),
      tx_disp_sel_ch0      => '0',
      rxdata_ch0           => rx_data(0*8+7 downto 0*8),
      rx_k_ch0             => rx_k(0),
      rx_disp_err_ch0      => open,
      rx_cv_err_ch0        => rx_error(0),
      rx_serdes_rst_ch0_c  => rx_serdes_rst(0),
      sb_felb_ch0_c        => '0',
      sb_felb_rst_ch0_c    => '0',
      tx_pcs_rst_ch0_c     => tx_pcs_rst(0),
      tx_pwrup_ch0_c       => '1',
      rx_pcs_rst_ch0_c     => rx_pcs_rst(0),
      rx_pwrup_ch0_c       => '1',
      rx_los_low_ch0_s     => rx_los_low(0),
      lsm_status_ch0_s     => lsm_status(0),
      rx_cdr_lol_ch0_s     => rx_cdr_lol(0),
      tx_div2_mode_ch0_c   => '0',
      rx_div2_mode_ch0_c   => '0',
      
      hdinp_ch1            => hdinp (1),
      hdinn_ch1            => hdinn (1),
      hdoutp_ch1           => hdoutp(1),
      hdoutn_ch1           => hdoutn(1),
      txiclk_ch1           => CLK_REF_FULL, --clk_tx_full(1),
      rxiclk_ch1           => clk_rx_full(1), --CLK_REF_FULL,
      rx_full_clk_ch1      => clk_rx_full(1),
      rx_half_clk_ch1      => clk_rx_half(1),
      tx_full_clk_ch1      => clk_tx_full(1),
      tx_half_clk_ch1      => clk_tx_half(1),
      fpga_rxrefclk_ch1    => CLK_INTERNAL_FULL,
      txdata_ch1           => tx_data(1*8+7 downto 1*8),
      tx_k_ch1             => tx_k(1),
      tx_force_disp_ch1    => tx_cd(1),
      tx_disp_sel_ch1      => '0',
      rxdata_ch1           => rx_data(1*8+7 downto 1*8),
      rx_k_ch1             => rx_k(1),
      rx_disp_err_ch1      => open,
      rx_cv_err_ch1        => rx_error(1),
      rx_serdes_rst_ch1_c  => rx_serdes_rst(1),
      sb_felb_ch1_c        => '0',
      sb_felb_rst_ch1_c    => '0',
      tx_pcs_rst_ch1_c     => tx_pcs_rst(1),
      tx_pwrup_ch1_c       => '1',
      rx_pcs_rst_ch1_c     => rx_pcs_rst(1),
      rx_pwrup_ch1_c       => '1',
      rx_los_low_ch1_s     => rx_los_low(1),
      lsm_status_ch1_s     => lsm_status(1),
      rx_cdr_lol_ch1_s     => rx_cdr_lol(1),
      tx_div2_mode_ch1_c   => '0',
      rx_div2_mode_ch1_c   => '0',

      hdinp_ch2            => hdinp (2),
      hdinn_ch2            => hdinn (2),
      hdoutp_ch2           => hdoutp(2),
      hdoutn_ch2           => hdoutn(2),
      txiclk_ch2           => CLK_REF_FULL, --clk_tx_full(2),
      rxiclk_ch2           => clk_rx_full(2), --CLK_REF_FULL,
      rx_full_clk_ch2      => clk_rx_full(2),
      rx_half_clk_ch2      => clk_rx_half(2),
      tx_full_clk_ch2      => clk_tx_full(2),
      tx_half_clk_ch2      => clk_tx_half(2),
      fpga_rxrefclk_ch2    => CLK_INTERNAL_FULL,
      txdata_ch2           => tx_data(2*8+7 downto 2*8),
      tx_k_ch2             => tx_k(2),
      tx_force_disp_ch2    => tx_cd(2),
      tx_disp_sel_ch2      => '0',
      rxdata_ch2           => rx_data(2*8+7 downto 2*8),
      rx_k_ch2             => rx_k(2),
      rx_disp_err_ch2      => open,
      rx_cv_err_ch2        => rx_error(2),
      rx_serdes_rst_ch2_c  => rx_serdes_rst(2),
      sb_felb_ch2_c        => '0',
      sb_felb_rst_ch2_c    => '0',
      tx_pcs_rst_ch2_c     => tx_pcs_rst(2),
      tx_pwrup_ch2_c       => '1',
      rx_pcs_rst_ch2_c     => rx_pcs_rst(2),
      rx_pwrup_ch2_c       => '1',
      rx_los_low_ch2_s     => rx_los_low(2),
      lsm_status_ch2_s     => lsm_status(2),
      rx_cdr_lol_ch2_s     => rx_cdr_lol(2),
      tx_div2_mode_ch2_c   => '0',
      rx_div2_mode_ch2_c   => '0',
      
      hdinp_ch3            => hdinp (3),
      hdinn_ch3            => hdinn (3),
      hdoutp_ch3           => hdoutp(3),
      hdoutn_ch3           => hdoutn(3),
      txiclk_ch3           => CLK_REF_FULL, --clk_tx_full(3),
      rxiclk_ch3           => clk_rx_full(3), --CLK_REF_FULL, --clk_tx_full(3),
      rx_full_clk_ch3      => clk_rx_full(3),
      rx_half_clk_ch3      => clk_rx_half(3),
      tx_full_clk_ch3      => clk_tx_full(3),
      tx_half_clk_ch3      => clk_tx_half(3),
      fpga_rxrefclk_ch3    => CLK_INTERNAL_FULL,
      txdata_ch3           => tx_data(3*8+7 downto 3*8),
      tx_k_ch3             => tx_k(3),
      tx_force_disp_ch3    => tx_cd(3),
      tx_disp_sel_ch3      => '0',
      rxdata_ch3           => rx_data(3*8+7 downto 3*8),
      rx_k_ch3             => rx_k(3),
      rx_disp_err_ch3      => open,
      rx_cv_err_ch3        => rx_error(3),
      rx_serdes_rst_ch3_c  => rx_serdes_rst(3),
      sb_felb_ch3_c        => '0',
      sb_felb_rst_ch3_c    => '0',
      tx_pcs_rst_ch3_c     => tx_pcs_rst(3),
      tx_pwrup_ch3_c       => '1',
      rx_pcs_rst_ch3_c     => rx_pcs_rst(3),
      rx_pwrup_ch3_c       => '1',
      rx_los_low_ch3_s     => rx_los_low(3),
      lsm_status_ch3_s     => lsm_status(3),
      rx_cdr_lol_ch3_s     => rx_cdr_lol(3),
      tx_div2_mode_ch3_c   => '0',
      rx_div2_mode_ch3_c   => '0',      
      
      SCI_WRDATA           => sci_data_in_i,
      SCI_RDDATA           => sci_data_out_i,
      SCI_ADDR             => sci_addr_i,
      SCI_SEL_QUAD         => sci_ch_i(4),
      SCI_SEL_CH0          => sci_ch_i(0),
      SCI_SEL_CH1          => sci_ch_i(1),
      SCI_SEL_CH2          => sci_ch_i(2),
      SCI_SEL_CH3          => sci_ch_i(3),
      SCI_RD               => sci_read_i,
      SCI_WRN              => sci_write_i,
      
      fpga_txrefclk        => CLK_REF_FULL,
      tx_serdes_rst_c      => '0',
      tx_pll_lol_qd_s      => tx_pll_lol,
      rst_qd_c             => rst_qd(0),
      serdes_rst_qd_c      => '0',
      tx_sync_qd_c         => '0'

      );


      
      
      
gen_control : for i in 0 to 3 generate   
  gen_used_control : if IS_USED(i) = c_YES generate
    THE_MED_CONTROL : entity work.med_sync_control
      generic map(
        IS_SYNC_SLAVE => IS_SYNC_SLAVE(i),
        IS_TX_RESET   => 1
        )
      port map(
        CLK_SYS     => SYSCLK,
        CLK_RXI     => clk_rx_full(i), --CLK_REF_FULL,
        CLK_RXHALF  => clk_rx_half(i),
        CLK_TXI     => CLK_REF_FULL, --clk_tx_full(i),
        CLK_REF     => CLK_INTERNAL_FULL,
        RESET       => RESET,
        CLEAR       => CLEAR,
        
        SFP_LOS     => SD_LOS_IN(i),
        TX_LOL      => tx_pll_lol,
        RX_CDR_LOL  => rx_cdr_lol(i),
        RX_LOS      => rx_los_low(i),
        WA_POSITION => wa_position(i*4+3 downto i*4),
        
        RX_SERDES_RST => rx_serdes_rst(i),
        RX_PCS_RST    => rx_pcs_rst(i),
        QUAD_RST      => rst_qd(i),
        TX_PCS_RST    => tx_pcs_rst(i),

        MEDIA_MED2INT => MEDIA_MED2INT(i),
        MEDIA_INT2MED => MEDIA_INT2MED(i),
        
        TX_DATA       => tx_data(i*8+7 downto i*8),
        TX_K          => tx_k(i),
        TX_CD         => tx_cd(i),
        RX_DATA       => rx_data(i*8+7 downto i*8),
        RX_K          => rx_k(i),
        
        TX_DLM_WORD   => TX_DLM_WORD(i*8+7 downto i*8),
        TX_DLM        => TX_DLM(i),
        RX_DLM_WORD   => RX_DLM_WORD(i*8+7 downto i*8),
        RX_DLM        => RX_DLM(i),
        
        STAT_TX_CONTROL  => stat_tx_control_i(i*32+31 downto i*32),
        STAT_RX_CONTROL  => stat_rx_control_i(i*32+31 downto i*32),
        DEBUG_TX_CONTROL => debug_tx_control_i(i*32+31 downto i*32),
        DEBUG_RX_CONTROL => debug_rx_control_i(i*32+31 downto i*32),
        STAT_RESET       => stat_fsm_reset_i(i*32+31 downto i*32)
        );
  end generate;   

  gen_not_used : if IS_USED(i) = c_NO generate
    MEDIA_MED2INT(i).dataready <= '0';
    MEDIA_MED2INT(i).tx_read   <= '1';
    MEDIA_MED2INT(i).stat_op   <= x"0007";
  end generate;
end generate;     

THE_SCI_READER : entity work.sci_reader
  port map(
    CLK        => SYSCLK,
    RESET      => RESET,
    
    --SCI
    SCI_WRDATA  => sci_data_in_i,
    SCI_RDDATA  => sci_data_out_i,
    SCI_ADDR    => sci_addr_i,
    SCI_SEL     => sci_ch_i,
    SCI_RD      => sci_read_i,
    SCI_WR      => sci_write_i,
    
    WA_POS_OUT  => open,
    
    --Slowcontrol
    BUS_RX      => BUS_RX,
    BUS_TX      => BUS_TX,
    
    MEDIA_STATUS_REG_IN(31 downto 0)   => stat_rx_control_i(31 downto 0),
    MEDIA_STATUS_REG_IN(63 downto 32)  => stat_tx_control_i(31 downto 0),
    MEDIA_STATUS_REG_IN(95 downto 64)  => stat_fsm_reset_i(31 downto 0),
    MEDIA_STATUS_REG_IN(127 downto 96) => (others => '0'),
    DEBUG_OUT   => open
    );

wa_position <= (others => '0');
    
STAT_DEBUG(13 downto 0)   <= debug_tx_control_i(13 downto 0);
STAT_DEBUG(15 downto 14) <= debug_tx_control_i(17 downto 16);
  
 
end architecture;

