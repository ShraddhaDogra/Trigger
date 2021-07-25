library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;

entity testbench is
end entity;

architecture testbench_arch of testbench is


  component adc_ltc2308_readout
    generic(
      CLOCK_FREQUENCY : integer := 100; --MHz
      PRESET_RANGES : range_ram_t := (x"FFF_000",  x"B50_C10", x"480_4E0", x"510_6A0",
                                  --   -3           3           1.2         1.4
                                  --    ???         2.9-3.1     1.15-1.25   1.3-1.7
                                      x"C80_D48", x"D48_ED8", x"A28_960", x"A28_960")
                                  --    3.3         3.5         5V/2        5V/2
                                  --    3.2-3.4     3.4-3.8     2.4-2.6     2.4-2.6

      );
    port(
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      ADC_SCK       : out std_logic;
      ADC_SDI       : out std_logic;
      ADC_SDO       : in  std_logic;
      ADC_CONVST    : out std_logic;

      DAT_ADDR_IN          : in  std_logic_vector(5 downto 0);
      DAT_READ_EN_IN       : in  std_logic;
      DAT_WRITE_EN_IN      : in  std_logic;
      DAT_DATA_OUT         : out std_logic_vector(31 downto 0);
      DAT_DATA_IN          : in  std_logic_vector(31 downto 0);
      DAT_DATAREADY_OUT    : out std_logic;
      DAT_NO_MORE_DATA_OUT : out std_logic;
      DAT_WRITE_ACK_OUT    : out std_logic;
      DAT_UNKNOWN_ADDR_OUT : out std_logic;
      DAT_TIMEOUT_IN       : in  std_logic;

      STAT_VOLTAGES_OUT    : out std_logic_vector(31 downto 0)
      );
    end component;

  signal CLK         :  std_logic := '1';
  signal RESET       :  std_logic := '1';
  signal CLK_EN      :  std_logic := '1';
  signal ADC_SDO     :  std_logic := '0';
  signal ADC_SCK     :  std_logic;
  signal ADC_SDI     :  std_logic;
  signal ADC_CONVST  :  std_logic;

  signal DAT_ADDR_IN          :  std_logic_vector(5 downto 0) := "000000";
  signal DAT_READ_EN_IN       :  std_logic := '0';
  signal DAT_WRITE_EN_IN      :  std_logic := '0';
  signal DAT_DATA_OUT         :  std_logic_vector(31 downto 0);
  signal DAT_DATA_IN          :  std_logic_vector(31 downto 0);
  signal DAT_DATAREADY_OUT    :  std_logic;
  signal DAT_NO_MORE_DATA_OUT :  std_logic;
  signal DAT_WRITE_ACK_OUT    :  std_logic;
  signal DAT_UNKNOWN_ADDR_OUT :  std_logic;
  signal DAT_TIMEOUT_IN       :  std_logic := '0';




begin
  CLK <= not CLK after 5 ns;
  RESET <= '0' after 50 ns;


  uut: adc_ltc2308_readout
    port map(
      CLK => CLK,
      RESET => RESET,
      CLK_EN => CLK_EN,
      ADC_SCK => ADC_SCK,
      ADC_SDI => ADC_SDI,
      ADC_SDO => ADC_SDO,
      ADC_CONVST => ADC_CONVST,
      DAT_ADDR_IN          => DAT_ADDR_IN,
      DAT_READ_EN_IN       => DAT_READ_EN_IN,
      DAT_WRITE_EN_IN      => DAT_WRITE_EN_IN,
      DAT_DATA_OUT         => DAT_DATA_OUT,
      DAT_DATA_IN          => DAT_DATA_IN,
      DAT_DATAREADY_OUT    => DAT_DATAREADY_OUT,
      DAT_NO_MORE_DATA_OUT => DAT_NO_MORE_DATA_OUT,
      DAT_WRITE_ACK_OUT    => DAT_WRITE_ACK_OUT,
      DAT_UNKNOWN_ADDR_OUT => DAT_UNKNOWN_ADDR_OUT,
      DAT_TIMEOUT_IN       => DAT_TIMEOUT_IN
      );

ADC_SDO <= '0';

--Register Map
--00     Control Register     0 Conversion Enable  1 single measurement  2 reset min/max/overview, 3 compare enable
--01     Overview             1 nibble for each channel: 0 Voltage ok, 1 Voltage too low, 2 Voltage too high
--10-17  Measurements         0-11 current value, 12-21 min value(10bit), 22-31 max value(10bit)
--20-27  Voltage Range CTRL   0-11 min value  16-27 max value
DAT_DATA_IN <= x"00000000", x"0000000D" after 2001ns, x"00000000" after 2021ns;--,
--                            x"00000000" after 15001ns, x"00000000" after 15021ns,
--                            x"0000000A" after 29001ns, x"00000000" after 29021ns;
DAT_ADDR_IN <= "000000";
DAT_WRITE_EN_IN <= '0', '1' after 2001ns,'0' after 2021ns;--,
--                        '1' after 15001ns,'0' after 15021ns,
--                        '1' after 29001ns,'0' after 29021ns;


end architecture;
