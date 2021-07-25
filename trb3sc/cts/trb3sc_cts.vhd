library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.version.all;
use work.config.all;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb3_components.all;
use work.trb_net16_hub_func.all;
use work.version.all;
use work.trb_net_gbe_components.all;
use work.med_sync_define.all;
use work.cts_pkg.all;

entity trb3sc_cts is
  port(
    CLK_SUPPL_PCLK       : in    std_logic; --125 MHz for GbE
    CLK_CORE_PCLK        : in    std_logic; --Main Oscillator
    CLK_EXT_PLL_LEFT     : in    std_logic; --External Clock

    --Additional IO
    HDR_IO               : inout std_logic_vector(10 downto 1);
    BACK_LVDS            : inout std_logic_vector( 1 downto 0);
    BACK_GPIO            : inout std_logic_vector( 3 downto 0);
    
    SPARE_IN             : in    std_logic_vector( 1 downto 0);
    INP                  : in    std_logic_vector(95 downto 64); 
    RJ_IO                : out   std_logic_vector( 3 downto  0); --0, inner RJ trigger output
    
    --LED
    LED_GREEN            : out   std_logic;
    LED_YELLOW           : out   std_logic;
    LED_ORANGE           : out   std_logic;
    LED_RED              : out   std_logic;
    LED_RJ_GREEN         : out   std_logic_vector( 1 downto 0);
    LED_RJ_RED           : out   std_logic_vector( 1 downto 0);
    LED_WHITE            : out   std_logic_vector( 1 downto 0);
    LED_SFP_GREEN        : out   std_logic_vector( 1 downto 0);
    LED_SFP_RED          : out   std_logic_vector( 1 downto 0);
    
    --SFP
    SFP_LOS              : in    std_logic_vector( 1 downto 0);
    SFP_MOD0             : in    std_logic_vector( 1 downto 0);  
    SFP_MOD1             : inout std_logic_vector( 1 downto 0) := (others => 'Z');
    SFP_MOD2             : inout std_logic_vector( 1 downto 0) := (others => 'Z');
    SFP_TX_DIS           : out   std_logic_vector( 1 downto 0) := (others => '0');  

    LED_HUB_LINKOK       : out   std_logic_vector(8 downto 1);
    LED_HUB_RX           : out   std_logic_vector(8 downto 1);
    LED_HUB_TX           : out   std_logic_vector(8 downto 1);
    HUB_MOD0             : in    std_logic_vector(8 downto 1);
    HUB_MOD1             : inout std_logic_vector(8 downto 1);
    HUB_MOD2             : inout std_logic_vector(8 downto 1);
    HUB_TXDIS            : out   std_logic_vector(8 downto 1);
    HUB_LOS              : in    std_logic_vector(8 downto 1);
    
    --Serdes switch
    PCSSW_ENSMB          : out   std_logic;
    PCSSW_EQ             : out   std_logic_vector( 3 downto 0);
    PCSSW_PE             : out   std_logic_vector( 3 downto 0);
    PCSSW                : out   std_logic_vector( 7 downto 0);
   
    --ADC
    ADC_CLK              : out   std_logic;
    ADC_CS               : out   std_logic;
    ADC_DIN              : out   std_logic;
    ADC_DOUT             : in    std_logic;

    --SPI
    DAC_OUT_SDO      : out std_logic_vector(6 downto 5);
    DAC_OUT_SCK      : out std_logic_vector(6 downto 5);
    DAC_OUT_CS       : out std_logic_vector(6 downto 5);
    DAC_IN_SDI       : in  std_logic_vector(6 downto 5);

    
    --Flash, 1-wire, Reload
    FLASH_CLK            : out   std_logic;
    FLASH_CS             : out   std_logic;
    FLASH_IN             : out   std_logic;
    FLASH_OUT            : in    std_logic;
    PROGRAMN             : out   std_logic;
    ENPIRION_CLOCK       : out   std_logic;
    TEMPSENS             : inout std_logic;
    
    --Test Connectors
    TEST_LINE            : out std_logic_vector(15 downto 0)
    );


  attribute syn_useioff                  : boolean;
  attribute syn_useioff of FLASH_CLK  : signal is true;
  attribute syn_useioff of FLASH_CS   : signal is true;
  attribute syn_useioff of FLASH_IN   : signal is true;
  attribute syn_useioff of FLASH_OUT  : signal is true;

  attribute syn_useioff of SPARE_IN  : signal is false;
  attribute syn_useioff of INP       : signal is false;
  
end entity;

architecture trb3sc_arch of trb3sc_cts is
  attribute syn_keep     : boolean;
  attribute syn_preserve : boolean;
  
--   constant CTS_ADDON_LINE_COUNT      : integer := 18;
--   constant CTS_OUTPUT_MULTIPLEXERS   : integer :=  1;
--   constant CTS_OUTPUT_INPUTS         : integer := 16;

  
  
  signal clk_sys, clk_full, clk_full_osc, clk_cal   : std_logic;
  signal GSR_N       : std_logic;
  signal reset_i     : std_logic;
  signal clear_i     : std_logic;
  signal do_reboot_i, reboot_from_gbe : std_logic;
  
  signal time_counter      : unsigned(31 downto 0) := (others => '0');
  signal led               : std_logic_vector(1 downto 0);
  signal debug_clock_reset : std_logic_vector(31 downto 0);

  --Media Interface
  signal med2int           : med2int_array_t(0 to INTERFACE_NUM-1);
  signal int2med           : int2med_array_t(0 to INTERFACE_NUM-1);
  
  signal ctrlbus_rx, bussci1_rx, bussci2_rx, bussci3_rx, bustools_rx, buscts_rx,
         bustc_rx, busgbeip_rx, busgbereg_rx, bus_master_out, handlerbus_rx, bustdc_rx  : CTRLBUS_RX;
  signal ctrlbus_tx, bussci1_tx, bussci2_tx, bussci3_tx, bustools_tx, buscts_tx,
         bustc_tx, busgbeip_tx, busgbereg_tx, bus_master_in, bustdc_tx : CTRLBUS_TX;
  
  signal sed_error_i    : std_logic;
  signal bus_master_active : std_logic;
  
  signal spi_cs, spi_mosi, spi_miso, spi_clk : std_logic_vector(15 downto 0);
  signal uart_tx, uart_rx : std_logic;

  signal common_ctrl_reg        : std_logic_vector (std_COMCTRLREG*32-1 downto 0);

  signal timer : TIMERS;
  signal reset_via_gbe : std_logic := '0';

  signal med_dataready_out    : std_logic_vector (5-1 downto 0);
  signal med_data_out         : std_logic_vector (5*c_DATA_WIDTH-1 downto 0);
  signal med_packet_num_out   : std_logic_vector (5*c_NUM_WIDTH-1 downto 0);
  signal med_read_in          : std_logic_vector (5-1 downto 0);
  signal med_dataready_in     : std_logic_vector (5-1 downto 0);
  signal med_data_in          : std_logic_vector (5*c_DATA_WIDTH-1 downto 0);
  signal med_packet_num_in    : std_logic_vector (5*c_NUM_WIDTH-1 downto 0);
  signal med_read_out         : std_logic_vector (5-1 downto 0);
  signal med_stat_op          : std_logic_vector (5*16-1 downto 0);
  signal med_ctrl_op          : std_logic_vector (5*16-1 downto 0);
  signal rdack, wrack         : std_logic;
  
  signal monitor_inputs_i : std_logic_vector(MONITOR_INPUT_NUM-1 downto 0);
  signal trigger_busy_i              : std_logic;
  signal cts_trigger_out             : std_logic;
  
  signal gbe_cts_number                   : std_logic_vector(15 downto 0);
  signal gbe_cts_code                     : std_logic_vector(7 downto 0);
  signal gbe_cts_information              : std_logic_vector(7 downto 0);
  signal gbe_cts_start_readout            : std_logic;
  signal gbe_cts_readout_type             : std_logic_vector(3 downto 0);
  signal gbe_cts_readout_finished         : std_logic;
  signal gbe_cts_status_bits              : std_logic_vector(31 downto 0);
  signal gbe_fee_data                     : std_logic_vector(15 downto 0);
  signal gbe_fee_dataready                : std_logic;
  signal gbe_fee_read                     : std_logic;
  signal gbe_fee_status_bits              : std_logic_vector(31 downto 0);
  signal gbe_fee_busy                     : std_logic;  

  signal gsc_init_data, gsc_reply_data : std_logic_vector(15 downto 0);
  signal gsc_init_read, gsc_reply_read : std_logic;
  signal gsc_init_dataready, gsc_reply_dataready : std_logic;
  signal gsc_init_packet_num, gsc_reply_packet_num : std_logic_vector(2 downto 0);
  signal gsc_busy : std_logic;

  signal cts_rdo_trg_status_bits_cts : std_logic_vector(31 downto 0) := (others => '0');
  signal cts_rdo_data                : std_logic_vector(31 downto 0);
  signal cts_rdo_write               : std_logic;
  signal cts_rdo_finished            : std_logic;

  signal cts_ext_trigger             : std_logic;
  signal cts_ext_status              : std_logic_vector(31 downto 0) := (others => '0');
  signal cts_ext_control             : std_logic_vector(31 downto 0);
  signal cts_ext_debug               : std_logic_vector(31 downto 0);
  signal cts_ext_header              : std_logic_vector(1 downto 0);

  signal cts_rdo_additional_data            : std_logic_vector(32*cts_rdo_additional_ports-1 downto 0);
  signal cts_rdo_additional_write           : std_logic_vector(cts_rdo_additional_ports-1 downto 0) := (others => '0');
  signal cts_rdo_additional_finished        : std_logic_vector(cts_rdo_additional_ports-1 downto 0) := (others => '1');
  signal cts_rdo_trg_status_bits_additional : std_logic_vector(32*cts_rdo_additional_ports-1 downto 0) := (others => '0');
  
  signal cts_rdo_additional : readout_tx_array_t(0 to cts_rdo_additional_ports-1);
  signal cts_rdo_rx : READOUT_RX;

  signal cts_addon_triggers_in       : std_logic_vector(ADDON_LINE_COUNT-1 downto 0);
--   signal cts_addon_activity_i,
--         cts_addon_selected_i        : std_logic_vector(6 downto 0);
        
--   signal cts_periph_trigger_i        : std_logic_vector(19 downto 0);
--   signal cts_output_multiplexers_i   : std_logic_vector(CTS_OUTPUT_MULTIPLEXERS - 1 downto 0);

--   signal cts_periph_lines_i   : std_logic_vector(CTS_OUTPUT_INPUTS - 1 downto 0);

  signal cts_trg_send                : std_logic;
  signal cts_trg_type                : std_logic_vector(3 downto 0);
  signal cts_trg_number              : std_logic_vector(15 downto 0);
  signal cts_trg_information         : std_logic_vector(23 downto 0);
  signal cts_trg_code                : std_logic_vector(7 downto 0);
  signal cts_trg_status_bits         : std_logic_vector(31 downto 0);
  signal cts_trg_busy                : std_logic;

  signal cts_ipu_send                : std_logic;
  signal cts_ipu_type                : std_logic_vector(3 downto 0);
  signal cts_ipu_number              : std_logic_vector(15 downto 0);
  signal cts_ipu_information         : std_logic_vector(7 downto 0);
  signal cts_ipu_code                : std_logic_vector(7 downto 0);
  signal cts_ipu_status_bits         : std_logic_vector(31 downto 0);
  signal cts_ipu_busy                : std_logic;
  
  signal reset_via_gbe_long, reset_via_gbe_timer, last_reset_via_gbe_long, make_reset : std_logic;
  
  signal hit_in_i         : std_logic_vector(64 downto 1);
  
  attribute syn_keep of GSR_N     : signal is true;
  attribute syn_preserve of GSR_N : signal is true;  
  attribute syn_keep of bussci1_rx     : signal is true;
  attribute syn_preserve of bussci1_rx : signal is true;  
  attribute syn_keep of bustools_rx     : signal is true;
  attribute syn_preserve of bustools_rx : signal is true;    
  attribute syn_keep of bustc_rx     : signal is true;
  attribute syn_preserve of bustc_rx : signal is true;   
  
begin


---------------------------------------------------------------------------
-- Clock & Reset Handling
---------------------------------------------------------------------------
THE_CLOCK_RESET :  entity work.clock_reset_handler
  port map(
    INT_CLK_IN      => CLK_CORE_PCLK,
    EXT_CLK_IN      => CLK_EXT_PLL_LEFT,
    NET_CLK_FULL_IN => '0',
    NET_CLK_HALF_IN => '0',
    RESET_FROM_NET  => make_reset,
    
    BUS_RX          => bustc_rx,
    BUS_TX          => bustc_tx,

    RESET_OUT       => reset_i,
    CLEAR_OUT       => clear_i,
    GSR_OUT         => GSR_N,
    
    FULL_CLK_OUT    => clk_full,
    SYS_CLK_OUT     => clk_sys,
    REF_CLK_OUT     => clk_full_osc,
    
    ENPIRION_CLOCK  => ENPIRION_CLOCK,    
    LED_RED_OUT     => LED_RJ_RED,
    LED_GREEN_OUT   => LED_RJ_GREEN,
    DEBUG_OUT       => debug_clock_reset
    );


  make_reset : process begin
    wait until rising_edge(clk_sys);
    if(reset_via_gbe = '1') then
      reset_via_gbe_long <= '1';
      reset_via_gbe_timer <= '1';
    end if;
    if timer.tick_us = '1' then
      reset_via_gbe_timer <= '0';
      reset_via_gbe_long  <= reset_via_gbe_timer;
    end if;
    last_reset_via_gbe_long <= reset_via_gbe_long;
    make_reset <= last_reset_via_gbe_long and not reset_via_gbe_long;
  end process;      

  pll_calibration : entity work.pll_in125_out33
    port map (
      CLK   => CLK_SUPPL_PCLK,
      CLKOP => clk_cal,
      LOCK  => open);

---------------------------------------------------------------------------
-- PCSA
---------------------------------------------------------------------------    
bussci1_tx.data <= (others => '0');
bussci1_tx.ack  <= '0';
bussci1_tx.nack <= '0';
bussci1_tx.unknown <= '1';


---------------------------------------------------------------------------
-- PCSB   Downlink without backplane is SFP
---------------------------------------------------------------------------   
gen_PCSB : if USE_BACKPLANE = c_NO generate
  THE_MEDIA_PCSB : entity work.med_ecp3_sfp_sync
    generic map(
      SERDES_NUM    => 3,
      IS_SYNC_SLAVE => c_NO
      )
    port map(
      CLK_REF_FULL       => clk_full_osc,
      CLK_INTERNAL_FULL  => clk_full_osc,
      SYSCLK        => clk_sys,
      RESET         => reset_i,
      CLEAR         => clear_i,
      --Internal Connection
      MEDIA_MED2INT => med2int(0),
      MEDIA_INT2MED => int2med(0),

      --Sync operation
      RX_DLM      => open,
      RX_DLM_WORD => open,
      TX_DLM      => open,
      TX_DLM_WORD => open,

      --SFP Connection
      SD_PRSNT_N_IN  => SFP_MOD0(1),
      SD_LOS_IN      => SFP_LOS(1),
      SD_TXDIS_OUT   => SFP_TX_DIS(1),
      --Control Interface
      BUS_RX         => bussci2_rx,
      BUS_TX         => bussci2_tx,
      -- Status and control port
      STAT_DEBUG     => open,
      CTRL_DEBUG     => open
      );    
end generate;

---------------------------------------------------------------------------
-- PCSC   4 downlinks
---------------------------------------------------------------------------    
-- bussci3_tx.data <= (others => '0');
-- bussci3_tx.ack  <= '0';
-- bussci3_tx.nack <= '0';
-- bussci3_tx.unknown <= '1';
gen_PCSC : if USE_BACKPLANE = c_NO and USE_ADDON = c_YES generate
  THE_MEDIA_PCSC : entity work.med_ecp3_sfp_sync_4
    generic map(
      IS_SYNC_SLAVE   => (c_NO, c_NO, c_NO, c_NO),
      IS_USED         => (c_YES,c_YES ,c_YES ,c_YES)
      )
    port map(
      CLK_REF_FULL       => clk_full_osc,
      CLK_INTERNAL_FULL  => clk_full_osc,
      SYSCLK             => clk_sys,
      RESET              => reset_i,
      CLEAR              => clear_i,
      
      --Internal Connection
      MEDIA_MED2INT(0) => med2int(3),
      MEDIA_MED2INT(1) => med2int(4),
      MEDIA_MED2INT(2) => med2int(1),
      MEDIA_MED2INT(3) => med2int(2),
      MEDIA_INT2MED(0) => int2med(3),
      MEDIA_INT2MED(1) => int2med(4),
      MEDIA_INT2MED(2) => int2med(1),
      MEDIA_INT2MED(3) => int2med(2),

      --Sync operation
      RX_DLM             => open,
      RX_DLM_WORD        => open,
      TX_DLM             => open,
      TX_DLM_WORD        => open,
      
      --SFP Connection
      SD_PRSNT_N_IN(0)   => HUB_MOD0(3),
      SD_PRSNT_N_IN(1)   => HUB_MOD0(4),
      SD_PRSNT_N_IN(2)   => HUB_MOD0(1),
      SD_PRSNT_N_IN(3)   => HUB_MOD0(2),

      SD_LOS_IN(0)   => HUB_LOS(3),
      SD_LOS_IN(1)   => HUB_LOS(4),
      SD_LOS_IN(2)   => HUB_LOS(1),
      SD_LOS_IN(3)   => HUB_LOS(2),

      SD_TXDIS_OUT(0)   => HUB_TXDIS(3),
      SD_TXDIS_OUT(1)   => HUB_TXDIS(4),
      SD_TXDIS_OUT(2)   => HUB_TXDIS(1),
      SD_TXDIS_OUT(3)   => HUB_TXDIS(2),
      
      --Control Interface
      BUS_RX             => bussci3_rx,
      BUS_TX             => bussci3_tx,

      -- Status and control port
      STAT_DEBUG         => open, --med_stat_debug(63 downto 0),
      CTRL_DEBUG         => open
    );      
end generate;


---------------------------------------------------------------------------
-- GbE (PCSD)
---------------------------------------------------------------------------
  GBE : entity work.gbe_wrapper
    generic map(
      DO_SIMULATION             => 0,
      INCLUDE_DEBUG             => 0,
      USE_INTERNAL_TRBNET_DUMMY => 0,
      USE_EXTERNAL_TRBNET_DUMMY => 0,
      RX_PATH_ENABLE            => 1,
      FIXED_SIZE_MODE           => 1,
      INCREMENTAL_MODE          => 1,
      FIXED_SIZE                => 100,
      FIXED_DELAY_MODE          => 1,
      UP_DOWN_MODE              => 0,
      UP_DOWN_LIMIT             => 100,
      FIXED_DELAY               => 100,

      NUMBER_OF_GBE_LINKS       => 4,
      LINKS_ACTIVE              => "0001",

      LINK_HAS_READOUT  => "0001",
      LINK_HAS_SLOWCTRL => "0001",
      LINK_HAS_DHCP     => "0001",
      LINK_HAS_ARP      => "0001",
      LINK_HAS_PING     => "0001",
      LINK_HAS_FWD      => "0000"
      )
              
    port map(
      CLK_SYS_IN               => clk_sys,
      CLK_125_IN               => CLK_SUPPL_PCLK,
      RESET                    => reset_i,
      GSR_N                    => GSR_N,

      TRIGGER_IN               => cts_rdo_rx.data_valid,
      
      SD_PRSNT_N_IN(0)         => SFP_MOD0(0),
      SD_LOS_IN(0)             => SFP_LOS(0),
      SD_TXDIS_OUT(0)          => SFP_TX_DIS(0),
      CTS_NUMBER_IN            => gbe_cts_number,          
      CTS_CODE_IN              => gbe_cts_code,            
      CTS_INFORMATION_IN       => gbe_cts_information,     
      CTS_READOUT_TYPE_IN      => gbe_cts_readout_type,    
      CTS_START_READOUT_IN     => gbe_cts_start_readout,   
      CTS_DATA_OUT             => open,                    
      CTS_DATAREADY_OUT        => open,                    
      CTS_READOUT_FINISHED_OUT => gbe_cts_readout_finished,
      CTS_READ_IN              => '1',                     
      CTS_LENGTH_OUT           => open,                    
      CTS_ERROR_PATTERN_OUT    => gbe_cts_status_bits,     
      
      FEE_DATA_IN              => gbe_fee_data,       
      FEE_DATAREADY_IN         => gbe_fee_dataready,  
      FEE_READ_OUT             => gbe_fee_read,       
      FEE_STATUS_BITS_IN       => gbe_fee_status_bits,
      FEE_BUSY_IN              => gbe_fee_busy,       
      
      MC_UNIQUE_ID_IN          => timer.uid,
      MY_TRBNET_ADDRESS_IN     => timer.network_address,
      ISSUE_REBOOT_OUT => reboot_from_gbe,
      
      GSC_CLK_IN               => clk_sys,            
      GSC_INIT_DATAREADY_OUT   => gsc_init_dataready,   
      GSC_INIT_DATA_OUT        => gsc_init_data,        
      GSC_INIT_PACKET_NUM_OUT  => gsc_init_packet_num,  
      GSC_INIT_READ_IN         => gsc_init_read,        
      GSC_REPLY_DATAREADY_IN   => gsc_reply_dataready,  
      GSC_REPLY_DATA_IN        => gsc_reply_data,       
      GSC_REPLY_PACKET_NUM_IN  => gsc_reply_packet_num, 
      GSC_REPLY_READ_OUT       => gsc_reply_read,       
      GSC_BUSY_IN              => gsc_busy,            
      
      BUS_IP_RX  => busgbeip_rx,
      BUS_IP_TX  => busgbeip_tx,
      BUS_REG_RX => busgbereg_rx,
      BUS_REG_TX => busgbereg_tx,
      
      MAKE_RESET_OUT           => reset_via_gbe,

      DEBUG_OUT                => open
      );


---------------------------------------------------------------------------
-- Hub
---------------------------------------------------------------------------
  THE_HUB : trb_net16_hub_streaming_port_sctrl_cts
    generic map(
      INIT_ADDRESS                  => x"F3C0",
      MII_NUMBER                    => INTERFACE_NUM,
      MII_IS_UPLINK                 => IS_UPLINK,
      MII_IS_DOWNLINK               => IS_DOWNLINK,
      MII_IS_UPLINK_ONLY            => IS_UPLINK_ONLY,
      HARDWARE_VERSION              => HARDWARE_INFO,
      INCLUDED_FEATURES             => INCLUDED_FEATURES,
      INIT_ENDPOINT_ID              => x"0001",
      BROADCAST_BITMASK             => x"7E",
      CLOCK_FREQUENCY               => 100,
      USE_ONEWIRE                   => c_YES,
      BROADCAST_SPECIAL_ADDR        => x"35",
      RDO_ADDITIONAL_PORT           => cts_rdo_additional_ports,
      RDO_DATA_BUFFER_DEPTH         => EVENT_BUFFER_SIZE,
      RDO_DATA_BUFFER_FULL_THRESH   => 2**EVENT_BUFFER_SIZE-EVENT_MAX_SIZE,
      RDO_HEADER_BUFFER_DEPTH       => 9,
      RDO_HEADER_BUFFER_FULL_THRESH => 2**9-16
      )
    port map (
      CLK    => clk_sys,
      RESET  => reset_i,
      CLK_EN => '1',

      -- Media interfacces ---------------------------------------------------------------
      MED_DATAREADY_OUT(INTERFACE_NUM*1-1 downto 0)  => med_dataready_out(INTERFACE_NUM*1-1 downto 0),
      MED_DATA_OUT(INTERFACE_NUM*16-1 downto 0)      => med_data_out(INTERFACE_NUM*16-1 downto 0),
      MED_PACKET_NUM_OUT(INTERFACE_NUM*3-1 downto 0) => med_packet_num_out(INTERFACE_NUM*3-1 downto 0),
      MED_READ_IN(INTERFACE_NUM*1-1 downto 0)        => med_read_in(INTERFACE_NUM*1-1 downto 0),
      MED_DATAREADY_IN(INTERFACE_NUM*1-1 downto 0)   => med_dataready_in(INTERFACE_NUM*1-1 downto 0),
      MED_DATA_IN(INTERFACE_NUM*16-1 downto 0)       => med_data_in(INTERFACE_NUM*16-1 downto 0),
      MED_PACKET_NUM_IN(INTERFACE_NUM*3-1 downto 0)  => med_packet_num_in(INTERFACE_NUM*3-1 downto 0),
      MED_READ_OUT(INTERFACE_NUM*1-1 downto 0)       => med_read_out(INTERFACE_NUM*1-1 downto 0),
      MED_STAT_OP(INTERFACE_NUM*16-1 downto 0)       => med_stat_op(INTERFACE_NUM*16-1 downto 0),
      MED_CTRL_OP(INTERFACE_NUM*16-1 downto 0)       => med_ctrl_op(INTERFACE_NUM*16-1 downto 0),

     -- Gbe Read-out Path ---------------------------------------------------------------
      --Event information coming from CTS for GbE
      GBE_CTS_NUMBER_OUT          => gbe_cts_number,
      GBE_CTS_CODE_OUT            => gbe_cts_code,
      GBE_CTS_INFORMATION_OUT     => gbe_cts_information,
      GBE_CTS_READOUT_TYPE_OUT    => gbe_cts_readout_type,
      GBE_CTS_START_READOUT_OUT   => gbe_cts_start_readout,
      --Information sent to CTS
      GBE_CTS_READOUT_FINISHED_IN => gbe_cts_readout_finished,
      GBE_CTS_STATUS_BITS_IN      => gbe_cts_status_bits,
      -- Data from Frontends
      GBE_FEE_DATA_OUT            => gbe_fee_data,
      GBE_FEE_DATAREADY_OUT       => gbe_fee_dataready,
      GBE_FEE_READ_IN             => gbe_fee_read,
      GBE_FEE_STATUS_BITS_OUT     => gbe_fee_status_bits,
      GBE_FEE_BUSY_OUT            => gbe_fee_busy,

      -- CTS Request Sending -------------------------------------------------------------
      --LVL1 trigger
      CTS_TRG_SEND_IN         => cts_trg_send,
      CTS_TRG_TYPE_IN         => cts_trg_type,
      CTS_TRG_NUMBER_IN       => cts_trg_number,
      CTS_TRG_INFORMATION_IN  => cts_trg_information,
      CTS_TRG_RND_CODE_IN     => cts_trg_code,
      CTS_TRG_STATUS_BITS_OUT => cts_trg_status_bits,
      CTS_TRG_BUSY_OUT        => cts_trg_busy,
      --IPU Channel
      CTS_IPU_SEND_IN         => cts_ipu_send,
      CTS_IPU_TYPE_IN         => cts_ipu_type,
      CTS_IPU_NUMBER_IN       => cts_ipu_number,
      CTS_IPU_INFORMATION_IN  => cts_ipu_information,
      CTS_IPU_RND_CODE_IN     => cts_ipu_code,
      -- Receiver port
      CTS_IPU_STATUS_BITS_OUT => cts_ipu_status_bits,
      CTS_IPU_BUSY_OUT        => cts_ipu_busy,

      -- CTS Data Readout ----------------------------------------------------------------
      --Trigger to CTS out
      RDO_TRIGGER_IN             => cts_trigger_out,
      RDO_TRG_DATA_VALID_OUT     => cts_rdo_rx.data_valid,
      RDO_VALID_TIMING_TRG_OUT   => cts_rdo_rx.valid_timing_trg,
      RDO_VALID_NOTIMING_TRG_OUT => cts_rdo_rx.valid_notiming_trg,
      RDO_INVALID_TRG_OUT        => cts_rdo_rx.invalid_trg,
      RDO_TRG_TYPE_OUT           => cts_rdo_rx.trg_type,
      RDO_TRG_CODE_OUT           => cts_rdo_rx.trg_code,
      RDO_TRG_INFORMATION_OUT    => cts_rdo_rx.trg_information,
      RDO_TRG_NUMBER_OUT         => cts_rdo_rx.trg_number,

      --Data from CTS in
      RDO_TRG_STATUSBITS_IN        => cts_rdo_trg_status_bits_cts,
      RDO_DATA_IN                  => cts_rdo_data,
      RDO_DATA_WRITE_IN            => cts_rdo_write,
      RDO_DATA_FINISHED_IN         => cts_rdo_finished,
      --Data from additional modules
      RDO_ADDITIONAL_STATUSBITS_IN => cts_rdo_trg_status_bits_additional,
      RDO_ADDITIONAL_DATA          => cts_rdo_additional_data,
      RDO_ADDITIONAL_WRITE         => cts_rdo_additional_write,
      RDO_ADDITIONAL_FINISHED      => cts_rdo_additional_finished,

      -- Slow Control --------------------------------------------------------------------
      COMMON_STAT_REGS    => open,
      COMMON_CTRL_REGS    => common_ctrl_reg,
      ONEWIRE             => TEMPSENS,
      ONEWIRE_MONITOR_IN  => open,
      MY_ADDRESS_OUT      => timer.network_address,
      UNIQUE_ID_OUT       => timer.uid,
      TIMER_TICKS_OUT(0)  => timer.tick_us,
      TIMER_TICKS_OUT(1)  => timer.tick_ms,
      TEMPERATURE_OUT     => timer.temperature,
      EXTERNAL_SEND_RESET => reset_via_gbe,

      REGIO_ADDR_OUT            => ctrlbus_rx.addr,
      REGIO_READ_ENABLE_OUT     => ctrlbus_rx.read,
      REGIO_WRITE_ENABLE_OUT    => ctrlbus_rx.write,
      REGIO_DATA_OUT            => ctrlbus_rx.data,
      REGIO_DATA_IN             => ctrlbus_tx.data,
      REGIO_DATAREADY_IN        => rdack,
      REGIO_NO_MORE_DATA_IN     => ctrlbus_tx.nack,
      REGIO_WRITE_ACK_IN        => wrack,
      REGIO_UNKNOWN_ADDR_IN     => ctrlbus_tx.unknown,
      REGIO_TIMEOUT_OUT         => ctrlbus_rx.timeout,
      
      --Gbe Sctrl Input
      GSC_INIT_DATAREADY_IN    => gsc_init_dataready,
      GSC_INIT_DATA_IN         => gsc_init_data,
      GSC_INIT_PACKET_NUM_IN   => gsc_init_packet_num,
      GSC_INIT_READ_OUT        => gsc_init_read,
      GSC_REPLY_DATAREADY_OUT  => gsc_reply_dataready,
      GSC_REPLY_DATA_OUT       => gsc_reply_data,
      GSC_REPLY_PACKET_NUM_OUT => gsc_reply_packet_num,
      GSC_REPLY_READ_IN        => gsc_reply_read,
      GSC_BUSY_OUT             => gsc_busy,

      --status and control ports
      HUB_STAT_CHANNEL => open,
      HUB_STAT_GEN     => open,
      MPLEX_CTRL       => (others => '0'),
      MPLEX_STAT       => open,
      STAT_REGS        => open,
      STAT_CTRL_REGS   => open,

      --Fixed status and control ports
      STAT_DEBUG => open,
      CTRL_DEBUG => (others => '0')
      );

  gen_addition_ports : for i in 0 to cts_rdo_additional_ports-1 generate
    cts_rdo_additional_data(31 + i*32 downto 32*i)            <= cts_rdo_additional(i).data;
    cts_rdo_trg_status_bits_additional(31 + i*32 downto 32*i) <= cts_rdo_additional(i).statusbits;
    
    cts_rdo_additional_write(i)                               <= cts_rdo_additional(i).data_write;
    cts_rdo_additional_finished(i)                            <= cts_rdo_additional(i).data_finished;
    
  end generate;

  gen_media_record : for i in 0 to INTERFACE_NUM-1 generate
    med_data_in(i*16+15 downto i*16)    <= med2int(i).data;
    med_packet_num_in(i*3+2 downto i*3) <= med2int(i).packet_num;
    med_dataready_in(i)                 <= med2int(i).dataready;
    med_read_in(i)                      <= med2int(i).tx_read;
    med_stat_op(i*16+15 downto i*16)    <= med2int(i).stat_op;
    
    int2med(i).data         <= med_data_out(i*16+15 downto i*16);    
    int2med(i).packet_num   <= med_packet_num_out(i*3+2 downto i*3);
    int2med(i).dataready    <= med_dataready_out(i);
    int2med(i).ctrl_op      <= med_ctrl_op(i*16+15 downto i*16);
  end generate;
  
  rdack <= ctrlbus_tx.ack or ctrlbus_tx.rack;
  wrack <= ctrlbus_tx.ack or ctrlbus_tx.wack;
  
---------------------------------------------------------------------------
-- CTS
---------------------------------------------------------------------------
    THE_CTS : CTS
      generic map (
        EXTERNAL_TRIGGER_ID => ETM_ID,  -- fill in trigger logic enumeration id of external trigger logic
        OUTPUT_MULTIPLEXERS => CTS_OUTPUT_MULTIPLEXERS,
        ADDON_GROUPS      => 2,
        ADDON_GROUP_UPPER => (1,17, others => 0)
        )
      port map (
        CLK   => clk_sys,
        RESET => reset_i,

        TRIGGER_BUSY_OUT   => trigger_busy_i,
        TIME_REFERENCE_OUT => cts_trigger_out,

        ADDON_TRIGGERS_IN        => cts_addon_triggers_in,
        ADDON_GROUP_ACTIVITY_OUT => open,
        ADDON_GROUP_SELECTED_OUT => open,

        EXT_TRIGGER_IN     => '0',
        EXT_STATUS_IN      => (others => '0'),
        EXT_CONTROL_OUT    => open,
        EXT_HEADER_BITS_IN => (others => '0'),
        EXT_FORCE_TRIGGER_INFO_IN => (others => '0'),

        PERIPH_TRIGGER_IN => (others => '0'),

        OUTPUT_MULTIPLEXERS_OUT => open,

        CTS_TRG_SEND_OUT        => cts_trg_send,
        CTS_TRG_TYPE_OUT        => cts_trg_type,
        CTS_TRG_NUMBER_OUT      => cts_trg_number,
        CTS_TRG_INFORMATION_OUT => cts_trg_information,
        CTS_TRG_RND_CODE_OUT    => cts_trg_code,
        CTS_TRG_STATUS_BITS_IN  => cts_trg_status_bits,
        CTS_TRG_BUSY_IN         => cts_trg_busy,

        CTS_IPU_SEND_OUT        => cts_ipu_send,
        CTS_IPU_TYPE_OUT        => cts_ipu_type,
        CTS_IPU_NUMBER_OUT      => cts_ipu_number,
        CTS_IPU_INFORMATION_OUT => cts_ipu_information,
        CTS_IPU_RND_CODE_OUT    => cts_ipu_code,
        CTS_IPU_STATUS_BITS_IN  => cts_ipu_status_bits,
        CTS_IPU_BUSY_IN         => cts_ipu_busy,

        CTS_REGIO_ADDR_IN          => buscts_rx.addr,
        CTS_REGIO_DATA_IN          => buscts_rx.data,
        CTS_REGIO_READ_ENABLE_IN   => buscts_rx.read,
        CTS_REGIO_WRITE_ENABLE_IN  => buscts_rx.write,
        CTS_REGIO_DATA_OUT         => buscts_tx.data,
        CTS_REGIO_DATAREADY_OUT    => buscts_tx.rack,
        CTS_REGIO_WRITE_ACK_OUT    => buscts_tx.wack,
        CTS_REGIO_UNKNOWN_ADDR_OUT => buscts_tx.unknown,

        LVL1_TRG_DATA_VALID_IN     => cts_rdo_rx.data_valid,
        LVL1_VALID_TIMING_TRG_IN   => cts_rdo_rx.valid_timing_trg,
        LVL1_VALID_NOTIMING_TRG_IN => cts_rdo_rx.valid_notiming_trg,
        LVL1_INVALID_TRG_IN        => cts_rdo_rx.invalid_trg,

        FEE_TRG_STATUSBITS_OUT => cts_rdo_trg_status_bits_cts,
        FEE_DATA_OUT           => cts_rdo_data,
        FEE_DATA_WRITE_OUT     => cts_rdo_write,
        FEE_DATA_FINISHED_OUT  => cts_rdo_finished
        );   

        
  cts_addon_triggers_in(1 downto 0)  <= SPARE_IN(1 downto 0);
  cts_addon_triggers_in(17 downto 2) <= INP(79 downto 64);
  buscts_tx.nack <= '0';
  buscts_tx.ack  <= '0';

---------------------------------------------------------------------------
-- Add timestamp generator
---------------------------------------------------------------------------
  GEN_TIMESTAMP : if INCLUDE_TIMESTAMP_GENERATOR = c_YES generate
    THE_TIMESTAMP : entity work.timestamp_generator 
      port map(
        CLK               => clk_sys,
        RESET_IN          => reset_i,
        
        TIMER_CLOCK_IN    => INP(80), 
        TIMER_RESET_IN    => INP(81),

        TRIGGER_IN         => cts_trigger_out,
        BUSRDO_RX          => cts_rdo_rx,
        BUSRDO_TX          => cts_rdo_additional(0)
        );
  end generate;  
  
  
---------------------------------------------------------------------------
-- Bus Handler
---------------------------------------------------------------------------
  THE_BUS_HANDLER : entity work.trb_net16_regio_bus_handler_record
    generic map(
      PORT_NUMBER      => 9,
      PORT_ADDRESSES   => (0 => x"d000", 1 => x"d300", 2 => x"b000", 3 => x"b200", 4 => x"b400", 5 => x"8100", 6 => x"8300", 7 => x"a000", 8 => x"c000", others => x"0000"),
      PORT_ADDR_MASK   => (0 => 12,      1 => 1,       2 => 9,       3 => 9,       4 => 9,       5 => 8,       6 => 8,       7 => 11,      8 => 12,      others => 0),
      PORT_MASK_ENABLE => 1
      )
    port map(
      CLK   => clk_sys,
      RESET => reset_i,

      REGIO_RX  => handlerbus_rx,
      REGIO_TX  => ctrlbus_tx,
      
      BUS_RX(0) => bustools_rx, --Flash, SPI, UART, ADC, SED
      BUS_RX(1) => bustc_rx,    --Clock switch
      BUS_RX(2) => bussci1_rx,   --SCI Serdes
      BUS_RX(3) => bussci2_rx,
      BUS_RX(4) => bussci3_rx,
      BUS_RX(5) => busgbeip_rx,
      BUS_RX(6) => busgbereg_rx,
      BUS_RX(7) => buscts_rx,
      BUS_RX(8) => bustdc_rx,
      BUS_TX(0) => bustools_tx,
      BUS_TX(1) => bustc_tx,
      BUS_TX(2) => bussci1_tx,
      BUS_TX(3) => bussci2_tx,
      BUS_TX(4) => bussci3_tx,
      BUS_TX(5) => busgbeip_tx,
      BUS_TX(6) => busgbereg_tx,
      BUS_TX(7) => buscts_tx,
      BUS_TX(8) => bustdc_tx,
      STAT_DEBUG => open
      );

  handlerbus_rx <= ctrlbus_rx when bus_master_active = '0' else bus_master_out;         
      
---------------------------------------------------------------------------
-- Control Tools
---------------------------------------------------------------------------
  THE_TOOLS: entity work.trb3sc_tools 
    port map(
      CLK         => clk_sys,
      RESET       => reset_i,
      
      --Flash & Reload
      FLASH_CS    => FLASH_CS,
      FLASH_CLK   => FLASH_CLK,
      FLASH_IN    => FLASH_OUT,
      FLASH_OUT   => FLASH_IN,
      PROGRAMN    => PROGRAMN,
      REBOOT_IN   => do_reboot_i,
      --SPI
      SPI_CS_OUT  => spi_cs,  
      SPI_MOSI_OUT=> spi_mosi,
      SPI_MISO_IN => spi_miso,
      SPI_CLK_OUT => spi_clk,
      --Header
      HEADER_IO   => HDR_IO,
      --LCD
      LCD_DATA_IN => open,
      --ADC
      ADC_CS      => ADC_CS,
      ADC_MOSI    => ADC_DIN,
      ADC_MISO    => ADC_DOUT,
      ADC_CLK     => ADC_CLK,
      --Trigger & Monitor 
      MONITOR_INPUTS => monitor_inputs_i,
      TRIG_GEN_INPUTS  => open,
      TRIG_GEN_OUTPUTS => open,      
      --SED
      SED_ERROR_OUT => sed_error_i,
      --Slowcontrol
      BUS_RX     => bustools_rx,
      BUS_TX     => bustools_tx,
      --Control master for default settings
      BUS_MASTER_IN  => ctrlbus_tx,
      BUS_MASTER_OUT => bus_master_out,
      BUS_MASTER_ACTIVE => bus_master_active,        
      DEBUG_OUT  => open
      );      

gen_reboot_no_gbe : if INCLUDE_GBE = c_NO generate
  do_reboot_i <= common_ctrl_reg(15);
end generate;  
gen_reboot_with_gbe : if INCLUDE_GBE = c_YES generate
  do_reboot_i <= common_ctrl_reg(15) or reboot_from_gbe;
end generate;  

---------------------------------------------------------------------------
-- Switches
---------------------------------------------------------------------------
--Serdes Select
  PCSSW_ENSMB <= '0';
  PCSSW_EQ    <= x"0";
  PCSSW_PE    <= x"F";
  PCSSW       <= "01001110"; --SFP2 on B3, AddOn on D1

---------------------------------------------------------------------------
-- I/O
---------------------------------------------------------------------------
  spi_miso(5 downto 4) <= DAC_IN_SDI(6 downto 5);
  DAC_OUT_SCK(6 downto 5) <= spi_clk(5 downto 4);
  DAC_OUT_CS(6 downto 5)  <= spi_cs(5 downto 4);
  DAC_OUT_SDO(6 downto 5) <= spi_mosi(5 downto 4);
  spi_miso(3 downto 0)    <= (others => '0');
  spi_miso(15 downto 7)   <= (others => '0');
  
  RJ_IO(0)                           <= cts_trigger_out;

---------------------------------------------------------------------------
-- LED
---------------------------------------------------------------------------
  --LED are green, orange, red, yellow, white(2), rj_green(2), rj_red(2), sfp_green(2), sfp_red(2)
  LED_GREEN            <= debug_clock_reset(0);   
  LED_ORANGE           <= debug_clock_reset(1);
  LED_RED              <= not sed_error_i;
  LED_YELLOW           <= debug_clock_reset(2);


gen_leds_addon : if USE_ADDON = c_YES generate
  gen_hub_leds : for i in 1 to 4 generate
    LED_HUB_LINKOK(i) <= not  med2int(i).stat_op(9);
    LED_HUB_TX(i)     <= not (med2int(i).stat_op(10) or not med2int(i).stat_op(9));
    LED_HUB_RX(i)     <= not (med2int(i).stat_op(11));
  end generate;
end generate;

--   LED_HUB_LINKOK(8)  <= not  med2int(7).stat_op(9) when INCLUDE_GBE = 0 else
--                              '1';
--   LED_HUB_TX(8)      <= not (med2int(7).stat_op(10) or not med2int(7).stat_op(9)) when INCLUDE_GBE = 0 else
--                              '1';
--   LED_HUB_RX(8)      <= not (med2int(7).stat_op(11)) when INCLUDE_GBE = 0 else
-- 
  LED_SFP_GREEN(0)   <= --not  med2int(8).stat_op(9) when INCLUDE_GBE = 0 else 
                             '1';
  LED_SFP_RED(0)     <= --not  (med2int(8).stat_op(10) or med2int(8).stat_op(11) or not med2int(8).stat_op(9)) when INCLUDE_GBE = 0 else 
                             '1';

  LED_SFP_GREEN(1)   <= not  med2int(0).stat_op(9) when USE_BACKPLANE = 0 and USE_ADDON = 0 else 
                             '1';
  LED_SFP_RED(1)     <= not  (med2int(0).stat_op(10) or med2int(0).stat_op(11) or not med2int(0).stat_op(9)) when USE_BACKPLANE = 0 and USE_ADDON = 0 else  
                             '1';
                        
--   LED_WHITE(0)       <= not  med2int(10).stat_op(9) when INCLUDE_GBE = 0 and USE_BACKPLANE = 1 else 
--                         not  med2int(8).stat_op(9)  when INCLUDE_GBE = 1 and USE_BACKPLANE = 1 else 
--                              '1';
--   LED_WHITE(1)       <= not  (med2int(10).stat_op(10) or med2int(10).stat_op(11) or not med2int(10).stat_op(9)) when INCLUDE_GBE = 0 and USE_BACKPLANE = 1 else 
--                         not  (med2int(8).stat_op(10) or med2int(8).stat_op(11) or not med2int(8).stat_op(9))    when INCLUDE_GBE = 1 and USE_BACKPLANE = 1 else
--                              '1';

-------------------------------------------------------------------------------
-- TDC
-------------------------------------------------------------------------------
  THE_TDC : entity work.TDC_record
    generic map (
      CHANNEL_NUMBER => NUM_TDC_CHANNELS,  -- Number of TDC channels per module
      STATUS_REG_NR  => 21,             -- Number of status regs
      DEBUG          => c_YES,
      SIMULATION     => c_NO)
    port map (
      RESET              => reset_i,
      CLK_TDC            => clk_full_osc,
      CLK_READOUT        => clk_sys,    -- Clock for the readout
      REFERENCE_TIME     => cts_trigger_out,  -- Reference time input
      HIT_IN             => hit_in_i(NUM_TDC_CHANNELS-1 downto 1),  -- Channel start signals
      HIT_CAL_IN         => clk_cal,    -- Hits for calibrating the TDC
      -- Trigger signals from handler
      BUSRDO_RX          => cts_rdo_rx,
      BUSRDO_TX          => cts_rdo_additional(INCLUDE_TIMESTAMP_GENERATOR),
      -- Slow control bus
      BUS_RX             => bustdc_rx,
      BUS_TX             => bustdc_tx,
      -- Dubug signals
      INFO_IN            => timer,
      LOGIC_ANALYSER_OUT => open
      );

  -- For single edge measurements
  gen_single : if DOUBLE_EDGE_TYPE = 0 or DOUBLE_EDGE_TYPE = 1 or DOUBLE_EDGE_TYPE = 3 generate
    hit_in_i(NUM_TDC_CHANNELS-1 downto 1) <= INP(NUM_TDC_CHANNELS-2+64 downto 64);
  end generate;

  -- For ToT Measurements
  gen_double : if DOUBLE_EDGE_TYPE = 2 generate
    Gen_Hit_In_Signals : for i in 0 to NUM_TDC_CHANNELS-2 generate
      hit_in_i(i*2+1)   <= INP(i+64);
      hit_in_i(i*2+2)   <= not INP(i+64);
    end generate Gen_Hit_In_Signals;
  end generate;
  
  
end architecture;



