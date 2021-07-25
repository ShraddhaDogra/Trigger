-- an active api together with an iobuf

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.trb_net_std.all;

--Entity decalaration for clock generator
entity trb_net_passive_apimbuf is

  generic (INIT_DEPTH : integer := 3;     -- Depth of the FIFO, 2^(n+1), if
                                          -- the initibuf
           REPLY_DEPTH : integer := 3;    -- or the replyibuf
           FIFO_TO_INT_DEPTH : integer := 3;     -- Depth of the FIFO, 2^(n+1),
                                                 -- for the direction to
                                                 -- internal world
           FIFO_TO_APL_DEPTH : integer := 3;     -- direction to application
           FIFO_TERM_BUFFER_DEPTH  : integer := 1  -- fifo for auto-answering of
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
    APL_Send_IN:       in  STD_LOGIC; -- Release sending of the data
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
    STAT_api_control_signals: out std_logic_vector(31 downto 0); 
    STAT_MPLEX:        out STD_LOGIC_VECTOR(31 downto 0);
    CTRL_GEN:          in  STD_LOGIC_VECTOR (31 downto 0); 
    CTRL_LOCKED:       in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_INIT_BUFFER:  in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_REPLY_BUFFER: in  STD_LOGIC_VECTOR (31 downto 0);
    MPLEX_CTRL: in  STD_LOGIC_VECTOR (31 downto 0);
    API_STAT_FIFO_TO_INT: out std_logic_vector(31 downto 0);
    API_STAT_FIFO_TO_APL: out std_logic_vector(31 downto 0)
    );
end trb_net_passive_apimbuf;

architecture trb_net_passive_apimbuf_arch of trb_net_passive_apimbuf is

component trb_net_iobuf is

  generic (SWITCH_OFF_BUFFER_CHECK : integer := 0;
                      --switching off erroneous output buffer counter. MUST ONLY be 
                      --used for short transfers!!!!
           INIT_DEPTH : integer := 3;     -- Depth of the FIFO, 2^(n+1), if
                                          -- the initibuf
           REPLY_DEPTH : integer := 3);   -- or the replyibuf

  port(
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;
    --  Media direction port
    MED_INIT_DATAREADY_OUT: out STD_LOGIC;  --Data word ready to be read out
                                       --by the media (via the TrbNetIOMultiplexer)
    MED_INIT_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
    MED_INIT_READ_IN:       in  STD_LOGIC; -- Media is reading
    
    MED_INIT_DATAREADY_IN:  in  STD_LOGIC; -- Data word is offered by the Media
                                      -- (the IOBUF MUST read)
    MED_INIT_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
    MED_INIT_READ_OUT:      out STD_LOGIC; -- buffer reads a word from media
    MED_INIT_ERROR_IN:      in  STD_LOGIC_VECTOR (2 downto 0);  -- Status bits

    MED_REPLY_DATAREADY_OUT: out STD_LOGIC;  --Data word ready to be read out
                                       --by the media (via the TrbNetIOMultiplexer)
    MED_REPLY_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
    MED_REPLY_READ_IN:       in  STD_LOGIC; -- Media is reading
    
    MED_REPLY_DATAREADY_IN:  in  STD_LOGIC; -- Data word is offered by the Media
                                      -- (the IOBUF MUST read)
    MED_REPLY_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
    MED_REPLY_READ_OUT:      out STD_LOGIC; -- buffer reads a word from media
    MED_REPLY_ERROR_IN:      in  STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    
    -- Internal direction port

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
    STAT_GEN:          out STD_LOGIC_VECTOR (31 downto 0); -- General Status
    STAT_LOCKED:       out STD_LOGIC_VECTOR (31 downto 0); -- Status of the handshake and buffer control
    STAT_INIT_BUFFER:  out STD_LOGIC_VECTOR (31 downto 0); -- Status of the handshake and buffer control
    STAT_REPLY_BUFFER: out STD_LOGIC_VECTOR (31 downto 0); -- General Status
    CTRL_GEN:          in  STD_LOGIC_VECTOR (31 downto 0); 
    CTRL_LOCKED:       in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_INIT_BUFFER:  in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_REPLY_BUFFER: in  STD_LOGIC_VECTOR (31 downto 0)  
    );
end component;

component trb_net_passive_api is

  generic (FIFO_TO_INT_DEPTH : integer := 3;     -- Depth of the FIFO, 2^(n+1),
                                                 -- for the direction to
                                                 -- internal world
           FIFO_TO_APL_DEPTH : integer := 3;     -- direction to application
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
    APL_Send_IN:       in  STD_LOGIC; -- Release sending of the data
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
    );
end component;

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
end component;

signal apl_to_buf_INIT_DATAREADY: STD_LOGIC;
signal apl_to_buf_INIT_DATA     : STD_LOGIC_VECTOR (50 downto 0);
signal apl_to_buf_INIT_READ     : STD_LOGIC;

signal buf_to_apl_INIT_DATAREADY: STD_LOGIC;
signal buf_to_apl_INIT_DATA     : STD_LOGIC_VECTOR (50 downto 0);
signal buf_to_apl_INIT_READ     : STD_LOGIC;

signal apl_to_buf_REPLY_DATAREADY: STD_LOGIC;
signal apl_to_buf_REPLY_DATA     : STD_LOGIC_VECTOR (50 downto 0);
signal apl_to_buf_REPLY_READ     : STD_LOGIC;

signal buf_to_apl_REPLY_DATAREADY: STD_LOGIC;
signal buf_to_apl_REPLY_DATA     : STD_LOGIC_VECTOR (50 downto 0);
signal buf_to_apl_REPLY_READ     : STD_LOGIC;

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

signal m_DATAREADY_OUT : STD_LOGIC_VECTOR (1 downto 0);
signal m_DATA_OUT      : STD_LOGIC_VECTOR (101 downto 0);
signal m_READ_IN       : STD_LOGIC_VECTOR (1 downto 0);

signal m_DATAREADY_IN  : STD_LOGIC_VECTOR (1 downto 0);
signal m_DATA_IN       : STD_LOGIC_VECTOR (101 downto 0);
signal m_READ_OUT      : STD_LOGIC_VECTOR (1 downto 0);

begin

  m_DATAREADY_OUT(0) <= MED_INIT_DATAREADY_OUT;
  m_DATAREADY_OUT(1) <= MED_REPLY_DATAREADY_OUT;
  m_DATA_OUT(50 downto 0) <= MED_INIT_DATA_OUT;
  m_DATA_OUT(101 downto 51) <= MED_REPLY_DATA_OUT;
  MED_INIT_READ_IN <= m_READ_IN(0);
  MED_REPLY_READ_IN <= m_READ_IN(1);

  MED_INIT_DATAREADY_IN <= m_DATAREADY_IN(0);
  MED_REPLY_DATAREADY_IN <= m_DATAREADY_IN(1);
  MED_INIT_DATA_IN <= m_DATA_IN(50 downto 0);
  MED_REPLY_DATA_IN <= m_DATA_IN(101 downto 51);
  m_READ_OUT(0) <= MED_INIT_READ_OUT;
  m_READ_OUT(1) <= MED_REPLY_READ_OUT;
  
  
  PASSIVE_API: trb_net_passive_api 

  generic map (FIFO_TO_INT_DEPTH => FIFO_TO_INT_DEPTH,               
               FIFO_TO_APL_DEPTH => FIFO_TO_APL_DEPTH,               
               FIFO_TERM_BUFFER_DEPTH => FIFO_TERM_BUFFER_DEPTH)
    
  port map (
    --  Misc
    CLK    => CLK,
    RESET  => RESET,
    CLK_EN => CLK_EN,

    -- APL Transmitter port
    APL_DATA_IN           => APL_DATA_IN,
    APL_WRITE_IN          => APL_WRITE_IN,
    APL_FIFO_FULL_OUT     => APL_FIFO_FULL_OUT,
    APL_SHORT_TRANSFER_IN => APL_SHORT_TRANSFER_IN,
    APL_DTYPE_IN          => APL_DTYPE_IN,
    APL_ERROR_PATTERN_IN  => APL_ERROR_PATTERN_IN,
    APL_Send_IN           => APL_Send_IN,
    APL_TARGET_ADDRESS_IN => APL_TARGET_ADDRESS_IN,

    -- Receiver port
    APL_DATA_OUT      => APL_DATA_OUT,
    APL_TYP_OUT       => APL_TYP_OUT,
    APL_DATAREADY_OUT => APL_DATAREADY_OUT,
    APL_READ_IN       => APL_READ_IN,
    
    -- APL Control port
    APL_RUN_OUT       => APL_RUN_OUT,
    APL_MY_ADDRESS_IN => APL_MY_ADDRESS_IN,
    APL_SEQNR_OUT     => APL_SEQNR_OUT,
    
    -- Internal direction port
    -- connect via private signals
    
    INT_INIT_DATAREADY_OUT => apl_to_buf_INIT_DATAREADY,
    INT_INIT_DATA_OUT      => apl_to_buf_INIT_DATA,
    INT_INIT_READ_IN       => apl_to_buf_INIT_READ,

    INT_INIT_DATAREADY_IN  => buf_to_apl_INIT_DATAREADY,
    INT_INIT_DATA_IN       => buf_to_apl_INIT_DATA,
    INT_INIT_READ_OUT      => buf_to_apl_INIT_READ,

    INT_REPLY_HEADER_IN    => '0',
    INT_REPLY_DATAREADY_OUT =>apl_to_buf_REPLY_DATAREADY,
    INT_REPLY_DATA_OUT     => apl_to_buf_REPLY_DATA,
    INT_REPLY_READ_IN      => apl_to_buf_REPLY_READ,

    INT_REPLY_DATAREADY_IN => buf_to_apl_REPLY_DATAREADY,
    INT_REPLY_DATA_IN      => buf_to_apl_REPLY_DATA,
    INT_REPLY_READ_OUT     => buf_to_apl_REPLY_READ,

    -- Status and control port
    STAT_FIFO_TO_INT => api_stat_fifo_to_int,
    STAT_FIFO_TO_APL => api_stat_fifo_to_apl
    );

STAT_api_control_signals(2 downto 0)  <= APL_DATA_IN(2 downto 0);
STAT_api_control_signals(3)           <= APL_WRITE_IN;
STAT_api_control_signals(4)           <= APL_Send_IN;
STAT_api_control_signals(7 downto 5)  <= (others => '0');
STAT_api_control_signals(10 downto 8) <= apl_to_buf_INIT_DATA(2 downto 0);
STAT_api_control_signals(11)           <= apl_to_buf_INIT_DATAREADY;
STAT_api_control_signals(12)           <= apl_to_buf_INIT_READ;
STAT_api_control_signals(13)           <= MED_INIT_DATAREADY_IN;
STAT_api_control_signals(14)           <= MED_REPLY_DATAREADY_IN;
STAT_api_control_signals(15)           <= MED_REPLY_DATA_IN(48);
STAT_api_control_signals(16)           <= MED_REPLY_DATA_IN(50);

STAT_api_control_signals(31 downto 17) <= (others => '0');



IOBUF: trb_net_iobuf

  generic map (SWITCH_OFF_BUFFER_CHECK => 0,
                      --switching off erroneous output buffer counter. MUST ONLY be 
                      --used for short transfers!!!!
               INIT_DEPTH => INIT_DEPTH,
               REPLY_DEPTH => REPLY_DEPTH)

  port map (
    --  Misc
    CLK     => CLK ,
    RESET   => RESET,
    CLK_EN  => CLK_EN,
    --  Media direction port
    MED_INIT_DATAREADY_OUT  => MED_INIT_DATAREADY_OUT,                           
    MED_INIT_DATA_OUT       => MED_INIT_DATA_OUT,
    MED_INIT_READ_IN        => MED_INIT_READ_IN,
    
    MED_INIT_DATAREADY_IN   => MED_INIT_DATAREADY_IN,                                 
    MED_INIT_DATA_IN        => MED_INIT_DATA_IN,
    MED_INIT_READ_OUT       => MED_INIT_READ_OUT,
    MED_INIT_ERROR_IN       => (others => '0'),

    MED_REPLY_DATAREADY_OUT => MED_REPLY_DATAREADY_OUT,                                  
    MED_REPLY_DATA_OUT      => MED_REPLY_DATA_OUT,
    MED_REPLY_READ_IN       => MED_REPLY_READ_IN,
    
    MED_REPLY_DATAREADY_IN  => MED_REPLY_DATAREADY_IN,                               
    MED_REPLY_DATA_IN       => MED_REPLY_DATA_IN,
    MED_REPLY_READ_OUT      => MED_REPLY_READ_OUT,
    MED_REPLY_ERROR_IN      => (others => '0'),
    
    -- Internal direction port

    INT_INIT_DATAREADY_OUT => buf_to_apl_INIT_DATAREADY,
    INT_INIT_DATA_OUT      => buf_to_apl_INIT_DATA,
    INT_INIT_READ_IN       => buf_to_apl_INIT_READ,

    INT_INIT_DATAREADY_IN  => apl_to_buf_INIT_DATAREADY,
    INT_INIT_DATA_IN       => apl_to_buf_INIT_DATA,
    INT_INIT_READ_OUT      => apl_to_buf_INIT_READ,
    
    INT_REPLY_HEADER_IN     => '0',
    INT_REPLY_DATAREADY_OUT => buf_to_apl_REPLY_DATAREADY,
    INT_REPLY_DATA_OUT      => buf_to_apl_REPLY_DATA,
    INT_REPLY_READ_IN       => buf_to_apl_REPLY_READ,

    INT_REPLY_DATAREADY_IN  => apl_to_buf_REPLY_DATAREADY,
    INT_REPLY_DATA_IN       => apl_to_buf_REPLY_DATA,
    INT_REPLY_READ_OUT      => apl_to_buf_REPLY_READ,

    -- Status and control port
    STAT_GEN               => STAT_GEN,
    STAT_LOCKED            => STAT_LOCKED,
    STAT_INIT_BUFFER       => STAT_INIT_BUFFER,
    STAT_REPLY_BUFFER      => STAT_REPLY_BUFFER,
    CTRL_GEN               => CTRL_GEN,
    CTRL_LOCKED            => CTRL_LOCKED,
    STAT_CTRL_INIT_BUFFER  => STAT_CTRL_INIT_BUFFER,
    STAT_CTRL_REPLY_BUFFER => STAT_CTRL_REPLY_BUFFER
    );

  MPLEX: trb_net_io_multiplexer
    generic map (BUS_WIDTH =>  52,
                 MULT_WIDTH =>  1)
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
    
    CTRL => MPLEX_CTRL,
    STAT => STAT_MPLEX

    );
  
end trb_net_passive_apimbuf_arch;
  
