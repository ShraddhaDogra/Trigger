LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;
library work;
use work.trb_net_std.all;


--this implementation uses IBM-CRC-16, i.e. x16 + x15 + x2 + 1


entity trb_net_CRC is
  port(
    CLK     : in  std_logic;
    RESET   : in std_logic;
    CLK_EN  : in std_logic;
    DATA_IN : in  std_logic_vector(15 downto 0);
    CRC_OUT : out std_logic_vector(15 downto 0);
    CRC_match : out std_logic
    );
end entity;


architecture trb_net_CRC_arch of trb_net_CRC is
signal D,C, next_CRC_OUT, CRC : std_logic_vector(15 downto 0) := x"0000";

begin
    D <= DATA_IN;
    C <= CRC;
    CRC_OUT <= CRC;
    CRC_match <= not or_all(CRC);

    next_CRC_OUT(0) <= D(15) xor D(13) xor D(12) xor D(11) xor D(10) xor D(9) xor
                 D(8) xor D(7) xor D(6) xor D(5) xor D(4) xor D(3) xor
                 D(2) xor D(1) xor D(0) xor C(0) xor C(1) xor C(2) xor
                 C(3) xor C(4) xor C(5) xor C(6) xor C(7) xor C(8) xor
                 C(9) xor C(10) xor C(11) xor C(12) xor C(13) xor C(15);
    next_CRC_OUT(1) <= D(14) xor D(13) xor D(12) xor D(11) xor D(10) xor D(9) xor
                 D(8) xor D(7) xor D(6) xor D(5) xor D(4) xor D(3) xor
                 D(2) xor D(1) xor C(1) xor C(2) xor C(3) xor C(4) xor
                 C(5) xor C(6) xor C(7) xor C(8) xor C(9) xor C(10) xor
                 C(11) xor C(12) xor C(13) xor C(14);
    next_CRC_OUT(2) <= D(14) xor D(1) xor D(0) xor C(0) xor C(1) xor C(14);
    next_CRC_OUT(3) <= D(15) xor D(2) xor D(1) xor C(1) xor C(2) xor C(15);
    next_CRC_OUT(4) <= D(3) xor D(2) xor C(2) xor C(3);
    next_CRC_OUT(5) <= D(4) xor D(3) xor C(3) xor C(4);
    next_CRC_OUT(6) <= D(5) xor D(4) xor C(4) xor C(5);
    next_CRC_OUT(7) <= D(6) xor D(5) xor C(5) xor C(6);
    next_CRC_OUT(8) <= D(7) xor D(6) xor C(6) xor C(7);
    next_CRC_OUT(9) <= D(8) xor D(7) xor C(7) xor C(8);
    next_CRC_OUT(10) <= D(9) xor D(8) xor C(8) xor C(9);
    next_CRC_OUT(11) <= D(10) xor D(9) xor C(9) xor C(10);
    next_CRC_OUT(12) <= D(11) xor D(10) xor C(10) xor C(11);
    next_CRC_OUT(13) <= D(12) xor D(11) xor C(11) xor C(12);
    next_CRC_OUT(14) <= D(13) xor D(12) xor C(12) xor C(13);
    next_CRC_OUT(15) <= D(15) xor D(14) xor D(12) xor D(11) xor D(10) xor D(9) xor
                  D(8) xor D(7) xor D(6) xor D(5) xor D(4) xor D(3) xor
                  D(2) xor D(1) xor D(0) xor C(0) xor C(1) xor C(2) xor
                  C(3) xor C(4) xor C(5) xor C(6) xor C(7) xor C(8) xor
                  C(9) xor C(10) xor C(11) xor C(12) xor C(14) xor C(15);

   process(CLK)
     begin
       if rising_edge(CLK) then
         if RESET = '1' then
           CRC <= (others => '0');
         elsif CLK_EN = '1' then
           CRC <= next_CRC_OUT;
         end if;
       end if;
     end process;

end architecture;

