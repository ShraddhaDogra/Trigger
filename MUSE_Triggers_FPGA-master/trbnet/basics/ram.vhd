LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity ram is
  generic(
    depth : integer := 5;
    width : integer := 32
    );
  port(
    CLK  : in std_logic;
    wr   : in std_logic;
    a    : in std_logic_vector(depth-1 downto 0);
    dout : out std_logic_vector(width-1 downto 0);
    din  : in std_logic_vector(width-1 downto 0)
    );
end entity;

architecture ram_arch of ram is
  type ram_t is array(0 to 2**depth-1) of std_logic_vector(width-1 downto 0);
	SIGNAL ram : ram_t;

begin
  process(CLK)
    begin
      if rising_edge(CLK) then
        if wr = '1' then
          ram(conv_integer(a)) <= din;
        end if;
        dout <= ram(conv_integer(a));
      end if;
    end process;
end architecture;
