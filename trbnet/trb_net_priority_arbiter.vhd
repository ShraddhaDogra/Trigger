LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity trb_net_priority_arbiter is
  generic (
    WIDTH : integer := 8
    );
  port(
    --  Misc
    CLK       : in  std_logic;
    RESET     : in  std_logic;
    CLK_EN    : in  std_logic;
    INPUT_IN  : in  std_logic_vector (WIDTH-1 downto 0);
    RESULT_OUT: out std_logic_vector (WIDTH-1 downto 0);
    ENABLE    : in  std_logic;
    CTRL      : in  std_logic_vector (9 downto 0)
    );
end trb_net_priority_arbiter;

architecture trb_net_priority_arbiter_arch of trb_net_priority_arbiter is

  component trb_net_priority_encoder is

  generic (
    WIDTH : integer := 8
    );
  port(
    INPUT_IN    : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    RESULT_OUT  : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    PATTERN_OUT : out STD_LOGIC_VECTOR (WIDTH-1 downto 0)
    );
  END component;

  signal next_fixed_pattern: STD_LOGIC_VECTOR (WIDTH-1 downto 0);
  signal next_rr_pattern: STD_LOGIC_VECTOR (WIDTH-1 downto 0);
  signal next_p1_pattern, current_p1_pattern: STD_LOGIC_VECTOR (WIDTH-1 downto 0);
  signal next_p2_pattern, current_p2_pattern: STD_LOGIC_VECTOR (WIDTH-1 downto 0);
  signal sampled_rr_pattern1, sampled_rr_pattern2: STD_LOGIC_VECTOR (WIDTH-1 downto 0);
  signal proposed_rr_pattern1, proposed_rr_pattern2: STD_LOGIC_VECTOR (WIDTH-1 downto 0);
  signal leading_rr_pattern1, leading_rr_pattern2: STD_LOGIC_VECTOR (WIDTH-1 downto 0);
  signal next_final_pattern, current_final_pattern: STD_LOGIC_VECTOR (WIDTH-1 downto 0);
  signal current_rr_mask, next_rr_mask:  STD_LOGIC_VECTOR (7 downto 0);

  signal use_rr: STD_LOGIC;
  signal enc1_pattern : std_logic_vector(WIDTH-1 downto 0);

  begin

    ---------------------------------------------------------------------------
    -- fixed pattern generator
    ---------------------------------------------------------------------------

    ENC1: trb_net_priority_encoder
      generic map (
        WIDTH => WIDTH
        )
      port map(
        INPUT_IN => INPUT_IN,
        PATTERN_OUT => enc1_pattern,
        RESULT_OUT => next_fixed_pattern
        );

-------------------------------------------------------------------------------
-- round robin: determine next pattern
-------------------------------------------------------------------------------

    -- from the current p1 and p2 pattern, look what would be the next rr pattern
    -- find out what would be the next rr pattern
    -- we call this proposed pattern

    ENC2: trb_net_priority_encoder
      generic map (
        WIDTH => WIDTH
        )
      port map(
        INPUT_IN => sampled_rr_pattern1,
        RESULT_OUT => proposed_rr_pattern1,
        PATTERN_OUT => leading_rr_pattern1
        );

    ENC3: trb_net_priority_encoder
      generic map (
        WIDTH => WIDTH
        )
      port map(
        INPUT_IN => sampled_rr_pattern2,
        RESULT_OUT => proposed_rr_pattern2,
        PATTERN_OUT => leading_rr_pattern2
        );

    sampled_rr_pattern1 <= INPUT_IN and current_p1_pattern;
    sampled_rr_pattern2 <= INPUT_IN and current_p2_pattern;

    use_rr <= current_rr_mask(0) and CTRL(9);  --rol_mask is on
    RESULT_OUT <= current_final_pattern;

    comb_rr : process(current_p1_pattern, current_p2_pattern,use_rr, current_final_pattern,
                      sampled_rr_pattern1, sampled_rr_pattern2, proposed_rr_pattern1,
                      proposed_rr_pattern2, leading_rr_pattern1, leading_rr_pattern2,
                      current_rr_mask, CTRL, next_fixed_pattern, next_rr_pattern,
                      ENABLE, INPUT_IN)
    begin
      next_rr_pattern(0) <=  '1';  --stay tuned on highst Pr.
      next_rr_pattern(WIDTH -1 downto 1) <= (others => '0');
      next_p1_pattern <=  current_p1_pattern;
      next_p2_pattern <=  current_p2_pattern;
      next_rr_mask <= current_rr_mask;
      next_final_pattern <= (others => '0');

      if use_rr = '1' then
        -- when _using_ the rr, overwrite the current pattern with a new one (
        -- this means do the "round" of the robin
        if or_all(sampled_rr_pattern1) = '1' then
          -- pattern 1 has higher priority
          next_p1_pattern <=  leading_rr_pattern1 xor proposed_rr_pattern1;
          next_p2_pattern <=  not leading_rr_pattern1 or proposed_rr_pattern1;
        elsif or_all(sampled_rr_pattern2) = '1' then
          next_p1_pattern <=  leading_rr_pattern2 xor proposed_rr_pattern2;
          next_p2_pattern <=  not leading_rr_pattern2 or proposed_rr_pattern2;
        end if;
      end if;

      if or_all(sampled_rr_pattern1) = '1' then
        next_rr_pattern <=  proposed_rr_pattern1;
      elsif or_all(sampled_rr_pattern2) = '1' then
        next_rr_pattern <=  proposed_rr_pattern2;
      end if;

      if (CTRL(9) = '1') and (CTRL(8) = '0') then  -- rol
        next_rr_mask(6 downto 0) <= current_rr_mask(7 downto 1);
        next_rr_mask(7) <= current_rr_mask(0);
      elsif (CTRL(8) = '1') then        --overwrite
        next_rr_mask(7 downto 0) <= CTRL(7 downto 0);
      end if;

      -- finally make the pattern
      if current_rr_mask(0) = '0' and ENABLE  = '1' then
        if or_all(next_fixed_pattern) = '1' then
          next_final_pattern <= next_fixed_pattern;
        else
          next_final_pattern(0) <=  '1';  --stay tuned on highst Pr.
          next_final_pattern(WIDTH -1 downto 1) <= (others => '0');
        end if;
      elsif ENABLE  = '1' then
        next_final_pattern <= next_rr_pattern;
      end if;
      if  or_all(INPUT_IN) = '0' then
        next_final_pattern <= current_final_pattern;
      end if;
  end process;

  sync_rr : process(CLK)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        current_p1_pattern    <= (others => '1');
        current_p2_pattern    <= (others => '0');
        current_rr_mask       <= (others => '0');
        current_final_pattern <= (others => '0');
        current_rr_mask       <= (others => '0');
      elsif CLK_EN = '1' then
        current_p1_pattern    <= next_p1_pattern;
        current_p2_pattern    <= next_p2_pattern;
        current_rr_mask       <= next_rr_mask;
        current_final_pattern <= next_final_pattern;
        current_rr_mask       <= next_rr_mask;
--         if ENABLE = '0' then
--           current_final_pattern <= (others => '0');
--         end if;
      end if;
    end if;
  end process;

end architecture;

