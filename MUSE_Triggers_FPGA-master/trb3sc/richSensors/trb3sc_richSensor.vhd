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

entity trb3sc_richSensor is
  port(
    CLK_SUPPL_PCLK       : in    std_logic; --125 MHz for GbE
    CLK_CORE_PCLK        : in    std_logic; --Main Oscillator
    CLK_EXT_PLL_LEFT     : in    std_logic; --External Clock
    --CLK_SUPPL_PLL_LEFT   : in    std_logic; --not used
    --CLK_SUPPL_PLL_RIGHT  : in    std_logic; --not used
    --CLK_CORE_PLL_LEFT    : in    std_logic; --not used
    --CLK_CORE_PLL_RIGHT   : in    std_logic; --not used
    --CLK_EXT_PCLK         : in    std_logic; --not used
    --CLK_EXT_PLL_RIGHT    : in    std_logic; --not used
    
    TRIG_LEFT            : in    std_logic; --Trigger Input
    --TRIG_PLL             : in    std_logic; --not used
    --TRIG_RIGHT           : in    std_logic; --not used
    
    --Backplane, all lines
--     BACK_GPIO            : inout std_logic_vector(15 downto 0);
    BACK_LVDS            : inout std_logic_vector( 1 downto 0);
    BACK_3V3             : inout std_logic_vector( 3 downto 0);
    --Backplane for slaves on trbv3scbp1
    BACK_GPIO            : inout std_logic_vector(3 downto 0);
    
    --AddOn Connector
    --to be added
    INP                  : in std_logic_vector(7 downto 0);
    OUTP                 : out std_logic_vector(1 downto 0);
    ONEWIRE 		 : inout std_logic_vector(1 downto 0);
    
    --KEL Connector
    KEL                  : inout std_logic_vector(40 downto 1);
    
    --Additional IO
    HDR_IO               : inout std_logic_vector(10 downto 1);
    RJ_IO                : inout std_logic_vector( 3 downto 0);
    SPARE_IN             : in    std_logic_vector( 1 downto 0);  
    
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
    TEST_LINE            : out std_logic_vector(15 downto 0);
    
    --INTERLOCK
    INTERLOCK_OUT	 : out std_logic;
    INTERLOCK_GND_OUT	 : out std_logic
    );


  attribute syn_useioff                  : boolean;
  attribute syn_useioff of FLASH_CLK  : signal is true;
  attribute syn_useioff of FLASH_CS   : signal is true;
  attribute syn_useioff of FLASH_IN   : signal is true;
  attribute syn_useioff of FLASH_OUT  : signal is true;
  
  attribute syn_useioff of INP        : signal is false;
  attribute syn_useioff of OUTP       : signal is false;
  attribute syn_useioff of ONEWIRE    : signal is false;

  
  --Serdes:                                Backplane
  --Backplane A2,A3,A0,A1                  Slave 3,4,1,2,             A0: TrbNet from backplane
  --AddOn     C2,C3,C0,C1,B0,B1,B2,D1(B3)  Slave --,--,5,9,8,7,6,--
  --SFP       D0,B3(D1)                                               D0: GbE, B3: TrbNet
  
  
end entity;

architecture trb3sc_arch of trb3sc_richSensor is
  attribute syn_keep     : boolean;
  attribute syn_preserve : boolean;
  
  signal clk_sys, clk_full, clk_full_osc   : std_logic;
  signal GSR_N       : std_logic;
  signal reset_i     : std_logic;
  signal clear_i     : std_logic;
  
  signal time_counter      : unsigned(31 downto 0) := (others => '0');
  signal led               : std_logic_vector(1 downto 0);
  signal debug_clock_reset : std_logic_vector(31 downto 0);
  signal debug_tools       : std_logic_vector(31 downto 0);

  --Media Interface
  signal med2int           : med2int_array_t(0 to 0);
  signal int2med           : int2med_array_t(0 to 0);
  signal med_stat_debug    : std_logic_vector (1*64-1  downto 0);
  
  --READOUT
  signal readout_rx        : READOUT_RX;
  signal readout_tx        : readout_tx_array_t(0 to 0);

  signal ctrlbus_rx, bussci_rx, bustools_rx, bustc_rx, busrdo_rx, bus_master_out, busparser_rx, busrelais_rx, businterlock_rx : CTRLBUS_RX;
  signal ctrlbus_tx, bussci_tx, bustools_tx, bustc_tx, busrdo_tx, bus_master_in , busparser_tx, busrelais_tx, businterlock_tx : CTRLBUS_TX;
  
  signal busonewire_rx : ctrlbus_rx_array_t(1 downto 0);
  signal busonewire_tx : ctrlbus_tx_array_t(1 downto 0);
  
  signal common_stat_reg   : std_logic_vector(std_COMSTATREG*32-1 downto 0) := (others => '0');
  signal common_ctrl_reg   : std_logic_vector(std_COMCTRLREG*32-1 downto 0);
  
  signal sed_error_i       : std_logic;
  signal clock_select      : std_logic;
  signal bus_master_active : std_logic;
  
  signal spi_cs, spi_mosi, spi_miso, spi_clk : std_logic_vector(15 downto 0);

  signal timer    : TIMERS;
  signal lcd_data : std_logic_vector(511 downto 0);

  signal sfp_los_i, sfp_txdis_i, sfp_prsnt_i : std_logic;

  type a_t is array(1 to 16) of std_logic_vector(6000 downto 0);
  signal c : a_t;
  attribute syn_keep of c : signal is true;
  attribute syn_preserve of c : signal is true;    
  
  attribute syn_keep of GSR_N     : signal is true;
  attribute syn_preserve of GSR_N : signal is true;  
  attribute syn_keep of bussci_rx     : signal is true;
  attribute syn_preserve of bussci_rx : signal is true;  
  attribute syn_keep of bustools_rx     : signal is true;
  attribute syn_preserve of bustools_rx : signal is true;    
  attribute syn_keep of bustc_rx     : signal is true;
  attribute syn_preserve of bustc_rx : signal is true;   
 
  type state_t is (IDLE, WRITE, FINISH, BUSYEND);
  signal state : state_t;
  signal data_counter, data_amount : unsigned(15 downto 0) := (others => '0');
 
  signal interlock_flag_i  : std_logic_vector(1 downto 0) := "00";
  signal interlock_output  : std_logic;
  signal interlock_limit_i : std_logic_vector(31 downto 0):= x"000001F0";
 
begin

---------------------------------------------------------------------------
-- Clock & Reset Handling
---------------------------------------------------------------------------
THE_CLOCK_RESET :  entity work.clock_reset_handler
  port map(
    INT_CLK_IN      => CLK_CORE_PCLK,
    EXT_CLK_IN      => CLK_EXT_PLL_LEFT,
    NET_CLK_FULL_IN => med2int(0).clk_full,
    NET_CLK_HALF_IN => med2int(0).clk_half,
    RESET_FROM_NET  => med2int(0).stat_op(13),
    
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
      SERDES_NUM    => SERDES_NUM,
      IS_SYNC_SLAVE => c_YES
      )
    port map(
      CLK_REF_FULL       => clk_full_osc, --med2int(0).clk_full,
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
      SD_PRSNT_N_IN  => sfp_prsnt_i,
      SD_LOS_IN      => sfp_los_i,
      SD_TXDIS_OUT   => sfp_txdis_i,
      --Control Interface
      BUS_RX         => bussci_rx,
      BUS_TX         => bussci_tx,
      -- Status and control port
      STAT_DEBUG     => med_stat_debug(63 downto 0),
      CTRL_DEBUG     => open
      );

  SFP_TX_DIS(0) <= '1';
  gen_sfp_con : if SERDES_NUM = 3 generate
    sfp_los_i   <= SFP_LOS(1);
    sfp_prsnt_i <= SFP_MOD0(1); 
    SFP_TX_DIS(1) <= sfp_txdis_i;
  end generate;  
  gen_bpl_con : if SERDES_NUM = 0 generate
    sfp_los_i   <= BACK_GPIO(1);
    sfp_prsnt_i <= BACK_GPIO(1); 
    BACK_GPIO(0) <= sfp_txdis_i;
  end generate;  
  
---------------------------------------------------------------------------
-- Endpoint
---------------------------------------------------------------------------
THE_ENDPOINT : entity work.trb_net16_endpoint_hades_full_handler_record
  generic map (
    ADDRESS_MASK                 => x"FFFF",
    BROADCAST_BITMASK            => x"FF",
    REGIO_INIT_ENDPOINT_ID       => x"0001",
    TIMING_TRIGGER_RAW           => c_YES,
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
    CLK                          => clk_sys,
    RESET                        => reset_i,
    CLK_EN                       => '1',

    --  Media direction port
    MEDIA_MED2INT                => med2int(0),
    MEDIA_INT2MED                => int2med(0),

    --Timing trigger in
    TRG_TIMING_TRG_RECEIVED_IN   => TRIG_LEFT,
    
    READOUT_RX                   => readout_rx,
    READOUT_TX                   => readout_tx,

    --Slow Control Port
    REGIO_COMMON_STAT_REG_IN     => common_stat_reg,  --0x00
    REGIO_COMMON_CTRL_REG_OUT    => common_ctrl_reg,  --0x20
    BUS_RX                       => ctrlbus_rx,
    BUS_TX                       => ctrlbus_tx,
    BUS_MASTER_IN                => bus_master_in,
    BUS_MASTER_OUT               => bus_master_out,
    BUS_MASTER_ACTIVE            => bus_master_active,
    
    ONEWIRE_INOUT                => TEMPSENS,
    --Timing registers
    TIMERS_OUT                   => timer
    );

---------------------------------------------------------------------------
-- Bus Handler
---------------------------------------------------------------------------


  THE_BUS_HANDLER : entity work.trb_net16_regio_bus_handler_record
    generic map(
      PORT_NUMBER      => 9,
      PORT_ADDRESSES   => (0 => x"d000", 1 => x"b000", 2 => x"d300", 3 => x"a000", 4 => x"e100", 5 => x"e110", 6 => x"e000", 7 => x"e200", 8 => x"e120", others => x"0000"),
      PORT_ADDR_MASK   => (0 => 12     , 1 => 9      , 2 => 1      , 3 => 12     , 4 => 4      , 5 => 4      , 6 => 8      , 7 => 4      , 8 => 4      , others => 0),
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
      BUS_RX(3) => busrdo_rx,   --User config
      BUS_RX(4) => busonewire_rx(0),
      BUS_RX(5) => busonewire_rx(1),
      BUS_RX(6) => busparser_rx,
      BUS_RX(7) => busrelais_rx,
      BUS_RX(8) => businterlock_rx,
      BUS_TX(0) => bustools_tx,
      BUS_TX(1) => bussci_tx,
      BUS_TX(2) => bustc_tx,
      BUS_TX(3) => busrdo_tx,
      BUS_TX(4) => busonewire_tx(0),
      BUS_TX(5) => busonewire_tx(1),
      BUS_TX(6) => busparser_tx,
      BUS_TX(7) => busrelais_tx,
      BUS_TX(8) => businterlock_tx,
      
      STAT_DEBUG => open
      );
      
      
---------------------------------------------------------------------------
-- OneWire TempSensor DS18b20
---------------------------------------------------------------------------
  THE_ONEWIRE : entity work.onewire_record
    generic map(
      N_SENSORS  => 10,  -- Number of connected sensors
      ROM_ADDR_0 => x"530416523728FF28",
      ROM_ADDR_1 => x"BB04165233BFFF28",
      ROM_ADDR_2 => x"52031646CD5FFF28",
      ROM_ADDR_3 => x"EC0416525116FF28",
      ROM_ADDR_4 => x"050416523379FF28",
      ROM_ADDR_5 => x"E2041651AEA5FF28",
      ROM_ADDR_6 => x"940000092C3B2F28",
      ROM_ADDR_7 => x"4B0000092D22BD28",
      ROM_ADDR_8 => x"C30000092B07EA28",
      ROM_ADDR_9 => x"780000092A277628"
    )
    port map(
      CLK      => clk_sys,
      RESET    => reset_i,
      READOUT_ENABLE_IN => '1',
      --connection to 1-wire interface
      ONEWIRE  => ONEWIRE(0),
      --INTERLOCK 
      INTERLOCK_FLAG  => interlock_flag_i(0),
      INTERLOCK_LIMIT => interlock_limit_i,
      -- SLOW CONTROL
      BUS_RX   => busonewire_rx(0),
      BUS_TX   => busonewire_tx(0)
    );
    
  THE_ONEWIRE_1 : entity work.onewire_record
    generic map(
      N_SENSORS  => 8,  -- Number of connected sensors
      ROM_ADDR_0 => x"3B0000092C430228",
      ROM_ADDR_1 => x"BB0000092A30D028",
      ROM_ADDR_2 => x"B60000092D9D3C28",
      ROM_ADDR_3 => x"0E0000092C30AF28",
      ROM_ADDR_4 => x"E40000092D682028",
      ROM_ADDR_5 => x"E70000092C430628",
      ROM_ADDR_6 => x"800000092AE74728",
      ROM_ADDR_7 => x"6E0000092AF8EF28"
    )
    port map(
      CLK      => clk_sys,
      RESET    => reset_i,
      READOUT_ENABLE_IN => '1',
      --connection to 1-wire interface
      ONEWIRE  => ONEWIRE(1),
      --INTERLOCK 
      INTERLOCK_FLAG  => interlock_flag_i(1),
      INTERLOCK_LIMIT => interlock_limit_i,
      -- SLOW CONTROL
      BUS_RX   => busonewire_rx(1),
      BUS_TX   => busonewire_tx(1)
    );

    interlock_output <= not or_all(interlock_flag_i);
    INTERLOCK_OUT <= interlock_output;
    INTERLOCK_GND_OUT <= '0';
    
    THE_UART : entity work.uart_mag
      generic map(
        OUTPUTS => 6--,
        --BAUD    => 56200
        )
      port map(
        CLK       => clk_sys,
        RESET     => reset_i,
        UART_RX(0)   => INP(0),--uart_rx,
        UART_RX(1)   => INP(1),--uart_rx,
        UART_RX(2)   => INP(2),--uart_rx,
        UART_RX(3)   => INP(3),--uart_rx,
        UART_RX(4)   => INP(4),--uart_rx,
        UART_RX(5)   => INP(5),--uart_rx,
        UART_TX(0)   => open,--uart_tx, 
        BUS_RX    => busparser_rx,
        BUS_TX    => busparser_tx
        );
        
    THE_UART_relais : entity work.uart_relais
      generic map(
        OUTPUTS => 1,
        BAUD    => 57600
        )
      port map(
        CLK        => clk_sys,
        RESET      => reset_i,
        UART_TX(0) => OUTP(0),--uart_tx, 
        BUS_RX     => busrelais_rx,
        BUS_TX     => busrelais_tx
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
      HEADER_IO   => HDR_IO,
      --LCD
      LCD_DATA_IN => lcd_data,
      --ADC
      ADC_CS      => ADC_CS,
      ADC_MOSI    => ADC_DIN,
      ADC_MISO    => ADC_DOUT,
      ADC_CLK     => ADC_CLK,
      --Trigger & Monitor 
      MONITOR_INPUTS   => KEL(32 downto 1),--(others => '0'),
      TRIG_GEN_INPUTS  => KEL(32 downto 1),--(others => '0'),
      TRIG_GEN_OUTPUTS => BACK_GPIO(3 downto 2),--open,
      --SED
      SED_ERROR_OUT => sed_error_i,
      --Slowcontrol
      BUS_RX     => bustools_rx,
      BUS_TX     => bustools_tx,
      --Control master for default settings
      BUS_MASTER_IN  => bus_master_in,
      BUS_MASTER_OUT => bus_master_out,
      BUS_MASTER_ACTIVE => bus_master_active,      
      DEBUG_OUT  => debug_tools
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
-- I/O
---------------------------------------------------------------------------

  RJ_IO               <= "0000";
  
--   BACK_GPIO           <= (others => 'Z');
  BACK_LVDS           <= (others => '0');
  BACK_3V3            <= (others => 'Z');

  
---------------------------------------------------------------------------
-- LCD Data to display
---------------------------------------------------------------------------  
  lcd_data(15 downto 0)    <= timer.network_address;
  lcd_data(47 downto 16)   <= timer.microsecond;
  lcd_data(79 downto 48)   <= std_logic_vector(to_unsigned(VERSION_NUMBER_TIME,32));
  lcd_data(91 downto 80)   <= timer.temperature;
  lcd_data(95 downto 92)   <= x"0";
  lcd_data(159 downto 96)  <= timer.uid;
  lcd_data(511 downto 160) <= (others => '0');  
  
---------------------------------------------------------------------------
-- LED
---------------------------------------------------------------------------
  --LED are green, orange, red, yellow, white(2), rj_green(2), rj_red(2), sfp_green(2), sfp_red(2)
  LED_GREEN            <= debug_clock_reset(0);   
  LED_ORANGE           <= debug_clock_reset(1);
  LED_RED              <= not sed_error_i;
  LED_YELLOW           <= debug_clock_reset(2);
  LED_WHITE(0)         <= time_counter(26) and time_counter(19);  
  LED_WHITE(1)         <= time_counter(20);
  LED_SFP_GREEN        <= not med2int(0).stat_op(9) & '1';  --SFP Link Status
  LED_SFP_RED          <= not (med2int(0).stat_op(10) or med2int(0).stat_op(11)) & '1';  --SFP RX/TX

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

--   TEST_LINE <= med_stat_debug(15 downto 0);
--   TEST_LINE(15 downto 0) <= debug_clock_reset(15 downto 14) & med2int(0).stat_op(13) & clear_i & reset_i & debug_clock_reset(10 downto 0);  
  TEST_LINE(0) <= med2int(0).stat_op(13);
  TEST_LINE(1) <= med2int(0).stat_op(15);
  TEST_LINE(2) <= clear_i;
  TEST_LINE(3) <= reset_i;
  TEST_LINE(4) <= med2int(0).dataready;
  TEST_LINE(5) <= int2med(0).dataready;
  TEST_LINE(6) <= sfp_txdis_i;
  TEST_LINE(7) <= med2int(0).stat_op(9);
-- readout_tx(0).data_finished <= '1';
-- readout_tx(0).data_write    <= '0';
-- readout_tx(0).busy_release  <= '1';  
--   
  
--   gen_chains : for i in 1 to 16 generate
--     process begin
--       wait until rising_edge(clk_full);
--       c(i)(5000 downto 1) <= c(i)(4999 downto 0);
--       c(i)(0) <= not c(i)(0) or KEL(i);
--       BACK_GPIO(i-1) <= c(i)(5000);
--       if reset_i = '1' then
--         c(i)(5000 downto 0) <= (others => '0');
--       end if;
--     end process;
--   
--   end generate;
    

THE_RDO_STAT : process begin
  wait until rising_edge(clk_sys);
  busrdo_tx.ack <= '0';
  busrdo_tx.nack <= '0';
  busrdo_tx.unknown <= '0';
  
  if busrdo_rx.write = '1' then
    if busrdo_rx.addr = x"0000" then
      busrdo_tx.ack <= '1';
      data_amount <= unsigned(busrdo_rx.data(15 downto 0));
    else
      busrdo_tx.unknown <= '1';
    end if;
  elsif busrdo_rx.read = '1' then
    if busrdo_rx.addr = x"0000" then
      busrdo_tx.ack <= '1';
      busrdo_tx.data(15 downto 0) <= std_logic_vector(data_amount);
    else
      busrdo_tx.unknown <= '1';
    end if;
  end if;
end process;

THE_RDO : process begin
  wait until rising_edge(clk_sys);
  readout_tx(0).busy_release  <= '0';
  readout_tx(0).data_write    <= '0';
  readout_tx(0).data_finished <= '0';
  
  case state is
    when IDLE => 
      if readout_rx.valid_timing_trg = '1' or readout_rx.valid_notiming_trg = '1' then
        state <= WRITE;
      end if;
      if readout_rx.invalid_trg = '1' then
        state <= FINISH;
      end if;
      data_counter <= 0;
    when WRITE =>
      readout_tx(0).data  <= timer.microsecond;
      readout_tx(0).data_write <= '1';
      data_counter <= data_counter + 1;
      if data_counter = data_amount then
        state <= FINISH;
      end if;
    when FINISH =>
      state <= BUSYEND;
      readout_tx(0).data_finished <= '1';
    when BUSYEND =>
      state <= IDLE;
      readout_tx(0).busy_release <= '1';
  end case;
end process;
 
THE_INTERLOCK : process begin

wait until rising_edge(clk_sys);

  businterlock_tx.unknown <= '0';
  businterlock_tx.ack     <= '0';
  businterlock_tx.nack    <= '0';
  businterlock_tx.data    <= (others => '0');
    
  if businterlock_rx.write = '1' then
    if businterlock_rx.addr(3 downto 0) = x"0" then
      interlock_limit_i    <= businterlock_rx.data;
      businterlock_tx.ack  <= '1';
    else
      businterlock_tx.unknown <= '1';
    end if;
  elsif businterlock_rx.read = '1' then
    if businterlock_rx.addr(3 downto 0) = x"0" then
      businterlock_tx.data <= interlock_limit_i;
      businterlock_tx.ack  <= '1';
    elsif businterlock_rx.addr(3 downto 0) = x"1" then
      businterlock_tx.data(0) <= interlock_output;
      businterlock_tx.data(31 downto 1) <= (others => '0');
      businterlock_tx.ack  <= '1';
    else
      businterlock_tx.unknown <= '1';
    end if;
  end if;
  
end process;
 
end architecture;



