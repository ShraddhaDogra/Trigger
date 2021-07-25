LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;
library work;
use work.trb_net_std.all;


entity trb_net_clock_generator is
  generic(
    FREQUENCY_IN  : real := 100.0;
    FREQUENCY_OUT : real := 300.0;
    CLOCK_MULT    : integer range 1 to 32 := 3;
    CLOCK_DIV     : integer range 1 to 32 := 1;
    CLKIN_DIVIDE_BY_2 : boolean := true;
    CLKIN_PERIOD  : real := 20.0
    );
  port(
    RESET    : in  std_logic;
    CLK_IN   : in  std_logic;
    CLK_OUT  : out std_logic;
    LOCKED   : out std_logic
    );

end entity;


architecture trb_net_clock_generator_arch of trb_net_clock_generator is

  component pll_in100_out200 is
      port (
          CLK: in std_logic;
          CLKOP: out std_logic;
          LOCK: out std_logic);
  end component;

  signal FB_CLK, CLK0_Out, CLKFX : std_logic;
begin

  gen_pll100_200 : if FREQUENCY_IN = 100.0 and FREQUENCY_OUT = 200.0 generate
    THE_PLL : pll_in100_out200
      port map(
        CLK => CLK_IN,
        CLKOP => CLK_OUT,
        LOCK  => LOCKED
        );
    end generate;

end architecture;