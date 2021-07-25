----------------------------------------------------------------------------------
-- SPI Interface for the ADS1018 ADC on the mupix 8 sensorboard
-- used for temperature measurement
-- Tobias Weber
-- Ruhr Unversitaet Bochum
-----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ADS1018SPI is
	generic(
		fpga_clock_speed : integer := 1e8;
		spi_clock_speed  : integer := 1e4
	);
	port(
		clk                : in  std_logic;
		reset              : in  std_logic;
		start_write        : in  std_logic; --start writing data to adc/start conversion
		config_in          : in  std_logic_vector(15 downto 0); --config data to adc
		spi_data_from_chip : in  std_logic; --serial data from dac
		spi_data_to_chip   : out std_logic; --seral data to dac shift register
		spi_data_out       : out std_logic_vector(31 downto 0); --conversion data and config readback
		spi_clk            : out std_logic; --SPI interface clock
		spi_cs             : out std_logic); --SPI chip select
end entity ADS1018SPI;

architecture RTL of ADS1018SPI is

	constant c_div_cnt_max : integer                              := fpga_clock_speed/spi_clock_speed;
	signal div_cnt         : integer range 0 to c_div_cnt_max - 1 := 0;

	type ads_fsm_type is (idle, cs_low, sendbit1, sendbit2, cs_high);
	signal ads_fsm_state : ads_fsm_type := idle;

	signal config_index   : integer range 0 to 15         := 15;
	signal byte_counter   : integer range 0 to 31         := 31;
	signal spi_data_out_i : std_logic_vector(31 downto 0) := (others => '0');

begin

	spi_proc : process(clk) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				spi_cs           <= '1';
				spi_clk          <= '0';
				spi_data_to_chip <= '0';
				spi_data_out     <= (others => '0');
				div_cnt          <= 0;
			else
				case ads_fsm_state is
					when idle =>
						spi_cs           <= '1';
						spi_clk          <= '0';
						spi_data_to_chip <= '0';
						div_cnt          <= 0;
						if start_write = '1' then
							config_index  <= 15;
							byte_counter  <= 31;
							spi_cs        <= '0';
							ads_fsm_state <= cs_low;
						end if;
					when cs_low =>
						div_cnt <= div_cnt + 1;
						if div_cnt = c_div_cnt_max - 1 then
							div_cnt       <= 0;
							ads_fsm_state <= sendbit1;
						end if;
					when sendbit1 =>
						spi_clk          <= '1';
						spi_data_to_chip <= config_in(config_index);
						div_cnt          <= div_cnt + 1;
						if div_cnt = c_div_cnt_max/2 then
							ads_fsm_state  <= sendbit2;
							spi_data_out_i <= spi_data_out_i(30 downto 0) & spi_data_from_chip;
						end if;
					when sendbit2 =>
						spi_clk <= '0';
						div_cnt <= div_cnt + 1;
						if div_cnt = c_div_cnt_max - 1 then
							div_cnt      <= 0;
							byte_counter <= byte_counter - 1;
							if config_index > 0 then
								config_index <= config_index - 1;
							else
								config_index <= 15;
							end if;
							if byte_counter > 0 then
								byte_counter  <= byte_counter - 1;
								ads_fsm_state <= sendbit1;
							else
								ads_fsm_state <= cs_high;
							end if;
						end if;
					when cs_high =>
						div_cnt <= div_cnt + 1;
						if div_cnt = c_div_cnt_max - 1 then
							div_cnt       <= 0;
							spi_cs        <= '1';
							ads_fsm_state <= idle;
							spi_data_out  <= spi_data_out_i;
						end if;
				end case;
			end if;
		end if;
	end process spi_proc;

end architecture RTL;
