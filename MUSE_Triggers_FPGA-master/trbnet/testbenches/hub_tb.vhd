LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb_net16_hub_func.all;

entity hub_tb is
end entity;

architecture hub_tb_arch of hub_tb is

component trb_net16_hub_base is
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
                                         x"00000000_00000000_00007077_00000000" &
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
    MY_ADDRESS_OUT               : out std_logic_vector (15 downto 0);
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
end component;

component trb_net16_endpoint_hades_full is
  generic (
    USE_CHANNEL                  : channel_config_t := (c_YES,c_YES,c_NO,c_YES);
    IBUF_DEPTH                   : channel_config_t := (6,6,6,6);
    FIFO_TO_INT_DEPTH            : channel_config_t := (6,6,6,6);
    FIFO_TO_APL_DEPTH            : channel_config_t := (1,1,1,1);
    IBUF_SECURE_MODE             : channel_config_t := (c_YES,c_YES,c_YES,c_YES);
    API_SECURE_MODE_TO_APL       : channel_config_t := (c_YES,c_YES,c_YES,c_YES);
    API_SECURE_MODE_TO_INT       : channel_config_t := (c_YES,c_YES,c_YES,c_YES);
    OBUF_DATA_COUNT_WIDTH        : integer range 0 to 7 := std_DATA_COUNT_WIDTH;
    INIT_CAN_SEND_DATA           : channel_config_t := (c_NO,c_NO,c_NO,c_NO);
    REPLY_CAN_SEND_DATA          : channel_config_t := (c_YES,c_YES,c_YES,c_YES);
    REPLY_CAN_RECEIVE_DATA       : channel_config_t := (c_NO,c_NO,c_NO,c_NO);
    USE_CHECKSUM                 : channel_config_t := (c_NO,c_YES,c_YES,c_YES);
    APL_WRITE_ALL_WORDS          : channel_config_t := (c_NO,c_NO,c_NO,c_NO);
    ADDRESS_MASK                 : std_logic_vector(15 downto 0) := x"FFFF";
    BROADCAST_BITMASK            : std_logic_vector(7 downto 0) := x"FF";
    BROADCAST_SPECIAL_ADDR       : std_logic_vector(7 downto 0) := x"FF";
    TIMING_TRIGGER_RAW           : integer range 0 to 1 := c_YES;
    REGIO_NUM_STAT_REGS          : integer range 0 to 6 := 3; --log2 of number of status registers
    REGIO_NUM_CTRL_REGS          : integer range 0 to 6 := 3; --log2 of number of ctrl registers
    --standard values for output registers
    REGIO_INIT_CTRL_REGS         : std_logic_vector(2**(4)*32-1 downto 0) := (others => '0');
    --set to 0 for unused ctrl registers to save resources
    REGIO_USED_CTRL_REGS         : std_logic_vector(2**(4)-1 downto 0)    := (others => '1');
    --set to 0 for each unused bit in a register
    REGIO_USED_CTRL_BITMASK      : std_logic_vector(2**(4)*32-1 downto 0) := (others => '1');
    REGIO_USE_DAT_PORT           : integer range 0 to 1 := c_YES;  --internal data port
    REGIO_INIT_ADDRESS           : std_logic_vector(15 downto 0) := x"FFFF";
    REGIO_INIT_UNIQUE_ID         : std_logic_vector(63 downto 0) := x"1000_2000_3654_4876";
    REGIO_INIT_BOARD_INFO        : std_logic_vector(31 downto 0) := x"1111_2222";
    REGIO_INIT_ENDPOINT_ID       : std_logic_vector(15 downto 0) := x"0001";
    REGIO_COMPILE_TIME           : std_logic_vector(31 downto 0) := x"00000000";
    REGIO_INCLUDED_FEATURES      : std_logic_vector(63 downto 0) := (others => '0');
    REGIO_HARDWARE_VERSION       : std_logic_vector(31 downto 0) := x"12345678";
    REGIO_USE_1WIRE_INTERFACE    : integer := c_YES; --c_YES,c_NO,c_MONITOR
    REGIO_USE_VAR_ENDPOINT_ID    : integer range c_NO to c_YES := c_NO;
    CLOCK_FREQUENCY              : integer range 1 to 200 := 100
    );


  port(
    --  Misc
    CLK                          : in std_logic;
    RESET                        : in std_logic;
    CLK_EN                       : in std_logic := '1';

    --  Media direction port
    MED_DATAREADY_OUT            : out std_logic;
    MED_DATA_OUT                 : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT           : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    MED_READ_IN                  : in  std_logic;
    MED_DATAREADY_IN             : in  std_logic;
    MED_DATA_IN                  : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN            : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    MED_READ_OUT                 : out std_logic;
    MED_STAT_OP_IN               : in  std_logic_vector(15 downto 0);
    MED_CTRL_OP_OUT              : out std_logic_vector(15 downto 0);

    -- LVL1 trigger APL
    TRG_TIMING_TRG_RECEIVED_IN   : in  std_logic;    --strobe when timing trigger received or real timing trigger signal

    LVL1_TRG_DATA_VALID_OUT      : out std_logic;    --trigger type, number, code, information are valid
    LVL1_TRG_VALID_TIMING_OUT    : out std_logic;    --valid timing trigger has been received
    LVL1_TRG_VALID_NOTIMING_OUT  : out std_logic;    --valid trigger without timing trigger has been received
    LVL1_TRG_INVALID_OUT         : out std_logic;    --the current trigger is invalid (e.g. no timing trigger, no LVL1...)

    LVL1_TRG_TYPE_OUT            : out std_logic_vector(3 downto 0);
    LVL1_TRG_NUMBER_OUT          : out std_logic_vector(15 downto 0);
    LVL1_TRG_CODE_OUT            : out std_logic_vector(7 downto 0);
    LVL1_TRG_INFORMATION_OUT     : out std_logic_vector(23 downto 0);

    LVL1_ERROR_PATTERN_IN        : in  std_logic_vector(31 downto 0) := x"00000000";
    LVL1_TRG_RELEASE_IN          : in  std_logic := '0';
    LVL1_INT_TRG_NUMBER_OUT      : out std_logic_vector(15 downto 0);  --internally generated trigger number, for informational uses only

    --Information about trigger handler errors
    TRG_MULTIPLE_TRG_OUT         : out std_logic;
    TRG_TIMEOUT_DETECTED_OUT     : out std_logic;
    TRG_SPURIOUS_TRG_OUT         : out std_logic;
    TRG_MISSING_TMG_TRG_OUT      : out std_logic;
    TRG_SPIKE_DETECTED_OUT       : out std_logic;
    TRG_LONG_TRG_OUT             : out std_logic;

    --Data Port
    IPU_NUMBER_OUT               : out std_logic_vector (15 downto 0);
    IPU_READOUT_TYPE_OUT         : out std_logic_vector (3 downto 0);
    IPU_INFORMATION_OUT          : out std_logic_vector (7 downto 0);
    --start strobe
    IPU_START_READOUT_OUT        : out std_logic;
    --detector data, equipped with DHDR
    IPU_DATA_IN                  : in  std_logic_vector (31 downto 0);
    IPU_DATAREADY_IN             : in  std_logic;
    --no more data, end transfer, send TRM
    IPU_READOUT_FINISHED_IN      : in  std_logic;
    --will be low every second cycle due to 32bit -> 16bit conversion
    IPU_READ_OUT                 : out std_logic;
    IPU_LENGTH_IN                : in  std_logic_vector (15 downto 0);
    IPU_ERROR_PATTERN_IN         : in  std_logic_vector (31 downto 0);


    -- Slow Control Data Port
    REGIO_COMMON_STAT_REG_IN  : in  std_logic_vector(std_COMSTATREG*32-1 downto 0) := (others => '0');
    REGIO_COMMON_CTRL_REG_OUT : out std_logic_vector(std_COMCTRLREG*32-1 downto 0);
    REGIO_REGISTERS_IN        : in  std_logic_vector(32*2**(REGIO_NUM_STAT_REGS)-1 downto 0) := (others => '0');
    REGIO_REGISTERS_OUT       : out std_logic_vector(32*2**(REGIO_NUM_CTRL_REGS)-1 downto 0);
    COMMON_STAT_REG_STROBE    : out std_logic_vector(std_COMSTATREG-1 downto 0);
    COMMON_CTRL_REG_STROBE    : out std_logic_vector(std_COMCTRLREG-1 downto 0);
    STAT_REG_STROBE           : out std_logic_vector(2**(REGIO_NUM_STAT_REGS)-1 downto 0);
    CTRL_REG_STROBE           : out std_logic_vector(2**(REGIO_NUM_CTRL_REGS)-1 downto 0);
    --following ports only used when using internal data port
    REGIO_ADDR_OUT            : out std_logic_vector(16-1 downto 0);
    REGIO_READ_ENABLE_OUT     : out std_logic;
    REGIO_WRITE_ENABLE_OUT    : out std_logic;
    REGIO_DATA_OUT            : out std_logic_vector(32-1 downto 0);
    REGIO_DATA_IN             : in  std_logic_vector(32-1 downto 0) := (others => '0');
    REGIO_DATAREADY_IN        : in  std_logic := '0';
    REGIO_NO_MORE_DATA_IN     : in  std_logic := '0';
    REGIO_WRITE_ACK_IN        : in  std_logic := '0';
    REGIO_UNKNOWN_ADDR_IN     : in  std_logic := '0';
    REGIO_TIMEOUT_OUT         : out std_logic;
    --IDRAM is used if no 1-wire interface, onewire used otherwise
    REGIO_IDRAM_DATA_IN       : in  std_logic_vector(15 downto 0) := (others => '0');
    REGIO_IDRAM_DATA_OUT      : out std_logic_vector(15 downto 0);
    REGIO_IDRAM_ADDR_IN       : in  std_logic_vector(2 downto 0) := "000";
    REGIO_IDRAM_WR_IN         : in  std_logic := '0';
    REGIO_ONEWIRE_INOUT       : inout std_logic;  --temperature sensor
    REGIO_ONEWIRE_MONITOR_IN  : in  std_logic := '0';
    REGIO_ONEWIRE_MONITOR_OUT : out std_logic;
    REGIO_VAR_ENDPOINT_ID     : in  std_logic_vector(15 downto 0) := (others => '0');

    GLOBAL_TIME_OUT           : out std_logic_vector(31 downto 0); --global time, microseconds
    LOCAL_TIME_OUT            : out std_logic_vector(7 downto 0);  --local time running with chip frequency
    TIME_SINCE_LAST_TRG_OUT   : out std_logic_vector(31 downto 0); --local time, resetted with each trigger
    TIMER_TICKS_OUT           : out std_logic_vector(1 downto 0);  --bit 1 ms-tick, 0 us-tick
    --Debugging & Status information
    STAT_DEBUG_IPU            : out std_logic_vector (31 downto 0);
    STAT_DEBUG_1              : out std_logic_vector (31 downto 0);
    STAT_DEBUG_2              : out std_logic_vector (31 downto 0);
    MED_STAT_OP               : out std_logic_vector (15 downto 0);
    CTRL_MPLEX                : in  std_logic_vector (31 downto 0) := (others => '0');
    IOBUF_CTRL_GEN            : in  std_logic_vector (4*32-1 downto 0) := (others => '0');
    STAT_ONEWIRE              : out std_logic_vector (31 downto 0);
    STAT_ADDR_DEBUG           : out std_logic_vector (15 downto 0);
    STAT_TRIGGER_OUT          : out std_logic_vector (79 downto 0);
    DEBUG_LVL1_HANDLER_OUT    : out std_logic_vector (15 downto 0)
    );
end component;

component trb_net16_endpoint_active_4_channel is

  generic (
    IBUF_DEPTH              : integer range 0 to 6 := 6;--c_FIFO_BRAM;
    FIFO_TO_INT_DEPTH       : integer range 0 to 6 := 6;--c_FIFO_SMALL;
    FIFO_TO_APL_DEPTH       : integer range 0 to 6 := 6;--c_FIFO_SMALL;
    SBUF_VERSION            : integer range 0 to 1 := c_SBUF_FULL;
    IBUF_SECURE_MODE        : integer range 0 to 1 := c_SECURE_MODE;
    API_SECURE_MODE_TO_APL  : integer range 0 to 1 := c_NON_SECURE_MODE;
    API_SECURE_MODE_TO_INT  : integer range 0 to 1 := c_SECURE_MODE;
    OBUF_DATA_COUNT_WIDTH   : integer range 0 to 7 := std_DATA_COUNT_WIDTH;
    INIT_CAN_SEND_DATA      : integer range 0 to 1 := c_YES;
    REPLY_CAN_SEND_DATA     : integer range 0 to 1 := c_YES;
    REPLY_CAN_RECEIVE_DATA  : integer range 0 to 1 := c_YES;
    USE_CHECKSUM            : integer range 0 to 1 := c_YES
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
    MED_STAT_OP_IN     : in  std_logic_vector (15 downto 0);
    MED_CTRL_OP_OUT    : out std_logic_vector (15 downto 0);

    -- APL Transmitter port
    APL_DATA_IN           : in  std_logic_vector ((2**(c_MUX_WIDTH-1))*c_DATA_WIDTH-1 downto 0);
    APL_PACKET_NUM_IN     : in  std_logic_vector ((2**(c_MUX_WIDTH-1))*c_NUM_WIDTH-1 downto 0);
    APL_DATAREADY_IN      : in  std_logic_vector ((2**(c_MUX_WIDTH-1))-1 downto 0);
    APL_READ_OUT          : out std_logic_vector ((2**(c_MUX_WIDTH-1))-1 downto 0);
    APL_SHORT_TRANSFER_IN : in  std_logic_vector ((2**(c_MUX_WIDTH-1))-1 downto 0);
    APL_DTYPE_IN          : in  std_logic_vector ((2**(c_MUX_WIDTH-1))*4-1 downto 0);
    APL_ERROR_PATTERN_IN  : in  std_logic_vector ((2**(c_MUX_WIDTH-1))*32-1 downto 0);
    APL_SEND_IN           : in  std_logic_vector ((2**(c_MUX_WIDTH-1))-1 downto 0);
    APL_TARGET_ADDRESS_IN : in  std_logic_vector ((2**(c_MUX_WIDTH-1))*16-1 downto 0);

    -- Receiver port
    APL_DATA_OUT          : out std_logic_vector ((2**(c_MUX_WIDTH-1))*c_DATA_WIDTH-1 downto 0);
    APL_PACKET_NUM_OUT    : out std_logic_vector ((2**(c_MUX_WIDTH-1))*c_NUM_WIDTH-1 downto 0);
    APL_TYP_OUT           : out std_logic_vector ((2**(c_MUX_WIDTH-1))*3-1 downto 0);
    APL_DATAREADY_OUT     : out std_logic_vector ((2**(c_MUX_WIDTH-1))-1 downto 0);
    APL_READ_IN           : in  std_logic_vector ((2**(c_MUX_WIDTH-1))-1 downto 0);

    -- APL Control port
    APL_RUN_OUT           : out std_logic_vector ((2**(c_MUX_WIDTH-1))-1 downto 0);
    APL_MY_ADDRESS_IN     : in  std_logic_vector (15 downto 0);
    APL_SEQNR_OUT         : out std_logic_vector ((2**(c_MUX_WIDTH-1))*8-1 downto 0);
    APL_LENGTH_IN         : in  std_logic_vector ((2**(c_MUX_WIDTH-1))*16-1 downto 0);

    -- Status and control port
    STAT_DEBUG            : out std_logic_vector (63 downto 0);
    MPLEX_CTRL            : in  std_logic_vector (31 downto 0);
    CTRL_GEN              : in  std_logic_vector ((2**(c_MUX_WIDTH-1))*32-1 downto 0)
    );
end component;

constant POINT_NUMBER : integer := 4;
type cmd_arr is array (0 to 3) of std_logic_vector(15 downto 0);
type num_arr is array (0 to 4) of std_logic_vector(2 downto 0);
constant initcommands : cmd_arr := (x"0000",x"8100",x"0000",x"0000");

  signal blocked   : std_logic := '0';
  signal ms_tick   : std_logic := '0';
  signal us_tick   : std_logic := '0';
  signal CLK       : std_logic := '1';
  signal RESET     : std_logic := '1';

  signal bMED_DATAREADY_IN     : std_logic_vector (POINT_NUMBER-1 downto 0);
  signal bMED_DATA_IN          : std_logic_vector (16*POINT_NUMBER-1 downto 0);
  signal bMED_PACKET_NUM_IN    : std_logic_vector (3*POINT_NUMBER-1 downto 0);
  
  
  signal MED_DATAREADY_IN     : std_logic_vector (POINT_NUMBER-1 downto 0);
  signal MED_DATA_IN          : std_logic_vector (16*POINT_NUMBER-1 downto 0);
  signal MED_PACKET_NUM_IN    : std_logic_vector (3*POINT_NUMBER-1 downto 0);
  signal MED_READ_OUT         : std_logic_vector (POINT_NUMBER-1 downto 0);
  signal MED_DATAREADY_OUT    : std_logic_vector (POINT_NUMBER-1 downto 0);
  signal MED_DATA_OUT         : std_logic_vector (16*POINT_NUMBER-1 downto 0);
  signal MED_PACKET_NUM_OUT   : std_logic_vector (3*POINT_NUMBER-1 downto 0);
  signal MED_READ_IN          : std_logic_vector (POINT_NUMBER-1 downto 0);
  signal MED_STAT_OP          : std_logic_vector (POINT_NUMBER*16-1 downto 0);
  signal MED_CTRL_OP          : std_logic_vector (POINT_NUMBER*16-1 downto 0);

  signal apl_data_i       : std_logic_vector(63 downto 0);
  signal apl_packet_num_i : std_logic_vector(11 downto 0);
  signal apl_dataready_i  : std_logic_vector(3 downto 0);
  signal apl_read_i       : std_logic_vector(3 downto 0);
  signal apl_send_i       : std_logic_vector(3 downto 0);
  signal apl_run_out_i    : std_logic_vector(3 downto 0);
  
  signal regio_read       : std_logic_vector(3 downto 0);
begin

  CLK <= not CLK after 5 ns;
  RESET <= '0' after 102 ns;

  SEND_INIT_PROC : process begin
    apl_dataready_i             <= (others => '0');
    apl_data_i                  <= (others => '0');
    apl_packet_num_i            <= (others => '0');
    apl_send_i                  <= (others => '0');

    wait for 1 us;
    if apl_run_out_i(3) = '1' then
      wait until apl_run_out_i(3) = '0';
    end if;
    wait for 5 us;
    wait until rising_edge(CLK); wait for 1 ns;
    send_cmd : for i in 0 to initcommands'length-1 loop
      apl_dataready_i(3)            <= '1';
      apl_data_i(63 downto 48)      <= initcommands(i);
      wait until rising_edge(CLK) and apl_read_i(3) = '1'; wait for 1 ns;
      apl_dataready_i(3)            <= '0';
    end loop;
    apl_send_i(3)     <= '1';
    wait until rising_edge(CLK); wait for 1 ns;
    apl_send_i(3)     <= '0';
  end process;
  


  
  THE_ACTIVE : trb_net16_endpoint_active_4_channel
  port map(
    CLK    => CLK,
    RESET  => RESET,
    CLK_EN => '1',
    MED_DATAREADY_OUT            => MED_DATAREADY_IN(1),
    MED_DATA_OUT                 => MED_DATA_IN(31 downto 16),
    MED_PACKET_NUM_OUT           => MED_PACKET_NUM_IN(5 downto 3),
    MED_READ_IN                  => MED_READ_OUT(1),
    MED_DATAREADY_IN             => MED_DATAREADY_OUT(1),
    MED_DATA_IN                  => MED_DATA_OUT(31 downto 16),
    MED_PACKET_NUM_IN            => MED_PACKET_NUM_OUT(5 downto 3),
    MED_READ_OUT                 => MED_READ_IN(1),
    MED_STAT_OP_IN               => (others => '0'),
    MED_CTRL_OP_OUT              => open,
    APL_DATA_IN           => apl_data_i,
    APL_PACKET_NUM_IN     => apl_packet_num_i,
    APL_DATAREADY_IN      => apl_dataready_i,
    APL_READ_OUT          => apl_read_i,
    APL_SHORT_TRANSFER_IN => (others => '0'),
    APL_DTYPE_IN          => x"8000",
    APL_ERROR_PATTERN_IN  => (others => '0'),
    APL_SEND_IN           => apl_send_i,
    APL_TARGET_ADDRESS_IN => x"f401f001f001f001",--(others => '1'), --x"f001f001f001f001",
    APL_DATA_OUT          => open,
    APL_PACKET_NUM_OUT    => open,
    APL_TYP_OUT           => open,
    APL_DATAREADY_OUT     => open,
    APL_READ_IN           => (others => '1'),
    APL_RUN_OUT           => apl_run_out_i,
    APL_MY_ADDRESS_IN     => x"F00A",
    APL_SEQNR_OUT         => open,
    APL_LENGTH_IN         => (others => '0'),
    STAT_DEBUG            => open,
    MPLEX_CTRL            => (others => '0'),
    CTRL_GEN              => (others => '0')
    );

  
  THE_HUB : trb_net16_hub_base
  generic map(
    MII_NUMBER              => POINT_NUMBER,
    RESET_IOBUF_AT_TIMEOUT  => c_YES,
    CLOCK_FREQUENCY         => 3,
    INIT_CTRL_REGS          =>
                                         x"00000000_00000000_00000000_00000000" &
                                         x"00000000_00000000_00000000_00000000" &
                                         x"00000000_00000000_003e1000_00000000" &
                                         x"FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF"    
    )
  port map(
    CLK    => CLK,
    RESET  => RESET,
    CLK_EN => '1',

    --Media interfacces
    MED_DATAREADY_OUT         => MED_DATAREADY_OUT,
    MED_DATA_OUT              => MED_DATA_OUT,
    MED_PACKET_NUM_OUT        => MED_PACKET_NUM_OUT,
    MED_READ_IN               => MED_READ_IN,
    MED_DATAREADY_IN          => MED_DATAREADY_IN,
    MED_DATA_IN               => MED_DATA_IN,
    MED_PACKET_NUM_IN         => MED_PACKET_NUM_IN,
    MED_READ_OUT              => MED_READ_OUT,
    MED_STAT_OP               => MED_STAT_OP,--(others => '0'),
    MED_CTRL_OP               => MED_CTRL_OP,
    --INT: interfaces to connect APIs
    INT_INIT_DATAREADY_OUT    => open,
    INT_INIT_DATA_OUT         => open,
    INT_INIT_PACKET_NUM_OUT   => open,
    INT_INIT_READ_IN          => (others => '0'),
    INT_INIT_DATAREADY_IN     => (others => '0'),
    INT_INIT_DATA_IN          => (others => '0'),
    INT_INIT_PACKET_NUM_IN    => (others => '0'),
    INT_INIT_READ_OUT         => open,
    INT_REPLY_DATAREADY_OUT   => open,
    INT_REPLY_DATA_OUT        => open,
    INT_REPLY_PACKET_NUM_OUT  => open,
    INT_REPLY_READ_IN         => (others => '0'),
    INT_REPLY_DATAREADY_IN    => (others => '0'),
    INT_REPLY_DATA_IN         => (others => '0'),
    INT_REPLY_PACKET_NUM_IN   => (others => '0'),
    INT_REPLY_READ_OUT        => open,
    ONEWIRE                   => open,
    ONEWIRE_MONITOR_IN        => '0',
    ONEWIRE_MONITOR_OUT       => open,
    COMMON_STAT_REGS          => (others => '0'),
    COMMON_CTRL_REGS          => open,
    MY_ADDRESS_OUT            => open,
    --REGIO INTERFACE
    REGIO_ADDR_OUT            => open,
    REGIO_READ_ENABLE_OUT     => open,
    REGIO_WRITE_ENABLE_OUT    => open,
    REGIO_DATA_OUT            => open,
    REGIO_DATA_IN             => (others => '0'),
    REGIO_DATAREADY_IN        => '0',
    REGIO_NO_MORE_DATA_IN     => '0',
    REGIO_WRITE_ACK_IN        => '0',
    REGIO_UNKNOWN_ADDR_IN     => '0',
    REGIO_TIMEOUT_OUT         => open,
    REGIO_VAR_ENDPOINT_ID     => (others => '0'),
    TIMER_TICKS_OUT           => open,
    HUB_LED_OUT               => open,
    UNIQUE_ID_OUT             => open,
    --Fixed status and control ports
    HUB_STAT_CHANNEL          => open,
    HUB_STAT_GEN              => open,
    MPLEX_CTRL                => (others => '0'),
    MPLEX_STAT                => open,
    STAT_REGS                 => open,
    STAT_CTRL_REGS            => open,
    IOBUF_STAT_INIT_OBUF_DEBUG  => open,
    IOBUF_STAT_REPLY_OBUF_DEBUG => open,
    --Debugging registers
    STAT_DEBUG                  => open,
    CTRL_DEBUG                  => (others => '0')
    );


THE_ENDP_0 : trb_net16_endpoint_hades_full
  generic map(
    REGIO_INIT_ADDRESS           => x"F000",
    BROADCAST_BITMASK            => x"00",
    REGIO_NUM_STAT_REGS          => 1
    )
  port map(
    CLK             => CLK,
    RESET           => RESET,
    CLK_EN          => '1',
    MED_DATAREADY_OUT            => bMED_DATAREADY_IN(0),
    MED_DATA_OUT                 => bMED_DATA_IN(15 downto 0),
    MED_PACKET_NUM_OUT           => bMED_PACKET_NUM_IN(2 downto 0),
    MED_READ_IN                  => MED_READ_OUT(0),
    MED_DATAREADY_IN             => MED_DATAREADY_OUT(0),
    MED_DATA_IN                  => MED_DATA_OUT(15 downto 0),
    MED_PACKET_NUM_IN            => MED_PACKET_NUM_OUT(2 downto 0),
    MED_READ_OUT                 => MED_READ_IN(0),
    MED_STAT_OP_IN               => (others => '0'),
    MED_CTRL_OP_OUT              => open,
    TRG_TIMING_TRG_RECEIVED_IN   => '0',
    LVL1_TRG_DATA_VALID_OUT      => open,
    LVL1_TRG_VALID_TIMING_OUT    => open,
    LVL1_TRG_VALID_NOTIMING_OUT  => open,
    LVL1_TRG_INVALID_OUT         => open,
    LVL1_TRG_TYPE_OUT            => open,
    LVL1_TRG_NUMBER_OUT          => open,
    LVL1_TRG_CODE_OUT            => open,
    LVL1_TRG_INFORMATION_OUT     => open,
    LVL1_ERROR_PATTERN_IN        => x"00000000",
    LVL1_TRG_RELEASE_IN          => '0',
    LVL1_INT_TRG_NUMBER_OUT      => open,
    TRG_MULTIPLE_TRG_OUT         => open,
    TRG_TIMEOUT_DETECTED_OUT     => open,
    TRG_SPURIOUS_TRG_OUT         => open,
    TRG_MISSING_TMG_TRG_OUT      => open,
    TRG_SPIKE_DETECTED_OUT       => open,
    TRG_LONG_TRG_OUT             => open,
    IPU_NUMBER_OUT               => open,
    IPU_READOUT_TYPE_OUT         => open,
    IPU_INFORMATION_OUT          => open,
    IPU_START_READOUT_OUT        => open,
    IPU_DATA_IN                  => x"00000000",
    IPU_DATAREADY_IN             => '0',
    IPU_READOUT_FINISHED_IN      => '0',
    IPU_READ_OUT                 => open,
    IPU_LENGTH_IN                => (others => '0'),
    IPU_ERROR_PATTERN_IN         => (others => '0'),
    REGIO_COMMON_STAT_REG_IN     => (others => '0'),
    REGIO_COMMON_CTRL_REG_OUT    => open,
    REGIO_REGISTERS_IN           => x"0a0eface0ea0affe",
    REGIO_REGISTERS_OUT          => open,
    COMMON_STAT_REG_STROBE       => open,
    COMMON_CTRL_REG_STROBE       => open,
    STAT_REG_STROBE              => open,
    CTRL_REG_STROBE              => open,
    REGIO_ADDR_OUT               => open,
    REGIO_READ_ENABLE_OUT        => regio_read(0),
    REGIO_WRITE_ENABLE_OUT       => open,
    REGIO_DATA_OUT               => open,
    REGIO_DATA_IN                => (others => '0'),
    REGIO_DATAREADY_IN           => regio_read(0),
    REGIO_NO_MORE_DATA_IN        => '0',
    REGIO_WRITE_ACK_IN           => '0',
    REGIO_UNKNOWN_ADDR_IN        => '0',
    REGIO_TIMEOUT_OUT            => open,
    REGIO_IDRAM_DATA_IN          => (others => '0'),
    REGIO_IDRAM_DATA_OUT         => open,
    REGIO_IDRAM_ADDR_IN          => "000",
    REGIO_IDRAM_WR_IN            => '0',
    REGIO_ONEWIRE_INOUT          => open,
    REGIO_ONEWIRE_MONITOR_IN     => '0',
    REGIO_ONEWIRE_MONITOR_OUT    => open,
    REGIO_VAR_ENDPOINT_ID        => (others => '0'),
    GLOBAL_TIME_OUT              => open,
    LOCAL_TIME_OUT               => open,
    TIME_SINCE_LAST_TRG_OUT      => open,
    TIMER_TICKS_OUT              => open,
    STAT_DEBUG_IPU               => open,
    STAT_DEBUG_1                 => open,
    STAT_DEBUG_2                 => open,
    MED_STAT_OP                  => open,
    CTRL_MPLEX                   => (others => '0'),
    IOBUF_CTRL_GEN               => (others => '0'),
    STAT_ONEWIRE                 => open,
    STAT_ADDR_DEBUG              => open,
    STAT_TRIGGER_OUT             => open,
    DEBUG_LVL1_HANDLER_OUT       => open
    );
    
THE_ENDP_2 : trb_net16_endpoint_hades_full
  generic map(
    REGIO_NUM_STAT_REGS          => 1,
    BROADCAST_BITMASK            => x"00",
    REGIO_INIT_ADDRESS           => x"F002"
    )
  port map(
    CLK             => CLK,
    RESET           => RESET,
    CLK_EN          => '1',
    MED_DATAREADY_OUT            => bMED_DATAREADY_IN(2),
    MED_DATA_OUT                 => bMED_DATA_IN(47 downto 32),
    MED_PACKET_NUM_OUT           => bMED_PACKET_NUM_IN(8 downto 6),
    MED_READ_IN                  => MED_READ_OUT(2),
    MED_DATAREADY_IN             => MED_DATAREADY_OUT(2),
    MED_DATA_IN                  => MED_DATA_OUT(47 downto 32),
    MED_PACKET_NUM_IN            => MED_PACKET_NUM_OUT(8 downto 6),
    MED_READ_OUT                 => MED_READ_IN(2),
    MED_STAT_OP_IN               => (others => '0'),
    MED_CTRL_OP_OUT              => open,
    TRG_TIMING_TRG_RECEIVED_IN   => '0',
    LVL1_TRG_DATA_VALID_OUT      => open,
    LVL1_TRG_VALID_TIMING_OUT    => open,
    LVL1_TRG_VALID_NOTIMING_OUT  => open,
    LVL1_TRG_INVALID_OUT         => open,
    LVL1_TRG_TYPE_OUT            => open,
    LVL1_TRG_NUMBER_OUT          => open,
    LVL1_TRG_CODE_OUT            => open,
    LVL1_TRG_INFORMATION_OUT     => open,
    LVL1_ERROR_PATTERN_IN        => x"00000000",
    LVL1_TRG_RELEASE_IN          => '0',
    LVL1_INT_TRG_NUMBER_OUT      => open,
    TRG_MULTIPLE_TRG_OUT         => open,
    TRG_TIMEOUT_DETECTED_OUT     => open,
    TRG_SPURIOUS_TRG_OUT         => open,
    TRG_MISSING_TMG_TRG_OUT      => open,
    TRG_SPIKE_DETECTED_OUT       => open,
    TRG_LONG_TRG_OUT             => open,
    IPU_NUMBER_OUT               => open,
    IPU_READOUT_TYPE_OUT         => open,
    IPU_INFORMATION_OUT          => open,
    IPU_START_READOUT_OUT        => open,
    IPU_DATA_IN                  => x"00000000",
    IPU_DATAREADY_IN             => '0',
    IPU_READOUT_FINISHED_IN      => '0',
    IPU_READ_OUT                 => open,
    IPU_LENGTH_IN                => (others => '0'),
    IPU_ERROR_PATTERN_IN         => (others => '0'),
    REGIO_COMMON_STAT_REG_IN     => (others => '0'),
    REGIO_COMMON_CTRL_REG_OUT    => open,
    REGIO_REGISTERS_IN           => x"b2bef2cede2d2ffe",
    REGIO_REGISTERS_OUT          => open,
    COMMON_STAT_REG_STROBE       => open,
    COMMON_CTRL_REG_STROBE       => open,
    STAT_REG_STROBE              => open,
    CTRL_REG_STROBE              => open,
    REGIO_ADDR_OUT               => open,
    REGIO_READ_ENABLE_OUT        => regio_read(2),
    REGIO_WRITE_ENABLE_OUT       => open,
    REGIO_DATA_OUT               => open,
    REGIO_DATA_IN                => (others => '0'),
    REGIO_DATAREADY_IN           => regio_read(2),
    REGIO_NO_MORE_DATA_IN        => '0',
    REGIO_WRITE_ACK_IN           => '0',
    REGIO_UNKNOWN_ADDR_IN        => '0',
    REGIO_TIMEOUT_OUT            => open,
    REGIO_IDRAM_DATA_IN          => (others => '0'),
    REGIO_IDRAM_DATA_OUT         => open,
    REGIO_IDRAM_ADDR_IN          => "000",
    REGIO_IDRAM_WR_IN            => '0',
    REGIO_ONEWIRE_INOUT          => open,
    REGIO_ONEWIRE_MONITOR_IN     => '0',
    REGIO_ONEWIRE_MONITOR_OUT    => open,
    REGIO_VAR_ENDPOINT_ID        => (others => '0'),
    GLOBAL_TIME_OUT              => open,
    LOCAL_TIME_OUT               => open,
    TIME_SINCE_LAST_TRG_OUT      => open,
    TIMER_TICKS_OUT              => open,
    STAT_DEBUG_IPU               => open,
    STAT_DEBUG_1                 => open,
    STAT_DEBUG_2                 => open,
    MED_STAT_OP                  => open,
    CTRL_MPLEX                   => (others => '0'),
    IOBUF_CTRL_GEN               => (others => '0'),
    STAT_ONEWIRE                 => open,
    STAT_ADDR_DEBUG              => open,
    STAT_TRIGGER_OUT             => open,
    DEBUG_LVL1_HANDLER_OUT       => open
    );
        
    
THE_ENDP_3 : trb_net16_endpoint_hades_full
  generic map(
    REGIO_NUM_STAT_REGS          => 1,
    BROADCAST_BITMASK            => x"00",
    REGIO_INIT_ADDRESS           => x"F003"
    )
  port map(
    CLK             => CLK,
    RESET           => RESET,
    CLK_EN          => '1',
    MED_DATAREADY_OUT            => bMED_DATAREADY_IN(3),
    MED_DATA_OUT                 => bMED_DATA_IN(63 downto 48),
    MED_PACKET_NUM_OUT           => bMED_PACKET_NUM_IN(11 downto 9),
    MED_READ_IN                  => MED_READ_OUT(3),
    MED_DATAREADY_IN             => MED_DATAREADY_OUT(3),
    MED_DATA_IN                  => MED_DATA_OUT(63 downto 48),
    MED_PACKET_NUM_IN            => MED_PACKET_NUM_OUT(11 downto 9),
    MED_READ_OUT                 => MED_READ_IN(3),
    MED_STAT_OP_IN               => (others => '0'),
    MED_CTRL_OP_OUT              => open,
    TRG_TIMING_TRG_RECEIVED_IN   => '0',
    LVL1_TRG_DATA_VALID_OUT      => open,
    LVL1_TRG_VALID_TIMING_OUT    => open,
    LVL1_TRG_VALID_NOTIMING_OUT  => open,
    LVL1_TRG_INVALID_OUT         => open,
    LVL1_TRG_TYPE_OUT            => open,
    LVL1_TRG_NUMBER_OUT          => open,
    LVL1_TRG_CODE_OUT            => open,
    LVL1_TRG_INFORMATION_OUT     => open,
    LVL1_ERROR_PATTERN_IN        => x"00000000",
    LVL1_TRG_RELEASE_IN          => '0',
    LVL1_INT_TRG_NUMBER_OUT      => open,
    TRG_MULTIPLE_TRG_OUT         => open,
    TRG_TIMEOUT_DETECTED_OUT     => open,
    TRG_SPURIOUS_TRG_OUT         => open,
    TRG_MISSING_TMG_TRG_OUT      => open,
    TRG_SPIKE_DETECTED_OUT       => open,
    TRG_LONG_TRG_OUT             => open,
    IPU_NUMBER_OUT               => open,
    IPU_READOUT_TYPE_OUT         => open,
    IPU_INFORMATION_OUT          => open,
    IPU_START_READOUT_OUT        => open,
    IPU_DATA_IN                  => x"00000000",
    IPU_DATAREADY_IN             => '0',
    IPU_READOUT_FINISHED_IN      => '0',
    IPU_READ_OUT                 => open,
    IPU_LENGTH_IN                => (others => '0'),
    IPU_ERROR_PATTERN_IN         => (others => '0'),
    REGIO_COMMON_STAT_REG_IN     => (others => '0'),
    REGIO_COMMON_CTRL_REG_OUT    => open,
    REGIO_REGISTERS_IN           => x"bab3fac3d3adaff3",
    REGIO_REGISTERS_OUT          => open,
    COMMON_STAT_REG_STROBE       => open,
    COMMON_CTRL_REG_STROBE       => open,
    STAT_REG_STROBE              => open,
    CTRL_REG_STROBE              => open,
    REGIO_ADDR_OUT               => open,
    REGIO_READ_ENABLE_OUT        => regio_read(3),
    REGIO_WRITE_ENABLE_OUT       => open,
    REGIO_DATA_OUT               => open,
    REGIO_DATA_IN                => (others => '0'),
    REGIO_DATAREADY_IN           => regio_read(3),
    REGIO_NO_MORE_DATA_IN        => '0',
    REGIO_WRITE_ACK_IN           => '0',
    REGIO_UNKNOWN_ADDR_IN        => '0',
    REGIO_TIMEOUT_OUT            => open,
    REGIO_IDRAM_DATA_IN          => (others => '0'),
    REGIO_IDRAM_DATA_OUT         => open,
    REGIO_IDRAM_ADDR_IN          => "000",
    REGIO_IDRAM_WR_IN            => '0',
    REGIO_ONEWIRE_INOUT          => open,
    REGIO_ONEWIRE_MONITOR_IN     => '0',
    REGIO_ONEWIRE_MONITOR_OUT    => open,
    REGIO_VAR_ENDPOINT_ID        => (others => '0'),
    GLOBAL_TIME_OUT              => open,
    LOCAL_TIME_OUT               => open,
    TIME_SINCE_LAST_TRG_OUT      => open,
    TIMER_TICKS_OUT              => open,
    STAT_DEBUG_IPU               => open,
    STAT_DEBUG_1                 => open,
    STAT_DEBUG_2                 => open,
    MED_STAT_OP                  => open,
    CTRL_MPLEX                   => (others => '0'),
    IOBUF_CTRL_GEN               => (others => '0'),
    STAT_ONEWIRE                 => open,
    STAT_ADDR_DEBUG              => open,
    STAT_TRIGGER_OUT             => open,
    DEBUG_LVL1_HANDLER_OUT       => open
    );

MED_DATAREADY_IN(3) <= transport bMED_DATAREADY_IN(3) after 499 ns;
MED_DATA_IN(63 downto 48)<=    transport bMED_DATA_IN(63 downto 48) after 499 ns;
MED_PACKET_NUM_IN(11 downto 9) <= transport bMED_PACKET_NUM_IN(11 downto 9) after 499 ns;

MED_DATAREADY_IN(2) <= transport bMED_DATAREADY_IN(2) after 499 ns;
MED_DATA_IN(47 downto 32)<=    transport bMED_DATA_IN(47 downto 32) after 499 ns;
MED_PACKET_NUM_IN(8 downto 6) <= transport bMED_PACKET_NUM_IN(8 downto 6) after 499 ns;

blocked <= '0', '1' after 12200 ns, '0' after 1014000 ns;
MED_DATAREADY_IN(0) <= transport bMED_DATAREADY_IN(0) and not blocked after 799 ns;
MED_DATA_IN(15 downto 0)<=    transport bMED_DATA_IN(15 downto 0) after 799 ns;
MED_PACKET_NUM_IN(2 downto 0) <= transport bMED_PACKET_NUM_IN(2 downto 0) after 799 ns;

MED_STAT_OP <= x"0000000000000000"; --, x"0000000000004003" after 13000 ns, 
                                    --x"0000000000000003" after 89600 ns, 
                                    --x"0000000000000000" after 102200 ns;

end architecture;


