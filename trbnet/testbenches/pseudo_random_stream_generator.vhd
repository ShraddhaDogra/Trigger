--produces a stream of 16bit wide pseudo-pseudo-random words
--(produced by a crc-generator fed with a counter)
--roughly every fourth word (randomly chosen by a second crc), the output is halted for a clock cycle (shown by D_EN low)
--every 2^20 words, the D_RST is high for some clock cycles to mark a restart of the sequence.

LIBRARY ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
library work;
use work.trb_net_std.all;

entity pseudo_random_stream_generator is
  port(
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
    D_OUT  : out std_logic_vector(15 downto 0);
    D_EN   : out std_logic;
    D_RST  : out std_logic
    );
end entity;



architecture arch of pseudo_random_stream_generator is

  component trb_net_CRC is
    port(
      CLK       : in  std_logic;
      RESET     : in std_logic;
      CLK_EN    : in std_logic;
      DATA_IN   : in  std_logic_vector(15 downto 0);
      CRC_OUT   : out std_logic_vector(15 downto 0);
      CRC_match : out std_logic
      );
  end component;


  signal test_counter : unsigned(20 downto 0) := '1' & x"FFF30";
  signal CRC_reset    : std_logic;
  signal CRC_enable   : std_logic;
  signal last_CRC_enable : std_logic;
  signal CRC_out      : std_logic_vector(15 downto 0);
  signal CRC2_out     : std_logic_vector(15 downto 0);
  signal next_D_EN    : std_logic;
  signal next_D_RST   : std_logic;
  signal next_D_OUT   : std_logic_vector(15 downto 0);


begin

--CRC used as Data stream
  THE_CRC : trb_net_CRC
    port map(
      CLK => CLK,
      RESET => CRC_reset,
      CLK_EN => CRC_enable,
      DATA_IN => std_logic_vector(test_counter(15 downto 0)),
      CRC_OUT => CRC_out,
      CRC_match => open
      );

--CRC generating enable
  THE_CRC_2 : trb_net_CRC
    port map(
      CLK => CLK,
      RESET => RESET,
      CLK_EN => '1',
      DATA_IN => std_logic_vector(test_counter(15 downto 0)),
      CRC_OUT => CRC2_out,
      CRC_match => open
      );

  next_D_OUT <= CRC_OUT;
  next_D_EN  <= last_CRC_enable;
  next_D_RST <= CRC_reset;

  CRC_reset <= and_all(std_logic_vector(test_counter(20 downto 10)));

  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          test_counter <= '1' & x"FFFF0";
          CRC_enable   <= '0';
          D_EN         <= '0';
          D_RST        <= '1';
        else
          test_counter <= test_counter + 1;
          D_OUT <= next_D_OUT;
          D_EN  <= next_D_EN;
          D_RST <= next_D_RST;
          CRC_enable <= ((CRC2_out(5) or CRC2_out(14))) or CRC_reset;
          last_CRC_enable <= CRC_enable;
        end if;
      end if;
    end process;
end architecture;