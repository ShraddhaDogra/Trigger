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

entity trb3sc_master is
  port(
    CLK_SUPPL_PCLK       : in    std_logic; --125 MHz for GbE
    CLK_CORE_PCLK        : in    std_logic; --Main Oscillator
    CLK_EXT_PLL_LEFT     : in    std_logic; --External Clock

    TRIG_LEFT            : in    std_logic;
    --Additional IO
    HDR_IO               : inout std_logic_vector(10 downto 1);
    RJ_IO                : inout std_logic_vector( 3 downto 0);
--     SPARE_IN             : in    std_logic_vector( 1 downto 0);  
    BACK_LVDS            : inout std_logic_vector( 1 downto 0);
    BACK_3V3             : inout std_logic_vector( 3 downto 0);

    --Lines to slaves
    BACK_MASTER_READY    : out std_logic_vector(8 downto 0);
    BACK_SLAVE_READY     : in  std_logic_vector(8 downto 0);
    BACK_TRIG1           : in  std_logic_vector(8 downto 0);
    BACK_TRIG2           : in  std_logic_vector(8 downto 0);
    
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
  attribute syn_useioff of HDR_IO     : signal is false;
  
  --Serdes:                                Backplane
  --Backplane A2,A3,A0,A1                  Slave 3,4,1,2,             A0: TrbNet from backplane
  --AddOn     C2,C3,C0,C1,B0,B1,B2,D1(B3)  Slave --,--,5,9,8,7,6,--
  --SFP       D0,B3(D1)                                               D0: GbE, B3: TrbNet
  
  
end entity;

architecture trb3sc_arch of trb3sc_master is
  attribute syn_keep     : boolean;
  attribute syn_preserve : boolean;
  
  signal clk_sys, clk_full, clk_full_osc   : std_logic;
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
  signal med_stat_debug    : std_logic_vector (1*64-1  downto 0);
  
  signal ctrlbus_rx, bussci1_rx, bussci2_rx, bussci3_rx, bussci4_rx, bustools_rx, 
         bustc_rx, busgbeip_rx, busgbereg_rx, bus_master_out, handlerbus_rx  : CTRLBUS_RX;
  signal ctrlbus_tx, bussci1_tx, bussci2_tx, bussci3_tx, bussci4_tx, bustools_tx, 
         bustc_tx, busgbeip_tx, busgbereg_tx, bus_master_in : CTRLBUS_TX;
  
  
  signal common_stat_reg         : std_logic_vector(std_COMSTATREG*32-1 downto 0) := (others => '0');
  signal common_ctrl_reg         : std_logic_vector(std_COMCTRLREG*32-1 downto 0);
  
  signal sed_error_i    : std_logic;
  signal bus_master_active : std_logic;
  
  signal spi_cs, spi_mosi, spi_miso, spi_clk : std_logic_vector(15 downto 0);
  signal uart_tx, uart_rx : std_logic;

  signal timer          : TIMERS;
  signal lcd_data       : std_logic_vector(511 downto 0);
  
  signal cts_number                   : std_logic_vector(15 downto 0);
  signal cts_code                     : std_logic_vector(7 downto 0);
  signal cts_information              : std_logic_vector(7 downto 0);
  signal cts_start_readout            : std_logic;
  signal cts_readout_type             : std_logic_vector(3 downto 0);
  signal cts_data                     : std_logic_vector(31 downto 0);
  signal cts_dataready                : std_logic;
  signal cts_readout_finished         : std_logic;
  signal cts_read                     : std_logic;
  signal cts_length                   : std_logic_vector(15 downto 0);
  signal cts_status_bits              : std_logic_vector(31 downto 0);
  signal fee_data                     : std_logic_vector(15 downto 0);
  signal fee_dataready                : std_logic;
  signal fee_read                     : std_logic;
  signal fee_status_bits              : std_logic_vector(31 downto 0);
  signal fee_busy                     : std_logic;
  signal gsc_init_data, gsc_reply_data : std_logic_vector(15 downto 0);
  signal gsc_init_read, gsc_reply_read : std_logic;
  signal gsc_init_dataready, gsc_reply_dataready : std_logic;
  signal gsc_init_packet_num, gsc_reply_packet_num : std_logic_vector(2 downto 0);
  signal gsc_busy : std_logic;
  signal my_address   : std_logic_vector(15 downto 0);
  signal mc_unique_id : std_logic_vector(63 downto 0);
  signal reset_via_gbe  : std_logic;
 
  signal med_dataready_out    : std_logic_vector (11-1 downto 0);
  signal med_data_out         : std_logic_vector (11*c_DATA_WIDTH-1 downto 0);
  signal med_packet_num_out   : std_logic_vector (11*c_NUM_WIDTH-1 downto 0);
  signal med_read_in          : std_logic_vector (11-1 downto 0);
  signal med_dataready_in     : std_logic_vector (11-1 downto 0);
  signal med_data_in          : std_logic_vector (11*c_DATA_WIDTH-1 downto 0);
  signal med_packet_num_in    : std_logic_vector (11*c_NUM_WIDTH-1 downto 0);
  signal med_read_out         : std_logic_vector (11-1 downto 0);
  signal med_stat_op          : std_logic_vector (11*16-1 downto 0);
  signal med_ctrl_op          : std_logic_vector (11*16-1 downto 0);
  signal rdack, wrack         : std_logic;
  signal reset_from_net_i     : std_logic;
  signal send_reset_i         : std_logic;
  signal external_reset_delayed : std_logic_vector(4 downto 0);
  
  signal trig_gen_out_i   : std_logic_vector(3 downto 0);
  signal monitor_inputs_i : std_logic_vector(17 downto 0);
  
  signal backplane_rx_present, backplane_tx_present : std_logic_vector(8 downto 0);
  
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
    NET_CLK_FULL_IN => med2int(9).clk_full,
    NET_CLK_HALF_IN => med2int(9).clk_half,
    RESET_FROM_NET  => reset_from_net_i,
    SEND_RESET_IN   => send_reset_i,
    
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
reset_from_net_i <= med2int(9).stat_op(13)  or external_reset_delayed(4) ;
send_reset_i <= med2int(9).stat_op(15); --int2med(0).ctrl_op(15) or;

---------------------------------------------------------------------------
-- TrbNet Uplink
---------------------------------------------------------------------------
THE_MEDIA_INT_MIXED : entity work.med_ecp3_sfp_sync_4_slave3  --PCSB
  generic map(
    IS_SYNC_SLAVE   => (c_NO,  c_NO,  c_NO,  c_YES),
    IS_USED         => (c_YES, c_YES, c_YES ,c_YES)
    )
  port map(
    CLK_REF_FULL       => clk_full_osc, --med2int(INTERFACE_NUM-1).clk_full,
    CLK_INTERNAL_FULL  => clk_full_osc,
    SYSCLK             => clk_sys,
    RESET              => reset_i,
    CLEAR              => clear_i,
    --Internal Connection
    MEDIA_MED2INT(0)   => med2int(7),
    MEDIA_MED2INT(1)   => med2int(6),
    MEDIA_MED2INT(2)   => med2int(5),
    MEDIA_MED2INT(3)   => med2int(9),
    MEDIA_INT2MED(0)   => int2med(7),
    MEDIA_INT2MED(1)   => int2med(6),
    MEDIA_INT2MED(2)   => int2med(5),
    MEDIA_INT2MED(3)   => int2med(9),

    --Sync operation
    RX_DLM             => open,
    RX_DLM_WORD        => open,
    TX_DLM             => open,
    TX_DLM_WORD        => open,
    
    --SFP Connection
    SD_PRSNT_N_IN(0)   => backplane_rx_present(7),
    SD_LOS_IN(0)       => backplane_rx_present(7),
    SD_TXDIS_OUT(0)    => backplane_tx_present(7),    
    SD_PRSNT_N_IN(1)   => backplane_rx_present(6),
    SD_LOS_IN(1)       => backplane_rx_present(6),
    SD_TXDIS_OUT(1)    => backplane_tx_present(6),    
    SD_PRSNT_N_IN(2)   => backplane_rx_present(5),
    SD_LOS_IN(2)       => backplane_rx_present(5),
    SD_TXDIS_OUT(2)    => backplane_tx_present(5),    
    SD_PRSNT_N_IN(3)   => SFP_MOD0(1),
    SD_LOS_IN(3)       => '0', --SFP_LOS(1),
    SD_TXDIS_OUT(3)    => SFP_TX_DIS(1),
    --Control Interface
    BUS_RX             => bussci2_rx,
    BUS_TX             => bussci2_tx,
    -- Status and control port
    STAT_DEBUG         => open,
    CTRL_DEBUG         => open
  );

---------------------------------------------------------------------------
-- PCSD   Uplink when no GbE is used
---------------------------------------------------------------------------    
gen_PCSD : if INCLUDE_GBE = c_NO generate
  THE_MEDIA_PCSD : entity work.med_ecp3_sfp_sync
    generic map(
      SERDES_NUM    => 0,
      IS_SYNC_SLAVE => c_NO
      )
    port map(
      CLK_REF_FULL       => clk_full_osc, --med2int(0).clk_full,
      CLK_INTERNAL_FULL  => clk_full_osc,
      SYSCLK        => clk_sys,
      RESET         => reset_i,
      CLEAR         => clear_i,
      --Internal Connection
      MEDIA_MED2INT => med2int(10),   --10 or 8
      MEDIA_INT2MED => int2med(10),

      --Sync operation
      RX_DLM      => open,
      RX_DLM_WORD => open,
      TX_DLM      => open,
      TX_DLM_WORD => open,

      --SFP Connection
      SD_PRSNT_N_IN  => SFP_MOD0(0),
      SD_LOS_IN      => SFP_LOS(0),
      SD_TXDIS_OUT   => SFP_TX_DIS(0),
      --Control Interface
      BUS_RX         => bussci4_rx,
      BUS_TX         => bussci4_tx,
      -- Status and control port
      STAT_DEBUG     => open, --med_stat_debug(63 downto 0),
      CTRL_DEBUG     => open
      );
end generate;

---------------------------------------------------------------------------
-- TrbNet Downlink
---------------------------------------------------------------------------
THE_MEDIA_4_DOWN : entity work.med_ecp3_sfp_sync_4 --PCSA
  generic map(
    IS_SYNC_SLAVE   => (c_NO, c_NO, c_NO, c_NO),
    IS_USED         => (c_YES,c_YES ,c_YES ,c_YES)
    )
  port map(
    CLK_REF_FULL       => clk_full_osc, --med2int(INTERFACE_NUM-1).clk_full,
    CLK_INTERNAL_FULL  => clk_full_osc,
    SYSCLK             => clk_sys,
    RESET              => reset_i,
    CLEAR              => clear_i,
    
    --Internal Connection
    MEDIA_MED2INT(0 to 3) => med2int(0 to 3),
    MEDIA_INT2MED(0 to 3) => int2med(0 to 3),

    --Sync operation
    RX_DLM             => open,
    RX_DLM_WORD        => open,
    TX_DLM             => open,
    TX_DLM_WORD        => open,
    
    --SFP Connection
    SD_PRSNT_N_IN      => backplane_rx_present(3 downto 0),
    SD_LOS_IN          => backplane_rx_present(3 downto 0),
    SD_TXDIS_OUT       => backplane_tx_present(3 downto 0),
    
    --Control Interface
    BUS_RX             => bussci1_rx,
    BUS_TX             => bussci1_tx,

    -- Status and control port
    STAT_DEBUG         => med_stat_debug(63 downto 0),
    CTRL_DEBUG         => open
   );

THE_MEDIA_4_DOWN2 : entity work.med_ecp3_sfp_sync_4 --PCSC
  generic map(
    IS_SYNC_SLAVE   => (c_NO, c_NO, c_NO, c_NO),
    IS_USED         => (c_YES,c_YES ,c_NO ,c_NO)
    )
  port map(
    CLK_REF_FULL       => clk_full_osc, --med2int(INTERFACE_NUM-1).clk_full,
    CLK_INTERNAL_FULL  => clk_full_osc,
    SYSCLK             => clk_sys,
    RESET              => reset_i,
    CLEAR              => clear_i,
    
    --Internal Connection
    MEDIA_MED2INT(0) => med2int(4),
    MEDIA_MED2INT(1) => med2int(8),
    MEDIA_INT2MED(0) => int2med(4),
    MEDIA_INT2MED(1) => int2med(8),

    --Sync operation
    RX_DLM             => open,
    RX_DLM_WORD        => open,
    TX_DLM             => open,
    TX_DLM_WORD        => open,
    
    --SFP Connection
    SD_PRSNT_N_IN(0)   => backplane_rx_present(4),
    SD_PRSNT_N_IN(1)   => backplane_rx_present(8),
    SD_PRSNT_N_IN(2)   => '1',
    SD_PRSNT_N_IN(3)   => '1',

    SD_LOS_IN(0)   => backplane_rx_present(4),
    SD_LOS_IN(1)   => backplane_rx_present(8),
    SD_LOS_IN(2)   => '1',
    SD_LOS_IN(3)   => '1',

    SD_TXDIS_OUT(0)   => backplane_tx_present(4),
    SD_TXDIS_OUT(1)   => backplane_tx_present(8),
    SD_TXDIS_OUT(2)   => open,
    SD_TXDIS_OUT(3)   => open,
    
    --Control Interface
    BUS_RX             => bussci3_rx,
    BUS_TX             => bussci3_tx,

    -- Status and control port
    STAT_DEBUG         => open, --med_stat_debug(63 downto 0),
    CTRL_DEBUG         => open
   );   
   
gen_ready_signals : for i in 0 to 8 generate
   backplane_rx_present(i) <= BACK_SLAVE_READY(i);
   BACK_MASTER_READY(i) <= backplane_tx_present(i) or SFP_LOS(1);
   
   monitor_inputs_i(i*2+1 downto i*2) <= BACK_TRIG2(i) & BACK_TRIG1(i);
end generate;   

---------------------------------------------------------------------------
-- GbE
---------------------------------------------------------------------------
gen_noGBE : if INCLUDE_GBE = 0 generate
  busgbeip_tx.unknown  <= busgbeip_rx.read  or busgbeip_rx.write;
  busgbereg_tx.unknown <= busgbereg_rx.read or busgbereg_rx.write;
end generate;  
  
gen_GBE : if INCLUDE_GBE = 1 generate
  signal external_reset_i : std_logic;
begin
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
      LINK_HAS_PING     => "0001"
      )
              
    port map(
      CLK_SYS_IN               => clk_sys,
      CLK_125_IN               => CLK_SUPPL_PCLK,
      RESET                    => reset_i,
      GSR_N                    => GSR_N,

      TRIGGER_IN               => TRIG_LEFT,
      
      SD_PRSNT_N_IN(0)         => SFP_MOD0(0),
      SD_LOS_IN(0)             => SFP_LOS(0),
      SD_TXDIS_OUT(0)          => SFP_TX_DIS(0),

      CTS_NUMBER_IN            => cts_number,          
      CTS_CODE_IN              => cts_code,            
      CTS_INFORMATION_IN       => cts_information,     
      CTS_READOUT_TYPE_IN      => cts_readout_type,    
      CTS_START_READOUT_IN     => cts_start_readout,   
      CTS_DATA_OUT             => cts_data,                    
      CTS_DATAREADY_OUT        => cts_dataready,                    
      CTS_READOUT_FINISHED_OUT => cts_readout_finished,
      CTS_READ_IN              => cts_read,                     
      CTS_LENGTH_OUT           => cts_length,                    
      CTS_ERROR_PATTERN_OUT    => cts_status_bits,     
      
      FEE_DATA_IN              => fee_data,       
      FEE_DATAREADY_IN         => fee_dataready,  
      FEE_READ_OUT             => fee_read,       
      FEE_STATUS_BITS_IN       => fee_status_bits,
      FEE_BUSY_IN              => fee_busy,       
      
      MC_UNIQUE_ID_IN          => mc_unique_id,
      MY_TRBNET_ADDRESS_IN     => my_address,
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
-- Hub with GbE
---------------------------------------------------------------------------

  THE_HUB: entity work.trb_net16_hub_streaming_port_sctrl_record
  generic map( 
    HUB_USED_CHANNELS   => (1,1,0,1),
    INIT_ADDRESS        => INIT_ADDRESS,
    MII_NUMBER          => INTERFACE_NUM,
    MII_IS_UPLINK       => MII_IS_UPLINK,
    MII_IS_DOWNLINK     => MII_IS_DOWNLINK,
    MII_IS_UPLINK_ONLY  => MII_IS_UPLINK_ONLY,
    USE_ONEWIRE         => c_YES,
    HARDWARE_VERSION    => HARDWARE_INFO,
    INCLUDED_FEATURES   => INCLUDED_FEATURES,
    INIT_ENDPOINT_ID    => x"0001",
    CLOCK_FREQUENCY     => CLOCK_FREQUENCY,
    BROADCAST_SPECIAL_ADDR => BROADCAST_SPECIAL_ADDR
    )
  port map( 
    CLK                     => clk_sys,
    RESET                   => reset_i,
    CLK_EN                  => '1',

    --Media interfacces
    MEDIA_MED2INT           => med2int,
    MEDIA_INT2MED           => int2med,
    
    --Event information coming from CTS
    CTS_NUMBER_OUT          => cts_number,
    CTS_CODE_OUT            => cts_code,
    CTS_INFORMATION_OUT     => cts_information,
    CTS_READOUT_TYPE_OUT    => cts_readout_type,
    CTS_START_READOUT_OUT   => cts_start_readout,
    --Information   sent to CTS
    --status data, equipped with DHDR
    CTS_DATA_IN             => cts_data,
    CTS_DATAREADY_IN        => cts_dataready,
    CTS_READOUT_FINISHED_IN => cts_readout_finished,
    CTS_READ_OUT            => cts_read,
    CTS_LENGTH_IN           => cts_length,
    CTS_STATUS_BITS_IN      => cts_status_bits,
    -- Data from Frontends
    FEE_DATA_OUT            => fee_data,
    FEE_DATAREADY_OUT       => fee_dataready,
    FEE_READ_IN             => fee_read,
    FEE_STATUS_BITS_OUT     => fee_status_bits,
    FEE_BUSY_OUT            => fee_busy,
    MY_ADDRESS_IN           => my_address,
    COMMON_STAT_REGS        => common_stat_reg, --open,
    COMMON_CTRL_REGS        => common_ctrl_reg, --open,
    ONEWIRE                 => TEMPSENS,
    MY_ADDRESS_OUT          => my_address,
    UNIQUE_ID_OUT           => mc_unique_id,
    EXTERNAL_SEND_RESET     => external_reset_i,
    
    BUS_RX                  => ctrlbus_rx,
    BUS_TX                  => ctrlbus_tx,
    TIMER                   => timer,

    --Gbe Sctrl Input
    GSC_INIT_DATAREADY_IN        => gsc_init_dataready,
    GSC_INIT_DATA_IN             => gsc_init_data,
    GSC_INIT_PACKET_NUM_IN       => gsc_init_packet_num,
    GSC_INIT_READ_OUT            => gsc_init_read,
    GSC_REPLY_DATAREADY_OUT      => gsc_reply_dataready,
    GSC_REPLY_DATA_OUT           => gsc_reply_data,
    GSC_REPLY_PACKET_NUM_OUT     => gsc_reply_packet_num,
    GSC_REPLY_READ_IN            => gsc_reply_read,
    GSC_BUSY_OUT                 => gsc_busy,

  --status and control ports
    HUB_STAT_CHANNEL             => open,
    HUB_STAT_GEN                 => open,
    MPLEX_CTRL                   => (others => '0'),
    MPLEX_STAT                   => open,
    STAT_REGS                    => open,
    STAT_CTRL_REGS               => open,

    --Fixed status and control ports
    STAT_DEBUG              => open,
    CTRL_DEBUG              => (others => '0')
  );
  
  external_reset_i <= reset_via_gbe; -- or med2int(9).stat_op(13);
  
  process begin
    wait until rising_edge(clk_sys);
    external_reset_delayed(0) <= external_reset_delayed(0) or external_reset_i;
    external_reset_delayed(3) <= external_reset_delayed(2);
    external_reset_delayed(4) <= external_reset_delayed(2) and not external_reset_delayed(3);
    if timer.tick_us = '1' then
      external_reset_delayed(1) <= external_reset_delayed(0);
      external_reset_delayed(2) <= external_reset_delayed(1);
    end if;
    if reset_i = '1' then
      external_reset_delayed <= (others => '0');
    end if;  
  end process;  
  
end generate;


---------------------------------------------------------------------------
-- Hub without GbE
---------------------------------------------------------------------------
gen_hub_no_gbe : if INCLUDE_GBE = c_NO generate

  THE_HUB : trb_net16_hub_base
    generic map( 
      HUB_USED_CHANNELS   => (1,1,0,1),
      INIT_ADDRESS        => INIT_ADDRESS,
      MII_NUMBER          => INTERFACE_NUM,
      MII_IS_UPLINK       => MII_IS_UPLINK,
      MII_IS_DOWNLINK     => MII_IS_DOWNLINK,
      MII_IS_UPLINK_ONLY  => MII_IS_UPLINK_ONLY,
      USE_ONEWIRE         => c_YES,
      HARDWARE_VERSION    => HARDWARE_INFO,
      INCLUDED_FEATURES   => INCLUDED_FEATURES,
      INIT_ENDPOINT_ID    => x"0001",
      CLOCK_FREQUENCY     => CLOCK_FREQUENCY,
      BROADCAST_SPECIAL_ADDR => BROADCAST_SPECIAL_ADDR,
      COMPILE_TIME        => std_logic_vector(to_unsigned(VERSION_NUMBER_TIME,32))
      )
    port map (
      CLK    => clk_sys,
      RESET  => reset_i,
      CLK_EN => '1',

      --Media interfacces
      MED_DATAREADY_OUT(INTERFACE_NUM*1-1 downto 0)   => med_dataready_out(INTERFACE_NUM*1-1 downto 0),
      MED_DATA_OUT(INTERFACE_NUM*16-1 downto 0)       => med_data_out(INTERFACE_NUM*16-1 downto 0),
      MED_PACKET_NUM_OUT(INTERFACE_NUM*3-1 downto 0)  => med_packet_num_out(INTERFACE_NUM*3-1 downto 0),
      MED_READ_IN(INTERFACE_NUM*1-1 downto 0)         => med_read_in(INTERFACE_NUM*1-1 downto 0),
      MED_DATAREADY_IN(INTERFACE_NUM*1-1 downto 0)    => med_dataready_in(INTERFACE_NUM*1-1 downto 0),
      MED_DATA_IN(INTERFACE_NUM*16-1 downto 0)        => med_data_in(INTERFACE_NUM*16-1 downto 0),
      MED_PACKET_NUM_IN(INTERFACE_NUM*3-1 downto 0)   => med_packet_num_in(INTERFACE_NUM*3-1 downto 0),
      MED_READ_OUT(INTERFACE_NUM*1-1 downto 0)        => med_read_out(INTERFACE_NUM*1-1 downto 0),
      MED_STAT_OP(INTERFACE_NUM*16-1 downto 0)        => med_stat_op(INTERFACE_NUM*16-1 downto 0),
      MED_CTRL_OP(INTERFACE_NUM*16-1 downto 0)        => med_ctrl_op(INTERFACE_NUM*16-1 downto 0),

      COMMON_STAT_REGS                => common_stat_reg,
      COMMON_CTRL_REGS                => common_ctrl_reg,
      MY_ADDRESS_OUT                  => my_address,
      --REGIO INTERFACE
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
      
      ONEWIRE                         => TEMPSENS,
      ONEWIRE_MONITOR_OUT             => open,
      --Status ports (for debugging)
      MPLEX_CTRL            => (others => '0'),
      CTRL_DEBUG            => (others => '0'),
      STAT_DEBUG            => open
      );
      
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
  reboot_from_gbe <= '0';
  reset_via_gbe   <= '0';
  external_reset_delayed <= (others => '0');
end generate;

---------------------------------------------------------------------------
-- Bus Handler
---------------------------------------------------------------------------
  THE_BUS_HANDLER : entity work.trb_net16_regio_bus_handler_record
    generic map(
      PORT_NUMBER      => 8,
      PORT_ADDRESSES   => (0 => x"d000", 1 => x"d300", 2 => x"b000", 3 => x"b200", 4 => x"b400", 5 => x"8100", 6 => x"8300", 7 => x"b600", others => x"0000"),
      PORT_ADDR_MASK   => (0 => 12,      1 => 1,       2 => 9,       3 => 9,       4 => 9,       5 => 8,       6 => 8,       7 => 9,       others => 0),
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
      BUS_RX(7) => bussci4_rx,
      BUS_TX(0) => bustools_tx,
      BUS_TX(1) => bustc_tx,
      BUS_TX(2) => bussci1_tx,
      BUS_TX(3) => bussci2_tx,
      BUS_TX(4) => bussci3_tx,
      BUS_TX(5) => busgbeip_tx,
      BUS_TX(6) => busgbereg_tx,
      BUS_TX(7) => bussci4_tx,
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
      LCD_DATA_IN => lcd_data,
      --ADC
      ADC_CS      => ADC_CS,
      ADC_MOSI    => ADC_DIN,
      ADC_MISO    => ADC_DOUT,
      ADC_CLK     => ADC_CLK,
      --Trigger & Monitor 
      MONITOR_INPUTS(17 downto 0) =>  monitor_inputs_i,
      MONITOR_INPUTS(21 downto 18) => trig_gen_out_i,
      TRIG_GEN_INPUTS  => monitor_inputs_i,
      TRIG_GEN_OUTPUTS => trig_gen_out_i,      
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
      
do_reboot_i <= common_ctrl_reg(15) or reboot_from_gbe;

---------------------------------------------------------------------------
-- Switches
---------------------------------------------------------------------------
--Serdes Select
  PCSSW_ENSMB <= '0';
  PCSSW_EQ    <= x"0";
  PCSSW_PE    <= x"F";
  PCSSW       <= "01001110"; --SFP2 on B3, AddOn on D1

  
---------------------------------------------------------------------------
-- LED
---------------------------------------------------------------------------
  --LED are green, orange, red, yellow, white(2), rj_green(2), rj_red(2), sfp_green(2), sfp_red(2)
  LED_GREEN            <= debug_clock_reset(0);   
  LED_ORANGE           <= debug_clock_reset(1);
  LED_RED              <= not sed_error_i;
  LED_YELLOW           <= debug_clock_reset(2);
  LED_WHITE            <= led;  
  LED_SFP_GREEN(1)        <= not med2int(9).stat_op(9);  --SFP Link Status
  LED_SFP_RED(1)          <= not (med2int(9).stat_op(10) or med2int(9).stat_op(11));  --SFP RX/TX
gen_led_nogbe : if INCLUDE_GBE = c_NO generate
  LED_SFP_GREEN(0)        <= not med2int(10).stat_op(9);  --SFP Link Status
  LED_SFP_RED(0)          <= not (med2int(10).stat_op(10) or med2int(10).stat_op(11));  --SFP RX/TX
end generate;  
gen_led_gbe : if INCLUDE_GBE = c_YES generate
  LED_SFP_GREEN(0) <= '1';
  LED_SFP_RED(0)   <= '1';
end generate;
---------------------------------------------------------------------------
-- LCD Data to display
---------------------------------------------------------------------------  
  lcd_data(15 downto 0)    <= timer.network_address;
  lcd_data(47 downto 16)   <= timer.microsecond;
  lcd_data(79 downto 48)   <= std_logic_vector(to_unsigned(VERSION_NUMBER_TIME,32));
  lcd_data(91 downto 80)   <= timer.temperature;
  lcd_data(95 downto 92)   <= x"0";
  lcd_data(159 downto 96)  <= mc_unique_id;
  lcd_data(511 downto 160) <= (others => '0');  
  
---------------------------------------------------------------------------
-- Backplane
---------------------------------------------------------------------------  
  BACK_LVDS(0) <= clk_full;
  BACK_LVDS(1) <= TRIG_LEFT;

  RJ_IO(3 downto 2) <= trig_gen_out_i(1 downto 0);  
  
---------------------------------------------------------------------------
-- Test Circuits
---------------------------------------------------------------------------
  process begin
    wait until rising_edge(clk_sys);
    time_counter <= time_counter + 1; 
    if reset_i = '1' then
      time_counter <= (others => '0');
    end if;
  end process;  

  led(0) <= time_counter(26) and time_counter(16);
  led(1) <= not (clear_i or reset_i);
  
  
--   TEST_LINE <= med_stat_debug(15 downto 0);
  TEST_LINE(0) <= med2int(9).stat_op(13);
  TEST_LINE(1) <= med2int(9).stat_op(15);
  TEST_LINE(2) <= clear_i;
  TEST_LINE(3) <= reset_i;
  TEST_LINE(4) <= med2int(9).dataready;
  TEST_LINE(5) <= int2med(9).dataready;
  TEST_LINE(6) <= med2int(7).dataready;
  TEST_LINE(7) <= int2med(7).dataready;
--   TEST_LINE(7) <= med2int(9).stat_op(9);
  
end architecture;



