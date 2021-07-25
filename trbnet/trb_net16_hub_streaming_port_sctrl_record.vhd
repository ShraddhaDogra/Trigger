LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb_net16_hub_func.all;

-- Be careful when setting the MII_NUMBER and MII_IS_* generics!
-- for MII_NUMBER=5 (4 downlinks, 1 uplink):
-- port 0,1,2,3: downlinks to other FPGA
-- port 4: LVL1/Data channel on uplink to CTS, but internal endpoint on SCTRL
-- port 5: SCTRL channel on uplink to CTS
-- port 6: SCTRL channel from GbE interface



--If the injected slow control should be visible to the network below this hub only:
-- MII_IS_UPLINK        => (0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0);
-- MII_IS_DOWNLINK      => (1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0);
-- MII_IS_UPLINK_ONLY   => (0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0);

--If injected slow control should also be visible upstream (This must be the ONLY slow control interface in this case!)
-- MII_IS_UPLINK        => (0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0);
-- MII_IS_DOWNLINK      => (1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0);
-- MII_IS_UPLINK_ONLY   => (0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0);


entity trb_net16_hub_streaming_port_sctrl_record is
  generic(
  --hub control
    HUB_USED_CHANNELS       : hub_channel_config_t := (c_YES,c_YES,c_NO,c_YES);
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
    MII_NUMBER              : integer range 1 to c_MAX_MII_PER_HUB := 5;
    MII_IS_UPLINK           : hub_mii_config_t := (others => c_YES);
    MII_IS_DOWNLINK         : hub_mii_config_t := (others => c_YES);
    MII_IS_UPLINK_ONLY      : hub_mii_config_t := (others => c_NO)
    );

  port(
    CLK                          : in std_logic;
    RESET                        : in std_logic;
    CLK_EN                       : in std_logic;

  --Media Interface
    MEDIA_MED2INT      : in  med2int_array_t(0 to MII_NUMBER-1);
    MEDIA_INT2MED      : out int2med_array_t(0 to MII_NUMBER-1);

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
    MY_ADDRESS_OUT               : out std_logic_vector(15 downto 0);
    UNIQUE_ID_OUT                : out std_logic_vector (63 downto 0);
    EXTERNAL_SEND_RESET          : in  std_logic := '0';
    
    --REGIO INTERFACE
    BUS_RX                       : out CTRLBUS_RX;
    BUS_TX                       : in  CTRLBUS_TX;
    TIMER                        : out TIMERS;

    --Gbe Sctrl Input
    GSC_INIT_DATAREADY_IN        : in  std_logic;
    GSC_INIT_DATA_IN             : in  std_logic_vector(15 downto 0);
    GSC_INIT_PACKET_NUM_IN       : in  std_logic_vector(2 downto 0);
    GSC_INIT_READ_OUT            : out std_logic;
    GSC_REPLY_DATAREADY_OUT      : out std_logic;
    GSC_REPLY_DATA_OUT           : out std_logic_vector(15 downto 0);
    GSC_REPLY_PACKET_NUM_OUT     : out std_logic_vector(2 downto 0);
    GSC_REPLY_READ_IN            : in  std_logic;
    GSC_BUSY_OUT                 : out std_logic;

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


architecture trb_net16_hub_streaming_arch of trb_net16_hub_streaming_port_sctrl_record is

constant mii : integer := MII_NUMBER-1;

signal hub_init_dataready_out    : std_logic_vector(4 downto 0);
signal hub_reply_dataready_out   : std_logic_vector(4 downto 0);
signal hub_init_dataready_in     : std_logic_vector(4 downto 0);
signal hub_reply_dataready_in    : std_logic_vector(4 downto 0);

signal hub_init_read_out    : std_logic_vector(4 downto 0);
signal hub_reply_read_out   : std_logic_vector(4 downto 0);
signal hub_init_read_in     : std_logic_vector(4 downto 0);
signal hub_reply_read_in    : std_logic_vector(4 downto 0);

signal hub_init_data_out    : std_logic_vector(64 downto 0);
signal hub_reply_data_out   : std_logic_vector(64 downto 0);
signal hub_init_data_in     : std_logic_vector(64 downto 0);
signal hub_reply_data_in    : std_logic_vector(64 downto 0);

signal hub_init_packet_num_out    : std_logic_vector(12 downto 0);
signal hub_reply_packet_num_out   : std_logic_vector(12 downto 0);
signal hub_init_packet_num_in     : std_logic_vector(12 downto 0);
signal hub_reply_packet_num_in    : std_logic_vector(12 downto 0);

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

signal hub_make_network_reset : std_logic := '0';
signal hub_got_network_reset  : std_logic;
signal timer_ticks            : std_logic_vector(1 downto 0);
signal hub_ctrl_debug         : std_logic_vector(31 downto 0);
signal buf_HUB_STAT_GEN       : std_logic_vector(31 downto 0);
signal external_send_reset_long  : std_logic;
signal external_send_reset_timer : std_logic;

signal med_dataready_out    : std_logic_vector (mii-1 downto 0);
signal med_data_out         : std_logic_vector (mii*c_DATA_WIDTH-1 downto 0);
signal med_packet_num_out   : std_logic_vector (mii*c_NUM_WIDTH-1 downto 0);
signal med_read_in          : std_logic_vector (mii-1 downto 0);
signal med_dataready_in     : std_logic_vector (mii-1 downto 0);
signal med_data_in          : std_logic_vector (mii*c_DATA_WIDTH-1 downto 0);
signal med_packet_num_in    : std_logic_vector (mii*c_NUM_WIDTH-1 downto 0);
signal med_read_out         : std_logic_vector (mii-1 downto 0);
signal med_stat_op          : std_logic_vector (mii*16+15 downto 0);
signal med_ctrl_op          : std_logic_vector (mii*16-1 downto 0);
signal rdack, wrack         : std_logic;

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
    med_ctrl_op(14+i*16 downto i*16) <= HUB_MED_CTRL_OP(14+i*16 downto i*16);
    med_ctrl_op(15+i*16) <= hub_make_network_reset or HUB_MED_CTRL_OP(15+i*16);
  end generate;


  hub_make_network_reset <= external_send_reset_long or med_stat_op((MII_NUMBER-1)*16+15);
  
  make_gbe_reset : process begin
    wait until rising_edge(CLK);
    if EXTERNAL_SEND_RESET = '1' or med_stat_op((MII_NUMBER-1)*16+15) = '1' then
      external_send_reset_long <= '1';
      external_send_reset_timer <= '1';
    end if;
    if timer_ticks(1) = '1' then
      external_send_reset_timer <= '0';
      external_send_reset_long  <= external_send_reset_timer;
    end if;
  end process;

---------------------------------------------------------------------
-- Connecting I/O
---------------------------------------------------------------------

  COMMON_CTRL_REGS <= common_ctrl;
  COMMON_STAT_REGS <= common_stat;
  MY_ADDRESS_OUT  <= my_address;


gen_media_record : for i in 0 to mii-1 generate
  med_data_in(i*16+15 downto i*16)    <= MEDIA_MED2INT(i).data;
  med_packet_num_in(i*3+2 downto i*3) <= MEDIA_MED2INT(i).packet_num;
  med_dataready_in(i)                 <= MEDIA_MED2INT(i).dataready;
  med_read_in(i)                      <= MEDIA_MED2INT(i).tx_read;
  med_stat_op(i*16+15 downto i*16)    <= MEDIA_MED2INT(i).stat_op;
  
  MEDIA_INT2MED(i).data         <= med_data_out(i*16+15 downto i*16);    
  MEDIA_INT2MED(i).packet_num   <= med_packet_num_out(i*3+2 downto i*3);
  MEDIA_INT2MED(i).dataready    <= med_dataready_out(i);
  MEDIA_INT2MED(i).ctrl_op      <= med_ctrl_op(i*16+15 downto i*16);
end generate;
  
---------------------------------------------------------------------
-- The Hub
---------------------------------------------------------------------
  THE_HUB : trb_net16_hub_base
    generic map (
    --hub control
      HUB_CTRL_CHANNELNUM        => c_SLOW_CTRL_CHANNEL,
      HUB_CTRL_DEPTH             => c_FIFO_BRAM,
      HUB_USED_CHANNELS          => HUB_USED_CHANNELS,
      USE_CHECKSUM               => (c_NO,c_YES,c_YES,c_YES),
      USE_VENDOR_CORES           => c_YES,
      IBUF_SECURE_MODE           => c_NO,
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
      MII_IBUF_DEPTH             => std_HUB_IBUF_DEPTH,
      MII_IS_UPLINK              => MII_IS_UPLINK,
      MII_IS_DOWNLINK            => MII_IS_DOWNLINK,
      MII_IS_UPLINK_ONLY         => MII_IS_UPLINK_ONLY,
      INIT_ENDPOINT_ID           => INIT_ENDPOINT_ID,
      INT_NUMBER                 => 4,
      INT_CHANNELS               => (0=>0,1=>1,2=>3,3=>3,others=>0)
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
      REGIO_ADDR_OUT            => BUS_RX.addr,
      REGIO_READ_ENABLE_OUT     => BUS_RX.read,
      REGIO_WRITE_ENABLE_OUT    => BUS_RX.write,
      REGIO_DATA_OUT            => BUS_RX.data,
      REGIO_DATA_IN             => BUS_TX.data,
      REGIO_DATAREADY_IN        => rdack,
      REGIO_NO_MORE_DATA_IN     => BUS_TX.nack,
      REGIO_WRITE_ACK_IN        => wrack,
      REGIO_UNKNOWN_ADDR_IN     => BUS_TX.unknown,
      REGIO_TIMEOUT_OUT         => BUS_RX.timeout,

      TIMER_TICKS_OUT(0)        => TIMER.tick_us,
      TIMER_TICKS_OUT(1)        => TIMER.tick_ms,
      ONEWIRE            => ONEWIRE,
      ONEWIRE_MONITOR_IN => '0',
      ONEWIRE_MONITOR_OUT=> open,
      MY_ADDRESS_OUT     => my_address,
      UNIQUE_ID_OUT      => UNIQUE_ID_OUT,
      COMMON_CTRL_REGS   => common_ctrl,
      COMMON_STAT_REGS   => common_stat,
      MPLEX_CTRL         => (others => '0'),
      CTRL_DEBUG         => hub_ctrl_debug,
      STAT_DEBUG         => STAT_DEBUG,
      HUB_STAT_GEN       => buf_HUB_STAT_GEN
      );

  rdack <= BUS_TX.ack or BUS_TX.rack;
  wrack <= BUS_TX.ack or BUS_TX.wack;
      
  hub_ctrl_debug(2 downto 0) <= not io_error_in;
  hub_ctrl_debug(31 downto 3) <= (others => '0');
  HUB_STAT_GEN <= buf_HUB_STAT_GEN;
  timer_ticks <= TIMER.tick_ms & TIMER.tick_us;
  
---------------------------------------------------------------------
-- I/O Buffers
---------------------------------------------------------------------
--iobuf towards CTS, lvl1 channel
  THE_IOBUF_0 : trb_net16_iobuf
    generic map(
      IBUF_DEPTH             => 6,
      USE_ACKNOWLEDGE        => cfg_USE_ACKNOWLEDGE(0),
      USE_CHECKSUM           => cfg_USE_CHECKSUM(0),
      INIT_CAN_SEND_DATA     => c_NO,
      INIT_CAN_RECEIVE_DATA  => c_YES,
      REPLY_CAN_SEND_DATA    => c_YES,
      REPLY_CAN_RECEIVE_DATA => c_NO
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

--iobuf on streaming api, towards CTS, data channel
  THE_IOBUF_1 : trb_net16_iobuf
    generic map(
      IBUF_DEPTH             => 6,
      USE_ACKNOWLEDGE        => cfg_USE_ACKNOWLEDGE(1),
      USE_CHECKSUM           => cfg_USE_CHECKSUM(1),
      INIT_CAN_SEND_DATA     => c_NO,
      INIT_CAN_RECEIVE_DATA  => c_YES,
      REPLY_CAN_SEND_DATA    => c_YES,
      REPLY_CAN_RECEIVE_DATA => c_NO
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

--who cares about an unused channel?      
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

--iobuf towards CTS, slow control channel      
  THE_IOBUF_3 : trb_net16_iobuf
    generic map(
      IBUF_DEPTH             => 6,
      USE_ACKNOWLEDGE        => cfg_USE_ACKNOWLEDGE(3),
      USE_CHECKSUM           => cfg_USE_CHECKSUM(3),
      INIT_CAN_SEND_DATA     => MII_IS_DOWNLINK(MII_NUMBER),
      INIT_CAN_RECEIVE_DATA  => MII_IS_UPLINK(MII_NUMBER),
      REPLY_CAN_SEND_DATA    => MII_IS_UPLINK(MII_NUMBER),
      REPLY_CAN_RECEIVE_DATA => MII_IS_DOWNLINK(MII_NUMBER)
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
        MED_DATAREADY_IN   => MEDIA_MED2INT(mii).dataready,
        MED_DATA_IN        => MEDIA_MED2INT(mii).data,
        MED_PACKET_NUM_IN  => MEDIA_MED2INT(mii).packet_num,
        MED_READ_OUT       => open,
        MED_DATAREADY_OUT  => MEDIA_INT2MED(mii).dataready,
        MED_DATA_OUT       => MEDIA_INT2MED(mii).data,
        MED_PACKET_NUM_OUT => MEDIA_INT2MED(mii).packet_num,
        MED_READ_IN        => MEDIA_MED2INT(mii).tx_read,
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
    io_error_in <= MEDIA_MED2INT(mii).stat_op(2 downto 0);
    med_stat_op(mii*16+15 downto mii*16) <= MEDIA_MED2INT(mii).stat_op;
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


---------------------------------------------------------------------
-- Slowcontrol injection via GbE
---------------------------------------------------------------------
    hub_init_dataready_in(3)              <= GSC_INIT_DATAREADY_IN;   
    hub_init_data_in(63 downto 48)        <= GSC_INIT_DATA_IN;
    hub_init_packet_num_in(11 downto 9)   <= GSC_INIT_PACKET_NUM_IN;  
    GSC_INIT_READ_OUT                     <= hub_init_read_out(3);
    GSC_REPLY_DATAREADY_OUT               <= hub_reply_dataready_out(3);
    GSC_REPLY_DATA_OUT                    <= hub_reply_data_out(63 downto 48);
    GSC_REPLY_PACKET_NUM_OUT              <= hub_reply_packet_num_out(11 downto 9);
    hub_reply_read_in(3)                  <= GSC_REPLY_READ_IN;       
    GSC_BUSY_OUT                          <= buf_HUB_STAT_GEN(3);

    
---------------------------------------------------------------------
-- Debug
---------------------------------------------------------------------
-- STAT_DEBUG(0) <= cts_reply_dataready_in;
-- STAT_DEBUG(1) <= cts_reply_read_out;
-- STAT_DEBUG(2) <= cts_init_dataready_out;
-- STAT_DEBUG(3) <= cts_reply_read_out;
-- STAT_DEBUG(4) <= io_dataready_out(2);
-- STAT_DEBUG(5) <= io_dataready_out(3);
-- STAT_DEBUG(6) <= '0';
-- STAT_DEBUG(7) <= '0';


end architecture;
