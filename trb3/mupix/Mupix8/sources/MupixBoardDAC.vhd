-----------------------------------------------------------------------------------
-- Collection of all SPI interfaces controlling threshold, injection and other DACs
-- Tobias Weber
-- Ruhr Unversitaet Bochum
------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MupixBoardDAC is
	port(
		clk                  : in  std_logic; --clock
		reset                : in  std_logic; --reset
		--DAC signals
		spi_dout_dac        :  in  std_logic; --dac serial data from board
    	dac4_dout           :  in  std_logic; --serial data in from threshold dac
    	spi_dout_adc        :  in  std_logic; --adc serial data from board
    	spi_clk             :  out std_logic; --serial clock
    	spi_din             :  out std_logic; --serial data out
    	spi_ld_tmp_dac      :  out std_logic; --load temperature dac 
    	spi_ld_thres        :  out std_logic; --load threshold and injection dac
    	spi_cs_adc          :  out std_logic; --load adc 
    	injection_pulse     :  out std_logic; --injection pulse to board
		--TRB slow control
		SLV_READ_IN          : in  std_logic;
		SLV_WRITE_IN         : in  std_logic;
		SLV_DATA_OUT         : out std_logic_vector(31 downto 0);
		SLV_DATA_IN          : in  std_logic_vector(31 downto 0);
		SLV_ADDR_IN          : in  std_logic_vector(15 downto 0);
		SLV_ACK_OUT          : out std_logic;
		SLV_NO_MORE_DATA_OUT : out std_logic;
		SLV_UNKNOWN_ADDR_OUT : out std_logic);
end entity MupixBoardDAC;

architecture RTL of MupixBoardDAC is
	
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
	
	component injection_generator
	port(
		rst                  : in  std_logic;
    	clk                  : in  std_logic;
    	pulse_length         : in  std_logic_vector(15 downto 0); 
    	pulse_start          : in  std_logic;
    	pulse_o              : out std_logic 
	);
	end component injection_generator;
	
	constant c_bits_threshold_dacs : integer := 64;--4*16 bit of the four DACs
	signal start_write_threshold : std_logic := '0';
	signal spi_data_in_threshold : std_logic_vector(c_bits_threshold_dacs - 1 downto 0);
	signal spi_data_to_chip_threshold : std_logic;
	signal spi_data_out_threshold : std_logic_vector(c_bits_threshold_dacs - 1 downto 0);
	signal spi_clk_threshold : std_logic;
	
	constant c_bits_temperature_dac : integer := 16;
	signal start_write_temperature : std_logic := '0';
	signal spi_data_in_temperature : std_logic_vector(c_bits_temperature_dac - 1 downto 0);
	signal spi_data_to_chip_temperature : std_logic;
	signal spi_data_out_temperature : std_logic_vector(c_bits_temperature_dac - 1 downto 0);
	signal spi_clk_temperature_temperature : std_logic;
	
	signal start_write_adc : std_logic := '0';
	signal config_adc : std_logic_vector(15 downto 0);
	signal spi_data_to_chip_adc : std_logic;
	signal spi_data_out_adc : std_logic_vector(31 downto 0);
	signal spi_clk_adc : std_logic;
	
	signal pulse_start_i : std_logic := '0';
	signal pulse_length_i  : std_logic_vector(15 downto 0) := (others => '0');
	
begin
	
	spi_din <= spi_data_to_chip_threshold or spi_data_to_chip_temperature or spi_data_to_chip_adc;
	spi_clk <= spi_clk_threshold or spi_clk_temperature_temperature or spi_clk_adc;
	
	threshold_injection_dac : entity work.LTC1658SPI
		generic map(
			data_length      => c_bits_threshold_dacs, 
			fpga_clock_speed => 1e8, --100 MHz
			spi_clock_speed  => 5e4 --50 kHz
		)
		port map(
			clk                => clk,
			reset              => reset,
			start_write        => start_write_threshold,
			spi_data_in        => spi_data_in_threshold,
			spi_data_from_chip => dac4_dout,
			spi_data_to_chip   => spi_data_to_chip_threshold,
			spi_data_out       => spi_data_out_threshold,
			spi_clk            => spi_clk_threshold,
			spi_ld             => spi_ld_thres
		);
		
		temperature_dac : entity work.LTC1658SPI
			generic map(
				data_length      => c_bits_temperature_dac,
				fpga_clock_speed => 1e8, --100 MHz
				spi_clock_speed  => 5e4 --50 kHz
			)
			port map(
				clk                => clk,
				reset              => reset,
				start_write        => start_write_temperature,
				spi_data_in        => spi_data_in_temperature,
				spi_data_from_chip => spi_dout_dac,
				spi_data_to_chip   => spi_data_to_chip_temperature,
				spi_data_out       => spi_data_out_temperature,
				spi_clk            => spi_clk_temperature_temperature,
				spi_ld             => spi_ld_tmp_dac
			);
			
			
		temperature_adc : component ADS1018SPI
			generic map(
				fpga_clock_speed => 1e8,
				spi_clock_speed  => 5e4
			)
			port map(
				clk                => clk,
				reset              => reset,
				start_write        => start_write_adc,
				config_in          => config_adc,
				spi_data_from_chip => spi_dout_adc,
				spi_data_to_chip   => spi_data_to_chip_adc,
				spi_data_out       => spi_data_out_adc,
				spi_clk            => spi_clk_adc,
				spi_cs             => spi_cs_adc
			);		
			
		injection_gen_1 : component injection_generator
		port map(
			rst                  => reset,
    		clk                  => clk,
    		pulse_length         => pulse_length_i,
    		pulse_start          => pulse_start_i,
    		pulse_o              => injection_pulse
		);	
	-----------------------------------------------------------------------------
  	--TRB Slave Bus
  	--0x0090: threshold high and low dacs, 31:16 threshold high, 15:0 threshold low
  	--0x0091: threshold pix dac and injection dac, 31:16 pix dac, 15:0 injection dac
  	--0x0092: readback threshold high and low dacs, 31:16 threshold high, 15:0 threshold low
  	--0x0093: readback threshold pix dac and injection dac, 31:16 pix dac, 15:0 injection dac
  	--0x0094: temperature dac
  	--0x0095: readback temperature dac
  	--0x0096: start write threshold and injection dacs bit
  	--0x0097: write config adc
  	--0x0098: read adc data
  	--0x0099: injection length
  	-----------------------------------------------------------------------------
  	SLV_BUS_HANDLER : process(clk)
	begin                               -- process SLV_BUS_HANDLER
		if rising_edge(clk) then
			SLV_DATA_OUT          <= (others => '0');
			SLV_ACK_OUT           <= '0';
			SLV_UNKNOWN_ADDR_OUT  <= '0';
			SLV_NO_MORE_DATA_OUT  <= '0';
			start_write_threshold <= '0';
			start_write_temperature <= '0';
			start_write_adc       <= '0';
			pulse_start_i <= '0';

			if SLV_READ_IN = '1' then
				case SLV_ADDR_IN is
					when x"0090" =>
						SLV_DATA_OUT <= spi_data_in_threshold(63 downto 32);
						SLV_ACK_OUT  <= '1';
					when x"0091" =>
						SLV_DATA_OUT <= spi_data_in_threshold(31 downto 0);
						SLV_ACK_OUT  <= '1';
					when x"0092" =>
						SLV_DATA_OUT <= spi_data_out_threshold(63 downto 32);
						SLV_ACK_OUT  <= '1';
					when x"0093" =>
						SLV_DATA_OUT <= spi_data_out_threshold(31 downto 0);
						SLV_ACK_OUT  <= '1';
					when x"0094" =>
						SLV_DATA_OUT(15 downto 0) <= spi_data_in_temperature;
						SLV_ACK_OUT               <= '1';
					when x"0095" =>
						SLV_DATA_OUT(15 downto 0) <= spi_data_out_temperature;
						SLV_ACK_OUT               <= '1';
					when x"0097" =>
						SLV_DATA_OUT(15 downto 0) <= config_adc;
						SLV_ACK_OUT               <= '1';
					when x"0098" =>
						SLV_DATA_OUT              <= spi_data_out_adc;
						SLV_ACK_OUT               <= '1';
					when x"0099" =>
						SLV_DATA_OUT(15 downto 0)  <= pulse_length_i;
						SLV_ACK_OUT                <= '1';
					when others =>
						SLV_UNKNOWN_ADDR_OUT <= '1';
				end case;

			elsif SLV_WRITE_IN = '1' then
				case SLV_ADDR_IN is
					when x"0090" =>
						spi_data_in_threshold(63 downto 32) <= SLV_DATA_IN;
						SLV_ACK_OUT                         <= '1';
					when x"0091" =>
						spi_data_in_threshold(31 downto 0) <= SLV_DATA_IN;
						SLV_ACK_OUT                        <= '1';
					when x"0094" =>
						spi_data_in_temperature <= SLV_DATA_IN(15 downto 0);
						start_write_temperature <= '1';
						SLV_ACK_OUT             <= '1';
					when x"0096" =>
						start_write_threshold <= '1';
						SLV_ACK_OUT           <= '1';
					when x"0097" =>
						config_adc            <= SLV_DATA_IN(15 downto 0);
						start_write_adc       <= '1';
						SLV_ACK_OUT           <= '1';
					when x"0099" =>
						pulse_start_i  <= '1';
						pulse_length_i <= SLV_DATA_IN(15 downto 0);
						SLV_ACK_OUT    <= '1';
					when others =>
						SLV_UNKNOWN_ADDR_OUT <= '1';
				end case;

			end if;
		end if;
	end process SLV_BUS_HANDLER;

end architecture RTL;
