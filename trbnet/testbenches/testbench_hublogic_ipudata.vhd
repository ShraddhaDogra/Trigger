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

  constant POINT_NUMBER : integer := 6;

  component trb_net16_hub_ipu_logic is
    generic (
    --media interfaces
      POINT_NUMBER        : integer range 2 to 17 := POINT_NUMBER
      );
    port (
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      --Internal interfaces to IOBufs
      INIT_DATAREADY_IN     : in  std_logic_vector (POINT_NUMBER-1 downto 0);
      INIT_DATA_IN          : in  std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
      INIT_PACKET_NUM_IN    : in  std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
      INIT_READ_OUT         : out std_logic_vector (POINT_NUMBER-1 downto 0);

      INIT_DATAREADY_OUT    : out std_logic_vector (POINT_NUMBER-1 downto 0);
      INIT_DATA_OUT         : out std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
      INIT_PACKET_NUM_OUT   : out std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
      INIT_READ_IN          : in  std_logic_vector (POINT_NUMBER-1 downto 0);

      REPLY_DATAREADY_IN    : in  std_logic_vector (POINT_NUMBER-1 downto 0);
      REPLY_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
      REPLY_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
      REPLY_READ_OUT        : out std_logic_vector (POINT_NUMBER-1 downto 0);

      REPLY_DATAREADY_OUT   : out std_logic_vector (POINT_NUMBER-1 downto 0);
      REPLY_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
      REPLY_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
      REPLY_READ_IN         : in  std_logic_vector (POINT_NUMBER-1 downto 0);

      MY_ADDRESS_IN         : in  std_logic_vector (15 downto 0);
      --Status ports
      STAT_DEBUG         : out std_logic_vector (31 downto 0);
      STAT_locked        : out std_logic;
      STAT_POINTS_locked : out std_logic_vector (31 downto 0);
      STAT_TIMEOUT       : out std_logic_vector (31 downto 0);
      STAT_ERRORBITS     : out std_logic_vector (31 downto 0);
      STAT_ALL_ERRORBITS : out std_logic_vector (16*32-1 downto 0);
      STAT_FSM           : out std_logic_vector (31 downto 0);
      STAT_MISMATCH      : out std_logic_vector (31 downto 0);
      CTRL_TIMEOUT_TIME  : in  std_logic_vector (15 downto 0) := x"0003";
      CTRL_activepoints  : in  std_logic_vector (31 downto 0) := (others => '1');
      CTRL_DISABLED_PORTS   : in  std_logic_vector (31 downto 0) := (others => '0');
      CTRL_TIMER_TICK    : in  std_logic_vector (1 downto 0)
      );
  end component;

  component trb_net16_api_base is
    generic (
      API_TYPE          : integer range 0 to 1 := c_API_PASSIVE;
      FIFO_TO_INT_DEPTH : integer range 0 to 6 := 6;--std_FIFO_DEPTH;
      FIFO_TO_APL_DEPTH : integer range 1 to 6 := 6;--std_FIFO_DEPTH;
      FORCE_REPLY       : integer range 0 to 1 := std_FORCE_REPLY;
      SBUF_VERSION      : integer range 0 to 1 := std_SBUF_VERSION;
      USE_VENDOR_CORES  : integer range 0 to 1 := c_YES;
      SECURE_MODE_TO_APL: integer range 0 to 1 := c_YES;
      SECURE_MODE_TO_INT: integer range 0 to 1 := c_YES;
      APL_WRITE_ALL_WORDS:integer range 0 to 1 := c_NO;
      BROADCAST_BITMASK : std_logic_vector(7 downto 0) := x"FF"
      );

    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      -- APL Transmitter port
      APL_DATA_IN           : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      APL_PACKET_NUM_IN     : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      APL_DATAREADY_IN      : in  std_logic;
      APL_READ_OUT          : out std_logic;
      APL_SHORT_TRANSFER_IN : in  std_logic;
      APL_DTYPE_IN          : in  std_logic_vector (3 downto 0);
      APL_ERROR_PATTERN_IN  : in  std_logic_vector (31 downto 0);
      APL_SEND_IN           : in  std_logic;
      APL_TARGET_ADDRESS_IN : in  std_logic_vector (15 downto 0);-- the target (only for active APIs)

      -- Receiver port
      APL_DATA_OUT          : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      APL_PACKET_NUM_OUT    : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      APL_TYP_OUT           : out std_logic_vector (2 downto 0);
      APL_DATAREADY_OUT     : out std_logic;
      APL_READ_IN           : in  std_logic;

      -- APL Control port
      APL_RUN_OUT           : out std_logic;
      APL_MY_ADDRESS_IN     : in  std_logic_vector (15 downto 0);
      APL_SEQNR_OUT         : out std_logic_vector (7 downto 0);
      APL_LENGTH_IN         : in  std_logic_vector (15 downto 0);

      -- Internal direction port
      -- the ports with master or slave in their name are to be mapped by the active api
      -- to the init respectivly the reply path and vice versa in the passive api.
      -- lets define: the "master" path is the path that I send data on.
      -- master_data_out and slave_data_in are only used in active API for termination
      INT_MASTER_DATAREADY_OUT  : out std_logic;
      INT_MASTER_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_MASTER_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_MASTER_READ_IN        : in  std_logic;

      INT_MASTER_DATAREADY_IN   : in  std_logic;
      INT_MASTER_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_MASTER_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_MASTER_READ_OUT       : out std_logic;

      INT_SLAVE_DATAREADY_OUT   : out std_logic;
      INT_SLAVE_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_SLAVE_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_SLAVE_READ_IN         : in  std_logic;

      INT_SLAVE_DATAREADY_IN    : in  std_logic;
      INT_SLAVE_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_SLAVE_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_SLAVE_READ_OUT        : out std_logic;

      -- Status and control port
      CTRL_SEQNR_RESET          : in  std_logic := '0';
      STAT_FIFO_TO_INT          : out std_logic_vector(31 downto 0);
      STAT_FIFO_TO_APL          : out std_logic_vector(31 downto 0)
      );
  end component;


  component trb_net16_dummy_apl is
    generic (
      TARGET_ADDRESS : std_logic_vector (15 downto 0) := x"F001";
      PREFILL_LENGTH  : integer := 1;
      TRANSFER_LENGTH  : integer := 1  -- length of dummy data
                                    -- might not work with transfer_length > api_fifo
                                    -- because of incorrect handling of fifo_full_in!

      );
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      -- APL Transmitter port
      APL_DATA_OUT:       out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      APL_PACKET_NUM_OUT: out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      APL_DATAREADY_OUT    : out std_logic;
      APL_READ_IN          : in std_logic;
      APL_SHORT_TRANSFER_OUT: out std_logic;
      APL_DTYPE_OUT:      out std_logic_vector (3 downto 0);
      APL_ERROR_PATTERN_OUT: out std_logic_vector (31 downto 0);
      APL_SEND_OUT:       out std_logic;
      APL_TARGET_ADDRESS_OUT: out std_logic_vector (15 downto 0);
      -- Receiver port
      APL_DATA_IN:      in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      APL_PACKET_NUM_IN:in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      APL_TYP_IN:       in  std_logic_vector (2 downto 0);
      APL_DATAREADY_IN: in  std_logic;
      APL_READ_OUT:     out std_logic;
      -- APL Control port
      APL_RUN_IN:       in std_logic;
      APL_SEQNR_IN:     in std_logic_vector (7 downto 0)
      );
  end component;

  component trb_net16_ipudata is
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
      -- Receiver port
      API_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      API_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
      API_TYP_IN          : in  std_logic_vector (2 downto 0);
      API_DATAREADY_IN    : in  std_logic;
      API_READ_OUT        : out std_logic;
      -- APL Control port
      API_RUN_IN          : in  std_logic;
      API_SEQNR_IN        : in  std_logic_vector (7 downto 0);
      API_LENGTH_OUT      : out std_logic_vector (15 downto 0);
      MY_ADDRESS_IN       : in  std_logic_vector (15 downto 0);
      --Information received with request
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


      STAT_DEBUG          : out std_logic_vector(31 downto 0)
      );
  end component;

  signal CLK : std_logic := '1';
  signal RESET : std_logic := '1';
  signal CLK_EN : std_logic := '1';

  signal INIT_DATAREADY_IN     :  std_logic_vector (POINT_NUMBER-1 downto 0);
  signal INIT_DATA_IN          :  std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
  signal INIT_PACKET_NUM_IN    :  std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
  signal INIT_READ_OUT         :  std_logic_vector (POINT_NUMBER-1 downto 0);

  signal INIT_DATAREADY_OUT    :  std_logic_vector (POINT_NUMBER-1 downto 0);
  signal INIT_DATA_OUT         :  std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
  signal INIT_PACKET_NUM_OUT   :  std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
  signal INIT_READ_IN          :  std_logic_vector (POINT_NUMBER-1 downto 0);

  signal REPLY_DATAREADY_IN    :  std_logic_vector (POINT_NUMBER-1 downto 0);
  signal REPLY_DATA_IN         :  std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
  signal REPLY_PACKET_NUM_IN   :  std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
  signal REPLY_READ_OUT        :  std_logic_vector (POINT_NUMBER-1 downto 0);

  signal REPLY_DATAREADY_OUT   :  std_logic_vector (POINT_NUMBER-1 downto 0);
  signal REPLY_DATA_OUT        :  std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
  signal REPLY_PACKET_NUM_OUT  :  std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
  signal REPLY_READ_IN         :  std_logic_vector (POINT_NUMBER-1 downto 0);


  signal APL_DATA_IN : std_logic_vector(POINT_NUMBER*c_DATA_WIDTH-1 downto 0);
  signal APL_PACKET_NUM_IN : std_logic_vector(POINT_NUMBER*c_NUM_WIDTH-1 downto 0);
  signal APL_DATAREADY_IN : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal APL_READ_OUT : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal APL_SHORT_TRANSFER_IN : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal APL_DTYPE_IN : std_logic_vector(POINT_NUMBER*4-1 downto 0);
  signal APL_ERROR_PATTERN_IN : std_logic_vector(POINT_NUMBER*32-1 downto 0);
  signal APL_SEND_IN : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal APL_TARGET_ADDRESS_IN : std_logic_vector(POINT_NUMBER*c_DATA_WIDTH-1 downto 0);
  signal APL_DATA_OUT : std_logic_vector(POINT_NUMBER*c_DATA_WIDTH-1 downto 0);
  signal APL_PACKET_NUM_OUT : std_logic_vector(POINT_NUMBER*c_NUM_WIDTH-1 downto 0);
  signal APL_TYP_OUT : std_logic_vector(POINT_NUMBER*3-1 downto 0);
  signal APL_DATAREADY_OUT : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal APL_READ_IN : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal APL_RUN_OUT : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal APL_SEQNR_OUT : std_logic_vector(POINT_NUMBER*8-1 downto 0);
  signal APL_LENGTH_IN : std_logic_vector(POINT_NUMBER*16-1 downto 0);
  signal APL_MY_ADDRESS_IN : std_logic_vector(POINT_NUMBER*16-1 downto 0);

  signal IPU_NUMBER_OUT : std_logic_vector(POINT_NUMBER*16-1 downto 16);
  signal IPU_INFORMATION_OUT : std_logic_vector(POINT_NUMBER*8-1 downto 8);
  signal IPU_START_READOUT_OUT : std_logic_vector(POINT_NUMBER-1 downto 1);
  signal IPU_DATA_IN : std_logic_vector(POINT_NUMBER*32-1 downto 32);
  signal IPU_DATAREADY_IN : std_logic_vector(POINT_NUMBER*1-1 downto 1);
  signal IPU_READOUT_FINISHED_IN : std_logic_vector(POINT_NUMBER*1-1 downto 1);
  signal IPU_READ_OUT : std_logic_vector(POINT_NUMBER*1-1 downto 1);
  signal IPU_LENGTH_IN : std_logic_vector(POINT_NUMBER*16-1 downto 16);
  signal IPU_ERROR_PATTERN_IN : std_logic_vector(POINT_NUMBER*32-1 downto 32);

  type state_t is array(1 to POINT_NUMBER) of integer range 0 to 255;
  signal state : state_t;
  signal counter : state_t;
  signal state_vec : std_logic_vector(POINT_NUMBER*4-1 downto 0);
  signal counter_vec : std_logic_vector(POINT_NUMBER*8-1 downto 0);
  signal CTRL_TIMER_TICK : std_logic_vector(1 downto 0) := "00";
  
  type int16_arr is array(0 to 5) of integer;
  signal data_amount : int16_arr := (0,16,0,0,0,5);
  
begin
  CLK <= not CLK after 5 ns;
  RESET <= '0' after 50 ns;
  CLK_EN <= '1';
  
  data_amount(0) <= 0;
  data_amount(1) <= 16;
  data_amount(2) <= 0;
  data_amount(3) <= 0;
  data_amount(4) <= 0;
  data_amount(5) <= 5;
  
  process begin
    wait for 1 us;
    wait until rising_edge(CLK);
    CTRL_TIMER_TICK(0) <= '1';
    wait until rising_edge(CLK);
    CTRL_TIMER_TICK(0) <= '0';
  end process;  
  
  process begin
    wait for 1 ms;
    wait until rising_edge(CLK);
    CTRL_TIMER_TICK(1) <= '1';
    wait until rising_edge(CLK);
    CTRL_TIMER_TICK(1) <= '0';
  end process;

  THE_HUB_LOGIC : trb_net16_hub_ipu_logic
    port map(
      CLK    => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,

      --Internal interfaces to IOBufs
      INIT_DATAREADY_IN     => INIT_DATAREADY_IN,
      INIT_DATA_IN          => INIT_DATA_IN,
      INIT_PACKET_NUM_IN    => INIT_PACKET_NUM_IN,
      INIT_READ_OUT         => INIT_READ_OUT,

      INIT_DATAREADY_OUT    => INIT_DATAREADY_OUT,
      INIT_DATA_OUT         => INIT_DATA_OUT,
      INIT_PACKET_NUM_OUT   => INIT_PACKET_NUM_OUT,
      INIT_READ_IN          => INIT_READ_IN,

      REPLY_DATAREADY_IN    => REPLY_DATAREADY_IN,
      REPLY_DATA_IN         => REPLY_DATA_IN,
      REPLY_PACKET_NUM_IN   => REPLY_PACKET_NUM_IN,
      REPLY_READ_OUT        => REPLY_READ_OUT,

      REPLY_DATAREADY_OUT   => REPLY_DATAREADY_OUT,
      REPLY_DATA_OUT        => REPLY_DATA_OUT,
      REPLY_PACKET_NUM_OUT  => REPLY_PACKET_NUM_OUT,
      REPLY_READ_IN         => REPLY_READ_IN,

      MY_ADDRESS_IN         => x"FCCC",
      --Status ports
      CTRL_TIMER_TICK       => CTRL_TIMER_TICK,
      CTRL_activepoints     => (others => '1')
      );

  THE_ACTIVE_API : trb_net16_api_base
    generic map(
      API_TYPE => c_API_ACTIVE
      )
    port map(
      --  Misc
      CLK    => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,
      APL_DATA_IN           => APL_DATA_IN(15 downto 0),
      APL_PACKET_NUM_IN     => APL_PACKET_NUM_IN(2 downto 0),
      APL_DATAREADY_IN      => APL_DATAREADY_IN(0),
      APL_READ_OUT          => APL_READ_OUT(0),
      APL_SHORT_TRANSFER_IN => APL_SHORT_TRANSFER_IN(0),
      APL_DTYPE_IN          => APL_DTYPE_IN(3 downto 0),
      APL_ERROR_PATTERN_IN  => APL_ERROR_PATTERN_IN(31 downto 0),
      APL_SEND_IN           => APL_SEND_IN(0),
      APL_TARGET_ADDRESS_IN => APL_TARGET_ADDRESS_IN(15 downto 0),
      APL_DATA_OUT          => APL_DATA_OUT(c_DATA_WIDTH-1 downto 0),
      APL_PACKET_NUM_OUT    => APL_PACKET_NUM_OUT (c_NUM_WIDTH-1 downto 0),
      APL_TYP_OUT           => APL_TYP_OUT(2 downto 0),
      APL_DATAREADY_OUT     => APL_DATAREADY_OUT(0),
      APL_READ_IN           => APL_READ_IN(0),
      APL_RUN_OUT           => APL_RUN_OUT(0),
      APL_MY_ADDRESS_IN     => APL_MY_ADDRESS_IN(15 downto 0),
      APL_SEQNR_OUT         => APL_SEQNR_OUT(7 downto 0),
      APL_LENGTH_IN         => APL_LENGTH_IN(15 downto 0),
      INT_MASTER_DATAREADY_OUT  => INIT_DATAREADY_IN(0),
      INT_MASTER_DATA_OUT       => INIT_DATA_IN(c_DATA_WIDTH-1 downto 0),
      INT_MASTER_PACKET_NUM_OUT => INIT_PACKET_NUM_IN(c_NUM_WIDTH-1 downto 0),
      INT_MASTER_READ_IN        => INIT_READ_OUT(0),
      INT_MASTER_DATAREADY_IN   => INIT_DATAREADY_OUT(0),
      INT_MASTER_DATA_IN        => INIT_DATA_OUT(15 downto 0),
      INT_MASTER_PACKET_NUM_IN  => INIT_PACKET_NUM_OUT(c_NUM_WIDTH-1 downto 0),
      INT_MASTER_READ_OUT       => INIT_READ_IN(0),
      INT_SLAVE_DATAREADY_OUT  => REPLY_DATAREADY_IN(0),
      INT_SLAVE_DATA_OUT       => REPLY_DATA_IN(c_DATA_WIDTH-1 downto 0),
      INT_SLAVE_PACKET_NUM_OUT => REPLY_PACKET_NUM_IN(c_NUM_WIDTH-1 downto 0),
      INT_SLAVE_READ_IN        => REPLY_READ_OUT(0),
      INT_SLAVE_DATAREADY_IN   => REPLY_DATAREADY_OUT(0),
      INT_SLAVE_DATA_IN        => REPLY_DATA_OUT(15 downto 0),
      INT_SLAVE_PACKET_NUM_IN  => REPLY_PACKET_NUM_OUT(c_NUM_WIDTH-1 downto 0),
      INT_SLAVE_READ_OUT       => REPLY_READ_IN(0)
--       INT_MASTER_DATAREADY_OUT  => INIT_DATAREADY_OUT(1),
--       INT_MASTER_DATA_OUT       => INIT_DATA_OUT(31 downto 16),
--       INT_MASTER_PACKET_NUM_OUT => INIT_PACKET_NUM_OUT(5 downto 3),
--       INT_MASTER_READ_IN        => INIT_READ_IN(1),
--       INT_MASTER_DATAREADY_IN   => INIT_DATAREADY_IN(1),
--       INT_MASTER_DATA_IN        => INIT_DATA_IN(31 downto 16),
--       INT_MASTER_PACKET_NUM_IN  => INIT_PACKET_NUM_IN(5 downto 3),
--       INT_MASTER_READ_OUT       => INIT_READ_OUT(1),
--       INT_SLAVE_DATAREADY_OUT  => REPLY_DATAREADY_OUT(1),
--       INT_SLAVE_DATA_OUT       => REPLY_DATA_OUT(31 downto 16),
--       INT_SLAVE_PACKET_NUM_OUT => REPLY_PACKET_NUM_OUT(5 downto 3),
--       INT_SLAVE_READ_IN        => REPLY_READ_IN(1),
--       INT_SLAVE_DATAREADY_IN   => REPLY_DATAREADY_IN(1),
--       INT_SLAVE_DATA_IN        => REPLY_DATA_IN(31 downto 16),
--       INT_SLAVE_PACKET_NUM_IN  => REPLY_PACKET_NUM_IN(5 downto 3),
--       INT_SLAVE_READ_OUT       => REPLY_READ_OUT(1)
      );
  REPLY_DATAREADY_IN(0) <= '0';



  gen_passive_apis : for i in 1 to POINT_NUMBER-1 generate
    A_PASSIVE_API : trb_net16_api_base
      generic map(
        API_TYPE => c_API_PASSIVE
        )
      port map(
        --  Misc
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        APL_DATA_IN           => APL_DATA_IN(i*16+15 downto i*16),
        APL_PACKET_NUM_IN     => APL_PACKET_NUM_IN(i*3+2 downto i*3),
        APL_DATAREADY_IN      => APL_DATAREADY_IN(i),
        APL_READ_OUT          => APL_READ_OUT(i),
        APL_SHORT_TRANSFER_IN => APL_SHORT_TRANSFER_IN(i),
        APL_DTYPE_IN          => APL_DTYPE_IN(i*4+3 downto i*4),
        APL_ERROR_PATTERN_IN  => APL_ERROR_PATTERN_IN(i*32+31 downto i*32),
        APL_SEND_IN           => APL_SEND_IN(i),
        APL_TARGET_ADDRESS_IN => APL_TARGET_ADDRESS_IN(i*16+15 downto i*16),
        APL_DATA_OUT          => APL_DATA_OUT((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
        APL_PACKET_NUM_OUT    => APL_PACKET_NUM_OUT ((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
        APL_TYP_OUT           => APL_TYP_OUT((i+1)*3-1 downto i*3),
        APL_DATAREADY_OUT     => APL_DATAREADY_OUT(i),
        APL_READ_IN           => APL_READ_IN(i),
        APL_RUN_OUT           => APL_RUN_OUT(i),
        APL_MY_ADDRESS_IN     => APL_MY_ADDRESS_IN(i*16+15 downto i*16),
        APL_SEQNR_OUT         => APL_SEQNR_OUT(i*8+7 downto i*8),
        APL_LENGTH_IN         => APL_LENGTH_IN(i*16+15 downto i*16),
        INT_MASTER_DATAREADY_OUT => REPLY_DATAREADY_IN(i),
        INT_MASTER_DATA_OUT      => REPLY_DATA_IN(i*16+15 downto i*16),
        INT_MASTER_PACKET_NUM_OUT=> REPLY_PACKET_NUM_IN(i*3+2 downto i*3),
        INT_MASTER_READ_IN       => REPLY_READ_OUT(i),
        INT_MASTER_DATAREADY_IN  => REPLY_DATAREADY_OUT(i),
        INT_MASTER_DATA_IN       => REPLY_DATA_OUT(i*16+15 downto i*16),
        INT_MASTER_PACKET_NUM_IN => REPLY_PACKET_NUM_OUT(i*3+2 downto i*3),
        INT_MASTER_READ_OUT      => REPLY_READ_IN(i),
        INT_SLAVE_DATAREADY_OUT  => INIT_DATAREADY_IN(i),
        INT_SLAVE_DATA_OUT       => INIT_DATA_IN(i*16+15 downto i*16),
        INT_SLAVE_PACKET_NUM_OUT => INIT_PACKET_NUM_IN(i*3+2 downto i*3),
        INT_SLAVE_READ_IN        => INIT_READ_OUT(i),
        INT_SLAVE_DATAREADY_IN   => INIT_DATAREADY_OUT(i),
        INT_SLAVE_DATA_IN        => INIT_DATA_OUT(i*16+15 downto i*16),
        INT_SLAVE_PACKET_NUM_IN  => INIT_PACKET_NUM_OUT(i*3+2 downto i*3),
        INT_SLAVE_READ_OUT       => INIT_READ_IN(i)
        );
  end generate;


  THE_SENDER : trb_net16_dummy_apl
    generic map(
      TARGET_ADDRESS => x"FFFF",
      PREFILL_LENGTH  => 1,
      TRANSFER_LENGTH  => 1
      )
    port map(
      --  Misc
      CLK    => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,
      -- APL Transmitter port
      APL_DATA_OUT           => APL_DATA_IN(15 downto 0),
      APL_PACKET_NUM_OUT     => APL_PACKET_NUM_IN(2 downto 0),
      APL_DATAREADY_OUT      => open,
      APL_READ_IN            => APL_READ_OUT(0),
      APL_SHORT_TRANSFER_OUT => open,
      APL_DTYPE_OUT          => open,
      APL_ERROR_PATTERN_OUT  => open,
      APL_SEND_OUT           => open, --APL_SEND_IN(0),
      APL_TARGET_ADDRESS_OUT => APL_TARGET_ADDRESS_IN(15 downto 0),
      -- Receiver port
      APL_DATA_IN          => APL_DATA_OUT(15 downto 0),
      APL_PACKET_NUM_IN    => APL_PACKET_NUM_OUT(2 downto 0),
      APL_TYP_IN           => APL_TYP_OUT(2 downto 0),
      APL_DATAREADY_IN     => APL_DATAREADY_OUT(0),
      APL_READ_OUT         => APL_READ_IN(0),
      -- APL Control port
      APL_RUN_IN           => APL_RUN_OUT(0),
      APL_SEQNR_IN         => APL_SEQNR_OUT(7 downto 0)
      );

APL_ERROR_PATTERN_IN(31 downto 0) <= x"0055" & x"EFE0";
APL_DTYPE_IN(3 downto 0) <= x"9";
APL_SHORT_TRANSFER_IN(0) <= '1';
APL_DATAREADY_IN(0) <= '0';
APL_SEND_IN(0) <= not APL_RUN_OUT(0);


  gen_ipudatas : for i in 1 to POINT_NUMBER-1 generate
    A_IPUDATA : trb_net16_ipudata
      port map(
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        API_DATA_OUT           => APL_DATA_IN(i*16+15 downto i*16),
        API_PACKET_NUM_OUT     => APL_PACKET_NUM_IN(i*3+2 downto i*3),
        API_DATAREADY_OUT      => APL_DATAREADY_IN(i),
        API_READ_IN            => APL_READ_OUT(i),
        API_SHORT_TRANSFER_OUT => APL_SHORT_TRANSFER_IN(i),
        API_DTYPE_OUT          => APL_DTYPE_IN((i+1)*4-1 downto i*4),
        API_ERROR_PATTERN_OUT  => APL_ERROR_PATTERN_IN((i+1)*32-1 downto i*32),
        API_SEND_OUT           => APL_SEND_IN(i),
        -- Receiver port
        API_DATA_IN          => APL_DATA_OUT((i+1)*16-1 downto i*16),
        API_PACKET_NUM_IN    => APL_PACKET_NUM_OUT((i+1)*3-1 downto i*3),
        API_TYP_IN           => APL_TYP_OUT((i+1)*3-1 downto i*3),
        API_DATAREADY_IN     => APL_DATAREADY_OUT(i),
        API_READ_OUT         => APL_READ_IN(i),
        -- APL Control port
        API_RUN_IN           => APL_RUN_OUT(i),
        API_SEQNR_IN         => APL_SEQNR_OUT((i+1)*8-1 downto i*8),
        API_LENGTH_OUT       => APL_LENGTH_IN((i+1)*16-1 downto i*16),
        MY_ADDRESS_IN        => APL_MY_ADDRESS_IN(i*16+15 downto i*16),
        --Information received with request
        IPU_NUMBER_OUT         => IPU_NUMBER_OUT((i+1)*16-1 downto i*16),
        IPU_INFORMATION_OUT    => IPU_INFORMATION_OUT((i+1)*8-1 downto i*8),
        --start strobe
        IPU_START_READOUT_OUT  => IPU_START_READOUT_OUT(i),
        --detector data, equipped with DHDR
        IPU_DATA_IN            => IPU_DATA_IN((i+1)*32-1 downto i*32),
        IPU_DATAREADY_IN       => IPU_DATAREADY_IN(i),
        --no more data, end transfer, send TRM
        IPU_READOUT_FINISHED_IN=> IPU_READOUT_FINISHED_IN(i),
        --will be low every second cycle due to 32bit -> 16bit conversion
        IPU_READ_OUT           => IPU_READ_OUT(i),
        IPU_LENGTH_IN          => IPU_LENGTH_IN((i+1)*16-1 downto i*16),
        IPU_ERROR_PATTERN_IN   => IPU_ERROR_PATTERN_IN((i+1)*32-1 downto i*32),
        STAT_DEBUG             => open
        );

    IPU_ERROR_PATTERN_IN((i+1)*32-1 downto i*32) <= (others => '0');

    counter_vec(i*4+3 downto i*4) <= std_logic_vector(to_unsigned(counter(i),4));
    state_vec(i*4+3 downto i*4)   <= std_logic_vector(to_unsigned(state(i),4));

    process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            IPU_LENGTH_IN((i*16+15) downto i*16) <= (others => '0');
            IPU_DATA_IN((i*32+31) downto i*32) <= (others => '0');
            IPU_READOUT_FINISHED_IN(i) <= '0';
          else
            case state(i) is
              when 0 =>
                if IPU_START_READOUT_OUT(i) = '1' then
                  state(i) <= 1;
                  counter(i) <= 0;
                  IPU_DATAREADY_IN(i) <= '0';
                  IPU_READOUT_FINISHED_IN(i) <= '0';
                end if;
              when 1 =>
                counter(i) <= counter(i) + 1;
                if counter(i) = 20-2*i then
                  counter(i) <= counter(i);
                  if IPU_READ_OUT(i) = '1' then
                    state(i) <= 2;
                    counter(i) <= 1;
                  end if;
                  IPU_DATAREADY_IN(i) <= '1';
                  IPU_LENGTH_IN((i*16+15) downto i*16) <= std_logic_vector(to_unsigned(data_amount(i),16));
                  IPU_DATA_IN((i*32+31) downto i*32) <= "0000"&"0001"&x"cc" & x"EEEE";
                end if;
              when 2 =>
                IPU_DATAREADY_IN(i) <= '1';
                if IPU_READ_OUT(i) = '1' and IPU_DATAREADY_IN(i) = '1' then
                  counter(i) <= counter(i) + 1;
                end if;
--                 case counter(i) is
--                   when 1 =>
--                     IPU_DATA_IN((i*32+31) downto i*32) <= std_logic_vector(to_unsigned(0,16)) & APL_MY_ADDRESS_IN(i*16+15 downto i*16);
--                     IPU_DATAREADY_IN(i) <= '1';
--                   when others =>
                    IPU_DATA_IN((i*32+31) downto i*32) <= std_logic_vector(to_unsigned(counter(i),16)) & std_logic_vector(to_unsigned(counter(i),16));
--                 end case;
                if counter(i) = data_amount(i)+3 then --normal: 1
                  IPU_DATAREADY_IN(i) <= '0';
                  IPU_READOUT_FINISHED_IN(i) <= '1';
                  state(i) <= 3;
                end if;
              when 3 =>
                if IPU_START_READOUT_OUT(i) = '0' then
                  state(i) <= 0;
                end if;
              when others => state(i) <= 0;
            end case;
          end if;
        end if;
      end process;
  end generate;




APL_MY_ADDRESS_IN <= x"F00E_F00D_F00C_F00B_F00A_F000";


end architecture;