--instantiates DualDataRate-Output-Flipflops with generic width

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library unisim;
use UNISIM.VComponents.all;

entity dualdatarate_flipflop is
  generic(
    WIDTH : integer := 1
    );
  port(
    C0 : in std_logic;
    C1 : in std_logic;            --two clocks
    CE : in std_logic;            --clock enable
    CLR : in std_logic;           --global clear
    D0 : in std_logic_vector(WIDTH-1 downto 0);
    D1 : in std_logic_vector(WIDTH-1 downto 0);
                                  --two data inputs
    PRE : in std_logic;           --global preset
    Q : out std_logic_vector(WIDTH-1 downto 0)
                                  --ddr output (must be connected to an OBUF)
    );
end entity dualdatarate_flipflop;

architecture dualdatarate_flipflop_arch of dualdatarate_flipflop is

begin

  ddr_ff_gen : for i in 0 to WIDTH-1 generate
    ddr_ff : FDDRCPE
      port map(
          Q => Q(i),
          C0 => C0,
          C1 => C1,
          CE  => CE,
          CLR => CLR,
          D0  => D0(i),
          D1  => D1(i),
          PRE => PRE
          );
  end generate;

end architecture;