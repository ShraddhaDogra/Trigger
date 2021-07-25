--a pseudo dual ported RAM with one write-only port and one read-only port.

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity ram_dp_rw is
  generic(
    depth : integer := 3;
    width : integer := 16
    );
  port(
    CLK   : in  std_logic;
    wr1   : in  std_logic;
    a1    : in  std_logic_vector(depth-1 downto 0);
    din1  : in  std_logic_vector(width-1 downto 0);
    a2    : in  std_logic_vector(depth-1 downto 0);
    dout2 : out std_logic_vector(width-1 downto 0)
    );
end entity;

architecture ram_dp_rw_arch of ram_dp_rw is
  type ram_t is array(0 to 2**depth-1) of std_logic_vector(width-1 downto 0);
  SIGNAL ram : ram_t := (others => (others => '0'));
begin

  process(CLK)
    begin
      if rising_edge(CLK) then
        if wr1 = '1' then
          ram((conv_integer(a1))) <= din1;
        end if;
        dout2 <= ram(conv_integer(a2));
      end if;
    end process;

end architecture;
