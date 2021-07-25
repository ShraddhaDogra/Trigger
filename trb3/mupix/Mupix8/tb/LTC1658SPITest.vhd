library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LTC1658SPITest is
end entity LTC1658SPITest;

architecture simulation of LTC1658SPITest is
	
	component LTC1658SPI
		generic(
			data_length      : integer;
			fpga_clock_speed : integer;
			spi_clock_speed  : integer
		);
		port(
			clk                : in  std_logic;
			reset              : in  std_logic;
			start_write        : in  std_logic;
			spi_data_in        : in  std_logic_vector(data_length - 1 downto 0);
			spi_data_from_chip : in  std_logic;
			spi_data_to_chip   : out std_logic;
			spi_data_out       : out std_logic_vector(data_length - 1 downto 0);
			spi_clk            : out std_logic;
			spi_ld             : out std_logic
		);
	end component LTC1658SPI;
	
	
	constant data_length : integer := 16;
	constant clk_period  : time := 10 ns;

	signal clk                	: std_logic;
	signal reset 				: std_logic := '0';
	signal start_write 			: std_logic := '0';
	signal spi_data_in 			: std_logic_vector(data_length - 1 downto 0);
	signal spi_data_from_chip 	: std_logic := '0';
	signal spi_data_to_chip 	: std_logic;
	signal spi_data_out 		: std_logic_vector(data_length - 1 downto 0);
	signal spi_clk 				: std_logic;
	signal spi_ld 				: std_logic;
	
	signal shiftreg : std_logic_vector(data_length - 1 downto 0) := (others => '0');
	
begin
	
	dut : entity work.LTC1658SPI
		generic map(
			data_length      => data_length,
			fpga_clock_speed => 100,
			spi_clock_speed  => 10
		)
		port map(
			clk                => clk,
			reset              => reset,
			start_write        => start_write,
			spi_data_in        => spi_data_in,
			spi_data_from_chip => spi_data_from_chip,
			spi_data_to_chip   => spi_data_to_chip,
			spi_data_out       => spi_data_out,
			spi_clk            => spi_clk,
			spi_ld             => spi_ld
		);
		
	clk_gen : process is
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process clk_gen;
	
	ltcshiftreg : process(spi_clk) is
	begin
		if spi_clk'event and spi_clk = '1' then
			spi_data_from_chip <= shiftreg(data_length - 1) after 5 ns;
			shiftreg <= shiftreg(data_length - 2 downto 0) & spi_data_to_chip;
		end if;
	end process ltcshiftreg;
	
		
	stimulus : process is
	begin
		wait for 100 ns;
		spi_data_in <= x"AAAA";
		start_write <= '1';
		wait for clk_period;
		start_write <= '0';
		wait for 5 us;
		spi_data_in <= x"BBBB";
		start_write <= '1';
		wait for clk_period;
		start_write <= '0';
		wait;
	end process stimulus;
	
	

end architecture simulation;
