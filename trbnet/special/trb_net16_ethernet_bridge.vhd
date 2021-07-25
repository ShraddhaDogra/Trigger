
entity trb_net16_ethernet_bridge is
  port(
    CLK    : out std_logic;
    RESET  : out std_logic;
    CLK_EN : out std_logic;

    --CTS Request Information
    IPU_NUMBER_IN               : in  std_logic_vector (15 downto 0);
    IPU_CODE_IN                 : in  std_logic_vector (7  downto 0);
    IPU_OUTFORMATION_IN         : in  std_logic_vector (7  downto 0);
    IPU_START_READOUT_IN        : in  std_logic;

    --Data from FEE and to CTS
    APL_CTS_DATA_OUT            : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    APL_CTS_PACKET_NUM_OUT      : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    APL_CTS_DATAREADY_OUT       : out std_logic;
    APL_CTS_READ_IN             : in  std_logic;
    APL_CTS_SHORT_TRANSFER_OUT  : out std_logic;
    APL_CTS_DTYPE_OUT           : out std_logic_vector (3 downto 0);
    APL_CTS_ERROR_PATTERN_OUT   : out std_logic_vector (31 downto 0);
    APL_CTS_SEND_OUT            : out std_logic;
    APL_CTS_LENGTH_OUT          : out std_logic_vector (15 downto 0);
    APL_FEE_DATA_IN             : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    APL_FEE_PACKET_NUM_IN       : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    APL_FEE_TYP_IN              : in  std_logic_vector (2 downto 0);
    APL_FEE_DATAREADY_IN        : in  std_logic;
    APL_FEE_READ_OUT            : out std_logic;
    APL_RUN_IN                  : in  std_logic;
    APL_MY_ADDRESS_OUT          : out std_logic_vector (15 downto 0);

    --Slow Control
    DAT_ADDR_IN          : in  std_logic_vector(c_REGIO_ADDRESS_WIDTH -1 downto 0);
    DAT_READ_ENABLE_IN   : in  std_logic;
    DAT_WRITE_ENABLE_IN  : in  std_logic;
    DAT_DATA_IN          : in  std_logic_vector(c_REGIO_REG_WIDTH -1 downto 0);
    DAT_DATA_OUT         : out std_logic_vector(c_REGIO_REG_WIDTH -1 downto 0);
    DAT_DATAREADY_OUT    : out std_logic;
    DAT_NO_MORE_DATA_OUT : out std_logic;
    DAT_WRITE_ACK_OUT    : out std_logic;
    DAT_UNKNOWN_ADDR_OUT : out std_logic;
    DAT_TIMEOUT_IN       : in  std_logic;

    --GbE


    --Status & Debugging


    );
end entity;