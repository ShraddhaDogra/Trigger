LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity trb_net_bridge_acromag_endpoint is
  port(
    RESET :   in std_logic;

    clk:      in std_logic;
    RD:       in STD_LOGIC;   -- Read strobe
    WR:       in STD_LOGIC;   -- Write strobe
    DATA_OUT: out STD_LOGIC_VECTOR (31 downto 0) ; -- I/O Bus
    DATA_IN : in  STD_LOGIC_VECTOR (31 downto 0) ; -- I/O Bus
    ADDRESS:  in STD_LOGIC_VECTOR (11 downto 0);  -- Adress lines for the given space
    TRB_INTERRUPT_OUT : out STD_LOGIC_VECTOR(7 downto 0);

    clk_trb:  in std_logic;
    LVDS_OUT: out STD_LOGIC_VECTOR (31 downto 0);
    LVDS_IN:  in STD_LOGIC_VECTOR (31 downto 0)
    );
end entity;


architecture trb_net_bridge_acromag_endpoint_arch of trb_net_bridge_acromag_endpoint is

  component trb_net_med_8bit_slow
    generic(
      TRANSMISSION_CLOCK_DIVIDER: integer range 2 to 62 := 2   --even values only!
      );
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      -- Internal direction port (MII)
      INT_DATAREADY_OUT : out STD_LOGIC;
      INT_DATA_OUT      : out STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
      INT_PACKET_NUM_OUT: out STD_LOGIC_VECTOR (c_NUM_WIDTH-1  downto 0);
      INT_READ_IN       : in  STD_LOGIC;
      INT_DATAREADY_IN  : in  STD_LOGIC;
      INT_DATA_IN       : in  STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
      INT_PACKET_NUM_IN : in  STD_LOGIC_VECTOR (c_NUM_WIDTH-1  downto 0);
      INT_READ_OUT      : out STD_LOGIC;
      --  Media direction port
      MED_DATA_OUT      : out STD_LOGIC_VECTOR (15 downto 0);
      MED_DATA_IN       : in  STD_LOGIC_VECTOR (15 downto 0);
      -- Status and control port
      STAT: out STD_LOGIC_VECTOR (31 downto 0);
                --STAT(5 downto 2): Debug bits in

      CTRL: in  STD_LOGIC_VECTOR (31 downto 0);
      STAT_OP : out std_logic_vector(15 downto 0);
      CTRL_OP : in  std_logic_vector(15 downto 0)
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


  component trb_net_bridge_acromag_apl is
    generic(
      CHANNELS : integer := 2**(c_MUX_WIDTH)
      );
    port(
      CLK     : in std_logic;
      CLK_TRB : in std_logic;
      RESET   : in std_logic;
      CLK_EN  : in std_logic;
      APL_DATA_OUT           : out std_logic_vector (c_DATA_WIDTH*2**(c_MUX_WIDTH)-1 downto 0);
      APL_PACKET_NUM_OUT     : out std_logic_vector (c_NUM_WIDTH*2**(c_MUX_WIDTH)-1 downto 0);
      APL_DATAREADY_OUT      : out std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_READ_IN            : in  std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_SHORT_TRANSFER_OUT : out std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_DTYPE_OUT          : out std_logic_vector (4*2**(c_MUX_WIDTH)-1 downto 0);
      APL_ERROR_PATTERN_OUT  : out std_logic_vector (32*2**(c_MUX_WIDTH)-1 downto 0);
      APL_SEND_OUT           : out std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_TARGET_ADDRESS_OUT : out std_logic_vector (16*2**(c_MUX_WIDTH)-1 downto 0);
      APL_DATA_IN            : in  std_logic_vector (c_DATA_WIDTH*2**(c_MUX_WIDTH)-1 downto 0);
      APL_PACKET_NUM_IN      : in  std_logic_vector (c_NUM_WIDTH*2**(c_MUX_WIDTH)-1 downto 0);
      APL_TYP_IN             : in  std_logic_vector (3*2**(c_MUX_WIDTH)-1 downto 0);
      APL_DATAREADY_IN       : in  std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_READ_OUT           : out std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_RUN_IN             : in  std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_SEQNR_IN           : in  std_logic_vector (8*2**(c_MUX_WIDTH)-1 downto 0);
      CPU_RD                 : in  STD_LOGIC;
      CPU_WR                 : in  STD_LOGIC;
      CPU_DATA_OUT           : out STD_LOGIC_VECTOR (31 downto 0);
      CPU_DATA_IN            : in  STD_LOGIC_VECTOR (31 downto 0);
      CPU_ADDRESS            : in  STD_LOGIC_VECTOR (11 downto 0);
      CPU_INTERRUPT_OUT      : out STD_LOGIC_VECTOR ( 7 downto 0);
      STAT                   : out std_logic_vector (31 downto 0);
      CTRL                   : in  std_logic_vector (31 downto 0);
      API_STAT_IN            : in  std_logic_vector (2**c_MUX_WIDTH*32-1 downto 0);
      API_OBUF_STAT_IN       : in  std_logic_vector (2**c_MUX_WIDTH*32-1 downto 0)
      );
  end component;

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
    REPLY_CAN_SEND_DATA   : integer range 0 to 1 := c_YES
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
    STAT_CTRL_IBUF_BUFFER     : in  std_logic_vector (31 downto 0);
    STAT_INIT_OBUF_DEBUG      : out  std_logic_vector (31 downto 0);
    STAT_REPLY_OBUF_DEBUG      : out  std_logic_vector (31 downto 0)
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
    APL_WRITE_ALL_WORDS:integer range 0 to 1 := c_NO;
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
    STAT_FIFO_TO_INT          : out std_logic_vector(31 downto 0);
    STAT_FIFO_TO_APL          : out std_logic_vector(31 downto 0)
    );
end component;


  signal MED_DATAREADY_IN, MED_DATAREADY_OUT  : std_logic;
  signal MED_DATA_IN, MED_DATA_OUT            : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal MED_PACKET_NUM_IN, MED_PACKET_NUM_OUT: std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal MED_ERROR_IN                         : std_logic_vector(2 downto 0);
  signal MED_READ_IN, MED_READ_OUT            : std_logic;
  signal LVDS_STAT, LVDS_CTRL : std_logic_vector(31 downto 0);
  signal buf_LVDS_OUT : std_logic_vector(15 downto 0);
  signal buf_LVDS_IN : std_logic_vector(15 downto 0);
  signal APL_STAT : std_logic_vector(31 downto 0);

  signal APL_DATA_IN            : std_logic_vector(2**(c_MUX_WIDTH)*c_DATA_WIDTH-1 downto 0);
  signal APL_PACKET_NUM_IN      : std_logic_vector(2**(c_MUX_WIDTH)*c_NUM_WIDTH-1 downto 0);
  signal APL_DATAREADY_IN           : std_logic_vector(2**(c_MUX_WIDTH)-1 downto 0);
  signal APL_READ_OUT      : std_logic_vector(2**(c_MUX_WIDTH)-1 downto 0);
  signal APL_SHORT_TRANSFER_IN  : std_logic_vector(2**(c_MUX_WIDTH)-1 downto 0);
  signal APL_DTYPE_IN           : std_logic_vector(2**(c_MUX_WIDTH)*4-1 downto 0);
  signal APL_SEND_IN            : std_logic_vector(2**(c_MUX_WIDTH)-1 downto 0);
  signal APL_DATA_OUT           : std_logic_vector(2**(c_MUX_WIDTH)*c_DATA_WIDTH-1 downto 0);
  signal APL_PACKET_NUM_OUT     : std_logic_vector(2**(c_MUX_WIDTH)*c_NUM_WIDTH-1 downto 0);
  signal APL_TYP_OUT            : std_logic_vector(2**(c_MUX_WIDTH)*3-1 downto 0);
  signal APL_DATAREADY_OUT      : std_logic_vector(2**(c_MUX_WIDTH)-1 downto 0);
  signal APL_READ_IN            : std_logic_vector(2**(c_MUX_WIDTH)-1 downto 0);
  signal APL_RUN_OUT            : std_logic_vector(2**(c_MUX_WIDTH)-1 downto 0);
  signal APL_SEQNR_OUT          : std_logic_vector(2**(c_MUX_WIDTH)*8-1 downto 0);
  signal APL_TARGET_ADDRESS_OUT : std_logic_vector(2**(c_MUX_WIDTH)*16-1 downto 0);
  signal APL_ERROR_PATTERN_IN   : std_logic_vector(2**(c_MUX_WIDTH)*32-1 downto 0);
  signal APL_TARGET_ADDRESS_IN  : std_logic_vector(2**(c_MUX_WIDTH)*16-1 downto 0);
  signal APL_MY_ADDRESS_IN      : std_logic_vector(15 downto 0);

  signal buf_api_stat_fifo_to_int : std_logic_vector(2**(c_MUX_WIDTH)*32-1 downto 0);
  signal buf_api_stat_fifo_to_apl : std_logic_vector(2**(c_MUX_WIDTH)*32-1 downto 0);

  signal buf_DATA_OUT           : std_logic_vector(31 downto 0);
  signal CLK_EN : std_logic;

  signal m_DATAREADY_OUT : std_logic_vector (2**c_MUX_WIDTH-1 downto 0);
  signal m_DATA_OUT      : std_logic_vector (c_DATA_WIDTH*2**c_MUX_WIDTH-1 downto 0);
  signal m_PACKET_NUM_OUT: std_logic_vector (c_NUM_WIDTH*2**c_MUX_WIDTH-1 downto 0);
  signal m_READ_IN       : std_logic_vector (2**c_MUX_WIDTH-1 downto 0);
  signal m_DATAREADY_IN  : std_logic_vector (c_MUX_WIDTH-1 downto 0);
  signal m_DATA_IN       : std_logic_vector (c_DATA_WIDTH-1 downto 0);
  signal m_PACKET_NUM_IN : std_logic_vector (c_NUM_WIDTH-1 downto 0);
  signal m_READ_OUT      : std_logic_vector (c_MUX_WIDTH-1 downto 0);
  signal MPLEX_CTRL      : std_logic_vector (31 downto 0);

  signal apl_to_buf_INIT_DATAREADY: std_logic_vector(2**(c_MUX_WIDTH-1)-1 downto 0);
  signal apl_to_buf_INIT_DATA     : std_logic_vector (2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto 0);
  signal apl_to_buf_INIT_PACKET_NUM:std_logic_vector (2**(c_MUX_WIDTH-1)*c_NUM_WIDTH-1 downto 0);
  signal apl_to_buf_INIT_READ     : std_logic_vector(2**(c_MUX_WIDTH-1)-1 downto 0);

  signal buf_to_apl_INIT_DATAREADY: std_logic_vector(2**(c_MUX_WIDTH-1)-1 downto 0);
  signal buf_to_apl_INIT_DATA     : std_logic_vector (2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto 0);
  signal buf_to_apl_INIT_PACKET_NUM:std_logic_vector (2**(c_MUX_WIDTH-1)*c_NUM_WIDTH-1 downto 0);
  signal buf_to_apl_INIT_READ     : std_logic_vector(2**(c_MUX_WIDTH-1)-1 downto 0);

  signal apl_to_buf_REPLY_DATAREADY: std_logic_vector(2**(c_MUX_WIDTH-1)-1 downto 0);
  signal apl_to_buf_REPLY_DATA     : std_logic_vector (2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto 0);
  signal apl_to_buf_REPLY_PACKET_NUM:std_logic_vector (2**(c_MUX_WIDTH-1)*c_NUM_WIDTH-1 downto 0);
  signal apl_to_buf_REPLY_READ     : std_logic_vector(2**(c_MUX_WIDTH-1)-1 downto 0);

  signal buf_to_apl_REPLY_DATAREADY: std_logic_vector(2**(c_MUX_WIDTH-1)-1 downto 0);
  signal buf_to_apl_REPLY_DATA     : std_logic_vector (2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto 0);
  signal buf_to_apl_REPLY_PACKET_NUM:std_logic_vector (2**(c_MUX_WIDTH-1)*c_NUM_WIDTH-1 downto 0);
  signal buf_to_apl_REPLY_READ     : std_logic_vector(2**(c_MUX_WIDTH-1)-1 downto 0);


  signal STAT_GEN               : std_logic_vector(32*2**(c_MUX_WIDTH-1)-1 downto 0);
  signal STAT_LOCKED            : std_logic_vector(32*2**(c_MUX_WIDTH-1)-1 downto 0);
  signal STAT_INIT_BUFFER       : std_logic_vector(32*2**(c_MUX_WIDTH-1)-1 downto 0);
  signal STAT_REPLY_BUFFER      : std_logic_vector(32*2**(c_MUX_WIDTH-1)-1 downto 0);
  signal CTRL_GEN               : std_logic_vector(32*2**(c_MUX_WIDTH-1)-1 downto 0);
  signal CTRL_LOCKED            : std_logic_vector(32*2**(c_MUX_WIDTH-1)-1 downto 0);
  signal STAT_CTRL_INIT_BUFFER  : std_logic_vector(32*2**(c_MUX_WIDTH-1)-1 downto 0);
  signal STAT_CTRL_REPLY_BUFFER : std_logic_vector(32*2**(c_MUX_WIDTH-1)-1 downto 0);
  signal RESET_i : std_logic;
  signal RESET_CNT : std_logic_vector(1 downto 0);
  signal counter : std_logic_vector(12 downto 0);
  signal MED_STAT_OP : std_logic_vector(15 downto 0);
  signal MED_CTRL_OP : std_logic_vector(15 downto 0);
  signal API_STAT_IN : std_logic_vector(32*2**c_MUX_WIDTH-1 downto 0);
  signal STAT_INIT_OBUF_DEBUG : std_logic_vector(32*2**c_MUX_WIDTH-1 downto 0);

begin
  CLK_EN <= '1';
  APL_MY_ADDRESS_IN <= x"FF09";

 process(CLK_TRB)
    begin
       if rising_edge(CLK_TRB) then
         if RESET = '1' then
           RESET_i <= '1';
           RESET_CNT <= "00";
         else
           counter <= counter + 1;
           RESET_CNT <= RESET_CNT + 1;
           RESET_i <= '1';
           if RESET_CNT = "11" then
             RESET_i <= '0';
             RESET_CNT <= "11";
           end if;
         end if;
       end if;
    end process;

  LVDS : trb_net_med_8bit_slow
    generic map(
      TRANSMISSION_CLOCK_DIVIDER => 4
      )
    port map(
      CLK    => CLK_TRB,
      RESET  => RESET_i,
      CLK_EN => CLK_EN,
      INT_DATAREADY_OUT => MED_DATAREADY_IN,
      INT_DATA_OUT      => MED_DATA_IN,
      INT_PACKET_NUM_OUT=> MED_PACKET_NUM_IN,
      INT_READ_IN       => MED_READ_OUT,
      INT_DATAREADY_IN  => MED_DATAREADY_OUT,
      INT_DATA_IN       => MED_DATA_OUT,
      INT_PACKET_NUM_IN => MED_PACKET_NUM_OUT,
      INT_READ_OUT      => MED_READ_IN,
      MED_DATA_OUT      => buf_LVDS_OUT,
      MED_DATA_IN       => buf_LVDS_IN,
      STAT              => LVDS_STAT,
      CTRL              => LVDS_CTRL,
      STAT_OP           => MED_STAT_OP,
      CTRL_OP           => MED_CTRL_OP
      );
MED_CTRL_OP(14 downto 0) <= (others => '0');
MED_CTRL_OP(15) <= MED_STAT_OP(15);


  LVDS_OUT(12 downto 8)   <= buf_LVDS_OUT(15 downto 11);
  LVDS_OUT(7 downto 0)    <= buf_LVDS_OUT(7 downto 0);
--LVDS_OUT(12 downto 0) <= counter;

  buf_LVDS_IN(7 downto 0)   <= LVDS_IN(21) & LVDS_IN(19 downto 13);
  buf_LVDS_IN(10 downto 8)  <= "000";
  buf_LVDS_IN(15 downto 11) <= LVDS_IN(26 downto 22);

--  LVDS_OUT(12 downto 0) <= LVDS_STAT(31 downto 19);

API_STAT_IN <= buf_api_stat_fifo_to_int;

  MPLEX: trb_net16_io_multiplexer
    port map (
      CLK      => clk_trb,
      RESET    => RESET_i,
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
      CTRL               => MPLEX_CTRL
      );

  gen_iobufs : for i in 0 to 2**(c_MUX_WIDTH-1)-1 generate
    IOBUF: trb_net16_iobuf
      port map (
        --  Misc
        CLK     => clk_trb ,
        RESET   => RESET_i,
        CLK_EN  => CLK_EN,
        --  Media direction port
        MED_INIT_DATAREADY_OUT  => m_DATAREADY_OUT(i*2),
        MED_INIT_DATA_OUT       => m_DATA_OUT((i*2+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH*2),
        MED_INIT_PACKET_NUM_OUT => m_PACKET_NUM_OUT((i*2+1)*c_NUM_WIDTH-1 downto i*2*c_NUM_WIDTH),
        MED_INIT_READ_IN        => m_READ_IN(i*2),
        MED_REPLY_DATAREADY_OUT => m_DATAREADY_OUT(i*2+1),
        MED_REPLY_DATA_OUT      => m_DATA_OUT((i*2+2)*c_DATA_WIDTH-1 downto (i*2+1)*c_DATA_WIDTH),
        MED_REPLY_PACKET_NUM_OUT=> m_PACKET_NUM_OUT((i*2+2)*c_NUM_WIDTH-1 downto (i*2+1)*c_NUM_WIDTH),
        MED_REPLY_READ_IN       => m_READ_IN(i*2+1),
        MED_DATAREADY_IN   => m_DATAREADY_IN(i),
        MED_DATA_IN        => m_DATA_IN(c_DATA_WIDTH-1 downto 0),
        MED_PACKET_NUM_IN  => m_PACKET_NUM_IN(c_NUM_WIDTH-1 downto 0),
        MED_READ_OUT       => m_READ_OUT(i),
        MED_ERROR_IN       => MED_STAT_OP(2 downto 0),
        -- Internal direction port
        INT_INIT_DATAREADY_OUT => buf_to_apl_INIT_DATAREADY(i),
        INT_INIT_DATA_OUT      => buf_to_apl_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
        INT_INIT_PACKET_NUM_OUT=> buf_to_apl_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
        INT_INIT_READ_IN       => buf_to_apl_INIT_READ(i),
        INT_INIT_DATAREADY_IN  => apl_to_buf_INIT_DATAREADY(i),
        INT_INIT_DATA_IN       => apl_to_buf_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
        INT_INIT_PACKET_NUM_IN => apl_to_buf_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
        INT_INIT_READ_OUT      => apl_to_buf_INIT_READ(i),
        INT_REPLY_DATAREADY_OUT => buf_to_apl_REPLY_DATAREADY(i),
        INT_REPLY_DATA_OUT      => buf_to_apl_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
        INT_REPLY_PACKET_NUM_OUT=> buf_to_apl_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
        INT_REPLY_READ_IN       => buf_to_apl_REPLY_READ(i),
        INT_REPLY_DATAREADY_IN  => apl_to_buf_REPLY_DATAREADY(i),
        INT_REPLY_DATA_IN       => apl_to_buf_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
        INT_REPLY_PACKET_NUM_IN => apl_to_buf_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
        INT_REPLY_READ_OUT      => apl_to_buf_REPLY_READ(i),
        -- Status and control port
        STAT_GEN               => STAT_GEN((i+1)*32-1 downto i*32),
        STAT_IBUF_BUFFER       => STAT_INIT_BUFFER((i+1)*32-1 downto i*32),
        CTRL_GEN               => CTRL_GEN((i+1)*32-1 downto i*32),
        STAT_CTRL_IBUF_BUFFER  => STAT_CTRL_INIT_BUFFER((i+1)*32-1 downto i*32),
        STAT_INIT_OBUF_DEBUG   => STAT_INIT_OBUF_DEBUG((i+1)*32-1 downto i*32)
        );
  end generate;


  gen_pas_apis : for i in 0 to 2**(c_MUX_WIDTH-1)-1 generate
      DAT_PASSIVE_API: trb_net16_api_base
        generic map (
          API_TYPE          => c_API_PASSIVE,
          FIFO_TO_INT_DEPTH => c_FIFO_BRAM,
          FIFO_TO_APL_DEPTH => c_FIFO_BRAM,
          FORCE_REPLY       => cfg_FORCE_REPLY(i),
          SBUF_VERSION      => 0,
          USE_VENDOR_CORES    => c_YES,
          SECURE_MODE_TO_APL  => c_YES,
          SECURE_MODE_TO_INT  => c_NO,
          APL_WRITE_ALL_WORDS => c_YES,
          BROADCAST_BITMASK   => x"FF"
          )
        port map (
          --  Misc
          CLK    => clk_trb,
          RESET  => RESET_i,
          CLK_EN => CLK_EN,
          -- APL Transmitter port
          APL_DATA_IN           => APL_DATA_IN((2*i+1)*c_DATA_WIDTH-1 downto 2*i*c_DATA_WIDTH),
          APL_PACKET_NUM_IN     => APL_PACKET_NUM_IN((2*i+1)*c_NUM_WIDTH-1 downto 2*i*c_NUM_WIDTH),
          APL_DATAREADY_IN          => APL_DATAREADY_IN(2*i),
          APL_READ_OUT     => APL_READ_OUT(2*i),
          APL_SHORT_TRANSFER_IN => APL_SHORT_TRANSFER_IN(2*i),
          APL_DTYPE_IN          => APL_DTYPE_IN((2*i+1)*4-1 downto 2*i*4),
          APL_ERROR_PATTERN_IN  => APL_ERROR_PATTERN_IN((2*i+1)*32-1 downto 2*i*32),
          APL_SEND_IN           => APL_SEND_IN(2*i),
          APL_TARGET_ADDRESS_IN => APL_TARGET_ADDRESS_IN((2*i+1)*16-1 downto 2*i*16),
          -- Receiver port
          APL_DATA_OUT      => APL_DATA_OUT((2*i+1)*c_DATA_WIDTH-1 downto 2*i*c_DATA_WIDTH),
          APL_PACKET_NUM_OUT=> APL_PACKET_NUM_OUT((2*i+1)*c_NUM_WIDTH-1 downto 2*i*c_NUM_WIDTH),
          APL_TYP_OUT       => APL_TYP_OUT((2*i+1)*3-1 downto 2*i*3),
          APL_DATAREADY_OUT => APL_DATAREADY_OUT(2*i),
          APL_READ_IN       => APL_READ_IN(2*i),
          -- APL Control port
          APL_RUN_OUT       => APL_RUN_OUT(2*i),
          APL_MY_ADDRESS_IN => APL_MY_ADDRESS_IN,
          APL_SEQNR_OUT     => APL_SEQNR_OUT((2*i+1)*8-1 downto 2*i*8),
          -- Internal direction port
          INT_MASTER_DATAREADY_OUT => apl_to_buf_REPLY_DATAREADY(i),
          INT_MASTER_DATA_OUT      => apl_to_buf_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
          INT_MASTER_PACKET_NUM_OUT=> apl_to_buf_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
          INT_MASTER_READ_IN       => apl_to_buf_REPLY_READ(i),
          INT_MASTER_DATAREADY_IN  => '0',
          INT_MASTER_DATA_IN       => (others => '0'),
          INT_MASTER_PACKET_NUM_IN => (others => '0'),
          INT_MASTER_READ_OUT      => open,
          INT_SLAVE_DATAREADY_OUT  => open,
          INT_SLAVE_DATA_OUT       => open,
          INT_SLAVE_PACKET_NUM_OUT => open,
          INT_SLAVE_READ_IN        => '1',
          INT_SLAVE_DATAREADY_IN => buf_to_apl_INIT_DATAREADY(i),
          INT_SLAVE_DATA_IN      => buf_to_apl_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
          INT_SLAVE_PACKET_NUM_IN=> buf_to_apl_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
          INT_SLAVE_READ_OUT     => buf_to_apl_INIT_READ(i),
          -- Status and control port
          STAT_FIFO_TO_INT => buf_api_stat_fifo_to_int((2*i+1)*32-1 downto 2*i*32),
          STAT_FIFO_TO_APL => buf_api_stat_fifo_to_apl((2*i+1)*32-1 downto 2*i*32)
          );
  end generate;
  gen_act_apis : for i in 0 to 2**(c_MUX_WIDTH-1)-1 generate
     DAT_ACTIVE_API: trb_net16_api_base
        generic map (
          API_TYPE          => c_API_ACTIVE,
          FIFO_TO_INT_DEPTH => c_FIFO_BRAM,
          FIFO_TO_APL_DEPTH => c_FIFO_BRAM,
          FORCE_REPLY       => cfg_FORCE_REPLY(i),
          SBUF_VERSION      => 0,
          USE_VENDOR_CORES    => c_YES,
          SECURE_MODE_TO_APL  => c_YES,
          SECURE_MODE_TO_INT  => c_NO,
          APL_WRITE_ALL_WORDS => c_YES,
          BROADCAST_BITMASK   => x"FF"
          )
        port map (
          --  Misc
          CLK    => clk_trb,
          RESET  => RESET_i,
          CLK_EN => CLK_EN,
          -- APL Transmitter port
          APL_DATA_IN           => APL_DATA_IN((2*i+2)*c_DATA_WIDTH-1 downto (2*i+1)*c_DATA_WIDTH),
          APL_PACKET_NUM_IN     => APL_PACKET_NUM_IN((2*i+2)*c_NUM_WIDTH-1 downto (2*i+1)*c_NUM_WIDTH),
          APL_DATAREADY_IN          => APL_DATAREADY_IN(2*i+1),
          APL_READ_OUT     => APL_READ_OUT(2*i+1),
          APL_SHORT_TRANSFER_IN => APL_SHORT_TRANSFER_IN(2*i+1),
          APL_DTYPE_IN          => APL_DTYPE_IN((2*i+2)*4-1 downto (2*i+1)*4),
          APL_ERROR_PATTERN_IN  => APL_ERROR_PATTERN_IN((2*i+2)*32-1 downto (2*i+1)*32),
          APL_SEND_IN           => APL_SEND_IN(2*i+1),
          APL_TARGET_ADDRESS_IN => APL_TARGET_ADDRESS_IN((2*i+2)*16-1 downto (2*i+1)*16),
          -- Receiver port
          APL_DATA_OUT      => APL_DATA_OUT((2*i+2)*c_DATA_WIDTH-1 downto (2*i+1)*c_DATA_WIDTH),
          APL_PACKET_NUM_OUT=> APL_PACKET_NUM_OUT((2*i+2)*c_NUM_WIDTH-1 downto (2*i+1)*c_NUM_WIDTH),
          APL_TYP_OUT       => APL_TYP_OUT((2*i+2)*3-1 downto (2*i+1)*3),
          APL_DATAREADY_OUT => APL_DATAREADY_OUT(2*i+1),
          APL_READ_IN       => APL_READ_IN(2*i+1),
          -- APL Control port
          APL_RUN_OUT       => APL_RUN_OUT(2*i+1),
          APL_MY_ADDRESS_IN => APL_MY_ADDRESS_IN,
          APL_SEQNR_OUT     => APL_SEQNR_OUT((2*i+2)*8-1 downto (2*i+1)*8),
          -- Internal direction port
          INT_MASTER_DATAREADY_OUT => apl_to_buf_INIT_DATAREADY(i),
          INT_MASTER_DATA_OUT      => apl_to_buf_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
          INT_MASTER_PACKET_NUM_OUT=> apl_to_buf_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
          INT_MASTER_READ_IN       => apl_to_buf_INIT_READ(i),
          INT_MASTER_DATAREADY_IN  => '0',
          INT_MASTER_DATA_IN       => (others => '0'),
          INT_MASTER_PACKET_NUM_IN => (others => '0'),
          INT_MASTER_READ_OUT      => open,
          INT_SLAVE_DATAREADY_OUT  => open,
          INT_SLAVE_DATA_OUT       => open,
          INT_SLAVE_PACKET_NUM_OUT => open,
          INT_SLAVE_READ_IN        => '1',
          INT_SLAVE_DATAREADY_IN => buf_to_apl_REPLY_DATAREADY(i),
          INT_SLAVE_DATA_IN      => buf_to_apl_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
          INT_SLAVE_PACKET_NUM_IN=> buf_to_apl_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
          INT_SLAVE_READ_OUT     => buf_to_apl_REPLY_READ(i),
          -- Status and control port
          STAT_FIFO_TO_INT => buf_api_stat_fifo_to_int((2*i+2)*32-1 downto (2*i+1)*32),
          STAT_FIFO_TO_APL => buf_api_stat_fifo_to_apl((2*i+2)*32-1 downto (2*i+1)*32)
          );
  end generate;

  APL : trb_net_bridge_acromag_apl
    port map(
      CLK     => CLK,
      CLK_TRB => CLK_TRB,
      RESET   => RESET_i,
      CLK_EN  => CLK_EN,
      APL_DATA_OUT        => APL_DATA_IN,
      APL_PACKET_NUM_OUT  => APL_PACKET_NUM_IN,
      APL_DATAREADY_OUT       => APL_DATAREADY_IN,
      APL_READ_IN    => APL_READ_OUT,
      APL_SHORT_TRANSFER_OUT => APL_SHORT_TRANSFER_IN,
      APL_DTYPE_OUT          => APL_DTYPE_IN,
      APL_ERROR_PATTERN_OUT  => APL_ERROR_PATTERN_IN,
      APL_SEND_OUT        => APL_SEND_IN,
      APL_DATA_IN         => APL_DATA_OUT,
      APL_PACKET_NUM_IN   => APL_PACKET_NUM_OUT,
      APL_TYP_IN          => APL_TYP_OUT,
      APL_DATAREADY_IN    => APL_DATAREADY_OUT,
      APL_READ_OUT        => APL_READ_IN,
      APL_RUN_IN          => APL_RUN_OUT,
      APL_SEQNR_IN        => APL_SEQNR_OUT,
      APL_TARGET_ADDRESS_OUT => APL_TARGET_ADDRESS_IN,
      CPU_RD                 => RD,
      CPU_WR                 => WR,
      CPU_DATA_OUT           => buf_DATA_OUT,
      CPU_DATA_IN            => DATA_IN,
      CPU_ADDRESS            => ADDRESS,
      CPU_INTERRUPT_OUT      => TRB_INTERRUPT_OUT,
      STAT                   => APL_STAT,
      CTRL(12 downto 0)      => LVDS_STAT(31 downto 19),
      CTRL(31 downto 13)     => "1111000000000000000",
      API_STAT_IN            => API_STAT_IN,
      API_OBUF_STAT_IN       => STAT_INIT_OBUF_DEBUG
      );
  DATA_OUT <= buf_DATA_OUT;

end architecture;