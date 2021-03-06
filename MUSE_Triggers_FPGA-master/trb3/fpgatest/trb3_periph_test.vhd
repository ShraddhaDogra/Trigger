library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb3_components.all;
use work.version.all;
use work.config.all;



entity trb3_periph_test is
  port(
    --Clocks
    CLK_GPLL_LEFT                  : in  std_logic;  --Clock Manager 1/(2468), 125 MHz
    CLK_GPLL_RIGHT                 : in  std_logic;  --Clock Manager 2/(2468), 200 MHz  <-- MAIN CLOCK for FPGA
    CLK_PCLK_LEFT                  : in  std_logic;  --Clock Fan-out, 200/400 MHz <-- For TDC. Same oscillator as GPLL right!
    CLK_PCLK_RIGHT                 : in  std_logic;  --Clock Fan-out, 200/400 MHz <-- For TDC. Same oscillator as GPLL right!

    --Trigger
    TRIGGER_LEFT                   : in  std_logic;  --left side trigger input from fan-out
    TRIGGER_RIGHT                  : in  std_logic;  --right side trigger input from fan-out
    
    --Serdes
    CLK_SERDES_INT_LEFT            : in  std_logic;  --Clock Manager 1/(1357), off, 125 MHz possible
    CLK_SERDES_INT_RIGHT           : in  std_logic;  --Clock Manager 2/(1357), 200 MHz, only in case of problems
    SERDES_INT_TX                  : out std_logic_vector(3 downto 0);
    SERDES_INT_RX                  : in  std_logic_vector(3 downto 0);
    SERDES_ADDON_TX                : out std_logic_vector(11 downto 0);
    SERDES_ADDON_RX                : in  std_logic_vector(11 downto 0);
    
    --Inter-FPGA Communication
    FPGA5_COMM                     : inout std_logic_vector(11 downto 0);
                                                           --Bit 0/1 input, serial link RX active
                                                           --Bit 2/3 output, serial link TX active
                                                           --others yet undefined
    --Connection to AddOn
    SPARE_LINE                     : inout std_logic_vector(5 downto 0); --inputs only
    DQUL                           : inout std_logic_vector(45 downto 0);                              
    DQLL                           : inout std_logic_vector(47 downto 0);                              
    DQUR                           : inout std_logic_vector(33 downto 0);
    DQLR                           : inout std_logic_vector(35 downto 0);                              

    --Flash ROM & Reboot
    FLASH_CLK                      : out std_logic;
    FLASH_CS                       : out std_logic;
    FLASH_DIN                      : out std_logic;
    FLASH_DOUT                     : in  std_logic;
    PROGRAMN                       : out std_logic; --reboot FPGA
    
    --Misc
    TEMPSENS                       : inout std_logic; --Temperature Sensor
    CODE_LINE                      : in  std_logic_vector(1 downto 0);
    LED_GREEN                      : out std_logic;
    LED_ORANGE                     : out std_logic; 
    LED_RED                        : out std_logic;
    LED_YELLOW                     : out std_logic;
    SUPPL                          : in  std_logic; --terminated diff pair, PCLK, Pads

    --Test Connectors
    TEST_LINE                      : out std_logic_vector(15 downto 0)
    );


    attribute syn_useioff : boolean;
    --no IO-FF for LEDs relaxes timing constraints
    attribute syn_useioff of LED_GREEN          : signal is false;
    attribute syn_useioff of LED_ORANGE         : signal is false;
    attribute syn_useioff of LED_RED            : signal is false;
    attribute syn_useioff of LED_YELLOW         : signal is false;
    attribute syn_useioff of TEMPSENS           : signal is false;
    attribute syn_useioff of PROGRAMN           : signal is false;
    attribute syn_useioff of CODE_LINE          : signal is false;
    attribute syn_useioff of TRIGGER_LEFT       : signal is false;
    attribute syn_useioff of TRIGGER_RIGHT      : signal is false;
    
    --important signals _with_ IO-FF
    attribute syn_useioff of FLASH_CLK          : signal is true;
    attribute syn_useioff of FLASH_CS           : signal is true;
    attribute syn_useioff of FLASH_DIN          : signal is true;
    attribute syn_useioff of FLASH_DOUT         : signal is true;
    attribute syn_useioff of FPGA5_COMM         : signal is true;
    attribute syn_useioff of TEST_LINE          : signal is true;
    attribute syn_useioff of DQLL               : signal is true;
    attribute syn_useioff of DQUL               : signal is true;
    attribute syn_useioff of DQLR               : signal is true;
    attribute syn_useioff of DQUR               : signal is true;
    attribute syn_useioff of SPARE_LINE         : signal is true;


end entity;

architecture trb3_periph_arch of trb3_periph_test is
  --Constants
  constant POWER_TEST : integer := 0;
  constant CDT_TEST   : integer := 0;

  attribute syn_keep : boolean;
  attribute syn_preserve : boolean;

  --Clock / Reset
  signal clk_100_i   : std_logic; --clock for main logic, 100 MHz, via Clock Manager and internal PLL
  signal clk_200_i   : std_logic; --clock for logic at 200 MHz, via Clock Manager and bypassed PLL
  signal pll_lock    : std_logic; --Internal PLL locked. E.g. used to reset all internal logic.
  signal clear_i     : std_logic;
  signal reset_i     : std_logic;
  signal GSR_N       : std_logic;
  attribute syn_keep of GSR_N : signal is true;
  attribute syn_preserve of GSR_N : signal is true;  
  
  --Media Interface
  signal med_stat_op             : std_logic_vector (1*16-1  downto 0);
  signal med_ctrl_op             : std_logic_vector (1*16-1  downto 0);
  signal med_stat_debug          : std_logic_vector (1*64-1  downto 0);
  signal med_ctrl_debug          : std_logic_vector (1*64-1  downto 0);
  signal med_data_out            : std_logic_vector (1*16-1  downto 0);
  signal med_packet_num_out      : std_logic_vector (1*3-1   downto 0);
  signal med_dataready_out       : std_logic;
  signal med_read_out            : std_logic;
  signal med_data_in             : std_logic_vector (1*16-1  downto 0);
  signal med_packet_num_in       : std_logic_vector (1*3-1   downto 0);
  signal med_dataready_in        : std_logic;
  signal med_read_in             : std_logic;

  --Slow Control channel
  signal common_stat_reg         : std_logic_vector(std_COMSTATREG*32-1 downto 0) := (others => '0');
  signal common_ctrl_reg         : std_logic_vector(std_COMCTRLREG*32-1 downto 0);
  signal common_stat_reg_strobe  : std_logic_vector(std_COMSTATREG-1 downto 0);
  signal common_ctrl_reg_strobe  : std_logic_vector(std_COMCTRLREG-1 downto 0);

  --Timer
  signal global_time             : std_logic_vector(31 downto 0);
  signal local_time              : std_logic_vector(7 downto 0);
  signal time_since_last_trg     : std_logic_vector(31 downto 0);
  signal timer_ticks             : std_logic_vector(1 downto 0);
  
  signal sed_debug : std_logic_vector(31 downto 0);
  
  signal regio_rx, busmem_rx, bussed_rx, bustest_rx : CTRLBUS_RX;
  signal regio_tx, busmem_tx, bussed_tx, bustest_tx : CTRLBUS_TX;
  signal readout_rx : READOUT_RX;
  signal readout_tx : READOUT_TX;
  
  --FPGA Test
  signal time_counter : unsigned(31 downto 0);
  
  type a_t is array(0 to 33) of std_logic_vector(1000 downto 0);
  signal c : a_t;
  attribute syn_keep of c : signal is true;
  attribute syn_preserve of c : signal is true;  
  
  signal test_debug : std_logic_vector(31 downto 0);
  
begin
---------------------------------------------------------------------------
-- Reset Generation
---------------------------------------------------------------------------

GSR_N   <= pll_lock;
  
THE_RESET_HANDLER : trb_net_reset_handler
  generic map(
    RESET_DELAY     => x"FEEE"
    )
  port map(
    CLEAR_IN        => '0',             -- reset input (high active, async)
    CLEAR_N_IN      => '1',             -- reset input (low active, async)
    CLK_IN          => clk_200_i,       -- raw master clock, NOT from PLL/DLL!
    SYSCLK_IN       => clk_100_i,       -- PLL/DLL remastered clock
    PLL_LOCKED_IN   => pll_lock,        -- master PLL lock signal (async)
    RESET_IN        => '0',             -- general reset signal (SYSCLK)
    TRB_RESET_IN    => med_stat_op(13), -- TRBnet reset signal (SYSCLK)
    CLEAR_OUT       => clear_i,         -- async reset out, USE WITH CARE!
    RESET_OUT       => reset_i,         -- synchronous reset out (SYSCLK)
    DEBUG_OUT       => open
  );  


---------------------------------------------------------------------------
-- Clock Handling
---------------------------------------------------------------------------
THE_MAIN_PLL : pll_in200_out100
  port map(
    CLK    => CLK_GPLL_RIGHT,
    RESET  => '0',
    CLKOP  => clk_100_i,
    CLKOK  => clk_200_i,
    LOCK   => pll_lock
    );


---------------------------------------------------------------------------
-- The TrbNet media interface (to other FPGA)
---------------------------------------------------------------------------
THE_MEDIA_UPLINK : trb_net16_med_ecp3_sfp
  generic map(
    SERDES_NUM  => 1,     --number of serdes in quad
    EXT_CLOCK   => c_NO,  --use internal clock
    USE_200_MHZ => c_YES, --run on 200 MHz clock
    USE_CTC     => c_NO
    )
  port map(
    CLK                => clk_200_i,
    SYSCLK             => clk_100_i,
    RESET              => reset_i,
    CLEAR              => clear_i,
    CLK_EN             => '1',
    --Internal Connection
    MED_DATA_IN        => med_data_out,
    MED_PACKET_NUM_IN  => med_packet_num_out,
    MED_DATAREADY_IN   => med_dataready_out,
    MED_READ_OUT       => med_read_in,
    MED_DATA_OUT       => med_data_in,
    MED_PACKET_NUM_OUT => med_packet_num_in,
    MED_DATAREADY_OUT  => med_dataready_in,
    MED_READ_IN        => med_read_out,
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
    STAT_OP            => med_stat_op,
    CTRL_OP            => med_ctrl_op,
    STAT_DEBUG         => med_stat_debug,
    CTRL_DEBUG         => (others => '0')
   );

---------------------------------------------------------------------------
-- Endpoint
---------------------------------------------------------------------------

  THE_ENDPOINT : entity work.trb_net16_endpoint_hades_full_handler_record
    generic map(
      REGIO_NUM_STAT_REGS       => 0,
      REGIO_NUM_CTRL_REGS       => 0,
      ADDRESS_MASK              => x"FFFF",
      BROADCAST_BITMASK         => x"ff",
      BROADCAST_SPECIAL_ADDR    => BROADCAST_SPECIAL_ADDR,
      REGIO_COMPILE_TIME        => std_logic_vector(to_unsigned(VERSION_NUMBER_TIME, 32)),
      REGIO_HARDWARE_VERSION    => HARDWARE_INFO,
      REGIO_INIT_ADDRESS        => INIT_ADDRESS,
      REGIO_USE_VAR_ENDPOINT_ID => c_YES,
      REGIO_INCLUDED_FEATURES   => INCLUDED_FEATURES,
      CLOCK_FREQUENCY           => CLOCK_FREQUENCY,
      TIMING_TRIGGER_RAW        => c_YES,
      --Configure data handler
      DATA_INTERFACE_NUMBER     => 1,
      DATA_BUFFER_DEPTH         => 9,
      DATA_BUFFER_WIDTH         => 32,
      DATA_BUFFER_FULL_THRESH   => 2**9-255,
      TRG_RELEASE_AFTER_DATA    => c_YES,
      HEADER_BUFFER_DEPTH       => 9,
      HEADER_BUFFER_FULL_THRESH => 2**9-16
      )
    port map(
      CLK                => clk_100_i,
      RESET              => reset_i,
      CLK_EN             => '1',
      MED_DATAREADY_OUT  => med_dataready_out,
      MED_DATA_OUT       => med_data_out,
      MED_PACKET_NUM_OUT => med_packet_num_out,
      MED_READ_IN        => med_read_in,
      MED_DATAREADY_IN   => med_dataready_in,
      MED_DATA_IN        => med_data_in,
      MED_PACKET_NUM_IN  => med_packet_num_in,
      MED_READ_OUT       => med_read_out,
      MED_STAT_OP_IN     => med_stat_op,
      MED_CTRL_OP_OUT    => med_ctrl_op,
      
      --Timing trigger in
      TRG_TIMING_TRG_RECEIVED_IN  => TRIGGER_LEFT,
      --LVL1 trigger to FEE
      LVL1_TRG_DATA_VALID_OUT     => readout_rx.data_valid,
      LVL1_VALID_TIMING_TRG_OUT   => readout_rx.valid_timing_trg,
      LVL1_VALID_NOTIMING_TRG_OUT => readout_rx.valid_notiming_trg,
      LVL1_INVALID_TRG_OUT        => readout_rx.invalid_trg,

      LVL1_TRG_TYPE_OUT        => readout_rx.trg_type,
      LVL1_TRG_NUMBER_OUT      => readout_rx.trg_number,
      LVL1_TRG_CODE_OUT        => readout_rx.trg_code,
      LVL1_TRG_INFORMATION_OUT => readout_rx.trg_information,
      LVL1_INT_TRG_NUMBER_OUT  => readout_rx.trg_int_number,

      --Information about trigger handler errors
      TRG_MULTIPLE_TRG_OUT     => readout_rx.trg_multiple,
      TRG_TIMEOUT_DETECTED_OUT => readout_rx.trg_timeout,
      TRG_SPURIOUS_TRG_OUT     => readout_rx.trg_spurious,
      TRG_MISSING_TMG_TRG_OUT  => readout_rx.trg_missing,
      TRG_SPIKE_DETECTED_OUT   => readout_rx.trg_spike,

      --Response from FEE
      FEE_TRG_RELEASE_IN(0)        => readout_tx.busy_release,
      FEE_TRG_STATUSBITS_IN        => readout_tx.statusbits,
      FEE_DATA_IN                  => readout_tx.data,
      FEE_DATA_WRITE_IN(0)         => readout_tx.data_write,
      FEE_DATA_FINISHED_IN(0)      => readout_tx.data_finished,
      FEE_DATA_ALMOST_FULL_OUT(0)  => readout_rx.buffer_almost_full,
     
      -- Slow Control Data Port
      REGIO_COMMON_STAT_REG_IN           => common_stat_reg,  --0x00
      REGIO_COMMON_CTRL_REG_OUT          => common_ctrl_reg,  --0x20
      REGIO_COMMON_STAT_STROBE_OUT       => common_stat_reg_strobe,
      REGIO_COMMON_CTRL_STROBE_OUT       => common_ctrl_reg_strobe,
      REGIO_STAT_REG_IN                  => (others => '0'),
      REGIO_CTRL_REG_OUT                 => open,
      REGIO_STAT_STROBE_OUT              => open,
      REGIO_CTRL_STROBE_OUT              => open,
      REGIO_VAR_ENDPOINT_ID(1 downto 0)  => CODE_LINE,
      REGIO_VAR_ENDPOINT_ID(15 downto 2) => (others => '0'),

      BUS_RX => regio_rx,
      BUS_TX => regio_tx,
      
      ONEWIRE_INOUT        => TEMPSENS,
      ONEWIRE_MONITOR_OUT  => open,

      TIME_GLOBAL_OUT         => global_time,
      TIME_LOCAL_OUT          => local_time,
      TIME_SINCE_LAST_TRG_OUT => time_since_last_trg,
      TIME_TICKS_OUT          => timer_ticks

      );

  readout_tx.busy_release <= '1';
  readout_tx.statusbits <= (others => '0');
  readout_tx.data <= (others => '0');
  readout_tx.data_write <= '0';
  readout_tx.data_finished <= '1';
      
---------------------------------------------------------------------------
-- AddOn
---------------------------------------------------------------------------
  DQLL <= (others => '0');
  DQUL <= (others => '0');
  DQLR <= (others => '0');
  DQUR <= (others => '0');

gen_power : if POWER_TEST = 1 generate  
  gen_chains : for i in 0 to 33 generate
    process begin
      wait until rising_edge(clk_200_i);
      c(i)(1000 downto 1) <= c(i)(999 downto 0);
      c(i)(0) <= not c(i)(0) or DQUL(i);
      DQUR(i) <= c(i)(1000);
      if reset_i = '1' then
        c(i)(1000 downto 0) <= (others => '0');
      end if;
    end process;
  
  end generate;
end generate;  

gen_cdt : if CDT_TEST = 1 generate  
  MY_TEST : entity work.cdt_test
    port map(
      CLK_200 => clk_200_i,
      CLK_100 => clk_100_i,
      BUS_RX  => bustest_rx,
      BUS_TX  => bustest_tx,
      DEBUG   => test_debug(31 downto 0)
      );
end generate;


---------------------------------------------------------------------------
-- Bus Handler
---------------------------------------------------------------------------
  THE_BUS_HANDLER : entity work.trb_net16_regio_bus_handler_record
    generic map(
      PORT_NUMBER      => 3,
      PORT_ADDRESSES   => (0 => x"d000", 1 => x"d500", 2 => x"a000", others => x"0000"),
      PORT_ADDR_MASK   => (0 => 9,       1 => 2,       2 => 8,       others => 0),
      PORT_MASK_ENABLE => 1
      )
    port map(
      CLK   => clk_100_i,
      RESET => reset_i,

      REGIO_RX  => regio_rx,
      REGIO_TX  => regio_tx,
      
      BUS_RX(0) => busmem_rx, --Flash
      BUS_RX(1) => bussed_rx, --SED
      BUS_RX(2) => bustest_rx,
      BUS_TX(0) => busmem_tx,
      BUS_TX(1) => bussed_tx,
      BUS_TX(2) => bustest_tx,
      
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

---------------------------------------------------------------------------
-- LED
---------------------------------------------------------------------------
  LED_GREEN                      <= not med_stat_op(9);
  LED_ORANGE                     <= not med_stat_op(10); 
  LED_RED                        <= not time_counter(26);
  LED_YELLOW                     <= not test_debug(31);


---------------------------------------------------------------------------
-- Test Connector
---------------------------------------------------------------------------    

  TEST_LINE(15 downto 0)  <= test_debug(31 downto 28) & test_debug(21 downto 16) & test_debug(5 downto 0);


---------------------------------------------------------------------------
-- Test Circuits
---------------------------------------------------------------------------
  process
    begin
      wait until rising_edge(clk_100_i);
      time_counter <= time_counter + 1;
    end process;

end architecture;
