LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity rom_16x8 is
  generic(
    INIT0 : std_logic_vector(15 downto 0) := x"12A0";
    INIT1 : std_logic_vector(15 downto 0) := x"23b1";
    INIT2 : std_logic_vector(15 downto 0) := x"34c2";
    INIT3 : std_logic_vector(15 downto 0) := x"49d3";
    INIT4 : std_logic_vector(15 downto 0) := x"56e5";
    INIT5 : std_logic_vector(15 downto 0) := x"67d5";
    INIT6 : std_logic_vector(15 downto 0) := x"7818";
    INIT7 : std_logic_vector(15 downto 0) := x"8927"
    );
  port(
    CLK  : in  std_logic;
    a    : in  std_logic_vector(2 downto 0);
    dout : out std_logic_vector(15 downto 0)
    );
end entity;

architecture rom_16x8_arch of rom_16x8 is
  type ram_t is array(0 to 7) of std_logic_vector(15 downto 0);
  SIGNAL rom : ram_t := (INIT0, INIT1, INIT2, INIT3, INIT4, INIT5, INIT6, INIT7);
begin
  rom(0) <= INIT0;
  rom(1) <= INIT1;
  rom(2) <= INIT2;
  rom(3) <= INIT3;
  rom(4) <= INIT4;
  rom(5) <= INIT5;
  rom(6) <= INIT6;
  rom(7) <= INIT7;

  process(CLK)
    begin
      if rising_edge(CLK) then
        dout <= rom(conv_integer(a));
      end if;
    end process;

end architecture;