-- the full endpoint for HADES: trg, data, unused, regio

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;


entity trb_net16_endpoint_hades_full is
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
    MY_ADDRESS_OUT            : out std_logic_vector(15 downto 0);

    GLOBAL_TIME_OUT           : out std_logic_vector(31 downto 0); --global time, microseconds
    LOCAL_TIME_OUT            : out std_logic_vector(7 downto 0);  --local time running with chip frequency
    TIME_SINCE_LAST_TRG_OUT   : out std_logic_vector(31 downto 0); --local time, resetted with each trigger
    TIMER_TICKS_OUT           : out std_logic_vector(1 downto 0);  --bit 1 ms-tick, 0 us-tick
    TEMPERATURE_OUT           : out std_logic_vector(11 downto 0);
    UNIQUE_ID_OUT             : out std_logic_vector(63 downto 0);
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
end trb_net16_endpoint_hades_full;





architecture trb_net16_endpoint_hades_full_arch of trb_net16_endpoint_hades_full is


  signal apl_to_buf_INIT_DATAREADY: std_logic_vector(3 downto 0);
  signal apl_to_buf_INIT_DATA     : std_logic_vector (4*c_DATA_WIDTH-1 downto 0);
  signal apl_to_buf_INIT_PACKET_NUM:std_logic_vector (4*c_NUM_WIDTH-1 downto 0);
  signal apl_to_buf_INIT_READ     : std_logic_vector(3 downto 0);

  signal buf_to_apl_INIT_DATAREADY: std_logic_vector(3 downto 0);
  signal buf_to_apl_INIT_DATA     : std_logic_vector (4*c_DATA_WIDTH-1 downto 0);
  signal buf_to_apl_INIT_PACKET_NUM:std_logic_vector (4*c_NUM_WIDTH-1 downto 0);
  signal buf_to_apl_INIT_READ     : std_logic_vector(3 downto 0);

  signal apl_to_buf_REPLY_DATAREADY: std_logic_vector(3 downto 0);
  signal apl_to_buf_REPLY_DATA     : std_logic_vector (4*c_DATA_WIDTH-1 downto 0);
  signal apl_to_buf_REPLY_PACKET_NUM:std_logic_vector (4*c_NUM_WIDTH-1 downto 0);
  signal apl_to_buf_REPLY_READ     : std_logic_vector(3 downto 0);

  signal buf_to_apl_REPLY_DATAREADY: std_logic_vector(3 downto 0);
  signal buf_to_apl_REPLY_DATA     : std_logic_vector (4*c_DATA_WIDTH-1 downto 0);
  signal buf_to_apl_REPLY_PACKET_NUM:std_logic_vector (4*c_NUM_WIDTH-1 downto 0);
  signal buf_to_apl_REPLY_READ     : std_logic_vector(3 downto 0);

  -- for the connection to the multiplexer
  signal MED_IO_DATAREADY_IN  : std_logic_vector(3 downto 0);
  signal MED_IO_DATA_IN       : std_logic_vector (4*c_DATA_WIDTH-1 downto 0);
  signal MED_IO_PACKET_NUM_IN : std_logic_vector (4*c_NUM_WIDTH-1 downto 0);
  signal MED_IO_READ_OUT      : std_logic_vector(3 downto 0);

  signal MED_IO_DATAREADY_OUT  : std_logic_vector(7 downto 0);
  signal MED_IO_DATA_OUT       : std_logic_vector (8*c_DATA_WIDTH-1 downto 0);
  signal MED_IO_PACKET_NUM_OUT : std_logic_vector (8*c_NUM_WIDTH-1 downto 0);
  signal MED_IO_READ_IN        : std_logic_vector(7 downto 0);

  signal buf_APL_DATA_IN : std_logic_vector(4*c_DATA_WIDTH-1 downto 0);
  signal buf_APL_PACKET_NUM_IN : std_logic_vector(4*c_NUM_WIDTH-1 downto 0);
  signal buf_APL_DATAREADY_IN : std_logic_vector(3 downto 0);
  signal buf_APL_READ_OUT : std_logic_vector(3 downto 0);
  signal buf_APL_SHORT_TRANSFER_IN : std_logic_vector(3 downto 0);
  signal buf_APL_DTYPE_IN : std_logic_vector(4*4-1 downto 0);
  signal buf_APL_ERROR_PATTERN_IN : std_logic_vector(4*32-1 downto 0);
  signal buf_APL_SEND_IN : std_logic_vector(3 downto 0);
  signal buf_APL_DATA_OUT : std_logic_vector(4*c_DATA_WIDTH-1 downto 0);
  signal buf_APL_PACKET_NUM_OUT : std_logic_vector(4*c_NUM_WIDTH-1 downto 0);
  signal buf_APL_DATAREADY_OUT : std_logic_vector(3 downto 0);
  signal buf_APL_READ_IN : std_logic_vector(3 downto 0);
  signal buf_APL_TYP_OUT : std_logic_vector(4*3-1 downto 0);
  signal buf_APL_RUN_OUT : std_logic_vector(3 downto 0);
  signal buf_APL_SEQNR_OUT : std_logic_vector(4*8-1 downto 0);
  signal buf_APL_LENGTH_IN : std_logic_vector(16*4-1 downto 0);

  signal MY_ADDRESS : std_logic_vector(15 downto 0);

  signal buf_api_stat_fifo_to_apl, buf_api_stat_fifo_to_int : std_logic_vector (4*32-1 downto 0);
  signal buf_STAT_GEN : std_logic_vector(32*4-1 downto 0);
  signal buf_STAT_INIT_BUFFER : std_logic_vector(32*4-1 downto 0);
  signal buf_CTRL_GEN : std_logic_vector(32*4-1 downto 0);
  signal buf_STAT_INIT_OBUF_DEBUG      : std_logic_vector (32*4-1 downto 0);
  signal buf_STAT_REPLY_OBUF_DEBUG     : std_logic_vector (32*4-1 downto 0);

  signal REGIO_REGIO_STAT : std_logic_vector(31 downto 0);

  signal buf_COMMON_STAT_REG_IN: std_logic_vector(std_COMSTATREG*32-1 downto 0);
  signal buf_REGIO_COMMON_CTRL_REG_OUT : std_logic_vector(std_COMCTRLREG*32-1 downto 0);

  signal buf_IDRAM_DATA_IN       :  std_logic_vector(15 downto 0);
  signal buf_IDRAM_DATA_OUT      :  std_logic_vector(15 downto 0);
  signal buf_IDRAM_ADDR_IN       :  std_logic_vector(2 downto 0);
  signal buf_IDRAM_WR_IN         :  std_logic;
  signal reset_no_link           :  std_logic;
  signal ONEWIRE_DATA            :  std_logic_vector(15 downto 0);
  signal ONEWIRE_ADDR            :  std_logic_vector(2 downto 0);
  signal ONEWIRE_WRITE           :  std_logic;
  signal buf_stat_onewire        :  std_logic_vector(31 downto 0);

  signal buf_COMMON_STAT_REG_STROBE :  std_logic_vector((std_COMSTATREG)-1 downto 0);
  signal buf_COMMON_CTRL_REG_STROBE :  std_logic_vector((std_COMCTRLREG)-1 downto 0);
  signal buf_STAT_REG_STROBE        :  std_logic_vector(2**(REGIO_NUM_STAT_REGS)-1 downto 0);
  signal buf_CTRL_REG_STROBE        :  std_logic_vector(2**(REGIO_NUM_CTRL_REGS)-1 downto 0);
  signal int_trigger_num            : std_logic_vector(15 downto 0);

  signal buf_LVL1_TRG_TYPE_OUT        : std_logic_vector(3 downto 0);
  signal buf_LVL1_TRG_RECEIVED_OUT    : std_logic;
  signal buf_LVL1_TRG_NUMBER_OUT      : std_logic_vector(15 downto 0);
  signal buf_LVL1_TRG_CODE_OUT        : std_logic_vector(7 downto 0);
  signal buf_LVL1_TRG_INFORMATION_OUT : std_logic_vector(23 downto 0);
  signal last_LVL1_TRG_RECEIVED_OUT   : std_logic;
  signal LVL1_TRG_RECEIVED_OUT_rising : std_logic;
  signal LVL1_TRG_RECEIVED_OUT_falling: std_logic;
  signal buf_LVL1_ERROR_PATTERN_IN    : std_logic_vector(31 downto 0);

  signal temperature                  : std_logic_vector(11 downto 0);
  signal got_timing_trigger           : std_logic;
  signal got_timingless_trigger       : std_logic;
  signal trigger_number_match         : std_logic;
  signal buf_TIMER_TICKS_OUT          : std_logic_vector(1 downto 0);
--   signal timing_trigger_missing       : std_logic;

  signal buf_LVL1_VALID_TIMING_TRG_OUT    : std_logic;
  signal buf_LVL1_VALID_NOTIMING_TRG_OUT  : std_logic;
  signal buf_LVL1_INVALID_TRG_OUT         : std_logic;
  signal buf_LVL1_TRG_RELEASE_IN          : std_logic;
  signal buf_LVL1_TRG_DATA_VALID_OUT      : std_logic;

  signal int_lvl1_delay            : std_logic_vector(15 downto 0);
  signal int_trg_reset             : std_logic;
  signal reset_trg_logic           : std_logic;
  signal stat_lvl1_handler         : std_logic_vector(63 downto 0);
  signal stat_counters_lvl1_handler: std_logic_vector(79 downto 0);
  signal trg_invert_i              : std_logic;
  signal int_multiple_trg          : std_logic;
  signal int_lvl1_timeout_detected : std_logic;
  signal int_lvl1_spurious_trg     : std_logic;
  signal int_lvl1_missing_tmg_trg  : std_logic;
  signal int_spike_detected        : std_logic;
  signal int_lvl1_long_trg         : std_logic;


  signal last_TRG_TIMING_TRG_RECEIVED_IN : std_logic;
  signal last_timingtrg_counter_write    : std_logic;
  signal last_timingtrg_counter_read     : std_logic;

  signal reg_timing_trigger : std_logic;
  signal trigger_timing_rising : std_logic;
  signal last_reg_timing_trigger : std_logic;
--   signal timing_trigger_missing_stat : std_logic;

  signal link_error_i            : std_logic;
  signal link_and_reset_status   : std_logic_vector(31 downto 0);

  signal make_trbnet_reset       : std_logic;
  signal last_make_trbnet_reset  : std_logic;
  signal lvl1_tmg_trg_missing_flag : std_logic;

  component edge_to_pulse is
    port (
      clock     : in  std_logic;
      en_clk    : in  std_logic;
      signal_in : in  std_logic;
      pulse     : out std_logic);
  end component;

begin

  process(CLK)
    begin
      if rising_edge(CLK) then
        reset_no_link  <= MED_STAT_OP_IN(14) or RESET;
        reset_trg_logic <= RESET or buf_REGIO_COMMON_CTRL_REG_OUT(1);
      end if;
    end process;

  MED_CTRL_OP_OUT(7 downto 0)  <= (others => '0');
  MED_CTRL_OP_OUT(8)           <= buf_REGIO_COMMON_CTRL_REG_OUT(64+27);
  MED_CTRL_OP_OUT(15 downto 9) <= (others => '0');
  MED_STAT_OP <= MED_STAT_OP_IN;

  --Connections for data channel
    genbuffers : for i in 0 to 3 generate
      geniobuf: if USE_CHANNEL(i) = c_YES generate
        IOBUF: trb_net16_iobuf
          generic map (
            IBUF_DEPTH          => IBUF_DEPTH(i),
            IBUF_SECURE_MODE    => IBUF_SECURE_MODE(i),
            SBUF_VERSION        => 0,
            SBUF_VERSION_OBUF   => 6,
            OBUF_DATA_COUNT_WIDTH => std_DATA_COUNT_WIDTH,
            USE_ACKNOWLEDGE     => cfg_USE_ACKNOWLEDGE(i),
            USE_CHECKSUM        => USE_CHECKSUM(i),
            USE_VENDOR_CORES    => c_YES,
            INIT_CAN_SEND_DATA  => INIT_CAN_SEND_DATA(i),
            REPLY_CAN_SEND_DATA => REPLY_CAN_SEND_DATA(i),
            REPLY_CAN_RECEIVE_DATA => REPLY_CAN_RECEIVE_DATA(i)
            )
          port map (
            --  Misc
            CLK     => CLK ,
            RESET   => reset_no_link,
            CLK_EN  => CLK_EN,
            --  Media direction port
            MED_INIT_DATAREADY_OUT  => MED_IO_DATAREADY_OUT(i*2),
            MED_INIT_DATA_OUT       => MED_IO_DATA_OUT((i*2+1)*c_DATA_WIDTH-1 downto i*2*c_DATA_WIDTH),
            MED_INIT_PACKET_NUM_OUT => MED_IO_PACKET_NUM_OUT((i*2+1)*c_NUM_WIDTH-1 downto i*2*c_NUM_WIDTH),
            MED_INIT_READ_IN        => MED_IO_READ_IN(i*2),

            MED_DATAREADY_IN   => MED_IO_DATAREADY_IN(i),
            MED_DATA_IN        => MED_IO_DATA_IN((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            MED_PACKET_NUM_IN  => MED_IO_PACKET_NUM_IN((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            MED_READ_OUT       => MED_IO_READ_OUT(i),
            MED_ERROR_IN       => MED_STAT_OP_IN(2 downto 0),

            MED_REPLY_DATAREADY_OUT => MED_IO_DATAREADY_OUT(i*2+1),
            MED_REPLY_DATA_OUT      => MED_IO_DATA_OUT((i*2+2)*c_DATA_WIDTH-1 downto (i*2+1)*c_DATA_WIDTH),
            MED_REPLY_PACKET_NUM_OUT=> MED_IO_PACKET_NUM_OUT((i*2+2)*c_NUM_WIDTH-1 downto (i*2+1)*c_NUM_WIDTH),
            MED_REPLY_READ_IN       => MED_IO_READ_IN(i*2+1),

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
            STAT_GEN               => buf_STAT_GEN(32*(i+1)-1 downto i*32),
            STAT_IBUF_BUFFER       => buf_STAT_INIT_BUFFER(32*(i+1)-1 downto i*32),
            CTRL_GEN               => buf_CTRL_GEN(32*(i+1)-1 downto i*32),
            STAT_INIT_OBUF_DEBUG   => buf_STAT_INIT_OBUF_DEBUG(32*(i+1)-1 downto i*32),
            STAT_REPLY_OBUF_DEBUG  => buf_STAT_REPLY_OBUF_DEBUG(32*(i+1)-1 downto i*32),
            TIMER_TICKS_IN         => buf_TIMER_TICKS_OUT,
            CTRL_STAT              => x"0000"
            );

      gen_api : if i /= c_TRG_LVL1_CHANNEL generate
        constant j : integer := i;
      begin
        DAT_PASSIVE_API: trb_net16_api_base
          generic map (
            API_TYPE          => c_API_PASSIVE,
            FIFO_TO_INT_DEPTH => FIFO_TO_INT_DEPTH(i),
            FIFO_TO_APL_DEPTH => FIFO_TO_APL_DEPTH(i),
            FORCE_REPLY       => cfg_FORCE_REPLY(i),
            SBUF_VERSION      => 0,
            USE_VENDOR_CORES   => c_YES,
            SECURE_MODE_TO_APL => API_SECURE_MODE_TO_APL(i),
            SECURE_MODE_TO_INT => API_SECURE_MODE_TO_INT(i),
            APL_WRITE_ALL_WORDS=> APL_WRITE_ALL_WORDS(i),
            ADDRESS_MASK       => ADDRESS_MASK,
            BROADCAST_BITMASK  => BROADCAST_BITMASK,
            BROADCAST_SPECIAL_ADDR => BROADCAST_SPECIAL_ADDR
            )
          port map (
            --  Misc
            CLK    => CLK,
            RESET  => RESET,
            CLK_EN => CLK_EN,
            -- APL Transmitter port
            APL_DATA_IN           => buf_APL_DATA_IN((j+1)*c_DATA_WIDTH-1 downto j*c_DATA_WIDTH),
            APL_PACKET_NUM_IN     => buf_APL_PACKET_NUM_IN((j+1)*c_NUM_WIDTH-1 downto j*c_NUM_WIDTH),
            APL_DATAREADY_IN      => buf_APL_DATAREADY_IN(j),
            APL_READ_OUT          => buf_APL_READ_OUT(j),
            APL_SHORT_TRANSFER_IN => buf_APL_SHORT_TRANSFER_IN(j),
            APL_DTYPE_IN          => buf_APL_DTYPE_IN((j+1)*4-1 downto j*4),
            APL_ERROR_PATTERN_IN  => buf_APL_ERROR_PATTERN_IN((j+1)*32-1 downto j*32),
            APL_SEND_IN           => buf_APL_SEND_IN(j),
            APL_TARGET_ADDRESS_IN => (others => '0'),
            -- Receiver port
            APL_DATA_OUT      => buf_APL_DATA_OUT((j+1)*c_DATA_WIDTH-1 downto j*c_DATA_WIDTH),
            APL_PACKET_NUM_OUT=> buf_APL_PACKET_NUM_OUT((j+1)*c_NUM_WIDTH-1 downto j*c_NUM_WIDTH),
            APL_TYP_OUT       => buf_APL_TYP_OUT((j+1)*3-1 downto j*3),
            APL_DATAREADY_OUT => buf_APL_DATAREADY_OUT(j),
            APL_READ_IN       => buf_APL_READ_IN(j),
            -- APL Control port
            APL_RUN_OUT       => buf_APL_RUN_OUT(j),
            APL_MY_ADDRESS_IN => MY_ADDRESS,
            APL_SEQNR_OUT     => buf_APL_SEQNR_OUT((j+1)*8-1 downto j*8),
            APL_LENGTH_IN     => buf_APL_LENGTH_IN((j+1)*16-1 downto j*16),
            -- Internal direction port
            INT_MASTER_DATAREADY_OUT => apl_to_buf_REPLY_DATAREADY(i),
            INT_MASTER_DATA_OUT      => apl_to_buf_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_MASTER_PACKET_NUM_OUT=> apl_to_buf_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_MASTER_READ_IN       => apl_to_buf_REPLY_READ(i),
            INT_MASTER_DATAREADY_IN  => buf_to_apl_REPLY_DATAREADY(i),
            INT_MASTER_DATA_IN       => buf_to_apl_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_MASTER_PACKET_NUM_IN => buf_to_apl_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_MASTER_READ_OUT      => buf_to_apl_REPLY_READ(i),
            INT_SLAVE_DATAREADY_OUT  => apl_to_buf_INIT_DATAREADY(i),
            INT_SLAVE_DATA_OUT       => apl_to_buf_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_SLAVE_PACKET_NUM_OUT => apl_to_buf_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_SLAVE_READ_IN        => apl_to_buf_INIT_READ(i),
            INT_SLAVE_DATAREADY_IN => buf_to_apl_INIT_DATAREADY(i),
            INT_SLAVE_DATA_IN      => buf_to_apl_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_SLAVE_PACKET_NUM_IN=> buf_to_apl_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_SLAVE_READ_OUT     => buf_to_apl_INIT_READ(i),
            -- Status and control port
            CTRL_SEQNR_RESET =>  buf_REGIO_COMMON_CTRL_REG_OUT(10),
            STAT_FIFO_TO_INT => buf_api_stat_fifo_to_int((i+1)*32-1 downto i*32),
            STAT_FIFO_TO_APL => buf_api_stat_fifo_to_apl((i+1)*32-1 downto i*32)
            );
        end generate;

        gentrgapi : if i = c_TRG_LVL1_CHANNEL generate
          buf_APL_READ_OUT(i) <= '0';
          buf_APL_DATA_IN((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');
          buf_APL_DATA_OUT((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');
          buf_APL_DATAREADY_OUT(i) <= '0';
          buf_APL_SEQNR_OUT((i+1)*8-1 downto i*8) <= (others => '0');
          buf_APL_PACKET_NUM_IN((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= (others => '0');
          buf_APL_DTYPE_IN((i+1)*4-1 downto i*4) <= (others => '0');
          buf_APL_LENGTH_IN((i+1)*16-1 downto i*16) <= (others => '1');
          buf_APL_RUN_OUT(i) <= '0';
          buf_APL_ERROR_PATTERN_IN((i+1)*32-1 downto i*32) <= (others => '0');
          buf_APL_READ_IN(i) <= '0';
          buf_APL_SHORT_TRANSFER_IN(i) <= '0';
          buf_APL_TYP_OUT((i+1)*3-1 downto i*3) <= (others => '0');
          buf_APL_DATAREADY_IN(i) <= '0';
          buf_APL_SEND_IN(i) <= '0';
          buf_APL_PACKET_NUM_OUT((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= (others => '0');

          apl_to_buf_INIT_DATAREADY(i) <= '0';
          apl_to_buf_INIT_DATA((i+1)*16-1 downto i*16) <= (others => '0');
          apl_to_buf_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= (others => '0');
          apl_to_buf_INIT_READ(i) <= '0';

          buf_to_apl_REPLY_READ(i) <= '1';
          buf_to_apl_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= (others => '0');
          buf_to_apl_REPLY_DATAREADY(i) <= '0';
          buf_to_apl_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');

          buf_api_stat_fifo_to_apl((i+1)*32-1 downto i*32) <= (others => '0');
          buf_api_stat_fifo_to_int((i+1)*32-1 downto i*32) <= (others => '0');


          the_trigger_apl : trb_net16_trigger
            generic map(
              USE_TRG_PORT => c_YES,
              SECURE_MODE  => std_TERM_SECURE_MODE
              )
            port map(
              --  Misc
              CLK    => CLK,
              RESET  => RESET,
              CLK_EN => CLK_EN,
              INT_DATAREADY_OUT => apl_to_buf_REPLY_DATAREADY(i),
              INT_DATA_OUT      => apl_to_buf_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
              INT_PACKET_NUM_OUT=> apl_to_buf_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
              INT_READ_IN       => apl_to_buf_REPLY_READ(i),
              INT_DATAREADY_IN => buf_to_apl_INIT_DATAREADY(i),
              INT_DATA_IN      => buf_to_apl_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
              INT_PACKET_NUM_IN=> buf_to_apl_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
              INT_READ_OUT     => buf_to_apl_INIT_READ(i),
              TRG_RECEIVED_OUT      => buf_LVL1_TRG_RECEIVED_OUT,
              TRG_TYPE_OUT          => buf_LVL1_TRG_TYPE_OUT,
              TRG_NUMBER_OUT        => buf_LVL1_TRG_NUMBER_OUT,
              TRG_CODE_OUT          => buf_LVL1_TRG_CODE_OUT,
              TRG_INFORMATION_OUT   => buf_LVL1_TRG_INFORMATION_OUT,
              TRG_RELEASE_IN        => buf_LVL1_TRG_RELEASE_IN,
              TRG_ERROR_PATTERN_IN  => buf_LVL1_ERROR_PATTERN_IN
              );
        end generate;

        gen_ipu_apl : if i = c_DATA_CHANNEL generate
          the_ipudata_apl : trb_net16_ipudata
            port map(
              CLK    => CLK,
              RESET  => RESET,
              CLK_EN => CLK_EN,
              API_DATA_OUT           => buf_APL_DATA_IN((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
              API_PACKET_NUM_OUT     => buf_APL_PACKET_NUM_IN((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
              API_DATAREADY_OUT      => buf_APL_DATAREADY_IN(i),
              API_READ_IN            => buf_APL_READ_OUT(i),
              API_SHORT_TRANSFER_OUT => buf_APL_SHORT_TRANSFER_IN(i),
              API_DTYPE_OUT          => buf_APL_DTYPE_IN((i+1)*4-1 downto i*4),
              API_ERROR_PATTERN_OUT  => buf_APL_ERROR_PATTERN_IN((i+1)*32-1 downto i*32),
              API_SEND_OUT           => buf_APL_SEND_IN(i),
              API_DATA_IN            => buf_APL_DATA_OUT((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
              API_PACKET_NUM_IN      => buf_APL_PACKET_NUM_OUT((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
              API_TYP_IN             => buf_APL_TYP_OUT((i+1)*3-1 downto i*3),
              API_DATAREADY_IN       => buf_APL_DATAREADY_OUT(i),
              API_READ_OUT           => buf_APL_READ_IN(i),
              API_RUN_IN             => buf_APL_RUN_OUT(i),
              API_SEQNR_IN           => buf_APL_SEQNR_OUT((i+1)*8-1 downto i*8),
              API_LENGTH_OUT         => buf_APL_LENGTH_IN((i+1)*16-1 downto i*16),
              MY_ADDRESS_IN          => MY_ADDRESS,
              --Information received with request
              IPU_NUMBER_OUT         => IPU_NUMBER_OUT,
              IPU_READOUT_TYPE_OUT   => IPU_READOUT_TYPE_OUT,
              IPU_INFORMATION_OUT    => IPU_INFORMATION_OUT,
              --start strobe
              IPU_START_READOUT_OUT  => IPU_START_READOUT_OUT,
              --detector data, equipped with DHDR
              IPU_DATA_IN            => IPU_DATA_IN,
              IPU_DATAREADY_IN       => IPU_DATAREADY_IN,
              --no more data, end transfer, send TRM
              IPU_READOUT_FINISHED_IN=> IPU_READOUT_FINISHED_IN,
              --will be low every second cycle due to 32bit -> 16bit conversion
              IPU_READ_OUT           => IPU_READ_OUT,
              IPU_LENGTH_IN          => IPU_LENGTH_IN,
              IPU_ERROR_PATTERN_IN   => IPU_ERROR_PATTERN_IN,
              STAT_DEBUG             => STAT_DEBUG_IPU
              );
        end generate;

        gen_regio : if i = c_SLOW_CTRL_CHANNEL generate
          buf_APL_LENGTH_IN((i+1)*16-1 downto i*16) <= (others => '1');

          regIO : trb_net16_regIO
            generic map(
              NUM_STAT_REGS      => REGIO_NUM_STAT_REGS,
              NUM_CTRL_REGS      => REGIO_NUM_CTRL_REGS,
              --standard values for output registers
              INIT_CTRL_REGS     => REGIO_INIT_CTRL_REGS,
              --set to 0 for unused ctrl registers to save resources
              USED_CTRL_REGS     => REGIO_USED_CTRL_REGS,
              --set to 0 for each unused bit in a register
              USED_CTRL_BITMASK  => REGIO_USED_CTRL_BITMASK,
              --no data / address out?
              USE_DAT_PORT       => REGIO_USE_DAT_PORT,
              INIT_ADDRESS       => REGIO_INIT_ADDRESS,
              INIT_UNIQUE_ID     => REGIO_INIT_UNIQUE_ID,
              INIT_ENDPOINT_ID   => REGIO_INIT_ENDPOINT_ID,
              COMPILE_TIME       => REGIO_COMPILE_TIME,
              INCLUDED_FEATURES  => REGIO_INCLUDED_FEATURES,
              HARDWARE_VERSION   => REGIO_HARDWARE_VERSION,
              CLOCK_FREQ         => CLOCK_FREQUENCY
              )
            port map(
            --  Misc
              CLK      => CLK,
              RESET    => RESET,
              CLK_EN   => CLK_EN,
            -- Port to API
              API_DATA_OUT           => buf_APL_DATA_IN((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
              API_PACKET_NUM_OUT     => buf_APL_PACKET_NUM_IN((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
              API_DATAREADY_OUT      => buf_APL_DATAREADY_IN(i),
              API_READ_IN            => buf_APL_READ_OUT(i),
              API_SHORT_TRANSFER_OUT => buf_APL_SHORT_TRANSFER_IN(i),
              API_DTYPE_OUT          => buf_APL_DTYPE_IN((i+1)*4-1 downto i*4),
              API_ERROR_PATTERN_OUT  => buf_APL_ERROR_PATTERN_IN((i+1)*32-1 downto i*32),
              API_SEND_OUT           => buf_APL_SEND_IN(3),
              API_DATA_IN            => buf_APL_DATA_OUT((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
              API_PACKET_NUM_IN      => buf_APL_PACKET_NUM_OUT((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
              API_TYP_IN             => buf_APL_TYP_OUT((i+1)*3-1 downto i*3),
              API_DATAREADY_IN       => buf_APL_DATAREADY_OUT(i),
              API_READ_OUT           => buf_APL_READ_IN(i),
              API_RUN_IN             => buf_APL_RUN_OUT(i),
              API_SEQNR_IN           => buf_APL_SEQNR_OUT((i+1)*8-1 downto i*8),
            --Port to write Unique ID
              IDRAM_DATA_IN          => buf_IDRAM_DATA_IN,
              IDRAM_DATA_OUT         => buf_IDRAM_DATA_OUT,
              IDRAM_ADDR_IN          => buf_IDRAM_ADDR_IN,
              IDRAM_WR_IN            => buf_IDRAM_WR_IN,
              MY_ADDRESS_OUT         => MY_ADDRESS,
              TRIGGER_MONITOR        => buf_LVL1_VALID_TIMING_TRG_OUT,
              GLOBAL_TIME            => GLOBAL_TIME_OUT,
              LOCAL_TIME             => LOCAL_TIME_OUT,
              TIME_SINCE_LAST_TRG    => TIME_SINCE_LAST_TRG_OUT,
              TIMER_US_TICK          => buf_TIMER_TICKS_OUT(0),
              TIMER_MS_TICK          => buf_TIMER_TICKS_OUT(1),
            --Common Register in / out
              COMMON_STAT_REG_IN     => buf_COMMON_STAT_REG_IN,
              COMMON_CTRL_REG_OUT    => buf_REGIO_COMMON_CTRL_REG_OUT,
            --Custom Register in / out
              REGISTERS_IN           => REGIO_REGISTERS_IN,
              REGISTERS_OUT          => REGIO_REGISTERS_OUT,
              COMMON_STAT_REG_STROBE => buf_COMMON_STAT_REG_STROBE,
              COMMON_CTRL_REG_STROBE => buf_COMMON_CTRL_REG_STROBE,
              STAT_REG_STROBE        => buf_STAT_REG_STROBE,
              CTRL_REG_STROBE        => buf_CTRL_REG_STROBE,
            --following ports only used when no internal register is accessed
              DAT_ADDR_OUT           => REGIO_ADDR_OUT,
              DAT_READ_ENABLE_OUT    => REGIO_READ_ENABLE_OUT,
              DAT_WRITE_ENABLE_OUT   => REGIO_WRITE_ENABLE_OUT,
              DAT_DATA_OUT           => REGIO_DATA_OUT,
              DAT_DATA_IN            => REGIO_DATA_IN,
              DAT_DATAREADY_IN       => REGIO_DATAREADY_IN,
              DAT_NO_MORE_DATA_IN    => REGIO_NO_MORE_DATA_IN,
              DAT_UNKNOWN_ADDR_IN    => REGIO_UNKNOWN_ADDR_IN,
              DAT_TIMEOUT_OUT        => REGIO_TIMEOUT_OUT,
              DAT_WRITE_ACK_IN       => REGIO_WRITE_ACK_IN,
              STAT                   => REGIO_REGIO_STAT,
              STAT_ADDR_DEBUG        => STAT_ADDR_DEBUG
              );
          gen_no1wire : if REGIO_USE_1WIRE_INTERFACE = c_NO generate
            ONEWIRE_DATA  <= REGIO_IDRAM_DATA_IN;
            ONEWIRE_ADDR  <= REGIO_IDRAM_ADDR_IN;
            ONEWIRE_WRITE <= REGIO_IDRAM_WR_IN;
            REGIO_IDRAM_DATA_OUT <= buf_IDRAM_DATA_OUT;
            REGIO_ONEWIRE_INOUT <= '0';
            REGIO_ONEWIRE_MONITOR_OUT <= '0';

          end generate;
          gen_1wire : if REGIO_USE_1WIRE_INTERFACE = c_YES generate


            REGIO_IDRAM_DATA_OUT <= (others => '0');
            STAT_ONEWIRE <= buf_stat_onewire;
            
            onewire_interface : trb_net_onewire
              generic map(
                USE_TEMPERATURE_READOUT => c_YES,
                CLK_PERIOD => 10
                )
              port map(
                CLK      => CLK,
                RESET    => RESET,
                --connection to 1-wire interface
                ONEWIRE  => REGIO_ONEWIRE_INOUT,
                MONITOR_OUT => REGIO_ONEWIRE_MONITOR_OUT,
                --connection to id ram, according to memory map in TrbNetRegIO
                DATA_OUT => ONEWIRE_DATA,
                ADDR_OUT => ONEWIRE_ADDR,
                WRITE_OUT=> ONEWIRE_WRITE,
                TEMP_OUT => temperature,
                ID_OUT   => UNIQUE_ID_OUT,                
                STAT     => buf_stat_onewire
                );
          end generate;
          gen_1wire_monitor : if REGIO_USE_1WIRE_INTERFACE = c_MONITOR generate
            REGIO_IDRAM_DATA_OUT <= (others => '0');
            REGIO_ONEWIRE_MONITOR_OUT <= '0';

            onewire_interface : trb_net_onewire_listener
              port map(
                CLK      => CLK,
                CLK_EN   => CLK_EN,
                RESET    => RESET,
                --connection to 1-wire interface
                MONITOR_IN => REGIO_ONEWIRE_MONITOR_IN,
                --connection to id ram, according to memory map in TrbNetRegIO
                DATA_OUT => ONEWIRE_DATA,
                ADDR_OUT => ONEWIRE_ADDR,
                WRITE_OUT=> ONEWIRE_WRITE,
                TEMP_OUT => temperature,
                ID_OUT   => UNIQUE_ID_OUT,                
                STAT     => buf_stat_onewire
                );
          end generate;
        end generate;
      end generate;
      gentermbuf: if USE_CHANNEL(i) = c_NO generate
        buf_APL_DATA_OUT((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');
        buf_APL_PACKET_NUM_OUT((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= (others => '0');
        buf_APL_READ_OUT(i) <= '0';
        buf_APL_DATAREADY_OUT(i) <= '0';
        buf_APL_DATA_IN((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');
        buf_APL_SEQNR_OUT((i+1)*8-1 downto i*8) <= (others => '0');
        buf_APL_PACKET_NUM_IN((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= (others => '0');
        buf_APL_DTYPE_IN((i+1)*4-1 downto i*4) <= (others => '0');
        buf_APL_LENGTH_IN((i+1)*16-1 downto i*16) <= (others => '1');
        buf_APL_RUN_OUT(i) <= '0';
        buf_APL_ERROR_PATTERN_IN((i+1)*32-1 downto i*32) <= (others => '0');
        buf_APL_READ_IN(i) <= '0';
        buf_APL_SHORT_TRANSFER_IN(i) <= '0';
        buf_APL_TYP_OUT((i+1)*3-1 downto i*3) <= (others => '0');
        buf_APL_DATAREADY_IN(i) <= '0';
        buf_APL_SEND_IN(i) <= '0';

        apl_to_buf_INIT_READ(i) <= '0';
        apl_to_buf_INIT_DATAREADY(i) <= '0';
        apl_to_buf_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');
        apl_to_buf_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= (others => '0');
        apl_to_buf_REPLY_DATAREADY(i) <= '0';
        apl_to_buf_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');
        apl_to_buf_REPLY_READ(i) <= '0';
        apl_to_buf_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= (others => '0');

        buf_to_apl_INIT_READ(i) <= '0';
        buf_to_apl_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= (others => '0');
        buf_to_apl_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');
        buf_to_apl_INIT_DATAREADY(i) <= '0';
        buf_to_apl_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= (others => '0');
        buf_to_apl_REPLY_DATAREADY(i) <= '0';
        buf_to_apl_REPLY_READ(i) <= '0';
        buf_to_apl_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');

        buf_STAT_INIT_OBUF_DEBUG((i+1)*32-1 downto i*32) <= (others => '0');
        buf_STAT_GEN((i+1)*32-1 downto i*32) <= (others => '0');
        buf_STAT_REPLY_OBUF_DEBUG((i+1)*32-1 downto i*32) <= (others => '0');
        buf_api_stat_fifo_to_apl((i+1)*32-1 downto i*32) <= (others => '0');
        buf_api_stat_fifo_to_int((i+1)*32-1 downto i*32) <= (others => '0');
        buf_STAT_INIT_BUFFER((i+1)*32-1 downto i*32) <= (others => '0');

        termbuf: trb_net16_term_buf
          port map(
            CLK    => CLK,
            RESET  => reset_no_link,
            CLK_EN => CLK_EN,
            MED_DATAREADY_IN       => MED_IO_DATAREADY_IN(i),
            MED_DATA_IN            => MED_IO_DATA_IN((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            MED_PACKET_NUM_IN      => MED_IO_PACKET_NUM_IN((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            MED_READ_OUT           => MED_IO_READ_OUT(i),

            MED_INIT_DATAREADY_OUT  => MED_IO_DATAREADY_OUT(i*2),
            MED_INIT_DATA_OUT       => MED_IO_DATA_OUT((i*2+1)*c_DATA_WIDTH-1 downto i*2*c_DATA_WIDTH),
            MED_INIT_PACKET_NUM_OUT => MED_IO_PACKET_NUM_OUT((i*2+1)*c_NUM_WIDTH-1 downto i*2*c_NUM_WIDTH),
            MED_INIT_READ_IN        => MED_IO_READ_IN(i*2),
            MED_REPLY_DATAREADY_OUT => MED_IO_DATAREADY_OUT(i*2+1),
            MED_REPLY_DATA_OUT      => MED_IO_DATA_OUT((i*2+2)*c_DATA_WIDTH-1 downto (i*2+1)*c_DATA_WIDTH),
            MED_REPLY_PACKET_NUM_OUT=> MED_IO_PACKET_NUM_OUT((i*2+2)*c_NUM_WIDTH-1 downto (i*2+1)*c_NUM_WIDTH),
            MED_REPLY_READ_IN       => MED_IO_READ_IN(i*2+1)
            );
      end generate;
    end generate;


  MPLEX: trb_net16_io_multiplexer
    generic map(
      USE_INPUT_SBUF => (1,1,1,1,0,0,1,1)
      )
    port map (
      CLK      => CLK,
      RESET    => reset_no_link,
      CLK_EN   => CLK_EN,
      MED_DATAREADY_IN   => MED_DATAREADY_IN,
      MED_DATA_IN        => MED_DATA_IN,
      MED_PACKET_NUM_IN  => MED_PACKET_NUM_IN,
      MED_READ_OUT       => MED_READ_OUT,
      MED_DATAREADY_OUT  => MED_DATAREADY_OUT,
      MED_DATA_OUT       => MED_DATA_OUT,
      MED_PACKET_NUM_OUT => MED_PACKET_NUM_OUT,
      MED_READ_IN        => MED_READ_IN,
      INT_DATAREADY_OUT  => MED_IO_DATAREADY_IN,
      INT_DATA_OUT       => MED_IO_DATA_IN,
      INT_PACKET_NUM_OUT => MED_IO_PACKET_NUM_IN,
      INT_READ_IN        => MED_IO_READ_OUT,
      INT_DATAREADY_IN   => MED_IO_DATAREADY_OUT,
      INT_DATA_IN        => MED_IO_DATA_OUT,
      INT_PACKET_NUM_IN  => MED_IO_PACKET_NUM_OUT,
      INT_READ_OUT       => MED_IO_READ_IN,
      STAT               => open,
      CTRL               => CTRL_MPLEX
      );

-------------------------------------------------
-- Include variable Endpoint ID
-------------------------------------------------
  gen_var_endpoint_id : if REGIO_USE_VAR_ENDPOINT_ID = c_YES generate
    buf_IDRAM_DATA_IN  <= REGIO_VAR_ENDPOINT_ID when RESET = '1' else ONEWIRE_DATA;
    buf_IDRAM_ADDR_IN  <= "100"                 when RESET = '1' else ONEWIRE_ADDR;
    buf_IDRAM_WR_IN    <= '1'                   when RESET = '1' else ONEWIRE_WRITE;
  end generate;

  gen_no_var_endpoint_id : if REGIO_USE_VAR_ENDPOINT_ID = c_NO generate
    buf_IDRAM_DATA_IN  <= ONEWIRE_DATA;
    buf_IDRAM_ADDR_IN  <= ONEWIRE_ADDR;
    buf_IDRAM_WR_IN    <= ONEWIRE_WRITE;
  end generate;



-------------------------------------------------
-- Common Status Register
-------------------------------------------------
  proc_gen_common_stat_regs : process(REGIO_COMMON_STAT_REG_IN, trigger_number_match, temperature, int_trigger_num,
                                      link_error_i, link_and_reset_status, stat_lvl1_handler)
    begin
      buf_COMMON_STAT_REG_IN               <= REGIO_COMMON_STAT_REG_IN;
      buf_COMMON_STAT_REG_IN(4)            <= stat_lvl1_handler(12);
      buf_COMMON_STAT_REG_IN(8)            <= lvl1_tmg_trg_missing_flag;
      buf_COMMON_STAT_REG_IN(13)           <= stat_lvl1_handler(7);
      buf_COMMON_STAT_REG_IN(15)           <= link_error_i;
      if REGIO_USE_1WIRE_INTERFACE = c_YES then
        buf_COMMON_STAT_REG_IN(31 downto 20) <= temperature;
      end if;
      buf_COMMON_STAT_REG_IN(47 downto 32)   <= int_trigger_num;
      buf_COMMON_STAT_REG_IN(127 downto 64)  <= stat_lvl1_handler;
      buf_COMMON_STAT_REG_IN(159 downto 128) <= link_and_reset_status(31 downto 0);
      buf_COMMON_STAT_REG_IN(175 downto 160) <= buf_LVL1_TRG_INFORMATION_OUT(15 downto 0);
      buf_COMMON_STAT_REG_IN(179 downto 176) <= buf_LVL1_TRG_TYPE_OUT;
      buf_COMMON_STAT_REG_IN(183 downto 180) <= buf_LVL1_TRG_NUMBER_OUT(3 downto 0);
      buf_COMMON_STAT_REG_IN(191 downto 184) <= buf_LVL1_TRG_CODE_OUT;
      buf_COMMON_STAT_REG_IN(271 downto 192) <= stat_counters_lvl1_handler;
      buf_COMMON_STAT_REG_IN(287 downto 272) <= (others => '0');
      buf_COMMON_STAT_REG_IN(319 downto 288) <= buf_stat_onewire;
    end process;



  REG_LINK_ERROR : process(CLK)
    begin
      if rising_edge(CLK) then
        if buf_REGIO_COMMON_CTRL_REG_OUT(4) = '1' then
          link_error_i <= '0';
        elsif MED_STAT_OP_IN(15) = '0' and MED_STAT_OP_IN(13) = '0' and MED_STAT_OP_IN(7 downto 4) = "0111" then
          link_error_i <= '1';
        end if;

        if buf_REGIO_COMMON_CTRL_REG_OUT(4) = '1' then
          lvl1_tmg_trg_missing_flag <= '0';
        elsif int_lvl1_missing_tmg_trg = '1' or int_lvl1_spurious_trg = '1' or int_spike_detected = '1' then
          lvl1_tmg_trg_missing_flag <= '1';
        end if;

--         if LVL1_TRG_RECEIVED_OUT_falling = '1' then
--           timing_trigger_missing_stat <= timing_trigger_missing;
--         end if;

        if make_trbnet_reset = '1' then
          link_and_reset_status(3 downto 0) <= link_and_reset_status(3 downto 0) + '1';
        end if;

        if MED_STAT_OP_IN(12) = '1' then
          link_and_reset_status(31 downto 24) <= link_and_reset_status(31 downto 24) + '1';
        end if;

        if MED_STAT_OP_IN(8) = '1' then
          link_and_reset_status(23 downto 16) <= link_and_reset_status(23 downto 16) + '1';
        end if;

        if buf_REGIO_COMMON_CTRL_REG_OUT(5) = '1' then
          link_and_reset_status <= (others => '0');
        end if;

      end if;
    end process;

  PROC_FIND_TRBNET_RESET : process(CLK)
    begin
      if rising_edge(CLK) then
        last_make_trbnet_reset <= MED_STAT_OP_IN(13);
        make_trbnet_reset      <= MED_STAT_OP_IN(13) and not last_make_trbnet_reset;
      end if;
    end process;

-------------------------------------------------
-- Check LVL1 trigger number
-------------------------------------------------

  THE_LVL1_HANDLER : handler_lvl1
    generic map (
      TIMING_TRIGGER_RAW           => TIMING_TRIGGER_RAW
    )
    port map(
      RESET                        => reset_trg_logic,
      RESET_FLAGS_IN               => buf_REGIO_COMMON_CTRL_REG_OUT(4),
      RESET_STATS_IN               => buf_REGIO_COMMON_CTRL_REG_OUT(5),
      CLOCK                        => CLK,
      --Timing Trigger
      LVL1_TIMING_TRG_IN           => TRG_TIMING_TRG_RECEIVED_IN,
      LVL1_PSEUDO_TMG_TRG_IN       => buf_REGIO_COMMON_CTRL_REG_OUT(16),
      --LVL1_handler connection
      LVL1_TRG_RECEIVED_IN         => buf_LVL1_TRG_RECEIVED_OUT,
      LVL1_TRG_TYPE_IN             => buf_LVL1_TRG_TYPE_OUT,
      LVL1_TRG_NUMBER_IN           => buf_LVL1_TRG_NUMBER_OUT,
      LVL1_TRG_CODE_IN             => buf_LVL1_TRG_CODE_OUT,
      LVL1_TRG_INFORMATION_IN      => buf_LVL1_TRG_INFORMATION_OUT,
      LVL1_ERROR_PATTERN_OUT       => buf_LVL1_ERROR_PATTERN_IN,
      LVL1_TRG_RELEASE_OUT         => buf_LVL1_TRG_RELEASE_IN,

      LVL1_INT_TRG_NUMBER_OUT      => int_trigger_num,
      LVL1_INT_TRG_LOAD_IN         => buf_COMMON_CTRL_REG_STROBE(1),
      LVL1_INT_TRG_COUNTER_IN      => buf_REGIO_COMMON_CTRL_REG_OUT(47 downto 32),

      --FEE logic / Data Handler
      LVL1_TRG_DATA_VALID_OUT      => buf_LVL1_TRG_DATA_VALID_OUT,
      LVL1_VALID_TIMING_TRG_OUT    => buf_LVL1_VALID_TIMING_TRG_OUT,
      LVL1_VALID_NOTIMING_TRG_OUT  => buf_LVL1_VALID_NOTIMING_TRG_OUT,
      LVL1_INVALID_TRG_OUT         => buf_LVL1_INVALID_TRG_OUT,
      LVL1_MULTIPLE_TRG_OUT        => int_multiple_trg,
      LVL1_DELAY_OUT               => int_lvl1_delay,
      LVL1_TIMEOUT_DETECTED_OUT    => int_lvl1_timeout_detected,
      LVL1_SPURIOUS_TRG_OUT        => int_lvl1_spurious_trg,
      LVL1_MISSING_TMG_TRG_OUT     => int_lvl1_missing_tmg_trg,
      LVL1_LONG_TRG_OUT            => int_lvl1_long_trg,
      SPIKE_DETECTED_OUT           => int_spike_detected,

      LVL1_ERROR_PATTERN_IN        => LVL1_ERROR_PATTERN_IN,
      LVL1_TRG_RELEASE_IN          => LVL1_TRG_RELEASE_IN,

      --Stat/Control
      STATUS_OUT                   => stat_lvl1_handler,
      TRG_ENABLE_IN                => buf_REGIO_COMMON_CTRL_REG_OUT(95),
      TRG_INVERT_IN                => buf_REGIO_COMMON_CTRL_REG_OUT(93),
      COUNTERS_STATUS_OUT          => stat_counters_lvl1_handler,
      --Debug
      DEBUG_OUT                    => DEBUG_LVL1_HANDLER_OUT
    );

  TRG_SPIKE_DETECTED_OUT   <= int_spike_detected;
  TRG_SPURIOUS_TRG_OUT     <= int_lvl1_spurious_trg;
  TRG_TIMEOUT_DETECTED_OUT <= int_lvl1_timeout_detected;
  TRG_MULTIPLE_TRG_OUT     <= int_multiple_trg;
  TRG_MISSING_TMG_TRG_OUT  <= int_lvl1_missing_tmg_trg;
  TRG_LONG_TRG_OUT         <= int_lvl1_long_trg;

  

--   THE_TRG_SYNC : signal_sync
--      generic map(
--        DEPTH => 2,
--        WIDTH => 1
--        )
--      port map(
--        RESET    => RESET,
--        D_IN(0)  => TRG_TIMING_TRG_RECEIVED_IN,
--        CLK0     => CLK,
--        CLK1     => CLK,
--        D_OUT(0) => reg_timing_trigger
--        );
--
--
--
--
--   proc_internal_trigger_number : process(CLK)
--     begin
--       if rising_edge(CLK) then
--         if reset_no_link = '1' then
--           int_trigger_num <= (others => '0');
--         elsif LVL1_TRG_RECEIVED_OUT_falling = '1' then
--           int_trigger_num <= int_trigger_num + 1;
--         elsif buf_COMMON_CTRL_REG_STROBE(1) = '1' then
--           int_trigger_num <= buf_REGIO_COMMON_CTRL_REG_OUT(47 downto 32);
--         end if;
--       end if;
--     end process;
--
--   proc_check_trigger_number : process(CLK)
--     begin
--       if rising_edge(CLK) then
--         if reset_no_link = '1' or LVL1_TRG_RECEIVED_OUT_falling = '1' then
--           trigger_number_match <= '1';
--         elsif LVL1_TRG_RECEIVED_OUT_rising = '1' then
--           if int_trigger_num = buf_LVL1_TRG_NUMBER_OUT  then
--             trigger_number_match <= '1';
--           else
--             trigger_number_match <= '0';
--           end if;
--         end if;
--       end if;
--     end process;
--
--
--   proc_detect_trigger_receive : process(CLK)
--     begin
--       if rising_edge(CLK) then
--         last_reg_timing_trigger <= reg_timing_trigger;
--         trigger_timing_rising   <= reg_timing_trigger and not last_reg_timing_trigger; -- and buf_REGIO_COMMON_CTRL_REG_OUT(95);
--
--         last_LVL1_TRG_RECEIVED_OUT <= buf_LVL1_TRG_RECEIVED_OUT;
--         LVL1_TRG_RECEIVED_OUT_rising <= buf_LVL1_TRG_RECEIVED_OUT and not last_LVL1_TRG_RECEIVED_OUT;
--         LVL1_TRG_RECEIVED_OUT_falling <= not buf_LVL1_TRG_RECEIVED_OUT and last_LVL1_TRG_RECEIVED_OUT;
--
--         if reset_no_link = '1' or LVL1_TRG_RECEIVED_OUT_falling = '1' then
--           got_timing_trigger <= '0';
--           got_timingless_trigger <= '0';
--           timing_trigger_missing <= '0';
--         elsif trigger_timing_rising = '1' then --TRG_TIMING_TRG_RECEIVED_IN
--           got_timing_trigger <= '1';
--         elsif (LVL1_TRG_RECEIVED_OUT_rising = '1' and buf_LVL1_TRG_TYPE_OUT >= x"8" and buf_LVL1_TRG_INFORMATION_OUT(7) = '1') then
--           got_timingless_trigger <= '1';
--         elsif (LVL1_TRG_RECEIVED_OUT_rising = '1' and not (buf_LVL1_TRG_TYPE_OUT >= x"8" and buf_LVL1_TRG_INFORMATION_OUT(7) = '1') and got_timing_trigger = '0') then
--           timing_trigger_missing <= '1';
--         end if;
--       end if;
--     end process;
--
--
--   proc_gen_lvl1_error_pattern : process(LVL1_ERROR_PATTERN_IN, trigger_number_match, got_timing_trigger,got_timingless_trigger )
--     begin
--       buf_LVL1_ERROR_PATTERN_IN     <= LVL1_ERROR_PATTERN_IN;
--       buf_LVL1_ERROR_PATTERN_IN(16) <= not trigger_number_match or LVL1_ERROR_PATTERN_IN(16);
--       buf_LVL1_ERROR_PATTERN_IN(17) <= (not got_timing_trigger and not got_timingless_trigger) or LVL1_ERROR_PATTERN_IN(17);
--     end process;
--
--   buf_LVL1_VALID_TIMING_TRG_OUT    <= trigger_timing_rising; --TRG_TIMING_TRG_RECEIVED_IN;
--   buf_LVL1_VALID_NOTIMING_TRG_OUT  <= LVL1_TRG_RECEIVED_OUT_rising and not got_timing_trigger
--                                         and buf_LVL1_TRG_TYPE_OUT(3) and buf_LVL1_TRG_INFORMATION_OUT(7);
--   buf_LVL1_INVALID_TRG_OUT         <= '0';

--   proc_count_timing_trg : process(CLK)
--     begin
--       if rising_edge(CLK) then
--         last_TRG_TIMING_TRG_RECEIVED_IN <= TRG_TIMING_TRG_RECEIVED_IN;
--         last_timingtrg_counter_write <= timingtrg_counter_write;
--         last_timingtrg_counter_read <= timingtrg_counter_read;
--         if RESET = '1' or timingtrg_counter_write = '1' then
--           timingtrg_counter <= (others => '0');
--         elsif TRG_TIMING_TRG_RECEIVED_IN = '1' and last_TRG_TIMING_TRG_RECEIVED_IN = '0' then
--           timingtrg_counter <= (others => '0');
--         end if;
--       end if;
--     end process;



-------------------------------------------------
-- Connect Outputs
-------------------------------------------------
--   buf_LVL1_TRG_RELEASE_IN        <= LVL1_TRG_RELEASE_IN;           --changed back
--   LVL1_TRG_DATA_VALID_OUT        <= buf_LVL1_TRG_RECEIVED_OUT;     --changed back
  LVL1_TRG_DATA_VALID_OUT        <= buf_LVL1_TRG_DATA_VALID_OUT;  --changed back

  LVL1_TRG_VALID_TIMING_OUT      <= buf_LVL1_VALID_TIMING_TRG_OUT;
  LVL1_TRG_VALID_NOTIMING_OUT    <= buf_LVL1_VALID_NOTIMING_TRG_OUT;
  LVL1_TRG_INVALID_OUT           <= buf_LVL1_INVALID_TRG_OUT;

  LVL1_TRG_TYPE_OUT              <= buf_LVL1_TRG_TYPE_OUT;
  LVL1_TRG_NUMBER_OUT            <= buf_LVL1_TRG_NUMBER_OUT;
  LVL1_TRG_CODE_OUT              <= buf_LVL1_TRG_CODE_OUT;
  LVL1_TRG_INFORMATION_OUT       <= buf_LVL1_TRG_INFORMATION_OUT;
  LVL1_INT_TRG_NUMBER_OUT        <= int_trigger_num;

  COMMON_STAT_REG_STROBE         <= buf_COMMON_STAT_REG_STROBE;
  COMMON_CTRL_REG_STROBE         <= buf_COMMON_CTRL_REG_STROBE;
  STAT_REG_STROBE                <= buf_STAT_REG_STROBE;
  CTRL_REG_STROBE                <= buf_CTRL_REG_STROBE;

  TIMER_TICKS_OUT                <= buf_TIMER_TICKS_OUT;
  TEMPERATURE_OUT                <= temperature;
  
  buf_CTRL_GEN                   <= IOBUF_CTRL_GEN;
  REGIO_COMMON_CTRL_REG_OUT      <= buf_REGIO_COMMON_CTRL_REG_OUT;

  STAT_DEBUG_1                   <= REGIO_REGIO_STAT;
  STAT_DEBUG_2(3 downto 0)       <= MED_IO_DATA_OUT(7*16+3 downto 7*16);
  STAT_DEBUG_2(7 downto 4)       <= apl_to_buf_REPLY_DATA(3*16+3 downto 3*16);
  STAT_DEBUG_2(8)                <= apl_to_buf_REPLY_DATAREADY(3);
  STAT_DEBUG_2(11 downto 9)      <= apl_to_buf_REPLY_PACKET_NUM(3*3+2 downto 3*3);
  STAT_DEBUG_2(15 downto 12)     <= (others => '0');
  STAT_DEBUG_2(31 downto 16)     <= buf_STAT_INIT_BUFFER(3*32+15 downto 3*32);

  STAT_TRIGGER_OUT               <= stat_counters_lvl1_handler;

  MY_ADDRESS_OUT                 <= MY_ADDRESS;
  
end architecture;

