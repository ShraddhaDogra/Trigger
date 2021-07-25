-- connection between the TRBNET and any application
-- for a description see HADES wiki
-- http://hades-wiki.gsi.de/cgi-bin/view/DaqSlowControl/TrbNetAPI

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;


entity trb_net16_api_active is

  generic (
    FIFO_TO_INT_DEPTH : integer := std_FIFO_DEPTH;     -- direction to medium
    FIFO_TO_APL_DEPTH : integer := std_FIFO_DEPTH;     -- direction to application
    SBUF_VERSION      : integer := std_SBUF_VERSION;
    );

  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    -- APL Transmitter port
    APL_DATA_IN           : in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word "application to network"
    APL_PACKET_NUM_IN     : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    APL_WRITE_IN          : in  std_logic; -- Data word is valid and should be transmitted
    APL_FIFO_FULL_OUT     : out std_logic; -- Stop transfer, the fifo is full
    APL_SHORT_TRANSFER_IN : in  std_logic; --
    APL_DTYPE_IN          : in  std_logic_vector (3 downto 0);  -- see NewTriggerBusNetworkDescr
    APL_ERROR_PATTERN_IN  : in  std_logic_vector (31 downto 0); -- see NewTriggerBusNetworkDescr
    APL_SEND_IN           : in  std_logic; -- Release sending of the data
    APL_TARGET_ADDRESS_IN : in  std_logic_vector (15 downto 0); -- Address of
                                                               -- the target (only for active APIs)

    -- Receiver port
    APL_DATA_OUT          : out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word "network to application"
    APL_PACKET_NUM_OUT    : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    APL_TYP_OUT           : out std_logic_vector (2 downto 0);  -- Which kind of data word: DAT, HDR or TRM
    APL_DATAREADY_OUT     : out std_logic; -- Data word is valid and might be read out
    APL_READ_IN           : in  std_logic; -- Read data word
    
    -- APL Control port
    APL_RUN_OUT           : out std_logic; -- Data transfer is running
    APL_MY_ADDRESS_IN     : in  std_logic_vector (15 downto 0);  -- My own address (temporary solution!!!)
    APL_SEQNR_OUT         : out std_logic_vector (7 downto 0);
    
    -- Internal direction port
    -- the ports with master or slave in their name are to be mapped by the active api
    -- to the init respectivly the reply path and vice versa in the passive api.
    -- lets define: the "master" path is the path that I send data on.
    INT_INIT_DATAREADY_OUT  : out std_logic;
    INT_INIT_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
    INT_INIT_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    INT_INIT_READ_IN        : in  std_logic;

    INT_INIT_DATAREADY_IN   : in  std_logic;
    INT_INIT_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
    INT_INIT_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    INT_INIT_READ_OUT       : out std_logic;


    INT_REPLY_HEADER_IN       : in  std_logic; -- Concentrator kindly asks to resend the last
                                      -- header (only for the reply path)
    INT_REPLY_DATAREADY_OUT   : out std_logic;
    INT_REPLY_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
    INT_REPLY_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    INT_REPLY_READ_IN         : in  std_logic;

    INT_REPLY_DATAREADY_IN    : in  std_logic;
    INT_REPLY_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
    INT_REPLY_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    INT_REPLY_READ_OUT        : out std_logic;

    -- Status and control port
    STAT_FIFO_TO_INT          : out std_logic_vector(31 downto 0);
    STAT_FIFO_TO_APL          : out std_logic_vector(31 downto 0)
    );
end entity;

architecture trb_net16_api_active_arch of trb_net16_api_active is

  component trb_net16_api_base is
    generic (
      API_TYPE : integer := 1;              -- type of api: 0 passive, 1 active
      FIFO_TO_INT_DEPTH : integer := FIFO_TO_INT_DEPTH;
      FIFO_TO_APL_DEPTH : integer := FIFO_TO_APL_DEPTH;
      SBUF_VERSION      : integer := std_SBUF_VERSION
      );
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
  
      -- APL Transmitter port
      APL_DATA_IN           : in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word "application to network"
      APL_PACKET_NUM_IN     : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      APL_WRITE_IN          : in  std_logic; -- Data word is valid and should be transmitted
      APL_FIFO_FULL_OUT     : out std_logic; -- Stop transfer, the fifo is full
      APL_SHORT_TRANSFER_IN : in  std_logic; --
      APL_DTYPE_IN          : in  std_logic_vector (3 downto 0);  -- see NewTriggerBusNetworkDescr
      APL_ERROR_PATTERN_IN  : in  std_logic_vector (31 downto 0); -- see NewTriggerBusNetworkDescr
      APL_SEND_IN           : in  std_logic; -- Release sending of the data
      APL_TARGET_ADDRESS_IN : in  std_logic_vector (15 downto 0); -- Address of
                                                                -- the target (only for active APIs)
  
      -- Receiver port
      APL_DATA_OUT          : out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word "network to application"
      APL_PACKET_NUM_OUT    : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      APL_TYP_OUT           : out std_logic_vector (2 downto 0);  -- Which kind of data word: DAT, HDR or TRM
      APL_DATAREADY_OUT     : out std_logic; -- Data word is valid and might be read out
      APL_READ_IN           : in  std_logic; -- Read data word
      
      -- APL Control port
      APL_RUN_OUT           : out std_logic; -- Data transfer is running
      APL_MY_ADDRESS_IN     : in  std_logic_vector (15 downto 0);  -- My own address (temporary solution!!!)
      APL_SEQNR_OUT         : out std_logic_vector (7 downto 0);
      
      -- Internal direction port
      -- the ports with master or slave in their name are to be mapped by the active api
      -- to the init respectivly the reply path and vice versa in the passive api.
      -- lets define: the "master" path is the path that I send data on.
      INT_MASTER_DATAREADY_OUT  : out std_logic;
      INT_MASTER_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      INT_MASTER_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_MASTER_READ_IN        : in  std_logic;
  
      INT_MASTER_DATAREADY_IN   : in  std_logic;
      INT_MASTER_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      INT_MASTER_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_MASTER_READ_OUT       : out std_logic;
  
  
      INT_SLAVE_HEADER_IN       : in  std_logic; -- Concentrator kindly asks to resend the last
                                        -- header (only for the reply path)
      INT_SLAVE_DATAREADY_OUT   : out std_logic;
      INT_SLAVE_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      INT_SLAVE_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_SLAVE_READ_IN         : in  std_logic;
  
      INT_SLAVE_DATAREADY_IN    : in  std_logic;
      INT_SLAVE_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      INT_SLAVE_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_SLAVE_READ_OUT        : out std_logic;
  
      -- Status and control port
      STAT_FIFO_TO_INT          : out std_logic_vector(31 downto 0);
      STAT_FIFO_TO_APL          : out std_logic_vector(31 downto 0)
      );
  end component;

begin

  BASE_API: trb_net16_api_base
    generic map (
      API_TYPE => 1,
      FIFO_TO_INT_DEPTH => FIFO_TO_INT_DEPTH,
      FIFO_TO_APL_DEPTH => FIFO_TO_APL_DEPTH,
      SBUF_VERSION      => SBUF_VERSION
      )
    port map (
      CLK => CLK,
      CLK_EN => CLK_EN,
      RESET => RESET,
      
      APL_DATA_IN => APL_DATA_IN,
      APL_PACKET_NUM_IN => APL_PACKET_NUM_IN,
      APL_WRITE_IN => APL_WRITE_IN,
      APL_FIFO_FULL_OUT => APL_FIFO_FULL_OUT,
      APL_SHORT_TRANSFER_IN => APL_SHORT_TRANSFER_IN,
      APL_DTYPE_IN => APL_DTYPE_IN,
      APL_ERROR_PATTERN_IN => APL_ERROR_PATTERN_IN,
      APL_SEND_IN => APL_SEND_IN,
      APL_TARGET_ADDRESS_IN => APL_TARGET_ADDRESS_IN,
      APL_DATA_OUT => APL_DATA_OUT,
      APL_PACKET_NUM_OUT => APL_PACKET_NUM_OUT,
      APL_TYP_OUT => APL_TYP_OUT,
      APL_DATAREADY_OUT => APL_DATAREADY_OUT,
      APL_READ_IN => APL_READ_IN,

      -- APL Control port
      APL_RUN_OUT => APL_RUN_OUT,
      APL_MY_ADDRESS_IN => APL_MY_ADDRESS_IN,
      APL_SEQNR_OUT => APL_SEQNR_OUT,

      -- Internal direction port
      INT_MASTER_DATAREADY_OUT => INT_INIT_DATAREADY_OUT,
      INT_MASTER_DATA_OUT => INT_INIT_DATA_OUT,
      INT_MASTER_PACKET_NUM_OUT => INT_INIT_PACKET_NUM_OUT,
      INT_MASTER_READ_IN => INT_INIT_READ_IN,

      INT_MASTER_DATAREADY_IN => INT_INIT_DATAREADY_IN,
      INT_MASTER_DATA_IN => INT_INIT_DATA_IN,
      INT_MASTER_PACKET_NUM_IN => INT_INIT_PACKET_NUM_IN,
      INT_MASTER_READ_OUT => INT_INIT_READ_OUT,

      INT_SLAVE_HEADER_IN => INT_REPLY_HEADER_IN,
      
      INT_SLAVE_DATAREADY_OUT => INT_REPLY_DATAREADY_OUT,
      INT_SLAVE_DATA_OUT => INT_REPLY_DATA_OUT,
		INT_SLAVE_PACKET_NUM_OUT => INT_REPLY_PACKET_NUM_OUT,
      INT_SLAVE_READ_IN => INT_REPLY_READ_IN,

      INT_SLAVE_DATAREADY_IN => INT_REPLY_DATAREADY_IN,
      INT_SLAVE_DATA_IN => INT_REPLY_DATA_IN,
		INT_SLAVE_PACKET_NUM_IN => INT_REPLY_PACKET_NUM_IN,
      INT_SLAVE_READ_OUT => INT_REPLY_READ_OUT,
      -- Status and control port
      STAT_FIFO_TO_INT => STAT_FIFO_TO_INT,
      STAT_FIFO_TO_APL => STAT_FIFO_TO_APL
      -- not needed now, but later
      );

end architecture;
