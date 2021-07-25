library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity handler_lvl1 is
generic(
  TIMING_TRIGGER_RAW           : integer range 0 to 1 := c_YES
);
port(
  RESET                        : in  std_logic;
  RESET_FLAGS_IN               : in  std_logic;
  RESET_STATS_IN               : in  std_logic;
  CLOCK                        : in  std_logic;
  --Timing Trigger
  LVL1_TIMING_TRG_IN           : in  std_logic;    --raw trigger signal input, min. 80 ns or strobe, see generics
  LVL1_PSEUDO_TMG_TRG_IN       : in  std_logic;    --strobe for dummy timing trigger
  --LVL1_handler connection
  LVL1_TRG_RECEIVED_IN         : in  std_logic;
  LVL1_TRG_TYPE_IN             : in  std_logic_vector(3 downto 0);
  LVL1_TRG_NUMBER_IN           : in  std_logic_vector(15 downto 0);
  LVL1_TRG_CODE_IN             : in  std_logic_vector(7 downto 0);
  LVL1_TRG_INFORMATION_IN      : in  std_logic_vector(23 downto 0);
  LVL1_ERROR_PATTERN_OUT       : out std_logic_vector(31 downto 0);  --errorbits to CTS
  LVL1_TRG_RELEASE_OUT         : out std_logic := '0';               --release to CTS

  LVL1_INT_TRG_NUMBER_OUT      : out std_logic_vector(15 downto 0);  -- increased after trigger release
  LVL1_INT_TRG_LOAD_IN         : in  std_logic;                      -- load internal trigger counter
  LVL1_INT_TRG_COUNTER_IN      : in  std_logic_vector(15 downto 0);  -- load value for internal trigger counter

  --FEE logic / Data Handler
  LVL1_TRG_DATA_VALID_OUT      : out std_logic;    -- trigger type, number, code, information are valid
  LVL1_VALID_TIMING_TRG_OUT    : out std_logic;    -- valid timing trigger has been received
  LVL1_VALID_NOTIMING_TRG_OUT  : out std_logic;    -- valid trigger without timing trigger has been received
  LVL1_INVALID_TRG_OUT         : out std_logic;    -- the current trigger is invalid (e.g. no timing trigger, no LVL1...)
  LVL1_MULTIPLE_TRG_OUT        : out std_logic;    -- more than one timing trigger detected
  LVL1_DELAY_OUT               : out std_logic_vector(15 downto 0);
  LVL1_TIMEOUT_DETECTED_OUT    : out std_logic;  -- gk 11.09.10
  LVL1_SPURIOUS_TRG_OUT        : out std_logic;  -- gk 11.09.10
  LVL1_MISSING_TMG_TRG_OUT     : out std_logic;  -- gk 11.09.10
  LVL1_LONG_TRG_OUT            : out std_logic;
  SPIKE_DETECTED_OUT           : out std_logic;  -- gk 12.09.10

  LVL1_ERROR_PATTERN_IN        : in  std_logic_vector(31 downto 0);  -- error pattern from FEE
  LVL1_TRG_RELEASE_IN          : in  std_logic := '0';               -- trigger release from FEE

  --Stat/Control
  STATUS_OUT                   : out std_logic_vector (63 downto 0); -- bits for status registers
  TRG_ENABLE_IN                : in  std_logic;                      -- trigger enable flag
  TRG_INVERT_IN                : in  std_logic;                      -- trigger invert flag
  COUNTERS_STATUS_OUT          : out std_logic_vector (79 downto 0); -- 16b starting missing, multiple, spike, spurious-- gk 29.09.10
  --Debug
  DEBUG_OUT                    : out std_logic_vector (15 downto 0)
);
end entity;


architecture handler_lvl1_arch of handler_lvl1 is

-- Components
component pulse_stretch is
port(
  CLK_IN      : in  std_logic;
  RESET_IN    : in    std_logic;
  START_IN    : in  std_logic;
  PULSE_OUT    : out  std_logic;
  DEBUG_OUT    : out  std_logic_vector(15 downto 0)
);
end component pulse_stretch;

-- state machine signals
type STATES is (IDLE, BADTRG, TRGFND, LVL1FND, WAITREL, TOCFND, DONE);
signal CURRENT_STATE, NEXT_STATE: STATES;

signal toc_ce               : std_logic; -- count enable for TRG/LVL1 timeout
signal next_toc_ce          : std_logic;
signal toc_save             : std_logic; -- count enable for TRG/LVL1 timeout
signal next_toc_save        : std_logic;
signal toc_rst              : std_logic; -- reset for timout
signal next_toc_rst         : std_logic;
signal trg_rel              : std_logic; -- release LVL1 channel
signal next_trg_rel         : std_logic;
signal trg_rst              : std_logic; -- reset trg_found latch
signal next_trg_rst         : std_logic;
signal val_trg              : std_logic; -- valid timing + LVL1 trigger
signal next_val_trg         : std_logic;
signal val_ttl_trg          : std_logic; -- valid timingtriggerless trigger (who invented that name?)
signal next_val_ttl_trg     : std_logic;
signal invalid_trg          : std_logic; -- invalid trigger: LVL1 missing, or wrong information
signal next_invalid_trg     : std_logic;

signal mult_trg_found       : std_logic;

signal data_valid           : std_logic;
signal next_data_valid      : std_logic;

signal bsm_x                : std_logic_vector(3 downto 0);

-- Signals
signal lvl1_int_trg_number  : unsigned(15 downto 0);
signal lvl1_int_trg_ce      : std_logic;
signal stretched_fake_trg   : std_logic;
signal synced_timing_trg    : std_logic;
signal timing_trg_reg       : std_logic_vector(3 downto 0);
signal timing_trg_comb      : std_logic;
signal timing_trg_rising    : std_logic;
signal timing_trg_found     : std_logic;
signal timeout_ctr          : unsigned(10 downto 0);
signal timeout_found        : std_logic;
signal next_timeout_found   : std_logic;
signal trg_num_match        : std_logic;
signal next_trg_num_match   : std_logic;

signal error_pattern        : std_logic_vector(31 downto 0);
signal next_error_pattern   : std_logic_vector(31 downto 0);

signal lvl1_delay           : std_logic_vector(15 downto 0);
signal trigger_edge_count   : unsigned(15 downto 0);
signal trigger_length       : unsigned(15 downto 0);

signal debug                : std_logic_vector(15 downto 0);

-- gk 11.09.10
signal next_spurious_trg    : std_logic;
signal spurious_trg         : std_logic;
signal next_missing_tmg     : std_logic;
signal missing_tmg          : std_logic;
-- gk 12.09.10
signal short_tmg_trg        : std_logic;
-- gk 24.09.10
signal mult_trg_lock        : std_logic;
signal prev_trg_reg         : std_logic_vector(3 downto 0);
-- gk 29.09.10
signal multiple_ctr         : unsigned(15 downto 0);
signal missing_ctr          : unsigned(15 downto 0);
signal spikes_ctr           : unsigned(15 downto 0);
signal spurious_ctr         : unsigned(15 downto 0);
signal ctr_lock             : std_logic;
signal wrong_polarity       : std_logic;

signal tmg_edge_ctr         : unsigned(15 downto 0);
signal tmg_edge_found_i     : std_logic;
signal sr0                  : std_logic;
signal tmg_edge_async       : std_logic;
signal buf_STATUS_OUT       : std_logic_vector(63 downto 0);
signal waiting_for_first    : std_logic;

begin


---------------------------------------------------------------------------
-- One process for registering combinatorial signals
---------------------------------------------------------------------------
THE_SYNC_PROC: process( CLOCK )
begin
  if( rising_edge(CLOCK) ) then
    -- timeout_found <= next_timeout_found;  -- gk 28.09.10
    if RESET = '1' then
      trg_num_match <= '1';
    elsif (LVL1_TRG_RELEASE_IN = '1') then
      trg_num_match <= next_trg_num_match;
    end if;

    error_pattern <= next_error_pattern;
  end if;
end process THE_SYNC_PROC;

--------------------------------------------------------------------------
-- fake timing trigger has only 10ns length!
---------------------------------------------------------------------------
THE_PULSE_STRETCH: pulse_stretch
port map(
  CLK_IN     => CLOCK,
  RESET_IN   => RESET,
  START_IN   => LVL1_PSEUDO_TMG_TRG_IN,
  PULSE_OUT  => stretched_fake_trg,
  DEBUG_OUT  => open
);

---------------------------------------------------------------------------
-- Sync the external timing trigger, if necessary.
---------------------------------------------------------------------------
GEN_SYNC: if ( TIMING_TRIGGER_RAW = c_YES ) generate
  THE_TIMING_TRG_SYNC: signal_sync
  generic map( WIDTH => 1, DEPTH => 2 )
  port map(
    RESET    => RESET,
    CLK0     => CLOCK,
    CLK1     => CLOCK,
    D_IN(0)  => LVL1_TIMING_TRG_IN,
    D_OUT(0) => synced_timing_trg
  );

  THE_TRIGGER_SHIFT_PROC: process( CLOCK )
  begin
    if( rising_edge(CLOCK) ) then
      if( RESET = '1' ) then
        timing_trg_reg <= (others => '0');
        prev_trg_reg   <= (others => '0');  -- gk 29.09.10
      else
        prev_trg_reg   <= timing_trg_reg;  -- gk 29.09.10
        timing_trg_reg <= timing_trg_reg(2 downto 0) & timing_trg_comb; -- could be generalized here
      end if;
    end if;
  end process THE_TRIGGER_SHIFT_PROC;

  -- detect rising edge and valid length
  THE_RISING_EDGE_PROC: process( CLOCK )
  begin
    if( rising_edge(CLOCK) ) then
      if( RESET = '1' ) then
        timing_trg_rising <= '0';
      else
        -- gk 21.09.10
        timing_trg_rising <= and_all(timing_trg_reg);
        -- 0111 sequence marks the rising edge
        --timing_trg_rising <= not timing_trg_reg(3) and timing_trg_reg(2) and timing_trg_reg(1) and timing_trg_reg(0);
      end if;
    end if;
  end process THE_RISING_EDGE_PROC;

end generate GEN_SYNC;

GEN_NOSYNC: if ( TIMING_TRIGGER_RAW = c_NO ) generate
  synced_timing_trg <= LVL1_TIMING_TRG_IN;
  timing_trg_rising <= synced_timing_trg;
end generate GEN_NOSYNC;

---------------------------------------------------------------------------
-- Combine both trigger sources, check length, find edges
---------------------------------------------------------------------------
timing_trg_comb <= ((synced_timing_trg xor TRG_INVERT_IN) and TRG_ENABLE_IN) or  stretched_fake_trg;


-- latch the result for state machine
-- detect multiple timing triggers
THE_LATCH_PROC: process( CLOCK )
begin
  if( rising_edge(CLOCK) ) then
    if   ( (RESET = '1') or (trg_rst = '1') ) then
      timing_trg_found <= '0';
      --mult_trg_found   <= '0';  -- gk 24.09.10
    elsif( timing_trg_rising = '1' ) then
      timing_trg_found <= '1';
      --mult_trg_found   <= timing_trg_found;  -- gk 24.09.10
    end if;
  end if;
end process THE_LATCH_PROC;

-- gk 24.09.10
MULTIPLE_TRG_FND_PROC : process(CLOCK)
begin
  if rising_edge(CLOCK) then
    if ((RESET = '1') or (trg_rel = '1')) then
      mult_trg_lock <= '0';
      mult_trg_found <= '0';
    elsif ((timing_trg_rising = '1') and (timing_trg_reg = b"1111") and (mult_trg_lock = '0')) then
      if (timing_trg_found = '1') then
        mult_trg_found <= '1';
      end if;
      mult_trg_lock <= '1';
    elsif (timing_trg_reg /= b"1111") then
      mult_trg_lock <= '0';
    end if;
  end if;
end process MULTIPLE_TRG_FND_PROC;


-------------------------------------------------------------------------------
-- Tmg Trigger spike detect
-------------------------------------------------------------------------------

  process (tmg_edge_found_i, LVL1_TIMING_TRG_IN)
    begin
      if ( tmg_edge_found_i = '1') then 
        tmg_edge_async <= '0';
      elsif rising_edge(LVL1_TIMING_TRG_IN) then 
        tmg_edge_async <= '1'; 
      end if;
  end process;
  
  -- Asynchrones Merker-FF eintakten
  process 
    begin
      wait until rising_edge(CLOCK);
      if(tmg_edge_found_i = '1') then 
        sr0 <= '0'; 
        tmg_edge_found_i <= '0'; 
      else
        sr0 <= tmg_edge_async; 
        tmg_edge_found_i <= sr0; 
      end if;
  end process;


---------------------------------------------------------------------------
-- Timeout counter for LVL1
---------------------------------------------------------------------------
THE_TIMEOUT_CTR_PROC: process( CLOCK )
begin
  if( rising_edge(CLOCK) ) then
    if   ( (RESET = '1') or (toc_rst = '1') ) then
      timeout_ctr <= (others => '0');
    elsif( (toc_ce = '1') and (and_all(std_logic_vector(timeout_ctr)) = '0') ) then
      timeout_ctr <= timeout_ctr + to_unsigned(1,1);
    end if;
  end if;
end process THE_TIMEOUT_CTR_PROC;

-- 20.48us maximum
next_timeout_found <= and_all(std_logic_vector(timeout_ctr));

-- gk 29.09.10
SHORT_TMG_TRG_PROC : process(CLOCK)
begin
  if rising_edge(CLOCK) then
    if ((RESET = '1') or (trg_rst = '1')) then
      short_tmg_trg <= '0';
    elsif ((LVL1_TRG_RELEASE_IN = '1') and (data_valid = '0')) then
      short_tmg_trg <= '0';
    elsif ((data_valid = '1') and (trg_rel = '1')) then
      short_tmg_trg <= '0';
    -- end of signal before filling the register out with ones
    elsif ((prev_trg_reg(0) = '1') and (timing_trg_reg(0) = '0') and (prev_trg_reg(3) = '0')) then
      short_tmg_trg <= '1';
    end if;
  end if;
end process SHORT_TMG_TRG_PROC;

-- gk 29.09.10
TIMEOUT_FOUND_PROC : process(CLOCK)
begin
  if rising_edge(CLOCK) then
    if ((RESET = '1') or (trg_rst = '1')) then
      timeout_found <= '0';
    elsif (next_timeout_found = '1') then
      timeout_found <= '1';
    end if;
  end if;
end process;


---------------------------------------------------------------------------
-- State machine
---------------------------------------------------------------------------
-- state registers
STATE_MEM: process( CLOCK )
begin
  if( rising_edge(CLOCK) ) then
    if( RESET = '1' ) then
      CURRENT_STATE  <= IDLE;
      toc_ce         <= '0';
      toc_rst        <= '1';
      toc_save       <= '0';
      trg_rel        <= '0';
      trg_rst        <= '0';
      val_trg        <= '0';
      val_ttl_trg    <= '0';
      invalid_trg    <= '0';
      data_valid     <= '0';
      spurious_trg   <= '0';  -- gk 11.09.10
      missing_tmg    <= '0';  -- gk 11.09.10
    else
      CURRENT_STATE  <= NEXT_STATE;
      toc_ce         <= next_toc_ce;
      toc_rst        <= next_toc_rst;
      toc_save       <= next_toc_save;
      trg_rel        <= next_trg_rel;
      trg_rst        <= next_trg_rst;
      val_trg        <= next_val_trg;
      val_ttl_trg    <= next_val_ttl_trg;
      invalid_trg    <= next_invalid_trg;
      data_valid     <= next_data_valid;
      spurious_trg   <= next_spurious_trg;  -- gk 11.09.10
      missing_tmg    <= next_missing_tmg;  -- gk 11.09.10
    end if;
  end if;
end process STATE_MEM;

-- state transitions
STATE_TRANSFORM: process( CURRENT_STATE, LVL1_TRG_RECEIVED_IN, LVL1_TRG_TYPE_IN(3), LVL1_TRG_INFORMATION_IN(7),
              LVL1_TRG_RELEASE_IN, timing_trg_found, timing_trg_rising, timeout_found, data_valid )
begin
  NEXT_STATE       <= IDLE; -- avoid latches
  next_toc_ce      <= '0';
  next_toc_rst     <= '0';
  next_toc_save     <= '0';
  next_trg_rel     <= '0';
  next_trg_rst     <= '0';
  next_val_trg     <= '0';
  next_val_ttl_trg <= '0';
  next_invalid_trg <= '0';
  next_data_valid   <= data_valid;
  next_spurious_trg <= spurious_trg;  -- gk 11.09.10
  next_missing_tmg  <= missing_tmg;  -- gk 11.09.10

  case CURRENT_STATE is

    when IDLE    => bsm_x <= x"0";
      if   ( (timing_trg_found = '1') and (timeout_found = '0')) then  -- gk 29.09.10
        -- timing trigger has a rising edge and valid length
        NEXT_STATE       <= TRGFND;
        next_toc_rst     <= '1';
        next_val_trg     <= '1';
      elsif( (timing_trg_found = '0') and (LVL1_TRG_RECEIVED_IN = '1') and
            (LVL1_TRG_TYPE_IN(3) = '1') and (LVL1_TRG_INFORMATION_IN(7) = '1')) then
        -- timingtriggerless trigger found
        NEXT_STATE       <= LVL1FND;
        next_toc_rst     <= '1';
        next_val_ttl_trg <= '1';
        next_data_valid  <= '1';
      elsif( (timing_trg_found = '0') and (LVL1_TRG_RECEIVED_IN = '1') and
           ((LVL1_TRG_TYPE_IN(3) = '0') or (LVL1_TRG_INFORMATION_IN(7) = '0')) ) then
        -- missing timing trigger
        NEXT_STATE       <= LVL1FND; --BADTRG;  -- gk 11.09.10
        next_invalid_trg <= '1';
        next_missing_tmg <= '1';
        next_data_valid  <= '1';  -- gk 11.09.10
      else
        NEXT_STATE   <= IDLE;
      end if;

    when TRGFND  => bsm_x <= x"1";
      if (LVL1_TRG_RECEIVED_IN = '1') then
        -- suitable LVL1 information has arrived
        NEXT_STATE       <= LVL1FND;
        next_data_valid  <= '1';
        next_toc_save    <= '1';
        next_toc_rst     <= '1';
        -- gk 11.09.10
        if (LVL1_TRG_INFORMATION_IN(7) = '1') then
          next_val_ttl_trg  <= '1';
          next_spurious_trg <= '1';
        end if;
-- was commented out
       --elsif( timeout_found = '1' ) then
        -- LVL1 did not arrive in time
        --NEXT_STATE       <= TRGFND; --TOCFND;  -- gk 29.09.10
        --next_toc_rst     <= '1';  -- gk 29.09.10
        --next_trg_rst     <= '1';  -- gk 21.09.10
        --next_invalid_trg <= '1';
----------------------------
      else
        -- wait for either timeout or LVL1
        NEXT_STATE  <= TRGFND;
        next_toc_ce <= '1';
      end if;

-- gk 29.09.10
-- was commented out
--      when TOCFND  => bsm_x <= x"2";
--       NEXT_STATE <= IDLE;
----------------------------

    when LVL1FND => bsm_x <= x"3";
      if( LVL1_TRG_RELEASE_IN = '1' ) then
        -- FEE logic releases trigger
        NEXT_STATE   <= DONE;
        next_trg_rel <= '1';
        --next_trg_rst <= '1';  -- gk 21.09.10
      else
        -- FEE logic still busy
        NEXT_STATE <= LVL1FND; --WAITREL;
      end if;

    when BADTRG  => bsm_x <= x"5";
      NEXT_STATE <= DONE;
      next_trg_rel <= '1';
      -- next_trg_rst <= '1';  -- gk 21.09.10

    when DONE    => bsm_x <= x"7";
      if( LVL1_TRG_RECEIVED_IN = '0' ) then
        NEXT_STATE        <= IDLE;
        next_data_valid   <= '0';
        next_spurious_trg <= '0';  -- gk 11.09.10
        next_missing_tmg  <= '0';  -- gk 11.09.10
        next_trg_rst      <= '1';  -- gk 21.09.10
      else
        NEXT_STATE   <= DONE;
        next_trg_rst <= '1';
      end if;

    when others  =>  bsm_x <= x"f";
      NEXT_STATE <= IDLE;
  end case;
end process STATE_TRANSFORM;


---------------------------------------------------------------------------
-- Internal trigger counter, compare internal and external counters
---------------------------------------------------------------------------
THE_INTERNAL_TRG_CTR_PROC: process( CLOCK )
begin
  if( rising_edge(CLOCK) ) then
    if   ( (RESET = '1')  ) then
      lvl1_int_trg_number <= (others => '0');
      waiting_for_first   <= '1';
    elsif( LVL1_INT_TRG_LOAD_IN = '1' ) then
      lvl1_int_trg_number <= unsigned(LVL1_INT_TRG_COUNTER_IN);
    elsif( lvl1_int_trg_ce = '1' ) then
      lvl1_int_trg_number <= lvl1_int_trg_number + to_unsigned(1,1);
    elsif waiting_for_first = '1' and LVL1_TRG_RECEIVED_IN = '1' then
      lvl1_int_trg_number <= unsigned(LVL1_TRG_NUMBER_IN);
      waiting_for_first <= '0';
    end if;
  end if;
end process THE_INTERNAL_TRG_CTR_PROC;

THE_INC_CTR_PROC: process( CLOCK )
begin
  if( rising_edge(CLOCK) ) then
    lvl1_int_trg_ce <= trg_rel;
  end if;
end process THE_INC_CTR_PROC;

next_trg_num_match <= '1' when ( lvl1_int_trg_number = unsigned(LVL1_TRG_NUMBER_IN) )
                      else '0';


---------------------------------------------------------------------------
-- Input Monitoring
---------------------------------------------------------------------------
COUNT_EDGES_AND_LENGTH_PROC: process(CLOCK)
begin
  if( rising_edge(CLOCK) ) then
    if   ( RESET = '1' ) then
      trigger_edge_count <= (others => '0');
      trigger_length     <= (others => '0');
    elsif( (timing_trg_reg(1) = '0') and (timing_trg_reg(0) = '1') and (TRG_ENABLE_IN = '1') ) then
      trigger_edge_count <= trigger_edge_count + 1;
      trigger_length     <= x"0001";
    elsif( (synced_timing_trg = '1') and (trigger_length /= 0) and (TRG_ENABLE_IN = '1') )  then
      trigger_length     <= trigger_length + 1;
      trigger_edge_count <= trigger_edge_count;
    end if;
  end if;
end process COUNT_EDGES_AND_LENGTH_PROC;

-- gk 29.09.10
WRONG_POLAR_PROC : process(CLOCK)
begin
  if rising_edge(CLOCK) then
    if (RESET = '1') or (RESET_FLAGS_IN = '1') then
      wrong_polarity <= '0';
    elsif (trigger_length > 100) then
      wrong_polarity <= '1';
    end if;
    if RESET = '1' 
      or (((LVL1_TRG_RELEASE_IN = '1') and (data_valid = '0')) or ((data_valid = '1') and (trg_rel = '1'))) then
      LVL1_LONG_TRG_OUT <= '0';
    elsif (trigger_length > 100) then
      LVL1_LONG_TRG_OUT <= '1';
    end if;
  end if;
end process WRONG_POLAR_PROC;

REAL_EDGE_COUNT_PROC : process(CLOCK)
  begin
    if rising_edge(CLOCK) then
      if RESET_STATS_IN = '1' then
        tmg_edge_ctr <= (others => '0');
      elsif tmg_edge_found_i = '1' then
        tmg_edge_ctr <= tmg_edge_ctr + to_unsigned(1,1);
      end if;
    end if;
  end process;

---------------------------------------------------------------------------
-- Error bits
---------------------------------------------------------------------------
next_error_pattern(31 downto 26) <= LVL1_ERROR_PATTERN_IN(31 downto 26);

next_error_pattern(25)           <= LVL1_ERROR_PATTERN_IN(25) or timeout_found; -- timeout
next_error_pattern(24)           <= LVL1_ERROR_PATTERN_IN(24) or short_tmg_trg; -- spike detected

next_error_pattern(23 downto 19) <= LVL1_ERROR_PATTERN_IN(23 downto 19);

next_error_pattern(18)           <= LVL1_ERROR_PATTERN_IN(18) or mult_trg_found; -- multiple timing triggers
next_error_pattern(17)           <= LVL1_ERROR_PATTERN_IN(17) or invalid_trg;    -- timing trigger missing
next_error_pattern(16)           <= LVL1_ERROR_PATTERN_IN(16) or (not next_trg_num_match);  -- trigger counter mismatch
next_error_pattern(15 downto 0)  <= LVL1_ERROR_PATTERN_IN(15 downto 0);

---------------------------------------------------------------------------
-- Delay measurement
---------------------------------------------------------------------------
-- store measured delay
-- BUG: register loading is not perfect!
THE_MEASURED_DELAY_PROC: process( CLOCK )
begin
  if( rising_edge(CLOCK) ) then
    if   ( RESET = '1' ) then
      lvl1_delay <= (others => '0');
    elsif( toc_save = '1' ) then
      lvl1_delay(15 downto 11) <= (others => '0'); -- here we can store nice status bits
      lvl1_delay(10 downto 0)  <= std_logic_vector(timeout_ctr);
    end if;
  end if;
end process THE_MEASURED_DELAY_PROC;

---------------------------------------------------------------------------
-- Status bits
---------------------------------------------------------------------------

-- gk 29.09.10
STAT_PROC : process(CLOCK)
begin
  if rising_edge(CLOCK) then
    buf_STATUS_OUT(63 downto 48)  <= std_logic_vector(trigger_length);
    buf_STATUS_OUT(47 downto 32)  <= std_logic_vector(trigger_edge_count);
    buf_STATUS_OUT(31 downto 16)  <= lvl1_delay;
    buf_STATUS_OUT(15)            <= timing_trg_found;
    buf_STATUS_OUT(14)            <= data_valid;
    buf_STATUS_OUT(12)            <= not trg_num_match;
    buf_STATUS_OUT(11)            <= timeout_found;
    buf_STATUS_OUT(10 downto 8)   <= (others => '0');
    buf_STATUS_OUT(3 downto 0)    <= bsm_x;

    if (RESET = '1') or (RESET_FLAGS_IN = '1') then
      buf_STATUS_OUT(7 downto 4) <= (others => '0');
      buf_STATUS_OUT(13) <= '0';
    elsif (val_trg = '1') or (invalid_trg = '1') then
      buf_STATUS_OUT(13)            <= buf_STATUS_OUT(13) or mult_trg_found;
      buf_STATUS_OUT(7)             <= buf_STATUS_OUT(7) or wrong_polarity;
      buf_STATUS_OUT(6)             <= buf_STATUS_OUT(6) or spurious_trg;
      buf_STATUS_OUT(5)             <= buf_STATUS_OUT(5) or missing_tmg;
      buf_STATUS_OUT(4)             <= buf_STATUS_OUT(4) or short_tmg_trg;
    end if;
  end if;
end process STAT_PROC;

STATUS_OUT <= buf_STATUS_OUT;

-- STATISTICS COUNTERS
-- gk 29.09.10
STAT_CTR_PROC : process(CLOCK)
begin
  if rising_edge(CLOCK) then
    if (RESET = '1') or (RESET_STATS_IN = '1') then
      multiple_ctr <= (others => '0');
      missing_ctr  <= (others => '0');
      spikes_ctr   <= (others => '0');
      spurious_ctr <= (others => '0');
      ctr_lock     <= '0';
    elsif (invalid_trg = '1') then
      missing_ctr <= missing_ctr + to_unsigned(1,1);
    elsif (timing_trg_found = '1') and (mult_trg_found = '1') and (ctr_lock = '0') then
      multiple_ctr <= multiple_ctr + to_unsigned(1,1);
      ctr_lock <= '1';
    elsif ((prev_trg_reg(0) = '1') and (timing_trg_reg(0) = '0') and (prev_trg_reg(3) = '0')) then
      spikes_ctr <= spikes_ctr + to_unsigned(1,1);
    elsif (spurious_trg = '1') and (ctr_lock = '0') then
      spurious_ctr <= spurious_ctr + to_unsigned(1,1);
      ctr_lock <= '1';
    elsif (invalid_trg = '0') and (mult_trg_found = '0') and (spurious_trg = '0') then
      ctr_lock <= '0';
    end if;
  end if;
end process STAT_CTR_PROC;
COUNTERS_STATUS_OUT(15 downto 0)  <= std_logic_vector(missing_ctr);
COUNTERS_STATUS_OUT(31 downto 16) <= std_logic_vector(multiple_ctr);
COUNTERS_STATUS_OUT(47 downto 32) <= std_logic_vector(spikes_ctr);
COUNTERS_STATUS_OUT(63 downto 48) <= std_logic_vector(spurious_ctr);
COUNTERS_STATUS_OUT(79 downto 64) <= std_logic_vector(tmg_edge_ctr);
---------------------------------------------------------------------------
-- Debug signals
---------------------------------------------------------------------------
debug(15 downto 12) <= bsm_x;
debug(11)           <= synced_timing_trg;
debug(10)           <= timing_trg_rising;
debug(9)            <= LVL1_TRG_RECEIVED_IN;
debug(8)            <= val_trg; --LVL1_VALID_TIMING_TRG_OUT;
debug(7)            <= invalid_trg; --LVL1_INVALID_TRG_OUT;
debug(6)            <= val_ttl_trg; --LVL1_VALID_NOTIMING_TRG_OUT;
debug(5)            <= LVL1_TRG_RELEASE_IN;
debug(4)            <= data_valid;
debug(3 downto 0)   <= std_logic_vector(timeout_ctr(8 downto 5));

---------------------------------------------------------------------------
-- Outputs
---------------------------------------------------------------------------
LVL1_TRG_RELEASE_OUT        <= trg_rel;
LVL1_TRG_DATA_VALID_OUT     <= data_valid;
LVL1_VALID_TIMING_TRG_OUT   <= val_trg;
LVL1_VALID_NOTIMING_TRG_OUT <= val_ttl_trg;
LVL1_INVALID_TRG_OUT        <= invalid_trg;
LVL1_MULTIPLE_TRG_OUT       <= mult_trg_found;
LVL1_INT_TRG_NUMBER_OUT     <= std_logic_vector(lvl1_int_trg_number);
LVL1_DELAY_OUT              <= lvl1_delay;
LVL1_ERROR_PATTERN_OUT      <= error_pattern;
LVL1_TIMEOUT_DETECTED_OUT   <= timeout_found;  -- gk 11.09.10
LVL1_SPURIOUS_TRG_OUT       <= spurious_trg;   -- gk 11.09.10
LVL1_MISSING_TMG_TRG_OUT    <= missing_tmg;    -- gk 11.09.10
SPIKE_DETECTED_OUT          <= short_tmg_trg;  -- gk 29.09.10

DEBUG_OUT                   <= debug;

end architecture;
