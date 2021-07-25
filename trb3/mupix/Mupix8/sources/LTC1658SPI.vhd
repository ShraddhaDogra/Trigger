----------------------------------------------------------------------------------
-- SPI Interface for the LTC1658 DACs on the mupix 8 sensorboard
-- used for controlling threshold + injection voltage and temperature measurement
-- Tobias Weber
-- Ruhr Unversitaet Bochum
-----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LTC1658SPI is
	generic(
		data_length : integer; -- bits in data word
		fpga_clock_speed : integer;-- clock speed of FPGA
		spi_clock_speed : integer);-- clock speed of SPI bus
  port(
    clk                  : in  std_logic; --clock
    reset                : in  std_logic; --reset
    start_write          : in  std_logic; --start writing data to DAC
    spi_data_in          : in  std_logic_vector(data_length - 1 downto 0); --data to write
    spi_data_from_chip   : in  std_logic; --serial data from dac
    spi_data_to_chip     : out std_logic; --seral data to dac shift register
    spi_data_out         : out std_logic_vector(data_length - 1 downto 0); --data read from shift register
    spi_clk              : out std_logic; --SPI interface clock
    spi_ld               : out std_logic); --SPI load/chip select          
end entity LTC1658SPI;


architecture rtl of LTC1658SPI is

  constant max_cycles : integer := fpga_clock_speed/spi_clock_speed;
	
  type   state_type is (waiting, sendbit1, sendbit2, loading1, loading2);
  signal state : state_type;

  signal shiftregister_out : std_logic_vector(data_length - 1 downto 0);
  signal shiftregister_in  : std_logic_vector(data_length - 1 downto 0);
  signal clkdiv : integer range 0 to max_cycles - 1;
  signal clk_enable : std_logic;
  signal clkdiv_reset : std_logic;
  signal wordcounter : integer range data_length - 1 downto 0;
  

begin

	clkdiv_reset <= reset or start_write;

	clk_div_proc : process(clk) is
	begin
		if rising_edge(clk) then
			if clkdiv_reset = '1' then
				clk_enable <= '0';
				clkdiv     <= 0;
			else
				if clkdiv = max_cycles - 1 then
					clk_enable <= '1';
					clkdiv     <= 0;
				else
					clk_enable <= '0';
					clkdiv     <= clkdiv + 1;
				end if;
			end if;
		end if;
	end process clk_div_proc;

	shift_out_proc : process(clk)
	begin
		if rising_edge(clk) then
			if (reset = '1') then
				wordcounter      <= 0;
				spi_data_to_chip <= '0';
				spi_clk          <= '0';
				spi_ld           <= '0';
				shiftregister_in <= (others => '0');
				state            <= waiting;
			else
				case state is
					when waiting =>
						wordcounter      <= 0;
						spi_data_to_chip <= '0';
						spi_clk          <= '0';
						spi_ld           <= '0';
						state            <= waiting;
						shiftregister_in <= (others => '0');
						if start_write = '1' then
							shiftregister_out <= spi_data_in;
							state             <= sendbit1;
						end if;
					when sendbit1 =>    --pull clock low and shift out new bit
						spi_clk          <= '0';
						spi_data_to_chip <= shiftregister_out(data_length - 1);
						if (clk_enable = '1') then
							shiftregister_out(data_length - 1 downto 1) <= shiftregister_out(data_length - 2 downto 0);
							shiftregister_out(0)                        <= '0';
							shiftregister_in                            <= shiftregister_in(data_length - 2 downto 0) & spi_data_from_chip;
							state                                       <= sendbit2;
						end if;
					when sendbit2 =>    --pull clock high
						spi_clk <= '1';
						if (clk_enable = '1') then
							if (wordcounter = data_length - 1) then -- we are done...
								state <= loading1;
							else
								state <= sendbit1;
								wordcounter <= wordcounter + 1;	
							end if;
						end if;
					when loading1 =>
						spi_clk <= '1';
						spi_ld  <= '1';
						if (clk_enable = '1') then
							state        <= loading2;
						end if;
					when loading2 =>
						spi_clk <= '0';
						spi_ld  <= '1';
						spi_data_to_chip <= '0';
						if (clk_enable = '1') then
							state        <= waiting;
							spi_data_out <= shiftregister_in;
						end if;
				end case;
			end if;
		end if;
	end process shift_out_proc;
	
	
end rtl;
