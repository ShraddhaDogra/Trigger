LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity trb_net_clock_generator is
  generic(
    FREQUENCY_IN  : real := 100.0;
    FREQUENCY_OUT : real := 200.0;
    CLOCK_MULT    : integer range 1 to 32 := 3;
    CLOCK_DIV     : integer range 1 to 32 := 1;
    CLKIN_DIVIDE_BY_2 : boolean := false;
    CLKIN_PERIOD  : real := 10.0
    );
  port(
    RESET    : in  std_logic;
    CLK_IN   : in  std_logic;
    CLK_OUT  : out std_logic;
    LOCKED   : out std_logic
    );

end entity;


architecture trb_net_clock_generator_arch of trb_net_clock_generator is
  component lattice_scm_clock_300
    generic (SMI_OFFSET : in String := "0x410");
    port (clk: in  std_logic; clkop: out  std_logic;
        clkos: out  std_logic; lock: out  std_logic);
  end component;
  component lattice_scm_clock_200
    generic (SMI_OFFSET : in String := "0x410");
    port (clk: in  std_logic; clkop: out  std_logic;
        clkos: out  std_logic; lock: out  std_logic);
  end component;

begin

  gen_3x : if FREQUENCY_OUT = 300.0 and FREQUENCY_IN = 100.0 generate

-- parameterized module component instance
    CLK_GEN : lattice_scm_clock_300
      port map (
        clk  =>CLK_IN,
        clkop=>CLK_OUT,
        clkos=>open,
        lock =>locked
        );
  end generate;
  gen_2x : if FREQUENCY_OUT = 200.0 and FREQUENCY_IN = 100.0 generate

-- parameterized module component instance
    CLK_GEN : lattice_scm_clock_200
      port map (
        clk  =>CLK_IN,
        clkop=>CLK_OUT,
        clkos=>open,
        lock =>locked
        );
  end generate;
  gen_none : if FREQUENCY_OUT = 300.0 or FREQUENCY_IN /= 100.0 generate
    CLK_OUT <= CLK_IN;
    LOCKED <= '0';
  end generate;


end architecture;
