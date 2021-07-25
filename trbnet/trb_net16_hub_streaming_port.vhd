LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb_net16_hub_func.all;

--the first media interface is always the uplink & stream output!

entity trb_net16_hub_streaming_port is
  generic(
  --hub control
    HUB_CTRL_CHANNELNUM     : integer range 0 to 3 := c_SLOW_CTRL_CHANNEL;
    HUB_CTRL_DEPTH          : integer range 0 to 6 := c_FIFO_BRAM;
    HUB_USED_CHANNELS       : hub_channel_config_t := (c_YES,c_YES,c_NO,c_YES);
    USE_CHECKSUM            : hub_channel_config_t := (c_NO,c_YES,c_YES,c_YES);
    USE_VENDOR_CORES        : integer range 0 to 1 := c_YES;
    IBUF_SECURE_MODE        : integer range 0 to 1 := c_YES;
    INIT_ADDRESS            : std_logic_vector(15 downto 0) := x"F004";
    INIT_UNIQUE_ID          : std_logic_vector(63 downto 0) := (others => '0');
    COMPILE_TIME            : std_logic_vector(31 downto 0) := x"00000000";
    INCLUDED_FEATURES       : std_logic_vector(63 downto 0) := (others => '0');
    HARDWARE_VERSION        : std_logic_vector(31 downto 0) := x"12345678";
    INIT_ENDPOINT_ID        : std_logic_vector(15 downto 0) := x"0001";
    BROADCAST_BITMASK       : std_logic_vector(7 downto 0)  := x"7E";
    CLOCK_FREQUENCY         : integer range 1 to 200 := 100;
    USE_ONEWIRE             : integer range 0 to 2 := c_YES;
    BROADCAST_SPECIAL_ADDR  : std_logic_vector(7 downto 0) := x"FF";
  --media interfaces
    MII_NUMBER              : integer range 2 to c_MAX_MII_PER_HUB := 12;
    MII_IBUF_DEPTH          : hub_iobuf_config_t := std_HUB_IBUF_DEPTH;
    MII_IS_UPLINK           : hub_mii_config_t := (others => c_YES);
    MII_IS_DOWNLINK         : hub_mii_config_t := (others => c_YES);
    MII_IS_UPLINK_ONLY      : hub_mii_config_t := (others => c_NO)
    );

  port(
    CLK                          : in std_logic;
    RESET                        : in std_logic;
    CLK_EN                       : in std_logic;

  --Media Interface
    MED_DATAREADY_OUT            : out std_logic_vector (MII_NUMBER-1 downto 0);
    MED_DATA_OUT                 : out std_logic_vector (MII_NUMBER*c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT           : out std_logic_vector (MII_NUMBER*c_NUM_WIDTH-1 downto 0);
    MED_READ_IN                  : in  std_logic_vector (MII_NUMBER-1 downto 0);
    MED_DATAREADY_IN             : in  std_logic_vector (MII_NUMBER-1 downto 0);
    MED_DATA_IN                  : in  std_logic_vector (MII_NUMBER*c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN            : in  std_logic_vector (MII_NUMBER*c_NUM_WIDTH-1 downto 0);
    MED_READ_OUT                 : out std_logic_vector (MII_NUMBER-1 downto 0);
    MED_STAT_OP                  : in  std_logic_vector (MII_NUMBER*16-1 downto 0);
    MED_CTRL_OP                  : out std_logic_vector (MII_NUMBER*16-1 downto 0);

    --Event information coming from CTS
    CTS_NUMBER_OUT               : out std_logic_vector (15 downto 0);
    CTS_CODE_OUT                 : out std_logic_vector (7  downto 0);
    CTS_INFORMATION_OUT          : out std_logic_vector (7  downto 0);
    CTS_READOUT_TYPE_OUT         : out std_logic_vector (3  downto 0);
    CTS_START_READOUT_OUT        : out std_logic;

    --Information sent to CTS
    --status data, equipped with DHDR
    CTS_DATA_IN                  : in  std_logic_vector (31 downto 0);
    CTS_DATAREADY_IN             : in  std_logic;
    CTS_READOUT_FINISHED_IN      : in  std_logic;      --no more data, end transfer, send TRM
    CTS_READ_OUT                 : out std_logic;
    CTS_LENGTH_IN                : in  std_logic_vector (15 downto 0);
    CTS_STATUS_BITS_IN           : in  std_logic_vector (31 downto 0);

    -- Data from Frontends
    FEE_DATA_OUT                 : out std_logic_vector (15 downto 0);
    FEE_DATAREADY_OUT            : out std_logic;
    FEE_READ_IN                  : in  std_logic;  --must be high when idle, otherwise you will never get a dataready
    FEE_STATUS_BITS_OUT          : out std_logic_vector (31 downto 0);
    FEE_BUSY_OUT                 : out std_logic;

    MY_ADDRESS_IN                : in  std_logic_vector (15 downto 0);

    COMMON_STAT_REGS             : out std_logic_vector (std_COMSTATREG*32-1 downto 0);  --Status of common STAT regs
    COMMON_CTRL_REGS             : out std_logic_vector (std_COMCTRLREG*32-1 downto 0);  --Status of common STAT regs
    ONEWIRE                      : inout std_logic;
    ONEWIRE_MONITOR_IN           : in  std_logic;
    ONEWIRE_MONITOR_OUT          : out std_logic;
    MY_ADDRESS_OUT               : out std_logic_vector(15 downto 0);
    TIMER_TICKS_OUT              : out std_logic_vector(1  downto 0);
    
    --REGIO INTERFACE
    REGIO_ADDR_OUT               : out std_logic_vector(16-1 downto 0);
    REGIO_READ_ENABLE_OUT        : out std_logic;
    REGIO_WRITE_ENABLE_OUT       : out std_logic;
    REGIO_DATA_OUT               : out std_logic_vector(32-1 downto 0);
    REGIO_DATA_IN                : in  std_logic_vector(32-1 downto 0) := (others => '0');
    REGIO_DATAREADY_IN           : in  std_logic := '0';
    REGIO_NO_MORE_DATA_IN        : in  std_logic := '0';
    REGIO_WRITE_ACK_IN           : in  std_logic := '0';
    REGIO_UNKNOWN_ADDR_IN        : in  std_logic := '0';
    REGIO_TIMEOUT_OUT            : out std_logic;


  --status and control ports
    HUB_STAT_CHANNEL             : out std_logic_vector (2**(c_MUX_WIDTH-1)*16-1 downto 0);
    HUB_STAT_GEN                 : out std_logic_vector (31 downto 0);
    MPLEX_CTRL                   : in  std_logic_vector (MII_NUMBER*32-1 downto 0);
    MPLEX_STAT                   : out std_logic_vector (MII_NUMBER*32-1 downto 0);
    STAT_REGS                    : out std_logic_vector (8*32-1 downto 0);  --Status of custom STAT regs
    STAT_CTRL_REGS               : out std_logic_vector (8*32-1 downto 0);  --Status of custom CTRL regs
    --Debugging registers
    STAT_DEBUG                   : out std_logic_vector (31 downto 0);      --free status regs for debugging
    CTRL_DEBUG                   : in  std_logic_vector (31 downto 0)      --free control regs for debugging
    );
end entity;


architecture trb_net16_hub_streaming_arch of trb_net16_hub_streaming_port is

constant mii : integer := MII_NUMBER-1;

signal hub_init_dataready_out    : std_logic_vector(3 downto 0);
signal hub_reply_dataready_out   : std_logic_vector(3 downto 0);
signal hub_init_dataready_in     : std_logic_vector(3 downto 0);
signal hub_reply_dataready_in    : std_logic_vector(3 downto 0);

signal hub_init_read_out    : std_logic_vector(3 downto 0);
signal hub_reply_read_out   : std_logic_vector(3 downto 0);
signal hub_init_read_in     : std_logic_vector(3 downto 0);
signal hub_reply_read_in    : std_logic_vector(3 downto 0);

signal hub_init_data_out    : std_logic_vector(48 downto 0);
signal hub_reply_data_out   : std_logic_vector(48 downto 0);
signal hub_init_data_in     : std_logic_vector(48 downto 0);
signal hub_reply_data_in    : std_logic_vector(48 downto 0);

signal hub_init_packet_num_out    : std_logic_vector(9 downto 0);
signal hub_reply_packet_num_out   : std_logic_vector(9 downto 0);
signal hub_init_packet_num_in     : std_logic_vector(9 downto 0);
signal hub_reply_packet_num_in    : std_logic_vector(9 downto 0);

signal cts_init_data_out       : std_logic_vector(15 downto 0);
signal cts_init_dataready_out  : std_logic;
signal cts_init_packet_num_out : std_logic_vector(2 downto 0);
signal cts_init_read_in        : std_logic;

signal cts_reply_data_in       : std_logic_vector(15 downto 0);
signal cts_reply_dataready_in  : std_logic;
signal cts_reply_packet_num_in : std_logic_vector(2 downto 0);
signal cts_reply_read_out      : std_logic;

signal common_ctrl             : std_logic_vector(std_COMCTRLREG*32-1 downto 0);
signal common_stat             : std_logic_vector(std_COMSTATREG*32-1 downto 0);
signal my_address              : std_logic_vector(15 downto 0);

signal io_dataready_out  : std_logic_vector(7 downto 0);
signal io_data_out       : std_logic_vector(127 downto 0);
signal io_packet_num_out : std_logic_vector(23 downto 0);
signal io_read_in        : std_logic_vector(7 downto 0);

signal io_dataready_in   : std_logic_vector(3 downto 0);
signal io_read_out       : std_logic_vector(3 downto 0);
signal io_data_in        : std_logic_vector(4*16-1 downto 0);
signal io_packet_num_in  : std_logic_vector(4*3-1 downto 0);
signal io_error_in       : std_logic_vector(2 downto 0);

signal reset_i : std_logic;

signal HUB_MED_CTRL_OP   : std_logic_vector(mii*16-1 downto 0);
signal reset_i_mux_io    : std_logic;

signal hub_make_network_reset : std_logic;
signal hub_got_network_reset  : std_logic;
signal timer_ticks            : std_logic_vector(1 downto 0);
signal hub_ctrl_debug         : std_logic_vector(31 downto 0);

begin

---------------------------------------------------------------------
-- Reset
---------------------------------------------------------------------
--13: reset sequence received
--14: not connected
--15: send reset sequence

  SYNC_RESET_MUX_IO : process(CLK)
    begin
      if rising_edge(CLK) then
        reset_i        <= RESET;
        reset_i_mux_io <= MED_STAT_OP(mii*16+14) or reset_i;
      end if;
    end process;


--generate media resync
  gen_resync : for i in 0 to mii-1 generate
    MED_CTRL_OP(13+i*16 downto i*16) <= (others => '0');
    MED_CTRL_OP(14+i*16) <= HUB_MED_CTRL_OP(14+i*16);
    MED_CTRL_OP(15+i*16) <= hub_make_network_reset ;
  end generate;
    MED_CTRL_OP(13+mii*16 downto mii*16) <= (others => '0');
    MED_CTRL_OP(14+mii*16) <= '0';
    MED_CTRL_OP(15+mii*16) <= hub_make_network_reset;


  hub_make_network_reset <= MED_STAT_OP(15) or MED_STAT_OP(15+mii*16);

---------------------------------------------------------------------
-- Connecting I/O
---------------------------------------------------------------------

  COMMON_CTRL_REGS <= common_ctrl;
  COMMON_STAT_REGS <= common_stat;
  MY_ADDRESS_OUT  <= my_address;


---------------------------------------------------------------------
-- The Hub
---------------------------------------------------------------------


  THE_HUB : trb_net16_hub_base
    generic map (
    --hub control
      HUB_CTRL_CHANNELNUM        => HUB_CTRL_CHANNELNUM,
      HUB_CTRL_DEPTH             => HUB_CTRL_DEPTH,
      HUB_USED_CHANNELS          => HUB_USED_CHANNELS,
      USE_CHECKSUM               => USE_CHECKSUM,
      USE_VENDOR_CORES           => USE_VENDOR_CORES,
      IBUF_SECURE_MODE           => IBUF_SECURE_MODE,
      INIT_ADDRESS               => INIT_ADDRESS,
      INIT_UNIQUE_ID             => INIT_UNIQUE_ID,
      COMPILE_TIME               => COMPILE_TIME,
      INCLUDED_FEATURES          => INCLUDED_FEATURES,
      HARDWARE_VERSION           => HARDWARE_VERSION,
      HUB_CTRL_BROADCAST_BITMASK => BROADCAST_BITMASK,
      CLOCK_FREQUENCY            => CLOCK_FREQUENCY,
      USE_ONEWIRE                => USE_ONEWIRE,
      BROADCAST_SPECIAL_ADDR     => BROADCAST_SPECIAL_ADDR,
      MII_NUMBER                 => mii,
      MII_IBUF_DEPTH             => MII_IBUF_DEPTH,
      MII_IS_UPLINK              => MII_IS_UPLINK,
      MII_IS_DOWNLINK            => MII_IS_DOWNLINK,
      MII_IS_UPLINK_ONLY         => MII_IS_UPLINK_ONLY,
      INIT_ENDPOINT_ID           => INIT_ENDPOINT_ID,
      INT_NUMBER                 => 3,
      INT_CHANNELS               => (0=>0,1=>1,2=>3,others=>0)
      )
    port map (
      CLK    => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,

      --Media interfacces
      MED_DATAREADY_OUT => med_dataready_out(mii-1 downto 0),
      MED_DATA_OUT      => med_data_out(mii*16-1 downto 0),
      MED_PACKET_NUM_OUT=> med_packet_num_out(mii*3-1 downto 0),
      MED_READ_IN       => med_read_in(mii-1 downto 0),
      MED_DATAREADY_IN  => med_dataready_in(mii-1 downto 0),
      MED_DATA_IN       => med_data_in(mii*16-1 downto 0),
      MED_PACKET_NUM_IN => med_packet_num_in(mii*3-1 downto 0),
      MED_READ_OUT      => med_read_out(mii-1 downto 0),
      MED_STAT_OP       => med_stat_op(mii*16-1 downto 0),
      MED_CTRL_OP       => HUB_MED_CTRL_OP(mii*16-1 downto 0),

      INT_INIT_DATAREADY_OUT    => hub_init_dataready_out,
      INT_INIT_DATA_OUT         => hub_init_data_out,
      INT_INIT_PACKET_NUM_OUT   => hub_init_packet_num_out,
      INT_INIT_READ_IN          => hub_init_read_in,
      INT_INIT_DATAREADY_IN     => hub_init_dataready_in,
      INT_INIT_DATA_IN          => hub_init_data_in,
      INT_INIT_PACKET_NUM_IN    => hub_init_packet_num_in,
      INT_INIT_READ_OUT         => hub_init_read_out,
      INT_REPLY_DATAREADY_OUT   => hub_reply_dataready_out,
      INT_REPLY_DATA_OUT        => hub_reply_data_out,
      INT_REPLY_PACKET_NUM_OUT  => hub_reply_packet_num_out,
      INT_REPLY_READ_IN         => hub_reply_read_in,
      INT_REPLY_DATAREADY_IN    => hub_reply_dataready_in,
      INT_REPLY_DATA_IN         => hub_reply_data_in,
      INT_REPLY_PACKET_NUM_IN   => hub_reply_packet_num_in,
      INT_REPLY_READ_OUT        => hub_reply_read_out,
      --REGIO INTERFACE
      REGIO_ADDR_OUT            => REGIO_ADDR_OUT,
      REGIO_READ_ENABLE_OUT     => REGIO_READ_ENABLE_OUT,
      REGIO_WRITE_ENABLE_OUT    => REGIO_WRITE_ENABLE_OUT,
      REGIO_DATA_OUT            => REGIO_DATA_OUT,
      REGIO_DATA_IN             => REGIO_DATA_IN,
      REGIO_DATAREADY_IN        => REGIO_DATAREADY_IN,
      REGIO_NO_MORE_DATA_IN     => REGIO_NO_MORE_DATA_IN,
      REGIO_WRITE_ACK_IN        => REGIO_WRITE_ACK_IN,
      REGIO_UNKNOWN_ADDR_IN     => REGIO_UNKNOWN_ADDR_IN,
      REGIO_TIMEOUT_OUT         => REGIO_TIMEOUT_OUT,
      TIMER_TICKS_OUT           => timer_ticks,
      ONEWIRE            => ONEWIRE,
      ONEWIRE_MONITOR_IN => ONEWIRE_MONITOR_IN,
      ONEWIRE_MONITOR_OUT=> ONEWIRE_MONITOR_OUT,
      MY_ADDRESS_OUT     => my_address,
      COMMON_CTRL_REGS   => common_ctrl,
      COMMON_STAT_REGS   => common_stat,
      MPLEX_CTRL         => (others => '0'),
      CTRL_DEBUG         => hub_ctrl_debug,
      STAT_DEBUG         => STAT_DEBUG
      );

  hub_ctrl_debug(2 downto 0) <= not io_error_in;
  hub_ctrl_debug(31 downto 3) <= (others => '0');
  TIMER_TICKS_OUT <= timer_ticks;
---------------------------------------------------------------------
-- I/O Buffers
---------------------------------------------------------------------

  THE_IOBUF_0 : trb_net16_iobuf
    generic map(
      IBUF_DEPTH             => 6,
      USE_ACKNOWLEDGE        => cfg_USE_ACKNOWLEDGE(0),
      USE_CHECKSUM           => cfg_USE_CHECKSUM(0),
      INIT_CAN_SEND_DATA     => c_YES,
      INIT_CAN_RECEIVE_DATA  => c_YES,
      REPLY_CAN_SEND_DATA    => c_YES,
      REPLY_CAN_RECEIVE_DATA => c_YES
      )
    port map(
      --  Misc
      CLK    => CLK,
      RESET  => reset_i_mux_io,
      CLK_EN => CLK_EN,
      --  Media direction port
      MED_INIT_DATAREADY_OUT    => io_dataready_out(0),
      MED_INIT_DATA_OUT         => io_data_out(15 downto 0),
      MED_INIT_PACKET_NUM_OUT   => io_packet_num_out(2 downto 0),
      MED_INIT_READ_IN          => io_read_in(0),

      MED_REPLY_DATAREADY_OUT   => io_dataready_out(1),
      MED_REPLY_DATA_OUT        => io_data_out(31 downto 16),
      MED_REPLY_PACKET_NUM_OUT  => io_packet_num_out(5 downto 3),
      MED_REPLY_READ_IN         => io_read_in(1),

      MED_DATAREADY_IN          => io_dataready_in(0),
      MED_DATA_IN               => io_data_in(15 downto 0),
      MED_PACKET_NUM_IN         => io_packet_num_in(2 downto 0),
      MED_READ_OUT              => io_read_out(0),
      MED_ERROR_IN              => io_error_in,

      -- Internal direction port

      INT_INIT_DATAREADY_OUT    => hub_init_dataready_in(0),
      INT_INIT_DATA_OUT         => hub_init_data_in(15 downto 0),
      INT_INIT_PACKET_NUM_OUT   => hub_init_packet_num_in(2 downto 0),
      INT_INIT_READ_IN          => hub_init_read_out(0),

      INT_INIT_DATAREADY_IN     => hub_init_dataready_out(0),
      INT_INIT_DATA_IN          => hub_init_data_out(15 downto 0),
      INT_INIT_PACKET_NUM_IN    => hub_init_packet_num_out(2 downto 0),
      INT_INIT_READ_OUT         => hub_init_read_in(0),

      INT_REPLY_DATAREADY_OUT   => hub_reply_dataready_in(0),
      INT_REPLY_DATA_OUT        => hub_reply_data_in(15 downto 0),
      INT_REPLY_PACKET_NUM_OUT  => hub_reply_packet_num_in(2 downto 0),
      INT_REPLY_READ_IN         => hub_reply_read_out(0),

      INT_REPLY_DATAREADY_IN    => hub_reply_dataready_out(0),
      INT_REPLY_DATA_IN         => hub_reply_data_out(15 downto 0),
      INT_REPLY_PACKET_NUM_IN   => hub_reply_packet_num_out(2 downto 0),
      INT_REPLY_READ_OUT        => hub_reply_read_in(0),

      -- Status and control port
      STAT_GEN                  => open,
      STAT_IBUF_BUFFER          => open,
      CTRL_GEN                  => (others => '0'),
      STAT_INIT_OBUF_DEBUG      => open,
      STAT_REPLY_OBUF_DEBUG     => open,
      TIMER_TICKS_IN            => timer_ticks
      );


  THE_IOBUF_1 : trb_net16_iobuf
    generic map(
      IBUF_DEPTH             => 6,
      USE_ACKNOWLEDGE        => cfg_USE_ACKNOWLEDGE(1),
      USE_CHECKSUM           => cfg_USE_CHECKSUM(1),
      INIT_CAN_SEND_DATA     => c_YES,
      INIT_CAN_RECEIVE_DATA  => c_YES,
      REPLY_CAN_SEND_DATA    => c_YES,
      REPLY_CAN_RECEIVE_DATA => c_YES
      )
    port map(
      --  Misc
      CLK    => CLK,
      RESET  => reset_i_mux_io,
      CLK_EN => CLK_EN,
      --  Media direction port
      MED_INIT_DATAREADY_OUT    => io_dataready_out(2),
      MED_INIT_DATA_OUT         => io_data_out(47 downto 32),
      MED_INIT_PACKET_NUM_OUT   => io_packet_num_out(8 downto 6),
      MED_INIT_READ_IN          => io_read_in(2),

      MED_REPLY_DATAREADY_OUT   => io_dataready_out(3),
      MED_REPLY_DATA_OUT        => io_data_out(63 downto 48),
      MED_REPLY_PACKET_NUM_OUT  => io_packet_num_out(11 downto 9),
      MED_REPLY_READ_IN         => io_read_in(3),

      MED_DATAREADY_IN          => io_dataready_in(1),
      MED_DATA_IN               => io_data_in(31 downto 16),
      MED_PACKET_NUM_IN         => io_packet_num_in(5 downto 3),
      MED_READ_OUT              => io_read_out(1),
      MED_ERROR_IN              => io_error_in,

      -- Internal direction port

      INT_INIT_DATAREADY_OUT    => cts_init_dataready_out,
      INT_INIT_DATA_OUT         => cts_init_data_out,
      INT_INIT_PACKET_NUM_OUT   => cts_init_packet_num_out,
      INT_INIT_READ_IN          => cts_init_read_in,

      INT_INIT_DATAREADY_IN     => '0',
      INT_INIT_DATA_IN          => (others => '0'),
      INT_INIT_PACKET_NUM_IN    => (others => '0'),
      INT_INIT_READ_OUT         => open,

      INT_REPLY_DATAREADY_OUT   => open,
      INT_REPLY_DATA_OUT        => open,
      INT_REPLY_PACKET_NUM_OUT  => open,
      INT_REPLY_READ_IN         => '1',

      INT_REPLY_DATAREADY_IN    => cts_reply_dataready_in,
      INT_REPLY_DATA_IN         => cts_reply_data_in,
      INT_REPLY_PACKET_NUM_IN   => cts_reply_packet_num_in,
      INT_REPLY_READ_OUT        => cts_reply_read_out,

      -- Status and control port
      STAT_GEN                  => open,
      STAT_IBUF_BUFFER          => open,
      CTRL_GEN                  => (others => '0'),
      STAT_INIT_OBUF_DEBUG      => open,
      STAT_REPLY_OBUF_DEBUG     => open,
      TIMER_TICKS_IN            => timer_ticks
      );

  THE_IOBUF_2 : trb_net16_term_buf
    port map (
      --  Misc
      CLK     => CLK ,
      RESET   => reset_i_mux_io,
      CLK_EN  => CLK_EN,
      --  Media direction port
      MED_INIT_DATAREADY_OUT  => io_dataready_out(4),
      MED_INIT_DATA_OUT       => io_data_out(79 downto 64),
      MED_INIT_PACKET_NUM_OUT => io_packet_num_out(14 downto 12),
      MED_INIT_READ_IN        => io_read_in(4),
      MED_REPLY_DATAREADY_OUT => io_dataready_out(5),
      MED_REPLY_DATA_OUT      => io_data_out(95 downto 80),
      MED_REPLY_PACKET_NUM_OUT=> io_packet_num_out(17 downto 15),
      MED_REPLY_READ_IN       => io_read_in(5),
      MED_DATAREADY_IN   => io_dataready_in(2),
      MED_DATA_IN        => io_data_in(47 downto 32),
      MED_PACKET_NUM_IN  => io_packet_num_in(8 downto 6),
      MED_READ_OUT       => io_read_out(2)
      );

  THE_IOBUF_3 : trb_net16_iobuf
    generic map(
      IBUF_DEPTH             => 6,
      USE_ACKNOWLEDGE        => cfg_USE_ACKNOWLEDGE(3),
      USE_CHECKSUM           => cfg_USE_CHECKSUM(3),
      INIT_CAN_SEND_DATA     => c_YES,
      INIT_CAN_RECEIVE_DATA  => c_YES,
      REPLY_CAN_SEND_DATA    => c_YES,
      REPLY_CAN_RECEIVE_DATA => c_YES
      )
    port map(
      --  Misc
      CLK    => CLK,
      RESET  => reset_i_mux_io,
      CLK_EN => CLK_EN,
      --  Media direction port
      MED_INIT_DATAREADY_OUT    => io_dataready_out(6),
      MED_INIT_DATA_OUT         => io_data_out(111 downto 96),
      MED_INIT_PACKET_NUM_OUT   => io_packet_num_out(20 downto 18),
      MED_INIT_READ_IN          => io_read_in(6),

      MED_REPLY_DATAREADY_OUT   => io_dataready_out(7),
      MED_REPLY_DATA_OUT        => io_data_out(127 downto 112),
      MED_REPLY_PACKET_NUM_OUT  => io_packet_num_out(23 downto 21),
      MED_REPLY_READ_IN         => io_read_in(7),

      MED_DATAREADY_IN          => io_dataready_in(3),
      MED_DATA_IN               => io_data_in(63 downto 48),
      MED_PACKET_NUM_IN         => io_packet_num_in(11 downto 9),
      MED_READ_OUT              => io_read_out(3),
      MED_ERROR_IN              => io_error_in,

      -- Internal direction port

      INT_INIT_DATAREADY_OUT    => hub_init_dataready_in(2),
      INT_INIT_DATA_OUT         => hub_init_data_in(47 downto 32),
      INT_INIT_PACKET_NUM_OUT   => hub_init_packet_num_in(8 downto 6),
      INT_INIT_READ_IN          => hub_init_read_out(2),

      INT_INIT_DATAREADY_IN     => hub_init_dataready_out(2),
      INT_INIT_DATA_IN          => hub_init_data_out(47 downto 32),
      INT_INIT_PACKET_NUM_IN    => hub_init_packet_num_out(8 downto 6),
      INT_INIT_READ_OUT         => hub_init_read_in(2),

      INT_REPLY_DATAREADY_OUT   => hub_reply_dataready_in(2),
      INT_REPLY_DATA_OUT        => hub_reply_data_in(47 downto 32),
      INT_REPLY_PACKET_NUM_OUT  => hub_reply_packet_num_in(8 downto 6),
      INT_REPLY_READ_IN         => hub_reply_read_out(2),

      INT_REPLY_DATAREADY_IN    => hub_reply_dataready_out(2),
      INT_REPLY_DATA_IN         => hub_reply_data_out(47 downto 32),
      INT_REPLY_PACKET_NUM_IN   => hub_reply_packet_num_out(8 downto 6),
      INT_REPLY_READ_OUT        => hub_reply_read_in(2),

      -- Status and control port
      STAT_GEN                  => open,
      STAT_IBUF_BUFFER          => open,
      CTRL_GEN                  => (others => '0'),
      STAT_INIT_OBUF_DEBUG      => open,
      STAT_REPLY_OBUF_DEBUG     => open,
      TIMER_TICKS_IN            => timer_ticks
      );

---------------------------------------------------------------------
-- Multiplexer
---------------------------------------------------------------------
 MPLEX: trb_net16_io_multiplexer
      port map (
        CLK      => CLK,
        RESET    => reset_i_mux_io,
        CLK_EN   => CLK_EN,
        MED_DATAREADY_IN   => MED_DATAREADY_IN(mii),
        MED_DATA_IN        => MED_DATA_IN(mii*16+15 downto mii*16),
        MED_PACKET_NUM_IN  => MED_PACKET_NUM_IN(mii*3+2 downto mii*3),
        MED_READ_OUT       => MED_READ_OUT(mii),
        MED_DATAREADY_OUT  => MED_DATAREADY_OUT(mii),
        MED_DATA_OUT       => MED_DATA_OUT(mii*16+15 downto mii*16),
        MED_PACKET_NUM_OUT => MED_PACKET_NUM_OUT(mii*3+2 downto mii*3),
        MED_READ_IN        => MED_READ_IN(mii),
        INT_DATAREADY_OUT  => io_dataready_in,
        INT_DATA_OUT       => io_data_in,
        INT_PACKET_NUM_OUT => io_packet_num_in,
        INT_READ_IN        => io_read_out,
        INT_DATAREADY_IN   => io_dataready_out,
        INT_DATA_IN        => io_data_out,
        INT_PACKET_NUM_IN  => io_packet_num_out,
        INT_READ_OUT       => io_read_in,
        CTRL               => (others => '0'),
        STAT               => open
        );
    io_error_in <= MED_STAT_OP(mii*16+2 downto mii*16+0);

---------------------------------------------------------------------
-- IPU Channel
---------------------------------------------------------------------

  hub_reply_data_in(31 downto 16)     <= (others => '0');
  hub_reply_packet_num_in(5 downto 3) <= (others => '0');
  hub_reply_dataready_in(1)           <= '0';
  hub_init_read_in(1)                 <= '1';

  THE_STREAMING : trb_net16_api_ipu_streaming
    port map(
      CLK    => CLK,
      RESET  => reset_i,
      CLK_EN => CLK_EN,

      -- Internal direction port

      FEE_INIT_DATA_OUT         => hub_init_data_in(31 downto 16),
      FEE_INIT_DATAREADY_OUT    => hub_init_dataready_in(1),
      FEE_INIT_PACKET_NUM_OUT   => hub_init_packet_num_in(5 downto 3),
      FEE_INIT_READ_IN          => hub_init_read_out(1),

      FEE_REPLY_DATA_IN         => hub_reply_data_out(31 downto 16),
      FEE_REPLY_DATAREADY_IN    => hub_reply_dataready_out(1),
      FEE_REPLY_PACKET_NUM_IN   => hub_reply_packet_num_out(5 downto 3),
      FEE_REPLY_READ_OUT        => hub_reply_read_in(1),

      CTS_INIT_DATA_IN          => cts_init_data_out,
      CTS_INIT_DATAREADY_IN     => cts_init_dataready_out,
      CTS_INIT_PACKET_NUM_IN    => cts_init_packet_num_out,
      CTS_INIT_READ_OUT         => cts_init_read_in,

      CTS_REPLY_DATA_OUT        => cts_reply_data_in,
      CTS_REPLY_DATAREADY_OUT   => cts_reply_dataready_in,
      CTS_REPLY_PACKET_NUM_OUT  => cts_reply_packet_num_in,
      CTS_REPLY_READ_IN         => cts_reply_read_out,

      --Event information coming from CTS
      CTS_NUMBER_OUT            => CTS_NUMBER_OUT,
      CTS_CODE_OUT              => CTS_CODE_OUT,
      CTS_INFORMATION_OUT       => CTS_INFORMATION_OUT,
      CTS_READOUT_TYPE_OUT      => CTS_READOUT_TYPE_OUT,
      CTS_START_READOUT_OUT     => CTS_START_READOUT_OUT,

      --Information sent to CTS
      --status data, equipped with DHDR
      CTS_DATA_IN               => CTS_DATA_IN,
      CTS_DATAREADY_IN          => CTS_DATAREADY_IN,
      CTS_READOUT_FINISHED_IN   => CTS_READOUT_FINISHED_IN,
      CTS_READ_OUT              => CTS_READ_OUT,
      CTS_LENGTH_IN             => CTS_LENGTH_IN,
      CTS_STATUS_BITS_IN        => CTS_STATUS_BITS_IN,

      -- Data from Frontends
      FEE_DATA_OUT              => FEE_DATA_OUT,
      FEE_DATAREADY_OUT         => FEE_DATAREADY_OUT,
      FEE_READ_IN               => FEE_READ_IN,
      FEE_STATUS_BITS_OUT       => FEE_STATUS_BITS_OUT,
      FEE_BUSY_OUT              => FEE_BUSY_OUT,

      MY_ADDRESS_IN              => MY_ADDRESS_IN,
      CTRL_SEQNR_RESET           => common_ctrl(10)

      );

-- STAT_DEBUG(0) <= cts_reply_dataready_in;
-- STAT_DEBUG(1) <= cts_reply_read_out;
-- STAT_DEBUG(2) <= cts_init_dataready_out;
-- STAT_DEBUG(3) <= cts_reply_read_out;
-- STAT_DEBUG(4) <= io_dataready_out(2);
-- STAT_DEBUG(5) <= io_dataready_out(3);
-- STAT_DEBUG(6) <= '0';
-- STAT_DEBUG(7) <= '0';


end architecture;