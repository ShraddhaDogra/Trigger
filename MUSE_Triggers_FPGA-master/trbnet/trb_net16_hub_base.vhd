LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;
library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb_net16_hub_func.all;

--take care of USE_INPUT_SBUF for multiplexer!

entity trb_net16_hub_base is
  generic (
  --hub control
    HUB_CTRL_CHANNELNUM     : integer range 0 to 3 := c_SLOW_CTRL_CHANNEL;
    HUB_CTRL_DEPTH          : integer range 0 to 6 := c_FIFO_BRAM;
    HUB_CTRL_ADDRESS_MASK   : std_logic_vector(15 downto 0) := x"FFFF";
    HUB_CTRL_BROADCAST_BITMASK : std_logic_vector(7 downto 0) := x"FE";
    HUB_USED_CHANNELS       : hub_channel_config_t := (c_YES,c_YES,c_NO,c_YES);
    USE_CHECKSUM            : hub_channel_config_t := (c_NO,c_YES,c_YES,c_YES);
    USE_VENDOR_CORES        : integer range 0 to 1 := c_YES;
    IBUF_SECURE_MODE        : integer range 0 to 1 := c_YES; --not used any more
    INIT_ADDRESS            : std_logic_vector(15 downto 0) := x"F004";
    INIT_UNIQUE_ID          : std_logic_vector(63 downto 0) := (others => '0');
    INIT_CTRL_REGS          : std_logic_vector(2**(4)*32-1 downto 0) :=
                                         x"00000000_00000000_00000000_00000000" &
                                         x"00000000_00000000_00000000_00000000" &
                                         x"00000000_00000000_000050FF_00000000" &
                                         x"FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF";
    COMPILE_TIME            : std_logic_vector(31 downto 0) := x"00000000";
    INCLUDED_FEATURES       : std_logic_vector(63 downto 0) := (others => '0');
    INIT_ENDPOINT_ID        : std_logic_vector(15 downto 0) := x"0001";
    USE_VAR_ENDPOINT_ID     : integer range c_NO to c_YES := c_NO;
    HARDWARE_VERSION        : std_logic_vector(31 downto 0) := x"12345678";
    CLOCK_FREQUENCY         : integer range 1 to 200 := 100;
    USE_ONEWIRE             : integer range 0 to 2 := c_YES;
    BROADCAST_SPECIAL_ADDR  : std_logic_vector(7 downto 0) := x"FF";
  --media interfaces
    MII_NUMBER              : integer range 0 to c_MAX_MII_PER_HUB := 4;
    MII_IBUF_DEPTH          : hub_iobuf_config_t := std_HUB_IBUF_DEPTH;
    MII_IS_UPLINK           : hub_mii_config_t := (others => c_YES);
    MII_IS_DOWNLINK         : hub_mii_config_t := (others => c_YES);
    MII_IS_UPLINK_ONLY      : hub_mii_config_t := (others => c_NO);
  -- settings for external api connections
    INT_NUMBER              : integer range 0 to c_MAX_API_PER_HUB := 0;
    INT_CHANNELS            : hub_api_config_t := (others => 3);
    INT_IBUF_DEPTH          : hub_api_config_t := (others => 6);
    RESET_IOBUF_AT_TIMEOUT  : integer range 0 to 1 := c_NO
    );
  port (
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    --Media interfacces
    MED_DATAREADY_OUT : out std_logic_vector (MII_NUMBER-1 downto 0);
    MED_DATA_OUT      : out std_logic_vector (MII_NUMBER*c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT: out std_logic_vector (MII_NUMBER*c_NUM_WIDTH-1 downto 0);
    MED_READ_IN       : in  std_logic_vector (MII_NUMBER-1 downto 0);
    MED_DATAREADY_IN  : in  std_logic_vector (MII_NUMBER-1 downto 0);
    MED_DATA_IN       : in  std_logic_vector (MII_NUMBER*c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN : in  std_logic_vector (MII_NUMBER*c_NUM_WIDTH-1 downto 0);
    MED_READ_OUT      : out std_logic_vector (MII_NUMBER-1 downto 0);
    MED_STAT_OP       : in  std_logic_vector (MII_NUMBER*16-1 downto 0);
    MED_CTRL_OP       : out std_logic_vector (MII_NUMBER*16-1 downto 0);
    --INT: interfaces to connect APIs
    INT_INIT_DATAREADY_OUT    : out std_logic_vector (INT_NUMBER downto 0);
    INT_INIT_DATA_OUT         : out std_logic_vector (INT_NUMBER*c_DATA_WIDTH downto 0);
    INT_INIT_PACKET_NUM_OUT   : out std_logic_vector (INT_NUMBER*c_NUM_WIDTH  downto 0);
    INT_INIT_READ_IN          : in  std_logic_vector (INT_NUMBER downto 0) := (others => '0');
    INT_INIT_DATAREADY_IN     : in  std_logic_vector (INT_NUMBER downto 0) := (others => '0');
    INT_INIT_DATA_IN          : in  std_logic_vector (INT_NUMBER*c_DATA_WIDTH downto 0) := (others => '0');
    INT_INIT_PACKET_NUM_IN    : in  std_logic_vector (INT_NUMBER*c_NUM_WIDTH  downto 0) := (others => '0');
    INT_INIT_READ_OUT         : out std_logic_vector (INT_NUMBER downto 0);
    INT_REPLY_DATAREADY_OUT   : out std_logic_vector (INT_NUMBER downto 0);
    INT_REPLY_DATA_OUT        : out std_logic_vector (INT_NUMBER*c_DATA_WIDTH downto 0);
    INT_REPLY_PACKET_NUM_OUT  : out std_logic_vector (INT_NUMBER*c_NUM_WIDTH  downto 0);
    INT_REPLY_READ_IN         : in  std_logic_vector (INT_NUMBER downto 0) := (others => '0');
    INT_REPLY_DATAREADY_IN    : in  std_logic_vector (INT_NUMBER downto 0) := (others => '0');
    INT_REPLY_DATA_IN         : in  std_logic_vector (INT_NUMBER*c_DATA_WIDTH downto 0) := (others => '0');
    INT_REPLY_PACKET_NUM_IN   : in  std_logic_vector (INT_NUMBER*c_NUM_WIDTH downto 0) := (others => '0');
    INT_REPLY_READ_OUT        : out std_logic_vector (INT_NUMBER downto 0);
    ONEWIRE                      : inout std_logic;
    ONEWIRE_MONITOR_IN           : in  std_logic := '0';
    ONEWIRE_MONITOR_OUT          : out std_logic;
    COMMON_STAT_REGS             : in  std_logic_vector (std_COMSTATREG*32-1 downto 0) := (others => '0');  --Status of common STAT regs
    COMMON_CTRL_REGS             : out std_logic_vector (std_COMCTRLREG*32-1 downto 0);  --Status of common STAT regs
    COMMON_STAT_REG_STROBE       : out std_logic_vector (std_COMSTATREG-1 downto 0);
    COMMON_CTRL_REG_STROBE       : out std_logic_vector (std_COMCTRLREG-1 downto 0);
    MY_ADDRESS_OUT               : out std_logic_vector (15 downto 0);
    TEMPERATURE_OUT              : out std_logic_vector (11 downto 0);
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
    REGIO_VAR_ENDPOINT_ID        : in  std_logic_vector(15 downto 0) := (others => '0');
    TIMER_TICKS_OUT              : out std_logic_vector(1 downto 0);
    HUB_LED_OUT                  : out std_logic_vector (MII_NUMBER-1 downto 0);
    UNIQUE_ID_OUT                : out std_logic_vector (63 downto 0);
    --Fixed status and control ports
    HUB_STAT_CHANNEL             : out std_logic_vector (2**(c_MUX_WIDTH-1)*16-1 downto 0);
    HUB_STAT_GEN                 : out std_logic_vector (31 downto 0);
    MPLEX_CTRL                   : in  std_logic_vector (MII_NUMBER*32-1 downto 0);
    MPLEX_STAT                   : out std_logic_vector (MII_NUMBER*32-1 downto 0);
    STAT_REGS                    : out std_logic_vector (16*32-1 downto 0);  --Status of custom STAT regs
    STAT_CTRL_REGS               : out std_logic_vector (8*32-1 downto 0);  --Status of custom CTRL regs
    IOBUF_STAT_INIT_OBUF_DEBUG   : out std_logic_vector (MII_NUMBER*32*2**(c_MUX_WIDTH-1)-1 downto 0);
    IOBUF_STAT_REPLY_OBUF_DEBUG  : out std_logic_vector (MII_NUMBER*32*2**(c_MUX_WIDTH-1)-1 downto 0);

    --Debugging registers
    STAT_DEBUG                   : out std_logic_vector (31 downto 0);      --free status regs for debugging
    CTRL_DEBUG                   : in  std_logic_vector (31 downto 0)      --free control regs for debugging
     -- bits 0-2 are NOT (inverted) error of streaming port
    );
end entity;

architecture trb_net16_hub_base_arch of trb_net16_hub_base is



  constant total_point_num : integer := MII_NUMBER*2**(c_MUX_WIDTH-1) + INT_NUMBER + 1;
  signal m_DATAREADY_OUT : std_logic_vector (MII_NUMBER*2**(c_MUX_WIDTH)-1 downto 0) := (others => '0');
  signal m_DATA_OUT      : std_logic_vector (MII_NUMBER*2**(c_MUX_WIDTH)*c_DATA_WIDTH-1 downto 0) := (others => '0');
  signal m_PACKET_NUM_OUT: std_logic_vector (MII_NUMBER*2**(c_MUX_WIDTH)*c_NUM_WIDTH-1 downto 0) := (others => '0');
  signal m_READ_IN       : std_logic_vector (MII_NUMBER*2**(c_MUX_WIDTH)-1 downto 0) := (others => '0');
  signal m_DATAREADY_IN  : std_logic_vector (MII_NUMBER*2**(c_MUX_WIDTH-1)-1 downto 0) := (others => '0');
  signal m_DATA_IN       : std_logic_vector (MII_NUMBER*2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto 0) := (others => '0');
  signal m_PACKET_NUM_IN : std_logic_vector (MII_NUMBER*2**(c_MUX_WIDTH-1)*c_NUM_WIDTH-1 downto 0) := (others => '0');
  signal m_READ_OUT      : std_logic_vector (MII_NUMBER*2**(c_MUX_WIDTH-1)-1 downto 0) := (others => '0');
  signal m_ERROR_IN      : std_logic_vector (MII_NUMBER*3-1 downto 0) := (others => '0');

  signal hub_to_buf_INIT_DATAREADY: std_logic_vector (total_point_num-1 downto 0) := (others => '0');
  signal hub_to_buf_INIT_DATA     : std_logic_vector (total_point_num*c_DATA_WIDTH-1 downto 0) := (others => '0');
  signal hub_to_buf_INIT_PACKET_NUM:std_logic_vector (total_point_num*c_NUM_WIDTH-1 downto 0) := (others => '0');
  signal hub_to_buf_INIT_READ     : std_logic_vector (total_point_num-1 downto 0) := (others => '0');

  signal buf_to_hub_INIT_DATAREADY : std_logic_vector (total_point_num-1 downto 0) := (others => '0');
  signal buf_to_hub_INIT_DATA      : std_logic_vector (total_point_num*c_DATA_WIDTH-1 downto 0) := (others => '0');
  signal buf_to_hub_INIT_PACKET_NUM: std_logic_vector (total_point_num*c_NUM_WIDTH-1 downto 0) := (others => '0');
  signal buf_to_hub_INIT_READ      : std_logic_vector (total_point_num-1 downto 0) := (others => '0');

  signal hub_to_buf_REPLY_DATAREADY   : std_logic_vector (total_point_num-1 downto 0) := (others => '0');
  signal hub_to_buf_REPLY_DATA        : std_logic_vector (total_point_num*c_DATA_WIDTH-1 downto 0) := (others => '0');
  signal hub_to_buf_REPLY_PACKET_NUM  : std_logic_vector (total_point_num*c_NUM_WIDTH-1 downto 0) := (others => '0');
  signal hub_to_buf_REPLY_READ        : std_logic_vector (total_point_num-1 downto 0) := (others => '0');

  signal buf_to_hub_REPLY_DATAREADY   : std_logic_vector (total_point_num-1 downto 0) := (others => '0');
  signal buf_to_hub_REPLY_DATA        : std_logic_vector (total_point_num*c_DATA_WIDTH-1 downto 0) := (others => '0');
  signal buf_to_hub_REPLY_PACKET_NUM  : std_logic_vector (total_point_num*c_NUM_WIDTH-1 downto 0) := (others => '0');
  signal buf_to_hub_REPLY_READ        : std_logic_vector (total_point_num-1 downto 0) := (others => '0');

  signal HUB_INIT_DATAREADY_OUT    : std_logic_vector (total_point_num-1 downto 0);
  signal HUB_INIT_DATA_OUT         : std_logic_vector (total_point_num*c_DATA_WIDTH-1 downto 0);
  signal HUB_INIT_PACKET_NUM_OUT   : std_logic_vector (total_point_num*c_NUM_WIDTH-1 downto 0);
  signal HUB_INIT_READ_IN          : std_logic_vector (total_point_num-1 downto 0);
  signal HUB_INIT_DATAREADY_IN     : std_logic_vector (total_point_num-1 downto 0);
  signal HUB_INIT_DATA_IN          : std_logic_vector (total_point_num*c_DATA_WIDTH-1 downto 0);
  signal HUB_INIT_PACKET_NUM_IN    : std_logic_vector (total_point_num*c_NUM_WIDTH-1 downto 0);
  signal HUB_INIT_READ_OUT         : std_logic_vector (total_point_num-1 downto 0);
  signal HUB_REPLY_DATAREADY_OUT   : std_logic_vector (total_point_num-1 downto 0);
  signal HUB_REPLY_DATA_OUT        : std_logic_vector (total_point_num*c_DATA_WIDTH-1 downto 0);
  signal HUB_REPLY_PACKET_NUM_OUT  : std_logic_vector (total_point_num*c_NUM_WIDTH-1 downto 0);
  signal HUB_REPLY_READ_IN         : std_logic_vector (total_point_num-1 downto 0);
  signal HUB_REPLY_DATAREADY_IN    : std_logic_vector (total_point_num-1 downto 0);
  signal HUB_REPLY_DATA_IN         : std_logic_vector (total_point_num*c_DATA_WIDTH-1 downto 0);
  signal HUB_REPLY_PACKET_NUM_IN   : std_logic_vector (total_point_num*c_NUM_WIDTH-1 downto 0);
  signal HUB_REPLY_READ_OUT        : std_logic_vector (total_point_num-1 downto 0);

  signal HUB_STAT_ERRORBITS        : std_logic_vector (2**(c_MUX_WIDTH-1)*32-1 downto 0);
  signal buf_HUB_STAT_CHANNEL      : std_logic_vector (2**(c_MUX_WIDTH-1)*16-1 downto 0);
  signal buf_STAT_POINTS_locked    : std_logic_vector (2**(c_MUX_WIDTH-1)*32-1 downto 0);
  signal buf_STAT_DEBUG            : std_logic_vector (31 downto 0);
  signal buf_CTRL_DEBUG            : std_logic_vector (31 downto 0);
  signal buf_MED_DATAREADY_OUT     : std_logic_vector (MII_NUMBER-1 downto 0);
  signal buf_MED_PACKET_NUM_OUT    : std_logic_vector(MII_NUMBER*c_NUM_WIDTH-1 downto 0);
  signal buf_MED_DATA_OUT          : std_logic_vector (MII_NUMBER*c_DATA_WIDTH-1 downto 0);

  signal HUB_locked                : std_logic_vector (2**(c_MUX_WIDTH-1)-1 downto 0);


  signal HC_DATA_IN       :  std_logic_vector (c_DATA_WIDTH-1 downto 0) := (others => '0');
  signal HC_PACKET_NUM_IN :  std_logic_vector (c_NUM_WIDTH-1 downto 0) := (others => '0');
  signal HC_DATAREADY_IN  :  std_logic;
  signal HC_READ_OUT      :  std_logic;
  signal HC_SHORT_TRANSFER_IN :  std_logic;
  signal HC_DTYPE_IN      :  std_logic_vector (3 downto 0);
  signal HC_ERROR_PATTERN_IN :   std_logic_vector (31 downto 0);
  signal HC_SEND_IN       :  std_logic;
  signal HC_DATA_OUT      :  std_logic_vector (c_DATA_WIDTH-1 downto 0);
  signal HC_PACKET_NUM_OUT:  std_logic_vector (c_NUM_WIDTH-1 downto 0);
  signal HC_TYP_OUT       :  std_logic_vector (2 downto 0);
  signal HC_DATAREADY_OUT :  std_logic;
  signal HC_READ_IN       :  std_logic;
  signal HC_RUN_OUT       :  std_logic;
  signal HC_SEQNR_OUT     :  std_logic_vector (7 downto 0);
  signal HC_STAT_REGS     :  std_logic_vector (64*32-1 downto 0) := (others => '0');
  signal HUB_SCTRL_ERROR  :  std_logic_vector (MII_NUMBER-1 downto 0);
  signal STAT_REG_STROBE  :  std_logic_vector (2**6-1 downto 0);
  signal reg_STROBES      :  std_logic_vector (2**6-1 downto 0);
  signal CTRL_REG_STROBE  :  std_logic_vector (2**4-1 downto 0);
  signal HC_CTRL_REGS     :  std_logic_vector (2**4*32-1 downto 0);
  signal HC_COMMON_STAT_REGS  : std_logic_vector(std_COMSTATREG*32-1 downto 0);
  signal HC_COMMON_CTRL_REGS  : std_logic_vector(std_COMCTRLREG*32-1 downto 0);
  signal HC_COMMON_STAT_REG_STROBE  : std_logic_vector(std_COMSTATREG-1 downto 0);
  signal HC_COMMON_CTRL_REG_STROBE  : std_logic_vector(std_COMCTRLREG-1 downto 0);
  signal buf_HC_STAT_REGS     :  std_logic_vector (64*32-1 downto 0);
  signal HC_STAT_ack_waiting : std_logic_vector(127 downto 0) := (others => '0');
  signal HUB_CTRL_LOCAL_NETWORK_RESET : std_logic_vector(MII_NUMBER-1 downto 0);
  signal ctrl_local_net_reset_changed : std_logic_vector(3 downto 0);

  signal HUB_MED_CONNECTED            : std_logic_vector  (31 downto 0);
  signal HUB_CTRL_final_activepoints  : std_logic_vector (2**(c_MUX_WIDTH-1)*32-1 downto 0);
  signal HUB_CTRL_activepoints        : std_logic_vector (2**(c_MUX_WIDTH-1)*32-1 downto 0);
  signal HUB_CTRL_media_interfaces_off: std_logic_vector (31 downto 0);
  signal HUB_CTRL_TIMEOUT_TIME        : std_logic_vector (31 downto 0);
  signal HUB_ADDRESS                  : std_logic_vector (15 downto 0);
  signal HUBLOGIC_IPU_STAT_DEBUG      : std_logic_vector (31 downto 0);
  signal HUB_ERROR_BITS               : std_logic_vector (16*32-1 downto 0);
  signal buf_HUB_ALL_ERROR_BITS       : std_logic_vector ((16*2**(c_MUX_WIDTH-1))*32-1 downto 0);

  signal IOBUF_STAT_GEN               : std_logic_vector ((MII_NUMBER*2**(c_MUX_WIDTH-1))*32-1 downto 0);
  signal IOBUF_IBUF_BUFFER            : std_logic_vector ((MII_NUMBER*2**(c_MUX_WIDTH-1))*32-1 downto 0);
  signal IOBUF_CTRL_GEN               : std_logic_vector ((MII_NUMBER*2**(c_MUX_WIDTH-1))*32-1 downto 0);
  signal IOBUF_STAT_DATA_COUNTER      : std_logic_vector ((MII_NUMBER*2**(c_MUX_WIDTH-1))*32-1 downto 0);

  signal resync : std_logic_vector(MII_NUMBER-1 downto 0);
  signal reset_i : std_logic;
  signal reset_i_mux_io : std_logic_vector((MII_NUMBER*2**(c_MUX_WIDTH-1))-1 downto 0);


  signal combined_resync : std_logic;
  signal IDRAM_DATA_IN, IDRAM_DATA_OUT : std_logic_vector(15 downto 0);
  signal IDRAM_WR_IN : std_logic;
  signal IDRAM_ADDR_IN : std_logic_vector(2 downto 0);
  signal TEMP_OUT : std_logic_vector(11 downto 0);
  signal ONEWIRE_DATA            :  std_logic_vector(15 downto 0);
  signal ONEWIRE_ADDR            :  std_logic_vector(2 downto 0);
  signal ONEWIRE_WRITE           :  std_logic;

  signal global_time : std_logic_vector(31 downto 0);
  signal local_time  : std_logic_vector(7 downto 0);
  signal timer_ms_tick : std_logic;
  signal timer_us_tick : std_logic;
  signal stat_ipu_fsm : std_logic_vector(31 downto 0);

  signal DAT_ADDR_OUT            : std_logic_vector(16-1 downto 0) := (others => '0');
  signal DAT_READ_ENABLE_OUT     : std_logic;
  signal DAT_WRITE_ENABLE_OUT    : std_logic;
  signal DAT_DATA_OUT            : std_logic_vector(32-1 downto 0) := (others => '0');
  signal DAT_DATA_IN             : std_logic_vector(32-1 downto 0) := (others => '0');
  signal DAT_DATAREADY_IN        : std_logic := '0';
  signal DAT_NO_MORE_DATA_IN     : std_logic := '0';
  signal DAT_WRITE_ACK_IN        : std_logic := '0';
  signal DAT_UNKNOWN_ADDR_IN     : std_logic := '0';
  signal DAT_TIMEOUT_OUT         : std_logic;

  signal STAT_TIMEOUT            : std_logic_vector(4*32-1 downto 0);
  signal last_STAT_TIMEOUT       : std_logic_vector(4*32-1 downto 0);

  signal local_network_reset     : std_logic_vector(MII_NUMBER-1 downto 0);
  signal local_reset_med         : std_logic_vector(MII_NUMBER-1 downto 0);
  signal network_reset_counter   : std_logic_vector(11 downto 0) := (others => '0');

  signal stream_port_connected   : std_logic;

  signal stat_packets_addr       : std_logic_vector(4 downto 0);
  signal stat_packets_read       : std_logic;
  signal stat_packets_write      : std_logic;
  signal stat_packets_data       : std_logic_vector(31 downto 0);
  signal stat_packets_ready      : std_logic;
  signal stat_packets_unknown    : std_logic;
  signal stat_packets_ack        : std_logic;
  signal stat_packets_all        : std_logic_vector(32*32-1 downto 0);

  signal stat_errorbits_addr     : std_logic_vector(3 downto 0);
  signal stat_errorbits_read     : std_logic;
  signal stat_errorbits_write    : std_logic;
  signal stat_errorbits_data     : std_logic_vector(31 downto 0);
  signal stat_errorbits_ready    : std_logic;
  signal stat_errorbits_unknown  : std_logic;

  signal stat_busycntincl_addr     : std_logic_vector(3 downto 0);
  signal stat_busycntincl_read     : std_logic;
  signal stat_busycntincl_write    : std_logic;
  signal stat_busycntincl_data     : std_logic_vector(31 downto 0);
  signal stat_busycntincl_ready    : std_logic;
  signal stat_busycntincl_ack      : std_logic;
  signal stat_busycntincl_unknown  : std_logic;

  signal stat_busycntexcl_addr     : std_logic_vector(3 downto 0);
  signal stat_busycntexcl_read     : std_logic;
  signal stat_busycntexcl_write    : std_logic;
  signal stat_busycntexcl_data     : std_logic_vector(31 downto 0);
  signal stat_busycntexcl_ready    : std_logic;
  signal stat_busycntexcl_ack      : std_logic;
  signal stat_busycntexcl_unknown  : std_logic;

  signal stat_globaltime_read      : std_logic;
  signal stat_globaltime_write     : std_logic;
  signal last_stat_globaltime_read : std_logic;
  signal last_stat_globaltime_write: std_logic;

  signal iobuf_ctrl_stat           : std_logic_vector(63 downto 0);
  signal iobuf_reset_ipu_counter   : std_logic;
  signal iobuf_reset_sctrl_counter : std_logic;

  type tv_t is array (2**(c_MUX_WIDTH-1)-1 downto 0) of std_logic_vector(15 downto 0);
  signal current_timeout_value     : tv_t := (others => (others => '0'));
  signal hub_level                 : std_logic_vector(7 downto 0);

  type cnt_t is array (MII_NUMBER+2 downto 0) of unsigned(31 downto 0);
  signal busy_counter_excl         : cnt_t := (others => (others => '0'));
  signal busy_counter_incl         : cnt_t := (others => (others => '0'));
  signal reg_STAT_POINTS_locked    : std_logic_vector(MII_NUMBER+2 downto 0);
  signal reg_excl_enable           : std_logic_vector(MII_NUMBER+2 downto 0);
  signal delay1_media_reset_me     : std_logic_vector(MII_NUMBER-1 downto 0);
  signal delay2_media_reset_me     : std_logic_vector(MII_NUMBER-1 downto 0);

  signal mii_error                 : std_logic_vector(31 downto 0);

  signal iobuf_stat_init_obuf_debug_i   : std_logic_vector (MII_NUMBER*32*2**(c_MUX_WIDTH-1)-1 downto 0);
  signal iobuf_stat_reply_obuf_debug_i  : std_logic_vector (MII_NUMBER*32*2**(c_MUX_WIDTH-1)-1 downto 0);

  signal led_counter               : unsigned(9 downto 0) := (others => '0');
  signal hub_led_i                 : std_logic_vector(MII_NUMBER-1 downto 0);
  signal hub_show_port             : std_logic_vector(MII_NUMBER-1 downto 0);

  signal lsm_addr                  : std_logic_vector(3 downto 0);
  signal lsm_read                  : std_logic;
  signal lsm_write                 : std_logic;
  signal lsm_data                  : std_logic_vector(31 downto 0);
  signal next_lsm_data             : std_logic_vector(31 downto 0);
  signal last_lsm_read             : std_logic;
  signal next_last_lsm_read        : std_logic;

  signal hub_ctrl_disabled_ports   : std_logic_vector(31 downto 0);
  signal buf_HUB_MISMATCH_PATTERN  : std_logic_vector(31 downto 0);

  type counter8b_t is array (0 to 15) of unsigned(7 downto 0);
  signal received_retransmit_requests : counter8b_t := (others => (others => '0'));
  signal sent_retransmit_requests     : counter8b_t := (others => (others => '0'));

  signal dummy : std_logic_vector(270 downto 0);
  signal tmp_buf_to_hub_REPLY_DATA_ctrl : std_logic_vector(15 downto 0);

  attribute syn_preserve : boolean;
  attribute syn_keep : boolean;
  attribute syn_preserve of m_DATA_IN : signal is true;
  attribute syn_keep of m_DATA_IN : signal is true;
  attribute syn_preserve of m_DATAREADY_IN : signal is true;
  attribute syn_keep of m_DATAREADY_IN : signal is true;
  attribute syn_preserve of m_PACKET_NUM_IN : signal is true;
  attribute syn_keep of m_PACKET_NUM_IN : signal is true;

  attribute syn_preserve of m_PACKET_NUM_OUT : signal is true;
  attribute syn_keep of m_PACKET_NUM_OUT : signal is true;
  attribute syn_preserve of m_DATA_OUT : signal is true;
  attribute syn_keep of m_DATA_OUT : signal is true;
  attribute syn_preserve of m_DATAREADY_OUT : signal is true;
  attribute syn_keep of m_DATAREADY_OUT : signal is true;

  attribute syn_preserve of m_READ_OUT : signal is true;
  attribute syn_keep of m_READ_OUT : signal is true;
  attribute syn_preserve of m_READ_IN : signal is true;
  attribute syn_keep of m_READ_IN : signal is true;

  attribute syn_keep of reset_i : signal is true;
  
  attribute syn_keep of reset_i_mux_io : signal is true;
  attribute syn_preserve of reset_i_mux_io : signal is true;

  attribute syn_hier : string;
  attribute syn_hier of trb_net16_hub_base_arch : architecture is "firm";

begin


---------------------------------------------------------------------
--Generate various reset signals
---------------------------------------------------------------------
  proc_SYNC_RESET : process(CLK)
    begin
      if rising_edge(CLK) then
        reset_i <= RESET;
        last_STAT_TIMEOUT <= STAT_TIMEOUT;
      end if;
    end process;

-- STAT_TIMEOUT

  gen_iobuf_noreset : if RESET_IOBUF_AT_TIMEOUT = c_NO generate
    gen_internal_reset : for i in 0 to MII_NUMBER-1 generate
      gen_int_reset_2 : for j in 0 to 2**(c_MUX_WIDTH-1)-1 generate
        SYNC_RESET_MUX_IO : process(CLK)
          begin
            if rising_edge(CLK) then
              reset_i_mux_io(i+j*MII_NUMBER) <= MED_STAT_OP(i*16+14) or RESET;
            end if;
          end process;
      end generate;
    end generate;
  end generate;
  
  gen_iobuf_reset : if RESET_IOBUF_AT_TIMEOUT = c_YES generate
    gen_int_reset_3 : for i in 0 to MII_NUMBER-1 generate
      gen_int_reset_4 : for j in 0 to 2**(c_MUX_WIDTH-1)-1 generate
        SYNC_RESET_MUX_IO : process begin 
          wait until rising_edge(CLK);
          if j /= 2 then
            if HUB_locked(j) = '1' then
              reset_i_mux_io(i+j*MII_NUMBER) <= RESET or (STAT_TIMEOUT(j*32+i) and not last_STAT_TIMEOUT(j*32+i)) 
                                                or reset_i_mux_io(i+j*MII_NUMBER) or delay2_media_reset_me(i);
            else
              reset_i_mux_io(i+j*MII_NUMBER) <= MED_STAT_OP(i*16+14) or RESET;
            end if;
          else
            reset_i_mux_io(i+j*MII_NUMBER) <= (MED_STAT_OP(i*16+14) and (not or_all(HUB_locked) or reset_i_mux_io(i+j*MII_NUMBER)))
                                              or RESET;
          end if;
        end process;
      end generate;
    end generate;
  end generate;


--generate media resync
  gen_resync : for i in 0 to MII_NUMBER-1 generate
    resync(i) <= MED_STAT_OP(i*16+15) when MII_IS_UPLINK(i) = c_YES else '0';
    proc_SYNC_CTRL_OP : process(CLK)
      begin
        if rising_edge(CLK) then
          MED_CTRL_OP(7+i*16 downto i*16) <= (others => '0');
          MED_CTRL_OP(8+i*16)  <= HC_COMMON_CTRL_REGS(64+27);
          MED_CTRL_OP(12+i*16 downto 9+i*16) <= (others => '0');
          MED_CTRL_OP(13+i*16) <= local_reset_med(i);
          MED_CTRL_OP(14+i*16) <= HUB_CTRL_media_interfaces_off(i);
          if MII_IS_UPLINK(i) = 0 then
            MED_CTRL_OP(15+i*16) <= combined_resync or local_network_reset(i);
          else
            MED_CTRL_OP(15+i*16) <= combined_resync;
          end if;
        end if;
      end process;
  end generate;
  combined_resync <= or_all(resync);

  gen_local_network_reset : process(CLK)
    begin
      if rising_edge(CLK) then
        if reset_i = '1' then
          local_network_reset   <= (others => '0');
          local_reset_med       <= (others => '0');
          network_reset_counter <= (others => '0');
        elsif ctrl_local_net_reset_changed(3) = '1' then
          local_network_reset   <= HUB_CTRL_LOCAL_NETWORK_RESET;
          local_reset_med       <= (others => '0');
          network_reset_counter <= x"001";
        
        elsif network_reset_counter(10) = '1' then
          network_reset_counter <= (others => '0');
          local_network_reset   <= (others => '0');
          local_reset_med       <= (others => '0');
        elsif and_all(network_reset_counter(9 downto 0)) = '1' then
          local_reset_med       <= local_network_reset;
          local_network_reset   <= (others => '0');
        end if;
        if network_reset_counter(9 downto 0) /= 0 then
          network_reset_counter <= network_reset_counter + 1;
        end if;
      end if;
    end process;
    
  gen_delayed_link_off : for i in 0 to MII_NUMBER-1 generate
		process begin 
      wait until rising_edge(CLK);
      if timer_us_tick = '1' then
        delay1_media_reset_me(i) <= MED_STAT_OP(i*16+14);
        delay2_media_reset_me(i) <= delay1_media_reset_me(i);
      end if;
    end process;
	end generate;    

  gen_local_net_reset_ctrl_reg : process begin
    wait until rising_edge(CLK);
    ctrl_local_net_reset_changed(0) <= (CTRL_REG_STROBE(6) or ctrl_local_net_reset_changed(0)) 
                                           and not ctrl_local_net_reset_changed(1);
    if timer_us_tick = '1' then
      ctrl_local_net_reset_changed(3 downto 1) <= ctrl_local_net_reset_changed(2 downto 0);
    end if;
  end process;

---------------------------------------------------------------------
--Multiplexer
---------------------------------------------------------------------

  gen_muxes: for i in 0 to MII_NUMBER-1 generate
    constant t : integer := 0;
  begin
    MPLEX: trb_net16_io_multiplexer
      generic map(
        USE_INPUT_SBUF     => (MII_IS_DOWNLINK(i),MII_IS_UPLINK(i),
                               MII_IS_DOWNLINK(i),MII_IS_UPLINK(i),
                               c_NO, c_NO,
                               MII_IS_DOWNLINK(i),MII_IS_UPLINK(i))
        )
      port map (
        CLK      => CLK,
        RESET    => reset_i_mux_io(i+2*MII_NUMBER), --use reset from ch.2 here (not influenced by timeouts)
        CLK_EN   => CLK_EN,
        MED_DATAREADY_IN   => MED_DATAREADY_IN(i),
        MED_DATA_IN        => MED_DATA_IN((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
        MED_PACKET_NUM_IN  => MED_PACKET_NUM_IN((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
        MED_READ_OUT       => MED_READ_OUT(i),
        MED_DATAREADY_OUT  => buf_MED_DATAREADY_OUT(i),
        MED_DATA_OUT       => buf_MED_DATA_OUT((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
        MED_PACKET_NUM_OUT => buf_MED_PACKET_NUM_OUT((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
        MED_READ_IN        => MED_READ_IN(i),
        INT_DATAREADY_OUT  => m_DATAREADY_IN((i+1)*2**(c_MUX_WIDTH-1)-1 downto i*2**(c_MUX_WIDTH-1)),
        INT_DATA_OUT       => m_DATA_IN((i+1)*2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH*2**(c_MUX_WIDTH-1)),
        INT_PACKET_NUM_OUT => m_PACKET_NUM_IN((i+1)*2**(c_MUX_WIDTH-1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH*2**(c_MUX_WIDTH-1)),
        INT_READ_IN        => m_READ_OUT((i+1)*2**(c_MUX_WIDTH-1)-1 downto i*2**(c_MUX_WIDTH-1)),
        INT_DATAREADY_IN   => m_DATAREADY_OUT((i+1)*2**c_MUX_WIDTH-1 downto i*2**c_MUX_WIDTH),
        INT_DATA_IN        => m_DATA_OUT((i+1)*c_DATA_WIDTH*2**c_MUX_WIDTH-1 downto i*c_DATA_WIDTH*2**c_MUX_WIDTH),
        INT_PACKET_NUM_IN  => m_PACKET_NUM_OUT((i+1)*c_NUM_WIDTH*2**c_MUX_WIDTH-1 downto i*c_NUM_WIDTH*2**c_MUX_WIDTH),
        INT_READ_OUT       => m_READ_IN((i+1)*2**c_MUX_WIDTH-1 downto i*2**c_MUX_WIDTH),
        CTRL               => MPLEX_CTRL((i+1)*32-1 downto i*32),
        STAT               => MPLEX_STAT((i+1)*32-1 downto i*32)
        );
    m_ERROR_IN((i+1)*3-1 downto i*3) <=MED_STAT_OP(i*16+2 downto i*16);
  end generate;
MED_DATAREADY_OUT <= buf_MED_DATAREADY_OUT;
MED_PACKET_NUM_OUT <= buf_MED_PACKET_NUM_OUT;
MED_DATA_OUT       <= buf_MED_DATA_OUT;


---------------------------------------------------------------------
--IOBufs
---------------------------------------------------------------------
  gen_bufs : for j in 0 to MII_NUMBER-1 generate
    gen_iobufs: for k in 0 to 2**(c_MUX_WIDTH-1)-1 generate
      constant i : integer := j*2**(c_MUX_WIDTH-1)+k;
    begin
      gen_iobuf: if HUB_USED_CHANNELS(k) = 1 generate
        IOBUF: trb_net16_iobuf
          generic map (
            IBUF_DEPTH =>  calc_depth(i,MII_IBUF_DEPTH, INT_IBUF_DEPTH, MII_NUMBER, INT_NUMBER, c_MUX_WIDTH, HUB_CTRL_DEPTH),
            USE_CHECKSUM          => USE_CHECKSUM(k),
            SBUF_VERSION          => 0,
            SBUF_VERSION_OBUF     => 6,
            OBUF_DATA_COUNT_WIDTH => std_DATA_COUNT_WIDTH,
            USE_ACKNOWLEDGE       => cfg_USE_ACKNOWLEDGE(k),
            USE_VENDOR_CORES      => USE_VENDOR_CORES,
            INIT_CAN_RECEIVE_DATA => MII_IS_UPLINK(j),
            REPLY_CAN_RECEIVE_DATA=> MII_IS_DOWNLINK(j),
            INIT_CAN_SEND_DATA    => MII_IS_DOWNLINK(j),
            REPLY_CAN_SEND_DATA   => MII_IS_UPLINK(j)
            )
          port map (
            --  Misc
            CLK     => CLK ,
            RESET   => reset_i_mux_io(j+k*MII_NUMBER),
            CLK_EN  => CLK_EN,
            --  Media direction port
            MED_INIT_DATAREADY_OUT  => m_DATAREADY_OUT(i*2),
            MED_INIT_DATA_OUT       => m_DATA_OUT((i*2+1)*c_DATA_WIDTH-1 downto i*2*c_DATA_WIDTH),
            MED_INIT_PACKET_NUM_OUT => m_PACKET_NUM_OUT((i*2+1)*c_NUM_WIDTH-1 downto i*2*c_NUM_WIDTH),
            MED_INIT_READ_IN        => m_READ_IN(i*2),
            MED_REPLY_DATAREADY_OUT => m_DATAREADY_OUT(i*2+1),
            MED_REPLY_DATA_OUT      => m_DATA_OUT((i*2+2)*c_DATA_WIDTH-1 downto (i*2+1)*c_DATA_WIDTH),
            MED_REPLY_PACKET_NUM_OUT=> m_PACKET_NUM_OUT((i*2+2)*c_NUM_WIDTH-1 downto (i*2+1)*c_NUM_WIDTH),
            MED_REPLY_READ_IN       => m_READ_IN(i*2+1),
            MED_DATAREADY_IN  => m_DATAREADY_IN(i),
            MED_DATA_IN       => m_DATA_IN((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            MED_PACKET_NUM_IN => m_PACKET_NUM_IN((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            MED_READ_OUT      => m_READ_OUT(i),
            MED_ERROR_IN      => m_ERROR_IN((j+1)*3-1 downto j*3),

            -- Internal direction port
            INT_INIT_DATAREADY_OUT => buf_to_hub_INIT_DATAREADY(i),
            INT_INIT_DATA_OUT      => buf_to_hub_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_INIT_PACKET_NUM_OUT=> buf_to_hub_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_INIT_READ_IN       => buf_to_hub_INIT_READ(i),
            INT_INIT_DATAREADY_IN  => hub_to_buf_INIT_DATAREADY(i),
            INT_INIT_DATA_IN       => hub_to_buf_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_INIT_PACKET_NUM_IN => hub_to_buf_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_INIT_READ_OUT      => hub_to_buf_INIT_READ(i),
            INT_REPLY_DATAREADY_OUT => buf_to_hub_REPLY_DATAREADY(i),
            INT_REPLY_DATA_OUT      => buf_to_hub_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_REPLY_PACKET_NUM_OUT=> buf_to_hub_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_REPLY_READ_IN       => buf_to_hub_REPLY_READ(i),
            INT_REPLY_DATAREADY_IN  => hub_to_buf_REPLY_DATAREADY(i),
            INT_REPLY_DATA_IN       => hub_to_buf_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_REPLY_PACKET_NUM_IN => hub_to_buf_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_REPLY_READ_OUT      => hub_to_buf_REPLY_READ(i),
            -- Status and control port
            STAT_GEN               => IOBUF_STAT_GEN((i+1)*32-1 downto i*32),
            STAT_IBUF_BUFFER       => IOBUF_IBUF_BUFFER((i+1)*32-1 downto i*32),
            STAT_DATA_COUNTER      => IOBUF_STAT_DATA_COUNTER((i+1)*32-1 downto i*32),
            CTRL_GEN               => IOBUF_CTRL_GEN((i+1)*32-1 downto i*32),
            CTRL_OBUF_settings(15 downto  0) => (others => '0'), -- current_timeout_value(k),--HUB_CTRL_TIMEOUT_TIME(k*4+19 downto k*4+16),
            CTRL_OBUF_settings(31 downto 16) => (others => '0'), -- current_timeout_value(k),--HUB_CTRL_TIMEOUT_TIME(k*4+19 downto k*4+16),
            STAT_INIT_OBUF_DEBUG   => iobuf_stat_init_obuf_debug_i((i+1)*32-1 downto i*32),
            STAT_REPLY_OBUF_DEBUG  => iobuf_stat_reply_obuf_debug_i((i+1)*32-1 downto i*32),
            TIMER_TICKS_IN(0)      => timer_us_tick,
            TIMER_TICKS_IN(1)      => timer_ms_tick,
            CTRL_STAT              => iobuf_ctrl_stat(k*16+15 downto k*16)
            );
      end generate;
      gen_trmbuf: if HUB_USED_CHANNELS(k) = 0 generate
--         hub_to_buf_INIT_DATAREADY(i) <= '0';
--         hub_to_buf_INIT_DATA(i*16+15 downto i*16) <= (others => '0');
--         hub_to_buf_INIT_PACKET_NUM(i*3+2 downto i*3) <= (others => '0');
        hub_to_buf_init_read(i)      <= '0';
        buf_to_hub_init_dataready(i) <= '0';
        buf_to_hub_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');
        buf_to_hub_init_packet_num((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= (others => '0');
        hub_to_buf_reply_read(i)      <= '0';
        buf_to_hub_reply_dataready(i) <= '0';
        buf_to_hub_reply_data((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');
        buf_to_hub_reply_packet_num((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= (others => '0');
        iobuf_stat_gen((i+1)*32-1 downto i*32) <= (others => '0');
        IOBUF_IBUF_BUFFER((i+1)*32-1 downto i*32) <= (others => '0');
        IOBUF_CTRL_GEN((i+1)*32-1 downto i*32) <= (others => '0');
        iobuf_stat_init_obuf_debug_i((i+1)*32-1 downto i*32) <= (others => '0');
        iobuf_stat_reply_obuf_debug_i((i+1)*32-1 downto i*32) <= (others => '0');
        IOBUF_STAT_DATA_COUNTER((i+1)*32-1 downto i*32)  <= (others => '0');

        m_DATAREADY_OUT(i*2) <= '0';
        m_DATA_OUT((i*2+1)*c_DATA_WIDTH-1 downto i*2*c_DATA_WIDTH) <= (others => '0');
        m_PACKET_NUM_OUT((i*2+1)*c_NUM_WIDTH-1 downto i*2*c_NUM_WIDTH) <= (others => '0');
        m_DATAREADY_OUT(i*2+1) <= '0';
        m_DATA_OUT((i*2+2)*c_DATA_WIDTH-1 downto (i*2+1)*c_DATA_WIDTH)  <= (others => '0');
        m_PACKET_NUM_OUT((i*2+2)*c_NUM_WIDTH-1 downto (i*2+1)*c_NUM_WIDTH) <= (others => '0');
        m_READ_OUT(i) <= '1';

--         IOBUF : trb_net16_term_buf
--           port map (
--             --  Misc
--             CLK     => CLK ,
--             RESET   => reset_i_mux_io(j),
--             CLK_EN  => CLK_EN,
--             --  Media direction port
--             MED_INIT_DATAREADY_OUT  => m_DATAREADY_OUT(i*2),
--             MED_INIT_DATA_OUT       => m_DATA_OUT((i*2+1)*c_DATA_WIDTH-1 downto i*2*c_DATA_WIDTH),
--             MED_INIT_PACKET_NUM_OUT => m_PACKET_NUM_OUT((i*2+1)*c_NUM_WIDTH-1 downto i*2*c_NUM_WIDTH),
--             MED_INIT_READ_IN        => m_READ_IN(i*2),
--             MED_REPLY_DATAREADY_OUT => m_DATAREADY_OUT(i*2+1),
--             MED_REPLY_DATA_OUT      => m_DATA_OUT((i*2+2)*c_DATA_WIDTH-1 downto (i*2+1)*c_DATA_WIDTH),
--             MED_REPLY_PACKET_NUM_OUT=> m_PACKET_NUM_OUT((i*2+2)*c_NUM_WIDTH-1 downto (i*2+1)*c_NUM_WIDTH),
--             MED_REPLY_READ_IN       => m_READ_IN(i*2+1),
--             MED_DATAREADY_IN   => m_DATAREADY_IN(i),
--             MED_DATA_IN        => m_DATA_IN((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
--             MED_PACKET_NUM_IN  => m_PACKET_NUM_IN((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
--             MED_READ_OUT       => m_READ_OUT(i)
--             );
      end generate;
    end generate;
  end generate;


---------------------------------------------------------------------
--API for control interface
---------------------------------------------------------------------
  gen_ctrl_api : if 1 = 1 generate    --just a dummy now
    constant i         : integer := 2**(c_MUX_WIDTH-1)*MII_NUMBER;
  begin
    CTRL_API : trb_net16_api_base
      generic map(
        API_TYPE               => 0,
        FIFO_TO_INT_DEPTH      => HUB_CTRL_DEPTH,
        FIFO_TO_APL_DEPTH      => HUB_CTRL_DEPTH,
        ADDRESS_MASK           => HUB_CTRL_ADDRESS_MASK,
        BROADCAST_BITMASK      => HUB_CTRL_BROADCAST_BITMASK,
        BROADCAST_SPECIAL_ADDR => BROADCAST_SPECIAL_ADDR
        )
      port map(
        --  Misc
        CLK    => CLK,
        RESET  => reset_i,
        CLK_EN => CLK_EN,
        -- APL Transmitter port
        APL_DATA_IN           => HC_DATA_IN(c_DATA_WIDTH-1 downto 0),
        APL_PACKET_NUM_IN     => HC_PACKET_NUM_IN(c_NUM_WIDTH-1 downto 0),
        APL_DATAREADY_IN      => HC_DATAREADY_IN,
        APL_READ_OUT          => HC_READ_OUT,
        APL_SHORT_TRANSFER_IN => HC_SHORT_TRANSFER_IN,
        APL_DTYPE_IN          => HC_DTYPE_IN(3 downto 0),
        APL_ERROR_PATTERN_IN  => HC_ERROR_PATTERN_IN(31 downto 0),
        APL_SEND_IN           => HC_SEND_IN,
        APL_TARGET_ADDRESS_IN => (others => '0'),
        -- Receiver port
        APL_DATA_OUT          => HC_DATA_OUT(c_DATA_WIDTH-1 downto 0),
        APL_PACKET_NUM_OUT    => HC_PACKET_NUM_OUT(c_NUM_WIDTH-1 downto 0),
        APL_TYP_OUT           => HC_TYP_OUT(2 downto 0),
        APL_DATAREADY_OUT     => HC_DATAREADY_OUT,
        APL_READ_IN           => HC_READ_IN,
        -- APL Control port
        APL_RUN_OUT           => HC_RUN_OUT,
        APL_MY_ADDRESS_IN     => HUB_ADDRESS,
        APL_SEQNR_OUT         => HC_SEQNR_OUT(7 downto 0),
        APL_LENGTH_IN         => (others => '1'),
        -- Internal direction port
        INT_MASTER_DATAREADY_OUT  => buf_to_hub_REPLY_DATAREADY(i),
        INT_MASTER_DATA_OUT       => tmp_buf_to_hub_REPLY_DATA_ctrl,
        INT_MASTER_PACKET_NUM_OUT => buf_to_hub_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
        INT_MASTER_READ_IN        => buf_to_hub_REPLY_READ(i),
        INT_MASTER_DATAREADY_IN   => hub_to_buf_REPLY_DATAREADY(i),
        INT_MASTER_DATA_IN        => hub_to_buf_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
        INT_MASTER_PACKET_NUM_IN  => hub_to_buf_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
        INT_MASTER_READ_OUT       => hub_to_buf_REPLY_READ(i),
        INT_SLAVE_DATAREADY_OUT   => buf_to_hub_INIT_DATAREADY(i),
        INT_SLAVE_DATA_OUT        => buf_to_hub_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
        INT_SLAVE_PACKET_NUM_OUT  => buf_to_hub_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
        INT_SLAVE_READ_IN         => buf_to_hub_INIT_READ(i),
        INT_SLAVE_DATAREADY_IN    => hub_to_buf_INIT_DATAREADY(i),
        INT_SLAVE_DATA_IN         => hub_to_buf_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
        INT_SLAVE_PACKET_NUM_IN   => hub_to_buf_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
        INT_SLAVE_READ_OUT        => hub_to_buf_INIT_READ(i),
        CTRL_SEQNR_RESET          => HC_COMMON_CTRL_REGS(10),
        -- Status and control port
        STAT_FIFO_TO_INT          => open,
        STAT_FIFO_TO_APL          => open
        );

--Workaround to get channel number right in local hub in pcie bridge
  PROC_CORRECT_CHANNEL : process(tmp_buf_to_hub_REPLY_DATA_ctrl, buf_to_hub_REPLY_PACKET_NUM)
    begin
      if buf_to_hub_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) = c_H0 then
        buf_to_hub_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <=  tmp_buf_to_hub_REPLY_DATA_ctrl or x"0038";
      else
        buf_to_hub_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <=  tmp_buf_to_hub_REPLY_DATA_ctrl;
      end if;
    end process;

end generate;


---------------------------------------------------------------------
--Connection for additional internal interfaces
---------------------------------------------------------------------
  gen_int : if INT_NUMBER /= 0 generate
    gen_int1 : for i in 0 to INT_NUMBER-1 generate
      constant j : integer := i + 2**(c_MUX_WIDTH-1)*MII_NUMBER+1;
    begin
      buf_to_hub_REPLY_DATAREADY(j)                     <= INT_REPLY_DATAREADY_IN(i);
      buf_to_hub_REPLY_DATA((j+1)*16-1 downto j*16)     <= INT_REPLY_DATA_IN((i+1)*16-1 downto i*16);
      buf_to_hub_REPLY_PACKET_NUM((j+1)*3-1 downto j*3) <= INT_REPLY_PACKET_NUM_IN((i+1)*3-1 downto i*3);
      INT_REPLY_READ_OUT(i)                             <= buf_to_hub_REPLY_READ(j);

      INT_REPLY_DATAREADY_OUT(i)                        <= hub_to_buf_REPLY_DATAREADY(j);
      INT_REPLY_DATA_OUT((i+1)*16-1 downto i*16)        <= hub_to_buf_REPLY_DATA((j+1)*16-1 downto j*16);
      INT_REPLY_PACKET_NUM_OUT((i+1)*3-1 downto i*3)    <= hub_to_buf_REPLY_PACKET_NUM((j+1)*3-1 downto j*3);
      hub_to_buf_REPLY_READ(j)                          <= INT_REPLY_READ_IN(i);

      buf_to_hub_INIT_DATAREADY(j)                      <= INT_INIT_DATAREADY_IN(i);
      buf_to_hub_INIT_DATA((j+1)*16-1 downto j*16)      <= INT_INIT_DATA_IN((i+1)*16-1 downto i*16);
      buf_to_hub_INIT_PACKET_NUM((j+1)*3-1 downto j*3)  <= INT_INIT_PACKET_NUM_IN((i+1)*3-1 downto i*3);
      INT_INIT_READ_OUT(i)                              <= buf_to_hub_INIT_READ(j);

      INT_INIT_DATAREADY_OUT(i)                         <= hub_to_buf_INIT_DATAREADY(j);
      INT_INIT_DATA_OUT((i+1)*16-1 downto i*16)         <= hub_to_buf_INIT_DATA((j+1)*16-1 downto j*16);
      INT_INIT_PACKET_NUM_OUT((i+1)*3-1 downto i*3)     <= hub_to_buf_INIT_PACKET_NUM((j+1)*3-1 downto j*3);
      hub_to_buf_INIT_READ(j)                           <= INT_INIT_READ_IN(i);
    end generate;
  end generate;
  INT_INIT_DATAREADY_OUT(INT_NUMBER) <= '0';
  INT_INIT_DATA_OUT(INT_NUMBER*c_DATA_WIDTH) <= '0';
  INT_INIT_PACKET_NUM_OUT(INT_NUMBER*c_NUM_WIDTH) <= '0';
  INT_INIT_READ_OUT(INT_NUMBER) <= '0';
  INT_REPLY_DATAREADY_OUT(INT_NUMBER) <= '0';
  INT_REPLY_DATA_OUT(INT_NUMBER*c_DATA_WIDTH) <= '0';
  INT_REPLY_PACKET_NUM_OUT(INT_NUMBER*c_NUM_WIDTH) <= '0';
  INT_REPLY_READ_OUT(INT_NUMBER) <= '0';


---------------------------------------------------------------------
--Connections between IOBuf and Hublogic
---------------------------------------------------------------------
  gen_rearrange : for CHANNEL in 0 to 2**(c_MUX_WIDTH-1)-1 generate
    constant int_num         : integer := calc_special_number(CHANNEL, INT_NUMBER, INT_CHANNELS);
    constant first_point_num : integer := calc_first_point_number(MII_NUMBER, CHANNEL, HUB_CTRL_CHANNELNUM, INT_NUMBER, INT_CHANNELS);
    constant is_ctrl_channel : integer := calc_is_ctrl_channel(CHANNEL, HUB_CTRL_CHANNELNUM);
  begin
    gen_hublogicsignals1 : for mii in 0 to MII_NUMBER-1 generate
      constant buf_to_hub_num : integer := mii*2**(c_MUX_WIDTH-1)+CHANNEL;
      constant hublogic_num   : integer := first_point_num + mii;
    begin
      HUB_INIT_DATAREADY_IN (hublogic_num)
                                <= buf_to_hub_INIT_DATAREADY(buf_to_hub_num);
      HUB_INIT_DATA_IN ((hublogic_num+1)*c_DATA_WIDTH-1 downto hublogic_num*c_DATA_WIDTH)
                                <= buf_to_hub_INIT_DATA((buf_to_hub_num+1)*c_DATA_WIDTH-1 downto buf_to_hub_num*c_DATA_WIDTH);
      HUB_INIT_PACKET_NUM_IN ((hublogic_num+1)*c_NUM_WIDTH-1 downto hublogic_num*c_NUM_WIDTH)
                                <= buf_to_hub_INIT_PACKET_NUM((buf_to_hub_num+1)*c_NUM_WIDTH-1 downto buf_to_hub_num*c_NUM_WIDTH);
      buf_to_hub_INIT_READ(buf_to_hub_num)
                                <= HUB_INIT_READ_OUT(hublogic_num);

      hub_to_buf_INIT_DATAREADY(buf_to_hub_num)
                                <= HUB_INIT_DATAREADY_OUT(hublogic_num);
      hub_to_buf_INIT_DATA((buf_to_hub_num+1)*c_DATA_WIDTH-1 downto buf_to_hub_num*c_DATA_WIDTH)
                                <= HUB_INIT_DATA_OUT((hublogic_num+1)*c_DATA_WIDTH-1 downto hublogic_num*c_DATA_WIDTH);
      hub_to_buf_INIT_PACKET_NUM((buf_to_hub_num+1)*c_NUM_WIDTH-1 downto buf_to_hub_num*c_NUM_WIDTH)
                                <= HUB_INIT_PACKET_NUM_OUT((hublogic_num+1)*c_NUM_WIDTH-1 downto hublogic_num*c_NUM_WIDTH);
      HUB_INIT_READ_IN (hublogic_num)
                                <= hub_to_buf_INIT_READ(buf_to_hub_num);

      HUB_REPLY_DATAREADY_IN (hublogic_num)
                                <= buf_to_hub_REPLY_DATAREADY(buf_to_hub_num);
      HUB_REPLY_DATA_IN ((hublogic_num+1)*c_DATA_WIDTH-1 downto hublogic_num*c_DATA_WIDTH)
                                <= buf_to_hub_REPLY_DATA((buf_to_hub_num+1)*c_DATA_WIDTH-1 downto buf_to_hub_num*c_DATA_WIDTH);
      HUB_REPLY_PACKET_NUM_IN ((hublogic_num+1)*c_NUM_WIDTH-1 downto hublogic_num*c_NUM_WIDTH)
                                <= buf_to_hub_REPLY_PACKET_NUM((buf_to_hub_num+1)*c_NUM_WIDTH-1 downto buf_to_hub_num*c_NUM_WIDTH);
      buf_to_hub_REPLY_READ(buf_to_hub_num)
                                <= HUB_REPLY_READ_OUT(hublogic_num);

      hub_to_buf_REPLY_DATAREADY(buf_to_hub_num)
                                <= HUB_REPLY_DATAREADY_OUT(hublogic_num);
      hub_to_buf_REPLY_DATA((buf_to_hub_num+1)*c_DATA_WIDTH-1 downto buf_to_hub_num*c_DATA_WIDTH)
                                <= HUB_REPLY_DATA_OUT((hublogic_num+1)*c_DATA_WIDTH-1 downto hublogic_num*c_DATA_WIDTH);
      hub_to_buf_REPLY_PACKET_NUM((buf_to_hub_num+1)*c_NUM_WIDTH-1 downto buf_to_hub_num*c_NUM_WIDTH)
                                <= HUB_REPLY_PACKET_NUM_OUT((hublogic_num+1)*c_NUM_WIDTH-1 downto hublogic_num*c_NUM_WIDTH);
      HUB_REPLY_READ_IN (hublogic_num)
                                <= hub_to_buf_REPLY_READ(buf_to_hub_num);
    end generate;
    gen_hublogicsignal_ctrl: if is_ctrl_channel = 1 generate
      constant hublogic_num   : integer := first_point_num + MII_NUMBER; --!num of mii not num of channels!
      constant buf_to_hub_num : integer := 2**(c_MUX_WIDTH-1)*MII_NUMBER;
    begin
      HUB_INIT_DATAREADY_IN (hublogic_num)
                                <= buf_to_hub_INIT_DATAREADY(buf_to_hub_num);
      HUB_INIT_DATA_IN ((hublogic_num+1)*c_DATA_WIDTH-1 downto hublogic_num*c_DATA_WIDTH)
                                <= buf_to_hub_INIT_DATA((buf_to_hub_num+1)*c_DATA_WIDTH-1 downto buf_to_hub_num*c_DATA_WIDTH);
      HUB_INIT_PACKET_NUM_IN ((hublogic_num+1)*c_NUM_WIDTH-1 downto hublogic_num*c_NUM_WIDTH)
                                <= buf_to_hub_INIT_PACKET_NUM((buf_to_hub_num+1)*c_NUM_WIDTH-1 downto buf_to_hub_num*c_NUM_WIDTH);
      buf_to_hub_INIT_READ(buf_to_hub_num)
                                <= HUB_INIT_READ_OUT(hublogic_num);

      hub_to_buf_INIT_DATAREADY(buf_to_hub_num)
                                <= HUB_INIT_DATAREADY_OUT(hublogic_num);
      hub_to_buf_INIT_DATA((buf_to_hub_num+1)*c_DATA_WIDTH-1 downto buf_to_hub_num*c_DATA_WIDTH)
                                <= HUB_INIT_DATA_OUT((hublogic_num+1)*c_DATA_WIDTH-1 downto hublogic_num*c_DATA_WIDTH);
      hub_to_buf_INIT_PACKET_NUM((buf_to_hub_num+1)*c_NUM_WIDTH-1 downto buf_to_hub_num*c_NUM_WIDTH)
                                <= HUB_INIT_PACKET_NUM_OUT((hublogic_num+1)*c_NUM_WIDTH-1 downto hublogic_num*c_NUM_WIDTH);
      HUB_INIT_READ_IN (hublogic_num)
                                <= hub_to_buf_INIT_READ(buf_to_hub_num);

      HUB_REPLY_DATAREADY_IN (hublogic_num)
                                <= buf_to_hub_REPLY_DATAREADY(buf_to_hub_num);
      HUB_REPLY_DATA_IN ((hublogic_num+1)*c_DATA_WIDTH-1 downto hublogic_num*c_DATA_WIDTH)
                                <= buf_to_hub_REPLY_DATA((buf_to_hub_num+1)*c_DATA_WIDTH-1 downto buf_to_hub_num*c_DATA_WIDTH);
      HUB_REPLY_PACKET_NUM_IN ((hublogic_num+1)*c_NUM_WIDTH-1 downto hublogic_num*c_NUM_WIDTH)
                                <= buf_to_hub_REPLY_PACKET_NUM((buf_to_hub_num+1)*c_NUM_WIDTH-1 downto buf_to_hub_num*c_NUM_WIDTH);
      buf_to_hub_REPLY_READ(buf_to_hub_num)
                                <= HUB_REPLY_READ_OUT(hublogic_num);

      hub_to_buf_REPLY_DATAREADY(buf_to_hub_num)
                                <= HUB_REPLY_DATAREADY_OUT(hublogic_num);
      hub_to_buf_REPLY_DATA((buf_to_hub_num+1)*c_DATA_WIDTH-1 downto buf_to_hub_num*c_DATA_WIDTH)
                                <= HUB_REPLY_DATA_OUT((hublogic_num+1)*c_DATA_WIDTH-1 downto hublogic_num*c_DATA_WIDTH);
      hub_to_buf_REPLY_PACKET_NUM((buf_to_hub_num+1)*c_NUM_WIDTH-1 downto buf_to_hub_num*c_NUM_WIDTH)
                                <= HUB_REPLY_PACKET_NUM_OUT((hublogic_num+1)*c_NUM_WIDTH-1 downto hublogic_num*c_NUM_WIDTH);
      HUB_REPLY_READ_IN (hublogic_num)
                                <= hub_to_buf_REPLY_READ(buf_to_hub_num);
    end generate;
    g5: if int_num /= 0 generate
      gen_hublogicsignals2 : for int in 0 to INT_NUMBER-1 generate
        constant hublogic_num   : integer := first_point_num + MII_NUMBER + is_ctrl_channel + calc_special_number(CHANNEL, int, INT_CHANNELS);
        constant buf_to_hub_num : integer := 2**(c_MUX_WIDTH-1)*MII_NUMBER + 1 + int;
                    --calc_special_number(CHANNEL, api, API_CHANNELS)
      begin
        h1: if INT_CHANNELS(int) = CHANNEL generate
          HUB_INIT_DATAREADY_IN (hublogic_num)
                                    <= buf_to_hub_INIT_DATAREADY(buf_to_hub_num);
          HUB_INIT_DATA_IN ((hublogic_num+1)*16-1 downto hublogic_num*16)
                                    <= buf_to_hub_INIT_DATA((buf_to_hub_num+1)*16-1 downto buf_to_hub_num*16);
          HUB_INIT_PACKET_NUM_IN ((hublogic_num+1)*3-1 downto hublogic_num*3)
                                    <= buf_to_hub_INIT_PACKET_NUM((buf_to_hub_num+1)*3-1 downto buf_to_hub_num*3);
          buf_to_hub_INIT_READ(buf_to_hub_num)
                                    <= HUB_INIT_READ_OUT(hublogic_num);

          hub_to_buf_INIT_DATAREADY(buf_to_hub_num)
                                    <= HUB_INIT_DATAREADY_OUT(hublogic_num);
          hub_to_buf_INIT_DATA((buf_to_hub_num+1)*16-1 downto buf_to_hub_num*16)
                                    <= HUB_INIT_DATA_OUT((hublogic_num+1)*16-1 downto hublogic_num*16);
          hub_to_buf_INIT_PACKET_NUM((buf_to_hub_num+1)*3-1 downto buf_to_hub_num*3)
                                    <= HUB_INIT_PACKET_NUM_OUT((hublogic_num+1)*3-1 downto hublogic_num*3);
          HUB_INIT_READ_IN (hublogic_num)
                                    <= hub_to_buf_INIT_READ(buf_to_hub_num);

          HUB_REPLY_DATAREADY_IN (hublogic_num)
                                    <= buf_to_hub_REPLY_DATAREADY(buf_to_hub_num);
          HUB_REPLY_DATA_IN ((hublogic_num+1)*16-1 downto hublogic_num*16)
                                    <= buf_to_hub_REPLY_DATA((buf_to_hub_num+1)*16-1 downto buf_to_hub_num*16);
          HUB_REPLY_PACKET_NUM_IN ((hublogic_num+1)*3-1 downto hublogic_num*3)
                                    <= buf_to_hub_REPLY_PACKET_NUM((buf_to_hub_num+1)*3-1 downto buf_to_hub_num*3);
          buf_to_hub_REPLY_READ(buf_to_hub_num)
                                    <= HUB_REPLY_READ_OUT(hublogic_num);

          hub_to_buf_REPLY_DATAREADY(buf_to_hub_num)
                                    <= HUB_REPLY_DATAREADY_OUT(hublogic_num);
          hub_to_buf_REPLY_DATA((buf_to_hub_num+1)*16-1 downto buf_to_hub_num*16)
                                    <= HUB_REPLY_DATA_OUT((hublogic_num+1)*16-1 downto hublogic_num*16);
          hub_to_buf_REPLY_PACKET_NUM((buf_to_hub_num+1)*3-1 downto buf_to_hub_num*3)
                                    <= HUB_REPLY_PACKET_NUM_OUT((hublogic_num+1)*3-1 downto hublogic_num*3);
          HUB_REPLY_READ_IN (hublogic_num)
                                    <= hub_to_buf_REPLY_READ(buf_to_hub_num);
        end generate;
      end generate;
    end generate;
  end generate;



---------------------------------------------------------------------
--Hub Logic
---------------------------------------------------------------------
  gen_hub_logic: for i in 0 to 2**(c_MUX_WIDTH-1)-1 generate
    constant point_num       : integer := calc_point_number      (MII_NUMBER, i, HUB_CTRL_CHANNELNUM, INT_NUMBER, INT_CHANNELS);
    constant first_point_num : integer := calc_first_point_number(MII_NUMBER, i, HUB_CTRL_CHANNELNUM, INT_NUMBER, INT_CHANNELS);
    constant next_point_num  : integer := first_point_num + point_num;
  begin
    gen_logic : if HUB_USED_CHANNELS(i) = 1 generate
      HUB_CTRL_final_activepoints((i+1)*32-1 downto i*32) <= HUB_CTRL_activepoints((i+1)*32-1 downto i*32) and HUB_MED_CONNECTED;
      gen_select_logic1 : if i /= c_IPU_CHANNEL generate
        HUBLOGIC : trb_net16_hub_logic
          generic map (
          --media interfaces
            POINT_NUMBER        => point_num,
            MII_IS_UPLINK_ONLY  => MII_IS_UPLINK_ONLY
            )
          port map(
            CLK    => CLK,
            RESET  => reset_i,
            CLK_EN => CLK_EN,
            INIT_DATAREADY_IN     => HUB_INIT_DATAREADY_IN(next_point_num-1 downto first_point_num),
            INIT_DATA_IN          => HUB_INIT_DATA_IN(next_point_num*c_DATA_WIDTH-1 downto first_point_num*c_DATA_WIDTH),
            INIT_PACKET_NUM_IN    => HUB_INIT_PACKET_NUM_IN(next_point_num*c_NUM_WIDTH-1 downto first_point_num*c_NUM_WIDTH),
            INIT_READ_OUT         => HUB_INIT_READ_OUT(next_point_num-1 downto first_point_num),
            INIT_DATAREADY_OUT    => HUB_INIT_DATAREADY_OUT(next_point_num-1 downto first_point_num),
            INIT_DATA_OUT         => HUB_INIT_DATA_OUT(next_point_num*c_DATA_WIDTH-1 downto first_point_num*c_DATA_WIDTH),
            INIT_PACKET_NUM_OUT   => HUB_INIT_PACKET_NUM_OUT(next_point_num*c_NUM_WIDTH-1 downto first_point_num*c_NUM_WIDTH),
            INIT_READ_IN          => HUB_INIT_READ_IN(next_point_num-1 downto first_point_num),
            REPLY_DATAREADY_IN    => HUB_REPLY_DATAREADY_IN(next_point_num-1 downto first_point_num),
            REPLY_DATA_IN         => HUB_REPLY_DATA_IN(next_point_num*c_DATA_WIDTH-1 downto first_point_num*c_DATA_WIDTH),
            REPLY_PACKET_NUM_IN   => HUB_REPLY_PACKET_NUM_IN(next_point_num*c_NUM_WIDTH-1 downto first_point_num*c_NUM_WIDTH),
            REPLY_READ_OUT        => HUB_REPLY_READ_OUT(next_point_num-1 downto first_point_num),
            REPLY_DATAREADY_OUT   => HUB_REPLY_DATAREADY_OUT(next_point_num-1 downto first_point_num),
            REPLY_DATA_OUT        => HUB_REPLY_DATA_OUT(next_point_num*c_DATA_WIDTH-1 downto first_point_num*c_DATA_WIDTH),
            REPLY_PACKET_NUM_OUT  => HUB_REPLY_PACKET_NUM_OUT(next_point_num*c_NUM_WIDTH-1 downto first_point_num*c_NUM_WIDTH),
            REPLY_READ_IN         => HUB_REPLY_READ_IN(next_point_num-1 downto first_point_num),
            STAT                  => buf_HUB_STAT_CHANNEL((i+1)*16-1 downto i*16),
            STAT_locked           => HUB_locked(i),
            STAT_POINTS_locked    => buf_STAT_POINTS_locked((i+1)*32-1 downto i*32),
            STAT_TIMEOUT          => STAT_TIMEOUT((i+1)*32-1 downto i*32),
            STAT_ERRORBITS        => HUB_STAT_ERRORBITS((i+1)*32-1 downto i*32),
            STAT_ALL_ERRORBITS    => buf_HUB_ALL_ERROR_BITS((i+1)*32*16-1 downto i*32*16),
            CTRL_TIMEOUT_TIME     => current_timeout_value(i),--HUB_CTRL_TIMEOUT_TIME(i*4+3 downto i*4),
            CTRL_activepoints     => HUB_CTRL_final_activepoints((i+1)*32-1 downto i*32),
            CTRL_DISABLED_PORTS   => hub_ctrl_disabled_ports,
            CTRL_TIMER_TICK(0)    => timer_us_tick,
            CTRL_TIMER_TICK(1)    => timer_ms_tick
            );
      end generate;
      gen_select_logic2 : if i = c_IPU_CHANNEL generate
        HUBLOGIC : trb_net16_hub_ipu_logic
          generic map (
          --media interfaces
            POINT_NUMBER        => point_num
            )
          port map(
            CLK    => CLK,
            RESET  => reset_i,
            CLK_EN => CLK_EN,
            INIT_DATAREADY_IN     => HUB_INIT_DATAREADY_IN(next_point_num-1 downto first_point_num),
            INIT_DATA_IN          => HUB_INIT_DATA_IN(next_point_num*c_DATA_WIDTH-1 downto first_point_num*c_DATA_WIDTH),
            INIT_PACKET_NUM_IN    => HUB_INIT_PACKET_NUM_IN(next_point_num*c_NUM_WIDTH-1 downto first_point_num*c_NUM_WIDTH),
            INIT_READ_OUT         => HUB_INIT_READ_OUT(next_point_num-1 downto first_point_num),
            INIT_DATAREADY_OUT    => HUB_INIT_DATAREADY_OUT(next_point_num-1 downto first_point_num),
            INIT_DATA_OUT         => HUB_INIT_DATA_OUT(next_point_num*c_DATA_WIDTH-1 downto first_point_num*c_DATA_WIDTH),
            INIT_PACKET_NUM_OUT   => HUB_INIT_PACKET_NUM_OUT(next_point_num*c_NUM_WIDTH-1 downto first_point_num*c_NUM_WIDTH),
            INIT_READ_IN          => HUB_INIT_READ_IN(next_point_num-1 downto first_point_num),
            REPLY_DATAREADY_IN    => HUB_REPLY_DATAREADY_IN(next_point_num-1 downto first_point_num),
            REPLY_DATA_IN         => HUB_REPLY_DATA_IN(next_point_num*c_DATA_WIDTH-1 downto first_point_num*c_DATA_WIDTH),
            REPLY_PACKET_NUM_IN   => HUB_REPLY_PACKET_NUM_IN(next_point_num*c_NUM_WIDTH-1 downto first_point_num*c_NUM_WIDTH),
            REPLY_READ_OUT        => HUB_REPLY_READ_OUT(next_point_num-1 downto first_point_num),
            REPLY_DATAREADY_OUT   => HUB_REPLY_DATAREADY_OUT(next_point_num-1 downto first_point_num),
            REPLY_DATA_OUT        => HUB_REPLY_DATA_OUT(next_point_num*c_DATA_WIDTH-1 downto first_point_num*c_DATA_WIDTH),
            REPLY_PACKET_NUM_OUT  => HUB_REPLY_PACKET_NUM_OUT(next_point_num*c_NUM_WIDTH-1 downto first_point_num*c_NUM_WIDTH),
            REPLY_READ_IN         => HUB_REPLY_READ_IN(next_point_num-1 downto first_point_num),
            MY_ADDRESS_IN         => HUB_ADDRESS,
            STAT_DEBUG            => HUBLOGIC_IPU_STAT_DEBUG(31 downto 0),
            STAT_locked           => HUB_locked(i),
            STAT_POINTS_locked    => buf_STAT_POINTS_locked((i+1)*32-1 downto i*32),
            STAT_TIMEOUT          => STAT_TIMEOUT((i+1)*32-1 downto i*32),
            STAT_ERRORBITS        => HUB_STAT_ERRORBITS((i+1)*32-1 downto i*32),
            STAT_ALL_ERRORBITS    => buf_HUB_ALL_ERROR_BITS((i+1)*32*16-1 downto i*32*16),
            STAT_FSM              => stat_ipu_fsm,
            STAT_MISMATCH         => buf_HUB_MISMATCH_PATTERN(31 downto 0),
            CTRL_TIMEOUT_TIME     => current_timeout_value(i),--HUB_CTRL_TIMEOUT_TIME(i*4+3 downto i*4),
            CTRL_activepoints     => HUB_CTRL_final_activepoints((i+1)*32-1 downto i*32),
            CTRL_DISABLED_PORTS   => hub_ctrl_disabled_ports,
            CTRL_TIMER_TICK(0)    => timer_us_tick,
            CTRL_TIMER_TICK(1)    => timer_ms_tick
            );
            buf_HUB_STAT_CHANNEL((i+1)*16-1 downto i*16) <= (others => '0');
      end generate;
    end generate;
    gen_select_no_logic : if HUB_USED_CHANNELS(i) = c_NO generate
      HUB_REPLY_DATA_OUT(next_point_num*c_DATA_WIDTH-1 downto first_point_num*c_DATA_WIDTH) <= (others => '0');
      HUB_REPLY_PACKET_NUM_OUT(next_point_num*c_NUM_WIDTH-1 downto first_point_num*c_NUM_WIDTH) <= (others => '0');
      HUB_REPLY_DATAREADY_OUT(next_point_num-1 downto first_point_num) <= (others => '0');
      HUB_REPLY_READ_IN(next_point_num-1 downto first_point_num) <= (others => '0');
      HUB_REPLY_READ_OUT(next_point_num-1 downto first_point_num) <= (others => '0');
      HUB_INIT_PACKET_NUM_OUT(next_point_num*c_NUM_WIDTH-1 downto first_point_num*c_NUM_WIDTH) <= (others => '0');
      HUB_INIT_DATA_OUT(next_point_num*c_DATA_WIDTH-1 downto first_point_num*c_DATA_WIDTH) <= (others => '0');
      HUB_INIT_DATAREADY_OUT(next_point_num-1 downto first_point_num) <= (others => '0');
      HUB_INIT_PACKET_NUM_IN(next_point_num*c_NUM_WIDTH-1 downto first_point_num*c_NUM_WIDTH) <= (others => '0');
      HUB_INIT_READ_OUT(next_point_num-1 downto first_point_num) <= (others => '0');
    end generate;    
  end generate;

  gen_unused_signals : if 1 =1  generate
    constant i : integer := 2;
    begin
      buf_STAT_POINTS_locked((i+1)*32-1 downto i*32) <= (others => '0');
      buf_HUB_STAT_CHANNEL((i+1)*16-1 downto i*16) <= (others => '0');
      HUB_locked(i) <= '0';
      HUB_CTRL_final_activepoints((i+1)*32-1 downto i*32) <= (others => '0');
      HUB_STAT_ERRORBITS((i+1)*32-1 downto i*32) <= (others => '0');
      hub_ctrl_final_activepoints((i+1)*32-1 downto i*32) <= (others => '0');
      buf_HUB_ALL_ERROR_BITS((i+1)*32*16-1 downto i*32*16) <= (others => '0');
      iobuf_stat_data_counter((i+1)*32-1 downto i*32) <= (others => '0');
      stat_timeout((i+1)*32-1 downto i*32) <= (others => '0');
    end generate;
---------------------------------------------------------------------
--Control RegIO
---------------------------------------------------------------------
  hub_control : trb_net16_regIO
    generic map(
      NUM_STAT_REGS      => 6,
      NUM_CTRL_REGS      => 4,
      INIT_CTRL_REGS     => INIT_CTRL_REGS,
      USED_CTRL_REGS     => (others => '1'),
      USED_CTRL_BITMASK  => (others => '1'),
      USE_DAT_PORT       => c_YES,
      INIT_ADDRESS       => INIT_ADDRESS,
      INIT_UNIQUE_ID     => INIT_UNIQUE_ID,
      INIT_ENDPOINT_ID   => INIT_ENDPOINT_ID,
      COMPILE_TIME       => COMPILE_TIME,
      INCLUDED_FEATURES  => INCLUDED_FEATURES,
      HARDWARE_VERSION   => HARDWARE_VERSION,
      CLOCK_FREQ         => CLOCK_FREQUENCY
      )
    port map(
      CLK    => CLK,
      RESET  =>  reset_i,
      CLK_EN => CLK_EN,
      -- Port to API
      API_DATA_OUT        => HC_DATA_IN,
      API_PACKET_NUM_OUT  => HC_PACKET_NUM_IN,
      API_DATAREADY_OUT   => HC_DATAREADY_IN,
      API_READ_IN         => HC_READ_OUT,
      API_SHORT_TRANSFER_OUT => HC_SHORT_TRANSFER_IN,
      API_DTYPE_OUT       => HC_DTYPE_IN,
      API_ERROR_PATTERN_OUT  => HC_ERROR_PATTERN_IN,
      API_SEND_OUT        => HC_SEND_IN,
      -- Receiver port
      API_DATA_IN         => HC_DATA_OUT,
      API_PACKET_NUM_IN   => HC_PACKET_NUM_OUT,
      API_TYP_IN          => HC_TYP_OUT,
      API_DATAREADY_IN    => HC_DATAREADY_OUT,
      API_READ_OUT        => HC_READ_IN,
      -- HC Control port
      API_RUN_IN          => HC_RUN_OUT,
      API_SEQNR_IN        => HC_SEQNR_OUT,
      MY_ADDRESS_OUT      => HUB_ADDRESS,
      TRIGGER_MONITOR     => '0',
      GLOBAL_TIME         => global_time,
      LOCAL_TIME          => local_time,
      TIME_SINCE_LAST_TRG => open,
      TIMER_MS_TICK       => timer_ms_tick,
      TIMER_US_TICK       => timer_us_tick,
      REGISTERS_IN        => HC_STAT_REGS,
      REGISTERS_OUT       => HC_CTRL_REGS,
      COMMON_STAT_REG_IN  => HC_COMMON_STAT_REGS,
      COMMON_CTRL_REG_OUT => HC_COMMON_CTRL_REGS,
      COMMON_STAT_REG_STROBE => HC_COMMON_STAT_REG_STROBE,
      COMMON_CTRL_REG_STROBE => HC_COMMON_CTRL_REG_STROBE,
      STAT_REG_STROBE        => STAT_REG_STROBE,
      CTRL_REG_STROBE        => CTRL_REG_STROBE,
      --Port to write Unique ID
      IDRAM_DATA_IN       => IDRAM_DATA_IN,
      IDRAM_DATA_OUT      => open,
      IDRAM_ADDR_IN       => IDRAM_ADDR_IN,
      IDRAM_WR_IN         => IDRAM_WR_IN,
      DAT_ADDR_OUT        => DAT_ADDR_OUT,
      DAT_READ_ENABLE_OUT => DAT_READ_ENABLE_OUT,
      DAT_WRITE_ENABLE_OUT=> DAT_WRITE_ENABLE_OUT,
      DAT_DATA_OUT        => DAT_DATA_OUT,
      DAT_DATA_IN         => DAT_DATA_IN,
      DAT_DATAREADY_IN    => DAT_DATAREADY_IN,
      DAT_NO_MORE_DATA_IN => DAT_NO_MORE_DATA_IN,
      DAT_UNKNOWN_ADDR_IN => DAT_UNKNOWN_ADDR_IN,
      DAT_TIMEOUT_OUT     => DAT_TIMEOUT_OUT,
      DAT_WRITE_ACK_IN    => DAT_WRITE_ACK_IN
      );


--Fucking Modelsim wants it like this...
THE_BUS_HANDLER : trb_net16_regio_bus_handler
  generic map(
    PORT_NUMBER    => 7,
    PORT_ADDRESSES => (0 => x"0000", 1 => x"4000", 2 => x"4020", 3 => x"4030", 4 => x"4040", 5 => x"4050", 6 => x"4060", others => x"0000"),
    PORT_ADDR_MASK => (0 => 16,      1 => 5,       2 => 4,       3 => 4,       4 => 4,       5 => 0,       6 => 4,       others => 0),
    PORT_MASK_ENABLE => 0
    )
  port map(
    CLK                          => CLK,
    RESET                        => reset_i,

    DAT_ADDR_IN                  => DAT_ADDR_OUT,
    DAT_DATA_IN                  => DAT_DATA_OUT,
    DAT_DATA_OUT                 => DAT_DATA_IN,
    DAT_READ_ENABLE_IN           => DAT_READ_ENABLE_OUT,
    DAT_WRITE_ENABLE_IN          => DAT_WRITE_ENABLE_OUT,
    DAT_TIMEOUT_IN               => DAT_TIMEOUT_OUT,
    DAT_DATAREADY_OUT            => DAT_DATAREADY_IN,
    DAT_WRITE_ACK_OUT            => DAT_WRITE_ACK_IN,
    DAT_NO_MORE_DATA_OUT         => DAT_NO_MORE_DATA_IN,
    DAT_UNKNOWN_ADDR_OUT         => DAT_UNKNOWN_ADDR_IN,


    BUS_ADDR_OUT(15 downto 0)    => REGIO_ADDR_OUT,
    BUS_ADDR_OUT(20 downto 16)   => stat_packets_addr,
    BUS_ADDR_OUT(31 downto 21)   => dummy(10 downto 0),
    BUS_ADDR_OUT(35 downto 32)   => stat_errorbits_addr,
    BUS_ADDR_OUT(47 downto 36)   => dummy(21 downto 10),
    BUS_ADDR_OUT(51 downto 48)   => stat_busycntincl_addr,
    BUS_ADDR_OUT(63 downto 52)   => dummy(33 downto 22),
    BUS_ADDR_OUT(67 downto 64)   => stat_busycntexcl_addr,
    BUS_ADDR_OUT(79 downto 68)   => dummy(44 downto 33),
    BUS_ADDR_OUT(95 downto 80)   => dummy(60 downto 45),
    BUS_ADDR_OUT(99 downto 96)   => lsm_addr,
    BUS_ADDR_OUT(111 downto 100) => dummy(72 downto 61),
    BUS_DATA_IN(31 downto 0)     => REGIO_DATA_IN,
    BUS_DATA_IN(63 downto 32)    => stat_packets_data,
    BUS_DATA_IN(95 downto 64)    => stat_errorbits_data,
    BUS_DATA_IN(127 downto 96)   => stat_busycntincl_data,
    BUS_DATA_IN(159 downto 128)  => stat_busycntexcl_data,
    BUS_DATA_IN(191 downto 160)  => global_time,
    BUS_DATA_IN(223 downto 192)  => lsm_data,
    BUS_DATA_OUT(31 downto 0)    => REGIO_DATA_OUT,
    BUS_DATA_OUT(63 downto 32)   => dummy(104 downto 73),
    BUS_DATA_OUT(95 downto 64)   => dummy(136 downto 105),
    BUS_DATA_OUT(127 downto 96)  => dummy(168 downto 137),
    BUS_DATA_OUT(159 downto 128) => dummy(200 downto 169),
    BUS_DATA_OUT(191 downto 160) => dummy(232 downto 201),
    BUS_DATA_OUT(223 downto 192) => dummy(264 downto 233),
    BUS_DATAREADY_IN(0)          => REGIO_DATAREADY_IN,
    BUS_DATAREADY_IN(1)          => stat_packets_ready,
    BUS_DATAREADY_IN(2)          => stat_errorbits_ready,
    BUS_DATAREADY_IN(3)          => stat_busycntincl_ready,
    BUS_DATAREADY_IN(4)          => stat_busycntexcl_ready,
    BUS_DATAREADY_IN(5)          => last_stat_globaltime_read,
    BUS_DATAREADY_IN(6)          => last_lsm_read,
    BUS_NO_MORE_DATA_IN(0)       => REGIO_NO_MORE_DATA_IN,
    BUS_NO_MORE_DATA_IN(1)       => '0',
    BUS_NO_MORE_DATA_IN(2)       => '0',
    BUS_NO_MORE_DATA_IN(3)       => '0',
    BUS_NO_MORE_DATA_IN(4)       => '0',
    BUS_NO_MORE_DATA_IN(5)       => '0',
    BUS_NO_MORE_DATA_IN(6)       => '0',
    BUS_READ_ENABLE_OUT(0)       => REGIO_READ_ENABLE_OUT,
    BUS_READ_ENABLE_OUT(1)       => stat_packets_read,
    BUS_READ_ENABLE_OUT(2)       => stat_errorbits_read,
    BUS_READ_ENABLE_OUT(3)       => stat_busycntincl_read,
    BUS_READ_ENABLE_OUT(4)       => stat_busycntexcl_read,
    BUS_READ_ENABLE_OUT(5)       => stat_globaltime_read,
    BUS_READ_ENABLE_OUT(6)       => lsm_read,
    BUS_TIMEOUT_OUT(0)           => REGIO_TIMEOUT_OUT,
    BUS_TIMEOUT_OUT(1)           => dummy(265),
    BUS_TIMEOUT_OUT(2)           => dummy(266),
    BUS_TIMEOUT_OUT(3)           => dummy(267),
    BUS_TIMEOUT_OUT(4)           => dummy(268),
    BUS_TIMEOUT_OUT(5)           => dummy(269),
    BUS_TIMEOUT_OUT(6)           => dummy(270),
    BUS_UNKNOWN_ADDR_IN(0)       => REGIO_UNKNOWN_ADDR_IN,
    BUS_UNKNOWN_ADDR_IN(1)       => stat_packets_unknown,
    BUS_UNKNOWN_ADDR_IN(2)       => stat_packets_unknown,
    BUS_UNKNOWN_ADDR_IN(3)       => stat_busycntincl_unknown,
    BUS_UNKNOWN_ADDR_IN(4)       => stat_busycntexcl_unknown,
    BUS_UNKNOWN_ADDR_IN(5)       => last_stat_globaltime_write,
    BUS_UNKNOWN_ADDR_IN(6)       => lsm_write,
    BUS_WRITE_ACK_IN(0)          => REGIO_WRITE_ACK_IN,
    BUS_WRITE_ACK_IN(1)          => stat_packets_ack,
    BUS_WRITE_ACK_IN(2)          => '0',
    BUS_WRITE_ACK_IN(3)          => stat_busycntincl_ack,
    BUS_WRITE_ACK_IN(4)          => stat_busycntexcl_ack,
    BUS_WRITE_ACK_IN(5)          => '0',
    BUS_WRITE_ACK_IN(6)          => '0',
    BUS_WRITE_ENABLE_OUT(0)      => REGIO_WRITE_ENABLE_OUT,
    BUS_WRITE_ENABLE_OUT(1)      => stat_packets_write,
    BUS_WRITE_ENABLE_OUT(2)      => stat_errorbits_write,
    BUS_WRITE_ENABLE_OUT(3)      => stat_busycntincl_write,
    BUS_WRITE_ENABLE_OUT(4)      => stat_busycntexcl_write,
    BUS_WRITE_ENABLE_OUT(5)      => stat_globaltime_write,
    BUS_WRITE_ENABLE_OUT(6)      => lsm_write,

    STAT_DEBUG  => open
    );

---------------------------------------------------------------------
--1-wire interface
---------------------------------------------------------------------
  gen_1wire : if USE_ONEWIRE = c_YES generate
    onewire_interface : trb_net_onewire
      generic map(
        USE_TEMPERATURE_READOUT => c_YES,
        CLK_PERIOD => 10
        )
      port map(
        CLK      => CLK,
        RESET    => reset_i,
        --connection to 1-wire interface
        ONEWIRE  => ONEWIRE,
        MONITOR_OUT => ONEWIRE_MONITOR_OUT,
        --connection to id ram, according to memory map in TrbNetRegIO
        DATA_OUT => ONEWIRE_DATA,
        ADDR_OUT => ONEWIRE_ADDR,
        WRITE_OUT=> ONEWIRE_WRITE,
        TEMP_OUT => TEMP_OUT,
        ID_OUT   => UNIQUE_ID_OUT,
        STAT     => open
        );
  end generate;

  gen_1wire_monitor : if USE_ONEWIRE = c_MONITOR generate
    onewire_interface : trb_net_onewire_listener
      port map(
        CLK      => CLK,
        CLK_EN   => CLK_EN,
        RESET    => reset_i,
        --connection to 1-wire interface
        MONITOR_IN => ONEWIRE_MONITOR_IN,
        --connection to id ram, according to memory map in TrbNetRegIO
        DATA_OUT => ONEWIRE_DATA,
        ADDR_OUT => ONEWIRE_ADDR,
        WRITE_OUT=> ONEWIRE_WRITE,
        TEMP_OUT => TEMP_OUT,
        ID_OUT   => UNIQUE_ID_OUT,
        STAT     => open
        );
  end generate;

-------------------------------------------------
-- Include variable Endpoint ID
-------------------------------------------------
  gen_var_endpoint_id : if USE_VAR_ENDPOINT_ID = c_YES generate
    IDRAM_DATA_IN  <= REGIO_VAR_ENDPOINT_ID when RESET = '1' else ONEWIRE_DATA;
    IDRAM_ADDR_IN  <= "100"                 when RESET = '1' else ONEWIRE_ADDR;
    IDRAM_WR_IN    <= '1'                   when RESET = '1' else ONEWIRE_WRITE;
  end generate;

  gen_no_var_endpoint_id : if USE_VAR_ENDPOINT_ID = c_NO generate
    IDRAM_DATA_IN  <= ONEWIRE_DATA;
    IDRAM_ADDR_IN  <= ONEWIRE_ADDR;
    IDRAM_WR_IN    <= ONEWIRE_WRITE;
  end generate;

---------------------------------------------------------------------
--Status of media interfaces
---------------------------------------------------------------------
  gen_MED_CON : for i in 0 to MII_NUMBER-1 generate
    process(CLK)
      begin
        if rising_edge(CLK) then
          if m_ERROR_IN((i+1)*3-1 downto i*3) /= ERROR_OK then
            HUB_MED_CONNECTED(i) <= '0';
          else
            HUB_MED_CONNECTED(i) <= '1';
          end if;
        end if;
      end process;
  end generate;


HUB_MED_CONNECTED(31 downto MII_NUMBER) <= (others => '1');

---------------------------------------------------------------------
--Status and Control Registers
---------------------------------------------------------------------

  gen_timeout_values : for k in 0 to 3 generate
    proc_get_timeout_value : process(CLK)
      begin
        if rising_edge(CLK) then
          case to_integer(unsigned(HUB_CTRL_TIMEOUT_TIME(k*4+3 downto k*4))) is
            when 0  => current_timeout_value(k) <= std_logic_vector(to_unsigned(0,16));
            when 1  => current_timeout_value(k) <= std_logic_vector(to_unsigned(128,16) - unsigned(hub_level&'0'));
            when 2  => current_timeout_value(k) <= std_logic_vector(to_unsigned(256,16) - unsigned(hub_level&'0'));
            when 3  => current_timeout_value(k) <= std_logic_vector(to_unsigned(512,16) - unsigned(hub_level&'0'));
            when 4  => current_timeout_value(k) <= std_logic_vector(to_unsigned(1024,16) - unsigned(hub_level&'0'));
            when 5  => current_timeout_value(k) <= std_logic_vector(to_unsigned(2048,16) - unsigned(hub_level&'0'));
            when 6  => current_timeout_value(k) <= std_logic_vector(to_unsigned(4096,16) - unsigned(hub_level&'0'));
            when 7  => current_timeout_value(k) <= std_logic_vector(to_unsigned(8192,16) - unsigned(hub_level&'0'));
            when others => current_timeout_value(k) <= std_logic_vector(to_unsigned(0,16));
          end case;
        end if;
      end process;
  end generate;


--Usual common stat reg, trigger counters are not in use here
  HC_COMMON_STAT_REGS(19 downto 0)   <= COMMON_STAT_REGS(19 downto 0);
  HC_COMMON_STAT_REGS(31 downto 20)  <= TEMP_OUT;
  HC_COMMON_STAT_REGS(287 downto 32) <= COMMON_STAT_REGS(287 downto 32);

--Status Registers
  buf_HC_STAT_REGS(3*32+31 downto 0)                 <= buf_STAT_POINTS_locked;
  buf_HC_STAT_REGS(4*32+MII_NUMBER-1 downto 4*32)    <= HUB_MED_CONNECTED(MII_NUMBER-1 downto 0);
  buf_HC_STAT_REGS(4*32+31 downto 4*32+MII_NUMBER)   <= (others => '0');
  buf_HC_STAT_REGS(5*32+31 downto 5*32+17)           <= (others => '0');
  buf_HC_STAT_REGS(6*32+31 downto 6*32+17)           <= (others => '0');
  buf_HC_STAT_REGS(7*32+31 downto 7*32)              <= stat_ipu_fsm;
  buf_HC_STAT_REGS(15*32+31 downto 8*32)             <= (others => '0');
  buf_HC_STAT_REGS(16*32+MII_NUMBER-1 downto 16*32)  <= mii_error(MII_NUMBER-1 downto 0);
  buf_HC_STAT_REGS(30*32+31 downto 16*32+MII_NUMBER) <= (others => '0');
  buf_HC_STAT_REGS(31*32+31 downto 31*32)            <= buf_HUB_MISMATCH_PATTERN;
  buf_HC_STAT_REGS(35*32+31 downto 32*32)            <= HUB_STAT_ERRORBITS;
  buf_HC_STAT_REGS(63*32+31 downto 36*32)            <= (others => '0');

  loop_links : for i in 0 to 16 generate
    buf_HC_STAT_REGS(5*32+i) <= '1' when MII_IS_UPLINK(i) = 1 else '0'; --(i < MII_NUMBER or (i = MII_NUMBER and INT_NUMBER > 0)) and
    buf_HC_STAT_REGS(6*32+i) <= '1' when MII_IS_DOWNLINK(i) = 1  else '0'; --(i < MII_NUMBER or (i = MII_NUMBER and INT_NUMBER > 0)) and;
  end generate;

  PROC_MED_ERROR : process(CLK)
    begin
      if rising_edge(CLK) then
        gen_bits : for i in 0 to MII_NUMBER-1 loop
          if MED_STAT_OP(i*16+15 downto i*16+13) = "000" and MED_STAT_OP(i*16+12) = '1' and RESET = '0' then
            mii_error(i) <= '1';
          elsif STAT_REG_STROBE(16) = '1' then
            mii_error(i) <= '0';
          end if;
        end loop;
      end if;
    end process;
  mii_error(31 downto MII_NUMBER) <= (others => '0');

  PROC_TIMEOUT : process(CLK)
    begin
      if rising_edge(CLK) then
        reg_STROBES <= STAT_REG_STROBE;
--Timeouts 88-8B
        if reg_STROBES(8) = '1' then
          HC_STAT_REGS(8*32+31 downto 8*32) <= (others => '0');
        elsif combined_resync = '0' and reset_i = '0' and timer_us_tick = '1' then
          HC_STAT_REGS(8*32+31 downto 8*32) <= STAT_TIMEOUT(0*32+31 downto 0*32) or HC_STAT_REGS(8*32+31 downto 8*32);
        end if;
        if reg_STROBES(9) = '1' then
          HC_STAT_REGS(9*32+31 downto 9*32) <= (others => '0');
        elsif combined_resync = '0' and reset_i = '0' and timer_us_tick = '1' then
          HC_STAT_REGS(9*32+31 downto 9*32) <= STAT_TIMEOUT(1*32+31 downto 1*32) or HC_STAT_REGS(9*32+31 downto 9*32);
        end if;
        HC_STAT_REGS(10*32+31 downto 10*32) <= (others => '0');
        if reg_STROBES(11) = '1' then
          HC_STAT_REGS(11*32+31 downto 11*32) <= (others => '0');
        elsif combined_resync = '0' and reset_i = '0' and timer_us_tick = '1' then
          HC_STAT_REGS(11*32+31 downto 11*32) <= STAT_TIMEOUT(3*32+31 downto 3*32) or HC_STAT_REGS(11*32+31 downto 11*32);
        end if;

--Waiting for ACK timeout 8C-8F
        if reg_STROBES(12) = '1' then
          HC_STAT_REGS(12*32+31 downto 12*32) <= (others => '0');
        else
          HC_STAT_REGS(12*32+31 downto 12*32) <= HC_STAT_ack_waiting(0*32+31 downto 0*32) or HC_STAT_REGS(12*32+31 downto 12*32);
        end if;
        if reg_STROBES(13) = '1' then
          HC_STAT_REGS(13*32+31 downto 13*32) <= (others => '0');
        else
          HC_STAT_REGS(13*32+31 downto 13*32) <= HC_STAT_ack_waiting(1*32+31 downto 1*32) or HC_STAT_REGS(13*32+31 downto 13*32);
        end if;
--         if reg_STROBES(14) = '1' then
          HC_STAT_REGS(14*32+31 downto 14*32) <= (others => '0');
--         else
--           HC_STAT_REGS(14*32+31 downto 14*32) <= HC_STAT_ack_waiting(2*32+31 downto 2*32) or HC_STAT_REGS(14*32+31 downto 14*32);
--         end if;
        if reg_STROBES(15) = '1' then
          HC_STAT_REGS(15*32+31 downto 15*32) <= (others => '0');
        else
          HC_STAT_REGS(15*32+31 downto 15*32) <= HC_STAT_ack_waiting(3*32+31 downto 3*32) or HC_STAT_REGS(15*32+31 downto 15*32);
        end if;

--Error on slowcontrol A4
        if reg_STROBES(36) = '1' then
          HC_STAT_REGS(36*32+31 downto 36*32) <= (others => '0');
        else
          for i in 0 to MII_NUMBER-1 loop
            HC_STAT_REGS(36*32+i) <= HC_STAT_REGS(36*32+i) or buf_HUB_ALL_ERROR_BITS(i*32+48*32+1) or buf_HUB_ALL_ERROR_BITS(i*32+48*32+3) or
                                     buf_HUB_ALL_ERROR_BITS(i*32+48*32+6);
          end loop;
        end if;

--Track boards A5
        if reg_STROBES(37) = '1' then
          HC_STAT_REGS(37*32+31 downto 37*32) <= (others => '0');
        else
          for i in 0 to MII_NUMBER-1 loop
            HC_STAT_REGS(37*32+i) <= HC_STAT_REGS(37*32+i)
                                     or (buf_HUB_ALL_ERROR_BITS(i*32+48*32+0) and buf_HUB_ALL_ERROR_BITS(i*32+48*32+4));
          end loop;
        end if;

--LSM packet timeout A6
        if reg_STROBES(38) = '1' then
          HC_STAT_REGS(38*32+31 downto 38*32) <= (others => '0');
        elsif reset_i = '0' then
          for i in 0 to MII_NUMBER-1 loop
            HC_STAT_REGS(38*32+i) <= HC_STAT_REGS(38*32+i) or (MED_STAT_OP(i*16+12));
          end loop;
        end if;

        HC_STAT_REGS(8*32-1 downto 0)      <= buf_HC_STAT_REGS(8*32-1 downto 0);
        HC_STAT_REGS(36*32-1 downto 16*32) <= buf_HC_STAT_REGS(36*32-1 downto 16*32);
      end if;
    end process;
  HC_STAT_REGS(64*32-1 downto 39*32) <= buf_HC_STAT_REGS(64*32-1 downto 39*32);

------------------------------------
--STAT error bits
------------------------------------
  loop_links_2 : for i in 0 to 15 generate
    HUB_ERROR_BITS(i*32+7  downto i*32+0)  <= buf_HUB_ALL_ERROR_BITS(i*32+7 downto i*32+0);
    HUB_ERROR_BITS(i*32+15 downto i*32+8)  <= buf_HUB_ALL_ERROR_BITS(i*32+23 downto i*32+16);
    HUB_ERROR_BITS(i*32+23 downto i*32+16) <= buf_HUB_ALL_ERROR_BITS(i*32+32*16+7 downto i*32+32*16+0);
    HUB_ERROR_BITS(i*32+31 downto i*32+24) <= buf_HUB_ALL_ERROR_BITS(i*32+32*16+23 downto i*32+32*16+16);
  end generate;

  PROC_ERROR_BITS : process(CLK, stat_errorbits_addr)
    variable tmp : integer;
    begin
      tmp := to_integer(unsigned(stat_errorbits_addr));
      if rising_edge(CLK) then
        stat_errorbits_unknown      <= stat_errorbits_write;
        stat_errorbits_ready        <= stat_errorbits_read;
        stat_errorbits_data         <= HUB_ERROR_BITS(tmp*32+31 downto tmp*32);
      end if;
    end process;

------------------------------------
--STAT packet counters
------------------------------------
  gen_packet_cnt : for i in 0 to MII_NUMBER-1 generate
    stat_packets_all(i*32+31 downto i*32) <= IOBUF_STAT_DATA_COUNTER(i*128+63  downto i*128+32);
    stat_packets_all((i+16)*32+31 downto (i+16)*32) <= IOBUF_STAT_DATA_COUNTER(i*128+127  downto i*128+96);
  end generate;
  stat_packets_all(16*32-1 downto MII_NUMBER*32) <= (others => '0');
  stat_packets_all(32*32-1 downto (MII_NUMBER+16)*32) <= (others => '0');


  PROC_PACKET_COUNTERS : process(CLK, stat_packets_addr)
    variable tmp : integer;
    begin
      tmp := to_integer(unsigned(stat_packets_addr));
      if rising_edge(CLK) then
        iobuf_reset_ipu_counter   <= '0';
        iobuf_reset_sctrl_counter <= '0';
        stat_packets_unknown      <= '0';
        stat_packets_ack          <= '0';
        stat_packets_ready        <= stat_packets_read;
        stat_packets_data         <= stat_packets_all(tmp*32+31 downto tmp*32);
        if stat_packets_addr = "00000" and stat_packets_write = '1' then
          stat_packets_ack          <= '1';
          iobuf_reset_ipu_counter   <= '1';
        elsif stat_packets_addr = "10000" and stat_packets_write = '1' then
          stat_packets_ack          <= '1';
          iobuf_reset_sctrl_counter <= '1';
        elsif stat_packets_write = '1' then
          stat_packets_unknown      <= stat_packets_write;
        end if;
      end if;
    end process;

------------------------------------
--LSM status
------------------------------------
  PROC_LSM_STAT : process(CLK, lsm_addr)
    variable tmp : integer range 0 to 15;
    begin
      tmp := to_integer(unsigned(lsm_addr));
      if rising_edge(CLK) then
        next_last_lsm_read          <= lsm_read;
        last_lsm_read               <= next_last_lsm_read;
        next_lsm_data(7 downto 0)   <= MED_STAT_OP(tmp*16+7 downto tmp*16+0);
        next_lsm_data(15 downto 8)  <= (others => '0');
        next_lsm_data(23 downto 16) <= std_logic_vector(received_retransmit_requests(tmp));
        next_lsm_data(31 downto 24) <= std_logic_vector(sent_retransmit_requests(tmp));
        lsm_data                    <= next_lsm_data;
      end if;
    end process;

  gen_retransmit_counters : for i in 0 to MII_NUMBER-1 generate
    proc_retransmit_counters : process(CLK)
      begin
        if rising_edge(CLK) then
          if HC_COMMON_CTRL_REGS(5) = '1' then
            sent_retransmit_requests(i) <= (others => '0');
          elsif MED_STAT_OP(i*16+12) = '1' then
            sent_retransmit_requests(i) <= sent_retransmit_requests(i) + to_unsigned(1,1);
          end if;
          if HC_COMMON_CTRL_REGS(5) = '1' then
            received_retransmit_requests(i) <= (others => '0');
          elsif MED_STAT_OP(i*16+8) = '1' then
            received_retransmit_requests(i) <= received_retransmit_requests(i) + to_unsigned(1,1);
          end if;
        end if;
      end process;
  end generate;
  
  gen_0s : for i in MII_NUMBER to 15 generate
    received_retransmit_requests(i) <= (others => '0');
    sent_retransmit_requests(i) <= (others => '0');
  end generate;

------------------------------------
--STAT busy counters
------------------------------------
  gen_busy_counters : for i in 0 to MII_NUMBER+2 generate
    proc_busy_counters : process(CLK)
      begin
        if rising_edge(CLK) then
          reg_STAT_POINTS_locked(i) <= buf_STAT_POINTS_locked(i);
          if reg_STAT_POINTS_locked(i) = '1' and
             or_all(reg_STAT_POINTS_locked(MII_NUMBER-1 downto 0) and not (std_logic_vector(to_unsigned(2**i,MII_NUMBER)))) = '0' then
            reg_excl_enable(i)        <= '1';
          else
            reg_excl_enable(i)        <= '0';
          end if;

          if stat_busycntincl_ack = '1' then
            busy_counter_incl(i) <= (others => '0');
          elsif reg_STAT_POINTS_locked(i) = '1' then
            busy_counter_incl(i) <= busy_counter_incl(i) + to_unsigned(1,1);
          end if;

          if stat_busycntexcl_ack = '1' then
            busy_counter_excl(i) <= (others => '0');
          elsif reg_excl_enable(i) = '1' then
            busy_counter_excl(i) <= busy_counter_excl(i) + to_unsigned(1,1);
          end if;

        end if;
      end process;
  end generate;

  proc_busy_counter_incl_register : process(CLK)
    variable tmp : integer range 0 to 15;
    begin
      if rising_edge(CLK) then
        last_stat_globaltime_read  <= stat_globaltime_read;
        last_stat_globaltime_write <= stat_globaltime_write;

        stat_busycntincl_unknown <= '0';
        stat_busycntincl_ready   <= '0';
        if stat_busycntincl_read = '1' then
          tmp := to_integer(unsigned(stat_busycntincl_addr));
          if tmp < MII_NUMBER then
            stat_busycntincl_data   <= std_logic_vector(busy_counter_incl(tmp));
            stat_busycntincl_ready  <= '1';
          else
            stat_busycntincl_data   <= (others => '0');
            stat_busycntincl_ready  <= '1';
          end if;
        end if;
        if stat_busycntincl_write = '1' then
          stat_busycntincl_ack <= '1';
        else
          stat_busycntincl_ack <= '0';
        end if;
      end if;
    end process;

  proc_busy_counter_excl_register : process(CLK)
    variable tmp : integer range 0 to 15;
    begin
      if rising_edge(CLK) then
        stat_busycntexcl_unknown <= '0';
        stat_busycntexcl_ready   <= '0';
        if stat_busycntexcl_read = '1' then
          tmp := to_integer(unsigned(stat_busycntexcl_addr));
          if tmp < MII_NUMBER then
            stat_busycntexcl_data   <= std_logic_vector(busy_counter_excl(tmp));
            stat_busycntexcl_ready  <= '1';
          else
            stat_busycntexcl_data   <= (others => '0');
            stat_busycntexcl_ready  <= '1';
          end if;
        end if;
        if stat_busycntexcl_write = '1' then
          stat_busycntexcl_ack <= '1';
        else
          stat_busycntexcl_ack <= '0';
        end if;
      end if;
    end process;

------------------------------------
--Control Registers
------------------------------------
  HUB_CTRL_media_interfaces_off <= HC_CTRL_REGS(2**2*32+31 downto 2**2*32);
  HUB_CTRL_LOCAL_NETWORK_RESET  <= HC_CTRL_REGS(6*32+MII_NUMBER-1 downto 6*32);

  PROC_active_points : process (CLK)
    begin
      if rising_edge(CLK) then
        for i in 0 to 2**(c_MUX_WIDTH-1)-1 loop
          if HUB_locked(i) = '0' then
            HUB_CTRL_activepoints(i*32+31 downto i*32)  <= HC_CTRL_REGS(i*32+31 downto i*32);
            if i < 2 and INT_NUMBER >= 3 then
              HUB_CTRL_activepoints(i*32+MII_NUMBER) <= HC_CTRL_REGS(i*32+MII_NUMBER) and stream_port_connected;
            else
              HUB_CTRL_activepoints(i*32+MII_NUMBER+1) <= HC_CTRL_REGS(i*32+MII_NUMBER+1) and stream_port_connected;
            end if;
          else
            HUB_CTRL_activepoints(i*32+31 downto i*32) <= HUB_CTRL_activepoints(i*32+31 downto i*32); -- and not HC_STAT_ack_waiting(i*32+31 downto i*32)
            if i < 2 and INT_NUMBER >= 3 then
              HUB_CTRL_activepoints(i*32+MII_NUMBER) <= HUB_CTRL_activepoints(i*32+MII_NUMBER) and stream_port_connected; -- and not HC_STAT_ack_waiting(i*32+31 downto i*32)
            else
              HUB_CTRL_activepoints(i*32+MII_NUMBER+1) <= HUB_CTRL_activepoints(i*32+MII_NUMBER+1) and stream_port_connected; -- and not HC_STAT_ack_waiting(i*32+31 downto i*32)
            end if;
          end if;
        end loop;
      end if;
    end process;

  PROC_ports_disable_after_timeout: process begin
    wait until rising_edge(CLK);
    if HUB_CTRL_TIMEOUT_TIME(31) = '0' or reset_i = '1' then
      hub_ctrl_disabled_ports <=  not HUB_MED_CONNECTED; --(others => '0');
    else
      hub_ctrl_disabled_ports(31 downto MII_NUMBER)  <= (others => '0');
      hub_ctrl_disabled_ports(MII_NUMBER-1 downto 0) <= STAT_TIMEOUT(3*32+MII_NUMBER-1+16 downto 3*32+16) or not HUB_MED_CONNECTED(MII_NUMBER-1 downto 0);
    end if;
  end process;
    
  PROC_timeout_settings : process (CLK)
    begin
      if rising_edge(CLK) then
--         if  CTRL_REG_STROBE(5) = '1' then
          HUB_CTRL_TIMEOUT_TIME <= HC_CTRL_REGS(5*32+31 downto 5*32);
          hub_level             <= HC_CTRL_REGS(5*32+23 downto 5*32+16);
--         end if;
      end if;
    end process;


  gen_ack_waiting : for i in 0 to MII_NUMBER-1 generate
    HC_STAT_ack_waiting(i)     <= iobuf_stat_init_obuf_debug_i((i*4+0)*32+20);
    HC_STAT_ack_waiting(32+i)  <= iobuf_stat_init_obuf_debug_i((i*4+1)*32+20);
    HC_STAT_ack_waiting(64+i)  <= iobuf_stat_init_obuf_debug_i((i*4+2)*32+20);
    HC_STAT_ack_waiting(96+i)  <= iobuf_stat_init_obuf_debug_i((i*4+3)*32+20);
  end generate;

  HC_STAT_ack_waiting( 0+31 downto  0+MII_NUMBER) <= (others => '0');
  HC_STAT_ack_waiting(32+31 downto 32+MII_NUMBER) <= (others => '0');
  HC_STAT_ack_waiting(64+31 downto 64+MII_NUMBER) <= (others => '0');
  HC_STAT_ack_waiting(96+31 downto 96+MII_NUMBER) <= (others => '0');

  stream_port_connected <= '1' when CTRL_DEBUG(2 downto 0) = (not ERROR_OK) else '0';
---------------------------------------------------------------------
-- Counter reset signals
---------------------------------------------------------------------
  iobuf_ctrl_stat(15 downto 0)  <= (others => '0');
  iobuf_ctrl_stat(16)           <= iobuf_reset_ipu_counter;
  iobuf_ctrl_stat(47 downto 17) <= (others => '0');
  iobuf_ctrl_stat(48)           <= iobuf_reset_sctrl_counter;
  iobuf_ctrl_stat(63 downto 49) <= (others => '0');

---------------------------------------------------------------------
--LED signals
---------------------------------------------------------------------
  proc_led_count: process(CLK)
    begin
      if rising_edge(CLK) then
        if timer_ms_tick = '1' then
          led_counter <= led_counter + to_unsigned(1,1);
        end if;
      end if;
    end process;

  proc_led : process(CLK)
    begin
      if rising_edge(CLK) then
        for i in 0 to MII_NUMBER-1 loop
          hub_led_i(i) <= '0';
          if hub_show_port(i) = '1' then
            if led_counter(6 downto 0) < to_unsigned(32,7) then
              hub_led_i(i) <= '1';
            end if;
          elsif HC_STAT_REGS(8*32+i) = '1' or HC_STAT_REGS(9*32+i) = '1' or HC_STAT_REGS(10*32+i) = '1' or HC_STAT_REGS(11*32+i) = '1' then
            if led_counter(8 downto 0) < to_unsigned(128,10) then
              hub_led_i(i) <= '1';
            end if;
          end if;
        end loop;
      end if;
    end process;

  hub_show_port <= HC_CTRL_REGS(7*32+MII_NUMBER-1 downto 7*32);
  HUB_LED_OUT <= hub_led_i;

---------------------------------------------------------------------
--Debugging Signals
---------------------------------------------------------------------
--   buf_STAT_DEBUG(0)  <= hub_to_buf_INIT_DATAREADY(2**(c_MUX_WIDTH-1)*MII_NUMBER);
--   buf_STAT_DEBUG(1)  <= hub_to_buf_INIT_READ(2**(c_MUX_WIDTH-1)*MII_NUMBER);
--   buf_STAT_DEBUG(2)  <= hub_to_buf_REPLY_DATAREADY(2**(c_MUX_WIDTH-1)*MII_NUMBER);
--   buf_STAT_DEBUG(3)  <= hub_to_buf_REPLY_READ(2**(c_MUX_WIDTH-1)*MII_NUMBER);
--   buf_STAT_DEBUG(6 downto 4)  <= hub_to_buf_INIT_DATA(2**(c_MUX_WIDTH-1)*MII_NUMBER*16+2 downto 2**(c_MUX_WIDTH-1)*MII_NUMBER*16);
--   buf_STAT_DEBUG(7)  <= buf_HUB_STAT_CHANNEL(3*16+1);
--   
--   buf_STAT_DEBUG(8)  <= reset_i_mux_io(2*MII_NUMBER+6);
--   buf_STAT_DEBUG(9)  <= reset_i_mux_io(3*MII_NUMBER+6);
--   buf_STAT_DEBUG(10) <= HUB_CTRL_final_activepoints(3*32+6);
--   buf_STAT_DEBUG(11) <= STAT_TIMEOUT(3*32+6);
--   buf_STAT_DEBUG(12) <= buf_to_hub_REPLY_DATAREADY(6*4+3);
--   buf_STAT_DEBUG(13) <= buf_to_hub_REPLY_READ(6*4+3);
--   buf_STAT_DEBUG(14) <= buf_HUB_STAT_CHANNEL(3*16+2);
--   
--   buf_STAT_DEBUG(15) <= buf_to_hub_INIT_DATAREADY(0*4+3);
  
  
  buf_STAT_DEBUG( 3 downto 0 ) <= STAT_TIMEOUT(3*32+3 downto 3*32);
  buf_STAT_DEBUG( 7 downto 4 ) <= HUB_CTRL_final_activepoints(3*32+3 downto 3*32);
  

  IOBUF_STAT_INIT_OBUF_DEBUG <= iobuf_stat_init_obuf_debug_i;
  IOBUF_STAT_REPLY_OBUF_DEBUG <= iobuf_stat_reply_obuf_debug_i;
  IOBUF_CTRL_GEN <= (others => '0');
  --map regio registers to stat & ctrl outputs
  COMMON_CTRL_REGS      <= HC_COMMON_CTRL_REGS;
  COMMON_CTRL_REG_STROBE <= HC_COMMON_CTRL_REG_STROBE;
  COMMON_STAT_REG_STROBE <= HC_COMMON_STAT_REG_STROBE;
  MY_ADDRESS_OUT        <= HUB_ADDRESS;
  STAT_REGS             <= HC_STAT_REGS(16*32-1 downto 0);
  STAT_CTRL_REGS        <= HC_CTRL_REGS(255 downto 0);
  HUB_STAT_CHANNEL      <= buf_HUB_STAT_CHANNEL;
  STAT_DEBUG            <= buf_STAT_DEBUG;
  
  HUB_STAT_GEN(3 downto 0)  <= HUB_locked;
  HUB_STAT_GEN(31 downto 4) <= (others => '0');

  TIMER_TICKS_OUT(0) <= timer_us_tick;
  TIMER_TICKS_OUT(1) <= timer_ms_tick;
  TEMPERATURE_OUT <= TEMP_OUT;
end architecture;
