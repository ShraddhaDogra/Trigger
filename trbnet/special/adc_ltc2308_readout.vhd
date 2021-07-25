--sequential readout of all eight single-ended channels of a LT2306 ADC via SPI interface

--Register Map
--00     Control Register     0 Conversion Enable  1 single measurement  2 reset min/max/overview, 3 compare enable
--01     Overview             1 nibble for each channel: 0 Voltage ok, 1 Voltage too low, 2 Voltage too high
--10-17  Measurements         0-11 current value
--18-1F  Measurements min/max 0-11 minimum, 16-27 maximum
--20-27  Voltage Range CTRL   0-11 min value  16-27 max value


LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;

entity adc_ltc2308_readout is
  generic(
    CLOCK_FREQUENCY : integer := 100; --MHz
    PRESET_RANGES_CH0 : std_logic_vector(23 downto 0) := x"B6D_A28" ; --5V/2 -  2.4-3.1
    PRESET_RANGES_CH1 : std_logic_vector(23 downto 0) := x"A00_960" ; --5V/2 -  2.4-2.6
    PRESET_RANGES_CH2 : std_logic_vector(23 downto 0) := x"E70_DAC" ; --3.5 -   3.4-3.8
    PRESET_RANGES_CH3 : std_logic_vector(23 downto 0) := x"D80_CB0" ; --3.3 -   3.2-3.4
    PRESET_RANGES_CH4 : std_logic_vector(23 downto 0) := x"6A0_5B0" ; --1.4 -   1.3-1.9
    PRESET_RANGES_CH5 : std_logic_vector(23 downto 0) := x"500_480" ; --1.2 -   1.15-1.25
    PRESET_RANGES_CH6 : std_logic_vector(23 downto 0) := x"BF0_B55" ; --3.0 -   2.9-3.1
    PRESET_RANGES_CH7 : std_logic_vector(23 downto 0) := x"C18_B50"   --3.0 -   2.9-3.1
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
end entity;

architecture adc_readout_arch of adc_ltc2308_readout is

  component ram_dp_rw is
    generic(
      depth : integer := 3;
      width : integer := 12
      );
    port(
      CLK   : in  std_logic;
      wr1   : in  std_logic;
      a1    : in  std_logic_vector(depth-1 downto 0);
      din1  : in  std_logic_vector(width-1 downto 0);
      a2    : in  std_logic_vector(depth-1 downto 0);
      dout2 : out std_logic_vector(width-1 downto 0)
      );
  end component;

  component signal_sync is
    generic(
      WIDTH : integer := 1;     --
      DEPTH : integer := 3
      );
    port(
      RESET    : in  std_logic; --Reset is neceessary to avoid optimization to shift register
      CLK0     : in  std_logic;                          --clock for first FF
      CLK1     : in  std_logic;                          --Clock for other FF
      D_IN     : in  std_logic_vector(WIDTH-1 downto 0); --Data input
      D_OUT    : out std_logic_vector(WIDTH-1 downto 0)  --Data output
      );
  end component;

  component ram_dp is
    generic(
      depth : integer := 3;
      width : integer := 16
      );
    port(
      CLK   : in  std_logic;
      wr1   : in  std_logic;
      a1    : in  std_logic_vector(depth-1 downto 0);
      dout1 : out std_logic_vector(width-1 downto 0);
      din1  : in  std_logic_vector(width-1 downto 0);
      a2    : in  std_logic_vector(depth-1 downto 0);
      dout2 : out std_logic_vector(width-1 downto 0)
      );
  end component;

  signal ram_write       : std_logic;
  signal ram_addr        : std_logic_vector(2 downto 0);
  signal ram_data        : std_logic_vector(35 downto 0);
  signal ram_data_out    : std_logic_vector(35 downto 0);
  signal timecounter     : unsigned(9 downto 0);
  signal current_channel : std_logic_vector(2 downto 0);
  signal last_channel    : std_logic_vector(2 downto 0);
  signal output_data     : std_logic_vector(11 downto 6);
  signal input_data      : std_logic_vector(11 downto 0);
  signal reg_ADC_SDO     : std_logic;
  type state_t is (IDLE, SEND_DATA, WAITING);
  signal state           : state_t;
  signal state_bits      : std_logic_vector(2 downto 0);
  signal range_ram_wr        : std_logic;
  signal range_ram_addr      : std_logic_vector(2 downto 0);
  signal range_ram_data      : std_logic_vector(23 downto 0);
  signal range_ram_data_out  : std_logic_vector(23 downto 0);
  signal conv_enabled        : std_logic;
  signal conv_single         : std_logic;
  signal conv_single_clr     : std_logic;
  signal conv_reset_clr      : std_logic;
  signal conv_reset          : std_logic;
  signal real_conv_reset     : std_logic;
  signal conv_compare_enable : std_logic;
  signal current_minimum     : std_logic_vector(11 downto 0);
  signal current_maximum     : std_logic_vector(11 downto 0);
  signal status_overview     : std_logic_vector(31 downto 0);
  signal value_ram_data      : std_logic_vector(35 downto 0);
  signal value_ram_addr      : std_logic_vector(2 downto 0);
  signal last_DAT_READ_EN_IN : std_logic;
  signal last_last_DAT_READ_EN_IN : std_logic;

  type value_ram_t is array(7 downto 0) of std_logic_vector(35 downto 0);
  signal value_ram : value_ram_t := (x"000000000",x"000000001",x"000000002",x"000000003",x"000000004",
                                     x"000000005",x"000000006",x"000000007");

  type range_ram_t is array(7 downto 0) of std_logic_vector(23 downto 0);
  signal range_ram : range_ram_t := (PRESET_RANGES_CH7,PRESET_RANGES_CH6,PRESET_RANGES_CH5,PRESET_RANGES_CH4,
                                    PRESET_RANGES_CH3,PRESET_RANGES_CH2,PRESET_RANGES_CH1,PRESET_RANGES_CH0);
  signal first_sequence_after_stop : std_logic;

begin

  assert CLOCK_FREQUENCY <= 200
  report "The clock frequency is too high, timing requirements of ADC not met."
  severity FAILURE;



  state_bits(0) <= '1' when state = IDLE else '0';
  state_bits(1) <= '1' when state = SEND_DATA else '0';
  state_bits(2) <= '1' when state = WAITING else '0';


  THE_VALUE_RAM : process(CLK)
    begin
      if rising_edge(CLK) then
        if ram_write = '1' then
          value_ram(to_integer(unsigned(ram_addr))) <= ram_data;
        end if;
        ram_data_out <= value_ram(to_integer(unsigned(ram_addr)));
        value_ram_data <= value_ram(to_integer(unsigned(value_ram_addr)));
      end if;
    end process;

--   THE_VALUE_RAM : ram_dp
--     generic map(
--       depth => 3,
--       width => 36
--       )
--     port map(
--       CLK   => CLK,
--       wr1   => ram_write,
--       a1    => ram_addr,
--       din1  => ram_data,
--       dout1 => ram_data_out,
--       a2    => value_ram_addr,
--       dout2 => value_ram_data
--       );

  ram_addr  <= std_logic_vector(unsigned(last_channel));
  value_ram_addr <= range_ram_addr;


  THE_RANGE_RAM : process(CLK)
    begin
      if rising_edge(CLK) then
--         if range_ram_wr = '1' then
--           range_ram(to_integer(unsigned(range_ram_addr))) <= range_ram_data;
--         end if;
        range_ram_data_out <= range_ram(to_integer(unsigned(range_ram_addr)));
        current_minimum <= range_ram(to_integer(unsigned(last_channel)))(11 downto 0);
        current_maximum <= range_ram(to_integer(unsigned(last_channel)))(23 downto 12);
      end if;
    end process;


  THE_ADC_SDO_sync : signal_sync
    generic map(
      WIDTH => 1,
      DEPTH => 2
      )
    port map(
      RESET    => RESET,
      CLK0     => CLK,
      CLK1     => CLK,
      D_IN(0)  => ADC_SDO,
      D_OUT(0) => reg_ADC_SDO
      );



  proc_fsm : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          state           <= IDLE;
          ADC_SCK         <= '0';
          ADC_CONVST      <= '1';
          ram_write       <= '0';
          last_channel    <= "111";
          current_channel <= "000";
          input_data      <= (others => '0');
          timecounter     <= (others => '0');
--           status_overview <= (others => '0');
          first_sequence_after_stop <= '1';
          real_conv_reset <= '0';
          conv_reset_clr  <= '0';
        elsif CLK_EN = '1' then
          timecounter <= timecounter + to_unsigned(1,1);
          case state is
            when IDLE =>
              -- output bits: singleended/not differential & channel number(3) & unipolar/not bipolar & sleepmode
              output_data     <= "1" & current_channel(0) & current_channel(2) & (current_channel(1)) & "10";
              input_data      <= (others => '0');
              timecounter     <= (others => '0');
              ADC_SCK         <= '0';
              ram_write       <= '0';
              conv_single_clr <= '0';
              if conv_reset = '1' then
                status_overview <= (others => '0');
              end if;
              if conv_enabled = '1' or conv_single = '1' then
                state           <= SEND_DATA;
                ADC_CONVST      <= '0';       --wake up device from nap,
              else
                current_channel <= "000";
                state <= IDLE;
              end if;

            when SEND_DATA =>
              if timecounter(2 downto 0) = 0 then
                ADC_SDI                  <= output_data(output_data'left);
                ADC_SCK                  <= '0';
                output_data              <= output_data(output_data'left -1 downto output_data'right) & '0';
              elsif timecounter(2 downto 0) = 4 then
                ADC_SCK                  <= '1';
              elsif timecounter(2 downto 0) = 6 then   --read on rising_edge, but delayed by two FF
                input_data               <= input_data(input_data'left -1 downto 0) & reg_ADC_SDO;
              end if;
              if timecounter(6 downto 3) = 12 then     --read/wrote 12 Bits
                state                    <= WAITING;
                ram_data                 <= ram_data_out;
                ram_write                <= not first_sequence_after_stop;
                ram_data(11 downto 0)    <= input_data;
                if unsigned(input_data(11 downto 0)) < unsigned(ram_data_out(23 downto 12)) or real_conv_reset = '1' then
                  ram_data(23 downto 12) <= input_data(11 downto 0);
                end if;
                if unsigned(input_data(11 downto 0)) > unsigned(ram_data_out(35 downto 24)) or real_conv_reset = '1' then
                  ram_data(35 downto 24) <= input_data(11 downto 0);
                end if;

                if conv_compare_enable = '1' and first_sequence_after_stop = '0' then
                  if input_data < current_minimum then   --too low
                    status_overview(to_integer(unsigned(last_channel))*4+1) <= '1';
                    status_overview(to_integer(unsigned(last_channel))*4)   <= '0';
                  elsif input_data > current_maximum then--too high
                    status_overview(to_integer(unsigned(last_channel))*4+2) <= '1';
                    status_overview(to_integer(unsigned(last_channel))*4)   <= '0';
                  else
                    status_overview(to_integer(unsigned(last_channel))*4)   <= '1';
                  end if;
                end if;
              end if;

            when WAITING =>
              ram_write           <= '0';
              if timecounter(7) = '1' then  --after 128 clock cycles = at least 640 ns after first bit
                ADC_CONVST        <= '1';       --left high until conv. finished to get into nap-sleep mode
              end if;
              if timecounter(9) = '1' then  --after 512 clock cycles = at least 2560 ns after first bit
                state             <= IDLE;
                current_channel   <= std_logic_vector(unsigned(current_channel) + to_unsigned(1,1));
                last_channel    <= current_channel;
                first_sequence_after_stop <= '0';
                if current_channel = "111" then
                  conv_single_clr <= conv_single;   --end single run after channel 8
                  real_conv_reset <= conv_reset and not real_conv_reset;
                  conv_reset_clr  <= real_conv_reset;
                end if;
              end if;

            when others =>
              state           <= IDLE;
          end case;
          if real_conv_reset = '1' then          --clear status bits on request
            status_overview <= (others => '0');
          end if;
        end if;
      end if;
    end process;




  proc_reg_ctrl : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          DAT_UNKNOWN_ADDR_OUT <= '0';
          DAT_WRITE_ACK_OUT    <= '0';
          DAT_NO_MORE_DATA_OUT <= '0';
          DAT_DATAREADY_OUT    <= '0';
          DAT_DATA_OUT         <= (others => '0');
          range_ram_wr         <= '0';
          conv_enabled         <= '1';
          conv_single          <= '0';
          conv_reset           <= '0';
          conv_compare_enable  <= '0';
          last_DAT_READ_EN_IN  <= '0';
        elsif CLK_EN = '1' then
          DAT_UNKNOWN_ADDR_OUT <= '0';
          DAT_WRITE_ACK_OUT    <= '0';
          DAT_NO_MORE_DATA_OUT <= '0';
          DAT_DATAREADY_OUT    <= '0';
          range_ram_wr         <= '0';
          conv_single          <= conv_single and not conv_single_clr;
          conv_reset           <= conv_reset  and not conv_reset_clr;
          last_DAT_READ_EN_IN  <= '0';
          last_last_DAT_READ_EN_IN <= '0';

          if DAT_WRITE_EN_IN = '1' or DAT_READ_EN_IN = '1' then
            range_ram_addr       <= DAT_ADDR_IN(2 downto 0);
            range_ram_data       <= DAT_DATA_IN(27 downto 16) & DAT_DATA_IN(11 downto 0);
          end if;

          if DAT_WRITE_EN_IN = '1' then
            if DAT_ADDR_IN = "000000" then
              conv_enabled      <= DAT_DATA_IN(0);
              conv_single       <= DAT_DATA_IN(1);
              conv_reset        <= DAT_DATA_IN(2);
              conv_compare_enable <= DAT_DATA_IN(3);
              DAT_WRITE_ACK_OUT <= '1';
            elsif DAT_ADDR_IN(5 downto 3) = "100" then   -- "100---"
              range_ram_wr      <= '1';
              DAT_WRITE_ACK_OUT <= '1';
            else
              DAT_UNKNOWN_ADDR_OUT <= '1';
            end if;
          end if;
          if DAT_READ_EN_IN = '1' or last_DAT_READ_EN_IN = '1' or last_last_DAT_READ_EN_IN = '1' then
            if DAT_ADDR_IN(5 downto 0) = "000000" then
              DAT_DATA_OUT        <= (0 => conv_enabled, 1 => conv_single, 3 => conv_compare_enable, others => '0');
              DAT_DATAREADY_OUT   <= '1';
            elsif DAT_ADDR_IN(5 downto 0) = "000001" then
              DAT_DATA_OUT        <= status_overview;
              DAT_DATAREADY_OUT   <= '1';
            elsif DAT_ADDR_IN(5 downto 3) = "010" then  --"010000"
              last_DAT_READ_EN_IN <= DAT_READ_EN_IN;
              last_last_DAT_READ_EN_IN <= last_DAT_READ_EN_IN;
              if last_last_DAT_READ_EN_IN = '1' then
                DAT_DATAREADY_OUT   <= '1';
                DAT_DATA_OUT        <= x"00000" & value_ram_data(11 downto 0);
              end if;
            elsif DAT_ADDR_IN(5 downto 3) = "011" then  --"010000"
              last_DAT_READ_EN_IN <= DAT_READ_EN_IN;
              last_last_DAT_READ_EN_IN <= last_DAT_READ_EN_IN;
              if last_last_DAT_READ_EN_IN = '1' then
                DAT_DATAREADY_OUT   <= '1';
                DAT_DATA_OUT        <= x"0" & value_ram_data(35 downto 24) & x"0" &  value_ram_data(23 downto 12);
              end if;
            elsif DAT_ADDR_IN(5 downto 3) = "100" then  --"100000"
              last_DAT_READ_EN_IN <= DAT_READ_EN_IN;
              last_last_DAT_READ_EN_IN <= last_DAT_READ_EN_IN;
              if last_last_DAT_READ_EN_IN = '1' then
                DAT_DATAREADY_OUT   <= '1';
                DAT_DATA_OUT        <= x"0" & range_ram_data_out(23 downto 12) & x"0" & range_ram_data_out(11 downto 0);
              end if;
            else
              DAT_UNKNOWN_ADDR_OUT <= '1';
            end if;
          end if;
        end if;
      end if;
    end process;


  STAT_VOLTAGES_OUT    <= status_overview;

end architecture;
