library IEEE;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;
use work.version.all;
use work.trb_net_std.all;
use work.trb_net16_hub_func.all;
use ieee.std_logic_arith.all;
-- library sc;
-- use sc.components.all;
entity hub is
  generic (
   HOW_MANY_CHANNELS : integer range 2 to c_MAX_MII_PER_HUB := 4
   );
  port (
    LVDS_CLK_200P : in    std_logic;
    --addon connector
    ADO_TTL       : inout std_logic_vector(46 downto 0);
    --diodes
    DBAD          : out   std_logic;
    DGOOD         : out   std_logic;
    DINT          : out   std_logic;
    DWAIT         : out   std_logic;
    LOK           : out   std_logic_vector(16 downto 1);
    RT            : out   std_logic_vector(16 downto 1);
    --sfp
    TX_DIS        : out   std_logic_vector(16 downto 1);
    IPLL          : out   std_logic;
    OPLL          : out   std_logic;
    --data to/from optical tranceivers
    SFP_INP_N     : in    std_logic_vector(15 downto 0);
    SFP_INP_P     : in    std_logic_vector(15 downto 0);
    SFP_OUT_N     : out   std_logic_vector(15 downto 0);
    SFP_OUT_P     : out   std_logic_vector(15 downto 0);
    --sfp
    SFP_LOS       : in    std_logic_vector(16 downto 1);
    --tempsens
    FS_PE_11      : inout std_logic;
    --etrax_interface
    FS_PE         : inout std_logic_vector(9 downto 8)--sim--;
--sim--       OPT_DATA_IN : in std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*64-1 downto 0);
--sim--       OPT_DATA_OUT : out std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*64-1 downto 0);
--sim--       OPT_DATA_VALID_IN : in std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
--sim--       OPT_DATA_VALID_OUT : out std_logic_vector(HOW_MANY_CHANNELS-1 downto 0)
    );
end hub;
--add all sfp connections to measure opt. power temp. sens and if there is SFP

architecture hub of hub is
  
  component serdes_fpga_ref_clk
    port(
      rxrefclk             : in  std_logic;
      refclk               : in  std_logic;
      hdinp_0              : in  std_logic;
      hdinn_0              : in  std_logic;
      tclk_0               : in  std_logic;
      rclk_0               : in  std_logic;
      tx_rst_0             : in  std_logic;
      rx_rst_0             : in  std_logic;
      txd_0                : in  std_logic_vector(15 downto 0);
      tx_k_0               : in  std_logic_vector(1 downto 0);
      tx_force_disp_0      : in  std_logic_vector(1 downto 0);
      tx_disp_sel_0        : in  std_logic_vector(1 downto 0);
      tx_crc_init_0        : in  std_logic_vector(1 downto 0);
      word_align_en_0      : in  std_logic;
      mca_align_en_0       : in  std_logic;
      felb_0               : in  std_logic;
      lsm_en_0             : in  std_logic;
      hdinp_1              : in  std_logic;
      hdinn_1              : in  std_logic;
      tclk_1               : in  std_logic;
      rclk_1               : in  std_logic;
      tx_rst_1             : in  std_logic;
      rx_rst_1             : in  std_logic;
      txd_1                : in  std_logic_vector(15 downto 0);
      tx_k_1               : in  std_logic_vector(1 downto 0);
      tx_force_disp_1      : in  std_logic_vector(1 downto 0);
      tx_disp_sel_1        : in  std_logic_vector(1 downto 0);
      tx_crc_init_1        : in  std_logic_vector(1 downto 0);
      word_align_en_1      : in  std_logic;
      mca_align_en_1       : in  std_logic;
      felb_1               : in  std_logic;
      lsm_en_1             : in  std_logic;
      hdinp_2              : in  std_logic;
      hdinn_2              : in  std_logic;
      tclk_2               : in  std_logic;
      rclk_2               : in  std_logic;
      tx_rst_2             : in  std_logic;
      rx_rst_2             : in  std_logic;
      txd_2                : in  std_logic_vector(15 downto 0);
      tx_k_2               : in  std_logic_vector(1 downto 0);
      tx_force_disp_2      : in  std_logic_vector(1 downto 0);
      tx_disp_sel_2        : in  std_logic_vector(1 downto 0);
      tx_crc_init_2        : in  std_logic_vector(1 downto 0);
      word_align_en_2      : in  std_logic;
      mca_align_en_2       : in  std_logic;
      felb_2               : in  std_logic;
      lsm_en_2             : in  std_logic;
      hdinp_3              : in  std_logic;
      hdinn_3              : in  std_logic;
      tclk_3               : in  std_logic;
      rclk_3               : in  std_logic;
      tx_rst_3             : in  std_logic;
      rx_rst_3             : in  std_logic;
      txd_3                : in  std_logic_vector(15 downto 0);
      tx_k_3               : in  std_logic_vector(1 downto 0);
      tx_force_disp_3      : in  std_logic_vector(1 downto 0);
      tx_disp_sel_3        : in  std_logic_vector(1 downto 0);
      tx_crc_init_3        : in  std_logic_vector(1 downto 0);
      word_align_en_3      : in  std_logic;
      mca_align_en_3       : in  std_logic;
      felb_3               : in  std_logic;
      lsm_en_3             : in  std_logic;
      mca_resync_01        : in  std_logic;
      mca_resync_23        : in  std_logic;
      quad_rst             : in  std_logic;
      serdes_rst           : in  std_logic;
      rxa_pclk             : out std_logic;
      rxb_pclk             : out std_logic;
      hdoutp_0             : out std_logic;
      hdoutn_0             : out std_logic;
      ref_0_sclk           : out std_logic;
      rx_0_sclk            : out std_logic;
      rxd_0                : out std_logic_vector(15 downto 0);
      rx_k_0               : out std_logic_vector(1 downto 0);
      rx_disp_err_detect_0 : out std_logic_vector(1 downto 0);
      rx_cv_detect_0       : out std_logic_vector(1 downto 0);
      rx_crc_eop_0         : out std_logic_vector(1 downto 0);
      lsm_status_0         : out std_logic;
      hdoutp_1             : out std_logic;
      hdoutn_1             : out std_logic;
      ref_1_sclk           : out std_logic;
      rx_1_sclk            : out std_logic;
      rxd_1                : out std_logic_vector(15 downto 0);
      rx_k_1               : out std_logic_vector(1 downto 0);
      rx_disp_err_detect_1 : out std_logic_vector(1 downto 0);
      rx_cv_detect_1       : out std_logic_vector(1 downto 0);
      rx_crc_eop_1         : out std_logic_vector(1 downto 0);
      lsm_status_1         : out std_logic;
      hdoutp_2             : out std_logic;
      hdoutn_2             : out std_logic;
      ref_2_sclk           : out std_logic;
      rx_2_sclk            : out std_logic;
      rxd_2                : out std_logic_vector(15 downto 0);
      rx_k_2               : out std_logic_vector(1 downto 0);
      rx_disp_err_detect_2 : out std_logic_vector(1 downto 0);
      rx_cv_detect_2       : out std_logic_vector(1 downto 0);
      rx_crc_eop_2         : out std_logic_vector(1 downto 0);
      lsm_status_2         : out std_logic;
      hdoutp_3             : out std_logic;
      hdoutn_3             : out std_logic;
      ref_3_sclk           : out std_logic;
      rx_3_sclk            : out std_logic;
      rxd_3                : out std_logic_vector(15 downto 0);
      rx_k_3               : out std_logic_vector(1 downto 0);
      rx_disp_err_detect_3 : out std_logic_vector(1 downto 0);
      rx_cv_detect_3       : out std_logic_vector(1 downto 0);
      rx_crc_eop_3         : out std_logic_vector(1 downto 0);
      lsm_status_3         : out std_logic;
      mca_aligned_01       : out std_logic;
      mca_inskew_01        : out std_logic;
      mca_outskew_01       : out std_logic;
      mca_aligned_23       : out std_logic;
      mca_inskew_23        : out std_logic;
      mca_outskew_23       : out std_logic;
      ref_pclk             : out std_logic
      );
  end component;
  
  component up_down_counter
    generic (
      NUMBER_OF_BITS : positive);
    port (
      CLK       : in  std_logic;
      RESET     : in  std_logic;
      COUNT_OUT : out std_logic_vector(NUMBER_OF_BITS-1 downto 0);
      UP_IN     : in  std_logic;
      DOWN_IN   : in  std_logic);
  end component;
  
  component flexi_PCS_synch
    generic (
      HOW_MANY_CHANNELS  :     positive;
      SYSTEM : positive );
    port (
      RESET              : in  std_logic;
      SYSTEM_CLK         : in  std_logic;
      TX_CLK             : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)-1 downto 0);
      RX_CLK             : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*4-1 downto 0);
      RXD                : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*64-1 downto 0);
      RX_K               : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
      RX_RST             : out std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*4-1 downto 0);
      CV                 : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
      TXD                : out std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*64-1 downto 0);
      TX_K               : out std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
      MEDIA_STATUS       : in  std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
      MEDIA_CONTROL      : out std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
      MED_DATAREADY_IN   : in  std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
      MED_DATA_IN        : in  std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
      MED_READ_OUT       : out std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
      MED_DATA_OUT       : out std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
      MED_READ_IN        : in  std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(HOW_MANY_CHANNELS*c_NUM_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(HOW_MANY_CHANNELS*c_NUM_WIDTH-1 downto 0);
      MED_STAT_OP        : out std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
      MED_CTRL_OP        : in  std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
      LINK_DEBUG         : out std_logic_vector(HOW_MANY_CHANNELS*32-1 downto 0)
      );
  end component;

  component trb_net16_hub_base is
    generic (
      --don't change
    --hub control
      HUB_CTRL_CHANNELNUM     : integer range 0 to 3 := c_SLOW_CTRL_CHANNEL;
      HUB_CTRL_DEPTH          : integer range 0 to 6 := c_FIFO_BRAM;
      HUB_USED_CHANNELS       : hub_channel_config_t := (c_YES,c_YES,c_NO,c_YES);
      USE_CHECKSUM            : hub_channel_config_t := (c_NO,c_YES,c_YES,c_YES);
      USE_VENDOR_CORES        : integer range 0 to 1 := c_YES;
      IBUF_SECURE_MODE        : integer range 0 to 1 := c_NO;
      INIT_ADDRESS            : std_logic_vector(15 downto 0) := x"F004";
      INIT_UNIQUE_ID          : std_logic_vector(63 downto 0) := (others => '0');
      COMPILE_TIME            : std_logic_vector(31 downto 0) := x"00000000";
      COMPILE_VERSION         : std_logic_vector(15 downto 0) := x"0001";
      HARDWARE_VERSION        : std_logic_vector(31 downto 0) := x"12345678";
    --media interfaces
      MII_NUMBER              : integer range 2 to c_MAX_MII_PER_HUB := 3;
      MII_IBUF_DEPTH          : hub_iobuf_config_t := std_HUB_IBUF_DEPTH;
    -- settings for external api connections
      INT_NUMBER              : integer range 0 to c_MAX_API_PER_HUB := 0;
      INT_CHANNELS            : hub_api_config_t := (3,3,3,3,3,3,3,3);
      INT_IBUF_DEPTH          : hub_api_config_t := (6,6,6,6,6,6,6,6)
      );
    port (
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      --Media interfacces
      MED_DATAREADY_OUT : out std_logic_vector (MII_NUMBER-1 downto 0);
      MED_DATA_OUT      : out std_logic_vector (MII_NUMBER*c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT: out std_logic_vector (MII_NUMBER*c_NUM_WIDTH-1 downto 0);
      MED_READ_IN       : in  std_logic_vector (MII_NUMBER-1 downto 0);
      MED_DATAREADY_IN  : in  std_logic_vector (MII_NUMBER-1 downto 0);
      MED_DATA_IN       : in  std_logic_vector (MII_NUMBER*c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN : in  std_logic_vector (MII_NUMBER*c_NUM_WIDTH-1 downto 0);
      MED_READ_OUT      : out std_logic_vector (MII_NUMBER-1 downto 0);
      MED_STAT_OP       : in  std_logic_vector (MII_NUMBER*16-1 downto 0);
      MED_CTRL_OP       : out std_logic_vector (MII_NUMBER*16-1 downto 0);
      --INT: interfaces to connect APIs
      INT_INIT_DATAREADY_OUT    : out std_logic_vector (INT_NUMBER downto 0);
      INT_INIT_DATA_OUT         : out std_logic_vector (INT_NUMBER*c_DATA_WIDTH downto 0);
      INT_INIT_PACKET_NUM_OUT   : out std_logic_vector (INT_NUMBER*c_NUM_WIDTH  downto 0);
      INT_INIT_READ_IN          : in  std_logic_vector (INT_NUMBER downto 0) := (others => '0');
      INT_INIT_DATAREADY_IN     : in  std_logic_vector (INT_NUMBER downto 0) := (others => '0');
      INT_INIT_DATA_IN          : in  std_logic_vector (INT_NUMBER*c_DATA_WIDTH downto 0) := (others => '0');
      INT_INIT_PACKET_NUM_IN    : in  std_logic_vector (INT_NUMBER*c_NUM_WIDTH  downto 0) := (others => '0');
      INT_INIT_READ_OUT         : out std_logic_vector (INT_NUMBER downto 0);
      INT_REPLY_DATAREADY_OUT   : out std_logic_vector (INT_NUMBER downto 0);
      INT_REPLY_DATA_OUT        : out std_logic_vector (INT_NUMBER*c_DATA_WIDTH downto 0);
      INT_REPLY_PACKET_NUM_OUT  : out std_logic_vector (INT_NUMBER*c_NUM_WIDTH  downto 0);
      INT_REPLY_READ_IN         : in  std_logic_vector (INT_NUMBER downto 0) := (others => '0');
      INT_REPLY_DATAREADY_IN    : in  std_logic_vector (INT_NUMBER downto 0) := (others => '0');
      INT_REPLY_DATA_IN         : in  std_logic_vector (INT_NUMBER*c_DATA_WIDTH downto 0) := (others => '0');
      INT_REPLY_PACKET_NUM_IN   : in  std_logic_vector (INT_NUMBER*c_NUM_WIDTH downto 0) := (others => '0');
      INT_REPLY_READ_OUT        : out std_logic_vector (INT_NUMBER downto 0);
      ONEWIRE               : inout std_logic;
      --Fixed status and control ports
      HUB_STAT_CHANNEL      : out std_logic_vector (2**(c_MUX_WIDTH-1)*16-1 downto 0);
      HUB_STAT_GEN          : out std_logic_vector (31 downto 0);
      MPLEX_CTRL            : in  std_logic_vector (MII_NUMBER*32-1 downto 0);
      MPLEX_STAT            : out std_logic_vector (MII_NUMBER*32-1 downto 0);
      STAT_COMMON_STAT_REGS : out std_logic_vector (std_COMSTATREG*32-1 downto 0);  --Status of common STAT regs
      STAT_COMMON_CTRL_REGS : out std_logic_vector (std_COMCTRLREG*32-1 downto 0);  --Status of common STAT regs
      STAT_REGS             : out std_logic_vector (8*32-1 downto 0);  --Status of custom STAT regs
      STAT_CTRL_REGS        : out std_logic_vector (8*32-1 downto 0);  --Status of custom CTRL regs
      --Additional access to registers
      REGIO_EXT_REG_DATA_IN : in  std_logic_vector(31 downto 0);
      REGIO_EXT_REG_DATA_OUT: out std_logic_vector(31 downto 0);
      REGIO_EXT_REG_WRITE_IN: in  std_logic;
      REGIO_EXT_REG_ADDR_IN : in  std_logic_vector(7 downto 0);

      --Debugging registers
      STAT_DEBUG            : out std_logic_vector (31 downto 0);      --free status regs for debugging
      CTRL_DEBUG            : in  std_logic_vector (31 downto 0)      --free control regs for debugging
      );
  end component;

  component edge_to_pulse
    port (
      clock      : in  std_logic;
      en_clk     : in  std_logic;
      signal_in  : in  std_logic;
      pulse      : out std_logic);
  end component;
   
  component etrax_interfacev2
    generic (
      RW_SYSTEM : positive);
    port (
      CLK                    : in    std_logic;
      RESET                  : in    std_logic;
      DATA_BUS               : in    std_logic_vector(31 downto 0);
      ETRAX_DATA_BUS_B       : inout std_logic_vector(16 downto 0);
      ETRAX_DATA_BUS_B_17    : in    std_logic;
      ETRAX_DATA_BUS_C       : inout std_logic_vector(17 downto 0);
      ETRAX_DATA_BUS_E       : inout std_logic_vector(10 downto 9);
      DATA_VALID             : in    std_logic;
      ETRAX_BUS_BUSY         : in    std_logic;
      ETRAX_IS_READY_TO_READ : out   std_logic;
      TDC_TCK                : out   std_logic;
      TDC_TDI                : out   std_logic;
      TDC_TMS                : out   std_logic;
      TDC_TRST               : out   std_logic;
      TDC_TDO                : in    std_logic;
      TDC_RESET              : out   std_logic;
      EXTERNAL_ADDRESS       : out   std_logic_vector(31 downto 0);
      EXTERNAL_DATA_OUT      : out   std_logic_vector(31 downto 0);
      EXTERNAL_DATA_IN       : in    std_logic_vector(31 downto 0);
      EXTERNAL_ACK           : out   std_logic;
      EXTERNAL_VALID         : in    std_logic;
      EXTERNAL_MODE          : out   std_logic_vector(15 downto 0);
      FPGA_REGISTER_00       : in    std_logic_vector(31 downto 0);
      FPGA_REGISTER_01       : in    std_logic_vector(31 downto 0);
      FPGA_REGISTER_02       : in    std_logic_vector(31 downto 0);
      FPGA_REGISTER_03       : in    std_logic_vector(31 downto 0);
      FPGA_REGISTER_04       : in    std_logic_vector(31 downto 0);
      FPGA_REGISTER_05       : in    std_logic_vector(31 downto 0);
      FPGA_REGISTER_06       : out   std_logic_vector(31 downto 0);
      FPGA_REGISTER_07       : out   std_logic_vector(31 downto 0);
      FPGA_REGISTER_08       : in    std_logic_vector(31 downto 0);
      FPGA_REGISTER_09       : in    std_logic_vector(31 downto 0);
      FPGA_REGISTER_0A       : in    std_logic_vector(31 downto 0);
      FPGA_REGISTER_0B       : in    std_logic_vector(31 downto 0);
      FPGA_REGISTER_0C       : in    std_logic_vector(31 downto 0);
      FPGA_REGISTER_0D       : in    std_logic_vector(31 downto 0);
      FPGA_REGISTER_0E       : out   std_logic_vector(31 downto 0);
--      EXTERNAL_RESET         : out   std_logic;
      LVL2_VALID             : in    std_logic);
  end component;

  component simple_hub
    generic (
      HOW_MANY_CHANNELS : positive);
    port (
      CLK             : in  std_logic;
      RESET           : in  std_logic;
      DATA_IN         : in  std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
      DATA_OUT        : out std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
      DATA_IN_VALID   : in  std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
      SEND_DATA       : out std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
      ENABLE_CHANNELS : in  std_logic_vector(15 downto 0);
      READ_DATA       : out std_logic_vector(HOW_MANY_CHANNELS -1 downto 0);
      HUB_DEBUG       : out std_logic_vector(31 downto 0)
      );
  end component;

  
--  constant HOW_MANY_CHANNELS : integer := 16;
  -----------------------------------------------------------------------------
  -- FLEXI_PCS
  -----------------------------------------------------------------------------
  signal   ref_pclk                 : std_logic_vector((HOW_MANY_CHANNELS+3)/4 -1 downto 0);
  signal   rxd_i                    : std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*64-1 downto 0);
  signal   rxd_synch_i              : std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*64-1 downto 0);
  signal   rx_k_i                   : std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
  signal   rx_rst_i                 : std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*4-1 downto 0);
  signal   cv_i                     : std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
  signal   txd_i                    : std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*64-1 downto 0);
  signal   txd_synch_i              : std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*64-1 downto 0);
  signal   tx_k_i                   : std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
  signal   rxb_pclk_a               : std_logic_vector((HOW_MANY_CHANNELS+3)/4 -1 downto 0);
  signal   rx_clk_i                 : std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*4-1 downto 0); 
  signal   link_debug_i             : std_logic_vector(HOW_MANY_CHANNELS*32-1 downto 0);
  signal   word_align_en            : std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*4-1 downto 0);
  -----------------------------------------------------------------------------
  -- hub trb interface
  -----------------------------------------------------------------------------
  signal hub_register_00_i   : std_logic_vector(31 downto 0);
  signal hub_register_01_i   : std_logic_vector(31 downto 0);
  signal hub_register_02_i   : std_logic_vector(31 downto 0);
  signal hub_register_03_i   : std_logic_vector(31 downto 0);
  signal hub_register_04_i   : std_logic_vector(31 downto 0);
  signal hub_register_05_i   : std_logic_vector(31 downto 0);
  signal hub_register_06_i   : std_logic_vector(31 downto 0);
  signal hub_register_07_i   : std_logic_vector(31 downto 0);
  signal hub_register_08_i   : std_logic_vector(31 downto 0);
  signal hub_register_09_i   : std_logic_vector(31 downto 0);
  signal hub_register_0a_i   : std_logic_vector(31 downto 0);
  signal hub_register_0b_i   : std_logic_vector(31 downto 0);
  signal hub_register_0c_i   : std_logic_vector(31 downto 0);
  signal hub_register_0d_i   : std_logic_vector(31 downto 0);
  signal hub_register_0e_i   : std_logic_vector(31 downto 0);
  signal hub_register_0f_i   : std_logic_vector(31 downto 0);
  signal hub_register_10_i   : std_logic_vector(31 downto 0);
  signal hub_register_11_i   : std_logic_vector(31 downto 0);
  signal hub_register_12_i   : std_logic_vector(31 downto 0);
  signal hub_register_13_i   : std_logic_vector(31 downto 0);
  signal hub_register_14_i   : std_logic_vector(31 downto 0);
  signal hub_register_15_i   : std_logic_vector(31 downto 0);
  signal hub_register_16_i   : std_logic_vector(31 downto 0);
  signal ADO_TTL_12 : std_logic;
  -----------------------------------------------------------------------------
  -- flexi_PCS to hub interface
  -----------------------------------------------------------------------------
  signal   med_dataready_in_i         : std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
  signal   med_dataready_in_i_test         : std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
  --test
  signal   data_valid_in_i            : std_logic_vector(HOW_MANY_CHANNELS-1 downto 0); 
  signal   med_dataready_out_i        : std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
  signal   med_read_in_i              : std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
  signal   med_read_out_i             : std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
  signal   med_data_out_i             : std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
  signal   med_data_out_i_test             : std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
  
  signal   med_data_in_i              : std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
  signal   med_packet_num_out_i       : std_logic_vector(HOW_MANY_CHANNELS*c_NUM_WIDTH-1 downto 0);
  signal   med_packet_num_in_i        : std_logic_vector(HOW_MANY_CHANNELS*c_NUM_WIDTH-1 downto 0);
  signal   med_error_out_i            : std_logic_vector(HOW_MANY_CHANNELS*3-1 downto 0);
  signal   med_stat_op_i : std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
  signal   med_ctrl_op_i : std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
  signal   hub_stat_channel_i : std_logic_vector(2**(c_MUX_WIDTH-1)*16-1 downto 0);
  signal   hub_stat_gen_i : std_logic_vector(31 downto 0);

  -----------------------------------------------------------------------------
  -- other
  -----------------------------------------------------------------------------
  signal hub_register_0e_and_0d : std_logic_vector(15 downto 0) := x"0006";
  signal cv_counter : std_logic_vector(31 downto 0);
  signal cv_countera : std_logic_vector(31 downto 0);
  signal serdes_ref_clk : std_logic;
  signal serdes_ref_lock : std_logic;
  signal serdes_ref_clks : std_logic;
  signal med_packet_num_in_s : std_logic_vector(HOW_MANY_CHANNELS*2 -1 downto 0);
  signal mplex_ctrl_i : std_logic_vector (HOW_MANY_CHANNELS*32-1 downto 0);
  signal word_counter_for_api_00 : std_logic_vector(1 downto 0);
  signal word_counter_for_api_01 : std_logic_vector(1 downto 0);
  signal global_reset_i : std_logic;
  signal global_reset_cnt : std_logic_vector(3 downto 0):=x"0";
  signal registered_signals : std_logic_vector(7 downto 0);
  signal hub_register_0a_i_synch : std_logic_vector(7 downto 0);
  signal hub_register_0e_and_0d_synch : std_logic_vector(15 downto 0);
  signal test_signal : std_logic_vector(1 downto 0);
  signal pulse_test : std_logic;
  signal saved_lvl1_ready : std_logic_vector(HOW_MANY_CHANNELS-1 downto 0):=(others => '0');
  signal saved_lvl2_ready : std_logic_vector(HOW_MANY_CHANNELS-1 downto 0):=(others => '0');
  signal all_lvl1_ready : std_logic;
  signal all_lvl2_ready : std_logic;
  signal flexi_pcs_ref_clk : std_logic;
  signal lok_i : std_logic_vector(16 downto 1);
  signal not_used_lok : std_logic_vector(15 downto 0);
  signal used_channels_locked : std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
  signal channels_locked : std_logic_vector(16 downto 1);
  signal switch_rx_clk : std_logic;
  signal lock_pattern : std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
  signal all_lvl1_ready_delay1  : std_logic;
  signal all_lvl1_ready_delay2  : std_logic;
  signal all_lvl2_ready_delay1  : std_logic;
  signal all_lvl2_ready_delay2  : std_logic;
  signal media_status_i : std_logic_vector(HOW_MANY_CHANNELS*16-1  downto 0);
  -- etrax interface
--    signal external_address_i : std_logic_vector(31 downto 0);
--    signal external_data_out_i : std_logic_vector(31 downto 0);
--    signal external_data_in_i : std_logic_vector(31 downto 0);
--    signal external_ack_i : std_logic;
--    signal external_valid_i : std_logic;
--    signal external_mode_i : std_logic_vector(7 downto 0);
--    signal data_valid_i : std_logic;
  signal debug_register_00_i : std_logic_vector(7 downto 0);
  signal test2 : std_logic_vector(1 downto 0);
  signal med_read_counter : std_logic_vector(3 downto 0);
  -- simulation
  signal rx_k_sim : std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
  signal tx_k_sim : std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
  signal cv_sim : std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
  signal rx_clk_sim : std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*4-1 downto 0);
  signal ref_pclk_sim : std_logic_vector(((HOW_MANY_CHANNELS+3)/4)-1 downto 0);
  constant trb_net_enable : integer := 1;
  --etrax interface
  signal external_address_i       : std_logic_vector(31 downto 0);
  signal external_data_out_i      : std_logic_vector(31 downto 0);
  signal external_data_in_i       : std_logic_vector(31 downto 0);
  signal external_ack_i           : std_logic;
  signal external_valid_i         : std_logic;
  signal external_mode_i          : std_logic_vector(15 downto 0);
  signal fpga_register_00_i       : std_logic_vector(31 downto 0);
  signal fpga_register_01_i       : std_logic_vector(31 downto 0);
  signal fpga_register_02_i       : std_logic_vector(31 downto 0);
  signal fpga_register_03_i       : std_logic_vector(31 downto 0);
  signal fpga_register_04_i       : std_logic_vector(31 downto 0);
  signal fpga_register_05_i       : std_logic_vector(31 downto 0);
  signal fpga_register_06_i       : std_logic_vector(31 downto 0):=x"00000003";
  signal fpga_register_07_i       : std_logic_vector(31 downto 0);
  signal fpga_register_08_i       : std_logic_vector(31 downto 0);
  signal fpga_register_09_i       : std_logic_vector(31 downto 0);
  signal fpga_register_0a_i       : std_logic_vector(31 downto 0);
  signal fpga_register_0b_i       : std_logic_vector(31 downto 0);
  signal fpga_register_0c_i       : std_logic_vector(31 downto 0);
  signal fpga_register_0d_i       : std_logic_vector(31 downto 0);
  signal fpga_register_0e_i       : std_logic_vector(31 downto 0);
  signal free_counter : std_logic_vector(16 downto 0);
  --simple hub
  signal hub_debug_i : std_logic_vector(31 downto 0);
  
  --test
  constant OPT_TEST_MODE : integer := 0;
  
  --trbnet
  signal hub_stat_debug_i : std_logic_vector(63 downto 0);
  signal hub_ctrl_debug_i : std_logic_vector(63 downto 0);
  signal sfp_los_synch : std_logic_vector(16 downto 1);
  signal wait_counter : std_logic_vector(31 downto 0);
  signal wait_counter_up : std_logic;
begin
  
 GLOBAL_RESET: process(LVDS_CLK_200P,global_reset_cnt)
 begin
   if rising_edge(LVDS_CLK_200P) then
     if global_reset_cnt < x"e" then
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
 
  QUAD_GENERATE                 : for bit_index in 0 to ((HOW_MANY_CHANNELS+3)/4-1) generate
  begin
    QUAD : serdes_fpga_ref_clk
      port map (
        rxrefclk        => LVDS_CLK_200P,--flexi_pcs_ref_clk,--LVDS_CLK_200P,--serdes_ref_clk,--LVDS_CLK_200P,
        refclk          => LVDS_CLK_200P,--serdes_ref_clk,--LVDS_CLK_200P,
        hdinp_0         => SFP_INP_P(bit_index*4+0),
        hdinn_0         => SFP_INP_N(bit_index*4+0),
        tclk_0          => ref_pclk(bit_index),
        rclk_0          => rx_clk_i(0+bit_index*4),
        tx_rst_0        => '0',
        rx_rst_0        => rx_rst_i(0+bit_index*4),--hub_register_0a_i(0),
        txd_0           => txd_synch_i(15+bit_index*64 downto 0+bit_index*64),--hub_register_0e_and_0d,--txd_synch_i(15+bit_index*64 downto 0+bit_index*64),--hub_register_0e_and_0d_synch,--txd_synch_i(15+bit_index*64 downto 0+bit_index*64),--hub_register_0e_and_0d_synch,--txd_synch_i(15+bit_index*64 downto 0+bit_index*64),--hub_register_0e_and_0d_synch,--
        tx_k_0          => tx_k_i(1+bit_index*8 downto 0+bit_index*8),--tx_force_disp_i(bit_index*8+1 downto 0+bit_index*8),--"10",--"10",--hub_register_0a_i_synch(1 downto 0),--"10",
        tx_force_disp_0 => "00",--hub_register_0a_i(3 downto 2),--tx_force_disp_i(bit_index*8+1 downto 0+bit_index*8),--hub_register_0a_i_synch(3 downto 2),--tx_force_disp_i(bit_index*8+1 downto 0+bit_index*8),--hub_register_0a_i_synch(3 downto 2),--tx_force_disp_i(bit_index*8+1 downto 0+bit_index*8),--hub_register_0a_i_synch(3 downto 2),--tx_force_disp_i(bit_index*8+1 downto 0+bit_index*8),
        tx_disp_sel_0   => "00",--hub_register_0a_i(5 downto 4), --"00",--hub_register_0a_i_synch(5 downto 4),--"00",
        tx_crc_init_0   => "00",
        word_align_en_0 => '1',--word_align_en(0+bit_index*4),--'1',
        mca_align_en_0  => '0',
        felb_0          => '0',
        lsm_en_0        => '0',
        hdinp_1         => SFP_INP_P(bit_index*4+1),
        hdinn_1         => SFP_INP_N(bit_index*4+1),
        tclk_1          => ref_pclk(bit_index),
        rclk_1          => rx_clk_i(1+bit_index*4),
        tx_rst_1        => '0',
        rx_rst_1        => rx_rst_i(1+bit_index*4),
        txd_1           => txd_synch_i(31+bit_index*64 downto 16+bit_index*64),
        tx_k_1          => tx_k_i(3+bit_index*8 downto 2+bit_index*8),--tx_force_disp_i(bit_index*8+1 downto 0+bit_index*8),--"10",--"10",--hub_register_0a_i_synch(1 downto 0),--"10",
        tx_force_disp_1      => "00",--tx_k_i(3+bit_index*8 downto 2+bit_index*8),
        tx_disp_sel_1        => "00",
        tx_crc_init_1        => "00",
        word_align_en_1      => '1',--word_align_en(1+bit_index*4),--'1',--
        mca_align_en_1       => '0',
        felb_1               => '0',
        lsm_en_1             => '0',
        hdinp_2              => SFP_INP_P(bit_index*4+2),
        hdinn_2              => SFP_INP_N(bit_index*4+2),
        tclk_2               => ref_pclk(bit_index),
        rclk_2               => rx_clk_i(2+bit_index*4),
        tx_rst_2             => '0',
        rx_rst_2             => rx_rst_i(2+bit_index*4),
        txd_2                => txd_synch_i(47+bit_index*64 downto 32+bit_index*64),
        tx_k_2               => tx_k_i(5+bit_index*8 downto 4+bit_index*8),--"10",
        tx_force_disp_2      => "00",--
        tx_disp_sel_2        => "00",
        tx_crc_init_2        => "00",
        word_align_en_2      => '1',--word_align_en(2+bit_index*4),--'1',
        mca_align_en_2       => '0',
        felb_2               => '0',
        lsm_en_2             => '0',
        hdinp_3              => SFP_INP_P(bit_index*4+3),
        hdinn_3              => SFP_INP_N(bit_index*4+3),
        tclk_3               => ref_pclk(bit_index),
        rclk_3               => rx_clk_i(3+bit_index*4),
        tx_rst_3             => '0',
        rx_rst_3             => rx_rst_i(3+bit_index*4),
        txd_3                => txd_synch_i(63+bit_index*64 downto 48+bit_index*64),
        tx_k_3               => tx_k_i(7+bit_index*8 downto 6+bit_index*8),--"10",
        tx_force_disp_3      => "00",
        tx_disp_sel_3        => "00",
        tx_crc_init_3        => "00",
        word_align_en_3      => '1',--word_align_en(3+bit_index*4),--'1',
        mca_align_en_3       => '0',
        felb_3               => '0',
        lsm_en_3             => '0',
        mca_resync_01        => '0',
        mca_resync_23        => '0',
        quad_rst             => '0',
        serdes_rst           => '0',
        rxa_pclk             => rx_clk_i(0+bit_index*4),
        rxb_pclk             => rxb_pclk_a(bit_index),
        hdoutp_0             => SFP_OUT_P(bit_index*4+0),
        hdoutn_0             => SFP_OUT_N(bit_index*4+0),
        ref_0_sclk           => open,
        rx_0_sclk            => open,
        rxd_0                => rxd_i(15+bit_index*64 downto 0+bit_index*64),
        rx_k_0               => rx_k_i(1+bit_index*8 downto 0+bit_index*8),
        rx_disp_err_detect_0 => open,   --rx_disp_err_detect_0_a,
        rx_cv_detect_0       => cv_i(1+bit_index*8 downto 0+bit_index*8),
        rx_crc_eop_0         => open,
        lsm_status_0         => open,
        hdoutp_1             => SFP_OUT_P(bit_index*4+1),
        hdoutn_1             => SFP_OUT_N(bit_index*4+1),
        ref_1_sclk           => open,
        rx_1_sclk            => rx_clk_i(1+bit_index*4),
        rxd_1                => rxd_i(31+bit_index*64 downto 16+bit_index*64),
        rx_k_1               => rx_k_i(3+bit_index*8 downto 2+bit_index*8),
        rx_disp_err_detect_1 => open,   --rx_disp_err_detect_1_a,
        rx_cv_detect_1       => cv_i(3+bit_index*8 downto 2+bit_index*8),
        rx_crc_eop_1         => open,
        lsm_status_1         => open,
        hdoutp_2             => SFP_OUT_P(bit_index*4+2),
        hdoutn_2             => SFP_OUT_N(bit_index*4+2),
        ref_2_sclk           => open,
        rx_2_sclk            => rx_clk_i(2+bit_index*4),
        rxd_2                => rxd_i(47+bit_index*64 downto 32+bit_index*64),
        rx_k_2               => rx_k_i(5+bit_index*8 downto 4+bit_index*8),
        rx_disp_err_detect_2 => open,   --rx_disp_err_detect_2_a,
        rx_cv_detect_2       => cv_i(5+bit_index*8 downto 4+bit_index*8),
        rx_crc_eop_2         => open,
        lsm_status_2         => open,
        hdoutp_3             => SFP_OUT_P(bit_index*4+3),
        hdoutn_3             => SFP_OUT_N(bit_index*4+3),
        ref_3_sclk           => open,
        rx_3_sclk            => rx_clk_i(3+bit_index*4),
        rxd_3                => rxd_i(63+bit_index*64 downto 48+bit_index*64),
        rx_k_3               => rx_k_i(7+bit_index*8 downto 6+bit_index*8),
        rx_disp_err_detect_3 => open,   --rx_disp_err_detect_3_a,
        rx_cv_detect_3       => cv_i(7+bit_index*8 downto 6+bit_index*8),
        rx_crc_eop_3         => open,
        lsm_status_3         => open,
        mca_aligned_01       => open,   --mca_aligned_01_i,
        mca_inskew_01        => open,   --mca_inskew_01_i,
        mca_outskew_01       => open,   --mca_outskew_01_i,
        mca_aligned_23       => open,   --mca_aligned_23_i,
        mca_inskew_23        => open,   --mca_inskew_23_i,
        mca_outskew_23       => open,   --mca_outskew_23_i,
        ref_pclk             => ref_pclk(bit_index)
        );
  end generate QUAD_GENERATE;
 --   word_align_en <= not rx_rst_i;
--sim-- SIMULATION_CONNECTION: for i in 0 to HOW_MANY_CHANNELS-1 generate
--sim--   rx_k_sim(i*2) <=  not OPT_DATA_VALID_IN(i);
--sim--   rx_k_sim(i*2+1) <= '0';
--sim--   OPT_DATA_VALID_OUT(i) <= not tx_k_sim(i*2);
--sim--   rx_clk_sim <= (others => LVDS_CLK_200P);
--sim--   ref_pclk_sim <= (others =>  LVDS_CLK_200P);
--sim--   cv_sim <= (others => '0');
--sim-- end generate SIMULATION_CONNECTION;
 FLEXI_PCS_INT : flexi_PCS_synch
   generic map (
     HOW_MANY_CHANNELS  => HOW_MANY_CHANNELS,
     SYSTEM => 1)
   port map (
     RESET              => global_reset_i,
     SYSTEM_CLK         => LVDS_CLK_200P,
     TX_CLK             => ref_pclk,  --no_sim--
--sim--       TX_CLK                => ref_pclk_sim,
     RX_CLK             => rx_clk_i,  --no_sim--
--sim--       RX_CLK             => rx_clk_sim,
     RXD                => rxd_i,  --no_sim--
--sim--       RXD                => OPT_DATA_IN,
     RX_K               => rx_k_i,  --no_sim--
--sim--       RX_K               => rx_k_sim,
     RX_RST             => rx_rst_i,
     CV                 => cv_i,  --no_sim--
--sim--       CV                 => cv_sim,     
     TXD                => txd_synch_i,  --no_sim--
--sim--       TXD          => OPT_DATA_OUT,     
     TX_K               => tx_k_i,  --no_sim--
--sim--       TX_K               => tx_k_sim,
     MEDIA_STATUS       => media_status_i,
     MEDIA_CONTROL      => open,
     MED_DATAREADY_IN   => med_dataready_in_i,
     MED_DATA_IN        => med_data_in_i,
     MED_READ_OUT       => med_read_out_i,
     MED_DATA_OUT       => med_data_out_i,
     MED_DATAREADY_OUT  => med_dataready_out_i,
     MED_READ_IN        => med_read_in_i,
     MED_PACKET_NUM_IN  => med_packet_num_in_i,
     MED_PACKET_NUM_OUT => med_packet_num_out_i,
     MED_STAT_OP        => med_stat_op_i,
     MED_CTRL_OP        => med_ctrl_op_i,
     LINK_DEBUG         => link_debug_i 
     );
 
  ADO_TTL(15 downto 0) <= link_debug_i(7 downto 4) & med_dataready_out_i(0) & med_packet_num_out_i(2 downto 0) & med_data_out_i(7 downto 0);--link_debug_i(15 downto 0);
  ADO_TTL(34 downto 19) <= link_debug_i(23 downto 22) & LVDS_CLK_200P & med_read_out_i(0) & med_dataready_in_i(0) & med_packet_num_in_i(2 downto 0) & med_data_in_i(7 downto 0);--link_debug_i(31 downto 16);

 
 SIMPLE_HUB_GEN    : if trb_net_enable = 0 and OPT_TEST_MODE = 0 generate
   
   SIMPLE_HUB_INST : simple_hub
     generic map (
       HOW_MANY_CHANNELS => HOW_MANY_CHANNELS)
     port map (
       CLK               => LVDS_CLK_200P,
       RESET             => global_reset_i,
       DATA_IN           => med_data_out_i,
--       DATA_IN           => med_data_out_i_test,
       DATA_OUT          => med_data_in_i,
       DATA_IN_VALID     => med_dataready_out_i,
       SEND_DATA         => med_dataready_in_i,
--       SEND_DATA         => med_dataready_in_i_test,
       ENABLE_CHANNELS   => fpga_register_06_i(15 downto 0),
       READ_DATA         => med_read_in_i,
       HUB_DEBUG         => hub_debug_i
       );

 end generate SIMPLE_HUB_GEN;
 
 FREE_COUNTER_INST: up_down_counter
   generic map (
       NUMBER_OF_BITS => 17)
   port map (
       CLK       => LVDS_CLK_200P,      
       RESET     => '0',
       COUNT_OUT => free_counter,
       UP_IN     => '1',
       DOWN_IN   => '0');
 
 WAIT_COUNTER_INST: up_down_counter
   generic map (
       NUMBER_OF_BITS => 32)
   port map (
       CLK       => LVDS_CLK_200P,
       RESET     => '0',
       COUNT_OUT => wait_counter,
       UP_IN     => wait_counter_up,
       DOWN_IN   => '0');

 wait_counter_up <= '1' when wait_counter(31) = '0' else '0';
 
 ENABLE_OPT_TEST : if OPT_TEST_MODE = 1 generate
   
   SEND_COUNTER: process (LVDS_CLK_200P, global_reset_i)
   begin  
     if rising_edge(LVDS_CLK_200P) then
       if global_reset_i = '1' then         
         med_dataready_in_i <=  (others => '0');
         med_data_in_i <= (others => '0');
--       elsif med_stat_op_i(9)='1' or med_stat_op_i(24)='1' or med_stat_op_i(40)='1' or med_stat_op_i(56)='1' then
    --   elsif link_debug_i(3 downto 0) = x"a"  and link_debug_i(35 downto 32) > 10 then
       elsif wait_counter(31) = '1' then
         
         med_dataready_in_i <=  free_counter(16) & free_counter(16) &free_counter(16) &free_counter(16);
         med_data_in_i <= free_counter(15 downto 0) & free_counter(15 downto 0) & free_counter(15 downto 0) & free_counter(15 downto 0);
         else
           med_dataready_in_i <=  (others => '0');
           med_data_in_i <= (others => '0');
     end if;
   end if;
 end process SEND_COUNTER;
 med_read_in_i <= (others => '1');
--    med_data_in_i <= med_data_out_i;
--    med_dataready_in_i <= med_dataready_out_i;
  end generate ENABLE_OPT_TEST;

 ENABLE_TRB_NET: if trb_net_enable = 1 generate
   
   HUB_API: trb_net16_hub_base
     generic map(
       MII_NUMBER => HOW_MANY_CHANNELS
       )
     port map (
       CLK                      => LVDS_CLK_200P,
       RESET                    => global_reset_i,
       CLK_EN                   => '1',
       MED_DATAREADY_OUT        => med_dataready_in_i,
       MED_DATA_OUT             => med_data_in_i,
       MED_PACKET_NUM_OUT       => med_packet_num_in_i,
       MED_READ_IN              => med_read_out_i,
       MED_DATAREADY_IN         => med_dataready_out_i,
       MED_DATA_IN              => med_data_out_i,
       MED_PACKET_NUM_IN        => med_packet_num_out_i,
       MED_READ_OUT             => med_read_in_i,
       MED_STAT_OP              => med_stat_op_i,
       MED_CTRL_OP              => med_ctrl_op_i,
       INT_INIT_DATAREADY_OUT   => open,
       INT_INIT_DATA_OUT        => open,
       INT_INIT_PACKET_NUM_OUT  => open,
       INT_INIT_READ_IN         => (others => '1'),
       INT_INIT_DATAREADY_IN    => (others => '0'),
       INT_INIT_DATA_IN         => (others => '0'),
       INT_INIT_PACKET_NUM_IN   => (others => '0'),
       INT_INIT_READ_OUT        => open,
       INT_REPLY_DATAREADY_OUT  => open,
       INT_REPLY_DATA_OUT       => open,
       INT_REPLY_PACKET_NUM_OUT => open,
       INT_REPLY_READ_IN        => (others => '1'),
       INT_REPLY_DATAREADY_IN   => (others => '0'),
       INT_REPLY_DATA_IN        => (others => '0'),
       INT_REPLY_PACKET_NUM_IN  => (others => '0'),
       INT_REPLY_READ_OUT       => open,
       ONEWIRE                  => FS_PE_11,
       HUB_STAT_CHANNEL         => hub_stat_channel_i,
       HUB_STAT_GEN             => hub_stat_gen_i,
       MPLEX_CTRL               => mplex_ctrl_i,
       MPLEX_STAT               => open,
       REGIO_EXT_REG_DATA_IN    => (others => '0'),
       REGIO_EXT_REG_DATA_OUT   => open,
       REGIO_EXT_REG_WRITE_IN   => '0',
       REGIO_EXT_REG_ADDR_IN    => (others => '0'),
       STAT_DEBUG               => open,
       CTRL_DEBUG               => (others => '0')
       );
   
 end generate ENABLE_TRB_NET;

   ETRAX_RW_DATA_INTERFACE : etrax_interfacev2
     generic map (
       RW_SYSTEM => 2)
     port map (
       CLK                    => LVDS_CLK_200P,
       RESET                  => global_reset_i,
       DATA_BUS               => (others => '0'),
       ETRAX_DATA_BUS_B       => open,--(others => '0'),
       ETRAX_DATA_BUS_B_17    => '0',
       ETRAX_DATA_BUS_C       => open,--(others => '0'),
       ETRAX_DATA_BUS_E       => FS_PE(9 downto 8),
       DATA_VALID             => '0',
       ETRAX_BUS_BUSY         => '0',
       ETRAX_IS_READY_TO_READ => open,
       TDC_TCK                => open,
       TDC_TDI                => open,
       TDC_TMS                => open,
       TDC_TRST               => open,
       TDC_TDO                => '0',
       TDC_RESET              => open,
       EXTERNAL_ADDRESS       => open,
       EXTERNAL_DATA_OUT      => open,
       EXTERNAL_DATA_IN       => x"ddbbccaa",--external_data_in_i,
       EXTERNAL_ACK           => external_ack_i,
       EXTERNAL_VALID         => '0',--external_valid_i,
       EXTERNAL_MODE          => external_mode_i,
       FPGA_REGISTER_00       => fpga_register_00_i,
       FPGA_REGISTER_01       => fpga_register_01_i,
       FPGA_REGISTER_02       => fpga_register_02_i,
       FPGA_REGISTER_03       => fpga_register_03_i,
       FPGA_REGISTER_04       => fpga_register_04_i,
       FPGA_REGISTER_05       => fpga_register_05_i,
       FPGA_REGISTER_06       => fpga_register_06_i,
       FPGA_REGISTER_07       => fpga_register_07_i,
       FPGA_REGISTER_08       => fpga_register_08_i,
       FPGA_REGISTER_09       => fpga_register_09_i,
       FPGA_REGISTER_0A       => fpga_register_0A_i,
       FPGA_REGISTER_0B       => fpga_register_0B_i,
       FPGA_REGISTER_0C       => fpga_register_0C_i,
       FPGA_REGISTER_0D       => fpga_register_0D_i,
       FPGA_REGISTER_0E       => fpga_register_0E_i,
 --      EXTERNAL_RESET         => open,
       LVL2_VALID             => '0');
  fpga_register_00_i <= x"0000"& lok_i;
  fpga_register_01_i <= hub_debug_i;
  fpga_register_02_i <= link_debug_i(31 downto 0);
  fpga_register_03_i <= link_debug_i(63 downto 32);
  fpga_register_04_i <= rxd_i(31 downto 0);
  fpga_register_0A_i <= rxd_i(63 downto 32);
--   fpga_register_02_i <= link_debug_i(95 downto 64);
--   fpga_register_03_i <= link_debug_i(127 downto 96);
--   fpga_register_04_i <= rxd_i(95 downto 64);
--   fpga_register_0A_i <= rxd_i(127 downto 96);
  fpga_register_0B_i <= conv_std_logic_vector(VERSION_NUMBER_TIME,32);
  fpga_register_0C_i <= link_debug_i(95 downto 64); 
  fpga_register_0D_i <= link_debug_i(127 downto 96);
-- --  fpga_register_08_i <= rxd_i(63 downto 32);
--   fpga_register_0a_i(15 downto 0) <= cv_i(7 downto 0) & rx_k_i(3 downto 0) & "0000";



 COUNT_LVL1_START: process (LVDS_CLK_200P, global_reset_i )
 begin  
   if rising_edge(LVDS_CLK_200P) then
     if global_reset_i = '1' then         
       fpga_register_05_i <= (others => '0');
     elsif med_dataready_out_i(0) = '1' and med_data_out_i(15 downto 12) = x"1" then
       fpga_register_05_i <= fpga_register_05_i + 1;
     end if;
   end if;
 end process COUNT_LVL1_START;

--    COUNT_LVL1_SEND: process (LVDS_CLK_200P, global_reset_i )
--   begin  
--     if rising_edge(LVDS_CLK_200P) then
--       if global_reset_i = '1' then         
--         fpga_register_08_i <= (others => '0');
--       elsif med_data_ready_in_i(1) = '1' and med_data_in_i(31 downto 28) = x"1" then
--         fpga_register_08_i <= fpga_register_08_i + 1;
--       end if;
--     end if;
--   end process COUNT_LVL1_SEND;

  COUNT_LVL1_SEND_a: process (LVDS_CLK_200P, global_reset_i )
  begin  
    if rising_edge(LVDS_CLK_200P) then
      if global_reset_i = '1' then         
        fpga_register_09_i <= (others => '0');
      elsif med_dataready_in_i(1) = '1' then
        fpga_register_09_i <= fpga_register_08_i + 1;
      end if;
    end if;
  end process COUNT_LVL1_SEND_a;

  COUNT_LVL1_END: process (LVDS_CLK_200P, global_reset_i )
  begin  
    if rising_edge(LVDS_CLK_200P) then
      if global_reset_i = '1' then         
        fpga_register_07_i <= (others => '0');
      elsif med_dataready_out_i(1) = '1' and med_data_out_i(31 downto 28) = x"1" then
        fpga_register_07_i <= fpga_register_07_i + 1;
      end if;
    end if;
  end process COUNT_LVL1_END;

  TX_DIS_g  : for synch_fsm_state in 0 to HOW_MANY_CHANNELS-1 generate
  begin
    TX_DIS(synch_fsm_state+1)   <= '0';
  end generate;

  TX_DIS_g1 : for not_connected in 0 to 16-HOW_MANY_CHANNELS-1 generate
  begin
    WHEN_NOT_ALL_EN   : if HOW_MANY_CHANNELS < 16 generate
      TX_DIS(16-not_connected) <= '1';
    end generate WHEN_NOT_ALL_EN;
  end generate;

---------------------------------------------------------------------------
-- setting LED
---------------------------------------------------------------------------
  
  --correct this for channels 11-8 - mirrored due to schematics  -- also
  --adressing of sfps !!!
  SYNCH_EXT_SIGNAL: process (LVDS_CLK_200P)
  begin  
    if rising_edge(LVDS_CLK_200P) then 
      if global_reset_i = '1' then
        sfp_los_synch <= (others => '0');
      else
        sfp_los_synch <= SFP_LOS;
      end if;
    end if;
  end process SYNCH_EXT_SIGNAL;
  LOK_STATUS_DIOD_EN  : for synch_fsm_state in 0 to HOW_MANY_CHANNELS-1 generate
  begin
 --   lok_i(synch_fsm_state+1)      <= not link_debug_i(2+synch_fsm_state*31);
    lok_i(synch_fsm_state+1)      <= med_stat_op_i(9 + synch_fsm_state*16);
    media_status_i(synch_fsm_state*16) <= SFP_LOS(synch_fsm_state+1);
  end generate LOK_STATUS_DIOD_EN;
  
--    LOK_STATUS_REGISTER_0  : for synch_fsm_state in 0 to (HOW_MANY_CHANNELS-1 mod 8) generate
--    begin
--      hub_register_00_i(synch_fsm_state) <= link_debug_i(2+synch_fsm_state*31);
--    end generate LOK_STATUS_REGISTER_0;
 
--    LOK_STATUS_REGISTER_1  : for synch_fsm_state in 0 to (HOW_MANY_CHANNELS-1 - 8) generate
--    begin
--      hub_register_01_i(synch_fsm_state) <= link_debug_i(2+synch_fsm_state*31+8*16);
--    end generate LOK_STATUS_REGISTER_1;

  LOK_STATUS_DIOD_DIS : for not_connected in 0 to 16-HOW_MANY_CHANNELS-1 generate
  begin
    WHEN_NOT_ALL_EN   : if HOW_MANY_CHANNELS < 16 generate
      lok_i(16-not_connected)    <= '1';
    end generate WHEN_NOT_ALL_EN;
  end generate LOK_STATUS_DIOD_DIS;
  
  LOK                         <= lok_i;
  IPLL                        <= '0';
  OPLL                        <= '0';
  DBAD                        <= '1';
  DGOOD                       <= '1';
  DINT                        <= '0';
  DWAIT                       <= global_reset_i;

  CV_COUNTERaaa: process (LVDS_CLK_200P, global_reset_i)
  begin 
    if rising_edge(LVDS_CLK_200P) then  -- rising clock edge
      if global_reset_i = '1' then            -- asynchronous reset (active low)
        cv_counter <= (others =>  '0');
      else
        cv_counter <= cv_counter + 1;
      end if;
    end if;
  end process CV_COUNTERaaa;
  CV_COUNTERaab: process (ref_pclk(0), global_reset_i)
  begin 
    if rising_edge(ref_pclk(0)) then  -- rising clock edge
      if global_reset_i = '1' then            -- asynchronous reset (active low)
        cv_countera <= (others =>  '0');
      else
        cv_countera <= cv_countera + 1;
      end if;
    end if;
  end process CV_COUNTERaab;
--   RT(8) <= cv_counter(23);
--   RT(9) <= med_read_in_i(0);
--   RT(16 downto 10) <= link_debug_i(7 downto 1);
--   RT(2) <= flexi_pcs_ref_clk;--cv_counter(0);
--   RT(1) <= not switch_rx_clk;--ref_pclk(0);
  
--   RT(3) <= LVDS_CLK_200P;

--   RT(4) <= rx_k_i(0);

--     RT(5) <= med_dataready_out_i(0);--serdes_ref_clk;
--     RT(6) <= med_data_out_i(0);--serdes_ref_clks;
--     RT(7) <= med_data_out_i(1);--serdes_ref_lock;
 RT <= (others => '1');
end hub;

