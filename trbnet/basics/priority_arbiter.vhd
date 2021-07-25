LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;



entity priority_arbiter is
  generic(
    INPUT_WIDTH : integer := 8
    );
  port(
    CLK         : in  std_logic;
    ENABLE      : in  std_logic;
    INPUT       : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    OUTPUT_VEC  : out std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
    OUTPUT_NUM  : out integer range 0 to INPUT_WIDTH-1 := 0
    );
end entity;


architecture priority_arbiter_arch of priority_arbiter is



begin

  process (CLK)
    begin 
    if rising_edge(CLK) and ENABLE = '1' then
      OUTPUT_VEC <= (others => '0');
      OUTPUT_NUM <= 0;
      gen_output : for i in 0 to INPUT_WIDTH-1 loop
        if INPUT(i) = '1' then
          OUTPUT_VEC <= std_logic_vector(to_unsigned(2**i,INPUT_WIDTH));
          OUTPUT_NUM <= i;
          exit;
        end if;
      end loop;
    end if;
  end process;

end architecture;