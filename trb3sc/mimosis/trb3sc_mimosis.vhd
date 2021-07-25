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

entity trb3sc_mimosis is
  port(
    CLK_SUPPL_PCLK       : in    std_logic; --125 MHz for GbE
    CLK_CORE_PCLK        : in    std_logic; --Main Oscillator
    CLK_EXT_PLL_LEFT     : in    std_logic; --External Clock
    
    TRIG_LEFT            : in    std_logic; --Trigger Input
    
    --Backplane, all lines
    BACK_LVDS            : inout std_logic_vector( 1 downto 0);
    --Backplane for slaves on trbv3scbp1
    BACK_GPIO            : inout std_logic_vector(3 downto 0);
    
    --AddOn Connector
    VALID_IN    : in  std_logic;
    ADDRPIX_IN  : in  std_logic_vector(13 downto 0);
    CMD_IN      : in  std_logic_vector(7 downto 4);
    TEMP        : inout std_logic;
    CLK_IN      : in  std_logic;
    RUN_OUT     : out std_logic;
    CLK_OUT     : out std_logic;
    
    --KEL Connector
    --KEL                  : inout std_logic_vector(40 downto 1);
    
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
    TEST_LINE            : out std_logic_vector(15 downto 0)
    );


  attribute syn_useioff                  : boolean;
  attribute syn_useioff of FLASH_CLK  : signal is true;
  attribute syn_useioff of FLASH_CS   : signal is true;
  attribute syn_useioff of FLASH_IN   : signal is true;
  attribute syn_useioff of FLASH_OUT  : signal is true;

  
  
end entity;

architecture trb3sc_arch of trb3sc_mimosis is
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

  signal ctrlbus_rx, bussci_rx, bustools_rx, bustc_rx, busrdo_rx, bus_master_out, busgbeip_rx, busgbereg_rx  : CTRLBUS_RX;
  signal ctrlbus_tx, bussci_tx, bustools_tx, bustc_tx, busrdo_tx, bus_master_in,  busgbeip_tx, busgbereg_tx  : CTRLBUS_TX;
  
  signal common_stat_reg   : std_logic_vector(std_COMSTATREG*32-1 downto 0) := (others => '0');
  signal common_ctrl_reg   : std_logic_vector(std_COMCTRLREG*32-1 downto 0);
  
  signal sed_error_i       : std_logic;
  signal clock_select      : std_logic;
  signal bus_master_active : std_logic;
  
  signal spi_cs, spi_mosi, spi_miso, spi_clk : std_logic_vector(15 downto 0);

  signal timer    : TIMERS;
  signal lcd_data : std_logic_vector(511 downto 0);

  signal sfp_los_i, sfp_txdis_i, sfp_prsnt_i : std_logic;

  signal fwd_dst_mac  : std_logic_vector(47 downto 0);
  signal fwd_dst_ip   : std_logic_vector(31 downto 0);
  signal fwd_dst_port : std_logic_vector(15 downto 0);
  signal fwd_data     : std_logic_vector(7  downto 0);
  signal fwd_datavalid : std_logic;
  signal fwd_sop       : std_logic;
  signal fwd_eop       : std_logic;
  signal fwd_ready     : std_logic;
  signal fwd_full      : std_logic; 
  signal fwd_length    : std_logic_vector(15 downto 0);
  signal fwd_do_send   : std_logic;
  signal word_counter  : unsigned(15 downto 0);
  type tx_state_t is (IDLE,START,START2,SEND,SEND_1,SEND_2,SEND_3,EOB);
  signal tx_state : tx_state_t;
  

  signal fifo_data_in, fifo_data_out  : std_logic_vector(35 downto 0);
  signal fifo_write, fifo_read        : std_logic;
  signal fifo_empty, fifo_full        : std_logic;
  signal fifo_count                   : std_logic_vector(11 downto 0);
  signal input_data                   : std_logic_vector(18 downto 0);
  signal sclk_r, sclk_rr              : std_logic;
  signal last_valid                   : std_logic;
  
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
      PORT_NUMBER      => 6,
      PORT_ADDRESSES   => (0 => x"d000", 1 => x"b000", 2 => x"d300", 3 => x"a000", 4 => x"8100", 5 => x"8300", others => x"0000"),
      PORT_ADDR_MASK   => (0 => 12,      1 => 9,       2 => 1,       3 => 12,      4 => 8,       5 => 8,       others => 0),
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
      BUS_RX(4) => busgbeip_rx,
      BUS_RX(5) => busgbereg_rx,      
      BUS_TX(0) => bustools_tx,
      BUS_TX(1) => bussci_tx,
      BUS_TX(2) => bustc_tx,
      BUS_TX(3) => busrdo_tx,
      BUS_TX(4) => busgbeip_tx,
      BUS_TX(5) => busgbereg_tx,
      
      STAT_DEBUG => open
      );
---------------------------------------------------------------------------
-- GbE
---------------------------------------------------------------------------
gen_GBE : if 1 = 1 generate
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
      LINK_HAS_SLOWCTRL => "0000",
      LINK_HAS_DHCP     => "0001",
      LINK_HAS_ARP      => "0001",
      LINK_HAS_PING     => "0001",
      LINK_HAS_FWD      => "0001"
      )
              
    port map(
      CLK_SYS_IN               => clk_sys,
      CLK_125_IN               => CLK_SUPPL_PCLK,
      RESET                    => reset_i,
      GSR_N                    => GSR_N,

      TRIGGER_IN               => '0',
      
      SD_PRSNT_N_IN(0)         => SFP_MOD0(0),
      SD_PRSNT_N_IN(3 downto 1)=> "111",
      SD_LOS_IN(0)             => SFP_LOS(0),
      SD_LOS_IN(3 downto 1)    => "111",
      SD_TXDIS_OUT(0)          => SFP_TX_DIS(0),

      CTS_NUMBER_IN            => (others => '0'),          
      CTS_CODE_IN              => (others => '0'),
      CTS_INFORMATION_IN       => (others => '0'),
      CTS_READOUT_TYPE_IN      => (others => '0'),
      CTS_START_READOUT_IN     => '0',
      CTS_DATA_OUT             => open,
      CTS_DATAREADY_OUT        => open,
      CTS_READOUT_FINISHED_OUT => open,
      CTS_READ_IN              => '1',
      CTS_LENGTH_OUT           => open,
      CTS_ERROR_PATTERN_OUT    => open,
      
      FEE_DATA_IN              => (others => '0'),
      FEE_DATAREADY_IN         => '0',
      FEE_READ_OUT             => open,
      FEE_STATUS_BITS_IN       => (others => '0'),
      FEE_BUSY_IN              => '0',
      
      MC_UNIQUE_ID_IN          => timer.uid,
      MY_TRBNET_ADDRESS_IN     => timer.network_address,
      ISSUE_REBOOT_OUT         => open,
      
      GSC_CLK_IN               => clk_sys,            
      GSC_INIT_DATAREADY_OUT   => open,   
      GSC_INIT_DATA_OUT        => open,
      GSC_INIT_PACKET_NUM_OUT  => open,
      GSC_INIT_READ_IN         => '1',
      GSC_REPLY_DATAREADY_IN   => '0',
      GSC_REPLY_DATA_IN        => (others => '0'),
      GSC_REPLY_PACKET_NUM_IN  => (others => '0'),
      GSC_REPLY_READ_OUT       => open,
      GSC_BUSY_IN              => '0',
      
      FWD_DST_MAC_IN(47 downto 0) => fwd_dst_mac,
      FWD_DST_IP_IN(31 downto 0)  => fwd_dst_ip,
      FWD_DST_UDP_IN(15 downto 0) => fwd_dst_port,
      FWD_DATA_IN(7 downto 0)     => fwd_data,
      FWD_DATA_VALID_IN(0)        => fwd_datavalid,
      FWD_SOP_IN(0)               => fwd_sop,
      FWD_EOP_IN(0)               => fwd_eop,
      FWD_READY_OUT(0)            => fwd_ready,
      FWD_FULL_OUT(0)             => fwd_full,
      
      BUS_IP_RX  => busgbeip_rx,
      BUS_IP_TX  => busgbeip_tx,
      BUS_REG_RX => busgbereg_rx,
      BUS_REG_TX => busgbereg_tx,
      
      MAKE_RESET_OUT           => open,

      DEBUG_OUT                => open
      );
end generate;

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
      MONITOR_INPUTS   => (others => '0'),
      TRIG_GEN_INPUTS  => (others => '0'),
      TRIG_GEN_OUTPUTS => open,
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
-- Dummy readout
---------------------------------------------------------------------------      
  readout_tx(0).busy_release  <= '1';
  readout_tx(0).data_write    <= '0';
  readout_tx(0).data_finished <= '1';

---------------------------------------------------------------------------
-- Test registers
---------------------------------------------------------------------------   
THE_REGS : process begin
  wait until rising_edge(clk_sys);
  busrdo_tx.ack <= '0';
  busrdo_tx.nack <= '0';
  busrdo_tx.unknown <= '0';
  
  if busrdo_rx.write = '1' then
    busrdo_tx.ack <= '1';
    case busrdo_rx.addr(7 downto 0) is
      when x"00" => fwd_dst_ip    <= busrdo_rx.data;
      when x"01" => fwd_dst_port  <= busrdo_rx.data(15 downto 0);
      when x"02" => fwd_dst_mac(31 downto 0)  <= busrdo_rx.data;
      when x"03" => fwd_dst_mac(47 downto 32) <= busrdo_rx.data(15 downto 0);
      when x"04" => fwd_length    <= busrdo_rx.data(15 downto 0);
      when x"05" => fwd_do_send   <= busrdo_rx.data(0);
      when others => busrdo_tx.ack <= '0'; busrdo_tx.unknown <= '1';
    end case;
  elsif busrdo_rx.read = '1' then
    busrdo_tx.ack <= '1';
    case busrdo_rx.addr(7 downto 0) is
      when x"00" => busrdo_tx.data <= fwd_dst_ip;
      when x"01" => busrdo_tx.data <= x"0000" & fwd_dst_port;
      when x"02" => busrdo_tx.data <= fwd_dst_mac(31 downto 0);
      when x"03" => busrdo_tx.data <= x"0000" & fwd_dst_mac(47 downto 32);
      when x"04" => busrdo_tx.data <= x"0000" & fwd_length;
      when x"05" => busrdo_tx.data <= x"0000000" & fwd_full & fwd_ready & "0" & fwd_do_send;
      when others => busrdo_tx.ack <= '0'; busrdo_tx.unknown <= '1';
    end case;  
  end if;
  if reset_i = '1' then
    fwd_do_send <= '0';
  end if;
end process;  

---------------------------------------------------------------------------
-- Input stage
---------------------------------------------------------------------------  
sclk_r  <= CLK_IN when rising_edge(clk_sys);
sclk_rr <= sclk_r when rising_edge(clk_sys);
input_data <=  VALID_IN & CMD_IN & ADDRPIX_IN when rising_edge(clk_sys);

  THE_READER : process begin
    wait until rising_edge(clk_sys);
    fifo_write <= '0';
    
    if sclk_r = '1' and sclk_rr = '0' then
      last_valid <= input_data(18);
      if fwd_do_send = '1' and fifo_full = '0' then
        if input_data(18) = '1' then
          fifo_data_in <= x"0" & x"000" & input_data(17 downto 14) & "00" & input_data(13 downto 0);
          fifo_write   <= '1';
        elsif last_valid = '1' then
          fifo_data_in <= x"0FFFFFFFF";
          fifo_write   <= '1';
        end if;
      end if;  
    end if;  
    
  end process;

---------------------------------------------------------------------------
-- Data Buffer
---------------------------------------------------------------------------  
  THE_BUFFER : entity work.fifo_36x2k_oreg
    port map(
      Data   => fifo_data_in,
      Clock  => clk_sys,
      WrEn   => fifo_write,
      RdEn   => fifo_read,
      Reset  => reset_i,
      AmFullThresh => (3 => '0', others => '1'),
      Q      => fifo_data_out, 
      WCNT   => fifo_count,
      Empty  => fifo_empty,
      Full   => open,
      AlmostFull => fifo_full
      );

---------------------------------------------------------------------------
-- Sender
---------------------------------------------------------------------------  
THE_SENDER : process begin
  wait until rising_edge(clk_sys);
  fwd_sop <= '0';
  fwd_eop <= '0';
  fwd_datavalid <= '0';
  fifo_read <= '0';
  case tx_state is
    when IDLE =>
      if fwd_ready = '1' and fwd_do_send = '1' and fifo_count(10) = '1' then -- 
        tx_state <= START;
        fwd_sop <= '1';
        fifo_read <= '1';
      end if;
    when START =>
      word_counter <= unsigned(fwd_length);
      fwd_datavalid <= '1';
      fwd_data <= x"00";
      tx_state <= START2;
    when START2 =>  
      tx_state <= SEND;
    when SEND =>
      word_counter  <= word_counter - 1;
      fwd_data      <= fifo_data_out(31 downto 24);
      --fwd_data <= std_logic_vector(word_counter(7 downto 0));
      fwd_datavalid <= '1';
      tx_state <= SEND_1;
    when SEND_1 =>
      fwd_data      <= fifo_data_out(23 downto 16);
      fwd_datavalid <= '1';
      if word_counter > 0 then
        fifo_read <= '1';
      end if; 
      tx_state <= SEND_2;
    when SEND_2 =>
      fwd_data      <= fifo_data_out(15 downto 8);
      fwd_datavalid <= '1';
      tx_state <= SEND_3;
    when SEND_3 =>
      fwd_data      <= fifo_data_out(7 downto 0);
      fwd_datavalid <= '1';
      if word_counter = 0 then
        fwd_eop <= '1';
        tx_state <= EOB;
      else 
        tx_state <= SEND;
      end if;
    when EOB =>
      tx_state <= IDLE;
  end case;
  if reset_i = '1' then
    tx_state <= IDLE;
  end if;
end process;



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


--   TEST_LINE <= med_stat_debug(15 downto 0);
---------------------------------------------------------------------------
-- Test data
---------------------------------------------------------------------------       
  
end architecture;



