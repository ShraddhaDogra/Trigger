--generate demux pattern from input
--combinatorial entity only


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity trb_net_pattern_gen is

  generic (
    WIDTH : integer := 2
    );
  port(
    INPUT_IN  : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    RESULT_OUT: out STD_LOGIC_VECTOR (2**WIDTH-1 downto 0)
    );
END trb_net_pattern_gen;

architecture trb_net_pattern_gen_arch of trb_net_pattern_gen is
  begin
    RESULT_OUT <= conv_std_logic_vector(2**conv_integer(INPUT_IN),2**WIDTH);
--     G1: for i in  0 to 2**WIDTH-1 generate
--       G2: process (INPUT_IN)
--         begin  -- process
--           if i = INPUT_IN then
--             RESULT_OUT(i) <= '1';
--           else
--             RESULT_OUT(i) <= '0';
--           end if;
--         end process;
--     end generate;
end trb_net_pattern_gen_arch;