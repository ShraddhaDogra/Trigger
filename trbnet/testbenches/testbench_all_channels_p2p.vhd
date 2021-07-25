LIBRARY ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net16_hub_func.all;


entity testbench is
end entity testbench;

architecture testbench_arch of testbench is

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

  component trb_net16_endpoint_hades_full is
    generic (
      USE_CHANNEL                  : channel_config_t := (c_YES,c_YES,c_NO,c_YES);
      IBUF_DEPTH                   : channel_config_t := (6,6,6,6);
      FIFO_TO_INT_DEPTH            : channel_config_t := (6,6,6,6);
      FIFO_TO_APL_DEPTH            : channel_config_t := (6,6,6,6);
      IBUF_SECURE_MODE             : channel_config_t := (c_YES,c_YES,c_YES,c_NO);
      API_SECURE_MODE_TO_APL       : channel_config_t := (c_YES,c_YES,c_YES,c_YES);
      API_SECURE_MODE_TO_INT       : channel_config_t := (c_YES,c_YES,c_YES,c_YES);
      OBUF_DATA_COUNT_WIDTH        : integer range 0 to 7 := std_DATA_COUNT_WIDTH;
      INIT_CAN_SEND_DATA           : channel_config_t := (c_YES,c_YES,c_YES,c_YES);
      REPLY_CAN_SEND_DATA          : channel_config_t := (c_YES,c_YES,c_YES,c_YES);
      REPLY_CAN_RECEIVE_DATA       : channel_config_t := (c_NO,c_NO,c_NO,c_YES);
      USE_CHECKSUM                 : channel_config_t := (c_NO,c_YES,c_YES,c_YES);
      APL_WRITE_ALL_WORDS          : channel_config_t := (c_NO,c_NO,c_NO,c_NO);
      BROADCAST_BITMASK            : std_logic_vector(7 downto 0) := x"FF";
      REGIO_NUM_STAT_REGS      : integer range 0 to 6 := 3; --log2 of number of status registers
      REGIO_NUM_CTRL_REGS      : integer range 0 to 6 := 3; --log2 of number of ctrl registers
      --standard values for output registers
      REGIO_INIT_CTRL_REGS     : std_logic_vector(2**(3)*32-1 downto 0) := (others => '0');
      --set to 0 for unused ctrl registers to save resources
      REGIO_USED_CTRL_REGS     : std_logic_vector(2**(3)-1 downto 0)    := "00000001";
      --set to 0 for each unused bit in a register
      REGIO_USED_CTRL_BITMASK  : std_logic_vector(2**(3)*32-1 downto 0) := (others => '1');
      REGIO_USE_DAT_PORT       : integer range 0 to 1 := c_YES;  --internal data port
      REGIO_INIT_ADDRESS       : std_logic_vector(15 downto 0) := x"F00E";
      REGIO_INIT_UNIQUE_ID     : std_logic_vector(63 downto 0) := x"1000_2000_3654_4876";
      REGIO_INIT_BOARD_INFO    : std_logic_vector(31 downto 0) := x"1111_2222";
      REGIO_INIT_ENDPOINT_ID   : std_logic_vector(15 downto 0) := x"0001";
      REGIO_COMPILE_TIME       : std_logic_vector(31 downto 0) := x"00000000";
      REGIO_COMPILE_VERSION    : std_logic_vector(15 downto 0) := x"0001";
      REGIO_HARDWARE_VERSION   : std_logic_vector(31 downto 0) := x"12345678";
      REGIO_USE_1WIRE_INTERFACE: integer := c_YES
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

      -- LVL1 trigger APL
      LVL1_TRG_TYPE_OUT      : out std_logic_vector(3 downto 0);
      LVL1_TRG_RECEIVED_OUT  : out std_logic;
      LVL1_TRG_NUMBER_OUT    : out std_logic_vector(15 downto 0);
      LVL1_TRG_CODE_OUT      : out std_logic_vector(7 downto 0);
      LVL1_TRG_INFORMATION_OUT : out std_logic_vector(7 downto 0);
      LVL1_ERROR_PATTERN_IN  : in  std_logic_vector(31 downto 0) := x"00000000";
      LVL1_TRG_RELEASE_IN    : in  std_logic := '0';


      --Data Port
      IPU_NUMBER_OUT   : out std_logic_vector (15 downto 0);
      IPU_INFORMATION_OUT  : out std_logic_vector (7 downto 0);
      --start strobe
      IPU_START_READOUT_OUT: out std_logic;
      --detector data, equipped with DHDR
      IPU_DATA_IN          : in  std_logic_vector (31 downto 0);
      IPU_DATAREADY_IN     : in  std_logic;
      --no more data, end transfer, send TRM
      IPU_READOUT_FINISHED_IN : in  std_logic;
      --will be low every second cycle due to 32bit -> 16bit conversion
      IPU_READ_OUT         : out std_logic;
      IPU_LENGTH_IN        : in  std_logic_vector (15 downto 0);
      IPU_ERROR_PATTERN_IN : in  std_logic_vector (31 downto 0);

      -- Slow Control Data Port
      REGIO_COMMON_STAT_REG_IN  : in  std_logic_vector(std_COMSTATREG*32-1 downto 0) := (others => '0');
      REGIO_COMMON_CTRL_REG_OUT : out std_logic_vector(std_COMCTRLREG*32-1 downto 0);
      REGIO_REGISTERS_IN        : in  std_logic_vector(32*2**(REGIO_NUM_STAT_REGS)-1 downto 0) := (others => '0');
      REGIO_REGISTERS_OUT       : out std_logic_vector(32*2**(REGIO_NUM_CTRL_REGS)-1 downto 0);
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
      REGIO_ONEWIRE_INOUT       : inout std_logic;
      --Additional r/w access to ctrl registers
      REGIO_EXT_REG_DATA_IN     : in  std_logic_vector(31 downto 0) := (others => '0');
      REGIO_EXT_REG_DATA_OUT    : out std_logic_vector(31 downto 0);
      REGIO_EXT_REG_WRITE_IN    : in  std_logic := '0';
      REGIO_EXT_REG_ADDR_IN     : in  std_logic_vector(7 downto 0) := (others => '0');

      STAT_DEBUG_IPU            : out std_logic_vector (31 downto 0);
      STAT_DEBUG_1              : out std_logic_vector (31 downto 0);
      STAT_DEBUG_2              : out std_logic_vector (31 downto 0);
      MED_STAT_OP               : out std_logic_vector (15 downto 0);
      CTRL_MPLEX                : in  std_logic_vector (31 downto 0);
      IOBUF_CTRL_GEN            : in  std_logic_vector (4*32-1 downto 0);
      STAT_ONEWIRE              : out std_logic_vector (31 downto 0)
      );
  end component;


  component trb_net16_dummy_apl is
    generic (
      TARGET_ADDRESS : std_logic_vector (15 downto 0) := x"ffff";
      PREFILL_LENGTH  : integer := 1;
      TRANSFER_LENGTH  : integer := 5  -- length of dummy data
                                    -- might not work with transfer_length > api_fifo
                                    -- because of incorrect handling of fifo_full_in!
                                    -- shorttransfer is not working too
      );
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      -- APL Transmitter port
      APL_DATA_OUT:       out std_logic_vector (15 downto 0); -- Data word "application to network"
      APL_PACKET_NUM_OUT: out std_logic_vector (2 downto 0);
      APL_DATAREADY_OUT:      out std_logic; -- Data word is valid and should be transmitted
      APL_READ_IN:   in  std_logic; -- Stop transfer, the fifo is full
      APL_SHORT_TRANSFER_OUT: out std_logic; --
      APL_DTYPE_OUT:      out std_logic_vector (3 downto 0);  -- see NewTriggerBusNetworkDescr
      APL_ERROR_PATTERN_OUT: out std_logic_vector (31 downto 0); -- see NewTriggerBusNetworkDescr
      APL_SEND_OUT:       out std_logic; -- Release sending of the data
      APL_TARGET_ADDRESS_OUT: out std_logic_vector (15 downto 0); -- Address of
                                                                -- the target (only for active APIs)
      -- Receiver port
      APL_DATA_IN:      in  std_logic_vector (15 downto 0); -- Data word "network to application"
      APL_PACKET_NUM_IN:in  std_logic_vector (2 downto 0);
      APL_TYP_IN:       in  std_logic_vector (2 downto 0);  -- Which kind of data word: DAT, HDR or TRM
      APL_DATAREADY_IN: in  std_logic; -- Data word is valid and might be read out
      APL_READ_OUT:     out std_logic; -- Read data word
      -- APL Control port
      APL_RUN_IN:       in std_logic; -- Data transfer is running
  --    APL_MY_ADDRESS_OUT: in  std_logic_vector (15 downto 0);  -- My own address (temporary solution!!!)
      APL_SEQNR_IN:     in std_logic_vector (7 downto 0)
      );
  end component;

  component trb_net16_med_16_CC is
    port(
      CLK    : in std_logic;
      CLK_EN : in std_logic;
      RESET  : in std_logic;

      --Internal Connection
      MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_IN   : in  std_logic;
      MED_READ_OUT       : out std_logic;
      MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic;
      MED_READ_IN        : in  std_logic;

      DATA_OUT           : out std_logic_vector(15 downto 0);
      DATA_VALID_OUT     : out std_logic;
      DATA_CTRL_OUT      : out std_logic;
      DATA_IN            : in  std_logic_vector(15 downto 0);
      DATA_VALID_IN      : in  std_logic;
      DATA_CTRL_IN       : in  std_logic;

      STAT_OP            : out std_logic_vector(15 downto 0);
      CTRL_OP            : in  std_logic_vector(15 downto 0);
      STAT_DEBUG         : out std_logic_vector(63 downto 0)
      );
  end component;

  signal CLK : std_logic := '1';
  signal RESET : std_logic := '1';
  signal CLK_EN : std_logic := '1';

  signal MED_DATAREADY_IN   : std_logic;
  signal MED_READ_IN        : std_logic;
  signal MED_DATAREADY_OUT  : std_logic;
  signal MED_READ_OUT       : std_logic;
  signal MED_PACKET_NUM_OUT : std_logic_vector(2 downto 0);
  signal MED_PACKET_NUM_IN  : std_logic_vector(2 downto 0);
  signal MED_DATA_IN        : std_logic_vector(15 downto 0);
  signal MED_DATA_OUT       : std_logic_vector(15 downto 0);
  signal MED_R_DATAREADY_IN   : std_logic;
  signal MED_R_READ_IN        : std_logic;
  signal MED_R_DATAREADY_OUT  : std_logic;
  signal MED_R_READ_OUT       : std_logic;
  signal MED_R_PACKET_NUM_OUT : std_logic_vector(2 downto 0);
  signal MED_R_PACKET_NUM_IN  : std_logic_vector(2 downto 0);
  signal MED_R_DATA_IN        : std_logic_vector(15 downto 0);
  signal MED_R_DATA_OUT       : std_logic_vector(15 downto 0);
  signal MED_STAT_OP     : std_logic_vector(31 downto 0);
  signal MED_CTRL_OP    : std_logic_vector(31 downto 0);

  signal LVL1_TRG_TYPE_OUT : std_logic_vector(3 downto 0);
  signal LVL1_TRG_RECEIVED_OUT : std_logic;
  signal LVL1_TRG_NUMBER_OUT : std_logic_vector(15 downto 0);
  signal LVL1_TRG_CODE_OUT : std_logic_vector(7 downto 0);
  signal LVL1_TRG_INFORMATION_OUT : std_logic_vector(7 downto 0);
  signal LVL1_ERROR_PATTERN_IN  : std_logic_vector(31 downto 0);
  signal LVL1_TRG_RELEASE_IN : std_logic;

  signal IPU_NUMBER_OUT : std_logic_vector(15 downto 0);
  signal IPU_INFORMATION_OUT : std_logic_vector(7 downto 0);
  signal IPU_START_READOUT_OUT : std_logic;
  signal IPU_DATA_IN : std_logic_vector(31 downto 0);
  signal IPU_DATAREADY_IN : std_logic;
  signal IPU_READOUT_FINISHED_IN : std_logic;
  signal IPU_READ_OUT : std_logic;
  signal IPU_LENGTH_IN : std_logic_vector(15 downto 0);
  signal IPU_ERROR_PATTERN_IN : std_logic_vector(31 downto 0);
  signal ipu_answer_delay : std_logic_vector(11 downto 0);

  signal REGIO_COMMON_STAT_REG_IN : std_logic_vector(std_COMSTATREG*32-1 downto 0);
  signal REGIO_COMMON_CTRL_REG_OUT : std_logic_vector(std_COMCTRLREG*32-1 downto 0);
  signal REGIO_REGISTERS_IN : std_logic_vector(32*2**(3)-1 downto 0);
  signal REGIO_REGISTERS_OUT : std_logic_vector(32*2**(3)-1 downto 0);
  signal REGIO_ADDR_OUT : std_logic_vector(15 downto 0);
  signal REGIO_READ_ENABLE_OUT : std_logic;
  signal REGIO_WRITE_ENABLE_OUT : std_logic;
  signal REGIO_DATA_OUT : std_logic_vector(31 downto 0);
  signal REGIO_DATA_IN : std_logic_vector(31 downto 0);
  signal REGIO_DATAREADY_IN : std_logic;
  signal REGIO_NO_MORE_DATA_IN : std_logic;
  signal REGIO_WRITE_ACK_IN : std_logic;
  signal REGIO_UNKNOWN_ADDR_IN : std_logic;
  signal REGIO_TIMEOUT_OUT : std_logic;
  signal REGIO_IDRAM_DATA_IN : std_logic_vector(15 downto 0);
  signal REGIO_IDRAM_DATA_OUT : std_logic_vector(15 downto 0);
  signal REGIO_IDRAM_ADDR_IN : std_logic_vector(2 downto 0);
  signal REGIO_IDRAM_WR_IN : std_logic;
  signal REGIO_ONEWIRE_INOUT : std_logic;
  signal REGIO_EXT_REG_DATA_IN : std_logic_vector(31 downto 0);
  signal REGIO_EXT_REG_DATA_OUT : std_logic_vector(31 downto 0);
  signal REGIO_EXT_REG_WRITE_IN : std_logic;
  signal REGIO_EXT_REG_ADDR_IN : std_logic_vector(7 downto 0);

  signal APL_DATA_IN : std_logic_vector(63 downto 0);
  signal APL_PACKET_NUM_IN : std_logic_vector(11 downto 0);
  signal APL_DATAREADY_IN : std_logic_vector(3 downto 0);
  signal APL_READ_OUT : std_logic_vector(3 downto 0);
  signal APL_SHORT_TRANSFER_IN : std_logic_vector(3 downto 0);
  signal APL_DTYPE_IN : std_logic_vector(15 downto 0);
  signal APL_ERROR_PATTERN_IN : std_logic_vector(127 downto 0);
  signal APL_SEND_IN : std_logic_vector(3 downto 0);
  signal APL_TARGET_ADDRESS_IN : std_logic_vector(63 downto 0);
  signal APL_DATA_OUT : std_logic_vector(63 downto 0);
  signal APL_PACKET_NUM_OUT : std_logic_vector(11 downto 0);
  signal APL_TYP_OUT : std_logic_vector(11 downto 0);
  signal APL_DATAREADY_OUT : std_logic_vector(3 downto 0);
  signal APL_READ_IN : std_logic_vector(3 downto 0);
  signal APL_RUN_OUT : std_logic_vector(3 downto 0);
  signal APL_SEQNR_OUT : std_logic_vector(4*8-1 downto 0);
  signal APL_LENGTH_IN : std_logic_vector(4*16-1 downto 0);
  signal APL_MY_ADDRESS_IN : std_logic_vector(15 downto 0);

  signal MPLEX_CTRL : std_logic_vector(31 downto 0);

  signal DATA_LINK1 : std_logic_vector(17 downto 0);
  signal DATA_LINK2 : std_logic_vector(17 downto 0);


begin
  CLK <= not CLK after 5 ns;
  RESET <= '0' after 50 ns;
  CLK_EN <= '1';





--Active Applications
---------------------------

  APL0 : trb_net16_dummy_apl
    generic map(
      TARGET_ADDRESS   => x"FFFF",
      PREFILL_LENGTH   => 3,
      TRANSFER_LENGTH  => 1
      )
    port map(
      CLK    => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,
      APL_DATA_OUT        => APL_DATA_IN(15 downto 0),
      APL_PACKET_NUM_OUT  => APL_PACKET_NUM_IN(2 downto 0),
      APL_DATAREADY_OUT   => APL_DATAREADY_IN(0),
      APL_READ_IN         => APL_READ_OUT(0),
      APL_SHORT_TRANSFER_OUT => APL_SHORT_TRANSFER_IN(0),
      APL_DTYPE_OUT       => APL_DTYPE_IN(3 downto 0),
      APL_SEND_OUT        => open,--APL_SEND_IN(0),
      APL_DATA_IN         => APL_DATA_OUT(15 downto 0),
      APL_PACKET_NUM_IN   => APL_PACKET_NUM_OUT(2 downto 0),
      APL_TYP_IN          => APL_TYP_OUT(2 downto 0),
      APL_DATAREADY_IN    => APL_DATAREADY_OUT(0),
      APL_READ_OUT        => APL_READ_IN(0),
      APL_RUN_IN          => APL_RUN_OUT(0),
      APL_ERROR_PATTERN_OUT => APL_ERROR_PATTERN_IN(31 downto 0),
      APL_SEQNR_IN        => APL_SEQNR_OUT(7 downto 0),
      APL_TARGET_ADDRESS_OUT => APL_TARGET_ADDRESS_IN(15 downto 0)
      );

  APL1 : trb_net16_dummy_apl
    generic map(
      TARGET_ADDRESS   => x"FFFF",
      PREFILL_LENGTH   => 3,
      TRANSFER_LENGTH  => 10
      )
    port map(
      CLK    => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,
      APL_DATA_OUT        => APL_DATA_IN(31 downto 16),
      APL_PACKET_NUM_OUT  => APL_PACKET_NUM_IN(5 downto 3),
      APL_DATAREADY_OUT   => APL_DATAREADY_IN(1),
      APL_READ_IN         => APL_READ_OUT(1),
      APL_SHORT_TRANSFER_OUT => APL_SHORT_TRANSFER_IN(1),
      APL_DTYPE_OUT       => APL_DTYPE_IN(7 downto 4),
      APL_SEND_OUT        => open,--APL_SEND_IN(1),
      APL_DATA_IN         => APL_DATA_OUT(31 downto 16),
      APL_PACKET_NUM_IN   => APL_PACKET_NUM_OUT(5 downto 3),
      APL_TYP_IN          => APL_TYP_OUT(5 downto 3),
      APL_DATAREADY_IN    => APL_DATAREADY_OUT(1),
      APL_READ_OUT        => APL_READ_IN(1),
      APL_RUN_IN          => APL_RUN_OUT(1),
      APL_ERROR_PATTERN_OUT => open , --APL_ERROR_PATTERN_IN(63 downto 32),
      APL_SEQNR_IN        => APL_SEQNR_OUT(15 downto 8),
      APL_TARGET_ADDRESS_OUT => APL_TARGET_ADDRESS_IN(31 downto 16)
      );


  APL_DATA_IN(47 downto 32) <= (others => '0');
  APL_PACKET_NUM_IN(8 downto 6) <= (others => '0');
  APL_DATAREADY_IN(2) <= '0';
  APL_READ_IN(2) <= '0';
  APL_DTYPE_IN(11 downto 8) <= (others => '0');

  APL3 : trb_net16_dummy_apl
    generic map(
      TARGET_ADDRESS   => x"FFFF",
      PREFILL_LENGTH   => 3,
      TRANSFER_LENGTH  => 1
      )
    port map(
      CLK    => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,
      APL_DATA_OUT        => APL_DATA_IN(63 downto 48),
      APL_PACKET_NUM_OUT  => APL_PACKET_NUM_IN(11 downto 9),
      APL_DATAREADY_OUT   => APL_DATAREADY_IN(3),
      APL_READ_IN         => APL_READ_OUT(3),
      APL_SHORT_TRANSFER_OUT => APL_SHORT_TRANSFER_IN(3),
      APL_DTYPE_OUT       => APL_DTYPE_IN(15 downto 12),
      APL_SEND_OUT        => APL_SEND_IN(3),
      APL_DATA_IN         => APL_DATA_OUT(63 downto 48),
      APL_PACKET_NUM_IN   => APL_PACKET_NUM_OUT(11 downto 9),
      APL_TYP_IN          => APL_TYP_OUT(11 downto 9),
      APL_DATAREADY_IN    => APL_DATAREADY_OUT(3),
      APL_READ_OUT        => APL_READ_IN(3),
      APL_RUN_IN          => APL_RUN_OUT(3),
      APL_ERROR_PATTERN_OUT => APL_ERROR_PATTERN_IN(127 downto 96),
      APL_SEQNR_IN        => APL_SEQNR_OUT(31 downto 24),
      APL_TARGET_ADDRESS_OUT => APL_TARGET_ADDRESS_IN(63 downto 48)
      );


MED_CTRL_OP(14 downto 0) <= (others => '0');
MED_CTRL_OP(15) <= MED_STAT_OP(15);
MED_CTRL_OP(30 downto 16) <= (others => '0');
MED_CTRL_OP(31) <= MED_STAT_OP(31);
APL_MY_ADDRESS_IN <= x"F001"; --Sender address
APL_LENGTH_IN <= (others => '0');

--Sender
-----------------------
  THE_SENDER : trb_net16_endpoint_active_4_channel
    port map(
      --  Misc
      CLK    => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,

      --  Media direction port
      MED_DATAREADY_OUT  => MED_DATAREADY_OUT,
      MED_DATA_OUT       => MED_DATA_OUT,
      MED_PACKET_NUM_OUT => MED_PACKET_NUM_OUT,
      MED_READ_IN        => MED_READ_IN,
      MED_DATAREADY_IN   => MED_DATAREADY_IN,
      MED_DATA_IN        => MED_DATA_IN,
      MED_PACKET_NUM_IN  => MED_PACKET_NUM_IN,
      MED_READ_OUT       => MED_READ_OUT,
      MED_STAT_OP_IN     => MED_STAT_OP(15 downto 0),
      MED_CTRL_OP_OUT    => MED_CTRL_OP(15 downto 0),

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
      APL_DATA_OUT          => APL_DATA_OUT,
      APL_PACKET_NUM_OUT    => APL_PACKET_NUM_OUT,
      APL_TYP_OUT           => APL_TYP_OUT,
      APL_DATAREADY_OUT     => APL_DATAREADY_OUT,
      APL_READ_IN           => APL_READ_IN,

      -- APL Control port
      APL_RUN_OUT           => APL_RUN_OUT,
      APL_SEQNR_OUT         => APL_SEQNR_OUT,
      APL_LENGTH_IN         => APL_LENGTH_IN,
      APL_MY_ADDRESS_IN     => APL_MY_ADDRESS_IN,

      -- Status and control port
      STAT_DEBUG            => open,
      MPLEX_CTRL            => MPLEX_CTRL,
      CTRL_GEN              => (others => '0')
      );


--Connecting both parts
-----------------------


-- MED_R_READ_IN <= transport MED_READ_OUT after 0 ns;
-- MED_R_DATAREADY_IN <= transport MED_DATAREADY_OUT after 499 ns ;
-- MED_R_DATA_IN      <= transport MED_DATA_OUT after 499 ns ;
-- MED_R_PACKET_NUM_IN <= transport MED_PACKET_NUM_OUT after 499 ns ;
--
-- MED_READ_IN <= transport MED_R_READ_OUT after 0 ns;
-- MED_DATAREADY_IN <= transport MED_R_DATAREADY_OUT after 499 ns ;
-- MED_DATA_IN      <= transport MED_R_DATA_OUT after 499 ns ;
-- MED_PACKET_NUM_IN <= transport MED_R_PACKET_NUM_OUT after 499 ns ;
-- MED_STAT_OP <= (others => '0');

  THE_SENDER_MED : trb_net16_med_16_CC
    port map(
      CLK    => CLK,
      CLK_EN => CLK_EN,
      RESET  => RESET,

      --Internal Connection
      MED_DATA_IN        => MED_DATA_OUT,
      MED_PACKET_NUM_IN  => MED_PACKET_NUM_OUT,
      MED_DATAREADY_IN   => MED_DATAREADY_OUT,
      MED_READ_OUT       => MED_READ_IN,
      MED_DATA_OUT       => MED_DATA_IN,
      MED_PACKET_NUM_OUT => MED_PACKET_NUM_IN,
      MED_DATAREADY_OUT  => MED_DATAREADY_IN,
      MED_READ_IN        => MED_READ_OUT,

      DATA_OUT           => DATA_LINK1(15 downto 0),
      DATA_VALID_OUT     => DATA_LINK1(16),
      DATA_CTRL_OUT      => DATA_LINK1(17),
      DATA_IN            => DATA_LINK2(15 downto 0),
      DATA_VALID_IN      => DATA_LINK2(16),
      DATA_CTRL_IN       => DATA_LINK2(17),

      STAT_OP            => MED_STAT_OP(15 downto 0),
      CTRL_OP            => MED_CTRL_OP(15 downto 0),
      STAT_DEBUG         => open
      );

  THE_RECEIVER_MED : trb_net16_med_16_CC
    port map(
      CLK    => CLK,
      CLK_EN => CLK_EN,
      RESET  => RESET,

      --Internal Connection
      MED_DATA_IN        => MED_R_DATA_OUT,
      MED_PACKET_NUM_IN  => MED_R_PACKET_NUM_OUT,
      MED_DATAREADY_IN   => MED_R_DATAREADY_OUT,
      MED_READ_OUT       => MED_R_READ_IN,
      MED_DATA_OUT       => MED_R_DATA_IN,
      MED_PACKET_NUM_OUT => MED_R_PACKET_NUM_IN,
      MED_DATAREADY_OUT  => MED_R_DATAREADY_IN,
      MED_READ_IN        => MED_R_READ_OUT,

      DATA_OUT           => DATA_LINK2(15 downto 0),
      DATA_VALID_OUT     => DATA_LINK2(16),
      DATA_CTRL_OUT      => DATA_LINK2(17),
      DATA_IN            => DATA_LINK1(15 downto 0),
      DATA_VALID_IN      => DATA_LINK1(16),
      DATA_CTRL_IN       => DATA_LINK1(17),

      STAT_OP            => MED_STAT_OP(31 downto 16),
      CTRL_OP            => MED_CTRL_OP(31 downto 16),
      STAT_DEBUG         => open
      );


--Receiver
-----------------------

  THE_RECEIVER : trb_net16_endpoint_hades_full
    port map(
      CLK    => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,

      MED_DATAREADY_OUT  => MED_R_DATAREADY_OUT,
      MED_DATA_OUT       => MED_R_DATA_OUT,
      MED_PACKET_NUM_OUT => MED_R_PACKET_NUM_OUT,
      MED_READ_IN        => MED_R_READ_IN,

      MED_DATAREADY_IN   => MED_R_DATAREADY_IN,
      MED_DATA_IN        => MED_R_DATA_IN,
      MED_PACKET_NUM_IN  => MED_R_PACKET_NUM_IN,
      MED_READ_OUT       => MED_R_READ_OUT,

      MED_STAT_OP_IN     => MED_STAT_OP(31 downto 16),
      MED_CTRL_OP_OUT    => MED_CTRL_OP(31 downto 16),

      -- LVL1 trigger APL
      LVL1_TRG_TYPE_OUT        => LVL1_TRG_TYPE_OUT,
      LVL1_TRG_RECEIVED_OUT    => LVL1_TRG_RECEIVED_OUT,
      LVL1_TRG_NUMBER_OUT      => LVL1_TRG_NUMBER_OUT,
      LVL1_TRG_CODE_OUT        => LVL1_TRG_CODE_OUT,
      LVL1_TRG_INFORMATION_OUT => LVL1_TRG_INFORMATION_OUT,
      LVL1_ERROR_PATTERN_IN    => LVL1_ERROR_PATTERN_IN,
      LVL1_TRG_RELEASE_IN      => LVL1_TRG_RELEASE_IN,

      --Data Port
      IPU_NUMBER_OUT          => IPU_NUMBER_OUT,
      IPU_INFORMATION_OUT     => IPU_INFORMATION_OUT,
      IPU_START_READOUT_OUT   => IPU_START_READOUT_OUT,
      IPU_DATA_IN             => IPU_DATA_IN,
      IPU_DATAREADY_IN        => IPU_DATAREADY_IN,
      IPU_READOUT_FINISHED_IN => IPU_READOUT_FINISHED_IN,
      IPU_READ_OUT            => IPU_READ_OUT,
      IPU_LENGTH_IN           => IPU_LENGTH_IN,
      IPU_ERROR_PATTERN_IN    => IPU_ERROR_PATTERN_IN,

      -- Slow Control Data Port
      REGIO_COMMON_STAT_REG_IN  => REGIO_COMMON_STAT_REG_IN,
      REGIO_COMMON_CTRL_REG_OUT => REGIO_COMMON_CTRL_REG_OUT,
      REGIO_REGISTERS_IN        => REGIO_REGISTERS_IN,
      REGIO_REGISTERS_OUT       => REGIO_REGISTERS_OUT,
      --following ports only used when using internal data port
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
      --IDRAM is used if no 1-wire interface, onewire used otherwise
      REGIO_IDRAM_DATA_IN       => REGIO_IDRAM_DATA_IN,
      REGIO_IDRAM_DATA_OUT      => REGIO_IDRAM_DATA_OUT,
      REGIO_IDRAM_ADDR_IN       => REGIO_IDRAM_ADDR_IN,
      REGIO_IDRAM_WR_IN         => REGIO_IDRAM_WR_IN,
      REGIO_ONEWIRE_INOUT       => REGIO_ONEWIRE_INOUT,
      --Additional r/w access to ctrl registers
      REGIO_EXT_REG_DATA_IN     => REGIO_EXT_REG_DATA_IN,
      REGIO_EXT_REG_DATA_OUT    => REGIO_EXT_REG_DATA_OUT,
      REGIO_EXT_REG_WRITE_IN    => REGIO_EXT_REG_WRITE_IN,
      REGIO_EXT_REG_ADDR_IN     => REGIO_EXT_REG_ADDR_IN,

      STAT_DEBUG_IPU            => open,
      STAT_DEBUG_1              => open,
      STAT_DEBUG_2              => open,
      MED_STAT_OP               => open,
      CTRL_MPLEX                => MPLEX_CTRL,
      IOBUF_CTRL_GEN            => (others => '0'),
      STAT_ONEWIRE              => open
      );

MPLEX_CTRL <= x"00000100";

LVL1_TRG_RELEASE_IN <= '1';
LVL1_ERROR_PATTERN_IN <= (others => '0');
IPU_ERROR_PATTERN_IN <= (others => '0');
APL_ERROR_PATTERN_IN(95 downto 64) <= (others => '0');


  REGIO_NO_MORE_DATA_IN <= '0';
  PROC_REGIO : process(CLK)
    begin
      if rising_edge(CLK) then
        if REGIO_WRITE_ENABLE_OUT = '1' then
          if REGIO_ADDR_OUT = x"8001" then
            REGIO_UNKNOWN_ADDR_IN <= '1';
          else
            REGIO_UNKNOWN_ADDR_IN <= '0';
          end if;
        end if;
      end if;
    end process;

  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          ipu_answer_delay <= (others => '0');
        elsif (ipu_answer_delay(10) = '0' or IPU_START_READOUT_OUT = '0') and not (ipu_answer_delay(3) = '1' and IPU_READ_OUT = '0') then
          ipu_answer_delay <= ipu_answer_delay(10 downto 0) & (IPU_START_READOUT_OUT and not or_all(ipu_answer_delay));
        end if;
      end if;
    end process;
  IPU_DATAREADY_IN <= ipu_answer_delay(3);
  IPU_READOUT_FINISHED_IN <= ipu_answer_delay(9);
  IPU_LENGTH_IN <= x"0001";
  IPU_ERROR_PATTERN_IN <= (others => '0');
  APL_ERROR_PATTERN_IN(63 downto 32) <= x"10EF1234";
  IPU_DATA_IN <= x"DA1A5E10";


end architecture;