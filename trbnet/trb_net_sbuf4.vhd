
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity trb_net_sbuf4 is
  generic (
    DATA_WIDTH : integer := 18
    );
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
    --  port to combinatorial logic
    COMB_DATAREADY_IN  : in  STD_LOGIC;  --comb logic provides data word
    COMB_next_READ_OUT : out STD_LOGIC;  --sbuf can read in NEXT cycle
    COMB_READ_IN       : in  STD_LOGIC;  --comb logic IS reading
    -- the COMB_next_READ_OUT should be connected via comb. logic to a register
    -- to provide COMB_READ_IN (feedback path with 1 cycle delay)
    COMB_DATA_IN       : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0); -- Data word
    -- Port to synchronous output.
    SYN_DATAREADY_OUT  : out STD_LOGIC;
    SYN_DATA_OUT       : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0); -- Data word
    SYN_READ_IN        : in  STD_LOGIC;
    -- Status and control port
    STAT_BUFFER        : out STD_LOGIC
    );
end entity;

architecture trb_net_sbuf4_arch of trb_net_sbuf4 is

  signal current_b0_buffer : std_logic_vector (DATA_WIDTH-1 downto 0);
  signal current_b1_buffer : std_logic_vector (DATA_WIDTH-1 downto 0);
  signal current_b2_buffer : std_logic_vector (DATA_WIDTH-1 downto 0);

  signal next_next_READ_OUT, current_next_READ_OUT : std_logic;
  signal next_SYN_DATAREADY_OUT, current_SYN_DATAREADY_OUT : std_logic;

--   signal move_b1_buffer, move_b2_buffer, move_b3_buffer: std_logic;

  type BUFFER_STATE is (BUFFER_EMPTY, BUFFER_B2_FULL, BUFFER_B1_FULL,BUFFER_B0_FULL);
  signal current_buffer_state, next_buffer_state : BUFFER_STATE;
  signal current_buffer_state_int : STD_LOGIC_VECTOR (1 downto 0);

  signal current_got_overflow, next_got_overflow : std_logic;
  signal combined_COMB_DATAREADY_IN: std_logic;
--   signal use_current_b1_buffer: std_logic;
--   signal use_current_b0_buffer: std_logic;

  signal move_b1_b2 : std_logic;
  signal move_b0_b1 : std_logic;

  signal load_b2    : std_logic;
  signal load_b1    : std_logic;
  signal load_b0    : std_logic;



  attribute syn_preserve : boolean;
  attribute syn_keep : boolean;
  attribute syn_preserve of current_SYN_DATAREADY_OUT : signal is true;
  attribute syn_keep of current_SYN_DATAREADY_OUT : signal is true;
  attribute syn_preserve of current_next_READ_OUT : signal is true;
  attribute syn_keep of current_next_READ_OUT : signal is true;
  attribute syn_hier : string;
  attribute syn_hier of trb_net_sbuf4_arch : architecture is "flatten, firm";


begin

  SYN_DATA_OUT      <= current_b2_buffer;
  SYN_DATAREADY_OUT <=  current_SYN_DATAREADY_OUT;
  COMB_next_READ_OUT <= current_next_READ_OUT;

  STAT_BUFFER <= current_got_overflow;

  combined_COMB_DATAREADY_IN <= (COMB_DATAREADY_IN and COMB_READ_IN);




  THE_FSM: process (current_buffer_state, SYN_READ_IN,
                 current_SYN_DATAREADY_OUT, current_got_overflow,
                 combined_COMB_DATAREADY_IN)
  begin  -- process COMB
    next_buffer_state <= current_buffer_state;
    next_next_READ_OUT <= '1';
    load_b0 <= '0';
    load_b1 <= '0';
    load_b2 <= '0';
    move_b1_b2 <= '0';
    move_b0_b1 <= '0';
    next_SYN_DATAREADY_OUT <= current_SYN_DATAREADY_OUT;
    next_got_overflow <= current_got_overflow;

    case current_buffer_state is
      when BUFFER_EMPTY =>
        current_buffer_state_int <= "00";
        if combined_COMB_DATAREADY_IN = '1' then
          next_buffer_state <= BUFFER_B2_FULL;
          load_b2 <= '1';
          next_SYN_DATAREADY_OUT <= '1';
        end if;

      when BUFFER_B2_FULL =>
        current_buffer_state_int <= "01";
        next_SYN_DATAREADY_OUT <= '1';
        if combined_COMB_DATAREADY_IN = '1' and SYN_READ_IN = '1' then
          load_b2                <= '1';
        elsif combined_COMB_DATAREADY_IN = '1' and SYN_READ_IN = '0' then
          next_buffer_state      <= BUFFER_B1_FULL;
          next_next_READ_OUT     <= '0';
          load_b1                <= '1';
        elsif combined_COMB_DATAREADY_IN = '0' and SYN_READ_IN = '1' then
          next_buffer_state      <= BUFFER_EMPTY;
          next_SYN_DATAREADY_OUT <= '0';
        else
          --next_next_READ_OUT     <= '0';

        end if;

      when BUFFER_B1_FULL =>
        current_buffer_state_int <= "10";
        next_SYN_DATAREADY_OUT <= '1';
        next_next_READ_OUT <= '0';
        if combined_COMB_DATAREADY_IN = '1' and SYN_READ_IN = '1' then
          load_b1    <= '1';
          move_b1_b2 <= '1';
        elsif combined_COMB_DATAREADY_IN = '1' and SYN_READ_IN = '0' then
          next_buffer_state  <= BUFFER_B0_FULL;
          load_b0            <= '1';
        elsif combined_COMB_DATAREADY_IN = '0' and  SYN_READ_IN = '1' then
          next_buffer_state  <= BUFFER_B2_FULL;
          next_next_READ_OUT <= '1';
          move_b1_b2         <= '1';
        end if;

      when BUFFER_B0_FULL =>
        current_buffer_state_int <= "11";
        next_SYN_DATAREADY_OUT <= '1';
        next_next_READ_OUT  <= '0';
        if combined_COMB_DATAREADY_IN = '1' and SYN_READ_IN = '0' then
          next_got_overflow <= '1';
        elsif combined_COMB_DATAREADY_IN = '0' and SYN_READ_IN = '1' then
          move_b1_b2        <= '1';
          move_b0_b1        <= '1';
          next_buffer_state <= BUFFER_B1_FULL;
        elsif combined_COMB_DATAREADY_IN = '1' and SYN_READ_IN = '1' then
          move_b1_b2        <= '1';
          move_b0_b1        <= '1';
          load_b0           <= '1';
        end if;
    end case;
  end process;



  PROC_FSM_REG : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          current_buffer_state      <= BUFFER_EMPTY;
          current_got_overflow      <= '0';
          current_SYN_DATAREADY_OUT <= '0';
          current_next_READ_OUT     <= '0';
        elsif CLK_EN = '1' then
          current_buffer_state      <= next_buffer_state;
          current_got_overflow      <= next_got_overflow;
          current_SYN_DATAREADY_OUT <= next_SYN_DATAREADY_OUT;
          current_next_READ_OUT     <= next_next_READ_OUT;
        end if;
      end if;
    end process;


  PROC_REG_BUFFERS : process(CLK)
    begin
      if rising_edge(CLK) then
        if move_b1_b2 = '1' then
          current_b2_buffer <= current_b1_buffer;
        end if;

        if move_b0_b1 = '1' then
          current_b1_buffer <= current_b0_buffer;
        end if;

        if load_b2 = '1' then
          current_b2_buffer <= COMB_DATA_IN;
        end if;

        if load_b1 = '1' then
          current_b1_buffer <= COMB_DATA_IN;
        end if;

        if load_b0 = '1' then
          current_b0_buffer <= COMB_DATA_IN;
        end if;

      end if;
    end process;



end architecture;

