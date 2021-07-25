LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;
library work;
use work.trb_net_std.all;
library unisim;
use UNISIM.VComponents.all;

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
  signal FB_CLK, CLK0_Out, CLKFX : std_logic;
begin
  U_DCM: DCM
    generic map(
      CLKFX_DIVIDE => CLOCK_DIV, -- Min 1 Max 32
      CLKFX_MULTIPLY => CLOCK_MULT, -- Min 2 Max 32
      CLKIN_PERIOD => CLKIN_PERIOD,
      STARTUP_WAIT => FALSE,
      CLKIN_DIVIDE_BY_2 => CLKIN_DIVIDE_BY_2
      )
    port map (
      CLKIN =>    CLK_IN,
      CLKFB =>    FB_CLK,
      DSSEN =>    '0',
      PSINCDEC => '0',
      PSEN =>     '0',
      PSCLK =>    '0',
      RST =>      RESET,
      CLK0 =>     CLK0_Out, -- for feedback
      CLKFX180 =>    CLKFX,
      LOCKED =>   LOCKED
      );
U0_BUFG: BUFG
  port map (
       I => CLK0_Out,
       O => FB_CLK
       );
U1_BUFG: BUFG
  port map (
       I => CLKFX,
       O => CLK_OUT
       );
end architecture;