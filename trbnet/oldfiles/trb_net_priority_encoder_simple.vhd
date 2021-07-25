LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity trb_net_priority_encoder_simple is
  generic (
    WIDTH : integer := 8
    );
  port (
    INPUT_IN    : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    RESULT_OUT  : out STD_LOGIC_VECTOR (WIDTH-1 downto 0)
    );
end entity;

architecture trb_net_priority_encoder_simple_arch of trb_net_priority_encoder_simple is

  signal fixed_pattern: STD_LOGIC_VECTOR (WIDTH-1 downto 0);

  begin
    fixed_pattern(0) <= INPUT_IN(0);
    F1: for i in 1 to WIDTH-1 generate
      process(INPUT_IN)
        begin
          if INPUT_IN(i) = '1' and INPUT_IN(i-1 downto 0) = 0 then
            fixed_pattern(i) <= '1';
          else
            fixed_pattern(i) <= '0';
          end if;
        end process;
    end generate;

    RESULT_OUT  <= fixed_pattern;


end architecture;

