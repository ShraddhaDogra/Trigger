
LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;


entity spi_flash_and_fpga_reload is
  port(
    CLK_IN               : in  std_logic;
    RESET_IN             : in  std_logic;
    
    BUS_ADDR_IN          : in  std_logic_vector(8 downto 0);
    BUS_READ_IN          : in  std_logic;
    BUS_WRITE_IN         : in  std_logic;
    BUS_DATAREADY_OUT    : out std_logic;
    BUS_WRITE_ACK_OUT    : out std_logic;
    BUS_UNKNOWN_ADDR_OUT : out std_logic;
    BUS_NO_MORE_DATA_OUT : out std_logic;
    BUS_DATA_IN          : in  std_logic_vector(31 downto 0);
    BUS_DATA_OUT         : out std_logic_vector(31 downto 0);
    
    DO_REBOOT_IN   : in  std_logic;      
    PROGRAMN       : out std_logic;
    
    SPI_CS_OUT     : out std_logic;
    SPI_SCK_OUT    : out std_logic;
    SPI_SDO_OUT    : out std_logic;
    SPI_SDI_IN     : in  std_logic
    );
end entity;


architecture flash_reboot_arch of spi_flash_and_fpga_reload is

  signal spictrl_read_en         : std_logic;
  signal spictrl_write_en        : std_logic;
  signal spictrl_data_in         : std_logic_vector(31 downto 0);
  signal spictrl_addr            : std_logic;
  signal spictrl_data_out        : std_logic_vector(31 downto 0);
  signal spictrl_ack             : std_logic;
  signal spictrl_busy            : std_logic;
  signal spimem_read_en          : std_logic;
  signal spimem_write_en         : std_logic;
  signal spimem_data_in          : std_logic_vector(31 downto 0);
  signal spimem_addr             : std_logic_vector(5 downto 0);
  signal spimem_data_out         : std_logic_vector(31 downto 0);
  signal spimem_ack              : std_logic;
  
  signal spi_bram_addr           : std_logic_vector(7 downto 0);
  signal spi_bram_wr_d           : std_logic_vector(7 downto 0);
  signal spi_bram_rd_d           : std_logic_vector(7 downto 0);
  signal spi_bram_we             : std_logic;

begin



THE_BUS_HANDLER : trb_net16_regio_bus_handler
  generic map(
    PORT_NUMBER    => 2,
    PORT_ADDRESSES => (0 => x"0000", 1 => x"0100", others => x"0000"),
    PORT_ADDR_MASK => (0 => 1,       1 => 6,       others => 0)
    )
  port map(
    CLK                   => CLK_IN,
    RESET                 => RESET_IN,

    DAT_ADDR_IN(8 downto 0) => BUS_ADDR_IN,
    DAT_ADDR_IN(15 downto 9)=>(others => '0'),
    DAT_DATA_IN           => BUS_DATA_IN,
    DAT_DATA_OUT          => BUS_DATA_OUT,
    DAT_READ_ENABLE_IN    => BUS_READ_IN,
    DAT_WRITE_ENABLE_IN   => BUS_WRITE_IN,
    DAT_TIMEOUT_IN        => '0',
    DAT_DATAREADY_OUT     => BUS_DATAREADY_OUT,
    DAT_WRITE_ACK_OUT     => BUS_WRITE_ACK_OUT,
    DAT_NO_MORE_DATA_OUT  => BUS_NO_MORE_DATA_OUT,
    DAT_UNKNOWN_ADDR_OUT  => BUS_UNKNOWN_ADDR_OUT,

  --Bus Handler (SPI CTRL)
    BUS_READ_ENABLE_OUT(0)              => spictrl_read_en,
    BUS_WRITE_ENABLE_OUT(0)             => spictrl_write_en,
    BUS_DATA_OUT(0*32+31 downto 0*32)   => spictrl_data_in,
    BUS_ADDR_OUT(0*16)                  => spictrl_addr,
    BUS_ADDR_OUT(0*16+15 downto 0*16+1) => open,
    BUS_TIMEOUT_OUT(0)                  => open,
    BUS_DATA_IN(0*32+31 downto 0*32)    => spictrl_data_out,
    BUS_DATAREADY_IN(0)                 => spictrl_ack,
    BUS_WRITE_ACK_IN(0)                 => spictrl_ack,
    BUS_NO_MORE_DATA_IN(0)              => spictrl_busy,
    BUS_UNKNOWN_ADDR_IN(0)              => '0',
    
  --Bus Handler (SPI Memory)
    BUS_READ_ENABLE_OUT(1)              => spimem_read_en,
    BUS_WRITE_ENABLE_OUT(1)             => spimem_write_en,
    BUS_DATA_OUT(1*32+31 downto 1*32)   => spimem_data_in,
    BUS_ADDR_OUT(1*16+5 downto 1*16)    => spimem_addr,
    BUS_ADDR_OUT(1*16+15 downto 1*16+6) => open,
    BUS_TIMEOUT_OUT(1)                  => open,
    BUS_DATA_IN(1*32+31 downto 1*32)    => spimem_data_out,
    BUS_DATAREADY_IN(1)                 => spimem_ack,
    BUS_WRITE_ACK_IN(1)                 => spimem_ack,
    BUS_NO_MORE_DATA_IN(1)              => '0',
    BUS_UNKNOWN_ADDR_IN(1)              => '0',
    STAT_DEBUG => open
    );


THE_SPI_MASTER: spi_master
  port map(
    CLK_IN         => CLK_IN,
    RESET_IN       => RESET_IN,
    -- Slave bus
    BUS_READ_IN    => spictrl_read_en,
    BUS_WRITE_IN   => spictrl_write_en,
    BUS_BUSY_OUT   => spictrl_busy,
    BUS_ACK_OUT    => spictrl_ack,
    BUS_ADDR_IN(0) => spictrl_addr,
    BUS_DATA_IN    => spictrl_data_in,
    BUS_DATA_OUT   => spictrl_data_out,
    -- SPI connections
    SPI_CS_OUT     => SPI_CS_OUT,
    SPI_SDI_IN     => SPI_SDI_IN,
    SPI_SDO_OUT    => SPI_SDO_OUT,
    SPI_SCK_OUT    => SPI_SCK_OUT,
    -- BRAM for read/write data
    BRAM_A_OUT     => spi_bram_addr,
    BRAM_WR_D_IN   => spi_bram_wr_d,
    BRAM_RD_D_OUT  => spi_bram_rd_d,
    BRAM_WE_OUT    => spi_bram_we,
    -- Status lines
    STAT           => open
    );

-- data memory for SPI accesses
THE_SPI_MEMORY: spi_databus_memory
  port map(
    CLK_IN        => CLK_IN,
    RESET_IN      => RESET_IN,
    -- Slave bus
    BUS_ADDR_IN   => spimem_addr,
    BUS_READ_IN   => spimem_read_en,
    BUS_WRITE_IN  => spimem_write_en,
    BUS_ACK_OUT   => spimem_ack,
    BUS_DATA_IN   => spimem_data_in,
    BUS_DATA_OUT  => spimem_data_out,
    -- state machine connections
    BRAM_ADDR_IN  => spi_bram_addr,
    BRAM_WR_D_OUT => spi_bram_wr_d,
    BRAM_RD_D_IN  => spi_bram_rd_d,
    BRAM_WE_IN    => spi_bram_we,
    -- Status lines
    STAT          => open
    );
    
---------------------------------------------------------------------------
-- Reboot FPGA
---------------------------------------------------------------------------
THE_FPGA_REBOOT : fpga_reboot
  port map(
    CLK       => CLK_IN,
    RESET     => RESET_IN,
    DO_REBOOT => DO_REBOOT_IN,
    PROGRAMN  => PROGRAMN
    );

    
end architecture;