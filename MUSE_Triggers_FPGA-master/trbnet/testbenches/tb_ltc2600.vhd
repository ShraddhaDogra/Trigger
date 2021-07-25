library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;



entity tb is
end entity;


architecture tb_arch of tb is

component spi_ltc2600 is
  port(
    CLK_IN          : in   std_logic;
    RESET_IN        : in   std_logic;
    -- Slave bus
    BUS_READ_IN     : in   std_logic;
    BUS_WRITE_IN    : in   std_logic;
    BUS_BUSY_OUT    : out  std_logic;
    BUS_ACK_OUT     : out  std_logic;
    BUS_ADDR_IN     : in   std_logic_vector(4 downto 0);
    BUS_DATA_IN     : in   std_logic_vector(31 downto 0);
    BUS_DATA_OUT    : out  std_logic_vector(31 downto 0);
    -- SPI connections
    SPI_CS_OUT      : out  std_logic;
    SPI_SDI_IN      : in   std_logic;
    SPI_SDO_OUT     : out  std_logic;
    SPI_SCK_OUT     : out  std_logic
    );
end component;


signal clk:   std_logic := '1';
signal reset: std_logic := '1';

signal write : std_logic := '0';
signal addr  : std_logic_vector(4 downto 0) := "00000";
signal data  : std_logic_vector(31 downto 0) := (others => '0');


begin

clk   <= not clk after 5 ns;
reset <= '0' after 100 ns;

the_ctrl: process begin
  wait for 200 ns;
  wait until rising_edge(clk); wait for 2 ns;
  addr  <= "00000";
  data  <= x"affedead";
  write <= '1';

  wait until rising_edge(clk); wait for 2 ns;
  addr  <= "00001";
  data  <= x"beeffeed";
  write <= '1';

  wait until rising_edge(clk); wait for 2 ns;
  addr  <= "00010";
  data  <= x"face5555";
  write <= '1';
  
  wait until rising_edge(clk); wait for 2 ns;
  addr  <= "10000";
  data  <= x"00000003";
  write <= '1';  

  wait until rising_edge(clk); wait for 2 ns;
  write <= '0';  

  wait for 1000 ns;
  wait until rising_edge(clk); wait for 2 ns;
  write <= '1';  
  wait until rising_edge(clk); wait for 2 ns;
  write <= '0';  
  wait;
  
  end process;



THE_DAC: spi_ltc2600
  port map(
    CLK_IN          => clk,
    RESET_IN        => reset,
    -- Slave bus
    BUS_READ_IN     => '0',
    BUS_WRITE_IN    => write,
    BUS_BUSY_OUT    => open,
    BUS_ACK_OUT     => open,
    BUS_ADDR_IN     => addr,
    BUS_DATA_IN     => data,
    BUS_DATA_OUT    => open,
    -- SPI connections
    SPI_CS_OUT      => open,
    SPI_SDI_IN      => '0',
    SPI_SDO_OUT     => open,
    SPI_SCK_OUT     => open
    );


end architecture;