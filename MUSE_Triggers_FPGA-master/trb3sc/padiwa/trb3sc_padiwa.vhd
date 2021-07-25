library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.version.all;
use work.config.all;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb3_components.all;
use work.tdc_components.all;
use work.trb_net16_hub_func.all;
use work.version.all;
use work.trb_net_gbe_components.all;
use work.med_sync_define.all;

entity trb3sc_padiwa is
  port(
    CLK_SUPPL_PCLK   : in std_logic;    --125 MHz for GbE
    CLK_CORE_PCLK    : in std_logic;    --Main Oscillator
    CLK_EXT_PLL_LEFT : in std_logic;    --External Clock
    --CLK_SUPPL_PLL_LEFT   : in    std_logic; --not used
    --CLK_SUPPL_PLL_RIGHT  : in    std_logic; --not used
    --CLK_CORE_PLL_LEFT    : in    std_logic; --not used
    --CLK_CORE_PLL_RIGHT   : in    std_logic; --not used
    --CLK_EXT_PCLK         : in    std_logic; --not used
    --CLK_EXT_PLL_RIGHT    : in    std_logic; --not used

    TRIG_LEFT : in std_logic;           --Trigger Input
    --TRIG_PLL             : in    std_logic; --not used
    --TRIG_RIGHT           : in    std_logic; --not used

    --Backplane for slaves on trbv3scbp1
    BACK_GPIO            : inout std_logic_vector(3 downto 0);

    --AddOn Connector
    INP      : in    std_logic_vector(95 downto 0);
    OUT_SDO  : out   std_logic_vector(6 downto 1);
    OUT_SCK  : out   std_logic_vector(6 downto 1);
    OUT_CS   : out   std_logic_vector(6 downto 1);
    IN_SDI   : in    std_logic_vector(6 downto 1);
    
    --Additional IO
    HDR_IO   : inout std_logic_vector(10 downto 1);
    RJ_IO    : inout std_logic_vector(3 downto 0);
    SPARE_IN : in    std_logic_vector(1 downto 0);

    --LED
    LED_GREEN     : out std_logic;
    LED_YELLOW    : out std_logic;
    LED_ORANGE    : out std_logic;
    LED_RED       : out std_logic;
    LED_RJ_GREEN  : out std_logic_vector(1 downto 0);
    LED_RJ_RED    : out std_logic_vector(1 downto 0);
    LED_WHITE     : out std_logic_vector(1 downto 0);
    LED_SFP_GREEN : out std_logic_vector(1 downto 0);
    LED_SFP_RED   : out std_logic_vector(1 downto 0);

    --SFP
    SFP_LOS    : in    std_logic_vector(1 downto 0);
    SFP_MOD0   : in    std_logic_vector(1 downto 0);
    SFP_MOD1   : inout std_logic_vector(1 downto 0) := (others => 'Z');
    SFP_MOD2   : inout std_logic_vector(1 downto 0) := (others => 'Z');
    SFP_TX_DIS : out   std_logic_vector(1 downto 0) := (others => '0');

    --Serdes switch
    PCSSW_ENSMB : out std_logic;
    PCSSW_EQ    : out std_logic_vector(3 downto 0);
    PCSSW_PE    : out std_logic_vector(3 downto 0);
    PCSSW       : out std_logic_vector(7 downto 0);

    --ADC
    ADC_CLK  : out std_logic;
    ADC_CS   : out std_logic;
    ADC_DIN  : out std_logic;
    ADC_DOUT : in  std_logic;

    --Flash, 1-wire, Reload
    FLASH_CLK      : out   std_logic;
    FLASH_CS       : out   std_logic;
    FLASH_IN       : out   std_logic;
    FLASH_OUT      : in    std_logic;
    PROGRAMN       : out   std_logic;
    ENPIRION_CLOCK : out   std_logic;
    TEMPSENS       : inout std_logic;

    --Test Connectors
    TEST_LINE : out std_logic_vector(15 downto 0)
    );


  attribute syn_useioff              : boolean;
  attribute syn_useioff of FLASH_CLK : signal is true;
  attribute syn_useioff of FLASH_CS  : signal is true;
  attribute syn_useioff of FLASH_IN  : signal is true;
  attribute syn_useioff of FLASH_OUT : signal is true;


  --Serdes:                                Backplane
  --Backplane A2,A3,A0,A1                  Slave 3,4,1,2,             A0: TrbNet from backplane
  --AddOn     C2,C3,C0,C1,B0,B1,B2,D1(B3)  Slave --,--,5,9,8,7,6,--
  --SFP       D0,B3(D1)                                               D0: GbE, B3: TrbNet
  
  
end entity;

architecture trb3sc_arch of trb3sc_padiwa is
  attribute syn_keep     : boolean;
  attribute syn_preserve : boolean;

  signal clk_sys, clk_full, clk_full_osc, clk_cal : std_logic;
  signal GSR_N                                    : std_logic;
  signal reset_i                                  : std_logic;
  signal clear_i                                  : std_logic;

  signal time_counter      : unsigned(31 downto 0) := (others => '0');
  signal led               : std_logic_vector(1 downto 0);
  signal debug_clock_reset : std_logic_vector(31 downto 0);

  --Media Interface
  signal med2int        : med2int_array_t(0 to 0);
  signal int2med        : int2med_array_t(0 to 0);
  signal med_stat_debug : std_logic_vector (1*64-1 downto 0);

  --READOUT
  signal readout_rx : READOUT_RX;
  signal readout_tx : readout_tx_array_t(0 to 0);

  signal ctrlbus_rx, bussci_rx, bustools_rx, bustc_rx, bustdc_rx, bus_master_out, handlerbus_rx : CTRLBUS_RX;
  signal ctrlbus_tx, bussci_tx, bustools_tx, bustc_tx, bustdc_tx, bus_master_in : CTRLBUS_TX;
  
  signal bus_master_active : std_logic;
  
  signal common_stat_reg : std_logic_vector(std_COMSTATREG*32-1 downto 0) := (others => '0');
  signal common_ctrl_reg : std_logic_vector(std_COMCTRLREG*32-1 downto 0);

  signal sed_error_i  : std_logic;
  signal clock_select : std_logic;

  signal spi_cs, spi_mosi, spi_miso, spi_clk : std_logic_vector(15 downto 0);

  signal timer    : TIMERS;
  signal lcd_data : std_logic_vector(511 downto 0);
  signal trig_gen_out_i : std_logic_vector(3 downto 0);
  --TDC
  signal hit_in_i         : std_logic_vector(64 downto 1);
  signal logic_analyser_i : std_logic_vector(15 downto 0);

  attribute syn_keep of GSR_N           : signal is true;
  attribute syn_preserve of GSR_N       : signal is true;
  attribute syn_keep of bussci_rx       : signal is true;
  attribute syn_preserve of bussci_rx   : signal is true;
  attribute syn_keep of bustools_rx     : signal is true;
  attribute syn_preserve of bustools_rx : signal is true;
  attribute syn_keep of bustc_rx        : signal is true;
  attribute syn_preserve of bustc_rx    : signal is true;
  
begin

---------------------------------------------------------------------------
-- Clock & Reset Handling
---------------------------------------------------------------------------
  THE_CLOCK_RESET : entity work.clock_reset_handler
    port map(
      INT_CLK_IN      => CLK_CORE_PCLK,
      EXT_CLK_IN      => CLK_EXT_PLL_LEFT,
      NET_CLK_FULL_IN => med2int(0).clk_full,
      NET_CLK_HALF_IN => med2int(0).clk_half,
      RESET_FROM_NET  => med2int(0).stat_op(13),

      BUS_RX => bustc_rx,
      BUS_TX => bustc_tx,

      RESET_OUT => reset_i,
      CLEAR_OUT => clear_i,
      GSR_OUT   => GSR_N,

      FULL_CLK_OUT => clk_full,
      SYS_CLK_OUT  => clk_sys,
      REF_CLK_OUT  => clk_full_osc,

      ENPIRION_CLOCK => ENPIRION_CLOCK,
      LED_RED_OUT    => LED_RJ_RED,
      LED_GREEN_OUT  => LED_RJ_GREEN,
      DEBUG_OUT      => debug_clock_reset
      );

  pll_calibration : entity work.pll_in125_out33
    port map (
      CLK   => CLK_SUPPL_PCLK,
      CLKOP => clk_cal,
      LOCK  => open);

---------------------------------------------------------------------------
-- TrbNet Uplink
---------------------------------------------------------------------------

  THE_MEDIA_INTERFACE : entity work.med_ecp3_sfp_sync
    generic map(
      SERDES_NUM    => 3,
      IS_SYNC_SLAVE => c_YES
      )
    port map(
      CLK_REF_FULL       => med2int(0).clk_full,
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
      BUS_RX         => bussci_rx,
      BUS_TX         => bussci_tx,
      -- Status and control port
      STAT_DEBUG     => med_stat_debug(63 downto 0),
      CTRL_DEBUG     => open
      );

  SFP_TX_DIS(0) <= '1';

---------------------------------------------------------------------------
-- Endpoint
---------------------------------------------------------------------------
  THE_ENDPOINT : entity work.trb_net16_endpoint_hades_full_handler_record
    generic map (
      ADDRESS_MASK              => x"FFFF",
      BROADCAST_BITMASK         => x"FF",
      REGIO_INIT_ENDPOINT_ID    => x"0001",
      TIMING_TRIGGER_RAW        => c_YES,
      --Configure data handler
      DATA_INTERFACE_NUMBER     => 1,
      DATA_BUFFER_DEPTH         => EVENT_BUFFER_SIZE,
      DATA_BUFFER_WIDTH         => 32,
      DATA_BUFFER_FULL_THRESH   => 2**EVENT_BUFFER_SIZE-EVENT_MAX_SIZE,
      TRG_RELEASE_AFTER_DATA    => c_YES,
      HEADER_BUFFER_DEPTH       => 9,
      HEADER_BUFFER_FULL_THRESH => 2**8
      )

    port map(
      --  Misc
      CLK    => clk_sys,
      RESET  => reset_i,
      CLK_EN => '1',

      --  Media direction port
      MEDIA_MED2INT => med2int(0),
      MEDIA_INT2MED => int2med(0),

      --Timing trigger in
      TRG_TIMING_TRG_RECEIVED_IN => TRIG_LEFT,

      READOUT_RX => readout_rx,
      READOUT_TX => readout_tx,

      --Slow Control Port
      REGIO_COMMON_STAT_REG_IN  => common_stat_reg,  --0x00
      REGIO_COMMON_CTRL_REG_OUT => common_ctrl_reg,  --0x20
      BUS_RX                    => ctrlbus_rx,
      BUS_TX                    => ctrlbus_tx,
      ONEWIRE_INOUT             => TEMPSENS,
      --Timing registers
      TIMERS_OUT                => timer
      );

      

---------------------------------------------------------------------------
-- Bus Handler
---------------------------------------------------------------------------
  THE_BUS_HANDLER : entity work.trb_net16_regio_bus_handler_record
    generic map(
      PORT_NUMBER      => 4,
      PORT_ADDRESSES   => (0 => x"d000", 1 => x"b000", 2 => x"d300", 3 => x"c000", others => x"0000"),
      PORT_ADDR_MASK   => (0 => 12, 1 => 9, 2 => 1, 3 => 12, others => 0),
      PORT_MASK_ENABLE => 1
      )
    port map(
      CLK   => clk_sys,
      RESET => reset_i,

      REGIO_RX => handlerbus_rx,
      REGIO_TX => ctrlbus_tx,

      BUS_RX(0) => bustools_rx,         --Flash, SPI, UART, ADC, SED
      BUS_RX(1) => bussci_rx,           --SCI Serdes
      BUS_RX(2) => bustc_rx,            --Clock switch
      BUS_RX(3) => bustdc_rx,           --TDC config
      BUS_TX(0) => bustools_tx,
      BUS_TX(1) => bussci_tx,
      BUS_TX(2) => bustc_tx,
      BUS_TX(3) => bustdc_tx,

      STAT_DEBUG => open
      );

  handlerbus_rx <= ctrlbus_rx when bus_master_active = '0' else bus_master_out;      
      
---------------------------------------------------------------------------
-- Control Tools
---------------------------------------------------------------------------
  THE_TOOLS : entity work.trb3sc_tools
    port map(
      CLK   => clk_sys,
      RESET => reset_i,

      --Flash & Reload
      FLASH_CS      => FLASH_CS,
      FLASH_CLK     => FLASH_CLK,
      FLASH_IN      => FLASH_OUT,
      FLASH_OUT     => FLASH_IN,
      PROGRAMN      => PROGRAMN,
      REBOOT_IN     => common_ctrl_reg(15),
      --SPI
      SPI_CS_OUT    => spi_cs,
      SPI_MOSI_OUT  => spi_mosi,
      SPI_MISO_IN   => spi_miso,
      SPI_CLK_OUT   => spi_clk,
      --Header
      HEADER_IO     => HDR_IO,
      --LCD
      LCD_DATA_IN   => lcd_data,
      --ADC
      ADC_CS        => ADC_CS,
      ADC_MOSI      => ADC_DIN,
      ADC_MISO      => ADC_DOUT,
      ADC_CLK       => ADC_CLK,
      --Trigger & Monitor 
      MONITOR_INPUTS(31 downto 0) => INP(31 downto 0),
      TRIG_GEN_INPUTS  => INP(31 downto 0),
      TRIG_GEN_OUTPUTS => trig_gen_out_i,
      --SED
      SED_ERROR_OUT => sed_error_i,
      --Slowcontrol
      BUS_RX        => bustools_rx,
      BUS_TX        => bustools_tx,
      --Control master for default settings
      BUS_MASTER_IN  => ctrlbus_tx,
      BUS_MASTER_OUT => bus_master_out,
      BUS_MASTER_ACTIVE => bus_master_active,    
      
      DEBUG_OUT => open
      );

---------------------------------------------------------------------------
-- Switches
---------------------------------------------------------------------------
--Serdes Select
  PCSSW_ENSMB <= '0';
  PCSSW_EQ    <= x"0";
  PCSSW_PE    <= x"F";
  PCSSW       <= "01001110";            --SFP2 on B3, AddOn on D1

---------------------------------------------------------------------------
-- I/O
---------------------------------------------------------------------------

  RJ_IO(3 downto 2) <= trig_gen_out_i(1 downto 0);
  

  BACK_GPIO(1 downto 0)  <= (others => 'Z');
  BACK_GPIO(3 downto 2)  <= trig_gen_out_i(3 downto 2);

--   BACK_GPIO <= (others => 'Z');
--   BACK_LVDS <= (others => '0');
--   BACK_3V3  <= (others => 'Z');

  OUT_CS  <= spi_cs(5 downto 0);
  OUT_SCK <= spi_clk(5 downto 0);
  OUT_SDO <= spi_mosi(5 downto 0);
  spi_miso(5 downto 0) <= IN_SDI;
  
---------------------------------------------------------------------------
-- LCD Data to display
---------------------------------------------------------------------------  
  lcd_data(15 downto 0)   <= timer.network_address;
  lcd_data(47 downto 16)  <= timer.microsecond;
  lcd_data(79 downto 48)  <= std_logic_vector(to_unsigned(VERSION_NUMBER_TIME, 32));
  lcd_data(91 downto 80)  <= timer.temperature;  
  lcd_data(511 downto 92) <= (others => '0');

---------------------------------------------------------------------------
-- LED
---------------------------------------------------------------------------
  --LED are green, orange, red, yellow, white(2), rj_green(2), rj_red(2), sfp_green(2), sfp_red(2)
  LED_GREEN     <= debug_clock_reset(0);
  LED_ORANGE    <= debug_clock_reset(1);
  LED_RED       <= not sed_error_i;
  LED_YELLOW    <= debug_clock_reset(2);
  LED_WHITE(0)  <= time_counter(26) and time_counter(19);
  LED_WHITE(1)  <= time_counter(20);
  LED_SFP_GREEN <= not med2int(0).stat_op(9) & '1';  --SFP Link Status
  LED_SFP_RED   <= not (med2int(0).stat_op(10) or med2int(0).stat_op(11)) & '1';  --SFP RX/TX

---------------------------------------------------------------------------
-- Test Circuits
---------------------------------------------------------------------------
  process
  begin
    wait until rising_edge(clk_sys);
    time_counter <= time_counter + 1;
    if reset_i = '1' then
      time_counter <= (others => '0');
    end if;
  end process;



-------------------------------------------------------------------------------
-- TDC
-------------------------------------------------------------------------------
  THE_TDC : TDC_record
    generic map (
      CHANNEL_NUMBER => NUM_TDC_CHANNELS,  -- Number of TDC channels per module
      STATUS_REG_NR  => 21,             -- Number of status regs
      DEBUG          => c_YES,
      SIMULATION     => c_NO)
    port map (
      RESET          => reset_i,
      CLK_TDC        => clk_full_osc,   
      CLK_READOUT    => clk_sys,        -- Clock for the readout
      REFERENCE_TIME => TRIG_LEFT,      -- Reference time input
      HIT_IN         => hit_in_i(NUM_TDC_CHANNELS-1 downto 1),  -- Channel start signals
      HIT_CAL_IN     => clk_cal,        -- Hits for calibrating the TDC
      -- Trigger signals from handler
      READOUT_RX     => readout_rx,
      READOUT_TX     => readout_tx(0),
      --
      LOGIC_ANALYSER_OUT => logic_analyser_i,
      BUS_RX             => bustdc_rx,
      BUS_TX             => bustdc_tx
      );

  -- For single edge measurements
  gen_single : if DOUBLE_EDGE_TYPE = 0 or DOUBLE_EDGE_TYPE = 1 or DOUBLE_EDGE_TYPE = 3 generate
    hit_in_i(40 downto 1) <= INP(40 downto 1);
  end generate;

  -- For ToT Measurements
  gen_double : if DOUBLE_EDGE_TYPE = 2 generate
    Gen_Hit_In_Signals : for i in 1 to 20 generate
      hit_in_i(i*2-1) <= INP(i);
      hit_in_i(i*2)   <= not INP(i);
    end generate Gen_Hit_In_Signals;
  end generate;


  
end architecture;



