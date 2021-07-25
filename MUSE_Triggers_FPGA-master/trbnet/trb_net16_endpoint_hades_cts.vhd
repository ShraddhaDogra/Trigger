LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;


entity trb_net16_endpoint_hades_cts is
  generic(
    USE_CHANNEL              : channel_config_t := (c_YES,c_YES,c_NO,c_YES);
    IBUF_DEPTH               : channel_config_t := (1,6,6,6);
    FIFO_TO_INT_DEPTH        : channel_config_t := (1,1,6,6);
    FIFO_TO_APL_DEPTH        : channel_config_t := (1,6,6,6);
    INIT_CAN_SEND_DATA       : channel_config_t := (c_YES,c_YES,c_NO,c_NO);
    REPLY_CAN_SEND_DATA      : channel_config_t := (c_NO,c_NO,c_NO,c_YES);
    REPLY_CAN_RECEIVE_DATA   : channel_config_t := (c_YES,c_YES,c_NO,c_NO);
    USE_CHECKSUM             : channel_config_t := (c_NO,c_YES,c_YES,c_YES);
    APL_WRITE_ALL_WORDS      : channel_config_t := (c_NO,c_NO,c_NO,c_NO);
    ADDRESS_MASK                 : std_logic_vector(15 downto 0) := x"FFFF";
    BROADCAST_BITMASK        : std_logic_vector(7 downto 0) := x"FF";
    REGIO_NUM_STAT_REGS      : integer range 0 to 6 := 2; --log2 of number of status registers
    REGIO_NUM_CTRL_REGS      : integer range 0 to 6 := 3; --log2 of number of ctrl registers
    --standard values for output registers
    REGIO_INIT_CTRL_REGS     : std_logic_vector(2**(4)*32-1 downto 0) := (others => '0');
    --set to 0 for unused ctrl registers to save resources
    REGIO_USED_CTRL_REGS     : std_logic_vector(2**(4)-1 downto 0)    := x"0001";
    --set to 0 for each unused bit in a register
    REGIO_USED_CTRL_BITMASK  : std_logic_vector(2**(4)*32-1 downto 0) := (others => '1');
    REGIO_USE_DAT_PORT       : integer range 0 to 1 := c_YES;  --internal data port
    REGIO_INIT_ADDRESS       : std_logic_vector(15 downto 0) := x"FFFF";
    REGIO_INIT_UNIQUE_ID     : std_logic_vector(63 downto 0) := x"0000_0000_0000_0000";
    REGIO_INIT_BOARD_INFO    : std_logic_vector(31 downto 0) := x"0000_0000";
    REGIO_INIT_ENDPOINT_ID   : std_logic_vector(15 downto 0) := x"0001";
    REGIO_COMPILE_TIME       : std_logic_vector(31 downto 0) := x"00000000";
    REGIO_INCLUDED_FEATURES  : std_logic_vector(63 downto 0) := (others => '0');
    REGIO_HARDWARE_VERSION   : std_logic_vector(31 downto 0) := x"50000000";
    REGIO_USE_1WIRE_INTERFACE: integer := c_YES; --c_YES,c_NO,c_MONITOR
    REGIO_USE_VAR_ENDPOINT_ID    : integer range c_NO to c_YES := c_NO;
    CLOCK_FREQUENCY          : integer range 1 to 200 := 100
    );
  port(
    CLK       : in  std_logic;
    RESET     : in  std_logic;
    CLK_EN    : in  std_logic;

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

    --LVL1 trigger
    TRG_SEND_IN         : in  std_logic;
    TRG_TYPE_IN         : in  std_logic_vector (3 downto 0);
    TRG_NUMBER_IN       : in  std_logic_vector (15 downto 0);
    TRG_INFORMATION_IN  : in  std_logic_vector (23 downto 0);
    TRG_RND_CODE_IN     : in  std_logic_vector (7 downto 0);
    TRG_STATUS_BITS_OUT : out std_logic_vector (31 downto 0);
    TRG_BUSY_OUT        : out std_logic;

    --IPU Channel
    IPU_SEND_IN         : in  std_logic;
    IPU_TYPE_IN         : in  std_logic_vector (3 downto 0);
    IPU_NUMBER_IN       : in  std_logic_vector (15 downto 0);
    IPU_INFORMATION_IN  : in  std_logic_vector (7 downto 0);
    IPU_RND_CODE_IN     : in  std_logic_vector (7 downto 0);
    -- Receiver port
    IPU_DATA_OUT        : out std_logic_vector (31 downto 0);
    IPU_DATAREADY_OUT   : out std_logic;
    IPU_READ_IN         : in  std_logic;
    IPU_STATUS_BITS_OUT : out std_logic_vector (31 downto 0);
    IPU_BUSY_OUT        : out std_logic;

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
    REGIO_ONEWIRE_INOUT       : inout std_logic;
    REGIO_ONEWIRE_MONITOR_OUT : out std_logic;
    REGIO_ONEWIRE_MONITOR_IN  : in  std_logic;
    REGIO_VAR_ENDPOINT_ID     : in  std_logic_vector(15 downto 0) := (others => '0');
    TRIGGER_MONITOR_IN        : in  std_logic := '0';  --strobe when timing trigger received
    GLOBAL_TIME_OUT           : out std_logic_vector(31 downto 0); --global time, microseconds
    LOCAL_TIME_OUT            : out std_logic_vector(7 downto 0);  --local time running with chip frequency
    TIME_SINCE_LAST_TRG_OUT   : out std_logic_vector(31 downto 0); --local time, resetted with each trigger
    TIMER_TICKS_OUT           : out std_logic_vector(1 downto 0);  --bit 1 ms-tick, 0 us-tick
    STAT_DEBUG_1              : out std_logic_vector(31 downto 0);
    STAT_DEBUG_2              : out std_logic_vector(31 downto 0)
    );

end trb_net16_endpoint_hades_cts;


architecture trb_net16_endpoint_hades_cts_arch of trb_net16_endpoint_hades_cts is

signal apl_to_buf_INIT_DATAREADY  : std_logic_vector (3 downto 0);
signal apl_to_buf_INIT_DATA       : std_logic_vector (4*c_DATA_WIDTH-1 downto 0);
signal tmp_apl_to_buf_INIT_DATA   : std_logic_vector (4*c_DATA_WIDTH-1 downto 0);
signal apl_to_buf_INIT_PACKET_NUM : std_logic_vector (4*c_NUM_WIDTH-1 downto 0);
signal apl_to_buf_INIT_READ       : std_logic_vector (3 downto 0);

signal buf_to_apl_INIT_DATAREADY  : std_logic_vector (3 downto 0);
signal buf_to_apl_INIT_DATA       : std_logic_vector (4*c_DATA_WIDTH-1 downto 0);
signal buf_to_apl_INIT_PACKET_NUM : std_logic_vector (4*c_NUM_WIDTH-1 downto 0);
signal buf_to_apl_INIT_READ       : std_logic_vector (3 downto 0);

signal apl_to_buf_REPLY_DATAREADY : std_logic_vector (3 downto 0);
signal apl_to_buf_REPLY_DATA      : std_logic_vector (4*c_DATA_WIDTH-1 downto 0);
signal apl_to_buf_REPLY_PACKET_NUM: std_logic_vector (4*c_NUM_WIDTH-1 downto 0);
signal apl_to_buf_REPLY_READ      : std_logic_vector (3 downto 0);

signal buf_to_apl_REPLY_DATAREADY : std_logic_vector (3 downto 0);
signal buf_to_apl_REPLY_DATA      : std_logic_vector (4*c_DATA_WIDTH-1 downto 0);
signal buf_to_apl_REPLY_PACKET_NUM: std_logic_vector (4*c_NUM_WIDTH-1 downto 0);
signal buf_to_apl_REPLY_READ      : std_logic_vector (3 downto 0);

-- for the connection to the multiplexer
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

signal reg_extended_trigger_information : std_logic_vector(15 downto 0);
signal buf_TRG_STATUS_BITS_OUT : std_logic_vector(31 downto 0);
signal buf_IPU_STATUS_BITS_OUT : std_logic_vector(31 downto 0);
signal buf_IPU_DATA_OUT : std_logic_vector(31 downto 0);
signal buf_IPU_DATAREADY_OUT : std_logic;

signal buf_api_stat_fifo_to_apl, buf_api_stat_fifo_to_int : std_logic_vector (4*32-1 downto 0);
signal buf_STAT_GEN : std_logic_vector(32*4-1 downto 0);
signal buf_STAT_INIT_BUFFER : std_logic_vector(32*4-1 downto 0);
signal buf_CTRL_GEN : std_logic_vector(32*4-1 downto 0);
signal buf_STAT_INIT_OBUF_DEBUG      : std_logic_vector (32*4-1 downto 0);
signal buf_STAT_REPLY_OBUF_DEBUG     : std_logic_vector (32*4-1 downto 0);
signal REGIO_REGIO_STAT : std_logic_vector(31 downto 0);
signal STAT_ADDR_DEBUG  : std_logic_vector(15 downto 0);
signal STAT_ONEWIRE     : std_logic_vector(31 downto 0);

signal buf_IDRAM_DATA_IN       :  std_logic_vector(15 downto 0);
signal buf_IDRAM_DATA_OUT      :  std_logic_vector(15 downto 0);
signal buf_IDRAM_ADDR_IN       :  std_logic_vector(2 downto 0);
signal buf_IDRAM_WR_IN         :  std_logic;
signal MY_ADDRESS : std_logic_vector(15 downto 0);

signal STAT_MPLEX : std_logic_vector(31 downto 0);
signal CTRL_MPLEX : std_logic_vector(31 downto 0):=(others => '0');


signal buf_COMMON_STAT_REG_IN: std_logic_vector(std_COMSTATREG*32-1 downto 0);
signal buf_REGIO_COMMON_CTRL_REG_OUT : std_logic_vector(std_COMCTRLREG*32-1 downto 0);

signal reset_no_link          :  std_logic;
signal buf_TIMER_TICKS        : std_logic_vector(1 downto 0);


begin


-------------------------------------------------------------------------------
--Media Interface Signals
-------------------------------------------------------------------------------
  reset_no_link <= MED_STAT_OP_IN(14) or RESET;
  MED_CTRL_OP_OUT(15) <= MED_STAT_OP_IN(15);
  MED_CTRL_OP_OUT(14 downto 0) <= (others => '0');

  TIMER_TICKS_OUT <= buf_TIMER_TICKS;
-------------------------------------------------------------------------------
--IO-Buffers
-------------------------------------------------------------------------------
    genbuffers : for i in 0 to 3 generate
      geniobuf: if USE_CHANNEL(i) = c_YES generate
        IOBUF: trb_net16_iobuf
          generic map (
            IBUF_DEPTH          => IBUF_DEPTH(i),
            IBUF_SECURE_MODE    => c_SECURE_MODE,
            SBUF_VERSION        => 0,
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
            MED_DATA_IN        => MED_IO_DATA_IN(i*16+15 downto i*16),
            MED_PACKET_NUM_IN  => MED_IO_PACKET_NUM_IN(i*3+2 downto i*3),
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
            TIMER_TICKS_IN         => buf_TIMER_TICKS,
            CTRL_STAT              => (others => '0')            
            );

-------------------------------------------------------------------------------
--Active API on channel 0 & 1
-------------------------------------------------------------------------------
      gen_api_act : if i /= c_SLOW_CTRL_CHANNEL generate
        constant j : integer := i;
      begin
        DAT_ACTIVE_API: trb_net16_api_base
          generic map (
            API_TYPE          => c_API_ACTIVE,
            FIFO_TO_INT_DEPTH => FIFO_TO_INT_DEPTH(i),
            FIFO_TO_APL_DEPTH => FIFO_TO_APL_DEPTH(i),
            FORCE_REPLY       => cfg_FORCE_REPLY(i),
            SBUF_VERSION      => 0,
            USE_VENDOR_CORES   => c_YES,
            SECURE_MODE_TO_APL => c_YES,
            SECURE_MODE_TO_INT => c_YES,
            APL_WRITE_ALL_WORDS=> APL_WRITE_ALL_WORDS(i),
            BROADCAST_BITMASK  => BROADCAST_BITMASK
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
            INT_MASTER_DATAREADY_OUT => apl_to_buf_INIT_DATAREADY(i),
            INT_MASTER_DATA_OUT      => tmp_apl_to_buf_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_MASTER_PACKET_NUM_OUT=> apl_to_buf_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_MASTER_READ_IN       => apl_to_buf_INIT_READ(i),
            INT_MASTER_DATAREADY_IN  => buf_to_apl_INIT_DATAREADY(i),
            INT_MASTER_DATA_IN       => buf_to_apl_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_MASTER_PACKET_NUM_IN => buf_to_apl_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_MASTER_READ_OUT      => buf_to_apl_INIT_READ(i),
            INT_SLAVE_DATAREADY_OUT  => apl_to_buf_REPLY_DATAREADY(i),
            INT_SLAVE_DATA_OUT       => apl_to_buf_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_SLAVE_PACKET_NUM_OUT => apl_to_buf_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_SLAVE_READ_IN        => apl_to_buf_REPLY_READ(i),
            INT_SLAVE_DATAREADY_IN => buf_to_apl_REPLY_DATAREADY(i),
            INT_SLAVE_DATA_IN      => buf_to_apl_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_SLAVE_PACKET_NUM_IN=> buf_to_apl_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_SLAVE_READ_OUT     => buf_to_apl_REPLY_READ(i),
            -- Status and control port
            CTRL_SEQNR_RESET =>  buf_REGIO_COMMON_CTRL_REG_OUT(10),
            STAT_FIFO_TO_INT => buf_api_stat_fifo_to_int((i+1)*32-1 downto i*32),
            STAT_FIFO_TO_APL => buf_api_stat_fifo_to_apl((i+1)*32-1 downto i*32)
            );
        end generate;

-------------------------------------------------------------------------------
--Passive API on channel 3
-------------------------------------------------------------------------------
     gen_api_pas : if i = c_SLOW_CTRL_CHANNEL generate
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
            SECURE_MODE_TO_APL => c_YES,
            SECURE_MODE_TO_INT => c_YES,
            APL_WRITE_ALL_WORDS=> APL_WRITE_ALL_WORDS(i),
            BROADCAST_BITMASK  => BROADCAST_BITMASK
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
            INT_MASTER_DATAREADY_OUT  => apl_to_buf_REPLY_DATAREADY(i),
            INT_MASTER_DATA_OUT       => apl_to_buf_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_MASTER_PACKET_NUM_OUT => apl_to_buf_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_MASTER_READ_IN        => apl_to_buf_REPLY_READ(i),
            INT_MASTER_DATAREADY_IN => buf_to_apl_REPLY_DATAREADY(i),
            INT_MASTER_DATA_IN      => buf_to_apl_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_MASTER_PACKET_NUM_IN=> buf_to_apl_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_MASTER_READ_OUT     => buf_to_apl_REPLY_READ(i),
            INT_SLAVE_DATAREADY_OUT => apl_to_buf_INIT_DATAREADY(i),
            INT_SLAVE_DATA_OUT      => tmp_apl_to_buf_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_SLAVE_PACKET_NUM_OUT=> apl_to_buf_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_SLAVE_READ_IN       => apl_to_buf_INIT_READ(i),
            INT_SLAVE_DATAREADY_IN  => buf_to_apl_INIT_DATAREADY(i),
            INT_SLAVE_DATA_IN       => buf_to_apl_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_SLAVE_PACKET_NUM_IN => buf_to_apl_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_SLAVE_READ_OUT      => buf_to_apl_INIT_READ(i),
            -- Status and control port
            CTRL_SEQNR_RESET =>  buf_REGIO_COMMON_CTRL_REG_OUT(10),
            STAT_FIFO_TO_INT => buf_api_stat_fifo_to_int((i+1)*32-1 downto i*32),
            STAT_FIFO_TO_APL => buf_api_stat_fifo_to_apl((i+1)*32-1 downto i*32)
            );
        end generate;
      end generate;

-------------------------------------------------------------------------------
--Unused channels: 2
-------------------------------------------------------------------------------
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
        tmp_apl_to_buf_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');
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
            MED_DATA_IN            => MED_IO_DATA_IN(i*16+15 downto i*16),
            MED_PACKET_NUM_IN      => MED_IO_PACKET_NUM_IN(i*3+2 downto i*3),
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

-------------------------------------------------------------------------------
--Multiplexer
-------------------------------------------------------------------------------
  MPLEX: trb_net16_io_multiplexer
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
      STAT               => STAT_MPLEX,
      CTRL               => CTRL_MPLEX
      );


-------------------------------------------------------------------------------
--LVL1 Trigger
-------------------------------------------------------------------------------

  buf_APL_DATA_IN(15 downto 0)           <= (others =>  '0');
  buf_APL_PACKET_NUM_IN(2 downto 0)      <= (others =>  '0');
  buf_APL_READ_IN(0)                     <= '1';
  buf_APL_DATAREADY_IN(0)                <= '0';
  buf_APL_SHORT_TRANSFER_IN(0)           <= '1';
  buf_APL_SEND_IN(0)                     <= TRG_SEND_IN;
  buf_APL_DTYPE_IN(3 downto 0)           <= TRG_TYPE_IN;
  buf_APL_ERROR_PATTERN_IN(15 downto  0) <= TRG_NUMBER_IN;
  buf_APL_ERROR_PATTERN_IN(23 downto 16) <= TRG_RND_CODE_IN;
  buf_APL_ERROR_PATTERN_IN(31 downto 24) <= TRG_INFORMATION_IN(7 downto 0);
  TRG_BUSY_OUT                           <= buf_APL_RUN_OUT(0);
  TRG_STATUS_BITS_OUT                    <= buf_TRG_STATUS_BITS_OUT;

  PROC_TRG_STATUS_BITS : process(CLK)
    begin
      if rising_edge(CLK) then
        if buf_APL_PACKET_NUM_OUT(2 downto 0) = c_F1 and buf_APL_TYP_OUT(2 downto 0) = TYPE_TRM then
          buf_TRG_STATUS_BITS_OUT(31 downto 16) <= buf_APL_DATA_OUT(15 downto 0);
        end if;
      if buf_APL_PACKET_NUM_OUT(2 downto 0) = c_F2 and buf_APL_TYP_OUT(2 downto 0) = TYPE_TRM then
        buf_TRG_STATUS_BITS_OUT(15 downto 0) <= buf_APL_DATA_OUT(15 downto 0);
      end if;
    end if;
    end process;

--Add additional word for trigger information
  apl_to_buf_INIT_DATA(apl_to_buf_INIT_DATA'left downto 16) <= tmp_apl_to_buf_INIT_DATA(apl_to_buf_INIT_DATA'left downto 16);

  proc_add_trigger_info : process(tmp_apl_to_buf_INIT_DATA, apl_to_buf_INIT_PACKET_NUM,reg_extended_trigger_information)
    begin
      if apl_to_buf_INIT_PACKET_NUM(2 downto 0) = c_F0 then
        apl_to_buf_INIT_DATA(15 downto 0) <= reg_extended_trigger_information;
      else
        apl_to_buf_INIT_DATA(15 downto 0) <= tmp_apl_to_buf_INIT_DATA(15 downto 0);
      end if;
    end process;

  proc_save_trigger_info : process(CLK)
    begin
      if rising_edge(CLK) then
        if TRG_SEND_IN = '1' then
          reg_extended_trigger_information <= TRG_INFORMATION_IN(23 downto 8);
        end if;
      end if;
    end process;


-------------------------------------------------------------------------------
--IPU Channel
-------------------------------------------------------------------------------

  buf_APL_DATA_IN(31 downto 16)          <= (others =>  '0');
  buf_APL_PACKET_NUM_IN(5 downto 3)      <= (others =>  '0');
  buf_APL_DATAREADY_IN(1)                <= '0';
  buf_APL_SHORT_TRANSFER_IN(1)           <= '1';
  buf_APL_READ_IN(1)                     <= IPU_READ_IN;
  buf_APL_SEND_IN(1)                     <= IPU_SEND_IN;
  buf_APL_DTYPE_IN(7 downto 4)           <= IPU_TYPE_IN;
  buf_APL_ERROR_PATTERN_IN(47 downto 32) <= IPU_NUMBER_IN;
  buf_APL_ERROR_PATTERN_IN(55 downto 48) <= IPU_RND_CODE_IN;
  buf_APL_ERROR_PATTERN_IN(63 downto 56) <= IPU_INFORMATION_IN;
  IPU_BUSY_OUT                           <= buf_APL_RUN_OUT(1);
  IPU_STATUS_BITS_OUT                    <= buf_IPU_STATUS_BITS_OUT;
  IPU_DATA_OUT                           <= buf_IPU_DATA_OUT;
  IPU_DATAREADY_OUT                      <= buf_IPU_DATAREADY_OUT;

  PROC_IPU_STATUS_BITS : process(CLK)
    begin
      if rising_edge(CLK) then
        if buf_APL_PACKET_NUM_OUT(5 downto 3) = c_F1 and buf_APL_TYP_OUT(5 downto 3) = TYPE_TRM then
          buf_IPU_STATUS_BITS_OUT(31 downto 16) <= buf_APL_DATA_OUT(31 downto 16);
        end if;
        if buf_APL_PACKET_NUM_OUT(5 downto 3) = c_F2 and buf_APL_TYP_OUT(5 downto 3) = TYPE_TRM then
          buf_IPU_STATUS_BITS_OUT(15 downto 0) <= buf_APL_DATA_OUT(31 downto 16);
        end if;
      end if;
    end process;

  PROC_IPU_DATA : process(CLK)
    begin
      if rising_edge(CLK) then
        if IPU_READ_IN = '1' then
          buf_IPU_DATAREADY_OUT <= '0';
        end if;
        if buf_APL_READ_IN(1) = '1' and buf_APL_DATAREADY_OUT(1) = '1' and buf_APL_TYP_OUT(5 downto 3) = TYPE_DAT then
          if buf_APL_PACKET_NUM_OUT(5 downto 3) = c_F0 or buf_APL_PACKET_NUM_OUT(5 downto 3) = c_F2 then
            buf_IPU_DATA_OUT(31 downto 16) <= buf_APL_DATA_OUT(31 downto 16);
          elsif buf_APL_PACKET_NUM_OUT(5 downto 3) = c_F1 or buf_APL_PACKET_NUM_OUT(5 downto 3) = c_F3 then
            buf_IPU_DATA_OUT(15 downto  0) <= buf_APL_DATA_OUT(31 downto 16);
            buf_IPU_DATAREADY_OUT <= '1';
          end if;
        end if;
      end if;
    end process;



-------------------------------------------------------------------------------
--RegIO
-------------------------------------------------------------------------------
  buf_APL_LENGTH_IN((3+1)*16-1 downto 3*16) <= (others => '1');
  REGIO_COMMON_CTRL_REG_OUT <= buf_REGIO_COMMON_CTRL_REG_OUT;

  regIO : trb_net16_regIO
    generic map(
      NUM_STAT_REGS      => REGIO_NUM_STAT_REGS,
      NUM_CTRL_REGS      => REGIO_NUM_CTRL_REGS,
      INIT_CTRL_REGS     => REGIO_INIT_CTRL_REGS,
      USED_CTRL_REGS     => REGIO_USED_CTRL_REGS,
      USED_CTRL_BITMASK  => REGIO_USED_CTRL_BITMASK,
      USE_DAT_PORT       => REGIO_USE_DAT_PORT,
      INIT_ADDRESS       => REGIO_INIT_ADDRESS,
      INIT_BOARD_INFO    => REGIO_INIT_BOARD_INFO,
      INIT_UNIQUE_ID     => REGIO_INIT_UNIQUE_ID,
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
      API_DATA_OUT           => buf_APL_DATA_IN((3+1)*c_DATA_WIDTH-1 downto 3*c_DATA_WIDTH),
      API_PACKET_NUM_OUT     => buf_APL_PACKET_NUM_IN((3+1)*c_NUM_WIDTH-1 downto 3*c_NUM_WIDTH),
      API_DATAREADY_OUT      => buf_APL_DATAREADY_IN(3),
      API_READ_IN            => buf_APL_READ_OUT(3),
      API_SHORT_TRANSFER_OUT => buf_APL_SHORT_TRANSFER_IN(3),
      API_DTYPE_OUT          => buf_APL_DTYPE_IN((3+1)*4-1 downto 3*4),
      API_ERROR_PATTERN_OUT  => buf_APL_ERROR_PATTERN_IN((3+1)*32-1 downto 3*32),
      API_SEND_OUT           => buf_APL_SEND_IN(3),
      API_DATA_IN            => buf_APL_DATA_OUT((3+1)*c_DATA_WIDTH-1 downto 3*c_DATA_WIDTH),
      API_PACKET_NUM_IN      => buf_APL_PACKET_NUM_OUT((3+1)*c_NUM_WIDTH-1 downto 3*c_NUM_WIDTH),
      API_TYP_IN             => buf_APL_TYP_OUT((3+1)*3-1 downto 3*3),
      API_DATAREADY_IN       => buf_APL_DATAREADY_OUT(3),
      API_READ_OUT           => buf_APL_READ_IN(3),
      API_RUN_IN             => buf_APL_RUN_OUT(3),
      API_SEQNR_IN           => buf_APL_SEQNR_OUT((3+1)*8-1 downto 3*8),
    --Port to write Unique ID
      IDRAM_DATA_IN          => buf_IDRAM_DATA_IN,
      IDRAM_DATA_OUT         => buf_IDRAM_DATA_OUT,
      IDRAM_ADDR_IN          => buf_IDRAM_ADDR_IN,
      IDRAM_WR_IN            => buf_IDRAM_WR_IN,
      MY_ADDRESS_OUT         => MY_ADDRESS,
      TRIGGER_MONITOR        => TRIGGER_MONITOR_IN,
      GLOBAL_TIME            => GLOBAL_TIME_OUT,
      LOCAL_TIME             => LOCAL_TIME_OUT,
      TIME_SINCE_LAST_TRG    => TIME_SINCE_LAST_TRG_OUT,
      TIMER_US_TICK          => buf_TIMER_TICKS(0),
      TIMER_MS_TICK          => buf_TIMER_TICKS(1),
    --Common Register in / out
      COMMON_STAT_REG_IN     => buf_COMMON_STAT_REG_IN,
      COMMON_CTRL_REG_OUT    => buf_REGIO_COMMON_CTRL_REG_OUT,
    --Custom Register in / out
      REGISTERS_IN           => REGIO_REGISTERS_IN,
      REGISTERS_OUT          => REGIO_REGISTERS_OUT,
      COMMON_STAT_REG_STROBE => COMMON_STAT_REG_STROBE,
      COMMON_CTRL_REG_STROBE => COMMON_CTRL_REG_STROBE,
      STAT_REG_STROBE        => STAT_REG_STROBE,
      CTRL_REG_STROBE        => CTRL_REG_STROBE,
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


-------------------------------------------------------------------------------
--1-wire
-------------------------------------------------------------------------------

  gen_no1wire : if REGIO_USE_1WIRE_INTERFACE = c_NO generate
    buf_IDRAM_DATA_IN <= (others => '0');
    buf_IDRAM_ADDR_IN <= (others => '0');
    buf_IDRAM_WR_IN   <= '0';
    REGIO_ONEWIRE_INOUT <= '0';
    REGIO_ONEWIRE_MONITOR_OUT <= '0';
    buf_COMMON_STAT_REG_IN <= REGIO_COMMON_STAT_REG_IN;
  end generate;

  gen_1wire : if REGIO_USE_1WIRE_INTERFACE = c_YES generate
    buf_COMMON_STAT_REG_IN(19 downto 0) <= REGIO_COMMON_STAT_REG_IN(19 downto 0);
    buf_COMMON_STAT_REG_IN(REGIO_COMMON_STAT_REG_IN'left downto 32) <=
                    REGIO_COMMON_STAT_REG_IN(REGIO_COMMON_STAT_REG_IN'left downto 32);


    the_onewire_interface : trb_net_onewire
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
        DATA_OUT => buf_IDRAM_DATA_IN,
        ADDR_OUT => buf_IDRAM_ADDR_IN,
        WRITE_OUT=> buf_IDRAM_WR_IN,
        TEMP_OUT => buf_COMMON_STAT_REG_IN(31 downto 20),
        STAT     => STAT_ONEWIRE
        );
  end generate;

  gen_1wire_monitor : if REGIO_USE_1WIRE_INTERFACE = c_MONITOR generate
    buf_COMMON_STAT_REG_IN(19 downto 0) <= REGIO_COMMON_STAT_REG_IN(19 downto 0);
    buf_COMMON_STAT_REG_IN(REGIO_COMMON_STAT_REG_IN'left downto 32) <=
                    REGIO_COMMON_STAT_REG_IN(REGIO_COMMON_STAT_REG_IN'left downto 32);
    REGIO_ONEWIRE_MONITOR_OUT <= '0';

    the_onewire_interface : trb_net_onewire_listener
      port map(
        CLK      => CLK,
        CLK_EN   => CLK_EN,
        RESET    => RESET,
        --connection to 1-wire interface
        MONITOR_IN => REGIO_ONEWIRE_MONITOR_IN,
        --connection to id ram, according to memory map in TrbNetRegIO
        DATA_OUT => buf_IDRAM_DATA_IN,
        ADDR_OUT => buf_IDRAM_ADDR_IN,
        WRITE_OUT=> buf_IDRAM_WR_IN,
        TEMP_OUT => buf_COMMON_STAT_REG_IN(31 downto 20),
        STAT     => STAT_ONEWIRE
        );
  end generate;




-------------------------------------------------------------------------------
--Debugging
-------------------------------------------------------------------------------

  --STAT_DEBUG_1 <= STAT_MPLEX;
  STAT_DEBUG_2(3 downto 0)  <= MED_IO_DATA_OUT(7*16+3 downto 7*16);
  STAT_DEBUG_2(7 downto 4)  <= apl_to_buf_REPLY_DATA(3*16+3 downto 3*16);
  STAT_DEBUG_2(8)           <= apl_to_buf_REPLY_DATAREADY(3);
  STAT_DEBUG_2(11 downto 9) <= apl_to_buf_REPLY_PACKET_NUM(3*3+2 downto 3*3);
  STAT_DEBUG_2(15 downto 12) <= (others => '0');
  STAT_DEBUG_2(31 downto 16) <= buf_STAT_INIT_BUFFER(3*32+15 downto 3*32);

  STAT_DEBUG_1 <= (others => '0');

end architecture;
