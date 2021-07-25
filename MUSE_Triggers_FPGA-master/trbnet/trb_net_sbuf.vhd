-------------------------------------------------------------------------------
-- Single buffer with one more buffer to keep the speed of the datalink
-- The sbuf can be connected to a combinatorial logic (as an output buffer)
-- to provide the synchronous logic
--
-- 2 versions are provided
-- VERSION=0 is the fast version, so double buffering is done
-- VERSION=1 is half data rate: After data has been written to the sbuf,
--           the input read signal is stalled until the buffer is empty.
--           Maybe enough for trigger and slow control channels
-------------------------------------------------------------------------------



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity trb_net_sbuf is
  generic (
    DATA_WIDTH : integer := 18;
    VERSION: integer := 0
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
    DEBUG_OUT          : out std_logic_vector(15 downto 0);
    STAT_BUFFER        : out STD_LOGIC
    );
end trb_net_sbuf;

architecture trb_net_sbuf_arch of trb_net_sbuf is

  signal current_b1_buffer, next_b1_buffer : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0) := (others => '0');
  signal current_b2_buffer, next_b2_buffer : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0) := (others => '0');
  signal next_next_READ_OUT, current_next_READ_OUT : std_logic;
  signal next_SYN_DATAREADY_OUT, current_SYN_DATAREADY_OUT : std_logic;

  signal move_b1_buffer, move_b2_buffer: std_logic;

  type BUFFER_STATE is (BUFFER_EMPTY, BUFFER_B2_FULL, BUFFER_B1_FULL);
  signal current_buffer_state, next_buffer_state : BUFFER_STATE;
  signal current_buffer_state_int : STD_LOGIC_VECTOR (1 downto 0);

  signal current_got_overflow, next_got_overflow : std_logic;
  signal combined_COMB_DATAREADY_IN: std_logic;
  signal use_current_b1_buffer: std_logic;

--   signal syn_real_reading : std_logic;
--   signal syn_wait_for_read : std_logic;
  signal buf_SYN_READ_IN : std_logic;

--   signal both_active : std_logic;
--   signal syn_only    : std_logic;
--   signal comb_only   : std_logic;
--   signal both_idle   : std_logic;
--   signal not_syn_read: std_logic;


  attribute syn_preserve : boolean;
  attribute syn_keep : boolean;
  attribute syn_preserve of current_SYN_DATAREADY_OUT : signal is true;
  attribute syn_keep of current_SYN_DATAREADY_OUT : signal is true;
  attribute syn_preserve of current_next_READ_OUT : signal is true;
  attribute syn_keep of current_next_READ_OUT : signal is true;
  attribute syn_preserve of combined_COMB_DATAREADY_IN : signal is true;
  attribute syn_keep of combined_COMB_DATAREADY_IN : signal is true;
--   attribute syn_preserve of syn_real_reading : signal is true;
--   attribute syn_keep of syn_real_reading : signal is true;
--   attribute syn_preserve of syn_wait_for_read : signal is true;
--   attribute syn_keep of syn_wait_for_read : signal is true;
  attribute syn_preserve of buf_SYN_READ_IN : signal is true;
  attribute syn_keep of buf_SYN_READ_IN : signal is true;
--   attribute syn_preserve of both_active : signal is true;
--   attribute syn_keep of both_active : signal is true;
--   attribute syn_preserve of both_idle : signal is true;
--   attribute syn_keep of both_idle : signal is true;
--   attribute syn_preserve of comb_only : signal is true;
--   attribute syn_keep of comb_only : signal is true;
--   attribute syn_preserve of syn_only : signal is true;
--   attribute syn_keep of syn_only : signal is true;
--   attribute syn_preserve of not_syn_read : signal is true;
--   attribute syn_keep of not_syn_read : signal is true;


  attribute syn_hier : string;
  attribute syn_hier of trb_net_sbuf_arch : architecture is "flatten, firm";


begin

  DEBUG_OUT <= (others => '0');

  SYN_DATA_OUT <= current_b2_buffer;
  SYN_DATAREADY_OUT <=  current_SYN_DATAREADY_OUT;

  STAT_BUFFER <= current_got_overflow;

  combined_COMB_DATAREADY_IN <= (COMB_DATAREADY_IN and COMB_READ_IN);

  MUX: process (use_current_b1_buffer,
                COMB_DATA_IN, current_b1_buffer)
    begin                                   -- simple MUX
      if use_current_b1_buffer = '1' then
        next_b2_buffer <= current_b1_buffer;
      else
        next_b2_buffer <= COMB_DATA_IN;
      end if;
    end process;


  COMB: process (current_buffer_state, COMB_DATA_IN, combined_comb_dataready_in,
                 current_SYN_DATAREADY_OUT, current_got_overflow,
                 buf_syn_read_in)
  begin  -- process COMB
    next_buffer_state <= current_buffer_state;
    next_next_READ_OUT <= '1';
    next_b1_buffer <= COMB_DATA_IN;
    move_b1_buffer <= '0';
    use_current_b1_buffer <= '0';          --by default COMB_DATA_IN;
    move_b2_buffer <= '0';

    next_SYN_DATAREADY_OUT <= current_SYN_DATAREADY_OUT;
    next_got_overflow <= current_got_overflow;

    if current_buffer_state = BUFFER_EMPTY then
      current_buffer_state_int <= "00";
      if combined_COMB_DATAREADY_IN = '1' then
        -- COMB logic is writing into the sbuf
        next_buffer_state <= BUFFER_B2_FULL;
        move_b2_buffer <= '1';
        next_SYN_DATAREADY_OUT <= '1';
      end if;
    elsif current_buffer_state = BUFFER_B2_FULL then
      current_buffer_state_int <= "01";
      if combined_COMB_DATAREADY_IN = '1' and buf_SYN_READ_IN = '1' then --both_active = '1'
        -- COMB logic is writing into the sbuf
        -- at the same time syn port is reading
        move_b2_buffer <= '1';
        next_SYN_DATAREADY_OUT <= '1';
      elsif combined_COMB_DATAREADY_IN = '1' and buf_SYN_READ_IN = '0' then
        -- ONLY COMB logic is writing into the sbuf
        -- this is the case when we should use the additional
        -- buffer
        next_buffer_state <= BUFFER_B1_FULL;
        next_next_READ_OUT <= '0';        --PLEASE stop writing
        move_b1_buffer <= '1';
        next_SYN_DATAREADY_OUT <= '1';
      elsif combined_COMB_DATAREADY_IN = '0' and buf_SYN_READ_IN = '1' then
        next_buffer_state <= BUFFER_EMPTY;
        next_SYN_DATAREADY_OUT <= '0';
      else --if combined_COMB_DATAREADY_IN = '0' and SYN_READ_IN = '0' then
        next_next_READ_OUT <= '0';
        next_SYN_DATAREADY_OUT <= '1';
      end if;
    elsif current_buffer_state = BUFFER_B1_FULL then
      current_buffer_state_int <= "10";
      next_SYN_DATAREADY_OUT <= '1';
      next_next_READ_OUT <= '0';

      if combined_COMB_DATAREADY_IN = '1' and buf_SYN_READ_IN = '1' then
        -- COMB logic is writing into the sbuf
        -- at the same time syn port is reading
        use_current_b1_buffer <= '1';
        move_b1_buffer <= '1';
        move_b2_buffer <= '1';
      elsif combined_COMB_DATAREADY_IN = '1' and buf_SYN_READ_IN = '0' then
        -- ONLY COMB logic is writing into the sbuf FATAL ERROR
        next_got_overflow <= '1';
      elsif combined_COMB_DATAREADY_IN = '0' and buf_SYN_READ_IN = '1' then
        next_buffer_state <= BUFFER_B2_FULL;
        next_next_READ_OUT <= '1'; --?
        use_current_b1_buffer <= '1';
        move_b1_buffer <= '1';
        move_b2_buffer <= '1';
      end if;

    end if;
  end process COMB;

-- the next lines are an emergency stop
-- unfortuanally unregistered
-- this is needed because the final READ_OUT has
-- to be known 2 clk cycles in advance, which is
-- almost impossible taking into account that
-- the SYN reader may release the RD signal at any point
-- if this is the case, BREAK
--combined_COMB_DATAREADY_IN = '0' and  SYN_READ_IN = '1'
  EM_STOP : process(current_next_READ_OUT,
                    current_buffer_state, current_SYN_DATAREADY_OUT, buf_SYN_READ_IN)
  begin
    if current_SYN_DATAREADY_OUT = '1' and buf_SYN_READ_IN = '0' and current_buffer_state = BUFFER_B2_FULL then
      COMB_next_READ_OUT <= '0';
    elsif current_SYN_DATAREADY_OUT = '1' and buf_SYN_READ_IN = '1' and current_buffer_state = BUFFER_B1_FULL then
      COMB_next_READ_OUT <= '1';
    else
      COMB_next_READ_OUT <= current_next_READ_OUT;
    end if;
  end process EM_STOP;

  REG : process(CLK)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        current_buffer_state  <= BUFFER_EMPTY;
        current_got_overflow  <= '0';
        current_SYN_DATAREADY_OUT <= '0';
        current_next_READ_OUT <= '0';
      elsif CLK_EN = '1' then
        current_buffer_state  <= next_buffer_state;
        current_got_overflow  <= next_got_overflow;
        current_SYN_DATAREADY_OUT <= next_SYN_DATAREADY_OUT;
        current_next_READ_OUT <= next_next_READ_OUT;
      end if;
    end if;
  end process;

  REG2 : process(CLK)
  begin
    if rising_edge(CLK) then
      if move_b1_buffer = '1' then
        current_b1_buffer     <= next_b1_buffer;
      end if;
    end if;
  end process;


  REG3 : process(CLK)
  begin
    if rising_edge(CLK) then
      if move_b2_buffer = '1' then
        current_b2_buffer     <= next_b2_buffer;
      end if;
    end if;
  end process;

--   syn_real_reading  <= not not_syn_read and current_SYN_DATAREADY_OUT;
--   syn_wait_for_read <= not_syn_read and current_SYN_DATAREADY_OUT;

  buf_SYN_READ_IN <= SYN_READ_IN;

--   both_active  <= combined_COMB_DATAREADY_IN and not not_syn_read;
--   syn_only     <= not combined_COMB_DATAREADY_IN and not not_syn_read;
--   comb_only    <= combined_COMB_DATAREADY_IN and not_syn_read;
--   both_idle    <= not combined_COMB_DATAREADY_IN and not_syn_read;
--
--   not_syn_read <= not buf_SYN_READ_IN or RESET;

end trb_net_sbuf_arch;

