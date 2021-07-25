library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
library work;
  use work.trb_net_components.all;
  use work.trb_net_std.all;
  use work.trb3_components.all;
  use work.config.all;

entity trb3sc_tools is
  port(
    CLK         : in std_logic;
    RESET       : in std_logic;
    
    --Flash & Reload
    FLASH_CS    : out std_logic;
    FLASH_CLK   : out std_logic;
    FLASH_IN    : in  std_logic;
    FLASH_OUT   : out std_logic;
    PROGRAMN    : out std_logic;
    REBOOT_IN   : in  std_logic;
    
    --SPI
    SPI_CS_OUT  : out std_logic_vector(15 downto 0);
    SPI_MOSI_OUT: out std_logic_vector(15 downto 0);
    SPI_MISO_IN : in  std_logic_vector(15 downto 0) := (others => '0');
    SPI_CLK_OUT : out std_logic_vector(15 downto 0);

    --LCD
    LCD_DATA_IN : in  std_logic_vector(511 downto 0) := (others => '0');
    ADDITIONAL_REG  : out std_logic_vector(31 downto 0);
    --HDR_IO
    HEADER_IO   : inout std_logic_vector(10 downto 1);
    
    --ADC
    ADC_CS      : out std_logic := '0';
    ADC_MOSI    : out std_logic := '0';
    ADC_MISO    : in  std_logic := '0';
    ADC_CLK     : out std_logic := '0';
    
    --Trigger & Monitor 
    MONITOR_INPUTS   : in  std_logic_vector(MONITOR_INPUT_NUM-1 downto 0) := (others => '0');
    TRIG_GEN_INPUTS  : in  std_logic_vector(TRIG_GEN_INPUT_NUM-1 downto 0) := (others => '0');
    TRIG_GEN_OUTPUTS : out std_logic_vector(TRIG_GEN_OUTPUT_NUM-1 downto 0);
    --SED
    SED_ERROR_OUT : out std_logic;

    --Slowcontrol
    BUS_RX     : in  CTRLBUS_RX;
    BUS_TX     : out CTRLBUS_TX;
    
    --Control master for default settings
    BUS_MASTER_IN  : in CTRLBUS_TX := (data => (others => '0'), unknown => '1', others => '0');
    BUS_MASTER_OUT : out CTRLBUS_RX;
    BUS_MASTER_ACTIVE : out std_logic;
    
    DEBUG_OUT  : out std_logic_vector(31 downto 0)
    );
end entity;



architecture trb3sc_tools_arch of trb3sc_tools is

signal bus_debug_rx_out, bus_flash_rx_out, busflash_rx, busspi_rx, busadc_rx, bussed_rx, 
       busuart_rx, busflashset_rx, busmon_rx, bustrig_rx, busctrl_rx : CTRLBUS_RX;
signal bus_debug_tx_in,  bus_flash_tx_in,  busflash_tx, busspi_tx, busadc_tx, bussed_tx, 
       busuart_tx, busflashset_tx, busmon_tx, bustrig_tx, busctrl_tx : CTRLBUS_TX;

signal spi_sdi, spi_sdo, spi_sck : std_logic;
signal spi_cs                    : std_logic_vector(15 downto 0);
signal lcd_cs, lcd_dc, lcd_mosi, lcd_sck, lcd_rst : std_logic;
signal uart_rx, uart_tx          : std_logic;

signal flashset_active, debug_active         : std_logic;
signal flash_cs_i, flash_clk_i, flash_out_i  : std_logic;
signal flash_cs_s, flash_clk_s, flash_out_s  : std_logic;

signal debug_rx, debug_tx : std_logic;
signal debug_status : std_logic_vector(31 downto 0);
signal additional_reg_i : std_logic_vector(31 downto 0);

begin

---------------------------------------------------------------------------
-- Bus Handler
---------------------------------------------------------------------------
  THE_BUS_HANDLER : entity work.trb_net16_regio_bus_handler_record
    generic map(
      PORT_NUMBER      => 9,
      PORT_ADDRESSES   => (0 => x"0000", 1 => x"0400", 2 => x"0480", 3 => x"0500", 4 => x"0600", 
                           5 => x"0180", 6 => x"0f00", 7 => x"0f80", 8 => x"0580", others => x"0000"),
      PORT_ADDR_MASK   => (0 => 9,       1 => 5,       2 => 5,       3 => 1,       4 => 2,       
                           5 => 4,       6 => 7,       7 => 7,       8 => 0,       others => 0),
      PORT_MASK_ENABLE => 1
      )
    port map(
      CLK   => CLK,
      RESET => RESET,

      REGIO_RX  => BUS_RX,
      REGIO_TX  => BUS_TX,
      
      BUS_RX(0) => busflash_rx,
      BUS_RX(1) => busspi_rx,
      BUS_RX(2) => busadc_rx,
      BUS_RX(3) => bussed_rx,
      BUS_RX(4) => busuart_rx,
      BUS_RX(5) => busflashset_rx,
      BUS_RX(6) => bustrig_rx,
      BUS_RX(7) => busmon_rx,
      BUS_RX(8) => busctrl_rx,
      BUS_TX(0) => busflash_tx,
      BUS_TX(1) => busspi_tx,
      BUS_TX(2) => busadc_tx,
      BUS_TX(3) => bussed_tx,
      BUS_TX(4) => busuart_tx,
      BUS_TX(5) => busflashset_tx,
      BUS_TX(6) => bustrig_tx,
      BUS_TX(7) => busmon_tx,
      BUS_TX(8) => busctrl_tx,
      STAT_DEBUG => open
      );



---------------------------------------------------------------------------
-- Flash & Reboot
---------------------------------------------------------------------------
  THE_SPI_RELOAD : entity work.spi_flash_and_fpga_reload_record
    port map(
      CLK_IN               => CLK,
      RESET_IN             => RESET,
      
      BUS_RX               => busflash_rx,
      BUS_TX               => busflash_tx,
      
      DO_REBOOT_IN         => REBOOT_IN,     
      PROGRAMN             => PROGRAMN,
      
      SPI_CS_OUT           => flash_cs_i,
      SPI_SCK_OUT          => flash_clk_i,
      SPI_SDO_OUT          => flash_out_i,
      SPI_SDI_IN           => FLASH_IN
      );

      
---------------------------------------------------------------------------
-- Load Settings from Flash
---------------------------------------------------------------------------      
THE_FLASH_REGS : entity work.load_settings
  port map(
    CLK        => CLK,
    RST        => RESET,
    
   -- the bus handler signals 
    BUS_RX          => busflashset_rx,
    BUS_TX          => busflashset_tx,
    
    IS_ACTIVE       => flashset_active,
    
    BUS_MASTER_TX   => bus_flash_rx_out,
    BUS_MASTER_RX   => bus_flash_tx_in,
    
    SPI_MOSI        => flash_out_s,
    SPI_MISO        => FLASH_IN,
    SPI_SCK         => flash_clk_s,
    SPI_NCS         => flash_cs_s
    
    );      

  BUS_MASTER_ACTIVE <= flashset_active or debug_active;
  FLASH_CS  <= flash_cs_i  when flashset_active = '0' else flash_cs_s;
  FLASH_CLK <= flash_clk_i when flashset_active = '0' else flash_clk_s;
  FLASH_OUT <= flash_out_i when flashset_active = '0' else flash_out_s;
  
  bus_flash_tx_in <= BUS_MASTER_IN;
  bus_debug_tx_in <= BUS_MASTER_IN;
  
  BUS_MASTER_OUT <= bus_debug_rx_out when debug_active = '1' else 
                    bus_flash_rx_out;
                    
 
---------------------------------------------------------------------------
-- SED Detection
---------------------------------------------------------------------------
  THE_SED : entity work.sedcheck
    port map(
      CLK       => CLK,
      ERROR_OUT => SED_ERROR_OUT,
      BUS_RX    => bussed_rx,
      BUS_TX    => bussed_tx,
      DEBUG     => open
      );        

      
---------------------------------------------------------------------------
-- ADC
---------------------------------------------------------------------------      
  busadc_tx.unknown <= '1';
  busadc_tx.nack    <= '0';
  busadc_tx.ack     <= '0';
  busadc_tx.data    <= (others => '0');


---------------------------------------------------------------------------
-- ADC
---------------------------------------------------------------------------        
gen_lcd : if INCLUDE_LCD = 1 generate
  THE_LCD : entity work.lcd
    port map(
      CLK   => CLK,
      RESET => RESET,
      
      MOSI  => lcd_mosi,
      SCK   => lcd_sck,
      DC    => lcd_dc,
      CS    => lcd_cs,
      RST   => lcd_rst,
      
      INPUT => LCD_DATA_IN,
      DEBUG => open
    );
end generate;  

---------------------------------------------------------------------------
-- SPI
---------------------------------------------------------------------------
  gen_SPI : if INCLUDE_SPI = 1 generate
    THE_SPI : spi_ltc2600
      port map(
        CLK_IN                 => CLK,
        RESET_IN               => RESET,
        -- Slave bus
        BUS_ADDR_IN            => busspi_rx.addr(4 downto 0),
        BUS_READ_IN            => busspi_rx.read,
        BUS_WRITE_IN           => busspi_rx.write,
        BUS_ACK_OUT            => busspi_tx.ack,
        BUS_BUSY_OUT           => busspi_tx.nack,
        BUS_DATA_IN            => busspi_rx.data,
        BUS_DATA_OUT           => busspi_tx.data,
        -- SPI connections
        SPI_CS_OUT(15 downto 0) => spi_cs,
        SPI_SDI_IN             => spi_sdi,
        SPI_SDO_OUT            => spi_sdo,
        SPI_SCK_OUT            => spi_sck
        );
    SPI_CS_OUT   <= spi_cs;
    SPI_CLK_OUT  <= (others => spi_sck);
    SPI_MOSI_OUT <= (others => spi_sdo);
    spi_sdi      <= (HEADER_IO(4) and not spi_cs(8)) or 
                    (ADC_MISO and not spi_cs(7)) or 
                    or_all(SPI_MISO_IN and not spi_cs and x"fe7f");
    
    ADC_CLK <= not spi_sck;
    ADC_CS  <= spi_cs(7);
    ADC_MOSI <= spi_sdo;
    
    busspi_tx.unknown <= '0';    
  end generate;

   gen_no_spi : if INCLUDE_SPI = 0 generate
     busspi_tx.unknown <= busspi_rx.write or busspi_rx.read;
     busspi_tx.ack <= '0'; busspi_tx.nack <= '0';
     busspi_tx.data <= (others => '0');
   end generate;

---------------------------------------------------------------------------
-- UART
---------------------------------------------------------------------------
  gen_uart : if INCLUDE_UART = 1 generate
    THE_UART : entity work.uart
      generic map(
        OUTPUTS => 1
        )
      port map(
        CLK       => CLK,
        RESET     => RESET,
        UART_RX(0)   => uart_rx,
        UART_TX(0)   => uart_tx, 
        BUS_RX    => busuart_rx,
        BUS_TX    => busuart_tx
        );
  end generate;      
   gen_no_uart : if INCLUDE_UART = 0 generate
     busuart_tx.unknown <= busuart_rx.write or busuart_rx.read;
     busuart_tx.ack <= '0'; busuart_tx.nack <= '0';
     busuart_tx.data <= (others => '0');
   end generate;

---------------------------------------------------------------------------
-- Debug Connection
---------------------------------------------------------------------------        
gen_debug : if INCLUDE_DEBUG_INTERFACE = 1 generate
  THE_DEBUG : entity work.debuguart
    port map(
      CLK => CLK,
      RESET => RESET, 
      
      RX_IN  => debug_rx,
      TX_OUT => debug_tx,
      
      DEBUG_ACTIVE  => debug_active,
    
      BUS_DEBUG_TX  => bus_debug_tx_in,
      BUS_DEBUG_RX  => bus_debug_rx_out,
      
      STATUS => debug_status
      
      );
end generate;
gen_nodebug : if INCLUDE_DEBUG_INTERFACE = 0 generate
  bus_debug_rx_out.write   <= '0';
  bus_debug_rx_out.read    <= '0';
  bus_debug_rx_out.timeout <= '0';
  bus_debug_rx_out.addr    <= (others => '0');
  bus_debug_rx_out.data    <= (others => '0');
  debug_tx <= 'Z';
  debug_active <= '0';
end generate;
  
---------------------------------------------------------------------------
-- Trigger logic
---------------------------------------------------------------------------
gen_TRIG_LOGIC : if INCLUDE_TRIGGER_LOGIC = 1 generate
  THE_TRIG_LOGIC : entity work.input_to_trigger_logic_record
    generic map(
      INPUTS    => TRIG_GEN_INPUT_NUM,
      OUTPUTS   => TRIG_GEN_OUTPUT_NUM
      )
    port map(
      CLK       => CLK,
      
      INPUT     => TRIG_GEN_INPUTS,
      OUTPUT    => TRIG_GEN_OUTPUTS,

      BUS_RX    => bustrig_rx,
      BUS_TX    => bustrig_tx
      );      

end generate;

gen_noTRIG_LOGIC : if INCLUDE_TRIGGER_LOGIC = 0 generate
     bustrig_tx.unknown <= bustrig_rx.write or bustrig_rx.read;
     bustrig_tx.ack <= '0'; bustrig_tx.nack <= '0';
     bustrig_tx.data <= (others => '0');
end generate;

---------------------------------------------------------------------------
-- Input Statistics
---------------------------------------------------------------------------
gen_STATISTICS : if INCLUDE_STATISTICS = 1 generate

  THE_STAT_LOGIC : entity work.input_statistics
    generic map(
      INPUTS    => MONITOR_INPUT_NUM,
      SINGLE_FIFO_ONLY => c_YES
      )
    port map(
      CLK       => CLK,
      
      INPUT     => MONITOR_INPUTS,

      DATA_IN   => busmon_rx.data,  
      DATA_OUT  => busmon_tx.data, 
      WRITE_IN  => busmon_rx.write,
      READ_IN   => busmon_rx.read,
      ACK_OUT   => busmon_tx.ack,  
      NACK_OUT  => busmon_tx.nack, 
      ADDR_IN   => busmon_rx.addr
      );
  busmon_tx.unknown <= '0';    
end generate;

gen_noSTATISTICS : if INCLUDE_STATISTICS = 0 generate
     busmon_tx.unknown <= busmon_rx.write or busmon_rx.read;
     busmon_tx.ack <= '0'; busmon_tx.nack <= '0';
     busmon_tx.data <= (others => '0');
end generate;

---------------------------------------------------------------------------
-- Additional control register
---------------------------------------------------------------------------  
proc_add_reg : process begin
  wait until rising_edge(CLK);
  busctrl_tx.ack     <= '0';
  busctrl_tx.nack    <= '0';
  busctrl_tx.unknown <= '0';
  
  if busctrl_rx.read = '1' then
    busctrl_tx.data(additional_reg_i'left downto 0) <= additional_reg_i;
    busctrl_tx.ack <= '1';
  elsif busctrl_rx.write = '1' then
    additional_reg_i <= busctrl_rx.data(additional_reg_i'left downto 0);
    busctrl_tx.ack <= '1';
  end if;
end process;

  ADDITIONAL_REG <= additional_reg_i;

---------------------------------------------------------------------------
-- HEADER_IO
---------------------------------------------------------------------------         
-- 1   UART TX
-- 2   UART RX
-- 3   SPI MOSI
-- 4   SPI MISO
-- 5   SPI CLK
-- 6   SPI CS
-- 7   lcd_dc
-- 8   lcd_rst
-- 9   Debug RX
-- 10  Debug TX
-- 11  3.3V
-- 12  3.3V
-- 13  GND
-- 14  GND

HEADER_IO(1)  <= uart_tx;
uart_rx       <= HEADER_IO(2);

gen_lcdio : if INCLUDE_LCD = 1 generate
  HEADER_IO(3)  <= lcd_mosi;
  HEADER_IO(5)  <= lcd_sck;
  HEADER_IO(6)  <= lcd_cs;
end generate;
gen_nolcdio : if INCLUDE_LCD = 0 generate
  HEADER_IO(3)  <= spi_sdo;
  -- HEADER_IO(4)  <= ;
  HEADER_IO(5)  <= spi_sck;
  HEADER_IO(6)  <= spi_cs(8);
end generate;


HEADER_IO(7)  <= lcd_dc;
HEADER_IO(8)  <= lcd_rst;
debug_rx      <= HEADER_IO(9);
HEADER_IO(10) <= debug_tx;

DEBUG_OUT <= debug_status;

      
end architecture;
