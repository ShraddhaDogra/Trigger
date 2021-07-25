library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;


library work;
use work.trb_net_std.all;

entity tb is
end entity;

architecture tar of tb is


component delay_signal is
  generic(
    INPUT_WIDTH : integer range 1 to 64 := 8;
    MAX_DELAY   : integer range 2 to 12 := 10
    );
  port(
    CLOCK_IN           : in  std_logic;
    CLOCK_EN_IN        : in  std_logic;
    INPUT_IN           : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    OUTPUT_OUT         : out std_logic_vector(INPUT_WIDTH-1 downto 0);
    DELAY_IN           : in  std_logic_vector(MAX_DELAY-1 downto 0)
    );
end component;

  constant INPUT_WIDTH : integer := 16;
  constant MAX_DELAY   : integer := 10;

  signal CLOCK_IN : std_logic := '1';
  signal CLOCK_EN_IN : std_logic := '1';
  signal INPUT_IN    : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
  signal OUTPUT_OUT  : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
  signal DELAY_IN    : std_logic_vector(MAX_DELAY-1 downto 0) := "0000001100";

begin

  uut : delay_signal
    generic map(
      INPUT_WIDTH => INPUT_WIDTH,
      MAX_DELAY   => MAX_DELAY
      )
    port map(
      CLOCK_IN   => CLOCK_IN,
      CLOCK_EN_IN=> CLOCK_EN_IN,
      INPUT_IN   => INPUT_IN,
      OUTPUT_OUT => OUTPUT_OUT,
      DELAY_IN   => DELAY_IN
      );

  CLOCK_IN <= not CLOCK_IN after 5 ns;

  process(CLOCK_IN)
    begin
      if rising_edge(CLOCK_IN) then
        INPUT_IN <= std_logic_vector(unsigned(INPUT_IN) + to_unsigned(1,16));
      end if;
    end process;

  process
    begin
      DELAY_IN <= std_logic_vector(to_unsigned(0,MAX_DELAY));
      wait for 5 us;
      wait until falling_edge(CLOCK_IN);
      DELAY_IN <= std_logic_vector(to_unsigned(100,MAX_DELAY));
      wait for 5 us;
      wait until falling_edge(CLOCK_IN);
      DELAY_IN <= std_logic_vector(to_unsigned(10,MAX_DELAY));
      wait for 5 us;
      wait until falling_edge(CLOCK_IN);
      DELAY_IN <= std_logic_vector(to_unsigned(50,MAX_DELAY));
      wait for 5 us;
      wait until falling_edge(CLOCK_IN);
      DELAY_IN <= std_logic_vector(to_unsigned(300,MAX_DELAY));
    end process;



end architecture;