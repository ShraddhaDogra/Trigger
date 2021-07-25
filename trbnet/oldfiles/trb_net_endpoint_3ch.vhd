-- this is the final endpoint to be used
-- It has 3 channels

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.trb_net_std.all;

--Entity decalaration for clock generator
entity trb_net_endpoint_3ch is

  -- per channel we have the following generics:
  -- 1.) APIX_FIFO_TO_INT_DEPTH
  -- 2.) APIX_FIFO_TO_APL_DEPTH
  -- 3.) APIX_TYPE (0=active, 1=passive, 99=dummy)
  -- 4.) APIX_INIT_DEPTH
  -- 5.) APIX_REPLY_DEPTH
  -- 6.) APIX_CHANNEL_NUMBER

  -- The dummy APL can be used for debugging
  -- In this case, the API lines are use only for sniffing
  -- and the input lines can be driven to any value
  -- with one exeption:
  -- if APL_SEND_IN = '0' the dummy APL will be resetted
  
  generic (

    API1_FIFO_TO_INT_DEPTH: integer := 3;
    API1_FIFO_TO_APL_DEPTH: integer := 3;
    API1_TYPE             : integer := 0;
    API1_INIT_DEPTH       : integer := 3;
    API1_REPLY_DEPTH      : integer := 3;
    API1_CHANNEL_NUMBER   : integer := 0;

    API2_FIFO_TO_INT_DEPTH: integer := 3;
    API2_FIFO_TO_APL_DEPTH: integer := 3;
    API2_TYPE             : integer := 0;
    API2_INIT_DEPTH       : integer := 3;
    API2_REPLY_DEPTH      : integer := 3;
    API2_CHANNEL_NUMBER   : integer := 1;

    API3_FIFO_TO_INT_DEPTH: integer := 3;
    API3_FIFO_TO_APL_DEPTH: integer := 3;
    API3_TYPE             : integer := 0;
    API3_INIT_DEPTH       : integer := 3;
    API3_REPLY_DEPTH      : integer := 3;
    API3_CHANNEL_NUMBER   : integer := 2    
    
           );   

  port(
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;

    ----------------------------------------------------------------------------
    -- API1
    ---------------------------------------------------------------------------- 
    -- APL Transmitter port
    APL1_DATA_IN:       in  STD_LOGIC_VECTOR (47 downto 0); -- Data word "application to network"
    APL1_WRITE_IN:      in  STD_LOGIC; -- Data word is valid and should be transmitted
    APL1_FIFO_FULL_OUT: out STD_LOGIC; -- Stop transfer, the fifo is full
    APL1_SHORT_TRANSFER_IN: in  STD_LOGIC; -- 
    APL1_DTYPE_IN:      in  STD_LOGIC_VECTOR (3 downto 0);  -- see NewTriggerBusNetworkDescr
    APL1_ERROR_PATTERN_IN: in  STD_LOGIC_VECTOR (31 downto 0); -- see NewTriggerBusNetworkDescr
    APL1_SEND_IN:       in  STD_LOGIC; -- Release sending of the data
    APL1_TARGET_ADDRESS_IN: in  STD_LOGIC_VECTOR (15 downto 0); -- Address of
                                                               -- the target (only for active APIs)

    -- Receiver port
    APL1_DATA_OUT:      out STD_LOGIC_VECTOR (47 downto 0); -- Data word "network to application"
    APL1_TYP_OUT:       out STD_LOGIC_VECTOR (2 downto 0);  -- Which kind of data word: DAT, HDR or TRM
    APL1_DATAREADY_OUT: out STD_LOGIC; -- Data word is valid and might be read out
    APL1_READ_IN:       in  STD_LOGIC; -- Read data word
    
    -- APL Control port
    APL1_RUN_OUT:       out STD_LOGIC; -- Data transfer is running
    APL1_SEQNR_OUT:     out STD_LOGIC_VECTOR (7 downto 0);

    ----------------------------------------------------------------------------
    -- API2
    ---------------------------------------------------------------------------- 
    -- APL Transmitter port
    APL2_DATA_IN:       in  STD_LOGIC_VECTOR (47 downto 0); -- Data word "application to network"
    APL2_WRITE_IN:      in  STD_LOGIC; -- Data word is valid and should be transmitted
    APL2_FIFO_FULL_OUT: out STD_LOGIC; -- Stop transfer, the fifo is full
    APL2_SHORT_TRANSFER_IN: in  STD_LOGIC; -- 
    APL2_DTYPE_IN:      in  STD_LOGIC_VECTOR (3 downto 0);  -- see NewTriggerBusNetworkDescr
    APL2_ERROR_PATTERN_IN: in  STD_LOGIC_VECTOR (31 downto 0); -- see NewTriggerBusNetworkDescr
    APL2_SEND_IN:       in  STD_LOGIC; -- Release sending of the data
    APL2_TARGET_ADDRESS_IN: in  STD_LOGIC_VECTOR (15 downto 0); -- Address of
                                                               -- the target (only for active APIs)

    -- Receiver port
    APL2_DATA_OUT:      out STD_LOGIC_VECTOR (47 downto 0); -- Data word "network to application"
    APL2_TYP_OUT:       out STD_LOGIC_VECTOR (2 downto 0);  -- Which kind of data word: DAT, HDR or TRM
    APL2_DATAREADY_OUT: out STD_LOGIC; -- Data word is valid and might be read out
    APL2_READ_IN:       in  STD_LOGIC; -- Read data word
    
    -- APL Control port
    APL2_RUN_OUT:       out STD_LOGIC; -- Data transfer is running
    APL2_SEQNR_OUT:     out STD_LOGIC_VECTOR (7 downto 0);

    ----------------------------------------------------------------------------
    -- API3
    ---------------------------------------------------------------------------- 
    -- APL Transmitter port
    APL3_DATA_IN:       in  STD_LOGIC_VECTOR (47 downto 0); -- Data word "application to network"
    APL3_WRITE_IN:      in  STD_LOGIC; -- Data word is valid and should be transmitted
    APL3_FIFO_FULL_OUT: out STD_LOGIC; -- Stop transfer, the fifo is full
    APL3_SHORT_TRANSFER_IN: in  STD_LOGIC; -- 
    APL3_DTYPE_IN:      in  STD_LOGIC_VECTOR (3 downto 0);  -- see NewTriggerBusNetworkDescr
    APL3_ERROR_PATTERN_IN: in  STD_LOGIC_VECTOR (31 downto 0); -- see NewTriggerBusNetworkDescr
    APL3_SEND_IN:       in  STD_LOGIC; -- Release sending of the data
    APL3_TARGET_ADDRESS_IN: in  STD_LOGIC_VECTOR (15 downto 0); -- Address of
                                                               -- the target (only for active APIs)

    -- Receiver port
    APL3_DATA_OUT:      out STD_LOGIC_VECTOR (47 downto 0); -- Data word "network to application"
    APL3_TYP_OUT:       out STD_LOGIC_VECTOR (2 downto 0);  -- Which kind of data word: DAT, HDR or TRM
    APL3_DATAREADY_OUT: out STD_LOGIC; -- Data word is valid and might be read out
    APL3_READ_IN:       in  STD_LOGIC; -- Read data word
    
    -- APL Control port
    APL3_RUN_OUT:       out STD_LOGIC; -- Data transfer is running
    APL3_SEQNR_OUT:     out STD_LOGIC_VECTOR (7 downto 0);
    
    
    ----------------------------------------------------------------------------
    -- Common API stuff
    ----------------------------------------------------------------------------     
    APL_MY_ADDRESS_IN: in  STD_LOGIC_VECTOR (15 downto 0);  -- My own address (temporary solution!!!)
    APL_MPLEX_CTRL: in  STD_LOGIC_VECTOR (31 downto 0);

    -- IOBUF ports missing -> Later (BUGBUG)

    APL_GOT_TRM : out STD_LOGIC_VECTOR (15 downto 0);  --pattern from the
                                                       --unused TERMs
    APL_HOLD_TRM: in  STD_LOGIC_VECTOR (15 downto 0);  --put to "0"
    
    ---------------------------------------------------------------------------
    -- Media direction port (directly to be connected to MII)
    ---------------------------------------------------------------------------  
    MED_DATAREADY_OUT: out STD_LOGIC;  --Data word ready to be read out
                                       --by the media (via the TrbNetIOMultiplexer)
    MED_DATA_OUT:      out STD_LOGIC_VECTOR (55 downto 0); -- Data word
    MED_READ_IN:       in  STD_LOGIC; -- Media is reading
    
    MED_DATAREADY_IN:  in  STD_LOGIC; -- Data word is offered by the Media
                                 -- (the IOBUF MUST read)
    MED_DATA_IN:       in  STD_LOGIC_VECTOR (55 downto 0); -- Data word
    MED_READ_OUT:      out STD_LOGIC; -- buffer reads a word from media
    MED_ERROR_IN:      in  STD_LOGIC_VECTOR (2 downto 0);  -- Status bits

    MED_MPLEX_CTRL: in  STD_LOGIC_VECTOR (31 downto 0)
    );
END trb_net_endpoint_3ch;

architecture trb_net_endpoint_3ch_arch of trb_net_endpoint_3ch is

  component trb_net_io_multiplexer is

  generic (BUS_WIDTH : integer := 56;
           MULT_WIDTH : integer := 5);

  port(
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;
    --  Media direction port
    MED_DATAREADY_IN:  in  STD_LOGIC; 
    MED_DATA_IN:       in  STD_LOGIC_VECTOR (BUS_WIDTH-1 downto 0);
                       -- highest bits are mult.
    MED_READ_OUT:      out STD_LOGIC;
    
    MED_DATAREADY_OUT: out  STD_LOGIC; 
    MED_DATA_OUT:      out  STD_LOGIC_VECTOR (BUS_WIDTH-1 downto 0);  
    MED_READ_IN:       in STD_LOGIC;
    
    -- Internal direction port
    INT_DATAREADY_OUT: out STD_LOGIC_VECTOR (2**MULT_WIDTH-1 downto 0);
    INT_DATA_OUT:      out STD_LOGIC_VECTOR ((BUS_WIDTH-MULT_WIDTH)*(2**MULT_WIDTH)-1 downto 0);  
    INT_READ_IN:       in  STD_LOGIC_VECTOR (2**MULT_WIDTH-1 downto 0);

    INT_DATAREADY_IN:  in STD_LOGIC_VECTOR (2**MULT_WIDTH-1 downto 0);
    INT_DATA_IN:       in STD_LOGIC_VECTOR ((BUS_WIDTH-MULT_WIDTH)*(2**MULT_WIDTH)-1 downto 0);  
    INT_READ_OUT:      out  STD_LOGIC_VECTOR (2**MULT_WIDTH-1 downto 0);
    
    -- Status and control port
    CTRL:              in  STD_LOGIC_VECTOR (31 downto 0);
    STAT:              out STD_LOGIC_VECTOR (31 downto 0)
    );
END component;

component trb_net_active_apimbuf is

  generic (INIT_DEPTH : integer := 3;     -- Depth of the FIFO, 2^(n+1), if
                                          -- the initibuf
           REPLY_DEPTH : integer := 3;    -- or the replyibuf
           FIFO_TO_INT_DEPTH : integer := 3;     -- Depth of the FIFO, 2^(n+1),
                                                 -- for the direction to
                                                 -- internal world
           FIFO_TO_APL_DEPTH : integer := 3;     -- direction to application
           FIFO_TERM_BUFFER_DEPTH  : integer := 0  -- fifo for auto-answering of
                                               -- the master path, if set to 0
                                               -- no buffer is used at all
           );   

  port(
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;
    --  Media direction port
    MED_DATAREADY_OUT: out STD_LOGIC;  --Data word ready to be read out
                                       --by the media (via the TrbNetIOMultiplexer)
    MED_DATA_OUT:      out STD_LOGIC_VECTOR (51 downto 0); -- Data word
    MED_READ_IN:       in  STD_LOGIC; -- Media is reading
    
    MED_DATAREADY_IN:  in  STD_LOGIC; -- Data word is offered by the Media
                                 -- (the IOBUF MUST read)
    MED_DATA_IN:       in  STD_LOGIC_VECTOR (51 downto 0); -- Data word
    MED_READ_OUT:      out STD_LOGIC; -- buffer reads a word from media
    MED_ERROR_IN:      in  STD_LOGIC_VECTOR (2 downto 0);  -- Status bits

    
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
    
    -- Status and control port => just coming from the iobuf for debugging
    STAT_GEN:          out STD_LOGIC_VECTOR (31 downto 0); -- General Status
    STAT_LOCKED:       out STD_LOGIC_VECTOR (31 downto 0); -- Status of the handshake and buffer control
    STAT_INIT_BUFFER:  out STD_LOGIC_VECTOR (31 downto 0); -- Status of the handshake and buffer control
    STAT_REPLY_BUFFER: out STD_LOGIC_VECTOR (31 downto 0); -- General Status
    CTRL_GEN:          in  STD_LOGIC_VECTOR (31 downto 0); 
    CTRL_LOCKED:       in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_INIT_BUFFER:  in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_REPLY_BUFFER: in  STD_LOGIC_VECTOR (31 downto 0);
    MPLEX_CTRL: in  STD_LOGIC_VECTOR (31 downto 0)
    );
END component;

component trb_net_term_mbuf is

  generic (FIFO_TERM_BUFFER_DEPTH  : integer := 0  -- fifo for auto-answering of
                                               -- the master path, if set to 0
                                               -- no buffer is used at all
           );   

  port(
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;
    --  Media direction port
    MED_DATAREADY_OUT: out STD_LOGIC;  --Data word ready to be read out
                                       --by the media (via the TrbNetIOMultiplexer)
    MED_DATA_OUT:      out STD_LOGIC_VECTOR (51 downto 0); -- Data word
    MED_READ_IN:       in  STD_LOGIC; -- Media is reading
    
    MED_DATAREADY_IN:  in  STD_LOGIC; -- Data word is offered by the Media
                                 -- (the IOBUF MUST read)
    MED_DATA_IN:       in  STD_LOGIC_VECTOR (51 downto 0); -- Data word
    MED_READ_OUT:      out STD_LOGIC; -- buffer reads a word from media
    MED_ERROR_IN:      in  STD_LOGIC_VECTOR (2 downto 0);  -- Status bits

    -- "mini" APL, just to see the triggers coming in
    APL_DTYPE_OUT:         out STD_LOGIC_VECTOR (3 downto 0);  -- see NewTriggerBusNetworkDescr
    APL_ERROR_PATTERN_OUT: out STD_LOGIC_VECTOR (31 downto 0); -- see NewTriggerBusNetworkDescr
    APL_SEQNR_OUT:         out STD_LOGIC_VECTOR (7 downto 0);
    APL_GOT_TRM:           out STD_LOGIC;

    APL_HOLD_TRM:          in STD_LOGIC;
    APL_DTYPE_IN:          in STD_LOGIC_VECTOR (3 downto 0);  -- see NewTriggerBusNetworkDescr
    APL_ERROR_PATTERN_IN:  in STD_LOGIC_VECTOR (31 downto 0); -- see NewTriggerBusNetworkDescr

    -- Status and control port => just coming from the iobuf for debugging
    STAT_GEN:          out STD_LOGIC_VECTOR (31 downto 0); -- General Status
    STAT_LOCKED:       out STD_LOGIC_VECTOR (31 downto 0); -- Status of the handshake and buffer control
    STAT_INIT_BUFFER:  out STD_LOGIC_VECTOR (31 downto 0); -- Status of the handshake and buffer control
    STAT_REPLY_BUFFER: out STD_LOGIC_VECTOR (31 downto 0); -- General Status
    CTRL_GEN:          in  STD_LOGIC_VECTOR (31 downto 0); 
    CTRL_LOCKED:       in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_INIT_BUFFER:  in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_REPLY_BUFFER: in  STD_LOGIC_VECTOR (31 downto 0);
    MPLEX_CTRL: in  STD_LOGIC_VECTOR (31 downto 0)
    );
END component;

-- for the connection to the multiplexer
signal MED_INIT_DATAREADY_OUT : STD_LOGIC;
signal MED_INIT_DATA_OUT    : STD_LOGIC_VECTOR (50 downto 0);
signal MED_INIT_READ_IN     : STD_LOGIC;

signal MED_INIT_DATAREADY_IN : STD_LOGIC;                                   
signal MED_INIT_DATA_IN        : STD_LOGIC_VECTOR (50 downto 0);
signal MED_INIT_READ_OUT     : STD_LOGIC;  

signal MED_REPLY_DATAREADY_OUT    : STD_LOGIC;                               
signal MED_REPLY_DATA_OUT      : STD_LOGIC_VECTOR (50 downto 0);
signal MED_REPLY_READ_IN       : STD_LOGIC;

signal MED_REPLY_DATAREADY_IN   : STD_LOGIC;                              
signal MED_REPLY_DATA_IN       : STD_LOGIC_VECTOR (50 downto 0);
signal MED_REPLY_READ_OUT   : STD_LOGIC;   

signal m_DATAREADY_OUT : STD_LOGIC_VECTOR (15 downto 0);
signal m_DATA_OUT      : STD_LOGIC_VECTOR (831 downto 0);
signal m_READ_IN       : STD_LOGIC_VECTOR (15 downto 0);

signal m_DATAREADY_IN  : STD_LOGIC_VECTOR (15 downto 0);
signal m_DATA_IN       : STD_LOGIC_VECTOR (831 downto 0);
signal m_READ_OUT      : STD_LOGIC_VECTOR (15 downto 0);

begin

  
--   m_DATAREADY_OUT(0) <= MED_INIT_DATAREADY_OUT;
--   m_DATAREADY_OUT(1) <= MED_REPLY_DATAREADY_OUT;
--   m_DATA_OUT(50 downto 0) <= MED_INIT_DATA_OUT;
--   m_DATA_OUT(101 downto 51) <= MED_REPLY_DATA_OUT;
--   MED_INIT_READ_IN <= m_READ_IN(0);
--   MED_REPLY_READ_IN <= m_READ_IN(1);

--   MED_INIT_DATAREADY_IN <= m_DATAREADY_IN(0);
--   MED_REPLY_DATAREADY_IN <= m_DATAREADY_IN(1);
--   MED_INIT_DATA_IN <= m_DATA_IN(50 downto 0);
--   MED_REPLY_DATA_IN <= m_DATA_IN(101 downto 51);
--   m_READ_OUT(0) <= MED_INIT_READ_OUT;
--   m_READ_OUT(1) <= MED_REPLY_READ_OUT;

  G1: for channel in  0 to 15 generate
-------------------------------------------------------------------------------
-- loop over the channels
-------------------------------------------------------------------------------
    GEN_API1: if not (channel = API1_CHANNEL_NUMBER)
                and not (channel = API2_CHANNEL_NUMBER)
                and not (channel = API3_CHANNEL_NUMBER)
    generate
      -- make the term
      TERM: trb_net_term_mbuf

        generic map (FIFO_TERM_BUFFER_DEPTH =>  0 )   
        port map (
          --  Misc
          CLK    =>   CLK,
          RESET    => RESET ,
          CLK_EN   => CLK_EN,
          --  Media direction port
          MED_DATAREADY_OUT => m_DATAREADY_OUT(channel),
          MED_DATA_OUT      => m_DATA_OUT(channel*52+51 downto channel*52),
          MED_READ_IN       => m_READ_IN(channel),
    
          MED_DATAREADY_IN => m_DATAREADY_IN(channel),
          MED_DATA_IN      => m_DATA_IN(channel*52+51 downto channel*52),
          MED_READ_OUT     => m_READ_OUT(channel),
          MED_ERROR_IN     => (others => '0'),
    
          APL_GOT_TRM      => APL_GOT_TRM(channel),

          APL_HOLD_TRM     => APL_HOLD_TRM(channel),
          APL_DTYPE_IN     => (others => '0'),
          APL_ERROR_PATTERN_IN => (others => '0'),

          CTRL_GEN              => (others => '0'),
          CTRL_LOCKED           => (others => '0'),
          STAT_CTRL_INIT_BUFFER => (others => '0'),
          STAT_CTRL_REPLY_BUFFER=> (others => '0'),
          
          MPLEX_CTRL            => APL_MPLEX_CTRL );
    end generate;
  end generate;

  MPLEX: trb_net_io_multiplexer
    generic map (BUS_WIDTH =>  56,
                 MULT_WIDTH =>  4)
    port map (
    CLK    =>   CLK,
    RESET    => RESET ,
    CLK_EN   => CLK_EN,

    MED_DATAREADY_IN  => MED_DATAREADY_IN,
    MED_DATA_IN  => MED_DATA_IN,
    MED_READ_OUT  => MED_READ_OUT,
    
    MED_DATAREADY_OUT => MED_DATAREADY_OUT,
    MED_DATA_OUT => MED_DATA_OUT,
    MED_READ_IN => MED_READ_IN,
    
    INT_DATAREADY_OUT => m_DATAREADY_IN,
    INT_DATA_OUT =>m_DATA_IN,
    INT_READ_IN =>m_READ_OUT,

    INT_DATAREADY_IN =>m_DATAREADY_OUT,
    INT_DATA_IN =>m_DATA_OUT,
    INT_READ_OUT =>m_READ_IN,
    
    CTRL => MED_MPLEX_CTRL
    );

API1: trb_net_active_apimbuf 

  generic map (INIT_DEPTH             => API1_INIT_DEPTH,
               REPLY_DEPTH            => API1_REPLY_DEPTH,
               FIFO_TO_INT_DEPTH      => API1_FIFO_TO_INT_DEPTH,
               FIFO_TO_APL_DEPTH      => API1_FIFO_TO_APL_DEPTH,
               FIFO_TERM_BUFFER_DEPTH => 0
           )
 
  port map(
    --  Misc
    CLK    => CLK,
    RESET  => RESET,
    CLK_EN => CLK_EN,
    --  Media direction port
    MED_DATAREADY_OUT => m_DATAREADY_OUT(API1_CHANNEL_NUMBER),
    MED_DATA_OUT      => m_DATA_OUT(API1_CHANNEL_NUMBER*52+51 downto API1_CHANNEL_NUMBER*52),
    MED_READ_IN       => m_READ_IN(API1_CHANNEL_NUMBER),
    
    MED_DATAREADY_IN => m_DATAREADY_IN(API1_CHANNEL_NUMBER),
    MED_DATA_IN      => m_DATA_IN(API1_CHANNEL_NUMBER*52+51 downto API1_CHANNEL_NUMBER*52),
    MED_READ_OUT     => m_READ_OUT(API1_CHANNEL_NUMBER),
    MED_ERROR_IN     => (others => '0'),
    
    -- APL Transmitter port
    APL_DATA_IN           => APL1_DATA_IN,
    APL_WRITE_IN          => APL1_WRITE_IN,
    APL_FIFO_FULL_OUT     => APL1_FIFO_FULL_OUT,
    APL_SHORT_TRANSFER_IN => APL1_SHORT_TRANSFER_IN,
    APL_DTYPE_IN          => APL1_DTYPE_IN,
    APL_ERROR_PATTERN_IN  => APL1_ERROR_PATTERN_IN,
    APL_SEND_IN           => APL1_SEND_IN,
    APL_TARGET_ADDRESS_IN => APL1_TARGET_ADDRESS_IN,

    -- Receiver port
    APL_DATA_OUT      => APL1_DATA_OUT,
    APL_TYP_OUT       => APL1_TYP_OUT,
    APL_DATAREADY_OUT => APL1_DATAREADY_OUT,
    APL_READ_IN       => APL1_READ_IN,
    
    -- APL Control port
    APL_RUN_OUT       => APL1_RUN_OUT,
    APL_MY_ADDRESS_IN => APL_MY_ADDRESS_IN,
    APL_SEQNR_OUT     => APL1_SEQNR_OUT,
    
    CTRL_GEN              => (others => '0'),
    CTRL_LOCKED           => (others => '0'),
    STAT_CTRL_INIT_BUFFER => (others => '0'),
    STAT_CTRL_REPLY_BUFFER=> (others => '0'),
    MPLEX_CTRL            => APL_MPLEX_CTRL
    );

API2: trb_net_active_apimbuf 

  generic map (INIT_DEPTH             => API2_INIT_DEPTH,
               REPLY_DEPTH            => API2_REPLY_DEPTH,
               FIFO_TO_INT_DEPTH      => API2_FIFO_TO_INT_DEPTH,
               FIFO_TO_APL_DEPTH      => API2_FIFO_TO_APL_DEPTH,
               FIFO_TERM_BUFFER_DEPTH => 0
           )
 
  port map(
    --  Misc
    CLK    => CLK,
    RESET  => RESET,
    CLK_EN => CLK_EN,
    --  Media direction port
    MED_DATAREADY_OUT => m_DATAREADY_OUT(API2_CHANNEL_NUMBER),
    MED_DATA_OUT      => m_DATA_OUT(API2_CHANNEL_NUMBER*52+51 downto API2_CHANNEL_NUMBER*52),
    MED_READ_IN       => m_READ_IN(API2_CHANNEL_NUMBER),
    
    MED_DATAREADY_IN => m_DATAREADY_IN(API2_CHANNEL_NUMBER),
    MED_DATA_IN      => m_DATA_IN(API2_CHANNEL_NUMBER*52+51 downto API2_CHANNEL_NUMBER*52),
    MED_READ_OUT     => m_READ_OUT(API2_CHANNEL_NUMBER),
    MED_ERROR_IN     => (others => '0'),
    
    -- APL Transmitter port
    APL_DATA_IN           => APL2_DATA_IN,
    APL_WRITE_IN          => APL2_WRITE_IN,
    APL_FIFO_FULL_OUT     => APL2_FIFO_FULL_OUT,
    APL_SHORT_TRANSFER_IN => APL2_SHORT_TRANSFER_IN,
    APL_DTYPE_IN          => APL2_DTYPE_IN,
    APL_ERROR_PATTERN_IN  => APL2_ERROR_PATTERN_IN,
    APL_SEND_IN           => APL2_SEND_IN,
    APL_TARGET_ADDRESS_IN => APL2_TARGET_ADDRESS_IN,

    -- Receiver port
    APL_DATA_OUT      => APL2_DATA_OUT,
    APL_TYP_OUT       => APL2_TYP_OUT,
    APL_DATAREADY_OUT => APL2_DATAREADY_OUT,
    APL_READ_IN       => APL2_READ_IN,
    
    -- APL Control port
    APL_RUN_OUT       => APL2_RUN_OUT,
    APL_MY_ADDRESS_IN => APL_MY_ADDRESS_IN,
    APL_SEQNR_OUT     => APL2_SEQNR_OUT,
    
    CTRL_GEN              => (others => '0'),
    CTRL_LOCKED           => (others => '0'),
    STAT_CTRL_INIT_BUFFER => (others => '0'),
    STAT_CTRL_REPLY_BUFFER=> (others => '0'),
    MPLEX_CTRL            => APL_MPLEX_CTRL
    );

API3: trb_net_active_apimbuf 

  generic map (INIT_DEPTH             => API3_INIT_DEPTH,
               REPLY_DEPTH            => API3_REPLY_DEPTH,
               FIFO_TO_INT_DEPTH      => API3_FIFO_TO_INT_DEPTH,
               FIFO_TO_APL_DEPTH      => API3_FIFO_TO_APL_DEPTH,
               FIFO_TERM_BUFFER_DEPTH => 0
           )
 
  port map(
    --  Misc
    CLK    => CLK,
    RESET  => RESET,
    CLK_EN => CLK_EN,
    --  Media direction port
    MED_DATAREADY_OUT => m_DATAREADY_OUT(API3_CHANNEL_NUMBER),
    MED_DATA_OUT      => m_DATA_OUT(API3_CHANNEL_NUMBER*52+51 downto API3_CHANNEL_NUMBER*52),
    MED_READ_IN       => m_READ_IN(API3_CHANNEL_NUMBER),
    
    MED_DATAREADY_IN => m_DATAREADY_IN(API3_CHANNEL_NUMBER),
    MED_DATA_IN      => m_DATA_IN(API3_CHANNEL_NUMBER*52+51 downto API3_CHANNEL_NUMBER*52),
    MED_READ_OUT     => m_READ_OUT(API3_CHANNEL_NUMBER),
    MED_ERROR_IN     => (others => '0'),
    
    -- APL Transmitter port
    APL_DATA_IN           => APL3_DATA_IN,
    APL_WRITE_IN          => APL3_WRITE_IN,
    APL_FIFO_FULL_OUT     => APL3_FIFO_FULL_OUT,
    APL_SHORT_TRANSFER_IN => APL3_SHORT_TRANSFER_IN,
    APL_DTYPE_IN          => APL3_DTYPE_IN,
    APL_ERROR_PATTERN_IN  => APL3_ERROR_PATTERN_IN,
    APL_SEND_IN           => APL3_SEND_IN,
    APL_TARGET_ADDRESS_IN => APL3_TARGET_ADDRESS_IN,

    -- Receiver port
    APL_DATA_OUT      => APL3_DATA_OUT,
    APL_TYP_OUT       => APL3_TYP_OUT,
    APL_DATAREADY_OUT => APL3_DATAREADY_OUT,
    APL_READ_IN       => APL3_READ_IN,
    
    -- APL Control port
    APL_RUN_OUT       => APL3_RUN_OUT,
    APL_MY_ADDRESS_IN => APL_MY_ADDRESS_IN,
    APL_SEQNR_OUT     => APL3_SEQNR_OUT,
    
    CTRL_GEN              => (others => '0'),
    CTRL_LOCKED           => (others => '0'),
    STAT_CTRL_INIT_BUFFER => (others => '0'),
    STAT_CTRL_REPLY_BUFFER=> (others => '0'),
    MPLEX_CTRL            => APL_MPLEX_CTRL
    );

  
end trb_net_endpoint_3ch_arch;
  
