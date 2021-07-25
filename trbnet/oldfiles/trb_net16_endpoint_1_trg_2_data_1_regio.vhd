-- the full endpoint for HADES: trg, data, data, regio

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;



entity trb_net16_endpoint_1_trg_2_api_1_regio is
  generic (
    USE_CHANNEL                  : channel_config_t := (c_YES,c_YES,c_YES,c_YES);
    API_TYPE                     : channel_config_t := (c_API_PASSIVE,c_API_PASSIVE,c_API_PASSIVE,c_API_PASSIVE);
    IBUF_DEPTH                   : channel_config_t := (0,6,6,6);
    FIFO_TO_INT_DEPTH            : channel_config_t := (0,6,6,6);
    FIFO_TO_APL_DEPTH            : channel_config_t := (0,6,6,6);
    IBUF_SECURE_MODE             : channel_config_t := (c_YES,c_YES,c_YES,c_YES);
    API_SECURE_MODE_TO_APL       : channel_config_t := (c_YES,c_YES,c_YES,c_YES);
    OBUF_DATA_COUNT_WIDTH        : integer range 0 to 7 := std_DATA_COUNT_WIDTH;
    INIT_CAN_SEND_DATA           : channel_config_t := (c_NO,c_NO,c_NO,c_NO);
    REPLY_CAN_SEND_DATA          : channel_config_t := (c_YES,c_YES,c_YES,c_YES);
    SCTR_NUM_STAT_REGS      : integer range 0 to 6 := 2; --log2 of number of status registers
    SCTR_NUM_CTRL_REGS      : integer range 0 to 6 := 2; --log2 of number of ctrl registers
    --standard values for output registers
    SCTR_INIT_CTRL_REGS     : std_logic_vector(2**(3)*32-1 downto 0) := (others => '0');
    --set to 0 for unused ctrl registers to save resources
    SCTR_USED_CTRL_REGS     : std_logic_vector(2**(3)-1 downto 0)   := "00000001";
    --set to 0 for each unused bit in a register
    SCTR_USED_CTRL_BITMASK  : std_logic_vector(2**(3)*32-1 downto 0) := (others => '1');
    --no data / address out?
    SCTR_USE_DATA_PORT        : integer := c_NO;
    SCTR_USE_1WIRE_INTERFACE  : integer := c_YES;
    SCTR_INIT_ADDRESS         : std_logic_vector(15 downto 0) := x"FFFF";
    SCTR_INIT_UNIQUE_ID       : std_logic_vector(95 downto 0) := (others => '0');
    SCTR_COMPILE_TIME         : std_logic_vector(31 downto 0) := x"00000000";
    SCTR_COMPILE_VERSION      : std_logic_vector(15 downto 0) := x"0001";
    SCTR_HARDWARE_VERSION     : std_logic_vector(31 downto 0) := x"12345678"
    );

  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    --  Media direction port
    MED_DATAREADY_OUT : out std_logic;
    MED_DATA_OUT      : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT: out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    MED_READ_IN       : in  std_logic;
    MED_DATAREADY_IN  : in  std_logic;
    MED_DATA_IN       : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    MED_READ_OUT      : out std_logic;
    MED_ERROR_IN      : in  std_logic_vector (2 downto 0);
    MED_STAT_OP       : in  std_logic_vector (15 downto 0);
    MED_CTRL_OP       : out std_logic_vector (15 downto 0);

    -- LVL1 trigger APL
    LVL1_ERROR_PATTERN_OUT : out std_logic_vector(31 downto 0);
    LVL1_GOT_TRIGGER_OUT   : out std_logic;
    LVL1_DTYPE_OUT         : out std_logic_vector(3 downto 0);
    LVL1_SEQNR_OUT         : out std_logic_vector(7 downto 0);
    LVL1_ERROR_PATTERN_IN  : in  std_logic_vector(31 downto 0) := x"00000000";
    LVL1_RELEASE_IN        : in  std_logic := '0';

    -- IPU-Data Channel APL
    IPUD_APL_DATA_IN          : in  std_logic_vector (c_DATA_WIDTH-1 downto 0) := x"0000";
    IPUD_APL_PACKET_NUM_IN    : in  std_logic_vector (c_NUM_WIDTH-1 downto 0) := "00";
    IPUD_APL_DATAREADY_IN     : in  std_logic := '0';
    IPUD_APL_READ_OUT         : out std_logic;
    IPUD_APL_SHORT_TRANSFER_IN: in  std_logic := '0';
    IPUD_APL_DTYPE_IN         : in  std_logic_vector (3 downto 0) := x"0";
    IPUD_APL_ERROR_PATTERN_IN : in  std_logic_vector (31 downto 0) := x"00000000";
    IPUD_APL_SEND_IN          : in  std_logic:= '0';
    IPUD_APL_TARGET_ADDRESS_IN: in  std_logic_vector (15 downto 0) := x"0000";
    IPUD_APL_DATA_OUT         : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    IPUD_APL_PACKET_NUM_OUT   : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    IPUD_APL_TYP_OUT          : out std_logic_vector (2 downto 0);
    IPUD_APL_DATAREADY_OUT    : out std_logic;
    IPUD_APL_READ_IN          : in  std_logic:= '0';
    IPUD_APL_RUN_OUT          : out std_logic;
    IPUD_APL_SEQNR_OUT        : out std_logic_vector (7 downto 0);

    -- LVL2-Data Channel APL
    LVL2_APL_DATA_IN          : in  std_logic_vector (c_DATA_WIDTH-1 downto 0) := x"0000";
    LVL2_APL_PACKET_NUM_IN    : in  std_logic_vector (c_NUM_WIDTH-1 downto 0) := "00";
    LVL2_APL_DATAREADY_IN     : in  std_logic := '0';
    LVL2_APL_READ_OUT         : out std_logic;
    LVL2_APL_SHORT_TRANSFER_IN: in  std_logic := '0';
    LVL2_APL_DTYPE_IN         : in  std_logic_vector (3 downto 0) := x"0";
    LVL2_APL_ERROR_PATTERN_IN : in  std_logic_vector (31 downto 0) := x"00000000";
    LVL2_APL_SEND_IN          : in  std_logic:= '0';
    LVL2_APL_TARGET_ADDRESS_IN: in  std_logic_vector (15 downto 0) := x"0000";
    LVL2_APL_DATA_OUT         : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    LVL2_APL_PACKET_NUM_OUT   : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    LVL2_APL_TYP_OUT          : out std_logic_vector (2 downto 0);
    LVL2_APL_DATAREADY_OUT    : out std_logic;
    LVL2_APL_READ_IN          : in  std_logic:= '0';
    LVL2_APL_RUN_OUT          : out std_logic;
    LVL2_APL_SEQNR_OUT        : out std_logic_vector (7 downto 0);

    -- Slow Control Data Port
    SCTR_COMMON_STAT_REG_IN  : in  std_logic_vector(std_COMSTATREG*32-1 downto 0) := (others => '0');
    SCTR_COMMON_CTRL_REG_OUT : out std_logic_vector(std_COMCTRLREG*32-1 downto 0);
    SCTR_REGISTERS_IN        : in  std_logic_vector(32*2**(SCTR_NUM_STAT_REGS)-1 downto 0) := (others => '0');
    SCTR_REGISTERS_OUT       : out std_logic_vector(32*2**(SCTR_NUM_CTRL_REGS)-1 downto 0);
    --following ports only used when using internal data port
    SCTR_ADDR_OUT            : out std_logic_vector(16-1 downto 0);
    SCTR_READ_ENABLE_OUT     : out std_logic;
    SCTR_WRITE_ENABLE_OUT    : out std_logic;
    SCTR_DATA_OUT            : out std_logic_vector(32-1 downto 0);
    SCTR_DATA_IN             : in  std_logic_vector(32-1 downto 0) := (others => '0');
    SCTR_DATAREADY_IN        : in  std_logic := '0';
    SCTR_NO_MORE_DATA_IN     : in  std_logic := '0';
    --IDRAM is used if no 1-wire interface, onewire used otherwise
    SCTR_IDRAM_DATA_IN       : in  std_logic_vector(15 downto 0) := (others => '0');
    SCTR_IDRAM_DATA_OUT      : out std_logic_vector(15 downto 0);
    SCTR_IDRAM_ADDR_IN       : in  std_logic_vector(2 downto 0) := "000";
    SCTR_IDRAM_WR_IN         : in  std_logic := '0';
    SCTR_ONEWIRE_INOUT       : inout std_logic;
    --Additional r/w access to ctrl registers
    SCTR_EXT_REG_DATA_IN     : in  std_logic_vector(31 downto 0) := (others => '0');
    SCTR_EXT_REG_DATA_OUT    : out std_logic_vector(31 downto 0);
    SCTR_EXT_REG_WRITE_IN    : in  std_logic := '0';
    SCTR_EXT_REG_ADDR_IN     : in  std_logic_vector(7 downto 0) := (others => '0');
    -- Status
    MPLEX_CTRL                : in  std_logic_vector (31 downto 0) := (others => '0');
    STAT_CTRL_INIT_BUFFER     : in  std_logic_vector (4*32-1 downto 0) := (others => '0');
    STAT_CTRL_GEN             : in  std_logic_vector (4*32-1 downto 0) := (others => '0');
    STAT_GEN_1                : out std_logic_vector (31 downto 0); -- General Status
    STAT_GEN_2                : out std_logic_vector (31 downto 0); -- General Status
    CTRL_GEN                  : in  std_logic_vector (4*32-1 downto 0) := (others => '0')
    );
end entity;





architecture trb_net16_endpoint_1_trg_2_api_1_regio_arch of trb_net16_endpoint_1_trg_2_api_1_regio is

  component trb_net_onewire is
    generic(
      USE_TEMPERATURE_READOUT : integer range 0 to 1 := 1;
      CLK_PERIOD : integer := 10  --clk period in ns
      );
    port(
      CLK      : in std_logic;
      RESET    : in std_logic;
      --connection to 1-wire interface
      ONEWIRE  : inout std_logic;
      --connection to id ram, according to memory map in TrbNetRegIO
      DATA_OUT : out std_logic_vector(15 downto 0);
      ADDR_OUT : out std_logic_vector(2 downto 0);
      WRITE_OUT: out std_logic;
      TEMP_OUT : out std_logic_vector(11 downto 0);
      STAT     : out std_logic_vector(31 downto 0)
      );
  end component;

  component trb_net16_regIO is
    generic (
      REGISTER_WIDTH     : integer range 32 to 32 := 32;
      ADDRESS_WIDTH      : integer range 8 to 16 := 16;
      NUM_STAT_REGS      : integer range 0 to 6 := 1; --log2 of number of status registers
      NUM_CTRL_REGS      : integer range 0 to 6 := 2; --log2 of number of ctrl registers
      --standard values for output registers
      INIT_CTRL_REGS     : std_logic_vector(2**(3)*32-1 downto 0) :=
              (others => '0');
      --set to 0 for unused ctrl registers to save resources
      USED_CTRL_REGS     : std_logic_vector(2**(3)-1 downto 0)   := "00000001";
      --set to 0 for each unused bit in a register
      USED_CTRL_BITMASK  : std_logic_vector(2**(3)*32-1 downto 0) :=
              (others => '1');
      USE_DAT_PORT        : integer range 0 to 1 := c_YES;  --internal data port

      INIT_ADDRESS       : std_logic_vector(15 downto 0) := x"FFFF";
      INIT_UNIQUE_ID     : std_logic_vector(95 downto 0) := (others => '0');
      COMPILE_TIME       : std_logic_vector(31 downto 0) := x"00000000";
      COMPILE_VERSION    : std_logic_vector(15 downto 0) := x"0001";
      HARDWARE_VERSION   : std_logic_vector(31 downto 0) := x"12345678"
      );
    port(
    --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
    -- Port to API
      API_DATA_OUT           : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      API_PACKET_NUM_OUT     : out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      API_DATAREADY_OUT      : out std_logic;
      API_READ_IN            : in  std_logic;
      API_SHORT_TRANSFER_OUT : out std_logic;
      API_DTYPE_OUT          : out std_logic_vector (3 downto 0);
      API_ERROR_PATTERN_OUT  : out std_logic_vector (31 downto 0);
      API_SEND_OUT           : out std_logic;
      API_TARGET_ADDRESS_OUT : out std_logic_vector (15 downto 0);
      -- Receiver port
      API_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      API_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
      API_TYP_IN          : in  std_logic_vector (2 downto 0);
      API_DATAREADY_IN    : in  std_logic;
      API_READ_OUT        : out std_logic;
      -- APL Control port
      API_RUN_IN          : in  std_logic;
      API_SEQNR_IN        : in  std_logic_vector (7 downto 0);

      --Port to write Unique ID
      IDRAM_DATA_IN       : in  std_logic_vector(15 downto 0);
      IDRAM_DATA_OUT      : out std_logic_vector(15 downto 0);
      IDRAM_ADDR_IN       : in  std_logic_vector(2 downto 0);
      IDRAM_WR_IN         : in  std_logic;
      MY_ADDRESS_OUT      : out std_logic_vector(15 downto 0);

    --Common Register in / out
      COMMON_STAT_REG_IN   : in  std_logic_vector(std_COMSTATREG*32-1 downto 0);
      COMMON_CTRL_REG_OUT  : out std_logic_vector(std_COMCTRLREG*32-1 downto 0);
    --Custom Register in / out
      REGISTERS_IN        : in  std_logic_vector(REGISTER_WIDTH*2**(NUM_STAT_REGS)-1 downto 0);
      REGISTERS_OUT       : out std_logic_vector(REGISTER_WIDTH*2**(NUM_CTRL_REGS)-1 downto 0);
    --Internal Data Port
      DAT_ADDR_OUT        : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      DAT_READ_ENABLE_OUT : out std_logic;
      DAT_WRITE_ENABLE_OUT: out std_logic;
      DAT_DATA_OUT        : out std_logic_vector(REGISTER_WIDTH-1 downto 0);
      --Data input can only be used as reaction on read or write access. write operation should return data
      --if successful
      DAT_DATA_IN         : in  std_logic_vector(REGISTER_WIDTH-1 downto 0);
      DAT_DATAREADY_IN    : in std_logic;
      DAT_NO_MORE_DATA_IN : in std_logic;
        --finish transmission, when reading from a fifo and it got empty
    --Additional write access to ctrl registers
      EXT_REG_DATA_IN     : in  std_logic_vector(31 downto 0);
      EXT_REG_DATA_OUT    : out std_logic_vector(31 downto 0);
      EXT_REG_WRITE_IN    : in  std_logic;
      EXT_REG_ADDR_IN     : in  std_logic_vector(7 downto 0);
      STAT : out std_logic_vector(31 downto 0)
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
      MED_INIT_DATAREADY_OUT: out std_logic;
      MED_INIT_DATA_OUT:      out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_INIT_PACKET_NUM_OUT:out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      MED_INIT_READ_IN:       in  std_logic;

      MED_REPLY_DATAREADY_OUT: out std_logic;
      MED_REPLY_DATA_OUT:      out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_REPLY_PACKET_NUM_OUT:out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      MED_REPLY_READ_IN:       in  std_logic;


      MED_DATAREADY_IN:  in  std_logic; -- Data word is offered by the Media(the IOBUF MUST read)
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
      STAT_CTRL_IBUF_BUFFER:  in  std_logic_vector (31 downto 0)
      );
  end component;

  component trb_net16_api_base is
    generic (
      API_TYPE          : integer range 0 to 1 := c_API_ACTIVE;
      FIFO_TO_INT_DEPTH : integer range 1 to 6 := 1;--std_FIFO_DEPTH;
      FIFO_TO_APL_DEPTH : integer range 1 to 6 := 1;--std_FIFO_DEPTH;
      FORCE_REPLY       : integer range 0 to 1 := std_FORCE_REPLY;
      SBUF_VERSION      : integer range 0 to 1 := std_SBUF_VERSION;
      USE_VENDOR_CORES  : integer range 0 to 1 := c_YES;
      SECURE_MODE_TO_APL: integer range 0 to 1 := c_YES;
      SECURE_MODE_TO_INT: integer range 0 to 1 := c_YES;
      APL_WRITE_4_PACKETS:integer range 0 to 1 := c_NO
      );

    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      -- APL Transmitter port
      APL_DATA_IN:       in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word "application to network"
      APL_PACKET_NUM_IN: in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      APL_DATAREADY_IN:  in  std_logic; -- Data word is valid and should be transmitted
      APL_READ_OUT:      out std_logic; -- Stop transfer, the fifo is full
      APL_SHORT_TRANSFER_IN: in  std_logic; --
      APL_DTYPE_IN:      in  std_logic_vector (3 downto 0);  -- see NewTriggerBusNetworkDescr
      APL_ERROR_PATTERN_IN: in  std_logic_vector (31 downto 0); -- see NewTriggerBusNetworkDescr
      APL_SEND_IN:       in  std_logic; -- Release sending of the data
      APL_TARGET_ADDRESS_IN: in  std_logic_vector (15 downto 0); -- Address of
                                                                -- the target (only for active APIs)

      -- Receiver port
      APL_DATA_OUT:      out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word "network to application"
      APL_PACKET_NUM_OUT:out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      APL_TYP_OUT:       out std_logic_vector (2 downto 0);  -- Which kind of data word: DAT, HDR or TRM
      APL_DATAREADY_OUT: out std_logic; -- Data word is valid and might be read out
      APL_READ_IN:       in  std_logic; -- Read data word

      -- APL Control port
      APL_RUN_OUT:       out std_logic; -- Data transfer is running
      APL_MY_ADDRESS_IN: in  std_logic_vector (15 downto 0);  -- My own address (temporary solution!!!)
      APL_SEQNR_OUT:     out std_logic_vector (7 downto 0);

      -- Internal direction port
      -- This is just a clone from trb_net_iobuf

      INT_MASTER_DATAREADY_OUT: out std_logic;
      INT_MASTER_DATA_OUT:      out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      INT_MASTER_PACKET_NUM_OUT:out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_MASTER_READ_IN:       in  std_logic;

      INT_MASTER_DATAREADY_IN:  in  std_logic;
      INT_MASTER_DATA_IN:       in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      INT_MASTER_PACKET_NUM_IN: in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_MASTER_READ_OUT:      out std_logic;


      INT_SLAVE_HEADER_IN:     in  std_logic; -- Concentrator kindly asks to resend the last
                                        -- header (only for the SLAVE path)
      INT_SLAVE_DATAREADY_OUT: out std_logic;
      INT_SLAVE_DATA_OUT:      out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      INT_SLAVE_PACKET_NUM_OUT:out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_SLAVE_READ_IN:       in  std_logic;

      INT_SLAVE_DATAREADY_IN:  in  std_logic;
      INT_SLAVE_DATA_IN:       in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      INT_SLAVE_PACKET_NUM_IN: in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_SLAVE_READ_OUT:      out std_logic;

      -- Status and control port
      STAT_FIFO_TO_INT: out std_logic_vector(31 downto 0);
      STAT_FIFO_TO_APL: out std_logic_vector(31 downto 0)
      );
  end component;



  component trb_net16_io_multiplexer is
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      --  Media direction port
      MED_DATAREADY_IN:  in  STD_LOGIC;
      MED_DATA_IN:       in  STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN:  in  STD_LOGIC_VECTOR (1 downto 0);
      MED_READ_OUT:      out STD_LOGIC;

      MED_DATAREADY_OUT: out STD_LOGIC;
      MED_DATA_OUT:      out STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT: out STD_LOGIC_VECTOR (1 downto 0);
      MED_READ_IN:       in  STD_LOGIC;

      -- Internal direction port
      INT_DATA_OUT:      out STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
      INT_PACKET_NUM_OUT: out STD_LOGIC_VECTOR (c_NUM_WIDTH-1 downto 0);
      INT_DATAREADY_OUT: out STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)-1 downto 0);
      INT_READ_IN:       in  STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)-1 downto 0);

      INT_DATAREADY_IN:  in  STD_LOGIC_VECTOR (2**c_MUX_WIDTH-1 downto 0);
      INT_DATA_IN:       in  STD_LOGIC_VECTOR ((c_DATA_WIDTH)*(2**c_MUX_WIDTH)-1 downto 0);
      INT_PACKET_NUM_IN:  in  STD_LOGIC_VECTOR (2*(2**c_MUX_WIDTH)-1 downto 0);
      INT_READ_OUT:      out STD_LOGIC_VECTOR (2**c_MUX_WIDTH-1 downto 0);

      -- Status and control port
      CTRL:              in  STD_LOGIC_VECTOR (31 downto 0);
      STAT:              out STD_LOGIC_VECTOR (31 downto 0)
      );
  end component;

  component trb_net16_term_buf is
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      MED_INIT_DATAREADY_OUT:     out std_logic;
      MED_INIT_DATA_OUT:          out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      MED_INIT_PACKET_NUM_OUT:    out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      MED_INIT_READ_IN:           in  std_logic;

      MED_REPLY_DATAREADY_OUT:     out std_logic;
      MED_REPLY_DATA_OUT:          out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      MED_REPLY_PACKET_NUM_OUT:    out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      MED_REPLY_READ_IN:           in  std_logic;

      MED_DATAREADY_IN:      in  std_logic;
      MED_DATA_IN:           in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      MED_PACKET_NUM_IN:     in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
      MED_READ_OUT:          out std_logic
      );
  end component;
  component trb_net16_term is
    generic (
      USE_APL_PORT : integer range 0 to 1 := 0;
      SECURE_MODE  : integer range 0 to 1 := std_TERM_SECURE_MODE
      );
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      INT_DATAREADY_OUT:     out std_logic;
      INT_DATA_OUT:          out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      INT_PACKET_NUM_OUT:    out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      INT_READ_IN:           in  std_logic;

      INT_DATAREADY_IN:      in  std_logic;
      INT_DATA_IN:           in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      INT_PACKET_NUM_IN:     in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
      INT_READ_OUT:          out std_logic;

      -- "mini" APL, just to see the triggers coming in
      APL_DTYPE_OUT:         out std_logic_vector (3 downto 0);  -- see NewTriggerBusNetworkDescr
      APL_ERROR_PATTERN_OUT: out std_logic_vector (31 downto 0); -- see NewTriggerBusNetworkDescr
      APL_SEQNR_OUT:         out std_logic_vector (7 downto 0);
      APL_GOT_TRM:           out std_logic;
      APL_RELEASE_TRM:       in std_logic;
      APL_ERROR_PATTERN_IN:  in std_logic_vector (31 downto 0) -- see NewTriggerBusNetworkDescr
      -- Status and control port
      );
  end component;
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
signal MED_IO_DATA_IN       : std_logic_vector (c_DATA_WIDTH-1 downto 0);
signal MED_IO_PACKET_NUM_IN : std_logic_vector (c_NUM_WIDTH-1 downto 0);
signal MED_IO_READ_OUT      : std_logic_vector(3 downto 0);

signal MED_IO_DATAREADY_OUT  : std_logic_vector(7 downto 0);
signal MED_IO_DATA_OUT       : std_logic_vector (8*c_DATA_WIDTH-1 downto 0);
signal MED_IO_PACKET_NUM_OUT : std_logic_vector (8*c_NUM_WIDTH-1 downto 0);
signal MED_IO_READ_IN        : std_logic_vector(7 downto 0);

signal buf_APL_DATA_IN : std_logic_vector(3*c_DATA_WIDTH-1 downto 0);
signal buf_APL_PACKET_NUM_IN : std_logic_vector(3*c_NUM_WIDTH-1 downto 0);
signal buf_APL_DATAREADY_IN : std_logic_vector(2 downto 0);
signal buf_APL_READ_OUT : std_logic_vector(2 downto 0);
signal buf_APL_SHORT_TRANSFER_IN : std_logic_vector(2 downto 0);
signal buf_APL_DTYPE_IN : std_logic_vector(3*4-1 downto 0);
signal buf_APL_ERROR_PATTERN_IN : std_logic_vector(3*32-1 downto 0);
signal buf_APL_SEND_IN : std_logic_vector(2 downto 0);
signal buf_APL_TARGET_ADDRESS_IN : std_logic_vector(3*16-1 downto 0);
signal buf_APL_DATA_OUT : std_logic_vector(3*c_DATA_WIDTH-1 downto 0);
signal buf_APL_PACKET_NUM_OUT : std_logic_vector(3*c_NUM_WIDTH-1 downto 0);
signal buf_APL_DATAREADY_OUT : std_logic_vector(2 downto 0);
signal buf_APL_READ_IN : std_logic_vector(2 downto 0);
signal buf_APL_TYP_OUT : std_logic_vector(3*3-1 downto 0);
signal buf_APL_RUN_OUT : std_logic_vector(2 downto 0);
signal buf_APL_SEQNR_OUT : std_logic_vector(3*8-1 downto 0);

signal MY_ADDRESS : std_logic_vector(15 downto 0);

signal buf_api_stat_fifo_to_apl, buf_api_stat_fifo_to_int : std_logic_vector (4*32-1 downto 0);
signal buf_STAT_GEN : std_logic_vector(32*4-1 downto 0);
signal buf_STAT_INIT_BUFFER : std_logic_vector(32*4-1 downto 0);
signal buf_CTRL_GEN : std_logic_vector(32*4-1 downto 0);
signal buf_STAT_CTRL_INIT_BUFFER : std_logic_vector(32*4-1 downto 0);
signal SCTR_REGIO_STAT : std_logic_vector(31 downto 0);

signal buf_COMMON_STAT_REG_IN: std_logic_vector(std_COMSTATREG*32-1 downto 0);

signal buf_IDRAM_DATA_IN       :  std_logic_vector(15 downto 0);
signal buf_IDRAM_DATA_OUT      :  std_logic_vector(15 downto 0);
signal buf_IDRAM_ADDR_IN       :  std_logic_vector(2 downto 0);
signal buf_IDRAM_WR_IN         :  std_logic;

begin

  MED_CTRL_OP(15) <= MED_STAT_OP(15);
  MED_CTRL_OP(14 downto 0) <= (others => '0');

  --Connections for data channel
    genbuffers : for i in 0 to 3 generate
      geniobuf: if USE_CHANNEL(i) = c_YES generate
        IOBUF: trb_net16_iobuf
          generic map (
            IBUF_DEPTH          => IBUF_DEPTH(i),
            IBUF_SECURE_MODE    => IBUF_SECURE_MODE(i),
            SBUF_VERSION        => 0,
            USE_ACKNOWLEDGE     => cfg_USE_ACKNOWLEDGE(i),
            USE_VENDOR_CORES    => c_YES,
            USE_CHECKSUM        => cfg_USE_CHECKSUM(i),
            INIT_CAN_SEND_DATA  => INIT_CAN_SEND_DATA(i),
            REPLY_CAN_SEND_DATA => REPLY_CAN_SEND_DATA(i)
            )
          port map (
            --  Misc
            CLK     => CLK ,
            RESET   => RESET,
            CLK_EN  => CLK_EN,
            --  Media direction port
            MED_INIT_DATAREADY_OUT  => MED_IO_DATAREADY_OUT(i*2),
            MED_INIT_DATA_OUT       => MED_IO_DATA_OUT((i*2+1)*c_DATA_WIDTH-1 downto i*2*c_DATA_WIDTH),
            MED_INIT_PACKET_NUM_OUT => MED_IO_PACKET_NUM_OUT((i*2+1)*c_NUM_WIDTH-1 downto i*2*c_NUM_WIDTH),
            MED_INIT_READ_IN        => MED_IO_READ_IN(i*2),

            MED_DATAREADY_IN   => MED_IO_DATAREADY_IN(i),
            MED_DATA_IN        => MED_IO_DATA_IN,
            MED_PACKET_NUM_IN  => MED_IO_PACKET_NUM_IN,
            MED_READ_OUT       => MED_IO_READ_OUT(i),
            MED_ERROR_IN       => MED_ERROR_IN,

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
            STAT_CTRL_IBUF_BUFFER  => buf_STAT_CTRL_INIT_BUFFER(32*(i+1)-1 downto i*32)
            );
      genactapi : if API_TYPE(i) = c_API_ACTIVE and i /= 0 generate
        DAT_ACTIVE_API: trb_net16_api_base
          generic map (
            API_TYPE          => API_TYPE(i),
            FIFO_TO_INT_DEPTH => FIFO_TO_INT_DEPTH(i),
            FIFO_TO_APL_DEPTH => FIFO_TO_APL_DEPTH(i),
            FORCE_REPLY       => cfg_FORCE_REPLY(i),
            SBUF_VERSION      => 0
            )
          port map (
            --  Misc
            CLK    => CLK,
            RESET  => RESET,
            CLK_EN => CLK_EN,
            -- APL Transmitter port
            APL_DATA_IN           => buf_APL_DATA_IN((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            APL_PACKET_NUM_IN     => buf_APL_PACKET_NUM_IN((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            APL_DATAREADY_IN      => buf_APL_DATAREADY_IN(i),
            APL_READ_OUT          => buf_APL_READ_OUT(i),
            APL_SHORT_TRANSFER_IN => buf_APL_SHORT_TRANSFER_IN(i),
            APL_DTYPE_IN          => buf_APL_DTYPE_IN((i+1)*4-1 downto i*4),
            APL_ERROR_PATTERN_IN  => buf_APL_ERROR_PATTERN_IN((i+1)*32-1 downto i*32),
            APL_SEND_IN           => buf_APL_SEND_IN(i),
            APL_TARGET_ADDRESS_IN => buf_APL_TARGET_ADDRESS_IN((i+1)*16-1 downto i*16),
            -- Receiver port
            APL_DATA_OUT      => buf_APL_DATA_OUT((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            APL_PACKET_NUM_OUT=> buf_APL_PACKET_NUM_OUT((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            APL_TYP_OUT       => buf_APL_TYP_OUT((i+1)*3-1 downto i*3),
            APL_DATAREADY_OUT => buf_APL_DATAREADY_OUT(i),
            APL_READ_IN       => buf_APL_READ_IN(i),
            -- APL Control port
            APL_RUN_OUT       => buf_APL_RUN_OUT(i),
            APL_MY_ADDRESS_IN => MY_ADDRESS,
            APL_SEQNR_OUT     => buf_APL_SEQNR_OUT((i+1)*8-1 downto i*8),
            -- Internal direction port
            INT_MASTER_DATAREADY_OUT => apl_to_buf_INIT_DATAREADY(i),
            INT_MASTER_DATA_OUT      => apl_to_buf_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_MASTER_PACKET_NUM_OUT=> apl_to_buf_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_MASTER_READ_IN       => apl_to_buf_INIT_READ(i),
            INT_MASTER_DATAREADY_IN  => buf_to_apl_INIT_DATAREADY(i),
            INT_MASTER_DATA_IN       => buf_to_apl_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_MASTER_PACKET_NUM_IN => buf_to_apl_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_MASTER_READ_OUT      => buf_to_apl_INIT_READ(i),
            INT_SLAVE_HEADER_IN      => '0',
            INT_SLAVE_DATAREADY_OUT  => apl_to_buf_REPLY_DATAREADY(i),
            INT_SLAVE_DATA_OUT       => apl_to_buf_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_SLAVE_PACKET_NUM_OUT => apl_to_buf_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_SLAVE_READ_IN        => apl_to_buf_REPLY_READ(i),
            INT_SLAVE_DATAREADY_IN => buf_to_apl_REPLY_DATAREADY(i),
            INT_SLAVE_DATA_IN      => buf_to_apl_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_SLAVE_PACKET_NUM_IN=> buf_to_apl_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_SLAVE_READ_OUT     => buf_to_apl_REPLY_READ(i),
            -- Status and control port
            STAT_FIFO_TO_INT => buf_api_stat_fifo_to_int((i+1)*32-1 downto i*32),
            STAT_FIFO_TO_APL => buf_api_stat_fifo_to_apl((i+1)*32-1 downto i*32)
            );
        end generate;
      genpasapi : if API_TYPE(i) = c_API_PASSIVE and i /= 0 generate
        constant j : integer := i-1;
      begin
        DAT_PASSIVE_API: trb_net16_api_base
          generic map (
            API_TYPE          => API_TYPE(i),
            FIFO_TO_INT_DEPTH => FIFO_TO_INT_DEPTH(i),
            FIFO_TO_APL_DEPTH => FIFO_TO_APL_DEPTH(i),
            FORCE_REPLY       => cfg_FORCE_REPLY(i),
            SBUF_VERSION      => 0
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
            APL_TARGET_ADDRESS_IN => buf_APL_TARGET_ADDRESS_IN((j+1)*16-1 downto j*16),
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
            -- Internal direction port
            INT_MASTER_DATAREADY_OUT => apl_to_buf_REPLY_DATAREADY(i),
            INT_MASTER_DATA_OUT      => apl_to_buf_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_MASTER_PACKET_NUM_OUT=> apl_to_buf_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_MASTER_READ_IN       => apl_to_buf_REPLY_READ(i),
            INT_MASTER_DATAREADY_IN  => buf_to_apl_REPLY_DATAREADY(i),
            INT_MASTER_DATA_IN       => buf_to_apl_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_MASTER_PACKET_NUM_IN => buf_to_apl_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_MASTER_READ_OUT      => buf_to_apl_REPLY_READ(i),
            INT_SLAVE_HEADER_IN      => '0',
            INT_SLAVE_DATAREADY_OUT  => apl_to_buf_INIT_DATAREADY(i),
            INT_SLAVE_DATA_OUT       => apl_to_buf_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_SLAVE_PACKET_NUM_OUT => apl_to_buf_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_SLAVE_READ_IN        => apl_to_buf_INIT_READ(i),
            INT_SLAVE_DATAREADY_IN => buf_to_apl_INIT_DATAREADY(i),
            INT_SLAVE_DATA_IN      => buf_to_apl_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
            INT_SLAVE_PACKET_NUM_IN=> buf_to_apl_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
            INT_SLAVE_READ_OUT     => buf_to_apl_INIT_READ(i),
            -- Status and control port
            STAT_FIFO_TO_INT => buf_api_stat_fifo_to_int((i+1)*32-1 downto i*32),
            STAT_FIFO_TO_APL => buf_api_stat_fifo_to_apl((i+1)*32-1 downto i*32)
            );
        end generate;
        gentrgapi : if i = 0 generate
          apl_to_buf_INIT_DATAREADY(0) <= '0';
          apl_to_buf_INIT_DATA(15 downto 0) <= (others => '0');
          apl_to_buf_INIT_PACKET_NUM(1 downto 0) <= "00";
          buf_to_apl_REPLY_READ(0) <= '1';
          trglvl1 : trb_net16_term
            generic map(
              USE_APL_PORT => c_YES,
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

              -- "mini" APL, just to see the triggers coming in
              APL_DTYPE_OUT         => LVL1_DTYPE_OUT,
              APL_ERROR_PATTERN_OUT => LVL1_ERROR_PATTERN_OUT,
              APL_SEQNR_OUT         => LVL1_SEQNR_OUT,
              APL_GOT_TRM           => LVL1_GOT_TRIGGER_OUT,
              APL_RELEASE_TRM       => LVL1_RELEASE_IN,
              APL_ERROR_PATTERN_IN  => LVL1_ERROR_PATTERN_IN
              );
        end generate;
      end generate;
      gentermbuf: if USE_CHANNEL(i) = c_NO generate
        termbuf: trb_net16_term_buf
          port map(
            CLK    => CLK,
            RESET  => RESET,
            CLK_EN => CLK_EN,
            MED_DATAREADY_IN       => MED_IO_DATAREADY_IN(i),
            MED_DATA_IN            => MED_IO_DATA_IN,
            MED_PACKET_NUM_IN      => MED_IO_PACKET_NUM_IN,
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


  buf_APL_DATA_IN(1*c_DATA_WIDTH-1 downto 0*c_DATA_WIDTH) <= IPUD_APL_DATA_IN;
  buf_APL_DATA_IN(2*c_DATA_WIDTH-1 downto 1*c_DATA_WIDTH) <= LVL2_APL_DATA_IN;
  buf_APL_PACKET_NUM_IN(1*c_NUM_WIDTH-1 downto 0*c_NUM_WIDTH) <= IPUD_APL_PACKET_NUM_IN;
  buf_APL_PACKET_NUM_IN(2*c_NUM_WIDTH-1 downto 1*c_NUM_WIDTH) <= LVL2_APL_PACKET_NUM_IN;
  buf_APL_DATAREADY_IN(0) <= IPUD_APL_DATAREADY_IN;
  buf_APL_DATAREADY_IN(1) <= LVL2_APL_DATAREADY_IN;
  IPUD_APL_READ_OUT <= buf_APL_READ_OUT(0);
  LVL2_APL_READ_OUT <= buf_APL_READ_OUT(1);
  buf_APL_SHORT_TRANSFER_IN(0) <= IPUD_APL_SHORT_TRANSFER_IN;
  buf_APL_SHORT_TRANSFER_IN(1) <= LVL2_APL_SHORT_TRANSFER_IN;
  buf_APL_DTYPE_IN(1*4-1 downto 0*4) <= IPUD_APL_DTYPE_IN;
  buf_APL_DTYPE_IN(2*4-1 downto 1*4) <= LVL2_APL_DTYPE_IN;
  buf_APL_ERROR_PATTERN_IN(1*32-1 downto 0*32) <= IPUD_APL_ERROR_PATTERN_IN;
  buf_APL_ERROR_PATTERN_IN(2*32-1 downto 1*32) <= LVL2_APL_ERROR_PATTERN_IN;
  buf_APL_SEND_IN(0) <= IPUD_APL_SEND_IN;
  buf_APL_SEND_IN(1) <= LVL2_APL_SEND_IN;
  buf_APL_TARGET_ADDRESS_IN(1*16-1 downto 0*16) <= IPUD_APL_TARGET_ADDRESS_IN;
  buf_APL_TARGET_ADDRESS_IN(2*16-1 downto 1*16) <= LVL2_APL_TARGET_ADDRESS_IN;

  IPUD_APL_DATA_OUT <= buf_APL_DATA_OUT(1*c_DATA_WIDTH-1 downto 0*c_DATA_WIDTH);
  LVL2_APL_DATA_OUT <= buf_APL_DATA_OUT(2*c_DATA_WIDTH-1 downto 1*c_DATA_WIDTH);
  IPUD_APL_PACKET_NUM_OUT <= buf_APL_DATA_OUT(1*c_NUM_WIDTH-1 downto 0*c_NUM_WIDTH);
  LVL2_APL_PACKET_NUM_OUT <= buf_APL_DATA_OUT(2*c_NUM_WIDTH-1 downto 1*c_NUM_WIDTH);
  IPUD_APL_DATAREADY_OUT <= buf_APL_DATAREADY_OUT(0);
  LVL2_APL_DATAREADY_OUT <= buf_APL_DATAREADY_OUT(1);
  buf_APL_READ_IN(0) <= IPUD_APL_READ_IN;
  buf_APL_READ_IN(1) <= LVL2_APL_READ_IN;
  IPUD_APL_TYP_OUT <= buf_APL_TYP_OUT(2 downto 0);
  LVL2_APL_TYP_OUT <= buf_APL_TYP_OUT(5 downto 3);

  buf_APL_DTYPE_IN(1*4-1 downto 0*4) <= IPUD_APL_DTYPE_IN;
  buf_APL_DTYPE_IN(2*4-1 downto 1*4) <= LVL2_APL_DTYPE_IN;
  IPUD_APL_RUN_OUT <= buf_APL_RUN_OUT(0);
  LVL2_APL_RUN_OUT <= buf_APL_RUN_OUT(1);
  IPUD_APL_SEQNR_OUT <= buf_APL_SEQNR_OUT(1*8-1 downto 0*8);
  LVL2_APL_SEQNR_OUT <= buf_APL_SEQNR_OUT(2*8-1 downto 1*8);

  gen_regio : if USE_CHANNEL(c_SLOW_CTRL_CHANNEL) = c_YES generate
  regIO : trb_net16_regIO
    generic map(
      REGISTER_WIDTH     => 32,
      ADDRESS_WIDTH      => 16,
      NUM_STAT_REGS      => SCTR_NUM_STAT_REGS,
      NUM_CTRL_REGS      => SCTR_NUM_CTRL_REGS,
      --standard values for output registers
      INIT_CTRL_REGS     => SCTR_INIT_CTRL_REGS,
      --set to 0 for unused ctrl registers to save resources
      USED_CTRL_REGS     => SCTR_USED_CTRL_REGS,
      --set to 0 for each unused bit in a register
      USED_CTRL_BITMASK  => SCTR_USED_CTRL_BITMASK,
      --no data / address out?
      USE_DAT_PORT       => SCTR_USE_DATA_PORT,
      INIT_ADDRESS       => SCTR_INIT_ADDRESS,
      INIT_UNIQUE_ID     => SCTR_INIT_UNIQUE_ID,
      COMPILE_TIME       => SCTR_COMPILE_TIME,
      COMPILE_VERSION    => SCTR_COMPILE_VERSION,
      HARDWARE_VERSION   => SCTR_HARDWARE_VERSION
      )
    port map(
    --  Misc
      CLK      => CLK,
      RESET    => RESET,
      CLK_EN   => CLK_EN,
    -- Port to API
      API_DATA_OUT           => buf_APL_DATA_IN(3*c_DATA_WIDTH-1 downto 2*c_DATA_WIDTH),
      API_PACKET_NUM_OUT     => buf_APL_PACKET_NUM_IN(3*c_NUM_WIDTH-1 downto 2*c_NUM_WIDTH),
      API_DATAREADY_OUT      => buf_APL_DATAREADY_IN(2),
      API_READ_IN            => buf_APL_READ_OUT(2),
      API_SHORT_TRANSFER_OUT => buf_APL_SHORT_TRANSFER_IN(2),
      API_DTYPE_OUT          => buf_APL_DTYPE_IN(3*4-1 downto 2*4),
      API_ERROR_PATTERN_OUT  => buf_APL_ERROR_PATTERN_IN(3*32-1 downto 2*32),
      API_SEND_OUT           => buf_APL_SEND_IN(2),
      API_TARGET_ADDRESS_OUT => buf_APL_TARGET_ADDRESS_IN(3*16-1 downto 2*16),
      API_DATA_IN            => buf_APL_DATA_OUT(3*c_DATA_WIDTH-1 downto 2*c_DATA_WIDTH),
      API_PACKET_NUM_IN      => buf_APL_PACKET_NUM_OUT(3*c_NUM_WIDTH-1 downto 2*c_NUM_WIDTH),
      API_TYP_IN             => buf_APL_TYP_OUT(3*3-1 downto 2*3),
      API_DATAREADY_IN       => buf_APL_DATAREADY_OUT(2),
      API_READ_OUT           => buf_APL_READ_IN(2),
      API_RUN_IN             => buf_APL_RUN_OUT(2),
      API_SEQNR_IN           => buf_APL_SEQNR_OUT(3*8-1 downto 2*8),
    --Port to write Unique ID
      IDRAM_DATA_IN          => buf_IDRAM_DATA_IN,
      IDRAM_DATA_OUT         => buf_IDRAM_DATA_OUT,
      IDRAM_ADDR_IN          => buf_IDRAM_ADDR_IN,
      IDRAM_WR_IN            => buf_IDRAM_WR_IN,
      MY_ADDRESS_OUT         => MY_ADDRESS,
    --Common Register in / out
      COMMON_STAT_REG_IN     => buf_COMMON_STAT_REG_IN,
      COMMON_CTRL_REG_OUT    => SCTR_COMMON_CTRL_REG_OUT,
    --Custom Register in / out
      REGISTERS_IN           => SCTR_REGISTERS_IN,
      REGISTERS_OUT          => SCTR_REGISTERS_OUT,
    --following ports only used when no internal register is accessed
      DAT_ADDR_OUT           => SCTR_ADDR_OUT,
      DAT_READ_ENABLE_OUT    => SCTR_READ_ENABLE_OUT,
      DAT_WRITE_ENABLE_OUT   => SCTR_WRITE_ENABLE_OUT,
      DAT_DATA_OUT           => SCTR_DATA_OUT,
      DAT_DATA_IN            => SCTR_DATA_IN,
      DAT_DATAREADY_IN       => SCTR_DATAREADY_IN,
      DAT_NO_MORE_DATA_IN    => SCTR_NO_MORE_DATA_IN,
      EXT_REG_DATA_IN        => SCTR_EXT_REG_DATA_IN,
      EXT_REG_DATA_OUT       => SCTR_EXT_REG_DATA_OUT,
      EXT_REG_WRITE_IN       => SCTR_EXT_REG_WRITE_IN,
      EXT_REG_ADDR_IN        => SCTR_EXT_REG_ADDR_IN,
      STAT                   => SCTR_REGIO_STAT
      );
  end generate;
      
  gen_no1wire : if SCTR_USE_1WIRE_INTERFACE = 0 generate
    buf_IDRAM_DATA_IN <= SCTR_IDRAM_DATA_IN;
    buf_IDRAM_ADDR_IN <= SCTR_IDRAM_ADDR_IN;
    buf_IDRAM_WR_IN   <= SCTR_IDRAM_WR_IN;
    SCTR_IDRAM_DATA_OUT <= buf_IDRAM_DATA_OUT;
    SCTR_ONEWIRE_INOUT <= '0';
    buf_COMMON_STAT_REG_IN <= SCTR_COMMON_STAT_REG_IN;
  end generate;
  gen_1wire : if SCTR_USE_1WIRE_INTERFACE = 1 generate
    buf_COMMON_STAT_REG_IN(19 downto 0) <= SCTR_COMMON_STAT_REG_IN(19 downto 0);
    buf_COMMON_STAT_REG_IN(SCTR_COMMON_STAT_REG_IN'left downto 32) <= SCTR_COMMON_STAT_REG_IN(SCTR_COMMON_STAT_REG_IN'left downto 32);

    SCTR_IDRAM_DATA_OUT <= (others => '0');

    onewire_interface : trb_net_onewire
      generic map(
        USE_TEMPERATURE_READOUT => c_YES,
        CLK_PERIOD => 10
        )
      port map(
        CLK      => CLK,
        RESET    => RESET,
        --connection to 1-wire interface
        ONEWIRE  => SCTR_ONEWIRE_INOUT,
        --connection to id ram, according to memory map in TrbNetRegIO
        DATA_OUT => buf_IDRAM_DATA_IN,
        ADDR_OUT => buf_IDRAM_ADDR_IN,
        WRITE_OUT=> buf_IDRAM_WR_IN,
        TEMP_OUT => buf_COMMON_STAT_REG_IN(31 downto 20),
        STAT     => open
        );
  end generate;


  MPLEX: trb_net16_io_multiplexer
    port map (
      CLK      => CLK,
      RESET    => RESET,
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
      CTRL               => MPLEX_CTRL
      );


buf_STAT_CTRL_INIT_BUFFER  <= STAT_CTRL_INIT_BUFFER;
buf_CTRL_GEN <= CTRL_GEN;
STAT_GEN_1 <= (others => '0');
STAT_GEN_2 <= (others => '0');

end architecture;

