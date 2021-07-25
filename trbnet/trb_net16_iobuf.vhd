LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

--CTRL_STAT(0) : reset packet counter in IBUF

entity trb_net16_iobuf is
  generic (
    IBUF_DEPTH            : integer range 0 to 6 := c_FIFO_BRAM;--std_FIFO_DEPTH;
    IBUF_SECURE_MODE      : integer range 0 to 1 := c_NO;--std_IBUF_SECURE_MODE;
    SBUF_VERSION          : integer range 0 to 1 := std_SBUF_VERSION;
    SBUF_VERSION_OBUF     : integer range 0 to 6 := std_SBUF_VERSION;
    OBUF_DATA_COUNT_WIDTH : integer range 2 to 7 := std_DATA_COUNT_WIDTH;
    USE_ACKNOWLEDGE       : integer range 0 to 1 := std_USE_ACKNOWLEDGE;
    USE_CHECKSUM          : integer range 0 to 1 := c_YES;
    USE_VENDOR_CORES      : integer range 0 to 1 := c_YES;
    INIT_CAN_SEND_DATA    : integer range 0 to 1 := c_YES;
    INIT_CAN_RECEIVE_DATA : integer range 0 to 1 := c_YES;
    REPLY_CAN_SEND_DATA   : integer range 0 to 1 := c_YES;
    REPLY_CAN_RECEIVE_DATA : integer range 0 to 1 := c_YES
    );
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
    --  Media direction port
    MED_INIT_DATAREADY_OUT    : out std_logic;
    MED_INIT_DATA_OUT         : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_INIT_PACKET_NUM_OUT   : out std_logic_vector (c_NUM_WIDTH-1  downto 0);
    MED_INIT_READ_IN          : in  std_logic;

    MED_REPLY_DATAREADY_OUT   : out std_logic;
    MED_REPLY_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_REPLY_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH-1  downto 0);
    MED_REPLY_READ_IN         : in  std_logic;

    MED_DATAREADY_IN          : in  std_logic;
    MED_DATA_IN               : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN         : in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
    MED_READ_OUT              : out std_logic;
    MED_ERROR_IN              : in  std_logic_vector (2 downto 0);

    -- Internal direction port

    INT_INIT_DATAREADY_OUT    : out std_logic;
    INT_INIT_DATA_OUT         : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    INT_INIT_PACKET_NUM_OUT   : out std_logic_vector (c_NUM_WIDTH-1  downto 0);
    INT_INIT_READ_IN          : in  std_logic;

    INT_INIT_DATAREADY_IN     : in  std_logic;
    INT_INIT_DATA_IN          : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    INT_INIT_PACKET_NUM_IN    : in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
    INT_INIT_READ_OUT         : out std_logic;

    INT_REPLY_DATAREADY_OUT   : out std_logic;
    INT_REPLY_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    INT_REPLY_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH-1  downto 0);
    INT_REPLY_READ_IN         : in  std_logic;

    INT_REPLY_DATAREADY_IN    : in  std_logic;
    INT_REPLY_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    INT_REPLY_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    INT_REPLY_READ_OUT        : out std_logic;

    -- Status and control port
    STAT_GEN                  : out std_logic_vector (31 downto 0);
    STAT_IBUF_BUFFER          : out std_logic_vector (31 downto 0);
    CTRL_GEN                  : in  std_logic_vector (31 downto 0);
    CTRL_OBUF_settings        : in  std_logic_vector (31 downto 0) := (others => '0'); --0..15 for init, 16..31 for reply
    STAT_INIT_OBUF_DEBUG      : out std_logic_vector (31 downto 0);
    STAT_REPLY_OBUF_DEBUG     : out std_logic_vector (31 downto 0);
    STAT_BUFFER_COUNTER       : out std_logic_vector (31 downto 0);
    STAT_DATA_COUNTER         : out std_logic_vector (31 downto 0);
    TIMER_TICKS_IN            : in  std_logic_vector (1 downto 0) := "00";
    CTRL_STAT                 : in  std_logic_vector (15 downto 0) := x"0000"
    );
end entity;

architecture trb_net16_iobuf_arch of trb_net16_iobuf is
--   -- Placer Directives
--   attribute HGROUP : string;
--   -- for whole architecture
--   attribute HGROUP of trb_net16_iobuf_arch : architecture  is "IOBUF_group";


  attribute syn_hier : string;
  attribute syn_hier of trb_net16_iobuf_arch : architecture is "firm";

  -- internal signals for the INITIBUF
  signal  IBUF_error:    STD_LOGIC_VECTOR (2 downto 0);  -- error watch needed!
  signal  IBUF_stat_buffer  :  STD_LOGIC_VECTOR (31 downto 0);
  signal  INITOBUF_stat_buffer, INITOBUF_ctrl_buffer:  STD_LOGIC_VECTOR (31 downto 0);
  signal  REPLYOBUF_stat_buffer, REPLYOBUF_ctrl_buffer:  STD_LOGIC_VECTOR (31 downto 0);
  signal ibuf_dataready_in, ibuf_read_out   : std_logic;
  signal buf_stat_buffer_counter : std_logic_vector (31 downto 0);
  signal buf_stat_data_counter : std_logic_vector (31 downto 0);

begin
  GEN_IBUF: if IBUF_DEPTH>0 generate
    ibuf_dataready_in <= MED_DATAREADY_IN;-- or MED_REPLY_DATAREADY_IN;
    MED_READ_OUT <= ibuf_read_out;
--    MED_REPLY_READ_OUT <= ibuf_read_out;

    THE_IBUF : trb_net16_ibuf
      generic map (
        DEPTH            => IBUF_DEPTH,
        USE_VENDOR_CORES => USE_VENDOR_CORES,
        USE_ACKNOWLEDGE  => USE_ACKNOWLEDGE,
        USE_CHECKSUM     => USE_CHECKSUM,
        SBUF_VERSION     => SBUF_VERSION,
        INIT_CAN_RECEIVE_DATA  => INIT_CAN_RECEIVE_DATA,
        REPLY_CAN_RECEIVE_DATA => REPLY_CAN_RECEIVE_DATA
        )
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        MED_DATAREADY_IN => ibuf_dataready_in,
        MED_DATA_IN => MED_DATA_IN,
        MED_PACKET_NUM_IN => MED_PACKET_NUM_IN,
        MED_READ_OUT => ibuf_read_out,
        MED_ERROR_IN => MED_ERROR_IN,
        INT_INIT_DATAREADY_OUT => INT_INIT_DATAREADY_OUT,
        INT_INIT_DATA_OUT => INT_INIT_DATA_OUT,
        INT_INIT_PACKET_NUM_OUT => INT_INIT_PACKET_NUM_OUT,
        INT_INIT_READ_IN => INT_INIT_READ_IN,
        INT_REPLY_DATAREADY_OUT => INT_REPLY_DATAREADY_OUT,
        INT_REPLY_DATA_OUT => INT_REPLY_DATA_OUT,
        INT_REPLY_PACKET_NUM_OUT => INT_REPLY_PACKET_NUM_OUT,
        INT_REPLY_READ_IN => INT_REPLY_READ_IN,
        INT_ERROR_OUT => IBUF_error,
        STAT_BUFFER_COUNTER => buf_stat_buffer_counter,
        STAT_DATA_COUNTER => buf_stat_data_counter,
        STAT_BUFFER(31 downto 0) => IBUF_stat_buffer,
        CTRL_STAT => CTRL_STAT
        );
  end generate;

  GEN_TERM_IBUF: if IBUF_DEPTH=0 generate
    THE_IBUF : trb_net16_term_ibuf
      generic map(
        SBUF_VERSION => SBUF_VERSION,
        SECURE_MODE  => c_YES
        )
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        MED_DATAREADY_IN => MED_DATAREADY_IN,
        MED_DATA_IN => MED_DATA_IN,
        MED_PACKET_NUM_IN => MED_PACKET_NUM_IN,
        MED_READ_OUT => MED_READ_OUT,
        MED_ERROR_IN => MED_ERROR_IN,
        INT_DATAREADY_OUT => INT_INIT_DATAREADY_OUT,
        INT_DATA_OUT => INT_INIT_DATA_OUT,
        INT_PACKET_NUM_OUT => INT_INIT_PACKET_NUM_OUT,
        INT_READ_IN => INT_INIT_READ_IN,
        INT_ERROR_OUT => IBUF_error,
        STAT_BUFFER(31 downto 0) => IBUF_stat_buffer
        );
    INT_REPLY_DATAREADY_OUT <= '0';
    INT_REPLY_DATA_OUT <= (others => '0');
    INT_REPLY_PACKET_NUM_OUT <= (others => '0');
  end generate;



  genINITOBUF1 : if INIT_CAN_SEND_DATA = 1 generate
    INITOBUF : trb_net16_obuf
      generic map (
        DATA_COUNT_WIDTH => OBUF_DATA_COUNT_WIDTH,
        USE_ACKNOWLEDGE  => USE_ACKNOWLEDGE,
        USE_CHECKSUM     => USE_CHECKSUM,
        SBUF_VERSION     => SBUF_VERSION_OBUF
        )
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        MED_DATAREADY_OUT => MED_INIT_DATAREADY_OUT,
        MED_DATA_OUT => MED_INIT_DATA_OUT,
        MED_PACKET_NUM_OUT => MED_INIT_PACKET_NUM_OUT,
        MED_READ_IN => MED_INIT_READ_IN,
        INT_DATAREADY_IN => INT_INIT_DATAREADY_IN,
        INT_DATA_IN => INT_INIT_DATA_IN,
        INT_PACKET_NUM_IN => INT_INIT_PACKET_NUM_IN,
        INT_READ_OUT => INT_INIT_READ_OUT,
        STAT_BUFFER(31 downto 0) => INITOBUF_stat_buffer,
        CTRL_BUFFER(31 downto 0) => INITOBUF_ctrl_buffer,
        CTRL_SETTINGS            => CTRL_OBUF_settings(15 downto 0),
        STAT_DEBUG => STAT_INIT_OBUF_DEBUG,
        TIMER_TICKS_IN => TIMER_TICKS_IN
        );
  end generate;
  genINITOBUF2 : if INIT_CAN_SEND_DATA = 0 generate
    gen_INITOBUF3 : if USE_ACKNOWLEDGE = 1 generate
      INITOBUF : trb_net16_obuf_nodata
        port map (
          CLK       => CLK,
          RESET     => RESET,
          CLK_EN    => CLK_EN,
          MED_DATAREADY_OUT => MED_INIT_DATAREADY_OUT,
          MED_DATA_OUT => MED_INIT_DATA_OUT,
          MED_PACKET_NUM_OUT => MED_INIT_PACKET_NUM_OUT,
          MED_READ_IN => MED_INIT_READ_IN,
          STAT_BUFFER(31 downto 0) => INITOBUF_stat_buffer,
          CTRL_BUFFER(31 downto 0) => INITOBUF_ctrl_buffer,
          STAT_DEBUG => STAT_INIT_OBUF_DEBUG
          );
      INT_INIT_READ_OUT <= '1';
    end generate;
    gen_INITOBUF4 : if USE_ACKNOWLEDGE = 0 generate
      INT_INIT_READ_OUT <= '1';
      MED_INIT_DATAREADY_OUT <= '0';
      MED_INIT_DATA_OUT <= (others => '0');
      MED_INIT_PACKET_NUM_OUT <= (others => '0');
    end generate;
  end generate;


  genREPLYOBUF1 : if REPLY_CAN_SEND_DATA = 1 generate
    REPLYOBUF : trb_net16_obuf
      generic map (
        DATA_COUNT_WIDTH => OBUF_DATA_COUNT_WIDTH,
        USE_ACKNOWLEDGE  => USE_ACKNOWLEDGE,
        USE_CHECKSUM     => USE_CHECKSUM,
        SBUF_VERSION     => SBUF_VERSION_OBUF
        )
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        MED_DATAREADY_OUT => MED_REPLY_DATAREADY_OUT,
        MED_DATA_OUT => MED_REPLY_DATA_OUT,
        MED_PACKET_NUM_OUT => MED_REPLY_PACKET_NUM_OUT,
        MED_READ_IN => MED_REPLY_READ_IN,
        INT_DATAREADY_IN => INT_REPLY_DATAREADY_IN,
        INT_DATA_IN => INT_REPLY_DATA_IN,
        INT_PACKET_NUM_IN => INT_REPLY_PACKET_NUM_IN,
        INT_READ_OUT => INT_REPLY_READ_OUT,
        STAT_BUFFER(31 downto 0) => REPLYOBUF_stat_buffer,
        CTRL_BUFFER(31 downto 0) => REPLYOBUF_ctrl_buffer,
        CTRL_SETTINGS            => CTRL_OBUF_settings(31 downto 16),
        STAT_DEBUG => STAT_REPLY_OBUF_DEBUG,
        TIMER_TICKS_IN => TIMER_TICKS_IN
        );
  end generate;
  genREPLYOBUF2 : if REPLY_CAN_SEND_DATA = 0 generate
    gen_REPLYOBUF3 : if USE_ACKNOWLEDGE = 1 generate

      REPLYOBUF : trb_net16_obuf_nodata
        port map (
          CLK       => CLK,
          RESET     => RESET,
          CLK_EN    => CLK_EN,
          MED_DATAREADY_OUT => MED_REPLY_DATAREADY_OUT,
          MED_DATA_OUT => MED_REPLY_DATA_OUT,
          MED_PACKET_NUM_OUT => MED_REPLY_PACKET_NUM_OUT,
          MED_READ_IN => MED_REPLY_READ_IN,
          STAT_BUFFER(31 downto 0) => REPLYOBUF_stat_buffer,
          CTRL_BUFFER(31 downto 0) => REPLYOBUF_ctrl_buffer,
          --CTRL_SETTINGS            => CTRL_OBUF_settings(31 downto 16),
          STAT_DEBUG => STAT_REPLY_OBUF_DEBUG
          );
      INT_REPLY_READ_OUT <= '1';
    end generate;
    gen_REPLYOBUF4 : if USE_ACKNOWLEDGE = 0 generate
      INT_REPLY_READ_OUT <= '1';
      MED_REPLY_DATAREADY_OUT <= '0';
      MED_REPLY_DATA_OUT <= (others => '0');
      MED_REPLY_PACKET_NUM_OUT <= (others => '0');
    end generate;
  end generate;

STAT_IBUF_BUFFER <= IBUF_stat_buffer;

-- build the registers according to the wiki page
  -- STAT_BUFFER(15 downto 0)
  -- STAT_INIT_BUFFER(8 downto 0) <= INITIBUF_stat_buffer(8 downto 0);
  -- STAT_INIT_BUFFER(11 downto 9) <= INITOBUF_stat_buffer(17 downto 15);
  -- STAT_INIT_BUFFER(13 downto 12) <= (others => '0');
  -- STAT_INIT_BUFFER(15 downto 14) <= INITOBUF_stat_buffer(1 downto 0);
  -- STAT_INIT_BUFFER(31 downto 16) <= INITOBUF_stat_buffer(31 downto 16);
  -- STAT_REPLY_BUFFER(11 downto 0) <= REPLYIBUF_stat_buffer(11 downto 0);
  -- STAT_REPLY_BUFFER(13 downto 12) <= (others => '0');
  -- STAT_REPLY_BUFFER(15 downto 14) <= REPLYOBUF_stat_buffer(1 downto 0);
  -- STAT_REPLY_BUFFER(31 downto 16) <= REPLYOBUF_stat_buffer(31 downto 16);

-- build the CTRL register of the OBUFs
  INITOBUF_ctrl_buffer(9 downto 0) <= IBUF_stat_buffer(9 downto 0);
  INITOBUF_ctrl_buffer(15 downto 10) <= (others => '0');
  INITOBUF_ctrl_buffer(31 downto 16) <= buf_stat_buffer_counter(15 downto 0);

  REPLYOBUF_ctrl_buffer(7 downto 0) <= IBUF_stat_buffer(7 downto 0);
  REPLYOBUF_ctrl_buffer(9 downto 8) <= IBUF_stat_buffer(11 downto 10);
  REPLYOBUF_ctrl_buffer(15 downto 10) <= (others => '0');
  REPLYOBUF_ctrl_buffer(31 downto 16) <= buf_stat_buffer_counter(31 downto 16);

  STAT_GEN  <= (others => '0');
  STAT_BUFFER_COUNTER <= buf_stat_buffer_counter;
  STAT_DATA_COUNTER   <= buf_stat_data_counter;

end architecture;
