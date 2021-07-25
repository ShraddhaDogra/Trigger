LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity trb_net_priority_encoder is
  generic (
    WIDTH : integer := 8
    );
  port (
    INPUT_IN    : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    RESULT_OUT  : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    PATTERN_OUT : out STD_LOGIC_VECTOR (WIDTH-1 downto 0)
    );
end trb_net_priority_encoder;

architecture trb_net_priority_encoder_arch of trb_net_priority_encoder is

  signal fixed_pattern: STD_LOGIC_VECTOR (WIDTH-1 downto 0);
  signal leading_pattern: STD_LOGIC_VECTOR (WIDTH-1 downto 0);
  
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

  leading_pattern(0) <= INPUT_IN(0);
    G1: for i in 1 to WIDTH-1 generate
        comb : process (INPUT_IN, leading_pattern)
          begin
            leading_pattern(i) <= leading_pattern(i-1);
            if (INPUT_IN(i) = '1') then -- and (leading_pattern(i-1)  = '0')
              leading_pattern(i) <= '1';
            end if;
        end process;
    end generate;

    RESULT_OUT  <= fixed_pattern;
    PATTERN_OUT <= leading_pattern;
    

end trb_net_priority_encoder_arch;
  
