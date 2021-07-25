-- the full endpoint for HADES: trg, data, unused, regio including data buffer & handling

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;


entity trb_net16_endpoint_hades_full_handler is
  generic (
    IBUF_DEPTH                   : channel_config_t              := (6,6,6,6);
    FIFO_TO_INT_DEPTH            : channel_config_t              := (6,6,6,6);
    FIFO_TO_APL_DEPTH            : channel_config_t              := (1,1,1,1);
    APL_WRITE_ALL_WORDS          : channel_config_t              := (c_NO,c_NO,c_NO,c_NO);
    ADDRESS_MASK                 : std_logic_vector(15 downto 0) := x"FFFF";
    BROADCAST_BITMASK            : std_logic_vector(7 downto 0)  := x"FF";
    BROADCAST_SPECIAL_ADDR       : std_logic_vector(7 downto 0)  := x"FF";
    REGIO_NUM_STAT_REGS          : integer range 0 to 6          := 3; --log2 of number of status registers
    REGIO_NUM_CTRL_REGS          : integer range 0 to 6          := 3; --log2 of number of ctrl registers
    REGIO_INIT_CTRL_REGS         : std_logic_vector(16*32-1 downto 0) := (others => '0');
    REGIO_INIT_ADDRESS           : std_logic_vector(15 downto 0) := x"FFFF";
    REGIO_INIT_BOARD_INFO        : std_logic_vector(31 downto 0) := x"1111_2222";
    REGIO_INIT_ENDPOINT_ID       : std_logic_vector(15 downto 0) := x"0001";
    REGIO_COMPILE_TIME           : std_logic_vector(31 downto 0) := x"00000000";
    REGIO_INCLUDED_FEATURES      : std_logic_vector(63 downto 0) := (others => '0');
    REGIO_HARDWARE_VERSION       : std_logic_vector(31 downto 0) := x"12345678";
    REGIO_USE_1WIRE_INTERFACE    : integer := c_YES; --c_YES,c_NO,c_MONITOR
    REGIO_USE_VAR_ENDPOINT_ID    : integer range c_NO to c_YES   := c_NO;
    CLOCK_FREQUENCY              : integer range 1 to 200        := 100;
    TIMING_TRIGGER_RAW           : integer range 0 to 1 := c_YES;
    --Configure data handler
    DATA_INTERFACE_NUMBER        : integer range 1 to 16         := 1;
    DATA_BUFFER_DEPTH            : integer range 9 to 14         := 9;
    DATA_BUFFER_WIDTH            : integer range 1 to 32         := 32;
    DATA_BUFFER_FULL_THRESH      : integer range 0 to 2**14-2    := 2**8;
    TRG_RELEASE_AFTER_DATA       : integer range 0 to 1          := c_YES;
    HEADER_BUFFER_DEPTH          : integer range 9 to 14         := 9;
    HEADER_BUFFER_FULL_THRESH    : integer range 2**8 to 2**14-2 := 2**8
    );

  port(
    --  Misc
    CLK                          : in  std_logic;
    RESET                        : in  std_logic;
    CLK_EN                       : in  std_logic := '1';

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

    --Timing trigger in
    TRG_TIMING_TRG_RECEIVED_IN   : in  std_logic;
    --LVL1 trigger to FEE
    LVL1_TRG_DATA_VALID_OUT      : out std_logic;    --trigger type, number, code, information are valid
    LVL1_VALID_TIMING_TRG_OUT    : out std_logic;    --valid timing trigger has been received
    LVL1_VALID_NOTIMING_TRG_OUT  : out std_logic;    --valid trigger without timing trigger has been received
    LVL1_INVALID_TRG_OUT         : out std_logic;    --the current trigger is invalid (e.g. no timing trigger, no LVL1...)

    LVL1_TRG_TYPE_OUT            : out std_logic_vector(3 downto 0);
    LVL1_TRG_NUMBER_OUT          : out std_logic_vector(15 downto 0);
    LVL1_TRG_CODE_OUT            : out std_logic_vector(7 downto 0);
    LVL1_TRG_INFORMATION_OUT     : out std_logic_vector(23 downto 0);
    LVL1_INT_TRG_NUMBER_OUT      : out std_logic_vector(15 downto 0);  --internally generated trigger number, for informational uses only

    --Information about trigger handler errors
    TRG_MULTIPLE_TRG_OUT         : out std_logic;
    TRG_TIMEOUT_DETECTED_OUT     : out std_logic;
    TRG_SPURIOUS_TRG_OUT         : out std_logic;
    TRG_MISSING_TMG_TRG_OUT      : out std_logic;
    TRG_SPIKE_DETECTED_OUT       : out std_logic;

    --Response from FEE
    FEE_TRG_RELEASE_IN           : in  std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
    FEE_TRG_STATUSBITS_IN        : in  std_logic_vector(DATA_INTERFACE_NUMBER*32-1 downto 0);
    FEE_DATA_IN                  : in  std_logic_vector(DATA_INTERFACE_NUMBER*32-1 downto 0);
    FEE_DATA_WRITE_IN            : in  std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
    FEE_DATA_FINISHED_IN         : in  std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
    FEE_DATA_ALMOST_FULL_OUT     : out std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);

    --Slow Control Port
    --common registers
    REGIO_COMMON_STAT_REG_IN     : in  std_logic_vector(std_COMSTATREG*32-1 downto 0) := (others => '0');
    REGIO_COMMON_CTRL_REG_OUT    : out std_logic_vector(std_COMCTRLREG*32-1 downto 0);
    REGIO_COMMON_STAT_STROBE_OUT : out std_logic_vector(std_COMSTATREG-1 downto 0);
    REGIO_COMMON_CTRL_STROBE_OUT : out std_logic_vector(std_COMCTRLREG-1 downto 0);
    --user defined registers
    REGIO_STAT_REG_IN            : in  std_logic_vector(2**(REGIO_NUM_STAT_REGS)*32-1 downto 0) := (others => '0');
    REGIO_CTRL_REG_OUT           : out std_logic_vector(2**(REGIO_NUM_CTRL_REGS)*32-1 downto 0);
    REGIO_STAT_STROBE_OUT        : out std_logic_vector(2**(REGIO_NUM_STAT_REGS)-1 downto 0);
    REGIO_CTRL_STROBE_OUT        : out std_logic_vector(2**(REGIO_NUM_CTRL_REGS)-1 downto 0);
    --internal data port
    BUS_ADDR_OUT                 : out std_logic_vector(16-1 downto 0);
    BUS_DATA_OUT                 : out std_logic_vector(32-1 downto 0);
    BUS_READ_ENABLE_OUT          : out std_logic;
    BUS_WRITE_ENABLE_OUT         : out std_logic;
    BUS_TIMEOUT_OUT              : out std_logic;
    BUS_DATA_IN                  : in  std_logic_vector(32-1 downto 0) := (others => '0');
    BUS_DATAREADY_IN             : in  std_logic                       := '0';
    BUS_WRITE_ACK_IN             : in  std_logic                       := '0';
    BUS_NO_MORE_DATA_IN          : in  std_logic                       := '0';
    BUS_UNKNOWN_ADDR_IN          : in  std_logic                       := '0';
    --Onewire
    ONEWIRE_INOUT                : inout std_logic;  --temperature sensor
    ONEWIRE_MONITOR_IN           : in  std_logic := '0';
    ONEWIRE_MONITOR_OUT          : out std_logic;
    --Config endpoint id, if not statically assigned
    REGIO_VAR_ENDPOINT_ID        : in  std_logic_vector (15 downto 0) := (others => '0');

    --Timing registers
    TIME_GLOBAL_OUT              : out std_logic_vector (31 downto 0); --global time, microseconds
    TIME_LOCAL_OUT               : out std_logic_vector ( 7 downto 0); --local time running with chip frequency
    TIME_SINCE_LAST_TRG_OUT      : out std_logic_vector (31 downto 0); --local time, resetted with each trigger
    TIME_TICKS_OUT               : out std_logic_vector ( 1 downto 0); --bit 1 ms-tick, 0 us-tick
    TEMPERATURE_OUT              : out std_logic_vector (11 downto 0);
    UNIQUE_ID_OUT                : out std_logic_vector (63 downto 0);

    --Debugging & Status information
    STAT_DEBUG_IPU               : out std_logic_vector (31 downto 0);
    STAT_DEBUG_1                 : out std_logic_vector (31 downto 0);
    STAT_DEBUG_2                 : out std_logic_vector (31 downto 0);
    STAT_DEBUG_DATA_HANDLER_OUT  : out std_logic_vector (31 downto 0);
    STAT_DEBUG_IPU_HANDLER_OUT   : out std_logic_vector (31 downto 0);
    CTRL_MPLEX                   : in  std_logic_vector (31 downto 0) := (others => '0');
    IOBUF_CTRL_GEN               : in  std_logic_vector (4*32-1 downto 0) := (others => '0');
    STAT_ONEWIRE                 : out std_logic_vector (31 downto 0);
    STAT_ADDR_DEBUG              : out std_logic_vector (15 downto 0);
    STAT_TRIGGER_OUT             : out std_logic_vector (79 downto 0);
    DEBUG_LVL1_HANDLER_OUT       : out std_logic_vector (15 downto 0)
    );
end entity;





architecture trb_net16_endpoint_hades_full_handler_arch of trb_net16_endpoint_hades_full_handler is

  signal lvl1_data_valid_i       : std_logic;
  signal lvl1_valid_i            : std_logic;
  signal lvl1_valid_timing_i     : std_logic;
  signal lvl1_valid_notiming_i   : std_logic;
  signal lvl1_invalid_i          : std_logic;
  signal lvl1_type_i             : std_logic_vector ( 3 downto 0);
  signal lvl1_number_i           : std_logic_vector (15 downto 0);
  signal lvl1_code_i             : std_logic_vector ( 7 downto 0);
  signal lvl1_information_i      : std_logic_vector (23 downto 0);
  signal lvl1_error_pattern_i    : std_logic_vector (31 downto 0);
  signal lvl1_release_i          : std_logic;
  signal lvl1_int_trg_number_i   : std_logic_vector (15 downto 0);

  signal ipu_number_i            : std_logic_vector (15 downto 0);
  signal ipu_readout_type_i      : std_logic_vector ( 3 downto 0);
  signal ipu_information_i       : std_logic_vector ( 7 downto 0);
  signal ipu_start_readout_i     : std_logic;
  signal ipu_data_i              : std_logic_vector (31 downto 0);
  signal ipu_dataready_i         : std_logic;
  signal ipu_readout_finished_i  : std_logic;
  signal ipu_read_i              : std_logic;
  signal ipu_length_i            : std_logic_vector (15 downto 0);
  signal ipu_error_pattern_i     : std_logic_vector (31 downto 0);
  signal reset_ipu_i             : std_logic;

  signal common_stat_reg_i       : std_logic_vector (std_COMSTATREG*32-1 downto 0);
  signal common_ctrl_reg_i       : std_logic_vector (std_COMCTRLREG*32-1 downto 0);
  signal common_stat_strobe_i    : std_logic_vector (std_COMSTATREG-1 downto 0);
  signal common_ctrl_strobe_i    : std_logic_vector (std_COMCTRLREG-1 downto 0);
  signal stat_reg_i              : std_logic_vector (2**(REGIO_NUM_STAT_REGS)*32-1 downto 0);
  signal ctrl_reg_i              : std_logic_vector (2**(REGIO_NUM_CTRL_REGS)*32-1 downto 0);
  signal stat_strobe_i           : std_logic_vector (2**(REGIO_NUM_STAT_REGS)-1 downto 0);
  signal ctrl_strobe_i           : std_logic_vector (2**(REGIO_NUM_CTRL_REGS)-1 downto 0);

  signal regio_addr_i            : std_logic_vector (15 downto 0);
  signal regio_read_enable_i     : std_logic;
  signal regio_write_enable_i    : std_logic;
  signal regio_data_out_i        : std_logic_vector (31 downto 0);
  signal regio_data_in_i         : std_logic_vector (31 downto 0);
  signal regio_dataready_i       : std_logic;
  signal regio_nomoredata_i      : std_logic;
  signal regio_write_ack_i       : std_logic;
  signal regio_unknown_addr_i    : std_logic;
  signal regio_timeout_i         : std_logic;

  signal time_global_i           : std_logic_vector (31 downto 0);
  signal time_local_i            : std_logic_vector ( 7 downto 0);
  signal time_since_last_trg_i   : std_logic_vector (31 downto 0);
  signal time_ticks_i            : std_logic_vector ( 1 downto 0);

  signal buf_fee_data_almost_full_out : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
  signal stat_handler_i          : std_logic_vector (127 downto 0);
  signal stat_data_buffer_level  : std_logic_vector (DATA_INTERFACE_NUMBER*32-1 downto 0);
  signal stat_header_buffer_level: std_logic_vector (31 downto 0);

  signal dbuf_read_enable        : std_logic;
  signal dbuf_addr               : std_logic_vector (15 downto 0);
  signal dbuf_data_out            : std_logic_vector (31 downto 0);
  signal dbuf_dataready          : std_logic;
  signal dbuf_unknown_addr       : std_logic;

  signal info_addr       : std_logic_vector(15 downto 0);
  signal info_data_in    : std_logic_vector(31 downto 0);
  signal info_data_out   : std_logic_vector(31 downto 0);
  signal info_read       : std_logic;
  signal info_write      : std_logic;
  signal info_rd_nack    : std_logic;
  signal info_wr_nack    : std_logic;
  signal info_wr_ack     : std_logic;
  signal info_valid      : std_logic;
  signal info_invalid    : std_logic;
  signal info_registers  : std_logic_vector_array_32(0 to 4);  

  signal stat_handler_addr       : std_logic_vector(15 downto 0);
  signal stat_handler_data_in    : std_logic_vector(31 downto 0);
  signal stat_handler_data_out   : std_logic_vector(31 downto 0);
  signal stat_handler_read       : std_logic;
  signal stat_handler_write      : std_logic;
  signal stat_handler_valid      : std_logic;
  signal stat_handler_invalid    : std_logic;
  signal stat_handler_registers  : std_logic_vector_array_32(0 to 2);  
  
  signal dummy                   : std_logic_vector(100 downto 0);

  signal debug_data_handler_i    : std_logic_vector(31 downto 0);
  signal debug_ipu_handler_i     : std_logic_vector(31 downto 0);

  signal int_multiple_trg          : std_logic;
  signal int_lvl1_timeout_detected : std_logic;
  signal int_lvl1_spurious_trg     : std_logic;
  signal int_lvl1_missing_tmg_trg  : std_logic;
  signal int_spike_detected        : std_logic;
  signal int_lvl1_long_trg         : std_logic;
  signal tmg_trg_error_i           : std_logic;

  signal stat_buffer_out           : std_logic_vector(31 downto 0);
  signal stat_buffer_read          : std_logic;
  signal stat_buffer_write         : std_logic;
  signal stat_buffer_ready         : std_logic;
  signal stat_buffer_unknown       : std_logic;
  signal stat_buffer_wr_nack       : std_logic;
  signal stat_buffer_rd_nack       : std_logic;
  signal stat_buffer_address       : std_logic_vector(15 downto 0);
  signal max_event_size            : std_logic_vector(15 downto 0);
  signal buffer_disable            : std_logic_vector(15 downto 0);
  signal new_max_size              : std_logic_vector(15 downto 0);

begin
---------------------------------------------------------------------------
-- TrbNet Endpoint
---------------------------------------------------------------------------

  THE_ENDPOINT: trb_net16_endpoint_hades_full
    generic map(
      IBUF_DEPTH                 => IBUF_DEPTH,
      FIFO_TO_INT_DEPTH          => FIFO_TO_INT_DEPTH,
      FIFO_TO_APL_DEPTH          => FIFO_TO_APL_DEPTH,
      APL_WRITE_ALL_WORDS        => APL_WRITE_ALL_WORDS,
      ADDRESS_MASK               => ADDRESS_MASK,
      BROADCAST_BITMASK          => BROADCAST_BITMASK,
      BROADCAST_SPECIAL_ADDR     => BROADCAST_SPECIAL_ADDR,
      REGIO_NUM_STAT_REGS        => REGIO_NUM_STAT_REGS,
      REGIO_NUM_CTRL_REGS        => REGIO_NUM_CTRL_REGS,
      REGIO_INIT_CTRL_REGS       => REGIO_INIT_CTRL_REGS,
      REGIO_INIT_ADDRESS         => REGIO_INIT_ADDRESS,
      REGIO_INIT_BOARD_INFO      => REGIO_INIT_BOARD_INFO,
      REGIO_INIT_ENDPOINT_ID     => REGIO_INIT_ENDPOINT_ID,
      REGIO_COMPILE_TIME         => REGIO_COMPILE_TIME,
      REGIO_INCLUDED_FEATURES    => REGIO_INCLUDED_FEATURES,
      REGIO_HARDWARE_VERSION     => REGIO_HARDWARE_VERSION,
      REGIO_USE_1WIRE_INTERFACE  => REGIO_USE_1WIRE_INTERFACE,
      REGIO_USE_VAR_ENDPOINT_ID  => REGIO_USE_VAR_ENDPOINT_ID,
      TIMING_TRIGGER_RAW         => TIMING_TRIGGER_RAW,
      CLOCK_FREQUENCY            => CLOCK_FREQUENCY
      )
    port map(
      CLK                        => CLK,
      RESET                      => RESET,
      CLK_EN                     => CLK_EN,

      MED_DATAREADY_OUT          => MED_DATAREADY_OUT,
      MED_DATA_OUT               => MED_DATA_OUT,
      MED_PACKET_NUM_OUT         => MED_PACKET_NUM_OUT,
      MED_READ_IN                => MED_READ_IN,
      MED_DATAREADY_IN           => MED_DATAREADY_IN,
      MED_DATA_IN                => MED_DATA_IN,
      MED_PACKET_NUM_IN          => MED_PACKET_NUM_IN,
      MED_READ_OUT               => MED_READ_OUT,
      MED_STAT_OP_IN             => MED_STAT_OP_IN,
      MED_CTRL_OP_OUT            => MED_CTRL_OP_OUT,

      -- LVL1 trigger APL
      TRG_TIMING_TRG_RECEIVED_IN => TRG_TIMING_TRG_RECEIVED_IN,
      LVL1_TRG_DATA_VALID_OUT    => lvl1_data_valid_i,
      LVL1_TRG_VALID_TIMING_OUT  => lvl1_valid_timing_i,
      LVL1_TRG_VALID_NOTIMING_OUT=> lvl1_valid_notiming_i,
      LVL1_TRG_INVALID_OUT       => lvl1_invalid_i,
      LVL1_TRG_TYPE_OUT          => lvl1_type_i,
      LVL1_TRG_NUMBER_OUT        => lvl1_number_i,
      LVL1_TRG_CODE_OUT          => lvl1_code_i,
      LVL1_TRG_INFORMATION_OUT   => lvl1_information_i,
      LVL1_ERROR_PATTERN_IN      => lvl1_error_pattern_i,
      LVL1_TRG_RELEASE_IN        => lvl1_release_i,
      LVL1_INT_TRG_NUMBER_OUT    => lvl1_int_trg_number_i,

      --Information about trigger handler errors
      TRG_SPIKE_DETECTED_OUT     => int_spike_detected,
      TRG_SPURIOUS_TRG_OUT       => int_lvl1_spurious_trg,
      TRG_TIMEOUT_DETECTED_OUT   => int_lvl1_timeout_detected,
      TRG_MULTIPLE_TRG_OUT       => int_multiple_trg,
      TRG_MISSING_TMG_TRG_OUT    => int_lvl1_missing_tmg_trg,
      TRG_LONG_TRG_OUT           => int_lvl1_long_trg,
      --Data Port
      IPU_NUMBER_OUT             => ipu_number_i,
      IPU_READOUT_TYPE_OUT       => ipu_readout_type_i,
      IPU_INFORMATION_OUT        => ipu_information_i,
      IPU_START_READOUT_OUT      => ipu_start_readout_i,
      IPU_DATA_IN                => ipu_data_i,
      IPU_DATAREADY_IN           => ipu_dataready_i,
      IPU_READOUT_FINISHED_IN    => ipu_readout_finished_i,
      IPU_READ_OUT               => ipu_read_i,
      IPU_LENGTH_IN              => ipu_length_i,
      IPU_ERROR_PATTERN_IN       => ipu_error_pattern_i,

      -- Slow Control Data Port
      REGIO_COMMON_STAT_REG_IN   => common_stat_reg_i,
      REGIO_COMMON_CTRL_REG_OUT  => common_ctrl_reg_i,
      REGIO_REGISTERS_IN         => stat_reg_i,
      REGIO_REGISTERS_OUT        => ctrl_reg_i,
      COMMON_STAT_REG_STROBE     => common_stat_strobe_i,
      COMMON_CTRL_REG_STROBE     => common_ctrl_strobe_i,
      STAT_REG_STROBE            => stat_strobe_i,
      CTRL_REG_STROBE            => ctrl_strobe_i,

      REGIO_ADDR_OUT             => regio_addr_i,
      REGIO_READ_ENABLE_OUT      => regio_read_enable_i,
      REGIO_WRITE_ENABLE_OUT     => regio_write_enable_i,
      REGIO_DATA_OUT             => regio_data_out_i,
      REGIO_DATA_IN              => regio_data_in_i,
      REGIO_DATAREADY_IN         => regio_dataready_i,
      REGIO_NO_MORE_DATA_IN      => regio_nomoredata_i,
      REGIO_WRITE_ACK_IN         => regio_write_ack_i,
      REGIO_UNKNOWN_ADDR_IN      => regio_unknown_addr_i,
      REGIO_TIMEOUT_OUT          => regio_timeout_i,

      REGIO_ONEWIRE_INOUT        => ONEWIRE_INOUT,
      REGIO_ONEWIRE_MONITOR_IN   => ONEWIRE_MONITOR_IN,
      REGIO_ONEWIRE_MONITOR_OUT  => ONEWIRE_MONITOR_OUT,
      REGIO_VAR_ENDPOINT_ID      => REGIO_VAR_ENDPOINT_ID,

      GLOBAL_TIME_OUT            => time_global_i,
      LOCAL_TIME_OUT             => time_local_i,
      TIME_SINCE_LAST_TRG_OUT    => time_since_last_trg_i,
      TIMER_TICKS_OUT            => time_ticks_i,
      TEMPERATURE_OUT            => TEMPERATURE_OUT,
      UNIQUE_ID_OUT              => UNIQUE_ID_OUT,

      STAT_DEBUG_IPU             => open,
      STAT_DEBUG_1               => open,
      STAT_DEBUG_2               => open,
      MED_STAT_OP                => open,
      CTRL_MPLEX                 => (others => '0'),
      IOBUF_CTRL_GEN             => (others => '0'),
      STAT_ONEWIRE               => open,
      STAT_ADDR_DEBUG            => open,
      STAT_TRIGGER_OUT           => STAT_TRIGGER_OUT,      
      DEBUG_LVL1_HANDLER_OUT     => DEBUG_LVL1_HANDLER_OUT
      );

---------------------------------------------------------------------------
-- RegIO Bus Handler
---------------------------------------------------------------------------

  THE_INTERNAL_BUS_HANDLER : trb_net16_regio_bus_handler
    generic map(
      PORT_NUMBER                => 5,
      PORT_ADDRESSES             => (0 => x"8000", 1 => x"7100", 2 => x"7110", 3 => x"7200", 4 => x"7300", others => x"0000"),
      PORT_ADDR_MASK             => (0 => 15,      1 => 4,       2 => 3,       3 => 2,       4 => 5,       others => 0)
      )
    port map(
      CLK                        => CLK,
      RESET                      => RESET,

      DAT_ADDR_IN                => regio_addr_i,
      DAT_DATA_IN                => regio_data_out_i,
      DAT_DATA_OUT               => regio_data_in_i,
      DAT_READ_ENABLE_IN         => regio_read_enable_i,
      DAT_WRITE_ENABLE_IN        => regio_write_enable_i,
      DAT_TIMEOUT_IN             => regio_timeout_i,
      DAT_DATAREADY_OUT          => regio_dataready_i,
      DAT_WRITE_ACK_OUT          => regio_write_ack_i,
      DAT_NO_MORE_DATA_OUT       => regio_nomoredata_i,
      DAT_UNKNOWN_ADDR_OUT       => regio_unknown_addr_i,

--Fucking Modelsim wants it like this...
      BUS_READ_ENABLE_OUT(0)     => BUS_READ_ENABLE_OUT,
      BUS_READ_ENABLE_OUT(1)     => dbuf_read_enable,
      BUS_READ_ENABLE_OUT(2)     => info_read,
      BUS_READ_ENABLE_OUT(3)     => stat_handler_read,
      BUS_READ_ENABLE_OUT(4)     => stat_buffer_read,
      
      BUS_WRITE_ENABLE_OUT(0)    => BUS_WRITE_ENABLE_OUT,
      BUS_WRITE_ENABLE_OUT(1)    => dummy(100),
      BUS_WRITE_ENABLE_OUT(2)    => info_write,
      BUS_WRITE_ENABLE_OUT(3)    => stat_handler_write,
      BUS_WRITE_ENABLE_OUT(4)    => stat_buffer_write,
      
      BUS_DATA_OUT(31 downto 0)   => BUS_DATA_OUT,
      BUS_DATA_OUT(63 downto 32)  => dummy(31 downto 0),
      BUS_DATA_OUT(95 downto 64)  => info_data_in,
      BUS_DATA_OUT(127 downto 96) => dummy(63 downto 32),
      BUS_DATA_OUT(159 downto 128)=> dummy(95 downto 64),
      
      BUS_ADDR_OUT(15 downto 0)   => BUS_ADDR_OUT,
      BUS_ADDR_OUT(31 downto 16)  => dbuf_addr,
      BUS_ADDR_OUT(47 downto 32)  => info_addr,
      BUS_ADDR_OUT(63 downto 48)  => stat_handler_addr,
      BUS_ADDR_OUT(79 downto 64)  => stat_buffer_address,
      
      BUS_TIMEOUT_OUT(0)         => BUS_TIMEOUT_OUT,
      BUS_TIMEOUT_OUT(1)         => dummy(96),
      BUS_TIMEOUT_OUT(2)         => dummy(97),
      BUS_TIMEOUT_OUT(3)         => dummy(98),
      BUS_TIMEOUT_OUT(4)         => dummy(99),
      
      BUS_DATA_IN(31 downto 0)   => BUS_DATA_IN,
      BUS_DATA_IN(63 downto 32)  => dbuf_data_out,
      BUS_DATA_IN(95 downto 64)  => info_data_out,
      BUS_DATA_IN(127 downto 96) => stat_handler_data_out,
      BUS_DATA_IN(159 downto 128)=> stat_buffer_out,
      
      BUS_DATAREADY_IN(0)        => BUS_DATAREADY_IN,
      BUS_DATAREADY_IN(1)        => dbuf_dataready,
      BUS_DATAREADY_IN(2)        => info_valid,
      BUS_DATAREADY_IN(3)        => stat_handler_valid,
      BUS_DATAREADY_IN(4)        => stat_buffer_ready,
      
      BUS_WRITE_ACK_IN(0)        => BUS_WRITE_ACK_IN,
      BUS_WRITE_ACK_IN(1)        => '0',
      BUS_WRITE_ACK_IN(2)        => info_wr_ack,
      BUS_WRITE_ACK_IN(3)        => '0',
      BUS_WRITE_ACK_IN(4)        => '0',
      
      BUS_NO_MORE_DATA_IN(0)     => BUS_NO_MORE_DATA_IN,
      BUS_NO_MORE_DATA_IN(1)     => '0',
      BUS_NO_MORE_DATA_IN(2)     => '0',
      BUS_NO_MORE_DATA_IN(3)     => '0',
      BUS_NO_MORE_DATA_IN(4)     => '0',
      
      BUS_UNKNOWN_ADDR_IN(0)     => BUS_UNKNOWN_ADDR_IN,
      BUS_UNKNOWN_ADDR_IN(1)     => dbuf_unknown_addr,
      BUS_UNKNOWN_ADDR_IN(2)     => info_invalid,
      BUS_UNKNOWN_ADDR_IN(3)     => stat_handler_invalid,
      BUS_UNKNOWN_ADDR_IN(4)     => stat_buffer_unknown
      );

stat_buffer_wr_nack <= stat_buffer_write;      
stat_buffer_unknown <= stat_buffer_wr_nack or stat_buffer_rd_nack when rising_edge(CLK);      
      
---------------------------------------------------------------------------
--  registers 0x7110 ff.  
---------------------------------------------------------------------------

THE_HANDLER_INFO_REGS : bus_register_handler
  generic map(
    BUS_LENGTH => 5
    )
  port map(
    RESET            => RESET,
    CLK              => CLK,
    DATA_IN          => info_registers,
    READ_EN_IN       => info_read,
    WRITE_EN_IN      => '0',
    ADDR_IN(2 downto 0) => info_addr(2 downto 0),
    ADDR_IN(6 downto 3) => "0000",
    DATA_OUT         => info_data_out,
    DATAREADY_OUT    => info_valid,
    UNKNOWN_ADDR_OUT => info_rd_nack
    );  

info_invalid      <= info_rd_nack or info_wr_nack;    
info_registers(0) <= stat_header_buffer_level;
info_registers(1) <= std_logic_vector(to_unsigned((2**DATA_BUFFER_DEPTH-DATA_BUFFER_FULL_THRESH-1),16)) & max_event_size;
info_registers(2) <=   std_logic_vector(to_unsigned(DATA_BUFFER_FULL_THRESH,16))
                     & std_logic_vector(to_unsigned(DATA_BUFFER_DEPTH,8))
                     & std_logic_vector(to_unsigned(DATA_INTERFACE_NUMBER,8));
info_registers(3) <=   std_logic_vector(to_unsigned(TRG_RELEASE_AFTER_DATA,1))
                     & "0000000"
                     & std_logic_vector(to_unsigned(HEADER_BUFFER_FULL_THRESH,16)) 
                     & std_logic_vector(to_unsigned(HEADER_BUFFER_DEPTH,8));
info_registers(4) <= x"0000" & buffer_disable;

  proc_maxeventsize : process begin
    wait until rising_edge(CLK);
    if RESET = '1' then
      max_event_size <= std_logic_vector(to_unsigned((2**DATA_BUFFER_DEPTH-DATA_BUFFER_FULL_THRESH-1),16));
      buffer_disable <= (others => '0');
    elsif info_write = '1' and info_addr(2 downto 0) = "001" then
      max_event_size  <= info_data_in(15 downto 0);
      info_wr_ack  <= '1';
      info_wr_nack <= '0';
    elsif info_write = '1' and info_addr(2 downto 0) = "100" then
      buffer_disable  <= info_data_in(15 downto 0);
      info_wr_ack  <= '1';
      info_wr_nack <= '0';
    else
      info_wr_nack   <= info_write;
      info_wr_ack    <= '0';
    end if;
  end process;                     

---------------------------------------------------------------------------
--  registers 0x7200 ff.  
---------------------------------------------------------------------------  
THE_HANDLER_STATUS_REGS : bus_register_handler
  generic map(
    BUS_LENGTH => 3
    )
  port map(
    RESET            => RESET,
    CLK              => CLK,
    DATA_IN          => stat_handler_registers,
    READ_EN_IN       => stat_handler_read,
    WRITE_EN_IN      => '0',
    ADDR_IN(2 downto 0) => stat_handler_addr(2 downto 0),
    ADDR_IN(6 downto 3) => "0000",
    DATA_OUT         => stat_handler_data_out,
    DATAREADY_OUT    => stat_handler_valid,
    UNKNOWN_ADDR_OUT => stat_handler_invalid
    );   
stat_handler_registers(0) <= stat_handler_i(31 downto 0);
stat_handler_registers(1) <= stat_handler_i(63 downto 32);
stat_handler_registers(2) <= stat_handler_i(95 downto 64);

---------------------------------------------------------------------------
-- Data and IPU Handler
---------------------------------------------------------------------------

  THE_HANDLER_TRIGGER_DATA : handler_trigger_and_data
    generic map(
      DATA_INTERFACE_NUMBER      => DATA_INTERFACE_NUMBER,
      DATA_BUFFER_DEPTH          => DATA_BUFFER_DEPTH,
      DATA_BUFFER_WIDTH          => DATA_BUFFER_WIDTH,
      DATA_BUFFER_FULL_THRESH    => DATA_BUFFER_FULL_THRESH,
      TRG_RELEASE_AFTER_DATA     => TRG_RELEASE_AFTER_DATA,
      HEADER_BUFFER_DEPTH        => HEADER_BUFFER_DEPTH,
      HEADER_BUFFER_FULL_THRESH  => HEADER_BUFFER_FULL_THRESH
      )
    port map(
      CLOCK                      => CLK,
      RESET                      => RESET,
      RESET_IPU                  => reset_ipu_i,
      --LVL1 channel
      LVL1_VALID_TRIGGER_IN      => lvl1_valid_i,
      LVL1_INT_TRG_NUMBER_IN     => lvl1_int_trg_number_i,
      LVL1_TRG_DATA_VALID_IN     => lvl1_data_valid_i,
      LVL1_TRG_TYPE_IN           => lvl1_type_i,
      LVL1_TRG_NUMBER_IN         => lvl1_number_i,
      LVL1_TRG_CODE_IN           => lvl1_code_i,
      LVL1_TRG_INFORMATION_IN    => lvl1_information_i,
      LVL1_ERROR_PATTERN_OUT     => lvl1_error_pattern_i,
      LVL1_TRG_RELEASE_OUT       => lvl1_release_i,

      --IPU channel
      IPU_NUMBER_IN              => ipu_number_i,
      IPU_INFORMATION_IN         => ipu_information_i,
      IPU_READOUT_TYPE_IN        => ipu_readout_type_i,
      IPU_START_READOUT_IN       => ipu_start_readout_i,
      IPU_DATA_OUT               => ipu_data_i,
      IPU_DATAREADY_OUT          => ipu_dataready_i,
      IPU_READOUT_FINISHED_OUT   => ipu_readout_finished_i,
      IPU_READ_IN                => ipu_read_i,
      IPU_LENGTH_OUT             => ipu_length_i,
      IPU_ERROR_PATTERN_OUT      => ipu_error_pattern_i,

      --FEE Input
      FEE_TRG_RELEASE_IN         => FEE_TRG_RELEASE_IN,
      FEE_TRG_STATUSBITS_IN      => FEE_TRG_STATUSBITS_IN,
      FEE_DATA_IN                => FEE_DATA_IN,
      FEE_DATA_WRITE_IN          => FEE_DATA_WRITE_IN,
      FEE_DATA_FINISHED_IN       => FEE_DATA_FINISHED_IN,
      FEE_DATA_ALMOST_FULL_OUT   => buf_fee_data_almost_full_out,

      TMG_TRG_ERROR_IN           => tmg_trg_error_i,
      MAX_EVENT_SIZE_IN          => max_event_size,
      BUFFER_DISABLE_IN          => buffer_disable,
      --Status Registers
      STAT_DATA_BUFFER_LEVEL     => stat_data_buffer_level,
      STAT_HEADER_BUFFER_LEVEL   => stat_header_buffer_level,
      STATUS_OUT                 => stat_handler_i,
      TIMER_TICKS_IN             => time_ticks_i,
      STATISTICS_DATA_OUT        => stat_buffer_out,
      STATISTICS_UNKNOWN_OUT     => stat_buffer_rd_nack,
      STATISTICS_READY_OUT       => stat_buffer_ready,
      STATISTICS_READ_IN         => stat_buffer_read,
      STATISTICS_ADDR_IN         => stat_buffer_address(4 downto 0),


      --Debug
      DEBUG_DATA_HANDLER_OUT     => debug_data_handler_i,
      DEBUG_IPU_HANDLER_OUT      => debug_ipu_handler_i

      );

  reset_ipu_i                  <= RESET or common_ctrl_reg_i(2);
  lvl1_valid_i                 <= lvl1_valid_timing_i or lvl1_valid_notiming_i or lvl1_invalid_i;
  STAT_DEBUG_IPU_HANDLER_OUT   <= debug_ipu_handler_i;
  STAT_DEBUG_DATA_HANDLER_OUT  <= debug_data_handler_i;
  tmg_trg_error_i              <= int_lvl1_missing_tmg_trg or int_lvl1_spurious_trg or int_lvl1_timeout_detected or int_multiple_trg
                                  or int_spike_detected or int_lvl1_long_trg;
  FEE_DATA_ALMOST_FULL_OUT     <= (others => or_all(buf_fee_data_almost_full_out));
  
---------------------------------------------------------------------------
-- Connect Status Registers
---------------------------------------------------------------------------
  proc_buf_status : process(CLK)
    variable tmp : integer range 0 to 15;
    begin
      if rising_edge(CLK) then
        dbuf_unknown_addr        <= '0';
        dbuf_dataready           <= '0';
        if dbuf_read_enable = '1' then
          tmp := to_integer(unsigned(dbuf_addr(3 downto 0)));
          if tmp < DATA_INTERFACE_NUMBER then
            dbuf_data_out        <= stat_data_buffer_level(tmp*32+31 downto tmp*32);
            dbuf_dataready       <= '1';
          else
            dbuf_data_out        <= (others => '0');
            dbuf_unknown_addr    <= '1';
          end if;
        end if;
      end if;
    end process;



---------------------------------------------------------------------------
-- Connect I/O Ports
---------------------------------------------------------------------------

  TRG_SPIKE_DETECTED_OUT   <= int_spike_detected;
  TRG_SPURIOUS_TRG_OUT     <= int_lvl1_spurious_trg;
  TRG_TIMEOUT_DETECTED_OUT <= int_lvl1_timeout_detected;
  TRG_MULTIPLE_TRG_OUT     <= int_multiple_trg;
  TRG_MISSING_TMG_TRG_OUT  <= int_lvl1_missing_tmg_trg;

  LVL1_TRG_DATA_VALID_OUT        <= lvl1_data_valid_i;
  LVL1_VALID_TIMING_TRG_OUT      <= lvl1_valid_timing_i;
  LVL1_VALID_NOTIMING_TRG_OUT    <= lvl1_valid_notiming_i;
  LVL1_INVALID_TRG_OUT           <= lvl1_invalid_i;
  LVL1_TRG_TYPE_OUT              <= lvl1_type_i;
  LVL1_TRG_NUMBER_OUT            <= lvl1_number_i;
  LVL1_TRG_CODE_OUT              <= lvl1_code_i;
  LVL1_TRG_INFORMATION_OUT       <= lvl1_information_i;
  LVL1_INT_TRG_NUMBER_OUT        <= lvl1_int_trg_number_i;

  REGIO_COMMON_CTRL_REG_OUT      <= common_ctrl_reg_i;
  REGIO_COMMON_STAT_STROBE_OUT   <= common_stat_strobe_i;
  REGIO_COMMON_CTRL_STROBE_OUT   <= common_ctrl_strobe_i;
  REGIO_CTRL_REG_OUT             <= ctrl_reg_i;
  REGIO_STAT_STROBE_OUT          <= stat_strobe_i;
  REGIO_CTRL_STROBE_OUT          <= ctrl_strobe_i;

  stat_reg_i                     <= REGIO_STAT_REG_IN;

  TIME_GLOBAL_OUT                <= time_global_i;
  TIME_LOCAL_OUT                 <= time_local_i;
  TIME_SINCE_LAST_TRG_OUT        <= time_since_last_trg_i;
  TIME_TICKS_OUT                 <= time_ticks_i;

  process(REGIO_COMMON_STAT_REG_IN, debug_ipu_handler_i,common_ctrl_reg_i, common_stat_reg_i)
    begin
      common_stat_reg_i(8 downto 0) <= REGIO_COMMON_STAT_REG_IN(8 downto 0);
      common_stat_reg_i(47 downto 12) <= REGIO_COMMON_STAT_REG_IN(47 downto 12);
      common_stat_reg_i(6)       <= debug_ipu_handler_i(15) or REGIO_COMMON_STAT_REG_IN(6);

      if rising_edge(CLK) then
        if common_ctrl_reg_i(4) = '1' then 
          common_stat_reg_i(11 downto 9) <= "000";
        else 
          common_stat_reg_i(9)       <= debug_ipu_handler_i(12) or REGIO_COMMON_STAT_REG_IN(9) or common_stat_reg_i(9);
          common_stat_reg_i(10)      <= debug_ipu_handler_i(13) or REGIO_COMMON_STAT_REG_IN(10) or common_stat_reg_i(10);
          common_stat_reg_i(11)      <= debug_ipu_handler_i(14) or REGIO_COMMON_STAT_REG_IN(11) or common_stat_reg_i(11);      
        end if;
      end if;
      common_stat_reg_i(159 downto 64) <= REGIO_COMMON_STAT_REG_IN(159 downto 64);
    end process;

  process(CLK)
    begin
      if rising_edge(CLK) then
        if ipu_start_readout_i = '1' then
          common_stat_reg_i(63 downto 48) <= ipu_number_i;
        end if;
      end if;
    end process;

end architecture;
