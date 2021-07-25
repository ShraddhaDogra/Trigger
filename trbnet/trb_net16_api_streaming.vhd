LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;


entity trb_net16_api_streaming is
  generic(
    USE_VENDOR_CORES   : integer range 0 to 1 := c_YES;
    FIFO_TO_INT_DEPTH  : integer range 0 to 6 := 6;
    FIFO_TO_APL_DEPTH  : integer range 1 to 6 := 6;
    FORCE_REPLY        : integer range 0 to 1 := std_FORCE_REPLY;
    SBUF_VERSION       : integer range 0 to 1 := std_SBUF_VERSION;
    SECURE_MODE_TO_APL : integer range 0 to 1 := c_YES;
    SECURE_MODE_TO_INT : integer range 0 to 1 := c_YES;
    APL_WRITE_ALL_WORDS: integer range 0 to 1 := c_NO
    );
  port(
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    INT_INIT_DATAREADY_IN    : in  std_logic;
    INT_INIT_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    INT_INIT_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    INT_INIT_READ_OUT        : out std_logic;

    INT_REPLY_DATAREADY_OUT  : out std_logic;
    INT_REPLY_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    INT_REPLY_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    INT_REPLY_READ_IN        : in  std_logic;

    INT_REPLY_DATAREADY_IN   : in  std_logic;
    INT_REPLY_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    INT_REPLY_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    INT_REPLY_READ_OUT       : out std_logic;

    --apl init channel
    APL_INIT_DATA_IN         : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    APL_INIT_PACKET_NUM_IN   : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    APL_INIT_DATAREADY_IN    : out std_logic;

    --apl reply sending
    APL_DATA_IN              : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    APL_PACKET_NUM_IN        : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    APL_DATAREADY_IN         : in  std_logic;
    APL_READ_OUT             : out std_logic;
    APL_SHORT_TRANSFER_IN    : in  std_logic;
    APL_DTYPE_IN             : in  std_logic_vector (3 downto 0);
    APL_ERROR_PATTERN_IN     : in  std_logic_vector (31 downto 0);
    APL_SEND_IN              : in  std_logic;

    -- reply receiving
    APL_DATA_OUT             : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    APL_PACKET_NUM_OUT       : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    APL_TYP_OUT              : out std_logic_vector (2 downto 0);
    APL_DATAREADY_OUT        : out std_logic;
    APL_READ_IN              : in  std_logic;

    -- APL Control port
    APL_RUN_OUT              : out std_logic;
    APL_MY_ADDRESS_IN        : in  std_logic_vector (15 downto 0);
    APL_SEQNR_OUT            : out std_logic_vector (7 downto 0);
    APL_LOOPBACK             : in  std_logic;

    STAT_FIFO_TO_INT         : out std_logic_vector(31 downto 0);
    STAT_FIFO_TO_APL         : out std_logic_vector(31 downto 0)
  );
end entity;


architecture trb_net16_api_streaming_arch of trb_net16_api_streaming is
  component trb_net16_dummy_fifo is
    port (
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      DATA_IN         : in  std_logic_vector(c_DATA_WIDTH - 1 downto 0);  -- Input data
      PACKET_NUM_IN   : in  std_logic_vector(1 downto 0);  -- Input data
      WRITE_ENABLE_IN : in  std_logic;
      DATA_OUT        : out std_logic_vector(c_DATA_WIDTH - 1 downto 0);  -- Output data
      PACKET_NUM_OUT  : out std_logic_vector(1 downto 0);  -- Input data
      READ_ENABLE_IN  : in  std_logic;
      FULL_OUT        : out std_logic;    -- Full Flag
      EMPTY_OUT       : out std_logic
      );
  end component;

  component trb_net16_fifo is
    generic (
      DEPTH      : integer := 3;       -- Depth of the FIFO, 2^(n+1) 64Bit packets
      USE_VENDOR_CORES : integer := c_YES
      );
    port (
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      DATA_IN         : in  std_logic_vector(c_DATA_WIDTH - 1 downto 0);  -- Input data
      PACKET_NUM_IN   : in  std_logic_vector(1 downto 0);  -- Input data
      WRITE_ENABLE_IN : in  std_logic;
      DATA_OUT        : out std_logic_vector(c_DATA_WIDTH - 1 downto 0);  -- Output data
      PACKET_NUM_OUT  : out std_logic_vector(1 downto 0);  -- Input data
      READ_ENABLE_IN  : in  std_logic;
      FULL_OUT        : out std_logic;    -- Full Flag
      EMPTY_OUT       : out std_logic
      );
  end component;

  component trb_net16_sbuf is
    generic (
      VERSION    : integer := 0
      );
    port(
      --  Misc
      CLK               : in std_logic;
      RESET             : in std_logic;
      CLK_EN            : in std_logic;
      --  port to combinatorial logic
      COMB_DATAREADY_IN : in  STD_LOGIC;  --comb logic provides data word
      COMB_next_READ_OUT: out STD_LOGIC;  --sbuf can read in NEXT cycle
      COMB_READ_IN      : in  STD_LOGIC;  --comb logic IS reading
      COMB_DATA_IN      : in  STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0); -- Data word
      COMB_PACKET_NUM_IN: in  STD_LOGIC_VECTOR(c_NUM_WIDTH-1 downto 0);
      -- Port to synchronous output.
      SYN_DATAREADY_OUT : out STD_LOGIC;
      SYN_DATA_OUT      : out STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0); -- Data word
      SYN_PACKET_NUM_OUT: out STD_LOGIC_VECTOR(c_NUM_WIDTH-1 downto 0);
      SYN_READ_IN       : in  STD_LOGIC;
      -- Status and control port
      STAT_BUFFER       : out STD_LOGIC
      );
  end component;

  component trb_net16_term is
    generic (
      USE_APL_PORT : integer range 0 to 1 := 0;
      SECURE_MODE : integer range 0 to 1 := 0
               --if secure_mode is not used, apl must provide error pattern and dtype until
               --next trigger comes in. In secure mode these must be available when hold_trm goes low
      );
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      INT_DATAREADY_OUT:     out std_logic;
      INT_DATA_OUT:          out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      INT_PACKET_NUM_OUT:    out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_READ_IN:           in  std_logic;
      INT_DATAREADY_IN:      in  std_logic;
      INT_DATA_IN:           in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      INT_PACKET_NUM_IN:     in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_READ_OUT:          out std_logic;
      -- "mini" APL, just to see the triggers coming in
      APL_DTYPE_OUT:         out std_logic_vector (3 downto 0);  -- see NewTriggerBusNetworkDescr
      APL_ERROR_PATTERN_OUT: out std_logic_vector (31 downto 0); -- see NewTriggerBusNetworkDescr
      APL_SEQNR_OUT:         out std_logic_vector (7 downto 0);
      APL_GOT_TRM:           out std_logic;
      APL_RELEASE_TRM:       in std_logic;
      APL_ERROR_PATTERN_IN:  in std_logic_vector (31 downto 0)
      -- Status and control port
      );
  end component;

  component trb_net_sbuf is
    generic (
      DATA_WIDTH  : integer := c_DATA_WIDTH + c_NUM_WIDTH;
      VERSION: integer := SBUF_VERSION);
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      --  port to combinatorial logic
      COMB_DATAREADY_IN:  in  STD_LOGIC;  --comb logic provides data word
      COMB_next_READ_OUT: out STD_LOGIC;  --sbuf can read in NEXT cycle
      COMB_READ_IN:       in  STD_LOGIC;  --comb logic IS reading
      COMB_DATA_IN:       in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0); -- Data word
      SYN_DATAREADY_OUT:  out STD_LOGIC;
      SYN_DATA_OUT:       out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0); -- Data word
      SYN_READ_IN:        in  STD_LOGIC;
      STAT_BUFFER:        out STD_LOGIC
      );
  end component;

  -- signals for the APL to INT fifo:
  signal fifo_to_int_data_in : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal fifo_to_int_packet_num_in : std_logic_vector(1 downto 0);
  signal fifo_to_int_write : std_logic;
  signal fifo_to_int_data_out : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal fifo_to_int_packet_num_out : std_logic_vector(1 downto 0);
  signal fifo_to_int_long_packet_num_out : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal fifo_to_int_read : std_logic;
  signal fifo_to_int_full : std_logic;
  signal fifo_to_int_empty : std_logic;

  -- signals for the INT to APL:
  signal fifo_to_apl_data_in : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal fifo_to_apl_packet_num_in : std_logic_vector(1 downto 0);
  signal fifo_to_apl_write : std_logic;
  signal fifo_to_apl_data_out : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal fifo_to_apl_packet_num_out : std_logic_vector(1 downto 0);
  signal fifo_to_apl_long_packet_num_out : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal fifo_to_apl_read : std_logic;
  signal fifo_to_apl_full : std_logic;
  signal fifo_to_apl_empty : std_logic;
  signal saved_fifo_to_apl_packet_type, current_fifo_to_apl_packet_type : std_logic_vector(2 downto 0);

  signal saved_fifo_to_apl_long_packet_num_out : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal saved_fifo_to_int_long_packet_num_out : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal last_fifo_to_apl_read                 : std_logic;
  signal last_fifo_to_int_read                 : std_logic;

  signal state_bits, state_bits_to_int, state_bits_to_apl : std_logic_vector(2 downto 0);
--  signal slave_running, next_slave_running, get_slave_running, release_slave_running : std_logic;

  signal next_INT_REPLY_DATA_OUT: std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal next_INT_REPLY_PACKET_NUM_OUT: std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal next_INT_REPLY_DATAREADY_OUT: std_logic;
  signal sbuf_free, sbuf_next_READ: std_logic;
  signal reg_INT_REPLY_READ_OUT: std_logic;
  signal next_APL_DATAREADY_OUT, reg_APL_DATAREADY_OUT: std_logic;
  signal next_APL_DATA_OUT, reg_APL_DATA_OUT: std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal next_APL_PACKET_NUM_OUT, reg_APL_PACKET_NUM_OUT: std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal next_APL_TYP_OUT, reg_APL_TYP_OUT, buf_APL_TYP_OUT: std_logic_vector(2 downto 0);

  type OUTPUT_SELECT is (HDR, DAT, TRM, TRM_COMB);
  signal out_select: OUTPUT_SELECT;
  signal sequence_counter,next_sequence_counter : std_logic_vector(7 downto 0);
  signal combined_header_F1, combined_header_F2, combined_header_F3, combined_header_F0    : std_logic_vector(15 downto 0);
  signal combined_trailer_F1, combined_trailer_F2, combined_trailer_F3, combined_trailer_F0 : std_logic_vector(15 downto 0);
  signal registered_trailer_F1, registered_trailer_F2, registered_trailer_F3, registered_trailer_F0 : std_logic_vector(15 downto 0);
  signal current_combined_header, current_registered_trailer, current_data : std_logic_vector(15 downto 0);

  signal update_registered_trailer: std_logic;
  signal master_counter : std_logic_vector(c_NUM_WIDTH-1 downto 0);

  type PAS_API_TO_APL_STATE_T is (sa_IDLE, sa_INACTIVE);
  signal state_to_apl, next_state_to_apl : PAS_API_TO_APL_STATE_T;

  type state_to_int_t is ( INACTIVE, IDLE, SEND_SHORT, SEND_HEADER, RUNNING, SEND_TRAILER, SHUTDOWN);
  signal state_to_int, next_state_to_int : state_to_int_t;

--  type API_STATE is (IDLE, SEND_HEADER, RUNNING, SHUTDOWN, SEND_SHORT, SEND_TRAILER, WAITING,MY_ERROR);
--  signal current_state, next_state : API_STATE;
  signal throw_away : std_logic;
  signal fifo_to_apl_read_before : std_logic;
  signal fifo_to_int_read_before : std_logic;

  signal sbuf_to_apl_next_READ : std_logic;
  signal sbuf_to_apl_free : std_logic;
  signal sbuf_apl_type_dataready : std_logic;

  signal master_start, master_end, slave_start, slave_end : std_logic;
  signal master_running, slave_running : std_logic;

  signal buf_INT_REPLY_PACKET_NUM_OUT : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal buf_INT_REPLY_DATAREADY_OUT : std_logic;

  signal next_fifo_was_not_empty, fifo_was_not_empty : std_logic;

begin

    APL_INIT_DATAREADY_IN  <= INT_INIT_DATAREADY_IN;
    APL_INIT_DATA_IN       <= INT_INIT_DATA_IN;
    APL_INIT_PACKET_NUM_IN <= INT_INIT_PACKET_NUM_IN;
    INT_INIT_READ_OUT      <= '1';

---------------------------------------
-- fifo to internal
---------------------------------------

    FIFO_TO_INT: trb_net16_fifo
      generic map (
        DEPTH => FIFO_TO_INT_DEPTH,
        USE_VENDOR_CORES => USE_VENDOR_CORES)
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        DATA_IN         => fifo_to_int_data_in,
        PACKET_NUM_IN   => fifo_to_int_packet_num_in,
        WRITE_ENABLE_IN => fifo_to_int_write,
        DATA_OUT        => fifo_to_int_data_out,
        PACKET_NUM_OUT  => fifo_to_int_packet_num_out,
        READ_ENABLE_IN  => fifo_to_int_read,
        FULL_OUT        => fifo_to_int_full,
        EMPTY_OUT       => fifo_to_int_empty
        );

  STAT_FIFO_TO_INT(2 downto 0)   <= fifo_to_int_data_in(2 downto 0);
  STAT_FIFO_TO_INT(3)            <= fifo_to_int_write;
  STAT_FIFO_TO_INT(6 downto 4)   <= buf_INT_REPLY_PACKET_NUM_OUT;
  STAT_FIFO_TO_INT(7)            <= buf_INT_REPLY_DATAREADY_OUT;
  STAT_FIFO_TO_INT(8)            <= INT_REPLY_READ_IN;
  STAT_FIFO_TO_INT(11 downto 9)  <= fifo_to_int_data_out(2 downto 0);
  STAT_FIFO_TO_INT(12)           <= fifo_to_int_read;
  STAT_FIFO_TO_INT(13)           <= fifo_to_int_read_before;
  STAT_FIFO_TO_INT(14)           <= fifo_to_int_full;
  STAT_FIFO_TO_INT(15)           <= fifo_to_int_empty;
  STAT_FIFO_TO_INT(16)           <= next_APL_DATAREADY_OUT;
  STAT_FIFO_TO_INT(17)           <= sbuf_to_apl_free;
  STAT_FIFO_TO_INT(18)           <= fifo_to_apl_read_before;
  STAT_FIFO_TO_INT(19)           <= fifo_to_apl_read;
  STAT_FIFO_TO_INT(20)           <= fifo_to_apl_empty;
  STAT_FIFO_TO_INT(21)           <= fifo_to_apl_write;
  STAT_FIFO_TO_INT(24 downto 22) <= next_INT_REPLY_PACKET_NUM_OUT;
  STAT_FIFO_TO_INT(25)           <= next_INT_REPLY_DATAREADY_OUT;
  STAT_FIFO_TO_INT(28 downto 26) <= state_bits_to_int;
  STAT_FIFO_TO_INT(31 downto 29) <= state_bits_to_apl;
---------------------------------------
-- fifo to apl
---------------------------------------

    FIFO_TO_APL: trb_net16_fifo
      generic map (
        DEPTH => FIFO_TO_APL_DEPTH,
        USE_VENDOR_CORES => USE_VENDOR_CORES)
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        DATA_IN         => fifo_to_apl_data_in,
        PACKET_NUM_IN   => fifo_to_apl_packet_num_in,
        WRITE_ENABLE_IN => fifo_to_apl_write,
        DATA_OUT        => fifo_to_apl_data_out,
        PACKET_NUM_OUT  => fifo_to_apl_packet_num_out,
        READ_ENABLE_IN  => fifo_to_apl_read,
        FULL_OUT        => fifo_to_apl_full,
        EMPTY_OUT       => fifo_to_apl_empty
        );

  STAT_FIFO_TO_APL(2 downto 0)   <= fifo_to_apl_data_in(2 downto 0);
  STAT_FIFO_TO_APL(3)            <= fifo_to_apl_write;
  STAT_FIFO_TO_APL(9 downto 8)   <= fifo_to_apl_data_out(1 downto 0);
  STAT_FIFO_TO_APL(11)           <= fifo_to_apl_read;
  STAT_FIFO_TO_APL(14)           <= fifo_to_apl_full;
  STAT_FIFO_TO_APL(15)           <= fifo_to_apl_empty;
  STAT_FIFO_TO_APL(7 downto 4)   <= (others => '0');
  --STAT_FIFO_TO_APL(13 downto 12) <= (others => '0');
  STAT_FIFO_TO_APL(31 downto 16) <= (others => '0');
  STAT_FIFO_TO_APL(13)           <= reg_INT_REPLY_READ_OUT;
  STAT_FIFO_TO_APL(12)           <= INT_REPLY_DATAREADY_IN;
  STAT_FIFO_TO_APL(10)           <= reg_APL_DATAREADY_OUT;

---------------------------------------
-- a sbuf (to_int direction)
---------------------------------------
  gen_int_sbuf : if SECURE_MODE_TO_INT = 1 generate
    SBUF: trb_net16_sbuf
      generic map (
        VERSION    => SBUF_VERSION)
      port map (
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        COMB_DATAREADY_IN  => next_INT_REPLY_DATAREADY_OUT,
        COMB_next_READ_OUT => sbuf_next_READ,
        COMB_READ_IN       => '1',
        COMB_DATA_IN       => next_INT_REPLY_DATA_OUT,
        COMB_PACKET_NUM_IN => next_INT_REPLY_PACKET_NUM_OUT,
        SYN_DATAREADY_OUT  => buf_INT_REPLY_DATAREADY_OUT,
        SYN_DATA_OUT       => INT_REPLY_DATA_OUT,
        SYN_PACKET_NUM_OUT => buf_INT_REPLY_PACKET_NUM_OUT,
        SYN_READ_IN        => INT_REPLY_READ_IN
        );

    process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            sbuf_free <= '0';
          else
            sbuf_free <= sbuf_next_READ or INT_REPLY_READ_IN;
          end if;
        end if;
      end process;
  end generate;
  gen_int_nonsbuf : if SECURE_MODE_TO_INT = 0 generate
    buf_INT_REPLY_DATAREADY_OUT <= next_INT_REPLY_DATAREADY_OUT;
    INT_REPLY_DATA_OUT <= next_INT_REPLY_DATA_OUT;
    buf_INT_REPLY_PACKET_NUM_OUT <= next_INT_REPLY_PACKET_NUM_OUT;
    sbuf_free <= INT_REPLY_READ_IN;
  end generate;
INT_REPLY_PACKET_NUM_OUT <= buf_INT_REPLY_PACKET_NUM_OUT;
INT_REPLY_DATAREADY_OUT  <= buf_INT_REPLY_DATAREADY_OUT;
---------------------------------------
-- a sbuf (to_apl direction)
---------------------------------------
  gen_apl_sbuf : if SECURE_MODE_TO_APL = 1 generate
    SBUF_TO_APL: trb_net16_sbuf
      generic map (
        VERSION    => SBUF_VERSION)
      port map (
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        COMB_DATAREADY_IN  => next_APL_DATAREADY_OUT,
        COMB_next_READ_OUT => sbuf_to_apl_next_READ,
        COMB_READ_IN       => '1',
        COMB_DATA_IN       => next_APL_DATA_OUT,
        COMB_PACKET_NUM_IN => next_APL_PACKET_NUM_OUT,
        SYN_DATAREADY_OUT  => reg_APL_DATAREADY_OUT,
        SYN_DATA_OUT       => reg_APL_DATA_OUT,
        SYN_PACKET_NUM_OUT => reg_APL_PACKET_NUM_OUT,
        SYN_READ_IN        => APL_READ_IN
        );
    SBUF_TO_APL2: trb_net_sbuf
      generic map (
        VERSION    => SBUF_VERSION,
        DATA_WIDTH => 3)
      port map (
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        COMB_DATAREADY_IN  => next_APL_DATAREADY_OUT,
        COMB_next_READ_OUT => open,
        COMB_READ_IN       => '1',
        COMB_DATA_IN       => next_APL_TYP_OUT,
        SYN_DATAREADY_OUT  => sbuf_apl_type_dataready,
        SYN_DATA_OUT       => buf_APL_TYP_OUT,
        SYN_READ_IN        => APL_READ_IN
        );

    reg_APL_TYP_OUT <= TYPE_ILLEGAL when sbuf_apl_type_dataready = '0' else buf_APL_TYP_OUT;
    process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            sbuf_to_apl_free <= '0';
          else
            sbuf_to_apl_free <= sbuf_to_apl_next_READ;
          end if;
        end if;
      end process;
  end generate;

  gen_apl_nonsbuf : if SECURE_MODE_TO_APL = 0 generate
    reg_APL_DATAREADY_OUT  <= next_APL_DATAREADY_OUT;
    reg_APL_DATA_OUT       <= next_APL_DATA_OUT;
    reg_APL_PACKET_NUM_OUT <= next_APL_PACKET_NUM_OUT;
    reg_APL_TYP_OUT        <= next_APL_TYP_OUT;
    sbuf_to_apl_free       <= APL_READ_IN;
  end generate;

  next_APL_DATA_OUT       <= fifo_to_apl_data_out;
  next_APL_PACKET_NUM_OUT <= fifo_to_apl_long_packet_num_out;
  next_APL_TYP_OUT        <= current_fifo_to_apl_packet_type;
  APL_DATAREADY_OUT  <= reg_APL_DATAREADY_OUT;
  APL_DATA_OUT       <= reg_APL_DATA_OUT;
  APL_PACKET_NUM_OUT <= reg_APL_PACKET_NUM_OUT;
  APL_TYP_OUT        <= reg_APL_TYP_OUT;
  APL_SEQNR_OUT      <= sequence_counter;



---------------------------------------
--regenerate long packet numbers
---------------------------------------
  fifo_to_int_long_packet_num_out(2) <= fifo_to_int_packet_num_out(1);
  fifo_to_int_long_packet_num_out(0) <= fifo_to_int_packet_num_out(0);
  fifo_to_int_long_packet_num_out(1) <= not saved_fifo_to_int_long_packet_num_out(1) when last_fifo_to_int_read = '1' and not saved_fifo_to_int_long_packet_num_out(2) = '1' and saved_fifo_to_int_long_packet_num_out(0) = '1' else saved_fifo_to_int_long_packet_num_out(1);

  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          saved_fifo_to_int_long_packet_num_out <= (others => '0');
        elsif last_fifo_to_int_read = '1' then
          saved_fifo_to_int_long_packet_num_out <= fifo_to_int_long_packet_num_out;
        end if;
      end if;
    end process;


  fifo_to_apl_long_packet_num_out(2) <= fifo_to_apl_packet_num_out(1);
  fifo_to_apl_long_packet_num_out(0) <= fifo_to_apl_packet_num_out(0);
  fifo_to_apl_long_packet_num_out(1) <= not saved_fifo_to_apl_long_packet_num_out(1) when last_fifo_to_apl_read = '1' and not saved_fifo_to_apl_long_packet_num_out(2) = '1' and saved_fifo_to_apl_long_packet_num_out(0) = '1' else saved_fifo_to_apl_long_packet_num_out(1);

  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          saved_fifo_to_apl_long_packet_num_out <= (others => '0');
        elsif last_fifo_to_apl_read = '1' then
          saved_fifo_to_apl_long_packet_num_out <= fifo_to_apl_long_packet_num_out;
        end if;
      end if;
    end process;

---------------------------------------
-- save packet type
---------------------------------------

  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' or fifo_to_apl_long_packet_num_out = c_F3 then
          saved_fifo_to_apl_packet_type <= TYPE_ILLEGAL;
        elsif fifo_to_apl_long_packet_num_out = c_H0 then
          saved_fifo_to_apl_packet_type <= fifo_to_apl_data_out(2 downto 0);
        end if;
      end if;
    end process;
  --create comb. real packet type
  current_fifo_to_apl_packet_type <= fifo_to_apl_data_out(2 downto 0) when (fifo_to_apl_long_packet_num_out = c_H0)
                         else saved_fifo_to_apl_packet_type;

---------------------------------------
-- select data for int direction
---------------------------------------


  process(current_combined_header, current_registered_trailer, current_data, out_select)
    begin
      case out_select is
        when HDR      => next_INT_REPLY_DATA_OUT <= current_combined_header;
        when TRM      => next_INT_REPLY_DATA_OUT <= current_registered_trailer;
        when others   => next_INT_REPLY_DATA_OUT <= current_data;
      end case;
    end process;



  process(master_counter, fifo_to_int_data_out, combined_header_F1, registered_trailer_F1,
          combined_header_F2, registered_trailer_F2, registered_trailer_F0,
          combined_header_F3, registered_trailer_F3, combined_header_F0)
    begin
      case master_counter is
        when c_F0 =>
           current_combined_header <= combined_header_F0;
           current_registered_trailer <= registered_trailer_F0;
           current_data <= fifo_to_int_data_out;
        when c_F1 =>
           current_combined_header <= combined_header_F1;
           current_registered_trailer <= registered_trailer_F1;
           current_data <= fifo_to_int_data_out;
        when c_F2 =>
           current_combined_header <= combined_header_F2;
           current_registered_trailer <= registered_trailer_F2;
           current_data <= fifo_to_int_data_out;
        when c_F3 =>
           current_combined_header <= combined_header_F3;
           current_registered_trailer <= registered_trailer_F3;
           current_data <= fifo_to_int_data_out;
        when others =>
           current_combined_header <=    "0000000000000" & TYPE_HDR;
           current_registered_trailer <= "0000000000000" & TYPE_TRM;
           current_data <= "0000000000000" & TYPE_DAT;
      end case;
    end process;

  next_INT_REPLY_PACKET_NUM_OUT <= master_counter;

  MASTER_TRANSFER_COUNTER : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          master_counter <= c_H0;
        elsif next_INT_REPLY_DATAREADY_OUT = '1' then
          if master_counter = c_max_word_number then
            master_counter <= (others => '0');
          else
            master_counter <= master_counter + 1;
          end if;
        end if;
      end if;
    end process;


---------------------------------------
-- keep track of fifo read operations
---------------------------------------
   process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          fifo_to_apl_read_before <= '0';
        else
          last_fifo_to_apl_read <= fifo_to_apl_read;
          if fifo_to_apl_read = '1' then
            fifo_to_apl_read_before <= '1';
          elsif sbuf_to_apl_free = '1' or throw_away = '1' then
            fifo_to_apl_read_before <= '0';
          end if;
        end if;
      end if;
    end process;

   process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          fifo_to_int_read_before <= '0';
        else
          last_fifo_to_int_read <= fifo_to_int_read;
          if fifo_to_int_read = '1' then
            fifo_to_int_read_before <= '1';
          elsif next_INT_REPLY_DATAREADY_OUT = '1' and master_counter /= "00" then --implies sbuf_free
            fifo_to_int_read_before <= '0';
          end if;
        end if;
      end if;
    end process;



---------------------------------------
--state machine for direction to APL
---------------------------------------
    to_apl : process(fifo_to_apl_full, reg_INT_REPLY_READ_OUT, INT_REPLY_DATAREADY_IN, fifo_to_apl_empty,
                     fifo_to_apl_long_packet_num_out, state_to_apl, reg_APL_TYP_OUT, reg_APL_PACKET_NUM_OUT,
                     sbuf_to_apl_free, INT_REPLY_DATA_IN, INT_REPLY_PACKET_NUM_IN,
                     reg_APL_DATAREADY_OUT, slave_running, fifo_to_apl_read_before, throw_away,state_to_int )
      begin
        reg_INT_REPLY_READ_OUT <= not fifo_to_apl_full;
        fifo_to_apl_write <= reg_INT_REPLY_READ_OUT and INT_REPLY_DATAREADY_IN;
        fifo_to_apl_read <= '0';
        next_APL_DATAREADY_OUT <= '0';
        next_state_to_apl <= state_to_apl;
        throw_away <= '0';
        slave_start <= '0';
        slave_end <= '0';

        case state_to_apl is
          when sa_IDLE =>
            slave_start <= fifo_to_apl_write;
            if APL_WRITE_ALL_WORDS = 0 then
              next_APL_DATAREADY_OUT <= fifo_to_apl_read_before and not fifo_to_apl_long_packet_num_out(2) and sbuf_to_apl_free;
              throw_away <= fifo_to_apl_long_packet_num_out(2);
            else
              next_APL_DATAREADY_OUT <= fifo_to_apl_read_before and sbuf_to_apl_free;
            end if;
            fifo_to_apl_read <= not fifo_to_apl_empty and not (fifo_to_apl_read_before and not sbuf_to_apl_free and not throw_away);
            if reg_APL_TYP_OUT = TYPE_TRM and reg_APL_PACKET_NUM_OUT = c_F3 and sbuf_to_apl_free = '1' then
              next_state_to_apl <= sa_INACTIVE;
              slave_end <= '1';
            end if;
          when sa_INACTIVE =>
            if state_to_int = INACTIVE then
              next_state_to_apl <= sa_IDLE;
            end if;
        end case;
      end process;

---------------------------------------
--state machine for direction to INT
---------------------------------------
    to_int : process(state_to_int, APL_SHORT_TRANSFER_IN, APL_SEND_IN, slave_start,
                     master_counter, sbuf_free, fifo_to_int_empty,  sequence_counter, fifo_to_int_read_before,
                     state_to_apl, master_start, fifo_was_not_empty)
      begin
        next_state_to_int <= state_to_int;
        update_registered_trailer <= '0';
        out_select <= DAT;
        next_INT_REPLY_DATAREADY_OUT <= '0';
        next_sequence_counter <= sequence_counter;
        fifo_to_int_read <= '0';
        master_start <= '0';
        master_end <= '0';
        next_fifo_was_not_empty <= fifo_was_not_empty or not fifo_to_int_empty;

        case state_to_int is
          when INACTIVE =>
            if slave_start = '1' then
              next_state_to_int <= IDLE;
            end if;
          when IDLE =>
            next_fifo_was_not_empty <= '0';
            if APL_SEND_IN = '1' then
              master_start <= '1';
              if APL_SHORT_TRANSFER_IN = '1' then
                next_state_to_int <= SEND_SHORT;
              else
                next_state_to_int <= SEND_HEADER;
              end if;
            end if;
          when SEND_SHORT =>
            if APL_SEND_IN = '0' then
              update_registered_trailer <= '1';
              next_state_to_int <= SEND_TRAILER;
            end if;
          when SEND_HEADER =>
            out_select <= HDR;
            next_INT_REPLY_DATAREADY_OUT <= sbuf_free;
            if master_counter = c_F3 and sbuf_free = '1' then
              next_state_to_int <= RUNNING;
            end if;
          when RUNNING =>
            fifo_to_int_read <= not fifo_to_int_empty and sbuf_free and not master_counter(2);
            next_INT_REPLY_DATAREADY_OUT <= sbuf_free and (fifo_to_int_read_before or master_counter(2));
            if APL_SEND_IN = '0' and fifo_was_not_empty = '1' then       -- terminate the transfer
              update_registered_trailer <= '1';
              if fifo_to_int_empty = '1' and master_counter = c_F3 and sbuf_free = '1' then
                next_state_to_int <= SEND_TRAILER;        -- immediate stop
              else
                next_state_to_int <= SHUTDOWN;            -- send rest of data / padding
              end if;
            end if;
          when SHUTDOWN =>
            fifo_to_int_read <= not fifo_to_int_empty and sbuf_free and not master_counter(2);
            next_INT_REPLY_DATAREADY_OUT <= sbuf_free and
                                ((fifo_to_int_read_before or master_counter(2)) or   --write data from fifo
                                (fifo_to_int_empty and not master_counter(2))); --fill with padding words
            if master_counter = c_F3 and fifo_to_int_empty = '1' and sbuf_free = '1' then
              next_state_to_int <= SEND_TRAILER;
            end if;
          when SEND_TRAILER =>
            out_select <= TRM;
            next_INT_REPLY_DATAREADY_OUT <= sbuf_free;
            if master_counter = "11" and sbuf_free = '1' then
              next_state_to_int <= INACTIVE;
              next_sequence_counter <= sequence_counter +1;
              master_end <= '1';
            end if;
        end case;
      end process;


    process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            state_to_apl <= sa_IDLE;
            state_to_int <= INACTIVE;
            sequence_counter <= (others => '0');
            fifo_was_not_empty <= '0';
          else
            state_to_apl <= next_state_to_apl;
            state_to_int <= next_state_to_int;
            sequence_counter <= next_sequence_counter;
            fifo_was_not_empty <= next_fifo_was_not_empty;
          end if;
        end if;
      end process;



---------------------------------------
--
---------------------------------------

  --save target address for passive api
  reg_hdr_f1: process(CLK)
    begin
      if rising_edge(CLK) then
        if current_fifo_to_apl_packet_type = TYPE_HDR then
          if fifo_to_apl_long_packet_num_out = c_F1 then
            combined_header_F1 <= fifo_to_apl_data_out;
          end if;
        end if;
      end if;
    end process;
  -- combine the next header
  combined_header_F0 <= APL_MY_ADDRESS_IN;
  combined_header_F2 <= (others => '0');
  combined_header_F3(15 downto 14) <= (others => '0');  -- LAY
  combined_header_F3(13 downto 12) <= (others => '0');  -- VERS
  combined_header_F3(11 downto 4)  <= sequence_counter;  -- SEQNR
  combined_header_F3(3 downto 0)   <= APL_DTYPE_IN;
  combined_trailer_F0 <= (others => '0');
  combined_trailer_F1 <= APL_ERROR_PATTERN_IN(31 downto 16);
  combined_trailer_F2 <= APL_ERROR_PATTERN_IN(15 downto 0);
  combined_trailer_F3(15 downto 14) <= (others => '0');  -- res.
  combined_trailer_F3(13 downto 12) <= (others => '0');  -- VERS
  combined_trailer_F3(11 downto 4)  <= sequence_counter;  -- SEQNR
  combined_trailer_F3(3 downto 0)   <= APL_DTYPE_IN;

  -- connect Transmitter port
  fifo_to_int_data_in       <= APL_DATA_IN;
  fifo_to_int_packet_num_in <= APL_PACKET_NUM_IN(2) & APL_PACKET_NUM_IN(0);
  fifo_to_int_write <= (APL_DATAREADY_IN and not fifo_to_int_full);
  APL_READ_OUT <= not fifo_to_int_full;  -- APL has to stop writing

  -- connect receiver
  fifo_to_apl_data_in       <= INT_REPLY_DATA_IN;
  fifo_to_apl_packet_num_in <= INT_REPLY_PACKET_NUM_IN(2) & INT_REPLY_PACKET_NUM_IN(0);
  INT_REPLY_READ_OUT        <= reg_INT_REPLY_READ_OUT;

  RUN_OUT_gen : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          APL_RUN_OUT <= '0';
        else
          if slave_start = '1' then
            APL_RUN_OUT <= '1';
          elsif slave_running = '0' and state_to_int = INACTIVE then
            APL_RUN_OUT <= '0';
          end if;
        end if;
      end if;
    end process;

  RUNNING_gen : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          master_running <= '0';
          slave_running <= '0';
        else
          if master_start = '1' then
            master_running <= '1';
          elsif master_end = '1' then
            master_running <= '0';
          end if;
          if slave_start = '1' then
            slave_running <= '1';
          elsif slave_end = '1' then
            slave_running <= '0';
          end if;
        end if;
      end if;
    end process;

  REG3 : process(CLK)
    begin
      if rising_edge(CLK) then
        if update_registered_trailer = '1' then
          registered_trailer_F0 <= combined_trailer_F0;
          registered_trailer_F1 <= combined_trailer_F1;
          registered_trailer_F2 <= combined_trailer_F2;
          registered_trailer_F3 <= combined_trailer_F3;
        end if;
      end if;
    end process;

--for simulation only


    process(state_to_apl)
    begin
      case state_to_apl is
        when sa_IDLE         => state_bits_to_apl <= "000";
        when sa_INACTIVE     => state_bits_to_apl <= "100";
        when others          => state_bits_to_apl <= "111";
      end case;
    end process;
  process(state_to_int)
    begin
      case state_to_int is
        when IDLE         => state_bits_to_int <= "000";
        when SEND_HEADER  => state_bits_to_int <= "001";
        when RUNNING      => state_bits_to_int <= "010";
        when SHUTDOWN     => state_bits_to_int <= "011";
        when SEND_SHORT   => state_bits_to_int <= "100";
        when SEND_TRAILER => state_bits_to_int <= "101";
        when INACTIVE     => state_bits_to_int <= "110";
        when others       => state_bits_to_int <= "111";
      end case;
    end process;


end architecture;
