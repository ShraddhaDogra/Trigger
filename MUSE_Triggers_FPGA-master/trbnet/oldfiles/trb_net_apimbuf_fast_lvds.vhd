------------------------------------------------------------------------------
--
-- This is a combination of the fast 8bit lvds interface and an active or 
-- passive api, selectable with generic "API_TYPE"
--
------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;



entity trb_net_apimbuf_fast_lvds is
  generic (
    API_TYPE : integer range 0 to 1 := 0  --0: passive, 1: active api
    );
  port(
    CLK    : in std_logic;      
    RESET  : in std_logic;
    API_RESET : in std_logic;
    CLK_EN : in std_logic;

    --LVDS
    LVDS_IN  : in  std_logic_vector(15 downto 0);
    LVDS_OUT : out std_logic_vector(15 downto 0);

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

    -- Status and Control registers
    API_STAT_GEN:           out std_logic_vector(31 downto 0);
    API_STAT_LOCKED:        out std_logic_vector(31 downto 0);
    API_STAT_INIT_BUFFER:   out std_logic_vector(31 downto 0);
    API_STAT_REPLY_BUFFER:  out std_logic_vector(31 downto 0);
    API_STAT_control_signals: out std_logic_vector(31 downto 0);
    STAT_MPLEX:             out STD_LOGIC_VECTOR(31 downto 0);
    API_STAT_FIFO_TO_INT:   out std_logic_vector(31 downto 0);
    API_STAT_FIFO_TO_APL:   out std_logic_vector(31 downto 0);
    LVDS_STAT:              out std_logic_vector(31 downto 0);
    LVDS_CTRL:              in  std_logic_vector(31 downto 0);
    MPLEX_CTRL:             in  std_logic_vector(31 downto 0)
    );
end entity;


architecture trb_net_apimbuf_fast_lvds_arch of trb_net_apimbuf_fast_lvds is
  component trb_net_55_to_18_converter is
    port(
      --  Misc
      CLK    : in std_logic;      
      RESET  : in std_logic;    
      CLK_EN : in std_logic;
  
      D55_DATA_IN        : in std_logic_vector(55 downto 0);
      D55_DATAREADY_IN   : in std_logic;
      D55_READ_OUT       : out std_logic;
  
      D18_DATA_OUT       : out std_logic_vector(15 downto 0);
      D18_PACKET_NUM_OUT : out std_logic_vector(1 downto 0);
      D18_DATAREADY_OUT  : out std_logic;
      D18_READ_IN        : in std_logic;
  
      D55_DATA_OUT       : out std_logic_vector(55 downto 0);
      D55_DATAREADY_OUT  : out std_logic;
      D55_READ_IN        : in std_logic;
  
      D18_DATA_IN       : in std_logic_vector(15 downto 0);
      D18_PACKET_NUM_IN : in std_logic_vector(1 downto 0);
      D18_DATAREADY_IN  : in std_logic;
      D18_READ_OUT      : out std_logic
    );
  end component;
  
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
  end component;

  component trb_net_passive_apimbuf is
    generic (
      INIT_DEPTH : integer := 3;     -- Depth of the FIFO, 2^(n+1), if
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
      
      -- Status and control port
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
  end component;


  component trb_net_med_8bit_fast is
  port(
    --  Misc
    CLK    : in std_logic;      
    RESET  : in std_logic;    
    CLK_EN : in std_logic;
    -- 1st part: from the medium to the internal logic (trbnet)
    INT_DATAREADY_OUT: out STD_LOGIC;
    INT_DATA_OUT:      out STD_LOGIC_VECTOR (15 downto 0); -- Data word
    INT_PACKET_NR_OUT: out STD_LOGIC_VECTOR(1 downto 0);
    INT_READ_IN:       in  STD_LOGIC; 
    INT_ERROR_OUT:     out STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    -- 2nd part: from the internal logic (trbnet) to the medium
    INT_DATAREADY_IN:  in  STD_LOGIC; -- Data word is offered for the Media 
    INT_DATA_IN:       in  STD_LOGIC_VECTOR (15 downto 0); -- Data word
    INT_PACKET_NR_IN : in STD_LOGIC_VECTOR(1 downto 0);
    INT_READ_OUT:      out STD_LOGIC; -- offered word is read
    INT_ERROR_IN:      in  STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    --  Media direction port
    -- in this case for the cable => 32 lines in total
    MED_DATA_OUT:             out STD_LOGIC_VECTOR (12 downto 0); -- Data word 
    MED_TRANSMISSION_CLK_OUT: out STD_LOGIC;
    MED_CARRIER_OUT:          out STD_LOGIC;
    MED_PARITY_OUT:           out STD_LOGIC;
    MED_DATA_IN:              in  STD_LOGIC_VECTOR (12 downto 0); -- Data word
    MED_TRANSMISSION_CLK_IN:  in  STD_LOGIC;
    MED_CARRIER_IN:           in  STD_LOGIC;
    MED_PARITY_IN:            in  STD_LOGIC;
    -- Status and control port => this never can hurt
    STAT: out STD_LOGIC_VECTOR (31 downto 0);
    CTRL: in  STD_LOGIC_VECTOR (31 downto 0)   
    );
  end component;
  
  
-----------------------------------------------------------------------
--media interface signals
-----------------------------------------------------------------------
  signal LVDS_INT_DATAREADY_OUT : std_logic;
  signal LVDS_INT_DATA_OUT : std_logic_vector(15 downto 0);
  signal LVDS_INT_READ_IN : std_logic;
  signal LVDS_INT_ERROR_IN : std_logic_vector(2 downto 0);
  signal LVDS_INT_DATAREADY_IN : std_logic;
  signal LVDS_INT_DATA_IN : std_logic_vector(15 downto 0);
  signal LVDS_INT_READ_OUT : std_logic;
  signal LVDS_INT_ERROR_OUT : std_logic_vector(2 downto 0);
  signal LVDS_MED_DATA_OUT : std_logic_vector(12 downto 0);
  signal LVDS_MED_TRANSMISSION_CLK_OUT : std_logic;
  signal LVDS_MED_CARRIER_OUT : std_logic;
  signal LVDS_MED_PARITY_OUT : std_logic;
  signal LVDS_MED_DATA_IN : std_logic_vector(12 downto 0);
  signal LVDS_MED_TRANSMISSION_CLK_IN : std_logic;
  signal LVDS_MED_CARRIER_IN : std_logic;
  signal LVDS_MED_PARITY_IN : std_logic;
  signal LVDS_INT_PACKET_NUM_OUT : std_logic_vector(1 downto 0);
  signal LVDS_INT_PACKET_NUM_IN : std_logic_vector(1 downto 0);


  
-----------------------------------------------------------------------
--API signals
-----------------------------------------------------------------------
  signal API_MED_DATAREADY_OUT : std_logic;
  signal API_MED_DATA_OUT : std_logic_vector(51 downto 0);
  signal API_MED_READ_IN : std_logic;
  signal API_MED_ERROR_IN : std_logic_vector(2 downto 0);
  signal API_MED_DATAREADY_IN : std_logic;
  signal API_MED_DATA_IN : std_logic_vector(51 downto 0);
  signal API_MED_READ_OUT : std_logic;
  signal API_MED_ERROR_OUT : std_logic_vector(2 downto 0);
  signal API_ctrl : std_logic_vector(31 downto 0);
  signal C5518_D55_DATA_IN, C5518_D55_DATA_OUT : std_logic_vector(55 downto 0);

-----------------------------------------------------------------------
--Control signals
----------------------------------------------------------------------- 

  
  
begin


-----------------------------------------------------------------------
--the media interface
----------------------------------------------------------------------- 
  lvds: trb_net_med_8bit_fast
    port map(
      CLK    => CLK,
      RESET  => RESET,    
      CLK_EN => CLK_EN,
      
      INT_DATAREADY_OUT => LVDS_INT_DATAREADY_OUT,
      INT_DATA_OUT => LVDS_INT_DATA_OUT,
      INT_PACKET_NR_OUT => LVDS_INT_PACKET_NUM_OUT,
      INT_READ_IN => LVDS_INT_READ_IN,
      INT_ERROR_OUT => LVDS_INT_ERROR_OUT,
      INT_DATAREADY_IN => LVDS_INT_DATAREADY_IN,
      INT_DATA_IN => LVDS_INT_DATA_IN,
      INT_PACKET_NR_IN => LVDS_INT_PACKET_NUM_IN,
      INT_READ_OUT => LVDS_INT_READ_OUT,
      INT_ERROR_IN => LVDS_INT_ERROR_IN,
      
      MED_DATA_OUT => LVDS_MED_DATA_OUT,
      MED_TRANSMISSION_CLK_OUT => LVDS_MED_TRANSMISSION_CLK_OUT,
      MED_CARRIER_OUT => LVDS_MED_CARRIER_OUT,
      MED_PARITY_OUT => LVDS_MED_PARITY_OUT,
      MED_DATA_IN => LVDS_MED_DATA_IN,
      MED_TRANSMISSION_CLK_IN => LVDS_MED_TRANSMISSION_CLK_IN,
      MED_CARRIER_IN => LVDS_MED_CARRIER_IN,
      MED_PARITY_IN => LVDS_MED_PARITY_IN,
      STAT => LVDS_STAT,
      CTRL => LVDS_CTRL
    );

  LVDS_OUT(7 downto 0) <= LVDS_MED_DATA_OUT(7 downto 0);
  LVDS_OUT(10) <= C5518_D55_DATA_OUT(48);
  LVDS_OUT(9)  <= LVDS_INT_DATA_OUT(0);
  LVDS_OUT(8)  <= LVDS_INT_DATAREADY_OUT;
  LVDS_OUT(11) <= LVDS_MED_DATA_OUT(11) and not API_RESET;
  LVDS_OUT(12) <= LVDS_MED_DATA_OUT(12);
  LVDS_OUT(13) <= LVDS_MED_TRANSMISSION_CLK_OUT;
  LVDS_OUT(14) <= LVDS_MED_CARRIER_OUT;
  LVDS_OUT(15) <= LVDS_MED_PARITY_OUT;
  LVDS_MED_DATA_IN <= LVDS_IN(12 downto 0);
  LVDS_MED_TRANSMISSION_CLK_IN <= LVDS_IN(13);
  LVDS_MED_CARRIER_IN <= LVDS_IN(14);
  LVDS_MED_PARITY_IN <= LVDS_IN(15);


-----------------------------------------------------------------------
--bus width converter
-----------------------------------------------------------------------
  C5518 : trb_net_55_to_18_converter
    port map(
      --  Misc
      CLK    => CLK,
      RESET  => API_RESET,
      CLK_EN => CLK_EN,
  
      D55_DATA_IN        => C5518_D55_DATA_IN,
      D55_DATAREADY_IN   => API_MED_DATAREADY_OUT,
      D55_READ_OUT       => API_MED_READ_IN,
  
      D18_DATA_OUT       => LVDS_INT_DATA_IN,
      D18_PACKET_NUM_OUT => LVDS_INT_PACKET_NUM_IN,
      D18_DATAREADY_OUT  => LVDS_INT_DATAREADY_IN,
      D18_READ_IN        => LVDS_INT_READ_OUT,
  
      D55_DATA_OUT       => C5518_D55_DATA_OUT,
      D55_DATAREADY_OUT  => API_MED_DATAREADY_IN,
      D55_READ_IN        => API_MED_READ_OUT,
  
      D18_DATA_IN        => LVDS_INT_DATA_OUT,
      D18_PACKET_NUM_IN  => LVDS_INT_PACKET_NUM_OUT,
      D18_DATAREADY_IN   => LVDS_INT_DATAREADY_OUT,
      D18_READ_OUT       => LVDS_INT_READ_IN
    );

  C5518_D55_DATA_IN(51 downto 0) <= API_MED_DATA_OUT;
  C5518_D55_DATA_IN(55 downto 52) <= "0000";
  API_MED_DATA_IN <= C5518_D55_DATA_OUT(51 downto 0);

-----------------------------------------------------------------------
--API
-----------------------------------------------------------------------

  apigenact : if API_TYPE = 1 generate
    API: trb_net_active_apimbuf
      generic map (
        FIFO_TERM_BUFFER_DEPTH => 3)
      port map (
        CLK             => CLK,
        RESET           => API_RESET,
        CLK_EN          => CLK_EN,
        -- APL Transmitter port
        APL_DATA_IN           => APL_DATA_IN,
        APL_WRITE_IN          => APL_WRITE_IN,
        APL_FIFO_FULL_OUT     => APL_FIFO_FULL_OUT,
        APL_SHORT_TRANSFER_IN => APL_SHORT_TRANSFER_IN,
        APL_DTYPE_IN          => APL_DTYPE_IN,
        APL_ERROR_PATTERN_IN  => APL_ERROR_PATTERN_IN,
        APL_SEND_IN           => APL_SEND_IN,
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
        -- Media direction
        MED_DATAREADY_OUT => API_MED_DATAREADY_OUT,
        MED_DATA_OUT      => API_MED_DATA_OUT,
        MED_READ_IN       => API_MED_READ_IN,
        MED_ERROR_IN      => LVDS_INT_ERROR_OUT,
        MED_DATAREADY_IN  => API_MED_DATAREADY_IN,
        MED_DATA_IN       => API_MED_DATA_IN,
        MED_READ_OUT      => API_MED_READ_OUT,
      
        CTRL_LOCKED     => (others => '0'),
        CTRL_GEN        => (others => '0'),
  
        STAT_GEN           => API_STAT_GEN,
        STAT_LOCKED        => API_STAT_LOCKED,
        STAT_INIT_BUFFER   => API_STAT_INIT_BUFFER,
        STAT_REPLY_BUFFER  => API_STAT_REPLY_BUFFER,
        STAT_api_control_signals => API_STAT_control_signals,
        STAT_MPLEX => STAT_MPLEX,
        STAT_CTRL_INIT_BUFFER     => (others => '0'),
        STAT_CTRL_REPLY_BUFFER     => (others => '0'),
        MPLEX_CTRL => MPLEX_CTRL,
        API_STAT_FIFO_TO_INT => API_STAT_FIFO_TO_INT,
        API_STAT_FIFO_TO_APL => API_STAT_FIFO_TO_APL
        );
  end generate;

  apigenpas : if API_TYPE = 0 generate
    API: trb_net_passive_apimbuf
      generic map (
        FIFO_TERM_BUFFER_DEPTH => 3)
      port map (
        CLK             => CLK,
        RESET           => API_RESET,
        CLK_EN          => CLK_EN,
        -- APL Transmitter port
        APL_DATA_IN           => APL_DATA_IN,
        APL_WRITE_IN          => APL_WRITE_IN,
        APL_FIFO_FULL_OUT     => APL_FIFO_FULL_OUT,
        APL_SHORT_TRANSFER_IN => APL_SHORT_TRANSFER_IN,
        APL_DTYPE_IN          => APL_DTYPE_IN,
        APL_ERROR_PATTERN_IN  => APL_ERROR_PATTERN_IN,
        APL_SEND_IN           => APL_SEND_IN,
        APL_TARGET_ADDRESS_IN => APL_TARGET_ADDRESS_IN,
        -- Receiver port
        APL_DATA_OUT      => APL_DATA_OUT,
        APL_TYP_OUT       => APL_TYP_OUT,
        APL_DATAREADY_OUT => APL_DATAREADY_OUT,
        APL_READ_IN       => APL_READ_IN,
        -- APL Control port
        APL_RUN_OUT       => APL_RUN_OUT,
        APL_SEQNR_OUT     => APL_SEQNR_OUT,
        APL_MY_ADDRESS_IN => APL_MY_ADDRESS_IN,
        -- Media direction
        MED_DATAREADY_OUT => API_MED_DATAREADY_OUT,
        MED_DATA_OUT      => API_MED_DATA_OUT,
        MED_READ_IN       => API_MED_READ_IN,
        MED_ERROR_IN      => API_MED_ERROR_IN,
        MED_DATAREADY_IN  => API_MED_DATAREADY_IN,
        MED_DATA_IN       => API_MED_DATA_IN,
        MED_READ_OUT      => API_MED_READ_OUT,
      
        CTRL_LOCKED     => (others => '0'),
        CTRL_GEN        => (others => '0'),
  
        STAT_GEN           => API_STAT_GEN,
        STAT_LOCKED        => API_STAT_LOCKED,
        STAT_INIT_BUFFER   => API_STAT_INIT_BUFFER,
        STAT_REPLY_BUFFER  => API_STAT_REPLY_BUFFER,
        STAT_api_control_signals => API_STAT_control_signals,
        STAT_MPLEX => STAT_MPLEX,
        STAT_CTRL_INIT_BUFFER     => (others => '0'),
        STAT_CTRL_REPLY_BUFFER     => (others => '0'),
        MPLEX_CTRL => MPLEX_CTRL,
        API_STAT_FIFO_TO_INT => API_STAT_FIFO_TO_INT,
        API_STAT_FIFO_TO_APL => API_STAT_FIFO_TO_APL
        );
  end generate;

end architecture;







