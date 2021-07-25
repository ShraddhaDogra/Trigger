-- connection between the TRBNET and any application
-- for a description see HADES wiki
-- http://hades-wiki.gsi.de/cgi-bin/view/DaqSlowControl/TrbNetAPI

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.trb_net_std.all;


entity trb_net_active_api is

  generic (FIFO_TO_INT_DEPTH : integer := 0;     -- Depth of the FIFO, 2^(n+1),
                                                 -- for the direction to
                                                 -- internal world
           FIFO_TO_APL_DEPTH : integer := 0;     -- direction to application
           FIFO_TERM_BUFFER_DEPTH  : integer := 0);  -- fifo for auto-answering of
                                               -- the master path, if set to 0
                                               -- no buffer is used at all

  
  port(
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;

    -- APL Transmitter port
    APL_DATA_IN:       in  STD_LOGIC_VECTOR (47 downto 0); -- Data word "application to network"
    APL_WRITE_IN:      in  STD_LOGIC; -- Data word is valid and should be transmitted
    APL_FIFO_FULL_OUT: out STD_LOGIC; -- Stop transfer, the fifo is full
    APL_SHORT_TRANSFER_IN: in  STD_LOGIC; -- 
    APL_DTYPE_IN:      in  STD_LOGIC_VECTOR (3 downto 0);  -- see NewTriggerBusNetworkDescr
    APL_ERROR_PATTERN_IN: in  STD_LOGIC_VECTOR (31 downto 0); -- see NewTriggerBusNetworkDescr
    APL_SEND_IN:       in  STD_LOGIC; -- Release sending of the data
    APL_TARGET_ADDRESS_IN: in  STD_LOGIC_VECTOR (15 downto 0); -- Address of
                                                               -- the target (only for active APIs)

    -- Receiver port
    APL_DATA_OUT:      out STD_LOGIC_VECTOR (47 downto 0); -- Data word "network to application"
    APL_TYP_OUT:       out STD_LOGIC_VECTOR (2 downto 0);  -- Which kind of data word: DAT, HDR or TRM
    APL_DATAREADY_OUT: out STD_LOGIC; -- Data word is valid and might be read out
    APL_READ_IN:       in  STD_LOGIC; -- Read data word
    
    -- APL Control port
    APL_RUN_OUT:       out STD_LOGIC; -- Data transfer is running
    APL_MY_ADDRESS_IN: in  STD_LOGIC_VECTOR (15 downto 0);  -- My own address (temporary solution!!!)
    APL_SEQNR_OUT:     out STD_LOGIC_VECTOR (7 downto 0);
    
    -- Internal direction port
    -- This is just a clone from trb_net_iobuf 
    
    INT_INIT_DATAREADY_OUT: out STD_LOGIC;
    INT_INIT_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_INIT_READ_IN:       in  STD_LOGIC; 

    INT_INIT_DATAREADY_IN:  in  STD_LOGIC;
    INT_INIT_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_INIT_READ_OUT:      out STD_LOGIC; 

    
    INT_REPLY_HEADER_IN:     in  STD_LOGIC; -- Concentrator kindly asks to resend the last
                                      -- header (only for the reply path)
    INT_REPLY_DATAREADY_OUT: out STD_LOGIC;
    INT_REPLY_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_REPLY_READ_IN:       in  STD_LOGIC; 

    INT_REPLY_DATAREADY_IN:  in  STD_LOGIC;
    INT_REPLY_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_REPLY_READ_OUT:      out STD_LOGIC;

    -- Status and control port
    STAT_FIFO_TO_INT: out std_logic_vector(31 downto 0);
    STAT_FIFO_TO_APL: out std_logic_vector(31 downto 0)
    -- not needed now, but later
    );
end trb_net_active_api;

architecture trb_net_active_api_arch of trb_net_active_api is

  component trb_net_base_api is
    generic (API_TYPE : integer := 0;              -- type of api: 0 passive, 1 active
            FIFO_TO_INT_DEPTH : integer := 0;     -- Depth of the FIFO, 2^(n+1),
                                                  -- for the direction to
                                                  -- internal world
            FIFO_TO_APL_DEPTH : integer := 0;     -- direction to application
            FIFO_TERM_BUFFER_DEPTH  : integer := 0);  -- fifo for auto-answering of
                                                -- the master path, if set to 0
                                                -- no buffer is used at all
    port(
      --  Misc
      CLK    : in std_logic;              
      RESET  : in std_logic;      
      CLK_EN : in std_logic;

      -- APL Transmitter port
      APL_DATA_IN:       in  STD_LOGIC_VECTOR (47 downto 0); -- Data word "application to network"
      APL_WRITE_IN:      in  STD_LOGIC; -- Data word is valid and should be transmitted
      APL_FIFO_FULL_OUT: out STD_LOGIC; -- Stop transfer, the fifo is full
      APL_SHORT_TRANSFER_IN: in  STD_LOGIC; -- 
      APL_DTYPE_IN:      in  STD_LOGIC_VECTOR (3 downto 0);  -- see NewTriggerBusNetworkDescr
      APL_ERROR_PATTERN_IN: in  STD_LOGIC_VECTOR (31 downto 0); -- see NewTriggerBusNetworkDescr
      APL_SEND_IN:       in  STD_LOGIC; -- Release sending of the data
      APL_TARGET_ADDRESS_IN: in  STD_LOGIC_VECTOR (15 downto 0); -- Address of
                                                                -- the target (only for active APIs)

      -- Receiver port
      APL_DATA_OUT:      out STD_LOGIC_VECTOR (47 downto 0); -- Data word "network to application"
      APL_TYP_OUT:       out STD_LOGIC_VECTOR (2 downto 0);  -- Which kind of data word: DAT, HDR or TRM
      APL_DATAREADY_OUT: out STD_LOGIC; -- Data word is valid and might be read out
      APL_READ_IN:       in  STD_LOGIC; -- Read data word

      -- APL Control port
      APL_RUN_OUT:       out STD_LOGIC; -- Data transfer is running
      APL_MY_ADDRESS_IN: in  STD_LOGIC_VECTOR (15 downto 0);  -- My own address (temporary solution!!!)
      APL_SEQNR_OUT:     out STD_LOGIC_VECTOR (7 downto 0);

      -- Internal direction port
      -- the ports with active or passive in their name are to be mapped by the active api
      -- to the init respectivly the reply path and vice versa in the passive api.
      INT_MASTER_DATAREADY_OUT: out STD_LOGIC;
      INT_MASTER_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
      INT_MASTER_READ_IN:       in  STD_LOGIC; 

      INT_MASTER_DATAREADY_IN:  in  STD_LOGIC;
      INT_MASTER_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
      INT_MASTER_READ_OUT:      out STD_LOGIC; 

      INT_SLAVE_HEADER_IN:     in  STD_LOGIC; -- Concentrator kindly asks to resend the last
                                        -- header (only for the reply path)
      INT_SLAVE_DATAREADY_OUT: out STD_LOGIC;
      INT_SLAVE_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
      INT_SLAVE_READ_IN:       in  STD_LOGIC; 

      INT_SLAVE_DATAREADY_IN:  in  STD_LOGIC;
      INT_SLAVE_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
      INT_SLAVE_READ_OUT:      out STD_LOGIC;
      -- Status and control port
      STAT_FIFO_TO_INT: out std_logic_vector(31 downto 0);
      STAT_FIFO_TO_APL: out std_logic_vector(31 downto 0)
      -- not needed now, but later
      );
  end component;

begin

  ACTIVE_API: trb_net_base_api
    generic map (
      API_TYPE => 1,
      FIFO_TO_INT_DEPTH => FIFO_TO_INT_DEPTH,
      FIFO_TO_APL_DEPTH => FIFO_TO_APL_DEPTH,
      FIFO_TERM_BUFFER_DEPTH  => FIFO_TERM_BUFFER_DEPTH
      )
    port map (
      CLK => CLK,
      CLK_EN => CLK_EN,
      RESET => RESET,
      
      APL_DATA_IN => APL_DATA_IN,
      APL_WRITE_IN => APL_WRITE_IN,
      APL_FIFO_FULL_OUT => APL_FIFO_FULL_OUT,
      APL_SHORT_TRANSFER_IN => APL_SHORT_TRANSFER_IN,
      APL_DTYPE_IN => APL_DTYPE_IN,
      APL_ERROR_PATTERN_IN => APL_ERROR_PATTERN_IN,
      APL_SEND_IN => APL_SEND_IN,
      APL_TARGET_ADDRESS_IN => APL_TARGET_ADDRESS_IN,
      APL_DATA_OUT => APL_DATA_OUT,
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
      INT_MASTER_READ_IN => INT_INIT_READ_IN,

      INT_MASTER_DATAREADY_IN => INT_INIT_DATAREADY_IN,
      INT_MASTER_DATA_IN => INT_INIT_DATA_IN,
      INT_MASTER_READ_OUT => INT_INIT_READ_OUT,

      INT_SLAVE_HEADER_IN => INT_REPLY_HEADER_IN,
      
      INT_SLAVE_DATAREADY_OUT => INT_REPLY_DATAREADY_OUT,
      INT_SLAVE_DATA_OUT => INT_REPLY_DATA_OUT,
      INT_SLAVE_READ_IN => INT_REPLY_READ_IN,

      INT_SLAVE_DATAREADY_IN => INT_REPLY_DATAREADY_IN,
      INT_SLAVE_DATA_IN => INT_REPLY_DATA_IN,
      INT_SLAVE_READ_OUT => INT_REPLY_READ_OUT,
      -- Status and control port
      STAT_FIFO_TO_INT => STAT_FIFO_TO_INT,
      STAT_FIFO_TO_APL => STAT_FIFO_TO_APL
      -- not needed now, but later
      );

end trb_net_active_api_arch;
