--instantiates DualDataRate-Output-Flipflops with generic width

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library SCM;
use SCM.COMPONENTS.all;

entity dualdatarate_flipflop is
--1 clock, no CE, PRE for Lattice SCM
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
   gen_ddrs : for i in 0 to WIDTH-1 generate
    ud_0: ODDRXA
        port map (DA=>D0(i), DB=>D1(i), CLK=>C0, RST=>CLR,
            Q=>Q(i));
   end generate;

end architecture;