library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb3_components.all;
use work.config.all;
use work.version.all;
use work.basic_type_declaration.all;  -- Ievgen: File with different type declarations.


entity trb3_periph_blank is
  port(
    --Clocks
    CLK_GPLL_LEFT        : in    std_logic;  --Clock Manager 1/(2468), 125 MHz
    CLK_GPLL_RIGHT       : in    std_logic;  --Clock Manager 2/(2468), 200 MHz  <-- MAIN CLOCK for FPGA
    CLK_PCLK_LEFT        : in    std_logic;  --Clock Fan-out, 200/400 MHz <-- For TDC. Same oscillator as GPLL right!
    CLK_PCLK_RIGHT       : in    std_logic;  --Clock Fan-out, 200/400 MHz <-- For TDC. Same oscillator as GPLL right!
	--MCLK				 : in	 std_logic;  --Same as CLK_GPLL_RIGHT, Renamed for trigger code. Can be external 50.6 MHz clock
    --Trigger
    TRIGGER_LEFT         : in    std_logic;  --left side trigger input from fan-out

    --Inter-FPGA Communication
    FPGA5_COMM           : inout std_logic_vector(11 downto 0);
                                        --Bit 0/1 input, serial link RX active
                                        --Bit 2/3 output, serial link TX active
                                        --Bit 10-7 trigger to CTS
    --Connection to AddOn:
    INP                  : in  std_logic_vector(47 downto 0);
	-- Trigger Output from AddOn:
	TRIG_OUT			 : out std_logic_vector(6 downto 0);
	
	--Splitter board connections
	IN_pA : in std_logic;
	IN_pB : in std_logic;
	IN_pC : in std_logic;
	IN_pD : in std_logic;
	--TestIn : in std_logic_vector(13 downto 0);  -- this uses 4th connector on 4Conn (same as TRIG_OUT)
	--OutpA : out std_logic_vector(2 downto 0);
	OUT_pA : out std_logic_vector(2 downto 0);
	OUT_pB : out std_logic_vector(2 downto 0);
	OUT_pC : out std_logic_vector(2 downto 0);
	OUT_pD : out std_logic_vector(1 downto 0);
	--TestLED : out std_logic_vector(7 downto 0);  -- this uses 4th connector on 4Conn (same as TRIG_OUT)
	--TestOut : out std_logic_vector(11 downto 0);  -- this uses 4th connector on 4Conn (same as TRIG_OUT)

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
    --Test Connectors
    TEST_LINE  : inout std_logic_vector(15 downto 0)
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
  --important signals
  attribute syn_useioff of FLASH_CLK     : signal is true;
  attribute syn_useioff of FLASH_CS      : signal is true;
  attribute syn_useioff of FLASH_DIN     : signal is true;
  attribute syn_useioff of FLASH_DOUT    : signal is true;
  attribute syn_useioff of FPGA5_COMM    : signal is true;
  attribute syn_useioff of TEST_LINE     : signal is true;
  attribute syn_useioff of INP           : signal is false;
 

end entity;


architecture trb3_periph_blank_arch of trb3_periph_blank is
  attribute syn_keep             : boolean;
  attribute syn_preserve         : boolean;

  --Clock / Reset
  signal clk_100_i                : std_logic;  --clock for main logic, 100 MHz, via Clock Manager and internal PLL
  signal clk_200_i                : std_logic;  --clock for logic at 200 MHz, via Clock Manager and bypassed PLL
  signal pll_lock                 : std_logic;  --Internal PLL locked. E.g. used to reset all internal logic.
  signal clear_i                  : std_logic;
  signal reset_i                  : std_logic;
  signal GSR_N                    : std_logic;
  attribute syn_keep of GSR_N     : signal is true;
  attribute syn_preserve of GSR_N : signal is true;

  --Media Interface
  signal med_stat_debug    : std_logic_vector (1*64-1 downto 0);
  signal med2int           : med2int_array_t(0 to 0);
  signal int2med           : int2med_array_t(0 to 0);
  
  signal timing_trg_received_i  : std_logic;

  --READOUT
  signal readout_rx : READOUT_RX;
  signal readout_tx : readout_tx_array_t(0 to 0);

  --Slow Control channel
  signal common_ctrl_reg        : std_logic_vector(std_COMCTRLREG*32-1 downto 0);

  signal ctrlbus_rx, busrdo_rx, bustools_rx, bus_master_out  : CTRLBUS_RX;
  signal ctrlbus_tx, busrdo_tx, bustools_tx, bus_master_in   : CTRLBUS_TX;
  signal bus_master_active : std_logic;
  signal timer             : TIMERS;
  signal lcd_data          : std_logic_vector(511 downto 0);
  signal lcd_out           : std_logic_vector(4 downto 0);
  signal feature_outputs_i : std_logic_vector(15 downto 0);
  signal spi_cs, spi_mosi, spi_miso, spi_clk, spi_clr : std_logic_vector(15 downto 0); 
  signal uart_rx, uart_tx, debug_rx, debug_tx         : std_logic;
  signal trig_gen_out_i                               : std_logic_vector(3 downto 0);
  signal sed_error_i                                  : std_logic;
  signal serdes_i          : std_logic_vector(3 downto 0);
  attribute nopad : string;
  attribute nopad of  serdes_i : signal is "true";  

  type state_t is (IDLE, WRITE, FINISH, BUSYEND);
  signal state : state_t;
  signal data_counter, data_amount : unsigned(15 downto 0) := (others => '0');
  signal data, rdata : std_logic_vector(31 downto 0) := (others => '0');
  signal addr : std_logic_vector(15 downto 0) := (others => '0');
  signal clk : std_logic_vector(5 downto 0);
  
  
  signal rd, wr, ack, netclk : std_logic;
  
  type t_addr is array (0 to 199) of std_logic_vector(15 downto 0);
  type t_data is array (0 to 199) of std_logic_vector(31 downto 0);
  --signal addr : t_addr := (others => (others => '0'));
  --signal data : t_data := (others => (others => '0'));  --signal rdata : t_data := (others => (others => '0'));
--  addr_bus(0) <= x"0000";
--  addr_bus(1) <= x"0001";
--  addr_bus(2) <= x"0002";

 ------------------------ Defining additional components  and signals for trigger logic:
  --signal trig_ch_delay		: array5(47 downto 0) := (others => (others => '0')); -- an array of 5 bit std_logic_vectors to store delay values for each of trigger input channels
  --signal str_val            : std_logic_vector(3 downto 0) := (others => '0'); -- mask of connected trigger channels
  --signal trig_out_OR		: std_logic; -- output of OR of all enabled channels;
  signal bar_enable_mask           : std_logic_vector(7 downto 0) := (others => '1');
  
  
  
 component Veto_BM is  
	  port(
	  INP 			    : in std_logic_vector(47 downto 0); --using only first 16.
	  CLK_PCLK_RIGHT	: in std_logic;
	  bar_enable_mask   : in std_logic_vector (7 downto 0);
	  OutpA				: out std_logic_vector(2 downto 0);
	  OutpB				: out std_logic_vector(2 downto 0);
	  OutpC				: out std_logic_vector(2 downto 0)
	      )  ; 
 end component Veto_BM;
 
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
      CLK_IN        => clk_200_i,        -- raw master clock, NOT from PLL/DLL!
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
  THE_MAIN_PLL : trb3_components.pll_in200_out100
    port map(
      CLK   => CLK_GPLL_RIGHT, --Originally GLK_GPLL_RIGHT. PLL needs to be changed when accepting 50.6 MHz external clock.
      RESET => '0',			   --This PLL expects a 200 MHz input clock to work, when sending in 50.6 MHz external for trigger, PLL needs to be remade to still output a 200 and 100 MHz clk.
      CLKOP => clk_100_i,	--originally CLKOP is clk_100_i
      CLKOK => clk_200_i,	--originally CLKOK is clk_200_i
      LOCK  => pll_lock
      );

---------------------------------------------------------------------------
-- The TrbNet media interface (to other FPGA)
---------------------------------------------------------------------------
  THE_MEDIA_UPLINK : trb_net16_med_ecp3_sfp
    generic map(
      SERDES_NUM  => 1,                 --number of serdes in quad
      EXT_CLOCK   => c_NO,              --use internal clock, seems no option for external in the relevant function
      USE_200_MHZ => c_YES,             --run on 200 MHz clock
      USE_125_MHZ => c_NO,				--may attempt to run on 125 MHz.
      USE_CTC     => c_NO
      )
    port map(
      CLK                => clk_200_i,
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
      --SD_RXD_P_IN        => serdes_i(0),
      --SD_RXD_N_IN        => serdes_i(1),
      --SD_TXD_P_OUT       => serdes_i(2),
      --SD_TXD_N_OUT       => serdes_i(3),
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
  generic map (
    ADDRESS_MASK                 => x"FFFF",
    BROADCAST_BITMASK            => x"FF",
    REGIO_INIT_ENDPOINT_ID       => x"0001",
    TIMING_TRIGGER_RAW           => c_YES,
    REGIO_USE_VAR_ENDPOINT_ID    => c_YES,
    --Configure data handler
    DATA_INTERFACE_NUMBER        => 1,
    DATA_BUFFER_DEPTH            => EVENT_BUFFER_SIZE,
    DATA_BUFFER_WIDTH            => 32,
    DATA_BUFFER_FULL_THRESH      => 2**EVENT_BUFFER_SIZE-EVENT_MAX_SIZE,
    TRG_RELEASE_AFTER_DATA       => c_YES,
    HEADER_BUFFER_DEPTH          => 9,
    HEADER_BUFFER_FULL_THRESH    => 2**9-16
    )

  port map(
    --  Misc
    CLK                          => clk_100_i,
    RESET                        => reset_i,
    CLK_EN                       => '1',

    --  Media direction port
    MEDIA_MED2INT                => med2int(0),
    MEDIA_INT2MED                => int2med(0),

    --Timing trigger in
    TRG_TIMING_TRG_RECEIVED_IN   => timing_trg_received_i,
    
    READOUT_RX                   => readout_rx,
    READOUT_TX                   => readout_tx,

    --Slow Control Port
    REGIO_COMMON_CTRL_REG_OUT    => common_ctrl_reg,  --0x20
    BUS_RX                       => ctrlbus_rx,
    BUS_TX                       => ctrlbus_tx,
    BUS_MASTER_IN                => bus_master_in,
    BUS_MASTER_OUT               => bus_master_out,
    BUS_MASTER_ACTIVE            => bus_master_active,
    
    REGIO_VAR_ENDPOINT_ID(1 downto 0)  => CODE_LINE,
    REGIO_VAR_ENDPOINT_ID(15 downto 2) => (others => '0'),
    ONEWIRE_INOUT                => TEMPSENS,
    --Timing registers
    TIMERS_OUT                   => timer
    );
    

  timing_trg_received_i <= TRIGGER_LEFT;

---------------------------------------------------------------------------
-- Bus Handler
---------------------------------------------------------------------------
  THE_BUS_HANDLER : entity work.trb_net16_regio_bus_handler_record
    generic map(
      PORT_NUMBER      => 2,
	  PORT_ADDRESSES   => (0 => x"d000", 1 => x"a000", others => x"0000"),
      PORT_ADDR_MASK   => (0 => 12,      1 => 12,      others => 0),
      PORT_MASK_ENABLE => 1
      )
    port map(
      CLK   => clk_100_i,
      RESET => reset_i,

      REGIO_RX => ctrlbus_rx,
      REGIO_TX => ctrlbus_tx,

      BUS_RX(0) => bustools_rx,         --Flash, SPI, UART, ADC, SED
      BUS_RX(1) => busrdo_rx,           --TDC config
      BUS_TX(0) => bustools_tx,
      BUS_TX(1) => busrdo_tx,

      STAT_DEBUG => open
      );

---------------------------------------------------------------------------
-- Control Tools
---------------------------------------------------------------------------
  THE_TOOLS : entity work.trb3_tools
    port map(
      CLK   => clk_100_i,
      RESET => reset_i,

      --Flash & Reload
      FLASH_CS      => FLASH_CS,
      FLASH_CLK     => FLASH_CLK,
      FLASH_IN      => FLASH_DOUT,
      FLASH_OUT     => FLASH_DIN,
      PROGRAMN      => PROGRAMN,
      REBOOT_IN     => common_ctrl_reg(15),
      --SPI
      SPI_CS_OUT    => spi_cs,
      SPI_MOSI_OUT  => spi_mosi,
      SPI_MISO_IN   => spi_miso,
      SPI_CLK_OUT   => spi_clk,
      SPI_CLR_OUT   => spi_clr,
      --LCD
      LCD_DATA_IN   => lcd_data,
      UART_RX_IN    => uart_rx, 
      UART_TX_OUT   => uart_tx,
      DEBUG_RX_IN   => debug_rx,
      DEBUG_TX_OUT  => debug_tx,

      --Trigger & Monitor 
      MONITOR_INPUTS(31 downto 0) => INP(31 downto 0),
      MONITOR_INPUTS(35 downto 32) => trig_gen_out_i,
      TRIG_GEN_INPUTS  => INP(31 downto 0),
      TRIG_GEN_OUTPUTS => trig_gen_out_i,
      LCD_OUT => lcd_out,
      --SED
      SED_ERROR_OUT => sed_error_i,
      --Slowcontrol
      BUS_RX        => bustools_rx,
      BUS_TX        => bustools_tx,
      --Control master for default settings
      BUS_MASTER_IN  => bus_master_in,
      BUS_MASTER_OUT => bus_master_out,
      BUS_MASTER_ACTIVE => bus_master_active, 
      DEBUG_OUT => open
      );      
     
---------------------------------------------------------------------------
-- Feature I/O
---------------------------------------------------------------------------      

  FPGA5_COMM(10 downto 7) <= trig_gen_out_i;
  FPGA5_COMM(6 downto 3)  <= (others => 'Z');
  FPGA5_COMM(1)           <= 'Z';  
  
  feature_outputs_i(0) <= uart_rx; 
  feature_outputs_i(1) <= uart_tx;
  feature_outputs_i(2) <= spi_cs(1);
  feature_outputs_i(3) <= spi_mosi(1);
  feature_outputs_i(4) <= spi_clk(1);
  spi_miso(1) <= TEST_LINE(5);
  feature_outputs_i(7) <= lcd_out(4); --lcd_cs  
  feature_outputs_i(8) <= lcd_out(0); --lcd_rst 
  feature_outputs_i(9) <= lcd_out(3); --lcd_dc
  feature_outputs_i(10) <= lcd_out(2); --lcd_mosi
  feature_outputs_i(11) <= lcd_out(1); --lcd_sck
  --12 is LCD MISO, but not used
  feature_outputs_i(14) <= debug_rx;
  feature_outputs_i(15) <= debug_tx; 

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
  --LED_GREEN  <= not med2int(0).stat_op(9);
  --LED_ORANGE <= not med2int(0).stat_op(10);
  --LED_RED    <= '1';
  --LED_YELLOW <= not med2int(0).stat_op(11);

---------------------------------------------------------------------------
-- Test Connector - Additional Features
---------------------------------------------------------------------------
  TEST_LINE <= feature_outputs_i;

-------------------------------------------------------------------------------
-- Master trigger logic
-------------------------------------------------------------------------------

	
 BM_VetoTriggeringing:
           Veto_BM port map(
	  INP 			    =>INP (47 downto 0),
	  bar_enable_mask => bar_enable_mask,
	 CLK_PCLK_RIGHT		=> CLK_PCLK_RIGHT,
		OutpA				=> OUT_pA,
		OutpB				=> OUT_pB,
		OutpC				=> OUT_pC
	      )  ; 





---------------- Reading/Writing  Values from the registers ---------------------------------
THE_RDO_STAT : process begin
  wait until rising_edge(clk_100_i);
  busrdo_tx.ack <= '0';
  busrdo_tx.nack <= '0';
  busrdo_tx.unknown <= '0';
  
--------------------------------------   WRITING VALUES: -----------------------------------------------
  if busrdo_rx.write = '1' then
    -- Writing trigger channels mask registers: (registers 0xd80X are for trigger masks) 
    if busrdo_rx.addr(15 downto 0) = x"0001" then
			busrdo_tx.ack <= '1';
			bar_enable_mask(7 downto 0) <= std_logic_vector(busrdo_rx.data(7 downto 0));
		else
          busrdo_tx.unknown <= '1';
		end if;
	
---------------------------------------  READING VALUES: ------------------------------------------------	
  elsif busrdo_rx.read = '1' then
    -- Firmware revision:
    if busrdo_rx.addr = x"0000" then  -- Firmware register  
      busrdo_tx.ack <= '1';
	  busrdo_tx.data(31 downto 16) <= (others => '0');
      busrdo_tx.data(15 downto 0) <= x"f001"; 
	  
	  elsif busrdo_rx.addr(15 downto 0) = x"0001" then
			busrdo_tx.ack <= '1';
			busrdo_tx.data(31 downto 8) <= (others => '0'); 
			busrdo_tx.data(7 downto 0) <= bar_enable_mask(7 downto 0);
	    
		else
			busrdo_tx.ack <= '1';
			busrdo_tx.data(31 downto 0) <= x"deadbeef"; 				
		end if;
		
	-- if register was not defined above, the output will produce the error:	
    else
      busrdo_tx.unknown <= '1';
    end if;
end process;



THE_RDO : process begin
  wait until rising_edge(clk_100_i);
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
      data_counter <= (others =>'0');
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


end architecture;
