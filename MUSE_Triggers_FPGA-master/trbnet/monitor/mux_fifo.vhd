-- ***********************************************************************************
-- ***********************************************************************************
--
--   The FIFO MUX
--	 ------------
--
--
--
--
--
-- ***********************************************************************************
-- ***********************************************************************************


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

library work;
use work.monitor_config.all;


entity fifo_mux is
  port(
    CLK        : in std_logic;
    RESET      : in std_logic;
    CLK_EN     : in std_logic;

    READ_IN    : in std_logic;                    -- Slow Control READ
    ADDR_IN    : in std_logic_vector(7 downto 0); -- Slow Control ADDR

    READ_OUT   : out std_logic_vector(FIFO_NUM-1 downto 0);         -- MUX-to-FIFO READ

    DATA_IN    : in std_logic_vector(FIFO_NUM*FIFO_BUS-1 downto 0); -- FIFO data
    VALID_IN   : in std_logic_vector(FIFO_NUM-1 downto 0);          -- FIFO valid
    STATUS_IN  : in std_logic_vector(8*FIFO_NUM-1 downto 0);        -- FIFO stats

    DATA_OUT   : out std_logic_vector(FIFO_BUS-1 downto 0);      -- MUX Data as received from the FIFO
    VALID_OUT  : out std_logic;                                  -- MUX Valid
    STATUS_OUT : out std_logic_vector(7 downto 0) := "00000000" -- MUX status bits
  );
end entity;

architecture basic of fifo_mux is

type   STATES is (IDLE, MONITOR, INIT);
signal state,next_state : STATES := IDLE;

signal buf_read_out, next_buf_read_out : std_logic_vector(FIFO_NUM-1 downto 0) := (others => '0');
signal stat, next_stat : std_logic_vector(7 downto 0) := "00000000";
signal buf_data_out, next_buf_data_out : std_logic_vector(31 downto 0) := (others => '0');
signal val, next_val : std_logic := '0';
signal handle, next_handle : integer range 0 to 255 := 0;

begin

  READ_OUT   <= buf_read_out;
  DATA_OUT   <= buf_data_out;
  VALID_OUT  <= val;
  STATUS_OUT <= stat;

  proc_register : process(CLK)
  begin
  if rising_edge(CLK) then
    state           <= next_state;
    buf_data_out    <= next_buf_data_out;
    buf_read_out    <= next_buf_read_out;
    stat            <= next_stat;
    val             <= next_val;
    handle          <= next_handle;
  end if;
  end process;

  proc_MUX : process(state, ADDR_IN, RESET, READ_IN, DATA_IN, VALID_IN, STATUS_IN, handle)
  begin
  next_state        <= state;
  next_buf_read_out <= (others => '0');
  next_stat(0)      <= '0';  -- UNKNOWN ADDRESS
  next_stat(1)      <= '0';  -- FIFO_EMPTY
  next_stat(2)      <= '0';  -- FIFO_FULL
  next_buf_data_out <= (others => '0');
  next_val          <= '0';
  next_handle       <= handle;

  case state is
    when IDLE =>
      if READ_IN = '1' then
        next_state <= INIT;
        next_handle <= to_integer(unsigned(ADDR_IN));
      end if;
    when INIT =>
      if handle < FIFO_NUM then
        next_buf_read_out(handle) <= '1';
        next_state                <= MONITOR;
      else
        next_stat(0) <= '1';
        next_state <= IDLE;
      end if;
    when MONITOR =>
      if VALID_IN(handle) = '1' then
        next_buf_data_out <= DATA_IN( FIFO_BUS*handle+FIFO_BUS-1 downto FIFO_BUS*handle );
        next_val          <= '1';
        next_state        <= IDLE;
      elsif STATUS_IN(8*handle+1) = '1' then
        next_stat(1) <= '1';
        next_state   <= IDLE;
      end if;
    when others =>
  end case;
  if RESET = '1' then
    next_stat(0) <= '0';
    next_stat(1) <= '0';
    next_stat(2) <= '0';
    next_buf_data_out <= (others => '0');
    next_buf_read_out <= (others => '0');
    next_val          <= '0';
    next_state        <= IDLE;
    next_handle       <= 0;
  end if;
  end process;

end architecture;
