library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb3_components.all;
use work.config.all;
use work.version.all;
use work.adc_package.all;

entity trb3_periph_adc is
  port(
    --Clocks
    CLK_GPLL_LEFT        : in    std_logic;  --Clock Manager 1/(2468), 125 MHz
    CLK_GPLL_RIGHT       : in    std_logic;  --Clock Manager 2/(2468), 200 MHz  <-- MAIN CLOCK for FPGA
    CLK_PCLK_LEFT        : in    std_logic;  --Clock Fan-out, 200/400 MHz <-- For TDC. Same oscillator as GPLL right!
    CLK_PCLK_RIGHT       : in    std_logic;  --Clock Fan-out, 200/400 MHz <-- For TDC. Same oscillator as GPLL right!
    --Trigger
    TRIGGER_LEFT         : in    std_logic;  --left side trigger input from fan-out
    TRIGGER_RIGHT        : in    std_logic;  --right side trigger input from fan-out
    --Serdes
    CLK_SERDES_INT_LEFT  : in    std_logic;  --Clock Manager 1/(1357), off, 125 MHz possible
    CLK_SERDES_INT_RIGHT : in    std_logic;  --Clock Manager 2/(1357), 200 MHz, only in case of problems
    SERDES_INT_TX        : out   std_logic_vector(3 downto 0);
    SERDES_INT_RX        : in    std_logic_vector(3 downto 0);
    SERDES_ADDON_TX      : out   std_logic_vector(11 downto 0);
    SERDES_ADDON_RX      : in    std_logic_vector(11 downto 0);
    --Inter-FPGA Communication
    FPGA5_COMM           : inout std_logic_vector(11 downto 0);
                                        --Bit 0/1 input, serial link RX active
                                        --Bit 2/3 output, serial link TX active

    --Connection to AddOn               
    ADC1_CH              : in std_logic_vector(4 downto 0);
    ADC2_CH              : in std_logic_vector(4 downto 0);
    ADC3_CH              : in std_logic_vector(4 downto 0);
    ADC4_CH              : in std_logic_vector(4 downto 0);
    ADC5_CH              : in std_logic_vector(4 downto 0);
    ADC6_CH              : in std_logic_vector(4 downto 0);
    ADC7_CH              : in std_logic_vector(4 downto 0);
    ADC8_CH              : in std_logic_vector(4 downto 0);
    ADC9_CH              : in std_logic_vector(4 downto 0);
    ADC10_CH             : in std_logic_vector(4 downto 0);
    ADC11_CH             : in std_logic_vector(4 downto 0);
    ADC12_CH             : in std_logic_vector(4 downto 0);
    ADC_DCO              : in std_logic_vector(12 downto 1);

    SPI_ADC_SCK          : out std_logic;
    SPI_ADC_SDIO         : inout std_logic;
    
    LMK_CLK              : out std_logic;
    LMK_DATA             : out std_logic;
    LMK_LE_1             : out std_logic;
    LMK_LE_2             : out std_logic;
    
    P_CLOCK              : out std_logic;
    POWER_ENABLE         : out std_logic;
    
    FPGA_CS              : out std_logic_vector(1 downto 0);
    FPGA_SCK             : out std_logic_vector(1 downto 0);
    FPGA_SDI             : out std_logic_vector(1 downto 0);
    FPGA_SDO             : in  std_logic_vector(1 downto 0);
    
    --Flash ROM & Reboot
    FLASH_CLK  : out   std_logic;
    FLASH_CS   : out   std_logic;
    FLASH_DIN  : out   std_logic;
    FLASH_DOUT : in    std_logic;
    PROGRAMN   : out   std_logic;       --reboot FPGA
    --Misc
    TEMPSENS   : inout std_logic;       --Temperature Sensor
    CODE_LINE  : in    std_logic_vector(1 downto 0);
    LED_GREEN  : out   std_logic;
    LED_ORANGE : out   std_logic;
    LED_RED    : out   std_logic;
    LED_YELLOW : out   std_logic;
    SUPPL      : in    std_logic;       --terminated diff pair, PCLK, Pads
    --Test Connectors
    TEST_LINE  : out   std_logic_vector(15 downto 0)
    );
  attribute syn_useioff                  : boolean;
  --no IO-FF for LEDs relaxes timing constraints
  attribute syn_useioff of LED_GREEN     : signal is false;
  attribute syn_useioff of LED_ORANGE    : signal is false;
  attribute syn_useioff of LED_RED       : signal is false;
  attribute syn_useioff of LED_YELLOW    : signal is false;
  attribute syn_useioff of TEMPSENS      : signal is false;
  attribute syn_useioff of PROGRAMN      : signal is false;
  attribute syn_useioff of CODE_LINE     : signal is false;
  attribute syn_useioff of TRIGGER_LEFT  : signal is false;
  attribute syn_useioff of TRIGGER_RIGHT : signal is false;
  --important signals
  attribute syn_useioff of FLASH_CLK     : signal is true;
  attribute syn_useioff of FLASH_CS      : signal is true;
  attribute syn_useioff of FLASH_DIN     : signal is true;
  attribute syn_useioff of FLASH_DOUT    : signal is true;
  attribute syn_useioff of FPGA5_COMM    : signal is true;
  attribute syn_useioff of TEST_LINE     : signal is true;

  

end entity;


architecture trb3_periph_adc_arch of trb3_periph_adc is

  attribute syn_keep     : boolean;
  attribute syn_preserve : boolean;

  --Clock / Reset
  signal clk_100_i                : std_logic;  --clock for main logic, 100 MHz, via Clock Manager and internal PLL
  signal clk_200_i                : std_logic;  --clock for logic at 200 MHz, via Clock Manager and bypassed PLL
  signal clk_125_i                : std_logic;  -- 125 MHz, via Clock Manager and bypassed PLL
  signal pll_lock                 : std_logic;  --Internal PLL locked. E.g. used to reset all internal logic.
  signal clear_i                  : std_logic;
  signal reset_i                  : std_logic;
  signal GSR_N                    : std_logic;
  attribute syn_keep of GSR_N     : signal is true;
  attribute syn_preserve of GSR_N : signal is true;

  --Media Interface
  signal med2int           : med2int_array_t(0 to 0);
  signal int2med           : int2med_array_t(0 to 0);
  signal med_stat_debug    : std_logic_vector (1*64-1  downto 0);

  --LVL1 channel
  signal timing_trg_received_i  : std_logic;

  --Slow Control channel
  signal common_stat_reg        : std_logic_vector(std_COMSTATREG*32-1 downto 0);
  signal common_ctrl_reg        : std_logic_vector(std_COMCTRLREG*32-1 downto 0);
  signal common_stat_reg_strobe : std_logic_vector(std_COMSTATREG-1 downto 0);
  signal common_ctrl_reg_strobe : std_logic_vector(std_COMCTRLREG-1 downto 0);

  --Timer
  signal global_time         : std_logic_vector(31 downto 0);
  signal local_time          : std_logic_vector(7 downto 0);
  signal time_since_last_trg : std_logic_vector(31 downto 0);
  signal timer_ticks         : std_logic_vector(1 downto 0);

  --SPI to MachXO FPGA (and LMK01010, and ADC SPI) 
  signal spi_cs                    : std_logic_vector(15 downto 0);
  signal spi_sdi, spi_sdo, spi_sck : std_logic;
  signal adcspi_ctrl               : std_logic_vector(7 downto 0);

  signal regio_rx, busadc_rx, busspi_rx, busmem_rx, bussed_rx : CTRLBUS_RX;
  signal regio_tx, busadc_tx, busspi_tx, busmem_tx, bussed_tx : CTRLBUS_TX;
  signal readout_rx : READOUT_RX;
  signal readout_tx : readout_tx_array_t(0 to 11);
  signal timer    : TIMERS;
  signal sed_debug : std_logic_vector(31 downto 0);
  
begin
---------------------------------------------------------------------------
-- Reset Generation
---------------------------------------------------------------------------

  GSR_N <= pll_lock;

  THE_RESET_HANDLER : trb_net_reset_handler
    generic map(
      RESET_DELAY => x"FEEE"
      )
    port map(
      CLEAR_IN      => '0',              -- reset input (high active, async)
      CLEAR_N_IN    => '1',              -- reset input (low active, async)
      CLK_IN        => CLK_PCLK_RIGHT,   -- raw master clock, NOT from PLL/DLL!
      SYSCLK_IN     => clk_100_i,        -- PLL/DLL remastered clock
      PLL_LOCKED_IN => pll_lock,         -- master PLL lock signal (async)
      RESET_IN      => '0',              -- general reset signal (SYSCLK)
      TRB_RESET_IN  => med2int(0).stat_op(13),  -- TRBnet reset signal (SYSCLK)
      CLEAR_OUT     => clear_i,          -- async reset out, USE WITH CARE!
      RESET_OUT     => reset_i,          -- synchronous reset out (SYSCLK)
      DEBUG_OUT     => open
      );


---------------------------------------------------------------------------
-- Clock Handling
---------------------------------------------------------------------------
  THE_MAIN_PLL : pll_in200_out100
    port map(
      CLK   => CLK_PCLK_RIGHT,
      RESET => '0',
      CLKOP => clk_100_i,
      CLKOK => clk_200_i,
      LOCK  => pll_lock
      );



  THE_ADC_REF : entity work.pll_in200_out40
    port map(
      CLK   => CLK_PCLK_RIGHT,
      CLKOP => P_CLOCK,
      LOCK  => open
      );  
  
---------------------------------------------------------------------------
-- The TrbNet media interface (to other FPGA)
---------------------------------------------------------------------------
  THE_MEDIA_UPLINK : trb_net16_med_ecp3_sfp
    generic map(
      SERDES_NUM  => 1,                 --number of serdes in quad
      EXT_CLOCK   => c_NO,              --use internal clock
      USE_200_MHZ => c_YES,             --run on 200 MHz clock
      USE_125_MHZ => c_NO,
      USE_CTC     => c_NO
      )
    port map(
      CLK                => CLK_PCLK_RIGHT,
      SYSCLK             => clk_100_i,
      RESET              => reset_i,
      CLEAR              => clear_i,
      CLK_EN             => '1',
      --Internal Connection
      MED_DATA_IN        => int2med(0).data,
      MED_PACKET_NUM_IN  => int2med(0).packet_num,
      MED_DATAREADY_IN   => int2med(0).dataready,
      MED_READ_OUT       => med2int(0).tx_read,
      MED_DATA_OUT       => med2int(0).data,
      MED_PACKET_NUM_OUT => med2int(0).packet_num,
      MED_DATAREADY_OUT  => med2int(0).dataready,
      MED_READ_IN        => '1',
      REFCLK2CORE_OUT    => open,
      --SFP Connection
      SD_RXD_P_IN        => SERDES_INT_RX(2),
      SD_RXD_N_IN        => SERDES_INT_RX(3),
      SD_TXD_P_OUT       => SERDES_INT_TX(2),
      SD_TXD_N_OUT       => SERDES_INT_TX(3),
      SD_REFCLK_P_IN     => open,
      SD_REFCLK_N_IN     => open,
      SD_PRSNT_N_IN      => FPGA5_COMM(0),
      SD_LOS_IN          => FPGA5_COMM(0),
      SD_TXDIS_OUT       => FPGA5_COMM(2),
      -- Status and control port
      STAT_OP            => med2int(0).stat_op,
      CTRL_OP            => int2med(0).ctrl_op,
      STAT_DEBUG         => med_stat_debug,
      CTRL_DEBUG         => (others => '0')
      );

---------------------------------------------------------------------------
-- Endpoint
---------------------------------------------------------------------------

  THE_ENDPOINT : entity work.trb_net16_endpoint_hades_full_handler_record
    generic map(
      ADDRESS_MASK              => x"FFFF",
      BROADCAST_BITMASK         => x"ff",
      REGIO_USE_VAR_ENDPOINT_ID => c_YES,
      TIMING_TRIGGER_RAW        => c_YES,
      --Configure data handler
      DATA_INTERFACE_NUMBER     => 12,
      DATA_BUFFER_DEPTH         => 10,
      DATA_BUFFER_WIDTH         => 32,
      DATA_BUFFER_FULL_THRESH   => 2**10-511,
      TRG_RELEASE_AFTER_DATA    => c_YES,
      HEADER_BUFFER_DEPTH       => 9,
      HEADER_BUFFER_FULL_THRESH => 2**9-16
      )
  port map(
    CLK                => clk_100_i,
    RESET              => reset_i,
    CLK_EN             => '1',
    --  Media direction port
    MEDIA_MED2INT                => med2int(0),
    MEDIA_INT2MED                => int2med(0),
    --Timing trigger in
    TRG_TIMING_TRG_RECEIVED_IN   => TRIGGER_LEFT,
    READOUT_RX                   => readout_rx,
    READOUT_TX                   => readout_tx,

    --Slow Control Port
    REGIO_COMMON_STAT_REG_IN     => (others => '0'),  --0x00
    REGIO_COMMON_CTRL_REG_OUT    => common_ctrl_reg,  --0x20
    BUS_RX                       => regio_rx,
    BUS_TX                       => regio_tx,
    BUS_MASTER_IN                => open,
    BUS_MASTER_OUT               => open,
    BUS_MASTER_ACTIVE            => '0',   
    ONEWIRE_INOUT                => TEMPSENS,
    REGIO_VAR_ENDPOINT_ID(1 downto 0) => CODE_LINE,
    --Timing registers
    TIMERS_OUT                   => timer

    );


---------------------------------------------------------------------------
-- AddOn
---------------------------------------------------------------------------
gen_reallogic : if USE_DUMMY_READOUT = 0 generate
  THE_ADC : entity work.adc_handler
    generic map(
      IS_TRB3 => 1
      )
    port map(
      CLK        => clk_100_i,
      CLK_ADCRAW => CLK_PCLK_RIGHT,
      CLK_RAW_LEFT => CLK_PCLK_LEFT,
      CLK_RAW_RIGHT=> CLK_PCLK_RIGHT,
      
      ADCCLK_OUT => open, 
      ADC_DATA( 4 downto  0)   => ADC1_CH,
      ADC_DATA( 9 downto  5)   => ADC2_CH,
      ADC_DATA(14 downto 10)   => ADC3_CH,
      ADC_DATA(19 downto 15)   => ADC4_CH,
      ADC_DATA(24 downto 20)   => ADC5_CH,
      ADC_DATA(29 downto 25)   => ADC6_CH,
      ADC_DATA(34 downto 30)   => ADC7_CH,
      ADC_DATA(39 downto 35)   => ADC8_CH,
      ADC_DATA(44 downto 40)   => ADC9_CH,
      ADC_DATA(49 downto 45)   => ADC10_CH,
      ADC_DATA(54 downto 50)   => ADC11_CH,
      ADC_DATA(59 downto 55)   => ADC12_CH,
      ADC_DCO     => ADC_DCO,
      TRIGGER_FLAG_OUT => FPGA5_COMM(7),
      
      TRIGGER_IN  => TRIGGER_LEFT,
      READOUT_RX  => readout_rx,
      READOUT_TX  => readout_tx,
      BUS_RX      => busadc_rx,
      BUS_TX      => busadc_tx,
      
      ADCSPI_CTRL => adcspi_ctrl
      );    
end generate;
    
gen_dummyreadout : if USE_DUMMY_READOUT = 1 generate
  THE_ADC : entity work.adc_slowcontrol_data_buffer
    port map(
      CLK        => clk_100_i,
      CLK_ADCRAW => CLK_PCLK_RIGHT,
      
      ADCCLK_OUT => P_CLOCK,
      ADC_DATA( 4 downto  0)   => ADC1_CH,
      ADC_DATA( 9 downto  5)   => ADC2_CH,
      ADC_DATA(14 downto 10)   => ADC3_CH,
      ADC_DATA(19 downto 15)   => ADC4_CH,
      ADC_DATA(24 downto 20)   => ADC5_CH,
      ADC_DATA(29 downto 25)   => ADC6_CH,
      ADC_DATA(34 downto 30)   => ADC7_CH,
      ADC_DATA(39 downto 35)   => ADC8_CH,
      ADC_DATA(44 downto 40)   => ADC9_CH,
      ADC_DATA(49 downto 45)   => ADC10_CH,
      ADC_DATA(54 downto 50)   => ADC11_CH,
      ADC_DATA(59 downto 55)   => ADC12_CH,
      ADC_DCO     => ADC_DCO,
      
      ADC_CONTROL_OUT => adcspi_ctrl,
      
      BUS_RX      => busadc_rx,
      BUS_TX      => busadc_tx
      );
end generate;

    
---------------------------------------------------------------------------
-- Bus Handler
---------------------------------------------------------------------------
  THE_BUS_HANDLER : entity work.trb_net16_regio_bus_handler_record
    generic map(
      PORT_NUMBER      => 4,
      PORT_ADDRESSES   => (0 => x"d000", 1 => x"d400", 2 => x"a000", 3 => x"d500", others => x"0000"),
      PORT_ADDR_MASK   => (0 => 9,       1 => 5,       2 => 12,      3 => 2,       others => 0),
      PORT_MASK_ENABLE => 1
      )
    port map(
      CLK   => clk_100_i,
      RESET => reset_i,

      REGIO_RX  => regio_rx,
      REGIO_TX  => regio_tx,
      
      BUS_RX(0) => busmem_rx, --Flash
      BUS_RX(1) => busspi_rx, --SPI
      BUS_RX(2) => busadc_rx, --ADC
      BUS_RX(3) => bussed_rx,
      BUS_TX(0) => busmem_tx,
      BUS_TX(1) => busspi_tx,
      BUS_TX(2) => busadc_tx,
      BUS_TX(3) => bussed_tx,
      
      STAT_DEBUG => open
      );


---------------------------------------------------------------------------
-- SPI / Flash
---------------------------------------------------------------------------

THE_SPI_RELOAD : entity work.spi_flash_and_fpga_reload
  port map(
    CLK_IN               => clk_100_i,
    RESET_IN             => reset_i,
    
    BUS_ADDR_IN          => busmem_rx.addr(8 downto 0),
    BUS_READ_IN          => busmem_rx.read,
    BUS_WRITE_IN         => busmem_rx.write,
    BUS_DATAREADY_OUT    => busmem_tx.rack,
    BUS_WRITE_ACK_OUT    => busmem_tx.wack,
    BUS_UNKNOWN_ADDR_OUT => busmem_tx.unknown,
    BUS_NO_MORE_DATA_OUT => busmem_tx.nack,
    BUS_DATA_IN          => busmem_rx.data,
    BUS_DATA_OUT         => busmem_tx.data,
    
    DO_REBOOT_IN         => common_ctrl_reg(15),     
    PROGRAMN             => PROGRAMN,
    
    SPI_CS_OUT           => FLASH_CS,
    SPI_SCK_OUT          => FLASH_CLK,
    SPI_SDO_OUT          => FLASH_DIN,
    SPI_SDI_IN           => FLASH_DOUT
    );

---------------------------------------------------------------------------
-- SED Detection
---------------------------------------------------------------------------
  THE_SED : entity work.sedcheck
    port map(
      CLK       => clk_100_i,
      ERROR_OUT => open,
      BUS_RX    => bussed_rx,
      BUS_TX    => bussed_tx,
      DEBUG     => sed_debug
      );    
    
-------------------------------------------------------------------------------
-- SPI
-------------------------------------------------------------------------------

  FPGA_SPI : spi_ltc2600
    generic map (
      BITS       => 32,
      WAITCYCLES => 15)
    port map (
      CLK_IN         => clk_100_i,
      RESET_IN       => reset_i,
      -- Slave bus
      BUS_READ_IN    => busspi_rx.read,
      BUS_WRITE_IN   => busspi_rx.write,
      BUS_BUSY_OUT   => busspi_tx.nack,
      BUS_ACK_OUT    => busspi_tx.ack,
      BUS_ADDR_IN    => busspi_rx.addr(4 downto 0),
      BUS_DATA_IN    => busspi_rx.data,
      BUS_DATA_OUT   => busspi_tx.data,
      -- SPI connections
      SPI_CS_OUT  => spi_CS,
      SPI_SDI_IN  => spi_SDI,
      SPI_SDO_OUT => spi_SDO,
      SPI_SCK_OUT => spi_SCK,
      SPI_CLR_OUT => open
      );

  -- the bits spi_CS (chip select) determines which SPI device is to be programmed
  -- it is already inverted, such that spi_CS=0xffff when nothing is to be programmed
  -- since the CS of the ADCs can only be controlled via the FPGA,
  -- we multiplex the SDI/O and SCK lines according to CS. This way we can control
  -- when which SPI device should be addressed via software

  FPGA_CS_mux: process (spi_CS(2 downto 0)) is
  begin  -- process FPGA_CS_mux
    case spi_CS(2 downto 0) is
      when b"110"  =>
        FPGA_CS <= b"00";
      when b"101"  =>
        FPGA_CS <= b"01";
      when b"011"  =>
        FPGA_CS <= b"10";        
      when others =>
        FPGA_CS <= b"11";
    end case;
  end process FPGA_CS_mux;
  
  FPGA_SCK(0) <= spi_SCK     when spi_CS(2 downto 0) /= b"111" else '1';
  FPGA_SDI(0) <= spi_SDO     when spi_CS(2 downto 0) /= b"111" else '0';
  spi_SDI     <= FPGA_SDO(0) when spi_CS(2 downto 0) /= b"111" else '0';
  
  SPI_ADC_SCK         <= spi_SCK when spi_CS(3) = '0' else adcspi_ctrl(4);
  SPI_ADC_SDIO        <= spi_SDO when spi_CS(3) = '0' else adcspi_ctrl(5);
  FPGA_SCK(1)         <= '0'     when spi_CS(3) = '0' else adcspi_ctrl(6); --CSB
  
  LMK_CLK             <= spi_SCK when spi_CS(5 downto 4) /= b"11" else '1' ;
  LMK_DATA            <= spi_SDO when spi_CS(5 downto 4) /= b"11" else '0' ;
  LMK_LE_1            <= spi_CS(4); -- active low
  LMK_LE_2            <= spi_CS(5); -- active low
  
  POWER_ENABLE        <= adcspi_ctrl(0);
---------------------------------------------------------------------------
-- LED
---------------------------------------------------------------------------
LED_GREEN  <= not med2int(0).stat_op(9);
LED_ORANGE <= not med2int(0).stat_op(10);
LED_RED    <= '1';
LED_YELLOW <= not med2int(0).stat_op(11);

---------------------------------------------------------------------------
-- Test Connector - Logic Analyser
---------------------------------------------------------------------------

  TEST_LINE <= sed_debug(28 downto 24) & sed_debug(10 downto 0);

end architecture;
