LIBRARY ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;



entity rich is
  port(
    CLK40M     : in std_logic;
    CLK100M_P  : in std_logic;
    CLK100M_N  : in std_logic;
    FPGA_LED   : out std_logic_vector(4 downto 0);
    SD_RXD_P   : in std_logic;
    SD_RXD_N   : in std_logic;
    SD_TXD_P   : out std_logic;
    SD_TXD_N   : out std_logic;
    SD_MD      : inout std_logic_vector(2 downto 0);
    SD_TXDIS   : out std_logic;
    SD_LOS     : in  std_logic;
    SD_TXFAULT : out std_logic;
    SD_RATE    : out std_logic;
    ONEWIRE    : inout std_logic;
    FPGA_EXP   : out std_logic_vector(15 downto 0)
   );
end entity;

architecture rich of rich is

  component pcs_for_ecp2m
    port(
      core_txrefclk          : in  std_logic;
      core_rxrefclk          : in  std_logic;
      hdinp2                 : in  std_logic;
      hdinn2                 : in  std_logic;
      ff_rxiclk_ch2          : in  std_logic;
      ff_txiclk_ch2          : in  std_logic;
      ff_ebrd_clk_2          : in  std_logic;
      ff_txdata_ch2          : in  std_logic_vector(15 downto 0);
      ff_tx_k_cntrl_ch2      : in  std_logic_vector(1 downto 0);
      ff_force_disp_ch2      : in  std_logic_vector(1 downto 0);
      ff_disp_sel_ch2        : in  std_logic_vector(1 downto 0);
      ff_correct_disp_ch2    : in  std_logic_vector(1 downto 0);
      ffc_rrst_ch2           : in  std_logic;
      ffc_signal_detect_ch2  : in  std_logic;
      ffc_enable_cgalign_ch2 : in  std_logic;
      ffc_lane_tx_rst_ch2    : in  std_logic;
      ffc_lane_rx_rst_ch2    : in  std_logic;
      ffc_txpwdnb_ch2        : in  std_logic;
      ffc_rxpwdnb_ch2        : in  std_logic;
      ffc_macro_rst          : in  std_logic;
      ffc_quad_rst           : in  std_logic;
      ffc_trst               : in  std_logic;
      hdoutp2                : out std_logic;
      hdoutn2                : out std_logic;
      ff_rxdata_ch2          : out std_logic_vector(15 downto 0);
      ff_rx_k_cntrl_ch2      : out std_logic_vector(1 downto 0);
      ff_rxfullclk_ch2       : out std_logic;
      ff_rxhalfclk_ch2       : out std_logic;
      ff_disp_err_ch2        : OUT std_logic_vector(1 downto 0);
      ff_cv_ch2              : OUT std_logic_vector(1 downto 0);
      ffs_rlos_lo_ch2        : OUT std_logic;
      ffs_rlol_ch2           : OUT std_logic;
      oob_out_ch2            : OUT std_logic;
      ff_txfullclk           : OUT std_logic;
      ff_txhalfclk : OUT std_logic;
      refck2core : OUT std_logic;
      ffs_plol : OUT std_logic
      );
  END COMPONENT;
  
  component flexi_PCS_channel_synch
    port (
      SYSTEM_CLK         : in  std_logic;
      TX_CLK             : in  std_logic;
      RX_CLK             : in  std_logic;
      RESET              : in  std_logic;
      RXD                : in  std_logic_vector(15 downto 0);
      RXD_SYNCH          : out std_logic_vector(15 downto 0);
      RX_K               : in  std_logic_vector(1 downto 0);
      RX_RST             : out std_logic;
      CV                 : in  std_logic_vector(1 downto 0);
      TXD                : in  std_logic_vector(15 downto 0);
      TXD_SYNCH          : out std_logic_vector(15 downto 0);
      TX_K               : out std_logic_vector(1 downto 0);
      DATA_VALID_IN      : in  std_logic;
      DATA_VALID_OUT     : out std_logic;
      FLEXI_PCS_STATUS   : out std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_ERROR_OUT      : out std_logic_vector(2 downto 0);
      MED_READ_IN        : in  std_logic);
  end component;
  
  component flexi_PCS_synch
  generic (
    HOW_MANY_CHANNELS      :     positive);
  port (
    SYSTEM_CLK             : in  std_logic;
    CLK                    : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)-1 downto 0);
    RX_CLK                 : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*4-1 downto 0);
    RESET                  : in  std_logic;
    RXD                    : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*64-1 downto 0);
    MED_DATA_OUT           : out std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
    RX_K                   : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
    RX_RST                 : out std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*4-1 downto 0);
    CV                     : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
    MED_DATA_IN            : in  std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
    TXD_SYNCH              : out std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*64-1 downto 0);
    TX_K                   : out std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
    MED_DATAREADY_IN       : in  std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
    MED_DATAREADY_OUT      : out std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
    FLEXI_PCS_SYNCH_STATUS : out std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
    MED_PACKET_NUM_IN      : in  std_logic_vector(HOW_MANY_CHANNELS*2-1 downto 0);
    MED_PACKET_NUM_OUT     : out std_logic_vector(HOW_MANY_CHANNELS*2-1 downto 0);
    MED_READ_IN            : in  std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
    MED_READ_OUT           : out std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
    MED_ERROR_OUT          : out std_logic_vector(HOW_MANY_CHANNELS*3-1 downto 0);
    MED_STAT_OP            : out  std_logic_vector (HOW_MANY_CHANNELS*16-1 downto 0);
    MED_CTRL_OP            : in std_logic_vector (HOW_MANY_CHANNELS*16-1 downto 0)
    );
  end component;
  
  component DCS
-- synthesis translate_off
    --sim
    generic (
      DCSMODE  :     string := "POS");
-- synthesis translate_on
    port (
      CLK0   : in  std_logic;
      CLK1   : in  std_logic;
      SEL    : in  std_logic;
      DCSOUT : out std_logic);
    end component;

  component link_test
    port (
      CLK        : in  std_logic;
      RESET      : in  std_logic;
      DATA_IN    : in  std_logic_vector(15 downto 0);
      DATA_OUT   : out std_logic_vector(15 downto 0);
      VALID_IN   : in  std_logic;
      VALID_OUT  : out std_logic;
      LINK_DEBUG : out std_logic_vector(31 downto 0);
      LINK_INFO  : in  std_logic_vector(15 downto 0));
  end component;
  
  signal core_txrefclk_i          : std_logic;
  signal core_rxrefclk_i          : std_logic;
  signal hdinp2_i                 : std_logic;
  signal hdinn2_i                 : std_logic;
  signal ff_rxiclk_ch2_i          : std_logic;
  signal ff_txiclk_ch2_i          : std_logic;
  signal ff_ebrd_clk_2_i          : std_logic;
  signal ff_txdata_ch2_i          : std_logic_vector(15 downto 0);
  signal ff_tx_k_cntrl_ch2_i      : std_logic_vector(1 downto 0);
  signal ff_force_disp_ch2_i      : std_logic_vector(1 downto 0);
  signal ff_disp_sel_ch2_i        : std_logic_vector(1 downto 0);
  signal ff_correct_disp_ch2_i    : std_logic_vector(1 downto 0);
  signal ffc_rrst_ch2_i           : std_logic;
  signal ffc_signal_detect_ch2_i  : std_logic;
  signal ffc_enable_cgalign_ch2_i : std_logic;
  signal ffc_lane_tx_rst_ch2_i    : std_logic;
  signal ffc_lane_rx_rst_ch2_i    : std_logic;
  signal ffc_txpwdnb_ch2_i        : std_logic;
  signal ffc_rxpwdnb_ch2_i        : std_logic;
  signal ffc_macro_rst_i          : std_logic;
  signal ffc_quad_rst_i           : std_logic;
  signal ffc_trst_i               : std_logic;
  signal hdoutp2_i                : std_logic;
  signal hdoutn2_i                : std_logic;
  signal ff_rxdata_ch2_i          : std_logic_vector(15 downto 0);
  signal ff_rx_k_cntrl_ch2_i      : std_logic_vector(1 downto 0);
  signal ff_rxfullclk_ch2_i       : std_logic;
  signal ff_rxhalfclk_ch2_i       : std_logic;
  signal ff_disp_err_ch2_i        : std_logic_vector(1 downto 0);
  signal ff_cv_ch2_i              : std_logic_vector(1 downto 0);
  signal ffs_rlos_lo_ch2_i        : std_logic;
  signal ffs_rlol_ch2_i           : std_logic;
  signal oob_out_ch2_i            : std_logic;
  signal ff_txfullclk_i           : std_logic;
  signal ff_txhalfclk_i           : std_logic;
  signal refck2core_i             : std_logic;
  signal ffs_plol_i               : std_logic;
  -- reset
  signal global_reset_cnt : std_logic_vector(3 downto 0);
  signal global_reset_i : std_logic:='0';
  signal counter : std_logic_vector(31 downto 0);
  -- dcs_clock
  signal dcs_clk_out : std_logic;
  signal not_lock : std_logic;
  --synch
  signal data_valid_out_i : std_logic;
  signal flexi_PCS_status_i : std_logic_vector(15 downto 0);
  signal ffc_lane_rx_rst_ch2_start  : std_logic;
  signal ffc_lane_rx_rst_ch2_resync  : std_logic;
  --test
  signal data_out_i : std_logic_vector(15 downto 0);
  signal data_in_i : std_logic_vector(15 downto 0);
  signal data_valid_in_i : std_logic;
  signal test_link_debug : std_logic_vector(31 downto 0);
  signal test_link_info : std_logic_vector(15 downto 0);
begin  -- rich
  RESET_COUNTER_a       : process (CLK40M)
  begin
    if rising_edge(CLK40M) then
      if counter < x"0ffffffe" then
        counter            <= counter +1;
      else
        counter            <= counter;
      end if;
    end if;
  end process RESET_COUNTER_a;
  
  ffc_quad_rst_i            <= '1' when (counter > x"0000ffff" and counter < x"0001000f") else '0';
  ffc_lane_tx_rst_ch2_i     <= '1' when (counter > x"00ffffff" and counter < x"0f00000f") else '0';
  ffc_lane_rx_rst_ch2_start     <= '1' when (counter > x"00ffffff" and counter < x"0f00000f") else '0';
  
  REF_CLK_SELECT: DCS
 -- synthesis translate_off
   
   generic map (--no_sim--
     DCSMODE => "POS")--no_sim--
 -- synthesis translate_on
   port map (
       CLK0   => ff_rxhalfclk_ch2_i,
       CLK1   => CLK40M,
       SEL    => ffs_rlol_ch2_i,--hub_register_0a_i(0),--'0',--switch_rx_clk,
       DCSOUT => dcs_clk_out);
  
  serdes : pcs_for_ecp2m port map(
    core_txrefclk          => CLK40M,
    core_rxrefclk          => dcs_clk_out,--CLK40M,--ff_rxhalfclk_ch2_i,
    hdinp2                 => SD_RXD_P,
    hdinn2                 => SD_RXD_N,
    hdoutp2                => SD_TXD_P,
    hdoutn2                => SD_TXD_N,
    ff_rxiclk_ch2          => ff_rxhalfclk_ch2_i,
    ff_txiclk_ch2          => ff_txhalfclk_i,
    ff_ebrd_clk_2          => open,--ff_ebrd_clk_2_i,
    ff_txdata_ch2          => ff_txdata_ch2_i,
    ff_rxdata_ch2          => ff_rxdata_ch2_i,
    ff_tx_k_cntrl_ch2      => ff_tx_k_cntrl_ch2_i,
    ff_rx_k_cntrl_ch2      => ff_rx_k_cntrl_ch2_i,
    ff_rxfullclk_ch2       => ff_rxfullclk_ch2_i,
    ff_rxhalfclk_ch2       => ff_rxhalfclk_ch2_i,
    ff_force_disp_ch2      => "00",--ff_force_disp_ch2_i,
    ff_disp_sel_ch2        => "00",--ff_disp_sel_ch2_i,
    ff_correct_disp_ch2    => ff_correct_disp_ch2_i,
    ff_disp_err_ch2        => ff_disp_err_ch2_i,
    ff_cv_ch2              => ff_cv_ch2_i,
    ffc_rrst_ch2           => '0',--ffc_rrst_ch2_i,
    ffc_signal_detect_ch2  => '1',--ffc_signal_detect_ch2_i,
    ffc_enable_cgalign_ch2 => '1',--ffc_enable_cgalign_ch2_i,
    ffc_lane_tx_rst_ch2    => ffc_lane_tx_rst_ch2_i,
    ffc_lane_rx_rst_ch2    => ffc_lane_rx_rst_ch2_i,
    ffc_txpwdnb_ch2        => '1',--ffc_txpwdnb_ch2_i,
    ffc_rxpwdnb_ch2        => '1',--ffc_rxpwdnb_ch2_i,
    ffs_rlos_lo_ch2        => ffs_rlos_lo_ch2_i,
    ffs_rlol_ch2           => ffs_rlol_ch2_i,
    oob_out_ch2            => oob_out_ch2_i,
    ffc_macro_rst          => '0',--ffc_macro_rst_i,
    ffc_quad_rst           => global_reset_i,--ffc_quad_rst_i,
    ffc_trst               => '0',--ffc_trst_i,
    ff_txfullclk           => ff_txfullclk_i,
    ff_txhalfclk           => ff_txhalfclk_i,
    refck2core => refck2core_i,
    ffs_plol => ffs_plol_i
    );
  ffc_lane_rx_rst_ch2_i <= ffc_lane_rx_rst_ch2_resync or ffc_lane_rx_rst_ch2_start;
  
  SYNCH: flexi_PCS_channel_synch
    port map (
        SYSTEM_CLK         => CLK40M,
        TX_CLK             => ff_txhalfclk_i,
        RX_CLK             => ff_rxhalfclk_ch2_i,
        RESET              => global_reset_i,
        RXD                => ff_rxdata_ch2_i,
        RXD_SYNCH          => data_in_i,
        RX_K               => ff_rx_k_cntrl_ch2_i,
        RX_RST             => ffc_lane_rx_rst_ch2_resync,
        CV                 => ff_cv_ch2_i,
        TXD                => data_out_i,
        TXD_SYNCH          => ff_txdata_ch2_i,
        TX_K               => ff_tx_k_cntrl_ch2_i,
        DATA_VALID_IN      => data_valid_in_i,
        DATA_VALID_OUT     => data_valid_out_i,
        FLEXI_PCS_STATUS   => flexi_pcs_status_i,
        MED_PACKET_NUM_OUT => open,
        MED_ERROR_OUT      => open,
        MED_READ_IN        => '1');
  
  test_link_info(2 downto 0) <= ff_cv_ch2_i & flexi_pcs_status_i(2);
    
  LINK_TETS_INST: link_test
    port map (
        CLK        => CLK40M,
        RESET      => global_reset_i,
        DATA_IN    => data_in_i,
        DATA_OUT   => data_out_i,
        VALID_IN   => data_valid_out_i,
        VALID_OUT  => data_valid_in_i,
        LINK_DEBUG => test_link_debug,
        LINK_INFO  => test_link_info);


  
   GLOBAL_RESET: process(CLK40M,global_reset_cnt,global_reset_i)
   begin
     if rising_edge(CLK40M) then
       if global_reset_cnt < x"e" or global_reset_cnt =x"f" then
         global_reset_cnt <= global_reset_cnt + 1;
         global_reset_i <= '1';
       elsif global_reset_cnt = x"e" then
         global_reset_i <= '0';
         global_reset_cnt <= x"e";
       else
         global_reset_i <= '0';
         global_reset_cnt <= global_reset_cnt;
       end if;
   end if;
 end process GLOBAL_RESET;

--   ff_tx_k_cntrl_ch2_i <= "10";
--   ff_txdata_ch2_i <= x"bcc5";
  FPGA_LED(4 downto 1) <= "1010";
  FPGA_LED(0) <= not flexi_pcs_status_i(2);     

  FPGA_EXP <= test_link_debug(15 downto 0);

--   FPGA_EXP(0) <= CLK40M;
--   FPGA_EXP(1) <= ff_rxhalfclk_ch2_i;
--   FPGA_EXP(2) <= dcs_clk_out;
--   FPGA_EXP(3) <= ff_cv_ch2_i(0);
--   FPGA_EXP(4) <= ff_cv_ch2_i(1);
--   FPGA_EXP(5) <= ff_rx_k_cntrl_ch2_i(0);
--   FPGA_EXP(6) <= ff_rx_k_cntrl_ch2_i(1);
--   FPGA_EXP(7) <= ff_disp_err_ch2_i(0);
--   FPGA_EXP(8) <= ff_disp_err_ch2_i(1);
--   FPGA_EXP(9) <= ffs_rlos_lo_ch2_i;
--   FPGA_EXP(10)<= ffs_rlol_ch2_i;
--   FPGA_EXP(11)<= global_reset_i;
--   FPGA_EXP(12)<= ffs_plol_i;
--   FPGA_EXP(13) <= not flexi_pcs_status_i(2);
--   FPGA_EXP(14) <= ffc_lane_rx_rst_ch2_i;
       
end rich;
