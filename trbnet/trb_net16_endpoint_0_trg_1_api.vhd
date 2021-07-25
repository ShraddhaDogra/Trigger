-- an active api together with an iobuf

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;


--Entity decalaration for clock generator
entity trb_net16_endpoint_0_trg_1_api is

  generic (
    API_TYPE                : integer range 0 to 1 := c_API_PASSIVE;
    IBUF_DEPTH              : integer range 0 to 6 := 6;--c_FIFO_BRAM;
    FIFO_TO_INT_DEPTH       : integer range 0 to 6 := 6;--c_FIFO_SMALL;
    FIFO_TO_APL_DEPTH       : integer range 0 to 6 := 0;--c_FIFO_SMALL;
    SBUF_VERSION            : integer range 0 to 1 := c_SBUF_FULL;
    IBUF_SECURE_MODE        : integer range 0 to 1 := c_SECURE_MODE;
    API_SECURE_MODE_TO_APL  : integer range 0 to 1 := c_NON_SECURE_MODE;
    API_SECURE_MODE_TO_INT  : integer range 0 to 1 := c_SECURE_MODE;
    OBUF_DATA_COUNT_WIDTH   : integer range 0 to 7 := std_DATA_COUNT_WIDTH;
    INIT_CAN_SEND_DATA      : integer range 0 to 1 := c_NO;
    REPLY_CAN_SEND_DATA     : integer range 0 to 1 := c_YES;
    REPLY_CAN_RECEIVE_DATA  : integer range 0 to 1 := c_YES;
    USE_CHECKSUM            : integer range 0 to 1 := c_YES;
    DAT_CHANNEL             : integer range 0 to 3 := c_SLOW_CTRL_CHANNEL
    );

  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    --  Media direction port
    MED_DATAREADY_OUT  : out std_logic;
    MED_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    MED_READ_IN        : in  std_logic;

    MED_DATAREADY_IN   : in  std_logic;
    MED_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    MED_READ_OUT       : out std_logic;

    MED_STAT_OP_IN     : in  std_logic_vector(15 downto 0);
    MED_CTRL_OP_OUT    : out std_logic_vector(15 downto 0);

    -- APL Transmitter port
    APL_DATA_IN:       in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    APL_PACKET_NUM_IN: in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    APL_DATAREADY_IN:  in  std_logic;
    APL_READ_OUT:      out std_logic;
    APL_SHORT_TRANSFER_IN: in  std_logic;
    APL_DTYPE_IN:      in  std_logic_vector (3 downto 0);
    APL_ERROR_PATTERN_IN: in  std_logic_vector (31 downto 0);
    APL_SEND_IN:       in  std_logic;
    APL_TARGET_ADDRESS_IN: in  std_logic_vector (15 downto 0);

    -- Receiver port
    APL_DATA_OUT:      out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    APL_PACKET_NUM_OUT:out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    APL_TYP_OUT:       out std_logic_vector (2 downto 0);
    APL_DATAREADY_OUT: out std_logic;
    APL_READ_IN:       in  std_logic;

    -- APL Control port
    APL_RUN_OUT:       out std_logic;
    APL_MY_ADDRESS_IN: in  std_logic_vector (15 downto 0);
    APL_SEQNR_OUT:     out std_logic_vector (7 downto 0);
    APL_LENGTH_IN:     in  std_logic_vector (15 downto 0);

    -- Status and control port
    STAT_GEN:          out std_logic_vector (31 downto 0);
    STAT_INIT_BUFFER:  out std_logic_vector (31 downto 0);
    STAT_REPLY_BUFFER: out std_logic_vector (31 downto 0);
    STAT_api_control_signals: out std_logic_vector(31 downto 0);
    STAT_MPLEX:        out std_logic_vector(31 downto 0);
    CTRL_GEN:          in  std_logic_vector (31 downto 0);
    CTRL_SEQNR_RESET:  in std_logic;
    MPLEX_CTRL: in  std_logic_vector (31 downto 0);
    API_STAT_FIFO_TO_INT: out std_logic_vector(31 downto 0);
    API_STAT_FIFO_TO_APL: out std_logic_vector(31 downto 0);
    STAT_INIT_OBUF_DEBUG      : out std_logic_vector (31 downto 0);
    STAT_REPLY_OBUF_DEBUG     : out std_logic_vector (31 downto 0)
    );
end entity;

architecture trb_net16_endpoint_0_trg_1_api_arch of trb_net16_endpoint_0_trg_1_api is

  component trb_net16_iobuf is
    generic (
      IBUF_DEPTH            : integer range 0 to 6 := c_FIFO_BRAM;--std_FIFO_DEPTH;
      IBUF_SECURE_MODE      : integer range 0 to 1 := c_NO;--std_IBUF_SECURE_MODE;
      SBUF_VERSION          : integer range 0 to 1 := std_SBUF_VERSION;
      OBUF_DATA_COUNT_WIDTH : integer range 2 to 7 := std_DATA_COUNT_WIDTH;
      USE_ACKNOWLEDGE       : integer range 0 to 1 := std_USE_ACKNOWLEDGE;
      USE_CHECKSUM          : integer range 0 to 1 := c_YES;
      USE_VENDOR_CORES      : integer range 0 to 1 := c_YES;
      INIT_CAN_SEND_DATA    : integer range 0 to 1 := c_YES;
      REPLY_CAN_SEND_DATA   : integer range 0 to 1 := c_YES;
      REPLY_CAN_RECEIVE_DATA : integer range 0 to 1 := c_YES
      );
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      --  Media direction port
      MED_INIT_DATAREADY_OUT: out std_logic;
      MED_INIT_DATA_OUT:      out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_INIT_PACKET_NUM_OUT:out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      MED_INIT_READ_IN:       in  std_logic;

      MED_REPLY_DATAREADY_OUT: out std_logic;
      MED_REPLY_DATA_OUT:      out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_REPLY_PACKET_NUM_OUT:out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      MED_REPLY_READ_IN:       in  std_logic;

      MED_DATAREADY_IN:  in  std_logic;
      MED_DATA_IN:       in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN: in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
      MED_READ_OUT:      out std_logic;
      MED_ERROR_IN:      in  std_logic_vector (2 downto 0);

      -- Internal direction port

      INT_INIT_DATAREADY_OUT: out std_logic;
      INT_INIT_DATA_OUT:      out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_INIT_PACKET_NUM_OUT:out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      INT_INIT_READ_IN:       in  std_logic;

      INT_INIT_DATAREADY_IN:  in  std_logic;
      INT_INIT_DATA_IN:       in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_INIT_PACKET_NUM_IN: in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
      INT_INIT_READ_OUT:      out std_logic;

      INT_REPLY_DATAREADY_OUT: out std_logic;
      INT_REPLY_DATA_OUT:      out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_REPLY_PACKET_NUM_OUT:out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      INT_REPLY_READ_IN:       in  std_logic;

      INT_REPLY_DATAREADY_IN:  in  std_logic;
      INT_REPLY_DATA_IN:       in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_REPLY_PACKET_NUM_IN :in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_REPLY_READ_OUT:      out std_logic;

      -- Status and control port
      STAT_GEN:               out std_logic_vector (31 downto 0);
      STAT_IBUF_BUFFER:       out std_logic_vector (31 downto 0);
      CTRL_GEN:               in  std_logic_vector (31 downto 0);
      STAT_INIT_OBUF_DEBUG      : out std_logic_vector (31 downto 0);
      STAT_REPLY_OBUF_DEBUG     : out std_logic_vector (31 downto 0)
      );
  end component;

  component trb_net16_api_base is
    generic (
      API_TYPE          : integer range 0 to 1 := c_API_PASSIVE;
      FIFO_TO_INT_DEPTH : integer range 0 to 6 := 6;--std_FIFO_DEPTH;
      FIFO_TO_APL_DEPTH : integer range 1 to 6 := 6;--std_FIFO_DEPTH;
      FORCE_REPLY       : integer range 0 to 1 := std_FORCE_REPLY;
      SBUF_VERSION      : integer range 0 to 1 := std_SBUF_VERSION;
      USE_VENDOR_CORES  : integer range 0 to 1 := c_YES;
      SECURE_MODE_TO_APL: integer range 0 to 1 := c_YES;
      SECURE_MODE_TO_INT: integer range 0 to 1 := c_YES;
      APL_WRITE_ALL_WORDS:integer range 0 to 1 := c_YES;
      BROADCAST_BITMASK : std_logic_vector(7 downto 0) := x"FF"
      );

    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      -- APL Transmitter port
      APL_DATA_IN           : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      APL_PACKET_NUM_IN     : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      APL_DATAREADY_IN      : in  std_logic;
      APL_READ_OUT          : out std_logic;
      APL_SHORT_TRANSFER_IN : in  std_logic;
      APL_DTYPE_IN          : in  std_logic_vector (3 downto 0);
      APL_ERROR_PATTERN_IN  : in  std_logic_vector (31 downto 0);
      APL_SEND_IN           : in  std_logic;
      APL_TARGET_ADDRESS_IN : in  std_logic_vector (15 downto 0);-- the target (only for active APIs)

      -- Receiver port
      APL_DATA_OUT          : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      APL_PACKET_NUM_OUT    : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      APL_TYP_OUT           : out std_logic_vector (2 downto 0);
      APL_DATAREADY_OUT     : out std_logic;
      APL_READ_IN           : in  std_logic;

      -- APL Control port
      APL_RUN_OUT           : out std_logic;
      APL_MY_ADDRESS_IN     : in  std_logic_vector (15 downto 0);
      APL_SEQNR_OUT         : out std_logic_vector (7 downto 0);
      APL_LENGTH_IN         : in  std_logic_vector (15 downto 0);
      -- Internal direction port
      -- the ports with master or slave in their name are to be mapped by the active api
      -- to the init respectivly the reply path and vice versa in the passive api.
      -- lets define: the "master" path is the path that I send data on.
      -- master_data_out and slave_data_in are only used in active API for termination
      INT_MASTER_DATAREADY_OUT  : out std_logic;
      INT_MASTER_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_MASTER_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_MASTER_READ_IN        : in  std_logic;

      INT_MASTER_DATAREADY_IN   : in  std_logic;
      INT_MASTER_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_MASTER_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_MASTER_READ_OUT       : out std_logic;

      INT_SLAVE_DATAREADY_OUT   : out std_logic;
      INT_SLAVE_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_SLAVE_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_SLAVE_READ_IN         : in  std_logic;

      INT_SLAVE_DATAREADY_IN    : in  std_logic;
      INT_SLAVE_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_SLAVE_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_SLAVE_READ_OUT        : out std_logic;

      -- Status and control port
      CTRL_SEQNR_RESET          : in  std_logic;
      STAT_FIFO_TO_INT          : out std_logic_vector(31 downto 0);
      STAT_FIFO_TO_APL          : out std_logic_vector(31 downto 0)
      );
  end component;

  component trb_net16_io_multiplexer is
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      --  Media direction port
      MED_DATAREADY_IN   : in  STD_LOGIC;
      MED_DATA_IN        : in  STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  STD_LOGIC_VECTOR (c_NUM_WIDTH-1 downto 0);
      MED_READ_OUT       : out STD_LOGIC;

      MED_DATAREADY_OUT  : out STD_LOGIC;
      MED_DATA_OUT       : out STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out STD_LOGIC_VECTOR (c_NUM_WIDTH-1 downto 0);
      MED_READ_IN        : in  STD_LOGIC;

      -- Internal direction port
      INT_DATA_OUT       : out STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
      INT_PACKET_NUM_OUT : out STD_LOGIC_VECTOR (c_NUM_WIDTH-1 downto 0);
      INT_DATAREADY_OUT  : out STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)-1 downto 0);
      INT_READ_IN        : in  STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)-1 downto 0);

      INT_DATAREADY_IN   : in  STD_LOGIC_VECTOR (2**c_MUX_WIDTH-1 downto 0);
      INT_DATA_IN        : in  STD_LOGIC_VECTOR (c_DATA_WIDTH*(2**c_MUX_WIDTH)-1 downto 0);
      INT_PACKET_NUM_IN  : in  STD_LOGIC_VECTOR (c_NUM_WIDTH*(2**c_MUX_WIDTH)-1 downto 0);
      INT_READ_OUT       : out STD_LOGIC_VECTOR (2**c_MUX_WIDTH-1 downto 0);

      -- Status and control port
      CTRL               : in  STD_LOGIC_VECTOR (31 downto 0);
      STAT               : out STD_LOGIC_VECTOR (31 downto 0)
      );
  end component;

  component trb_net16_term_buf is
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    MED_INIT_DATAREADY_OUT   : out std_logic;
    MED_INIT_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
    MED_INIT_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH-1  downto 0);
    MED_INIT_READ_IN         : in  std_logic;

    MED_REPLY_DATAREADY_OUT  : out std_logic;
    MED_REPLY_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
    MED_REPLY_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1  downto 0);
    MED_REPLY_READ_IN        : in  std_logic;

    MED_DATAREADY_IN         : in  std_logic;
    MED_DATA_IN              : in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
    MED_PACKET_NUM_IN        : in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
    MED_READ_OUT             : out std_logic
    );
  end component;

signal apl_to_buf_INIT_DATAREADY: std_logic;
signal apl_to_buf_INIT_DATA     : std_logic_vector (c_DATA_WIDTH-1 downto 0);
signal apl_to_buf_INIT_PACKET_NUM:std_logic_vector (c_NUM_WIDTH-1 downto 0);
signal apl_to_buf_INIT_READ     : std_logic;

signal buf_to_apl_INIT_DATAREADY: std_logic;
signal buf_to_apl_INIT_DATA     : std_logic_vector (c_DATA_WIDTH-1 downto 0);
signal buf_to_apl_INIT_PACKET_NUM:std_logic_vector (c_NUM_WIDTH-1 downto 0);
signal buf_to_apl_INIT_READ     : std_logic;

signal apl_to_buf_REPLY_DATAREADY: std_logic;
signal apl_to_buf_REPLY_DATA     : std_logic_vector (c_DATA_WIDTH-1 downto 0);
signal apl_to_buf_REPLY_PACKET_NUM:std_logic_vector (c_NUM_WIDTH-1 downto 0);
signal apl_to_buf_REPLY_READ     : std_logic;

signal buf_to_apl_REPLY_DATAREADY: std_logic;
signal buf_to_apl_REPLY_DATA     : std_logic_vector (c_DATA_WIDTH-1 downto 0);
signal buf_to_apl_REPLY_PACKET_NUM:std_logic_vector (c_NUM_WIDTH-1 downto 0);
signal buf_to_apl_REPLY_READ     : std_logic;

-- for the connection to the multiplexer
signal MED_INIT_DATAREADY_OUT  : std_logic;
signal MED_INIT_DATA_OUT       : std_logic_vector (c_DATA_WIDTH-1 downto 0);
signal MED_INIT_PACKET_NUM_OUT : std_logic_vector (c_NUM_WIDTH-1 downto 0);
signal MED_INIT_READ_IN        : std_logic;

signal MED_IO_DATAREADY_IN  : std_logic;
signal MED_IO_DATA_IN       : std_logic_vector (c_DATA_WIDTH-1 downto 0);
signal MED_IO_PACKET_NUM_IN : std_logic_vector (c_NUM_WIDTH-1 downto 0);
signal MED_IO_READ_OUT      : std_logic;

signal MED_REPLY_DATAREADY_OUT  : std_logic;
signal MED_REPLY_DATA_OUT       : std_logic_vector (c_DATA_WIDTH-1 downto 0);
signal MED_REPLY_PACKET_NUM_OUT : std_logic_vector (c_NUM_WIDTH-1 downto 0);
signal MED_REPLY_READ_IN        : std_logic;

signal m_DATAREADY_OUT : std_logic_vector (2**c_MUX_WIDTH-1 downto 0);
signal m_DATA_OUT      : std_logic_vector (c_DATA_WIDTH*2**c_MUX_WIDTH-1 downto 0);
signal m_PACKET_NUM_OUT: std_logic_vector (c_NUM_WIDTH*2**c_MUX_WIDTH-1 downto 0);
signal m_READ_IN       : std_logic_vector (2**c_MUX_WIDTH-1 downto 0);

signal m_DATAREADY_IN  : std_logic_vector (2**(c_MUX_WIDTH-1)-1 downto 0);
signal m_DATA_IN       : std_logic_vector (c_DATA_WIDTH-1 downto 0);
signal m_PACKET_NUM_IN : std_logic_vector (c_NUM_WIDTH-1 downto 0);
signal m_READ_OUT      : std_logic_vector (2**(c_MUX_WIDTH-1)-1 downto 0);

signal buf_STAT_INIT_BUFFER : std_logic_vector (31 downto 0);
signal buf_api_stat_fifo_to_apl, buf_api_stat_fifo_to_int : std_logic_vector (31 downto 0);

signal reset_internal : std_logic;


begin

  reset_internal <= MED_STAT_OP_IN(13) or RESET;
  MED_CTRL_OP_OUT(15) <= MED_STAT_OP_IN(15);
  MED_CTRL_OP_OUT(14 downto 0) <= (others => '0');
  STAT_REPLY_BUFFER <= (others => '0');

  --Connections for data channel
    genmuxcon : for i in 0 to 2**(c_MUX_WIDTH-1)-1 generate
      gendat: if i = DAT_CHANNEL generate
        m_DATAREADY_OUT(i*2) <= MED_INIT_DATAREADY_OUT;
        m_DATAREADY_OUT(i*2+1) <= MED_REPLY_DATAREADY_OUT;
        m_DATA_OUT((i*2+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH*2) <= MED_INIT_DATA_OUT;
        m_DATA_OUT((i*2+2)*c_DATA_WIDTH-1 downto (i*2+1)*c_DATA_WIDTH) <= MED_REPLY_DATA_OUT;
        m_PACKET_NUM_OUT((i*2+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH*2) <= MED_INIT_PACKET_NUM_OUT;
        m_PACKET_NUM_OUT((i*2+2)*c_NUM_WIDTH-1 downto (i*2+1)*c_NUM_WIDTH) <= MED_REPLY_PACKET_NUM_OUT;
        MED_INIT_READ_IN <= m_READ_IN(i*2);
        MED_REPLY_READ_IN <= m_READ_IN(i*2+1);

        MED_IO_DATAREADY_IN <= m_DATAREADY_IN(i);
        MED_IO_DATA_IN <= m_DATA_IN(c_DATA_WIDTH-1 downto 0);
        MED_IO_PACKET_NUM_IN <= m_PACKET_NUM_IN(c_NUM_WIDTH-1 downto 0);
        m_READ_OUT(i) <= MED_IO_READ_OUT;
      end generate;
      genelse: if i /= DAT_CHANNEL generate
        termbuf: trb_net16_term_buf
          port map(
            CLK    => CLK,
            RESET  => reset_internal,
            CLK_EN => CLK_EN,
            MED_INIT_DATAREADY_OUT      => m_DATAREADY_OUT(i*2),
            MED_INIT_DATA_OUT           => m_DATA_OUT((i*2+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH*2),
            MED_INIT_PACKET_NUM_OUT     => m_PACKET_NUM_OUT((i*2+1)*c_NUM_WIDTH-1 downto (i*2)*c_NUM_WIDTH),
            MED_INIT_READ_IN            => m_READ_IN(i*2),
            MED_REPLY_DATAREADY_OUT      => m_DATAREADY_OUT(i*2+1),
            MED_REPLY_DATA_OUT           => m_DATA_OUT((i*2+2)*c_DATA_WIDTH-1 downto (i*2+1)*c_DATA_WIDTH),
            MED_REPLY_PACKET_NUM_OUT     => m_PACKET_NUM_OUT((i*2+2)*c_NUM_WIDTH-1 downto (i*2+1)*c_NUM_WIDTH),
            MED_REPLY_READ_IN            => m_READ_IN(i*2+1),

            MED_DATAREADY_IN       => m_DATAREADY_IN(i),
            MED_DATA_IN            => m_DATA_IN(c_DATA_WIDTH-1 downto 0),
            MED_PACKET_NUM_IN      => m_PACKET_NUM_IN(c_NUM_WIDTH-1 downto 0),
            MED_READ_OUT           => m_READ_OUT(i)

            );
      end generate;
    end generate;



  gen_actapi: if API_TYPE = 1 generate
    DAT_ACTIVE_API: trb_net16_api_base
      generic map (
        API_TYPE          => API_TYPE,
        FIFO_TO_INT_DEPTH => FIFO_TO_INT_DEPTH,
        FIFO_TO_APL_DEPTH => FIFO_TO_APL_DEPTH,
        FORCE_REPLY       => cfg_FORCE_REPLY(DAT_CHANNEL),
        SBUF_VERSION      => SBUF_VERSION
        )
      port map (
        --  Misc
        CLK    => CLK,
        RESET  => reset_internal,
        CLK_EN => CLK_EN,
        -- APL Transmitter port
        APL_DATA_IN           => APL_DATA_IN,
        APL_PACKET_NUM_IN     => APL_PACKET_NUM_IN,
        APL_DATAREADY_IN      => APL_DATAREADY_IN,
        APL_READ_OUT          => APL_READ_OUT,
        APL_SHORT_TRANSFER_IN => APL_SHORT_TRANSFER_IN,
        APL_DTYPE_IN          => APL_DTYPE_IN,
        APL_ERROR_PATTERN_IN  => APL_ERROR_PATTERN_IN,
        APL_SEND_IN           => APL_SEND_IN,
        APL_TARGET_ADDRESS_IN => APL_TARGET_ADDRESS_IN,
        -- Receiver port
        APL_DATA_OUT      => APL_DATA_OUT,
        APL_PACKET_NUM_OUT=> APL_PACKET_NUM_OUT,
        APL_TYP_OUT       => APL_TYP_OUT,
        APL_DATAREADY_OUT => APL_DATAREADY_OUT,
        APL_READ_IN       => APL_READ_IN,
        -- APL Control port
        APL_RUN_OUT       => APL_RUN_OUT,
        APL_MY_ADDRESS_IN => APL_MY_ADDRESS_IN,
        APL_SEQNR_OUT     => APL_SEQNR_OUT,
        APL_LENGTH_IN     => APL_LENGTH_IN,
        -- Internal direction port
        INT_MASTER_DATAREADY_OUT => apl_to_buf_INIT_DATAREADY,
        INT_MASTER_DATA_OUT      => apl_to_buf_INIT_DATA,
        INT_MASTER_PACKET_NUM_OUT=> apl_to_buf_INIT_PACKET_NUM,
        INT_MASTER_READ_IN       => apl_to_buf_INIT_READ,
        INT_MASTER_DATAREADY_IN  => buf_to_apl_INIT_DATAREADY,
        INT_MASTER_DATA_IN       => buf_to_apl_INIT_DATA,
        INT_MASTER_PACKET_NUM_IN => buf_to_apl_INIT_PACKET_NUM,
        INT_MASTER_READ_OUT      => buf_to_apl_INIT_READ,
        INT_SLAVE_DATAREADY_OUT  => apl_to_buf_REPLY_DATAREADY,
        INT_SLAVE_DATA_OUT       => apl_to_buf_REPLY_DATA,
        INT_SLAVE_PACKET_NUM_OUT => apl_to_buf_REPLY_PACKET_NUM,
        INT_SLAVE_READ_IN        => apl_to_buf_REPLY_READ,
        INT_SLAVE_DATAREADY_IN => buf_to_apl_REPLY_DATAREADY,
        INT_SLAVE_DATA_IN      => buf_to_apl_REPLY_DATA,
        INT_SLAVE_PACKET_NUM_IN=> buf_to_apl_REPLY_PACKET_NUM,
        INT_SLAVE_READ_OUT     => buf_to_apl_REPLY_READ,
        -- Status and control port
        CTRL_SEQNR_RESET      => CTRL_SEQNR_RESET,
        STAT_FIFO_TO_INT => buf_api_stat_fifo_to_int,
        STAT_FIFO_TO_APL => buf_api_stat_fifo_to_apl
        );
  end generate;

  gen_pasapi: if API_TYPE = 0 generate
    DAT_PASSIVE_API: trb_net16_api_base
      generic map (
        API_TYPE          => API_TYPE,
        FIFO_TO_INT_DEPTH => FIFO_TO_INT_DEPTH,
        FIFO_TO_APL_DEPTH => FIFO_TO_APL_DEPTH,
        FORCE_REPLY       => cfg_FORCE_REPLY(DAT_CHANNEL),
        SBUF_VERSION      => SBUF_VERSION
        )
      port map (
        --  Misc
        CLK    => CLK,
        RESET  => reset_internal,
        CLK_EN => CLK_EN,
        -- APL Transmitter port
        APL_DATA_IN           => APL_DATA_IN,
        APL_PACKET_NUM_IN     => APL_PACKET_NUM_IN,
        APL_DATAREADY_IN      => APL_DATAREADY_IN,
        APL_READ_OUT          => APL_READ_OUT,
        APL_SHORT_TRANSFER_IN => APL_SHORT_TRANSFER_IN,
        APL_DTYPE_IN          => APL_DTYPE_IN,
        APL_ERROR_PATTERN_IN  => APL_ERROR_PATTERN_IN,
        APL_SEND_IN           => APL_SEND_IN,
        APL_TARGET_ADDRESS_IN => APL_TARGET_ADDRESS_IN,
        -- Receiver port
        APL_DATA_OUT      => APL_DATA_OUT,
        APL_PACKET_NUM_OUT=> APL_PACKET_NUM_OUT,
        APL_TYP_OUT       => APL_TYP_OUT,
        APL_DATAREADY_OUT => APL_DATAREADY_OUT,
        APL_READ_IN       => APL_READ_IN,
        -- APL Control port
        APL_RUN_OUT       => APL_RUN_OUT,
        APL_MY_ADDRESS_IN => APL_MY_ADDRESS_IN,
        APL_SEQNR_OUT     => APL_SEQNR_OUT,
        APL_LENGTH_IN     => APL_LENGTH_IN,
        -- Internal direction port
        INT_MASTER_DATAREADY_OUT => apl_to_buf_REPLY_DATAREADY,
        INT_MASTER_DATA_OUT      => apl_to_buf_REPLY_DATA,
        INT_MASTER_PACKET_NUM_OUT=> apl_to_buf_REPLY_PACKET_NUM,
        INT_MASTER_READ_IN       => apl_to_buf_REPLY_READ,
        INT_MASTER_DATAREADY_IN  => buf_to_apl_REPLY_DATAREADY,
        INT_MASTER_DATA_IN       => buf_to_apl_REPLY_DATA,
        INT_MASTER_PACKET_NUM_IN => buf_to_apl_REPLY_PACKET_NUM,
        INT_MASTER_READ_OUT      => buf_to_apl_REPLY_READ,
        INT_SLAVE_DATAREADY_OUT  => apl_to_buf_INIT_DATAREADY,
        INT_SLAVE_DATA_OUT       => apl_to_buf_INIT_DATA,
        INT_SLAVE_PACKET_NUM_OUT => apl_to_buf_INIT_PACKET_NUM,
        INT_SLAVE_READ_IN        => apl_to_buf_INIT_READ,
        INT_SLAVE_DATAREADY_IN => buf_to_apl_INIT_DATAREADY,
        INT_SLAVE_DATA_IN      => buf_to_apl_INIT_DATA,
        INT_SLAVE_PACKET_NUM_IN=> buf_to_apl_INIT_PACKET_NUM,
        INT_SLAVE_READ_OUT     => buf_to_apl_INIT_READ,
        -- Status and control port
        CTRL_SEQNR_RESET      => CTRL_SEQNR_RESET,
        STAT_FIFO_TO_INT => buf_api_stat_fifo_to_int,
        STAT_FIFO_TO_APL => buf_api_stat_fifo_to_apl
        );
  end generate;
api_stat_fifo_to_apl <= buf_api_stat_fifo_to_apl;
api_stat_fifo_to_int <= buf_api_stat_fifo_to_int;

STAT_api_control_signals(2 downto 0)  <= APL_DATA_IN(2 downto 0);
STAT_api_control_signals(3)           <= APL_DATAREADY_IN;
STAT_api_control_signals(4)           <= APL_SEND_IN;
STAT_api_control_signals(7 downto 5)  <= (others => '0');
STAT_api_control_signals(10 downto 8) <= apl_to_buf_INIT_DATA(2 downto 0);
STAT_api_control_signals(11)           <= apl_to_buf_INIT_DATAREADY;
STAT_api_control_signals(12)           <= apl_to_buf_INIT_READ;
STAT_api_control_signals(15 downto 13) <= (others => '0');
STAT_api_control_signals(19 downto 16) <= MED_INIT_DATA_OUT(3 downto 0);
STAT_api_control_signals(21 downto 20) <= MED_INIT_PACKET_NUM_OUT(1 downto 0);
STAT_api_control_signals(22)           <= MED_INIT_DATAREADY_OUT and MED_INIT_READ_IN;
STAT_api_control_signals(23)           <= apl_to_buf_REPLY_DATAREADY;
STAT_api_control_signals(24)           <= MED_REPLY_DATAREADY_OUT;
STAT_api_control_signals(25)           <= MED_INIT_DATAREADY_OUT;
STAT_api_control_signals(26)           <= apl_to_buf_INIT_DATAREADY;
STAT_api_control_signals(27)           <= reset_internal;
STAT_api_control_signals(28) <= '0';
--STAT_api_control_signals(30 downto 13) <= (others => '0');

STAT_api_control_signals(31)           <= buf_to_apl_INIT_READ;
--STAT_api_control_signals(30)           <= buf_to_apl_INIT_PACKET_NUM(0);
--STAT_api_control_signals(29)           <= buf_to_apl_INIT_DATAREADY;
STAT_api_control_signals(30) <= buf_api_stat_fifo_to_apl(3);
STAT_api_control_signals(29) <= buf_api_stat_fifo_to_apl(14);


IOBUF: trb_net16_iobuf

  generic map (
    IBUF_DEPTH          => IBUF_DEPTH,
    IBUF_SECURE_MODE    => IBUF_SECURE_MODE,
    SBUF_VERSION        => SBUF_VERSION,
    USE_ACKNOWLEDGE     => cfg_USE_ACKNOWLEDGE(DAT_CHANNEL),
    USE_CHECKSUM        => USE_CHECKSUM,
    INIT_CAN_SEND_DATA  => INIT_CAN_SEND_DATA,
    REPLY_CAN_SEND_DATA => REPLY_CAN_SEND_DATA,
    REPLY_CAN_RECEIVE_DATA => REPLY_CAN_RECEIVE_DATA
    )
  port map (
    --  Misc
    CLK     => CLK ,
    RESET   => reset_internal,
    CLK_EN  => CLK_EN,
    --  Media direction port
    MED_INIT_DATAREADY_OUT  => MED_INIT_DATAREADY_OUT,
    MED_INIT_DATA_OUT       => MED_INIT_DATA_OUT,
    MED_INIT_PACKET_NUM_OUT => MED_INIT_PACKET_NUM_OUT,
    MED_INIT_READ_IN        => MED_INIT_READ_IN,

    MED_DATAREADY_IN   => MED_IO_DATAREADY_IN,
    MED_DATA_IN        => MED_IO_DATA_IN,
    MED_PACKET_NUM_IN  => MED_IO_PACKET_NUM_IN,
    MED_READ_OUT       => MED_IO_READ_OUT,
    MED_ERROR_IN       => MED_STAT_OP_IN(2 downto 0),

    MED_REPLY_DATAREADY_OUT => MED_REPLY_DATAREADY_OUT,
    MED_REPLY_DATA_OUT      => MED_REPLY_DATA_OUT,
    MED_REPLY_PACKET_NUM_OUT=> MED_REPLY_PACKET_NUM_OUT,
    MED_REPLY_READ_IN       => MED_REPLY_READ_IN,

    -- Internal direction port

    INT_INIT_DATAREADY_OUT => buf_to_apl_INIT_DATAREADY,
    INT_INIT_DATA_OUT      => buf_to_apl_INIT_DATA,
    INT_INIT_PACKET_NUM_OUT=> buf_to_apl_INIT_PACKET_NUM,
    INT_INIT_READ_IN       => buf_to_apl_INIT_READ,

    INT_INIT_DATAREADY_IN  => apl_to_buf_INIT_DATAREADY,
    INT_INIT_DATA_IN       => apl_to_buf_INIT_DATA,
    INT_INIT_PACKET_NUM_IN => apl_to_buf_INIT_PACKET_NUM,
    INT_INIT_READ_OUT      => apl_to_buf_INIT_READ,

    INT_REPLY_DATAREADY_OUT => buf_to_apl_REPLY_DATAREADY,
    INT_REPLY_DATA_OUT      => buf_to_apl_REPLY_DATA,
    INT_REPLY_PACKET_NUM_OUT=> buf_to_apl_REPLY_PACKET_NUM,
    INT_REPLY_READ_IN       => buf_to_apl_REPLY_READ,

    INT_REPLY_DATAREADY_IN  => apl_to_buf_REPLY_DATAREADY,
    INT_REPLY_DATA_IN       => apl_to_buf_REPLY_DATA,
    INT_REPLY_PACKET_NUM_IN => apl_to_buf_REPLY_PACKET_NUM,
    INT_REPLY_READ_OUT      => apl_to_buf_REPLY_READ,

    -- Status and control port
    STAT_GEN               => STAT_GEN,
    STAT_IBUF_BUFFER       => buf_STAT_INIT_BUFFER,
    CTRL_GEN               => CTRL_GEN,
    STAT_INIT_OBUF_DEBUG   => STAT_INIT_OBUF_DEBUG,
    STAT_REPLY_OBUF_DEBUG  => STAT_REPLY_OBUF_DEBUG
    );
  STAT_INIT_BUFFER <= buf_STAT_INIT_BUFFER;

  MPLEX: trb_net16_io_multiplexer

    port map (
      CLK      => CLK,
      RESET    => reset_internal,
      CLK_EN   => CLK_EN,
      MED_DATAREADY_IN   => MED_DATAREADY_IN,
      MED_DATA_IN        => MED_DATA_IN,
      MED_PACKET_NUM_IN  => MED_PACKET_NUM_IN,
      MED_READ_OUT       => MED_READ_OUT,
      MED_DATAREADY_OUT  => MED_DATAREADY_OUT,
      MED_DATA_OUT       => MED_DATA_OUT,
      MED_PACKET_NUM_OUT => MED_PACKET_NUM_OUT,
      MED_READ_IN        => MED_READ_IN,
      INT_DATAREADY_OUT  => m_DATAREADY_IN,
      INT_DATA_OUT       => m_DATA_IN,
      INT_PACKET_NUM_OUT => m_PACKET_NUM_IN,
      INT_READ_IN        => m_READ_OUT,
      INT_DATAREADY_IN   => m_DATAREADY_OUT,
      INT_DATA_IN        => m_DATA_OUT,
      INT_PACKET_NUM_IN  => m_PACKET_NUM_OUT,
      INT_READ_OUT       => m_READ_IN,
      CTRL               => MPLEX_CTRL,
      STAT               => STAT_MPLEX
      );

end architecture;

