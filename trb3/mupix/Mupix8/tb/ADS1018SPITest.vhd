library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ADS1018SPITest is
end entity ADS1018SPITest;
 
architecture sim of ADS1018SPITest is
	
	component ADS1018SPI
		generic(
			fpga_clock_speed : integer := 1e8;
			spi_clock_speed  : integer := 1e4
		);
		port(
			clk                : in  std_logic;
			reset              : in  std_logic;
			start_write        : in  std_logic;
			config_in          : in  std_logic_vector(15 downto 0);
			spi_data_from_chip : in  std_logic;
			spi_data_to_chip   : out std_logic;
			spi_data_out       : out std_logic_vector(31 downto 0);
			spi_clk            : out std_logic;
			spi_cs             : out std_logic
		);
	end component ADS1018SPI;
	
	constant c_fpga_clock_speed : integer := 1e8;
	constant c_spi_clock_speed  : integer := 5e6;
	constant c_clock_period     : time    := 10 ns;
	--dut interface signals
	signal clk                  : std_logic;
	signal reset                : std_logic := '0';
	signal start_write          : std_logic := '0';
	signal config_in            : std_logic_vector(15 downto 0) := (others => '0');
	signal spi_data_from_chip   : std_logic;
	signal spi_data_to_chip     : std_logic;
	signal spi_data_out         : std_logic_vector(31 downto 0);
	signal spi_clk              : std_logic;
	signal spi_cs               : std_logic;
	
	signal config_chip, config_chip_new : std_logic_vector(15 downto 0) := (others => '0');
	signal data_chip                    : std_logic_vector(15 downto 0) := x"AACC";
	signal shiftreg_reg                 : std_logic_vector(31 downto 0) := (others => '0');
		
begin
	
	dut : entity work.ADS1018SPI
		generic map(
			fpga_clock_speed => c_fpga_clock_speed,
			spi_clock_speed  => c_spi_clock_speed
		)
		port map(
			clk                => clk,
			reset              => reset,
			start_write        => start_write,
			config_in          => config_in,
			spi_data_from_chip => spi_data_from_chip,
			spi_data_to_chip   => spi_data_to_chip,
			spi_data_out       => spi_data_out,
			spi_clk            => spi_clk,
			spi_cs             => spi_cs
		);
		
	ADS_response : process(spi_cs, spi_clk) is
	begin
		if spi_cs'event and spi_cs = '0' then
			shiftreg_reg   <= data_chip & config_chip after 100 ns;
		end if;
		if spi_cs'event and spi_cs = '1' then
			config_chip <= config_chip_new;
		end if;
		if spi_clk'event and spi_clk = '1' then --on rising clock edge write out new bit
			spi_data_from_chip <= shiftreg_reg(shiftreg_reg'length - 1);
			shiftreg_reg <= shiftreg_reg(shiftreg_reg'length - 2 downto 0) & '0' after 100 ns;
		end if;
		if spi_clk'event and spi_clk = '0' then --on falling clock edge load new data to config bit
			config_chip_new <= config_chip_new(config_chip_new'length - 2 downto 0) & spi_data_to_chip;
		end if;
	end process ADS_response;
		
		
	clk_generation : process is
	begin
		clk <= '1';
		wait for c_clock_period/2;
		clk <= '0';
		wait for c_clock_period/2;
	end process clk_generation;
	
	stimulus : process is
	begin
		wait for 100 ns;
		config_in <= x"BCDB";
		start_write <= '1';
		wait for c_clock_period;
		start_write <= '0';
		if spi_cs = '0' then
			wait until spi_cs = '1';
		end if;
		wait for 200*c_clock_period;
		config_in <= x"BCDB";
		start_write <= '1';
		wait for c_clock_period;
		start_write <= '0';
		wait;
	end process stimulus;
	
	
end architecture sim;
