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

entity trb3sc_hubaddon is
  port(
    CLK_SUPPL_PCLK       : in    std_logic; --125 MHz for GbE
    CLK_CORE_PCLK        : in    std_logic; --Main Oscillator
    CLK_EXT_PLL_LEFT     : in    std_logic; --External Clock

    --Additional IO
    HDR_IO               : inout std_logic_vector(10 downto 1);
--     RJ_IO                : inout std_logic_vector( 3 downto 0);
--     SPARE_IN             : in    std_logic_vector( 1 downto 0);  
    
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

    LED_HUB_LINKOK       : out   std_logic_vector(6 downto 1);
    LED_HUB_RX           : out   std_logic_vector(6 downto 1);
    LED_HUB_TX           : out   std_logic_vector(6 downto 1);
    HUB_MOD0             : in    std_logic_vector(6 downto 1);
    HUB_MOD1             : inout std_logic_vector(6 downto 1);
    HUB_MOD2             : inout std_logic_vector(6 downto 1);
    HUB_TXDIS            : out   std_logic_vector(6 downto 1);
    HUB_LOS              : in    std_logic_vector(6 downto 1);
    
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

  
  --Serdes:                                Backplane
  --Backplane A2,A3,A0,A1                  Slave 3,4,1,2,             A0: TrbNet from backplane
  --AddOn     C2,C3,C0,C1,B0,B1,B2,D1(B3)  Slave --,--,5,9,8,7,6,--
  --SFP       D0,B3(D1)                                               D0: GbE, B3: TrbNet
  
  
end entity;

architecture trb3sc_arch of trb3sc_hubaddon is
  attribute syn_keep     : boolean;
  attribute syn_preserve : boolean;
  
  signal clk_sys, clk_full, clk_full_osc   : std_logic;
  signal GSR_N       : std_logic;
  signal reset_i     : std_logic;
  signal clear_i     : std_logic;
  
  signal time_counter      : unsigned(31 downto 0) := (others => '0');
  signal led               : std_logic_vector(1 downto 0);
  signal debug_clock_reset : std_logic_vector(31 downto 0);

  --Media Interface
  signal med2int           : med2int_array_t(0 to 4);
  signal int2med           : int2med_array_t(0 to 4);
  signal med_stat_debug    : std_logic_vector (1*64-1  downto 0);
  
  signal ctrlbus_rx, bussci_rx, bussci2_rx, bustools_rx, bustc_rx  : CTRLBUS_RX;
  signal ctrlbus_tx, bussci_tx, bussci2_tx, bustools_tx, bustc_tx  : CTRLBUS_TX;
  
  signal common_stat_reg         : std_logic_vector(std_COMSTATREG*32-1 downto 0) := (others => '0');
  signal common_ctrl_reg         : std_logic_vector(std_COMCTRLREG*32-1 downto 0);
  
  signal sed_error_i    : std_logic;
  
  signal spi_cs, spi_mosi, spi_miso, spi_clk : std_logic_vector(15 downto 0);

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
  signal reset_via_gbe : std_logic;
  
  attribute syn_keep of GSR_N     : signal is true;
  attribute syn_preserve of GSR_N : signal is true;  
  attribute syn_keep of bussci_rx     : signal is true;
  attribute syn_preserve of bussci_rx : signal is true;  
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
    NET_CLK_FULL_IN => med2int(4).clk_full,
    NET_CLK_HALF_IN => med2int(4).clk_half,
    RESET_FROM_NET  => med2int(4).stat_op(13),
    
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


---------------------------------------------------------------------------
-- TrbNet Uplink
---------------------------------------------------------------------------
THE_MEDIA_INTERFACE : entity work.med_ecp3_sfp_sync
  generic map(
    SERDES_NUM  => 3,
    IS_SYNC_SLAVE   => c_YES
    )
  port map(
    CLK_REF_FULL       => clk_full_osc, --med2int(0).clk_full,
    CLK_INTERNAL_FULL  => clk_full_osc,
    SYSCLK             => clk_sys,
    RESET              => reset_i,
    CLEAR              => clear_i,
    --Internal Connection
    MEDIA_MED2INT      => med2int(4),
    MEDIA_INT2MED      => int2med(4),

    --Sync operation
    RX_DLM             => open,
    RX_DLM_WORD        => open,
    TX_DLM             => open,
    TX_DLM_WORD        => open,
    
    --SFP Connection
    SD_PRSNT_N_IN      => SFP_MOD0(1),
    SD_LOS_IN          => SFP_LOS(1),
    SD_TXDIS_OUT       => SFP_TX_DIS(1),
    --Control Interface
    BUS_RX             => bussci_rx,
    BUS_TX             => bussci_tx,
    -- Status and control port
    STAT_DEBUG         => open,
    CTRL_DEBUG         => open
  );

SFP_TX_DIS(0) <= '1';

---------------------------------------------------------------------------
-- TrbNet Downlink
---------------------------------------------------------------------------
THE_MEDIA_4_DOWN : entity work.med_ecp3_sfp_sync_4
  generic map(
    IS_SYNC_SLAVE   => (c_NO, c_NO, c_NO, c_NO),
    IS_USED         => (c_YES,c_YES ,c_YES ,c_YES)
    )
  port map(
    CLK_REF_FULL       => clk_full_osc, --med2int(0).clk_full,
    CLK_INTERNAL_FULL  => clk_full_osc,
    SYSCLK        => clk_sys,
    RESET              => reset_i,
    CLEAR              => clear_i,
    
    --Internal Connection
    MEDIA_MED2INT(0 to 1) => med2int(2 to 3),
    MEDIA_MED2INT(2 to 3) => med2int(0 to 1),
    MEDIA_INT2MED(0 to 1) => int2med(2 to 3),
    MEDIA_INT2MED(2 to 3) => int2med(0 to 1),

    --Sync operation
    RX_DLM             => open,
    RX_DLM_WORD        => open,
    TX_DLM             => open,
    TX_DLM_WORD        => open,
    
    --SFP Connection
    SD_PRSNT_N_IN(3 downto 2) => HUB_MOD0(2 downto 1),
    SD_PRSNT_N_IN(1 downto 0) => HUB_MOD0(4 downto 3),
    SD_LOS_IN(3 downto 2)     => HUB_LOS(2 downto 1),
    SD_LOS_IN(1 downto 0)     => HUB_LOS(4 downto 3),
    SD_TXDIS_OUT(3 downto 2)  => HUB_TXDIS(2 downto 1),
    SD_TXDIS_OUT(1 downto 0)  => HUB_TXDIS(4 downto 3),
    
    --Control Interface
    BUS_RX             => bussci2_rx,
    BUS_TX             => bussci2_tx,

    -- Status and control port
    STAT_DEBUG         => med_stat_debug(63 downto 0),
    CTRL_DEBUG         => open
   );

   HUB_TXDIS(6 downto 5) <= "11";
---------------------------------------------------------------------------
-- GbE
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- Hub
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
    
    --Event information coming from CTSCTS_READOUT_TYPE_OUT
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
    EXTERNAL_SEND_RESET     => reset_via_gbe,
    
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
    GSC_REPLY_READ_IN            => '1', --gsc_reply_read,
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


---------------------------------------------------------------------------
-- Bus Handler
---------------------------------------------------------------------------
  THE_BUS_HANDLER : entity work.trb_net16_regio_bus_handler_record
    generic map(
      PORT_NUMBER      => 4,
      PORT_ADDRESSES   => (0 => x"d000", 1 => x"b000", 2 => x"d300", 3 => x"b200", others => x"0000"),
      PORT_ADDR_MASK   => (0 => 12,      1 => 9,       2 => 1,       3 => 9,       others => 0),
      PORT_MASK_ENABLE => 1
      )
    port map(
      CLK   => clk_sys,
      RESET => reset_i,

      REGIO_RX  => ctrlbus_rx,
      REGIO_TX  => ctrlbus_tx,
      
      BUS_RX(0) => bustools_rx, --Flash, SPI, UART, ADC, SED
      BUS_RX(1) => bussci_rx,   --SCI Serdes
      BUS_RX(2) => bustc_rx,    --Clock switch
      BUS_RX(3) => bussci2_rx,
      BUS_TX(0) => bustools_tx,
      BUS_TX(1) => bussci_tx,
      BUS_TX(2) => bustc_tx,
      BUS_TX(3) => bussci2_tx,
      STAT_DEBUG => open
      );

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
      REBOOT_IN   => common_ctrl_reg(15),
      --SPI
      SPI_CS_OUT  => spi_cs,  
      SPI_MOSI_OUT=> spi_mosi,
      SPI_MISO_IN => spi_miso,
      SPI_CLK_OUT => spi_clk,
      --Header
      HEADER_IO     => HDR_IO,
      --LCD
      LCD_DATA_IN   => lcd_data,
      --ADC
      ADC_CS      => ADC_CS,
      ADC_MOSI    => ADC_DIN,
      ADC_MISO    => ADC_DOUT,
      ADC_CLK     => ADC_CLK,
      --SED
      SED_ERROR_OUT => sed_error_i,
      --Slowcontrol
      BUS_RX     => bustools_rx,
      BUS_TX     => bustools_tx,
      
      DEBUG_OUT  => open
      );

---------------------------------------------------------------------------
-- Switches
---------------------------------------------------------------------------
--Serdes Select
  PCSSW_ENSMB <= '0';
  PCSSW_EQ    <= x"0";
  PCSSW_PE    <= x"F";
  PCSSW       <= "01001110"; --SFP2 on B3, AddOn on D1

---------------------------------------------------------------------------
-- LCD Data to display
---------------------------------------------------------------------------  
  lcd_data(15 downto 0)   <= timer.network_address;
  lcd_data(47 downto 16)  <= timer.microsecond;
  lcd_data(79 downto 48)  <= std_logic_vector(to_unsigned(VERSION_NUMBER_TIME, 32));
  lcd_data(511 downto 80) <= (others => '0');  
  
---------------------------------------------------------------------------
-- LED
---------------------------------------------------------------------------
  --LED are green, orange, red, yellow, white(2), rj_green(2), rj_red(2), sfp_green(2), sfp_red(2)
  LED_GREEN            <= debug_clock_reset(0);   
  LED_ORANGE           <= debug_clock_reset(1);
  LED_RED              <= not sed_error_i;
  LED_YELLOW           <= debug_clock_reset(2);
  LED_WHITE            <= led;  
  LED_SFP_GREEN        <= not med2int(4).stat_op(9) & '1';  --SFP Link Status
  LED_SFP_RED          <= not (med2int(4).stat_op(10) or med2int(4).stat_op(11)) & '1';  --SFP RX/TX
  
  LED_HUB_LINKOK(1) <= not  med2int(0).stat_op(9);
  LED_HUB_TX(1)     <= not (med2int(0).stat_op(10)); -- or med2int(0).stat_op(11));
  LED_HUB_RX(1)     <= not  med2int(0).stat_op(11);
  LED_HUB_LINKOK(2) <= not  med2int(1).stat_op(9);
  LED_HUB_TX(2)     <= not (med2int(1).stat_op(10)); -- or med2int(1).stat_op(11));
  LED_HUB_RX(2)     <= not  med2int(1).stat_op(11);
  LED_HUB_LINKOK(3) <= not  med2int(2).stat_op(9);
  LED_HUB_TX(3)     <= not (med2int(2).stat_op(10)); -- or med2int(2).stat_op(11));
  LED_HUB_RX(3)     <= not  med2int(2).stat_op(11);
  LED_HUB_LINKOK(4) <= not  med2int(3).stat_op(9);
  LED_HUB_TX(4)     <= not (med2int(3).stat_op(10)); -- or med2int(3).stat_op(11));
  LED_HUB_RX(4)     <= not  med2int(3).stat_op(11);
  
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
  led(1) <= not reset_i;
  
  
  TEST_LINE <= med_stat_debug(15 downto 0);
  
end architecture;



