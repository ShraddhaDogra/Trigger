
-- NOT UP TO DATE
























-- this is an trigger receiver combined with a passive api

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

--Entity decalaration for clock generator
entity trb_net16_endpoint_2_trg_2_api is

  generic (
   --api type for data channel
    API1_TYPE          : integer range 0 to 1 := 0;
    API2_TYPE          : integer range 0 to 1 := 0;
   --Fifo for data channel
    DAT1_INIT_DEPTH    : integer range 0 to 7 := 2;
    DAT1_REPLY_DEPTH   : integer range 0 to 7 := 0; --passive api doesn't need a fifo here
    DAT1_FIFO_TO_INT_DEPTH : integer range 0 to 7 := 1;
    DAT1_FIFO_TO_APL_DEPTH : integer range 0 to 7 := 1;
    DAT2_INIT_DEPTH    : integer range 0 to 7 := 2;
    DAT2_REPLY_DEPTH   : integer range 0 to 7 := 0; --passive api doesn't need a fifo here
    DAT2_FIFO_TO_INT_DEPTH : integer range 0 to 7 := 1;
    DAT2_FIFO_TO_APL_DEPTH : integer range 0 to 7 := 1;
    --SBUF_DATA_VERSION : integer range 0 to 1 := 0;
   --Fifo for TRG channel 
    TRG1_INIT_DEPTH    : integer range 0 to 7 := 0;
    TRG1_REPLY_DEPTH   : integer range 0 to 7 := 0;
    TRG1_SECURE_MODE   : integer range 0 to 1 := 0;
    TRG2_INIT_DEPTH    : integer range 0 to 7 := 0;
    TRG2_REPLY_DEPTH   : integer range 0 to 7 := 0;
    TRG2_SECURE_MODE   : integer range 0 to 1 := 0;
    --SBUF_TRG_VERSION  : integer range 0 to 1 := 0;
   --Multiplexer
    MUX_WIDTH        : integer range 1 to 5 := 3;
    MUX_SECURE_MODE  : integer range 0 to 1 := 0;
    TRG1_CHANNEL     : integer range 0 to 3 := 0; --range 0 to 2**(MUX_WIDTH-1)
    TRG2_CHANNEL     : integer range 0 to 3 := 1; --range 0 to 2**(MUX_WIDTH-1)
    DAT1_CHANNEL     : integer range 0 to 3 := 2; --range 0 to 2**(MUX_WIDTH-1)
    DAT2_CHANNEL     : integer range 0 to 3 := 3; --range 0 to 2**(MUX_WIDTH-1)
   --General
    DATA_WIDTH       : integer range 16 to 16 := 16;
    NUM_WIDTH        : integer range 2 to 2 := 2
    );

  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
    --  Media direction port
    MED_DATAREADY_OUT: out std_logic;  --Data word ready to be read out
    MED_DATA_OUT:      out std_logic_vector (15 downto 0); -- Data word
    MED_PACKET_NUM_OUT:out std_logic_vector (1 downto 0);
    MED_READ_IN:       in  std_logic; -- Media is reading
    MED_DATAREADY_IN:  in  std_logic; -- Data word is offered by the Media
    MED_DATA_IN:       in  std_logic_vector (15 downto 0); -- Data word
    MED_PACKET_NUM_IN: in  std_logic_vector (1 downto 0);
    MED_READ_OUT:      out std_logic; -- buffer reads a word from media
    MED_ERROR_IN:      in  std_logic_vector (2 downto 0);  -- Status bits

    -- APL1 Transceiver port
    APL1_DATA_IN:       in  std_logic_vector (15 downto 0); -- Data word "application to network"
    APL1_PACKET_NUM_IN: in  std_logic_vector (1 downto 0);
    APL1_WRITE_IN:      in  std_logic; -- Data word is valid and should be transmitted
    APL1_FIFO_FULL_OUT: out std_logic; -- Stop transfer, the fifo is full
    APL1_SHORT_TRANSFER_IN: in  std_logic; --
    APL1_DTYPE_IN:      in  std_logic_vector (3 downto 0);  -- see NewTriggerBusNetworkDescr
    APL1_ERROR_PATTERN_IN: in  std_logic_vector (31 downto 0); -- see NewTriggerBusNetworkDescr
    APL1_SEND_IN:       in  std_logic; -- Release sending of the data
    APL1_DATA_OUT:      out std_logic_vector (15 downto 0); -- Data word "network to application"
    APL1_PACKET_NUM_OUT:out std_logic_vector (1 downto 0);
    APL1_TYP_OUT:       out std_logic_vector (2 downto 0);  -- Which kind of data word: DAT, HDR or TRM
    APL1_DATAREADY_OUT: out std_logic; -- Data word is valid and might be read out
    APL1_READ_IN:       in  std_logic; -- Read data word
    APL1_RUN_OUT:       out std_logic; -- Data transfer is running
    APL1_MY_ADDRESS_IN: in  std_logic_vector (15 downto 0);  -- My own address (temporary solution!!!)
    APL1_SEQNR_OUT:     out std_logic_vector (7 downto 0);
    APL1_TARGET_ADDRESS_IN : in std_logic_vector(15 downto 0);

    -- APL2 Transceiver port
    APL2_DATA_IN:       in  std_logic_vector (15 downto 0); -- Data word "application to network"
    APL2_PACKET_NUM_IN: in  std_logic_vector (1 downto 0);
    APL2_WRITE_IN:      in  std_logic; -- Data word is valid and should be transmitted
    APL2_FIFO_FULL_OUT: out std_logic; -- Stop transfer, the fifo is full
    APL2_SHORT_TRANSFER_IN: in  std_logic; --
    APL2_DTYPE_IN:      in  std_logic_vector (3 downto 0);  -- see NewTriggerBusNetworkDescr
    APL2_ERROR_PATTERN_IN: in  std_logic_vector (31 downto 0); -- see NewTriggerBusNetworkDescr
    APL2_SEND_IN:       in  std_logic; -- Release sending of the data
    APL2_DATA_OUT:      out std_logic_vector (15 downto 0); -- Data word "network to application"
    APL2_PACKET_NUM_OUT:out std_logic_vector (1 downto 0);
    APL2_TYP_OUT:       out std_logic_vector (2 downto 0);  -- Which kind of data word: DAT, HDR or TRM
    APL2_DATAREADY_OUT: out std_logic; -- Data word is valid and might be read out
    APL2_READ_IN:       in  std_logic; -- Read data word
    APL2_RUN_OUT:       out std_logic; -- Data transfer is running
    APL2_MY_ADDRESS_IN: in  std_logic_vector (15 downto 0);  -- My own address (temporary solution!!!)
    APL2_SEQNR_OUT:     out std_logic_vector (7 downto 0);
    APL2_TARGET_ADDRESS_IN : in std_logic_vector(15 downto 0);

    -- TRG1 Receiver port
    TRG1_GOT_TRIGGER_OUT   : out std_logic;
    TRG1_ERROR_PATTERN_OUT : out std_logic_vector(31 downto 0);
    TRG1_DTYPE_OUT         : out std_logic_vector(3 downto 0);
    TRG1_SEQNR_OUT         : out std_logic_vector(7 downto 0);
    TRG1_ERROR_PATTERN_IN  : in  std_logic_vector(31 downto 0);
    TRG1_RELEASE_IN        : in  std_logic;

    -- TRG2 Receiver port
    TRG2_GOT_TRIGGER_OUT   : out std_logic;
    TRG2_ERROR_PATTERN_OUT : out std_logic_vector(31 downto 0);
    TRG2_DTYPE_OUT         : out std_logic_vector(3 downto 0);
    TRG2_SEQNR_OUT         : out std_logic_vector(7 downto 0);
    TRG2_ERROR_PATTERN_IN  : in  std_logic_vector(31 downto 0);
    TRG2_RELEASE_IN        : in  std_logic;

    -- Status and control port => for debugging
    STAT_DAT2_GEN:          out std_logic_vector (31 downto 0); -- General Status
    STAT_DAT2_LOCKED:       out std_logic_vector (31 downto 0); -- Status of the handshake and buffer control
    STAT_DAT2_INIT_BUFFER:  out std_logic_vector (31 downto 0); -- Status of the handshake and buffer control
    STAT_DAT2_REPLY_BUFFER: out std_logic_vector (31 downto 0); -- General Status
    STAT_DAT2_api_control_signals: out std_logic_vector(31 downto 0);
    CTRL_DAT2_GEN:          in  std_logic_vector (31 downto 0);
    CTRL_DAT2_LOCKED:       in  std_logic_vector (31 downto 0);
    STAT_DAT2_CTRL_INIT_BUFFER:  in  std_logic_vector (31 downto 0);
    STAT_DAT2_CTRL_REPLY_BUFFER: in  std_logic_vector (31 downto 0);
    STAT_TRG2_GEN:          out std_logic_vector (31 downto 0); -- General Status
    STAT_TRG2_LOCKED:       out std_logic_vector (31 downto 0); -- Status of the handshake and buffer control
    STAT_TRG2_INIT_BUFFER:  out std_logic_vector (31 downto 0); -- Status of the handshake and buffer control
    STAT_TRG2_REPLY_BUFFER: out std_logic_vector (31 downto 0); -- General Status
    STAT_TRG2_api_control_signals: out std_logic_vector(31 downto 0);
    CTRL_TRG2_GEN:          in  std_logic_vector (31 downto 0);
    CTRL_TRG2_LOCKED:       in  std_logic_vector (31 downto 0);
    STAT_TRG2_CTRL_INIT_BUFFER:  in  std_logic_vector (31 downto 0);
    STAT_TRG2_CTRL_REPLY_BUFFER: in  std_logic_vector (31 downto 0);
    STAT_MPLEX:        out std_logic_vector(31 downto 0);
    MPLEX_CTRL: in  std_logic_vector (31 downto 0);
    DAT1_API_STAT_FIFO_TO_INT: out std_logic_vector(31 downto 0);
    DAT1_API_STAT_FIFO_TO_APL: out std_logic_vector(31 downto 0)
    DAT2_API_STAT_FIFO_TO_INT: out std_logic_vector(31 downto 0);
    DAT2_API_STAT_FIFO_TO_APL: out std_logic_vector(31 downto 0)
    );
end entity;

architecture trb_net16_endpoint_2_trg_2_api_arch of trb_net16_endpoint_2_trg_2_api_endpoint is

  component trb_net16_iobuf is
  
    generic (
      INIT_DEPTH : integer := 1;
      REPLY_DEPTH : integer := 1
      );
  
    port(
      --  Misc
      CLK    : in std_logic;      
      RESET  : in std_logic;    
      CLK_EN : in std_logic;
      --  Media direction port
      MED_INIT_DATAREADY_OUT: out std_logic;  --Data word ready to be read out
                                        --by the media (via the TrbNetIOMultiplexer)
      MED_INIT_DATA_OUT:      out std_logic_vector (15 downto 0); -- Data word
      MED_INIT_PACKET_NUM_OUT:out std_logic_vector (1 downto 0);
      MED_INIT_READ_IN:       in  std_logic; -- Media is reading
      
      MED_INIT_DATAREADY_IN:  in  std_logic; -- Data word is offered by the Media
                                        -- (the IOBUF MUST read)
      MED_INIT_DATA_IN:       in  std_logic_vector (15 downto 0); -- Data word
      MED_INIT_PACKET_NUM_IN: in  std_logic_vector (1 downto 0);
      MED_INIT_READ_OUT:      out std_logic; -- buffer reads a word from media
      MED_INIT_ERROR_IN:      in  std_logic_vector (2 downto 0);  -- Status bits
  
      MED_REPLY_DATAREADY_OUT: out std_logic;  --Data word ready to be read out
                                        --by the media (via the TrbNetIOMultiplexer)
      MED_REPLY_DATA_OUT:      out std_logic_vector (15 downto 0); -- Data word
      MED_REPLY_PACKET_NUM_OUT:out std_logic_vector (1 downto 0);
      MED_REPLY_READ_IN:       in  std_logic; -- Media is reading
      
      MED_REPLY_DATAREADY_IN:  in  std_logic; -- Data word is offered by the Media
                                        -- (the IOBUF MUST read)
      MED_REPLY_DATA_IN:       in  std_logic_vector (15 downto 0); -- Data word
      MED_REPLY_PACKET_NUM_IN: in  std_logic_vector (1 downto 0);
      MED_REPLY_READ_OUT:      out std_logic; -- buffer reads a word from media
      MED_REPLY_ERROR_IN:      in  std_logic_vector (2 downto 0);  -- Status bits
      
      -- Internal direction port
  
      INT_INIT_DATAREADY_OUT: out std_logic;
      INT_INIT_DATA_OUT:      out std_logic_vector (15 downto 0); -- Data word
      INT_INIT_PACKET_NUM_OUT:out std_logic_vector (1 downto 0);
      INT_INIT_READ_IN:       in  std_logic;
  
      INT_INIT_DATAREADY_IN:  in  std_logic;
      INT_INIT_DATA_IN:       in  std_logic_vector (15 downto 0); -- Data word
      INT_INIT_PACKET_NUM_IN: in  std_logic_vector (1 downto 0);
      INT_INIT_READ_OUT:      out std_logic;
      
      INT_REPLY_HEADER_IN:     in  std_logic; -- Concentrator kindly asks to resend the last
                                        -- header (only for the reply path)
      INT_REPLY_DATAREADY_OUT: out std_logic;
      INT_REPLY_DATA_OUT:      out std_logic_vector (15 downto 0); -- Data word
      INT_REPLY_PACKET_NUM_OUT:out std_logic_vector (1 downto 0);
      INT_REPLY_READ_IN:       in  std_logic;
  
      INT_REPLY_DATAREADY_IN:  in  std_logic;
      INT_REPLY_DATA_IN:       in  std_logic_vector (15 downto 0); -- Data word
      INT_REPLY_PACKET_NUM_IN: in  std_logic_vector (1 downto 0);
      INT_REPLY_READ_OUT:      out std_logic;
  
      -- Status and control port
      STAT_GEN:          out std_logic_vector (31 downto 0); -- General Status
      STAT_LOCKED:       out std_logic_vector (31 downto 0); -- Status of the handshake and buffer control
      STAT_INIT_BUFFER:  out std_logic_vector (31 downto 0); -- Status of the handshake and buffer control
      STAT_REPLY_BUFFER: out std_logic_vector (31 downto 0); -- General Status
      CTRL_GEN:          in  std_logic_vector (31 downto 0);
      CTRL_LOCKED:       in  std_logic_vector (31 downto 0);
      STAT_CTRL_INIT_BUFFER:  in  std_logic_vector (31 downto 0);
      STAT_CTRL_REPLY_BUFFER: in  std_logic_vector (31 downto 0)
      );
  end component;
  
  component trb_net16_api_base is
    generic (API_TYPE : integer := API_TYPE;              -- type of api: 0 passive, 1 active
            --FIFO size is given in 2^(n+1) 64Bit-packets i.e. 2^(n+3) 16bit packets
            FIFO_TO_INT_DEPTH : integer := 1;     -- direction to medium
            FIFO_TO_APL_DEPTH : integer := 1;     -- direction to application
            FIFO_TERM_BUFFER_DEPTH  : integer := 0);  -- fifo for auto-answering master path
                                                  -- if set to 0, no buffer is used
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      -- APL Transmitter port
      APL_DATA_IN           : in  std_logic_vector (15 downto 0); -- Data word "application to network"
      APL_PACKET_NUM_IN     : in  std_logic_vector (1 downto 0);
      APL_WRITE_IN          : in  std_logic; -- Data word is valid and should be transmitted
      APL_FIFO_FULL_OUT     : out std_logic; -- Stop transfer, the fifo is full
      APL_SHORT_TRANSFER_IN : in  std_logic; --
      APL_DTYPE_IN          : in  std_logic_vector (3 downto 0);  -- see NewTriggerBusNetworkDescr
      APL_ERROR_PATTERN_IN  : in  std_logic_vector (31 downto 0); -- see NewTriggerBusNetworkDescr
      APL_SEND_IN           : in  std_logic; -- Release sending of the data
      APL_TARGET_ADDRESS_IN : in  std_logic_vector (15 downto 0); -- Address of
      -- Receiver port
      APL_DATA_OUT          : out std_logic_vector (15 downto 0); -- Data word "network to application"
      APL_PACKET_NUM_OUT    : out std_logic_vector (1 downto 0);
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
      INT_MASTER_DATA_OUT       : out std_logic_vector (15 downto 0); -- Data word
      INT_MASTER_PACKET_NUM_OUT : out std_logic_vector (1 downto 0);
      INT_MASTER_READ_IN        : in  std_logic;
      INT_MASTER_DATAREADY_IN   : in  std_logic;
      INT_MASTER_DATA_IN        : in  std_logic_vector (15 downto 0); -- Data word
      INT_MASTER_PACKET_NUM_IN  : in  std_logic_vector (1 downto 0);
      INT_MASTER_READ_OUT       : out std_logic;
      INT_SLAVE_HEADER_IN       : in  std_logic; -- Concentrator kindly asks to resend the last HDR
      INT_SLAVE_DATAREADY_OUT   : out std_logic;
      INT_SLAVE_DATA_OUT        : out std_logic_vector (15 downto 0); -- Data word
      INT_SLAVE_PACKET_NUM_OUT  : out std_logic_vector (1 downto 0);
      INT_SLAVE_READ_IN         : in  std_logic;
      INT_SLAVE_DATAREADY_IN    : in  std_logic;
      INT_SLAVE_DATA_IN         : in  std_logic_vector (15 downto 0); -- Data word
      INT_SLAVE_PACKET_NUM_IN   : in  std_logic_vector (1 downto 0);
      INT_SLAVE_READ_OUT        : out std_logic;
      -- Status and control port
      STAT_FIFO_TO_INT          : out std_logic_vector(31 downto 0);
      STAT_FIFO_TO_APL          : out std_logic_vector(31 downto 0)
      );
  end component;

  component trb_net16_term is
    generic (
      USE_APL_PORT : integer range 0 to 1 := 1;
      SECURE_MODE  : integer range 0 to 1 := 0
               --if secure_mode is not used, apl must provide error pattern and dtype until
               --next trigger comes in. In secure mode these must be available when hold_trm goes low
       );
    port(
      --  Misc
      CLK    : in std_logic;      
      RESET  : in std_logic;    
      CLK_EN : in std_logic;
      INT_DATAREADY_OUT:     out std_logic;
      INT_DATA_OUT:          out std_logic_vector (15 downto 0); -- Data word
      INT_PACKET_NUM_OUT:    out std_logic_vector (1 downto 0);
      INT_READ_IN:           in  std_logic;
      INT_DATAREADY_IN:      in  std_logic;
      INT_DATA_IN:           in  std_logic_vector (15 downto 0); -- Data word
      INT_PACKET_NUM_IN:     in  std_logic_vector (1 downto 0);
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

  component trb_net16_io_multiplexer is
    generic (
      DATA_WIDTH : integer := 16;
      NUM_WIDTH : integer := 2;
      MUX_WIDTH : integer range 1 to 5 := 3;
      MUX_SECURE_MODE : integer range 0 to 1 := 0 --use sbufs or not?
      );
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      --  Media direction port
      MED_DATAREADY_IN:  in  std_logic;
      MED_DATA_IN:       in  std_logic_vector (DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN: in  std_logic_vector (NUM_WIDTH-1 downto 0);
      MED_READ_OUT:      out std_logic;
      MED_DATAREADY_OUT: out std_logic;
      MED_DATA_OUT:      out std_logic_vector (DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT:out std_logic_vector (NUM_WIDTH-1 downto 0);
      MED_READ_IN:       in  std_logic;
      -- Internal direction port
      INT_DATAREADY_OUT: out std_logic_vector (2**MUX_WIDTH-1 downto 0);
      INT_DATA_OUT:      out std_logic_vector ((DATA_WIDTH)*(2**MUX_WIDTH)-1 downto 0);
      INT_PACKET_NUM_OUT:out std_logic_vector (2*(2**MUX_WIDTH)-1 downto 0);
      INT_READ_IN:       in  std_logic_vector (2**MUX_WIDTH-1 downto 0);
      INT_DATAREADY_IN:  in  std_logic_vector (2**MUX_WIDTH-1 downto 0);
      INT_DATA_IN:       in  std_logic_vector ((DATA_WIDTH)*(2**MUX_WIDTH)-1 downto 0);
      INT_PACKET_NUM_IN: in  std_logic_vector (2*(2**MUX_WIDTH)-1 downto 0);
      INT_READ_OUT:      out std_logic_vector (2**MUX_WIDTH-1 downto 0);
      -- Status and control port
      CTRL:              in  std_logic_vector (31 downto 0);
      STAT:              out std_logic_vector (31 downto 0)
      );
  end component;

  component trb_net16_term_buf is
    port(
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      MED_INIT_DATAREADY_OUT:     out std_logic;
      MED_INIT_DATA_OUT:          out std_logic_vector (15 downto 0);
      MED_INIT_PACKET_NUM_OUT:    out std_logic_vector (1 downto 0);
      MED_INIT_READ_IN:           in  std_logic;
      MED_INIT_DATAREADY_IN:      in  std_logic;
      MED_INIT_DATA_IN:           in  std_logic_vector (15 downto 0);
      MED_INIT_PACKET_NUM_IN:     in  std_logic_vector (1 downto 0);
      MED_INIT_READ_OUT:          out std_logic;
      MED_REPLY_DATAREADY_OUT:     out std_logic;
      MED_REPLY_DATA_OUT:          out std_logic_vector (15 downto 0);
      MED_REPLY_PACKET_NUM_OUT:    out std_logic_vector (1 downto 0);
      MED_REPLY_READ_IN:           in  std_logic;
      MED_REPLY_DATAREADY_IN:      in  std_logic;
      MED_REPLY_DATA_IN:           in  std_logic_vector (15 downto 0);
      MED_REPLY_PACKET_NUM_IN:     in  std_logic_vector (1 downto 0);
      MED_REPLY_READ_OUT:          out std_logic
      );
  end component;
signal apl_to_buf_DAT1_INIT_DATAREADY: std_logic;
signal apl_to_buf_DAT1_INIT_DATA     : std_logic_vector (DATA_WIDTH-1 downto 0);
signal apl_to_buf_DAT1_INIT_PACKET_NUM:std_logic_vector (NUM_WIDTH-1 downto 0);
signal apl_to_buf_DAT1_INIT_READ     : std_logic;

signal buf_to_apl_DAT1_INIT_DATAREADY: std_logic;
signal buf_to_apl_DAT1_INIT_DATA     : std_logic_vector (DATA_WIDTH-1 downto 0);
signal buf_to_apl_DAT1_INIT_PACKET_NUM:std_logic_vector (NUM_WIDTH-1 downto 0);
signal buf_to_apl_DAT1_INIT_READ     : std_logic;

signal apl_to_buf_DAT1_REPLY_DATAREADY: std_logic;
signal apl_to_buf_DAT1_REPLY_DATA     : std_logic_vector (DATA_WIDTH-1 downto 0);
signal apl_to_buf_DAT1_REPLY_PACKET_NUM:std_logic_vector (NUM_WIDTH-1 downto 0);
signal apl_to_buf_DAT1_REPLY_READ     : std_logic;

signal buf_to_apl_DAT1_REPLY_DATAREADY: std_logic;
signal buf_to_apl_DAT1_REPLY_DATA     : std_logic_vector (DATA_WIDTH-1 downto 0);
signal buf_to_apl_DAT1_REPLY_PACKET_NUM:std_logic_vector (NUM_WIDTH-1 downto 0);
signal buf_to_apl_DAT1_REPLY_READ     : std_logic;

signal apl_to_buf_DAT2_INIT_DATAREADY: std_logic;
signal apl_to_buf_DAT2_INIT_DATA     : std_logic_vector (DATA_WIDTH-1 downto 0);
signal apl_to_buf_DAT2_INIT_PACKET_NUM:std_logic_vector (NUM_WIDTH-1 downto 0);
signal apl_to_buf_DAT2_INIT_READ     : std_logic;

signal buf_to_apl_DAT2_INIT_DATAREADY: std_logic;
signal buf_to_apl_DAT2_INIT_DATA     : std_logic_vector (DATA_WIDTH-1 downto 0);
signal buf_to_apl_DAT2_INIT_PACKET_NUM:std_logic_vector (NUM_WIDTH-1 downto 0);
signal buf_to_apl_DAT2_INIT_READ     : std_logic;

signal apl_to_buf_DAT2_REPLY_DATAREADY: std_logic;
signal apl_to_buf_DAT2_REPLY_DATA     : std_logic_vector (DATA_WIDTH-1 downto 0);
signal apl_to_buf_DAT2_REPLY_PACKET_NUM:std_logic_vector (NUM_WIDTH-1 downto 0);
signal apl_to_buf_DAT2_REPLY_READ     : std_logic;

signal buf_to_apl_DAT2_REPLY_DATAREADY: std_logic;
signal buf_to_apl_DAT2_REPLY_DATA     : std_logic_vector (DATA_WIDTH-1 downto 0);
signal buf_to_apl_DAT2_REPLY_PACKET_NUM:std_logic_vector (NUM_WIDTH-1 downto 0);
signal buf_to_apl_DAT2_REPLY_READ     : std_logic;

signal apl_to_buf_TRG1_INIT_DATAREADY: std_logic;
signal apl_to_buf_TRG1_INIT_DATA     : std_logic_vector (DATA_WIDTH-1 downto 0);
signal apl_to_buf_TRG1_INIT_PACKET_NUM:std_logic_vector (NUM_WIDTH-1 downto 0);
signal apl_to_buf_TRG1_INIT_READ     : std_logic;

signal buf_to_apl_TRG1_INIT_DATAREADY: std_logic;
signal buf_to_apl_TRG1_INIT_DATA     : std_logic_vector (DATA_WIDTH-1 downto 0);
signal buf_to_apl_TRG1_INIT_PACKET_NUM:std_logic_vector (NUM_WIDTH-1 downto 0);
signal buf_to_apl_TRG1_INIT_READ     : std_logic;

signal apl_to_buf_TRG1_REPLY_DATAREADY: std_logic;
signal apl_to_buf_TRG1_REPLY_DATA     : std_logic_vector (DATA_WIDTH-1 downto 0);
signal apl_to_buf_TRG1_REPLY_PACKET_NUM:std_logic_vector (NUM_WIDTH-1 downto 0);
signal apl_to_buf_TRG1_REPLY_READ     : std_logic;

signal buf_to_apl_TRG1_REPLY_DATAREADY: std_logic;
signal buf_to_apl_TRG1_REPLY_DATA     : std_logic_vector (DATA_WIDTH-1 downto 0);
signal buf_to_apl_TRG1_REPLY_PACKET_NUM:std_logic_vector (NUM_WIDTH-1 downto 0);
signal buf_to_apl_TRG1_REPLY_READ     : std_logic;

signal apl_to_buf_TRG2_INIT_DATAREADY: std_logic;
signal apl_to_buf_TRG2_INIT_DATA     : std_logic_vector (DATA_WIDTH-1 downto 0);
signal apl_to_buf_TRG2_INIT_PACKET_NUM:std_logic_vector (NUM_WIDTH-1 downto 0);
signal apl_to_buf_TRG2_INIT_READ     : std_logic;

signal buf_to_apl_TRG2_INIT_DATAREADY: std_logic;
signal buf_to_apl_TRG2_INIT_DATA     : std_logic_vector (DATA_WIDTH-1 downto 0);
signal buf_to_apl_TRG2_INIT_PACKET_NUM:std_logic_vector (NUM_WIDTH-1 downto 0);
signal buf_to_apl_TRG2_INIT_READ     : std_logic;

signal apl_to_buf_TRG2_REPLY_DATAREADY: std_logic;
signal apl_to_buf_TRG2_REPLY_DATA     : std_logic_vector (DATA_WIDTH-1 downto 0);
signal apl_to_buf_TRG2_REPLY_PACKET_NUM:std_logic_vector (NUM_WIDTH-1 downto 0);
signal apl_to_buf_TRG2_REPLY_READ     : std_logic;

signal buf_to_apl_TRG2_REPLY_DATAREADY: std_logic;
signal buf_to_apl_TRG2_REPLY_DATA     : std_logic_vector (DATA_WIDTH-1 downto 0);
signal buf_to_apl_TRG2_REPLY_PACKET_NUM:std_logic_vector (NUM_WIDTH-1 downto 0);
signal buf_to_apl_TRG2_REPLY_READ     : std_logic;

-- for the connection to the multiplexer
signal MED_DAT1_INIT_DATAREADY_OUT  : std_logic;
signal MED_DAT1_INIT_DATA_OUT       : std_logic_vector (DATA_WIDTH-1 downto 0);
signal MED_DAT1_INIT_PACKET_NUM_OUT : std_logic_vector (NUM_WIDTH-1 downto 0);
signal MED_DAT1_INIT_READ_IN        : std_logic;

signal MED_DAT1_INIT_DATAREADY_IN  : std_logic;
signal MED_DAT1_INIT_DATA_IN       : std_logic_vector (DATA_WIDTH-1 downto 0);
signal MED_DAT1_INIT_PACKET_NUM_IN : std_logic_vector (NUM_WIDTH-1 downto 0);
signal MED_DAT1_INIT_READ_OUT      : std_logic;

signal MED_DAT1_REPLY_DATAREADY_OUT  : std_logic;
signal MED_DAT1_REPLY_DATA_OUT       : std_logic_vector (DATA_WIDTH-1 downto 0);
signal MED_DAT1_REPLY_PACKET_NUM_OUT : std_logic_vector (NUM_WIDTH-1 downto 0);
signal MED_DAT1_REPLY_READ_IN        : std_logic;

signal MED_DAT1_REPLY_DATAREADY_IN  : std_logic;
signal MED_DAT1_REPLY_DATA_IN       : std_logic_vector (DATA_WIDTH-1 downto 0);
signal MED_DAT1_REPLY_PACKET_NUM_IN : std_logic_vector (NUM_WIDTH-1 downto 0);
signal MED_DAT1_REPLY_READ_OUT      : std_logic;

signal MED_DAT2_INIT_DATAREADY_OUT  : std_logic;
signal MED_DAT2_INIT_DATA_OUT       : std_logic_vector (DATA_WIDTH-1 downto 0);
signal MED_DAT2_INIT_PACKET_NUM_OUT : std_logic_vector (NUM_WIDTH-1 downto 0);
signal MED_DAT2_INIT_READ_IN        : std_logic;

signal MED_DAT2_INIT_DATAREADY_IN  : std_logic;
signal MED_DAT2_INIT_DATA_IN       : std_logic_vector (DATA_WIDTH-1 downto 0);
signal MED_DAT2_INIT_PACKET_NUM_IN : std_logic_vector (NUM_WIDTH-1 downto 0);
signal MED_DAT2_INIT_READ_OUT      : std_logic;

signal MED_DAT2_REPLY_DATAREADY_OUT  : std_logic;
signal MED_DAT2_REPLY_DATA_OUT       : std_logic_vector (DATA_WIDTH-1 downto 0);
signal MED_DAT2_REPLY_PACKET_NUM_OUT : std_logic_vector (NUM_WIDTH-1 downto 0);
signal MED_DAT2_REPLY_READ_IN        : std_logic;

signal MED_DAT2_REPLY_DATAREADY_IN  : std_logic;
signal MED_DAT2_REPLY_DATA_IN       : std_logic_vector (DATA_WIDTH-1 downto 0);
signal MED_DAT2_REPLY_PACKET_NUM_IN : std_logic_vector (NUM_WIDTH-1 downto 0);
signal MED_DAT2_REPLY_READ_OUT      : std_logic;

signal MED_TRG1_INIT_DATAREADY_OUT  : std_logic_vector(1 downto 0);
signal MED_TRG1_INIT_DATA_OUT       : std_logic_vector (DATA_WIDTH*2-1 downto 0);
signal MED_TRG1_INIT_PACKET_NUM_OUT : std_logic_vector (NUM_WIDTH*2-1 downto 0);
signal MED_TRG1_INIT_READ_IN        : std_logic_vector(1 downto 0);

signal MED_TRG1_INIT_DATAREADY_IN  : std_logic_vector(1 downto 0);
signal MED_TRG1_INIT_DATA_IN       : std_logic_vector (DATA_WIDTH*2-1 downto 0);
signal MED_TRG1_INIT_PACKET_NUM_IN : std_logic_vector (NUM_WIDTH*2-1 downto 0);
signal MED_TRG1_INIT_READ_OUT      : std_logic_vector(1 downto 0);

signal MED_TRG1_REPLY_DATAREADY_OUT  : std_logic_vector(1 downto 0);
signal MED_TRG1_REPLY_DATA_OUT       : std_logic_vector (DATA_WIDTH*2-1 downto 0);
signal MED_TRG1_REPLY_PACKET_NUM_OUT : std_logic_vector (NUM_WIDTH*2-1 downto 0);
signal MED_TRG1_REPLY_READ_IN        : std_logic_vector(1 downto 0);

signal MED_TRG1_REPLY_DATAREADY_IN  : std_logic_vector(1 downto 0);
signal MED_TRG1_REPLY_DATA_IN       : std_logic_vector (DATA_WIDTH*2-1 downto 0);
signal MED_TRG1_REPLY_PACKET_NUM_IN : std_logic_vector (NUM_WIDTH*2-1 downto 0);
signal MED_TRG1_REPLY_READ_OUT      : std_logic_vector(1 downto 0);

signal MED_TRG2_INIT_DATAREADY_OUT  : std_logic_vector(1 downto 0);
signal MED_TRG2_INIT_DATA_OUT       : std_logic_vector (DATA_WIDTH*2-1 downto 0);
signal MED_TRG2_INIT_PACKET_NUM_OUT : std_logic_vector (NUM_WIDTH*2-1 downto 0);
signal MED_TRG2_INIT_READ_IN        : std_logic_vector(1 downto 0);

signal MED_TRG2_INIT_DATAREADY_IN  : std_logic_vector(1 downto 0);
signal MED_TRG2_INIT_DATA_IN       : std_logic_vector (DATA_WIDTH*2-1 downto 0);
signal MED_TRG2_INIT_PACKET_NUM_IN : std_logic_vector (NUM_WIDTH*2-1 downto 0);
signal MED_TRG2_INIT_READ_OUT      : std_logic_vector(1 downto 0);

signal MED_TRG2_REPLY_DATAREADY_OUT  : std_logic_vector(1 downto 0);
signal MED_TRG2_REPLY_DATA_OUT       : std_logic_vector (DATA_WIDTH*2-1 downto 0);
signal MED_TRG2_REPLY_PACKET_NUM_OUT : std_logic_vector (NUM_WIDTH*2-1 downto 0);
signal MED_TRG2_REPLY_READ_IN        : std_logic_vector(1 downto 0);

signal MED_TRG2_REPLY_DATAREADY_IN  : std_logic_vector(1 downto 0);
signal MED_TRG2_REPLY_DATA_IN       : std_logic_vector (DATA_WIDTH*2-1 downto 0);
signal MED_TRG2_REPLY_PACKET_NUM_IN : std_logic_vector (NUM_WIDTH*2-1 downto 0);
signal MED_TRG2_REPLY_READ_OUT      : std_logic_vector(1 downto 0);

signal m_DATAREADY_OUT : std_logic_vector (2**MUX_WIDTH-1 downto 0);
signal m_DATA_OUT      : std_logic_vector (DATA_WIDTH*2**MUX_WIDTH-1 downto 0);
signal m_PACKET_NUM_OUT: std_logic_vector (NUM_WIDTH*2**MUX_WIDTH-1 downto 0);
signal m_READ_IN       : std_logic_vector (2**MUX_WIDTH-1 downto 0);

signal m_DATAREADY_IN  : std_logic_vector (2**MUX_WIDTH-1 downto 0);
signal m_DATA_IN       : std_logic_vector (DATA_WIDTH**MUX_WIDTH-1 downto 0);
signal m_PACKET_NUM_IN : std_logic_vector (NUM_WIDTH*2**MUX_WIDTH-1 downto 0);
signal m_READ_OUT      : std_logic_vector (2**MUX_WIDTH-1 downto 0);

begin

  --Connections for data and trigger channel
    genmuxcon : for i in 0 to 2**(MUX_WIDTH-1)-1 generate
      gendat1: if i = DAT1_CHANNEL generate
        m_DATAREADY_OUT(i*2) <= MED_DAT1_INIT_DATAREADY_OUT;
        m_DATAREADY_OUT(i*2+1) <= MED_DAT1_REPLY_DATAREADY_OUT;
        m_DATA_OUT((i*2+1)*DATA_WIDTH-1 downto i*DATA_WIDTH*2) <= MED_DAT1_INIT_DATA_OUT;
        m_DATA_OUT((i*2+2)*DATA_WIDTH-1 downto (i*2+1)*DATA_WIDTH) <= MED_DAT1_REPLY_DATA_OUT;
        m_PACKET_NUM_OUT(i*NUM_WIDTH*2+1 downto i*NUM_WIDTH*2) <= MED_DAT1_INIT_PACKET_NUM_OUT;
        m_PACKET_NUM_OUT(i*NUM_WIDTH*2+3 downto i*NUM_WIDTH*2+2) <= MED_DAT1_REPLY_PACKET_NUM_OUT;
        MED_DAT1_INIT_READ_IN <= m_READ_IN(i*2);
        MED_DAT1_REPLY_READ_IN <= m_READ_IN(i*2+1);
        MED_DAT1_INIT_DATAREADY_IN <= m_DATAREADY_IN(i*2);
        MED_DAT1_REPLY_DATAREADY_IN <= m_DATAREADY_IN(i*2+1);
        MED_DAT1_INIT_DATA_IN <= m_DATA_IN((i*2+1)*DATA_WIDTH-1 downto i*DATA_WIDTH*2);
        MED_DAT1_REPLY_DATA_IN <= m_DATA_IN((i*2+2)*DATA_WIDTH-1 downto (i*2+1)*DATA_WIDTH);
        MED_DAT1_INIT_PACKET_NUM_IN <= m_PACKET_NUM_IN(i*NUM_WIDTH*2+1 downto i*NUM_WIDTH*2);
        MED_DAT1_REPLY_PACKET_NUM_IN <= m_PACKET_NUM_IN(i*NUM_WIDTH*2+3 downto i*NUM_WIDTH*2+2);
        m_READ_OUT(i*2) <= MED_DAT1_INIT_READ_OUT;
        m_READ_OUT(i*2+1) <= MED_DAT1_REPLY_READ_OUT;
      end generate;
      gendat2: if i = DAT2_CHANNEL generate
        m_DATAREADY_OUT(i*2) <= MED_DAT2_INIT_DATAREADY_OUT;
        m_DATAREADY_OUT(i*2+1) <= MED_DAT2_REPLY_DATAREADY_OUT;
        m_DATA_OUT((i*2+1)*DATA_WIDTH-1 downto i*DATA_WIDTH*2) <= MED_DAT2_INIT_DATA_OUT;
        m_DATA_OUT((i*2+2)*DATA_WIDTH-1 downto (i*2+1)*DATA_WIDTH) <= MED_DAT2_REPLY_DATA_OUT;
        m_PACKET_NUM_OUT(i*NUM_WIDTH*2+1 downto i*NUM_WIDTH*2) <= MED_DAT2_INIT_PACKET_NUM_OUT;
        m_PACKET_NUM_OUT(i*NUM_WIDTH*2+3 downto i*NUM_WIDTH*2+2) <= MED_DAT2_REPLY_PACKET_NUM_OUT;
        MED_DAT2_INIT_READ_IN <= m_READ_IN(i*2);
        MED_DAT2_REPLY_READ_IN <= m_READ_IN(i*2+1);
        MED_DAT2_INIT_DATAREADY_IN <= m_DATAREADY_IN(i*2);
        MED_DAT2_REPLY_DATAREADY_IN <= m_DATAREADY_IN(i*2+1);
        MED_DAT2_INIT_DATA_IN <= m_DATA_IN((i*2+1)*DATA_WIDTH-1 downto i*DATA_WIDTH*2);
        MED_DAT2_REPLY_DATA_IN <= m_DATA_IN((i*2+2)*DATA_WIDTH-1 downto (i*2+1)*DATA_WIDTH);
        MED_DAT2_INIT_PACKET_NUM_IN <= m_PACKET_NUM_IN(i*NUM_WIDTH*2+1 downto i*NUM_WIDTH*2);
        MED_DAT2_REPLY_PACKET_NUM_IN <= m_PACKET_NUM_IN(i*NUM_WIDTH*2+3 downto i*NUM_WIDTH*2+2);
        m_READ_OUT(i*2) <= MED_DAT2_INIT_READ_OUT;
        m_READ_OUT(i*2+1) <= MED_DAT2_REPLY_READ_OUT;
      end generate;
      gentrg1: if i = TRG1_CHANNEL generate
        m_DATAREADY_OUT(i*2) <= MED_TRG1_INIT_DATAREADY_OUT;
        m_DATAREADY_OUT(i*2+1) <= MED_TRG1_REPLY_DATAREADY_OUT;
        m_DATA_OUT((i*2+1)*DATA_WIDTH-1 downto i*DATA_WIDTH*2) <= MED_TRG1_INIT_DATA_OUT;
        m_DATA_OUT((i*2+2)*DATA_WIDTH-1 downto (i*2+1)*DATA_WIDTH) <= MED_TRG1_REPLY_DATA_OUT;
        m_PACKET_NUM_OUT(i*NUM_WIDTH*2+1 downto i*NUM_WIDTH*2) <= MED_TRG1_INIT_PACKET_NUM_OUT;
        m_PACKET_NUM_OUT(i*NUM_WIDTH*2+3 downto i*NUM_WIDTH*2+2) <= MED_TRG1_REPLY_PACKET_NUM_OUT;
        MED_TRG1_INIT_READ_IN <= m_READ_IN(i*2);
        MED_TRG1_REPLY_READ_IN <= m_READ_IN(i*2+1);
        MED_TRG1_INIT_DATAREADY_IN <= m_DATAREADY_IN(i*2);
        MED_TRG1_REPLY_DATAREADY_IN <= m_DATAREADY_IN(i*2+1);
        MED_TRG1_INIT_DATA_IN <= m_DATA_IN((i*2+1)*DATA_WIDTH-1 downto i*DATA_WIDTH*2);
        MED_TRG1_REPLY_DATA_IN <= m_DATA_IN((i*2+2)*DATA_WIDTH-1 downto (i*2+1)*DATA_WIDTH);
        MED_TRG1_INIT_PACKET_NUM_IN <= m_PACKET_NUM_IN(i*NUM_WIDTH*2+1 downto i*NUM_WIDTH*2);
        MED_TRG1_REPLY_PACKET_NUM_IN <= m_PACKET_NUM_IN(i*NUM_WIDTH*2+3 downto i*NUM_WIDTH*2+2);
        m_READ_OUT(i*2) <= MED_TRG1_INIT_READ_OUT;
        m_READ_OUT(i*2+1) <= MED_TRG1_REPLY_READ_OUT;
      end generate;
      gentrg1: if i = TRG2_CHANNEL generate
        m_DATAREADY_OUT(i*2) <= MED_TRG2_INIT_DATAREADY_OUT;
        m_DATAREADY_OUT(i*2+1) <= MED_TRG2_REPLY_DATAREADY_OUT;
        m_DATA_OUT((i*2+1)*DATA_WIDTH-1 downto i*DATA_WIDTH*2) <= MED_TRG2_INIT_DATA_OUT;
        m_DATA_OUT((i*2+2)*DATA_WIDTH-1 downto (i*2+1)*DATA_WIDTH) <= MED_TRG2_REPLY_DATA_OUT;
        m_PACKET_NUM_OUT(i*NUM_WIDTH*2+1 downto i*NUM_WIDTH*2) <= MED_TRG2_INIT_PACKET_NUM_OUT;
        m_PACKET_NUM_OUT(i*NUM_WIDTH*2+3 downto i*NUM_WIDTH*2+2) <= MED_TRG2_REPLY_PACKET_NUM_OUT;
        MED_TRG2_INIT_READ_IN <= m_READ_IN(i*2);
        MED_TRG2_REPLY_READ_IN <= m_READ_IN(i*2+1);
        MED_TRG2_INIT_DATAREADY_IN <= m_DATAREADY_IN(i*2);
        MED_TRG2_REPLY_DATAREADY_IN <= m_DATAREADY_IN(i*2+1);
        MED_TRG2_INIT_DATA_IN <= m_DATA_IN((i*2+1)*DATA_WIDTH-1 downto i*DATA_WIDTH*2);
        MED_TRG2_REPLY_DATA_IN <= m_DATA_IN((i*2+2)*DATA_WIDTH-1 downto (i*2+1)*DATA_WIDTH);
        MED_TRG2_INIT_PACKET_NUM_IN <= m_PACKET_NUM_IN(i*NUM_WIDTH*2+1 downto i*NUM_WIDTH*2);
        MED_TRG2_REPLY_PACKET_NUM_IN <= m_PACKET_NUM_IN(i*NUM_WIDTH*2+3 downto i*NUM_WIDTH*2+2);
        m_READ_OUT(i*2) <= MED_TRG2_INIT_READ_OUT;
        m_READ_OUT(i*2+1) <= MED_TRG2_REPLY_READ_OUT;
      end generate;
      genelse: if i /= DAT1_CHANNEL and i /= DAT2_CHANNEL and i /= TRG1_CHANNEL and  i /= TRG2_CHANNEL generate
        termbuf: trb_net16_term_buf
          port map(
            CLK    => CLK,
            RESET  => RESET,
            CLK_EN => CLK_EN,
            MED_INIT_DATAREADY_OUT      => m_DATAREADY_OUT(i*2),
            MED_INIT_DATA_OUT           => m_DATA_OUT((i*2+1)*DATA_WIDTH-1 downto i*DATA_WIDTH*2),
            MED_INIT_PACKET_NUM_OUT     => m_PACKET_NUM_OUT(i*NUM_WIDTH*2+1 downto i*NUM_WIDTH*2),
            MED_INIT_READ_IN            => m_READ_IN(i*2),
            MED_INIT_DATAREADY_IN       => m_DATAREADY_IN(i*2),
            MED_INIT_DATA_IN            => m_DATA_IN((i*2+1)*DATA_WIDTH-1 downto i*DATA_WIDTH*2),
            MED_INIT_PACKET_NUM_IN      => m_PACKET_NUM_IN(i*NUM_WIDTH*2+1 downto i*NUM_WIDTH*2),
            MED_INIT_READ_OUT           => m_READ_OUT(i*2),

            MED_REPLY_DATAREADY_OUT      => m_DATAREADY_OUT(i*2+1),
            MED_REPLY_DATA_OUT           => m_DATA_OUT((i*2+2)*DATA_WIDTH-1 downto (i*2+1)*DATA_WIDTH),
            MED_REPLY_PACKET_NUM_OUT     => m_PACKET_NUM_OUT(i*NUM_WIDTH*2+3 downto i*NUM_WIDTH*2+2),
            MED_REPLY_READ_IN            => m_READ_IN(i*2+1),
            MED_REPLY_DATAREADY_IN       => m_DATAREADY_IN(i*2+1),
            MED_REPLY_DATA_IN            => m_DATA_IN((i*2+2)*DATA_WIDTH-1 downto (i*2+1)*DATA_WIDTH),
            MED_REPLY_PACKET_NUM_IN      => m_PACKET_NUM_IN(i*NUM_WIDTH*2+3 downto i*NUM_WIDTH*2+2),
            MED_REPLY_READ_OUT           => m_READ_OUT(i*2+1)
            );
      end generate;
    end generate;

  gen_actapi1: if API1_TYPE = 1 generate
    DAT_ACTIVE_API1: trb_net16_api_base
      generic map (
        API_TYPE => 1,
        FIFO_TO_INT_DEPTH => DAT1_FIFO_TO_INT_DEPTH,
        FIFO_TO_APL_DEPTH => DAT1_FIFO_TO_APL_DEPTH,
        FIFO_TERM_BUFFER_DEPTH => 0
        )
      port map (
        --  Misc
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        -- APL Transmitter port
        APL_DATA_IN           => APL1_DATA_IN,
        APL_PACKET_NUM_IN     => APL1_PACKET_NUM_IN,
        APL_WRITE_IN          => APL1_WRITE_IN,
        APL_FIFO_FULL_OUT     => APL1_FIFO_FULL_OUT,
        APL_SHORT_TRANSFER_IN => APL1_SHORT_TRANSFER_IN,
        APL_DTYPE_IN          => APL1_DTYPE_IN,
        APL_ERROR_PATTERN_IN  => APL1_ERROR_PATTERN_IN,
        APL_SEND_IN           => APL1_SEND_IN,
        APL_TARGET_ADDRESS_IN => APL1_TARGET_ADDRESS_IN,
        -- Receiver port
        APL_DATA_OUT      => APL1_DATA_OUT,
        APL_PACKET_NUM_OUT=> APL1_PACKET_NUM_OUT,
        APL_TYP_OUT       => APL1_TYP_OUT,
        APL_DATAREADY_OUT => APL1_DATAREADY_OUT,
        APL_READ_IN       => APL1_READ_IN,
        -- APL Control port
        APL_RUN_OUT       => APL1_RUN_OUT,
        APL_MY_ADDRESS_IN => APL1_MY_ADDRESS_IN,
        APL_SEQNR_OUT     => APL1_SEQNR_OUT,
        -- Internal direction port
        INT_MASTER_DATAREADY_OUT => apl_to_buf_DAT1_INIT_DATAREADY,
        INT_MASTER_DATA_OUT      => apl_to_buf_DAT1_INIT_DATA,
        INT_MASTER_PACKET_NUM_OUT=> apl_to_buf_DAT1_INIT_PACKET_NUM,
        INT_MASTER_READ_IN       => apl_to_buf_DAT1_INIT_READ,
        INT_MASTER_DATAREADY_IN  => buf_to_apl_DAT1_INIT_DATAREADY,
        INT_MASTER_DATA_IN       => buf_to_apl_DAT1_INIT_DATA,
        INT_MASTER_PACKET_NUM_IN => buf_to_apl_DAT1_INIT_PACKET_NUM,
        INT_MASTER_READ_OUT      => buf_to_apl_DAT1_INIT_READ,
        INT_SLAVE_HEADER_IN      => '0',
        INT_SLAVE_DATAREADY_OUT  => apl_to_buf_DAT1_REPLY_DATAREADY,
        INT_SLAVE_DATA_OUT       => apl_to_buf_DAT1_REPLY_DATA,
        INT_SLAVE_PACKET_NUM_OUT => apl_to_buf_DAT1_REPLY_PACKET_NUM,
        INT_SLAVE_READ_IN        => apl_to_buf_DAT1_REPLY_READ,
        INT_SLAVE_DATAREADY_IN => buf_to_apl_DAT1_REPLY_DATAREADY,
        INT_SLAVE_DATA_IN      => buf_to_apl_DAT1_REPLY_DATA,
        INT_SLAVE_PACKET_NUM_IN=> buf_to_apl_DAT1_REPLY_PACKET_NUM,
        INT_SLAVE_READ_OUT     => buf_to_apl_DAT1_REPLY_READ,
        -- Status and control port
        STAT_FIFO_TO_INT => DAT1_api_stat_fifo_to_int,
        STAT_FIFO_TO_APL => DAT1_api_stat_fifo_to_apl
        );
  end generate;

  gen_pasapi1: if API1_TYPE = 0 generate
    DAT_PASSIVE_API1: trb_net16_api_base
      generic map (
        API_TYPE => 0,
        FIFO_TO_INT_DEPTH => DAT1_FIFO_TO_INT_DEPTH,
        FIFO_TO_APL_DEPTH => DAT1_FIFO_TO_APL_DEPTH,
        FIFO_TERM_BUFFER_DEPTH => 0
        )
      port map (
        --  Misc
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        -- APL Transmitter port
        APL_DATA_IN           => APL1_DATA_IN,
        APL_PACKET_NUM_IN     => APL1_PACKET_NUM_IN,
        APL_WRITE_IN          => APL1_WRITE_IN,
        APL_FIFO_FULL_OUT     => APL1_FIFO_FULL_OUT,
        APL_SHORT_TRANSFER_IN => APL1_SHORT_TRANSFER_IN,
        APL_DTYPE_IN          => APL1_DTYPE_IN,
        APL_ERROR_PATTERN_IN  => APL1_ERROR_PATTERN_IN,
        APL_SEND_IN           => APL1_SEND_IN,
        APL_TARGET_ADDRESS_IN => (others => '0'),
        -- Receiver port
        APL_DATA_OUT      => APL1_DATA_OUT,
        APL_PACKET_NUM_OUT=> APL1_PACKET_NUM_OUT,
        APL_TYP_OUT       => APL1_TYP_OUT,
        APL_DATAREADY_OUT => APL1_DATAREADY_OUT,
        APL_READ_IN       => APL1_READ_IN,
        -- APL Control port
        APL_RUN_OUT       => APL1_RUN_OUT,
        APL_MY_ADDRESS_IN => APL1_MY_ADDRESS_IN,
        APL_SEQNR_OUT     => APL1_SEQNR_OUT,
        -- Internal direction port
        INT_MASTER_DATAREADY_OUT => apl_to_buf_DAT1_REPLY_DATAREADY,
        INT_MASTER_DATA_OUT      => apl_to_buf_DAT1_REPLY_DATA,
        INT_MASTER_PACKET_NUM_OUT=> apl_to_buf_DAT1_REPLY_PACKET_NUM,
        INT_MASTER_READ_IN       => apl_to_buf_DAT1_REPLY_READ,
        INT_MASTER_DATAREADY_IN  => buf_to_apl_DAT1_REPLY_DATAREADY,
        INT_MASTER_DATA_IN       => buf_to_apl_DAT1_REPLY_DATA,
        INT_MASTER_PACKET_NUM_IN => buf_to_apl_DAT1_REPLY_PACKET_NUM,
        INT_MASTER_READ_OUT      => buf_to_apl_DAT1_REPLY_READ,
        INT_SLAVE_HEADER_IN      => '0',
        INT_SLAVE_DATAREADY_OUT  => apl_to_buf_DAT1_INIT_DATAREADY,
        INT_SLAVE_DATA_OUT       => apl_to_buf_DAT1_INIT_DATA,
        INT_SLAVE_PACKET_NUM_OUT => apl_to_buf_DAT1_INIT_PACKET_NUM,
        INT_SLAVE_READ_IN        => apl_to_buf_DAT1_INIT_READ,
        INT_SLAVE_DATAREADY_IN => buf_to_apl_DAT1_INIT_DATAREADY,
        INT_SLAVE_DATA_IN      => buf_to_apl_DAT1_INIT_DATA,
        INT_SLAVE_PACKET_NUM_IN=> buf_to_apl_DAT1_INIT_PACKET_NUM,
        INT_SLAVE_READ_OUT     => buf_to_apl_DAT1_INIT_READ,
        -- Status and control port
        STAT_FIFO_TO_INT => DAT1_api_stat_fifo_to_int,
        STAT_FIFO_TO_APL => DAT1_api_stat_fifo_to_apl
        );
  end generate;

STAT_DAT1_api_control_signals(2 downto 0)  <= APL1_DATA_IN(2 downto 0);
STAT_DAT1_api_control_signals(3)           <= APL1_WRITE_IN;
STAT_DAT1_api_control_signals(4)           <= APL1_SEND_IN;
STAT_DAT1_api_control_signals(7 downto 5)  <= (others => '0');
STAT_DAT1_api_control_signals(10 downto 8) <= apl_to_buf_DAT1_INIT_DATA(2 downto 0);
STAT_DAT1_api_control_signals(11)           <= apl_to_buf_DAT1_INIT_DATAREADY;
STAT_DAT1_api_control_signals(12)           <= apl_to_buf_DAT1_INIT_READ;
STAT_DAT1_api_control_signals(31 downto 13) <= (others => '0');

  gen_actapi2: if API2_TYPE = 1 generate
    DAT_ACTIVE_API1: trb_net16_api_base
      generic map (
        API_TYPE => 1,
        FIFO_TO_INT_DEPTH => DAT2_FIFO_TO_INT_DEPTH,
        FIFO_TO_APL_DEPTH => DAT2_FIFO_TO_APL_DEPTH,
        FIFO_TERM_BUFFER_DEPTH => 0
        )
      port map (
        --  Misc
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        -- APL Transmitter port
        APL_DATA_IN           => APL2_DATA_IN,
        APL_PACKET_NUM_IN     => APL2_PACKET_NUM_IN,
        APL_WRITE_IN          => APL2_WRITE_IN,
        APL_FIFO_FULL_OUT     => APL2_FIFO_FULL_OUT,
        APL_SHORT_TRANSFER_IN => APL2_SHORT_TRANSFER_IN,
        APL_DTYPE_IN          => APL2_DTYPE_IN,
        APL_ERROR_PATTERN_IN  => APL2_ERROR_PATTERN_IN,
        APL_SEND_IN           => APL2_SEND_IN,
        APL_TARGET_ADDRESS_IN => APL2_TARGET_ADDRESS_IN,
        -- Receiver port
        APL_DATA_OUT      => APL2_DATA_OUT,
        APL_PACKET_NUM_OUT=> APL2_PACKET_NUM_OUT,
        APL_TYP_OUT       => APL2_TYP_OUT,
        APL_DATAREADY_OUT => APL2_DATAREADY_OUT,
        APL_READ_IN       => APL2_READ_IN,
        -- APL Control port
        APL_RUN_OUT       => APL2_RUN_OUT,
        APL_MY_ADDRESS_IN => APL2_MY_ADDRESS_IN,
        APL_SEQNR_OUT     => APL2_SEQNR_OUT,
        -- Internal direction port
        INT_MASTER_DATAREADY_OUT => apl_to_buf_DAT2_INIT_DATAREADY,
        INT_MASTER_DATA_OUT      => apl_to_buf_DAT2_INIT_DATA,
        INT_MASTER_PACKET_NUM_OUT=> apl_to_buf_DAT2_INIT_PACKET_NUM,
        INT_MASTER_READ_IN       => apl_to_buf_DAT2_INIT_READ,
        INT_MASTER_DATAREADY_IN  => buf_to_apl_DAT2_INIT_DATAREADY,
        INT_MASTER_DATA_IN       => buf_to_apl_DAT2_INIT_DATA,
        INT_MASTER_PACKET_NUM_IN => buf_to_apl_DAT2_INIT_PACKET_NUM,
        INT_MASTER_READ_OUT      => buf_to_apl_DAT2_INIT_READ,
        INT_SLAVE_HEADER_IN      => '0',
        INT_SLAVE_DATAREADY_OUT  => apl_to_buf_DAT2_REPLY_DATAREADY,
        INT_SLAVE_DATA_OUT       => apl_to_buf_DAT2_REPLY_DATA,
        INT_SLAVE_PACKET_NUM_OUT => apl_to_buf_DAT2_REPLY_PACKET_NUM,
        INT_SLAVE_READ_IN        => apl_to_buf_DAT2_REPLY_READ,
        INT_SLAVE_DATAREADY_IN => buf_to_apl_DAT2_REPLY_DATAREADY,
        INT_SLAVE_DATA_IN      => buf_to_apl_DAT2_REPLY_DATA,
        INT_SLAVE_PACKET_NUM_IN=> buf_to_apl_DAT2_REPLY_PACKET_NUM,
        INT_SLAVE_READ_OUT     => buf_to_apl_DAT2_REPLY_READ,
        -- Status and control port
        STAT_FIFO_TO_INT => DAT2_api_stat_fifo_to_int,
        STAT_FIFO_TO_APL => DAT2_api_stat_fifo_to_apl
        );
  end generate;

  gen_pasapi2: if API2_TYPE = 0 generate
    DAT_PASSIVE_API1: trb_net16_api_base
      generic map (
        API_TYPE => 0,
        FIFO_TO_INT_DEPTH => DAT2_FIFO_TO_INT_DEPTH,
        FIFO_TO_APL_DEPTH => DAT2_FIFO_TO_APL_DEPTH,
        FIFO_TERM_BUFFER_DEPTH => 0
        )
      port map (
        --  Misc
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        -- APL Transmitter port
        APL_DATA_IN           => APL2_DATA_IN,
        APL_PACKET_NUM_IN     => APL2_PACKET_NUM_IN,
        APL_WRITE_IN          => APL2_WRITE_IN,
        APL_FIFO_FULL_OUT     => APL2_FIFO_FULL_OUT,
        APL_SHORT_TRANSFER_IN => APL2_SHORT_TRANSFER_IN,
        APL_DTYPE_IN          => APL2_DTYPE_IN,
        APL_ERROR_PATTERN_IN  => APL2_ERROR_PATTERN_IN,
        APL_SEND_IN           => APL2_SEND_IN,
        APL_TARGET_ADDRESS_IN => (others => '0'),
        -- Receiver port
        APL_DATA_OUT      => APL2_DATA_OUT,
        APL_PACKET_NUM_OUT=> APL2_PACKET_NUM_OUT,
        APL_TYP_OUT       => APL2_TYP_OUT,
        APL_DATAREADY_OUT => APL2_DATAREADY_OUT,
        APL_READ_IN       => APL2_READ_IN,
        -- APL Control port
        APL_RUN_OUT       => APL2_RUN_OUT,
        APL_MY_ADDRESS_IN => APL2_MY_ADDRESS_IN,
        APL_SEQNR_OUT     => APL2_SEQNR_OUT,
        -- Internal direction port
        INT_MASTER_DATAREADY_OUT => apl_to_buf_DAT2_REPLY_DATAREADY,
        INT_MASTER_DATA_OUT      => apl_to_buf_DAT2_REPLY_DATA,
        INT_MASTER_PACKET_NUM_OUT=> apl_to_buf_DAT2_REPLY_PACKET_NUM,
        INT_MASTER_READ_IN       => apl_to_buf_DAT2_REPLY_READ,
        INT_MASTER_DATAREADY_IN  => buf_to_apl_DAT2_REPLY_DATAREADY,
        INT_MASTER_DATA_IN       => buf_to_apl_DAT2_REPLY_DATA,
        INT_MASTER_PACKET_NUM_IN => buf_to_apl_DAT2_REPLY_PACKET_NUM,
        INT_MASTER_READ_OUT      => buf_to_apl_DAT2_REPLY_READ,
        INT_SLAVE_HEADER_IN      => '0',
        INT_SLAVE_DATAREADY_OUT  => apl_to_buf_DAT2_INIT_DATAREADY,
        INT_SLAVE_DATA_OUT       => apl_to_buf_DAT2_INIT_DATA,
        INT_SLAVE_PACKET_NUM_OUT => apl_to_buf_DAT2_INIT_PACKET_NUM,
        INT_SLAVE_READ_IN        => apl_to_buf_DAT2_INIT_READ,
        INT_SLAVE_DATAREADY_IN => buf_to_apl_DAT2_INIT_DATAREADY,
        INT_SLAVE_DATA_IN      => buf_to_apl_DAT2_INIT_DATA,
        INT_SLAVE_PACKET_NUM_IN=> buf_to_apl_DAT2_INIT_PACKET_NUM,
        INT_SLAVE_READ_OUT     => buf_to_apl_DAT2_INIT_READ,
        -- Status and control port
        STAT_FIFO_TO_INT => DAT2_api_stat_fifo_to_int,
        STAT_FIFO_TO_APL => DAT2_api_stat_fifo_to_apl
        );
  end generate;

STAT_DAT2_api_control_signals(2 downto 0)  <= APL2_DATA_IN(2 downto 0);
STAT_DAT2_api_control_signals(3)           <= APL2_WRITE_IN;
STAT_DAT2_api_control_signals(4)           <= APL2_SEND_IN;
STAT_DAT2_api_control_signals(7 downto 5)  <= (others => '0');
STAT_DAT2_api_control_signals(10 downto 8) <= apl_to_buf_DAT2_INIT_DATA(2 downto 0);
STAT_DAT2_api_control_signals(11)           <= apl_to_buf_DAT2_INIT_DATAREADY;
STAT_DAT2_api_control_signals(12)           <= apl_to_buf_DAT2_INIT_READ;
STAT_DAT2_api_control_signals(31 downto 13) <= (others => '0');

DAT1_IOBUF: trb_net16_iobuf
  generic map(
    INIT_DEPTH  => DAT1_INIT_DEPTH,
    REPLY_DEPTH => DAT1_REPLY_DEPTH
    )
  port map (
    --  Misc
    CLK     => CLK ,
    RESET   => RESET,
    CLK_EN  => CLK_EN,
    --  Media direction port
    MED_INIT_DATAREADY_OUT  => MED_DAT1_INIT_DATAREADY_OUT,
    MED_INIT_DATA_OUT       => MED_DAT1_INIT_DATA_OUT,
    MED_INIT_PACKET_NUM_OUT => MED_DAT1_INIT_PACKET_NUM_OUT,
    MED_INIT_READ_IN        => MED_DAT1_INIT_READ_IN,
    MED_INIT_DATAREADY_IN   => MED_DAT1_INIT_DATAREADY_IN,
    MED_INIT_DATA_IN        => MED_DAT1_INIT_DATA_IN,
    MED_INIT_PACKET_NUM_IN  => MED_DAT1_INIT_PACKET_NUM_IN,
    MED_INIT_READ_OUT       => MED_DAT1_INIT_READ_OUT,
    MED_INIT_ERROR_IN       => (others => '0'),
    MED_REPLY_DATAREADY_OUT => MED_DAT1_REPLY_DATAREADY_OUT,
    MED_REPLY_DATA_OUT      => MED_DAT1_REPLY_DATA_OUT,
    MED_REPLY_PACKET_NUM_OUT=> MED_DAT1_REPLY_PACKET_NUM_OUT,
    MED_REPLY_READ_IN       => MED_DAT1_REPLY_READ_IN,
    MED_REPLY_DATAREADY_IN  => MED_DAT1_REPLY_DATAREADY_IN,
    MED_REPLY_DATA_IN       => MED_DAT1_REPLY_DATA_IN,
    MED_REPLY_PACKET_NUM_IN => MED_DAT1_REPLY_PACKET_NUM_IN,
    MED_REPLY_READ_OUT      => MED_DAT1_REPLY_READ_OUT,
    MED_REPLY_ERROR_IN      => (others => '0'),
    -- Internal direction port
    INT_INIT_DATAREADY_OUT => buf_to_apl_DAT1_INIT_DATAREADY,
    INT_INIT_DATA_OUT      => buf_to_apl_DAT1_INIT_DATA,
    INT_INIT_PACKET_NUM_OUT=> buf_to_apl_DAT1_INIT_PACKET_NUM,
    INT_INIT_READ_IN       => buf_to_apl_DAT1_INIT_READ,
    INT_INIT_DATAREADY_IN  => apl_to_buf_DAT1_INIT_DATAREADY,
    INT_INIT_DATA_IN       => apl_to_buf_DAT1_INIT_DATA,
    INT_INIT_PACKET_NUM_IN => apl_to_buf_DAT1_INIT_PACKET_NUM,
    INT_INIT_READ_OUT      => apl_to_buf_DAT1_INIT_READ,
    INT_REPLY_HEADER_IN     => '0',
    INT_REPLY_DATAREADY_OUT => buf_to_apl_DAT1_REPLY_DATAREADY,
    INT_REPLY_DATA_OUT      => buf_to_apl_DAT1_REPLY_DATA,
    INT_REPLY_PACKET_NUM_OUT=> buf_to_apl_DAT1_REPLY_PACKET_NUM,
    INT_REPLY_READ_IN       => buf_to_apl_DAT1_REPLY_READ,
    INT_REPLY_DATAREADY_IN  => apl_to_buf_DAT1_REPLY_DATAREADY,
    INT_REPLY_DATA_IN       => apl_to_buf_DAT1_REPLY_DATA,
    INT_REPLY_PACKET_NUM_IN => apl_to_buf_DAT1_REPLY_PACKET_NUM,
    INT_REPLY_READ_OUT      => apl_to_buf_DAT1_REPLY_READ,
    -- Status and control port
    STAT_GEN               => STAT_DAT1_GEN,
    STAT_LOCKED            => STAT_DAT1_LOCKED,
    STAT_INIT_BUFFER       => STAT_DAT1_INIT_BUFFER,
    STAT_REPLY_BUFFER      => STAT_DAT1_REPLY_BUFFER,
    CTRL_GEN               => CTRL_DAT1_GEN,
    CTRL_LOCKED            => CTRL_DAT1_LOCKED,
    STAT_CTRL_INIT_BUFFER  => STAT_DAT1_CTRL_INIT_BUFFER,
    STAT_CTRL_REPLY_BUFFER => STAT_DAT1_CTRL_REPLY_BUFFER
    );

DAT2_IOBUF: trb_net16_iobuf
  generic map(
    INIT_DEPTH  => DAT2_INIT_DEPTH,
    REPLY_DEPTH => DAT2_REPLY_DEPTH
    )
  port map (
    --  Misc
    CLK     => CLK ,
    RESET   => RESET,
    CLK_EN  => CLK_EN,
    --  Media direction port
    MED_INIT_DATAREADY_OUT  => MED_DAT2_INIT_DATAREADY_OUT,
    MED_INIT_DATA_OUT       => MED_DAT2_INIT_DATA_OUT,
    MED_INIT_PACKET_NUM_OUT => MED_DAT2_INIT_PACKET_NUM_OUT,
    MED_INIT_READ_IN        => MED_DAT2_INIT_READ_IN,
    MED_INIT_DATAREADY_IN   => MED_DAT2_INIT_DATAREADY_IN,
    MED_INIT_DATA_IN        => MED_DAT2_INIT_DATA_IN,
    MED_INIT_PACKET_NUM_IN  => MED_DAT2_INIT_PACKET_NUM_IN,
    MED_INIT_READ_OUT       => MED_DAT2_INIT_READ_OUT,
    MED_INIT_ERROR_IN       => (others => '0'),
    MED_REPLY_DATAREADY_OUT => MED_DAT2_REPLY_DATAREADY_OUT,
    MED_REPLY_DATA_OUT      => MED_DAT2_REPLY_DATA_OUT,
    MED_REPLY_PACKET_NUM_OUT=> MED_DAT2_REPLY_PACKET_NUM_OUT,
    MED_REPLY_READ_IN       => MED_DAT2_REPLY_READ_IN,
    MED_REPLY_DATAREADY_IN  => MED_DAT2_REPLY_DATAREADY_IN,
    MED_REPLY_DATA_IN       => MED_DAT2_REPLY_DATA_IN,
    MED_REPLY_PACKET_NUM_IN => MED_DAT2_REPLY_PACKET_NUM_IN,
    MED_REPLY_READ_OUT      => MED_DAT2_REPLY_READ_OUT,
    MED_REPLY_ERROR_IN      => (others => '0'),
    -- Internal direction port
    INT_INIT_DATAREADY_OUT => buf_to_apl_DAT2_INIT_DATAREADY,
    INT_INIT_DATA_OUT      => buf_to_apl_DAT2_INIT_DATA,
    INT_INIT_PACKET_NUM_OUT=> buf_to_apl_DAT2_INIT_PACKET_NUM,
    INT_INIT_READ_IN       => buf_to_apl_DAT2_INIT_READ,
    INT_INIT_DATAREADY_IN  => apl_to_buf_DAT2_INIT_DATAREADY,
    INT_INIT_DATA_IN       => apl_to_buf_DAT2_INIT_DATA,
    INT_INIT_PACKET_NUM_IN => apl_to_buf_DAT2_INIT_PACKET_NUM,
    INT_INIT_READ_OUT      => apl_to_buf_DAT2_INIT_READ,
    INT_REPLY_HEADER_IN     => '0',
    INT_REPLY_DATAREADY_OUT => buf_to_apl_DAT2_REPLY_DATAREADY,
    INT_REPLY_DATA_OUT      => buf_to_apl_DAT2_REPLY_DATA,
    INT_REPLY_PACKET_NUM_OUT=> buf_to_apl_DAT2_REPLY_PACKET_NUM,
    INT_REPLY_READ_IN       => buf_to_apl_DAT2_REPLY_READ,
    INT_REPLY_DATAREADY_IN  => apl_to_buf_DAT2_REPLY_DATAREADY,
    INT_REPLY_DATA_IN       => apl_to_buf_DAT2_REPLY_DATA,
    INT_REPLY_PACKET_NUM_IN => apl_to_buf_DAT2_REPLY_PACKET_NUM,
    INT_REPLY_READ_OUT      => apl_to_buf_DAT2_REPLY_READ,
    -- Status and control port
    STAT_GEN               => STAT_DAT2_GEN,
    STAT_LOCKED            => STAT_DAT2_LOCKED,
    STAT_INIT_BUFFER       => STAT_DAT2_INIT_BUFFER,
    STAT_REPLY_BUFFER      => STAT_DAT2_REPLY_BUFFER,
    CTRL_GEN               => CTRL_DAT2_GEN,
    CTRL_LOCKED            => CTRL_DAT2_LOCKED,
    STAT_CTRL_INIT_BUFFER  => STAT_DAT2_CTRL_INIT_BUFFER,
    STAT_CTRL_REPLY_BUFFER => STAT_DAT2_CTRL_REPLY_BUFFER
    );

  TRG1_IOBUF: trb_net16_iobuf
    generic map(
      INIT_DEPTH  => TRG1_INIT_DEPTH,
      REPLY_DEPTH => TRG1_REPLY_DEPTH
      )
    port map (
      --  Misc
      CLK     => CLK ,
      RESET   => RESET,
      CLK_EN  => CLK_EN,
      --  Media direction port
      MED_INIT_DATAREADY_OUT  => MED_TRG1_INIT_DATAREADY_OUT,
      MED_INIT_DATA_OUT       => MED_TRG1_INIT_DATA_OUT,
      MED_INIT_PACKET_NUM_OUT => MED_TRG1_INIT_PACKET_NUM_OUT,
      MED_INIT_READ_IN        => MED_TRG1_INIT_READ_IN,
      MED_INIT_DATAREADY_IN   => MED_TRG1_INIT_DATAREADY_IN,
      MED_INIT_DATA_IN        => MED_TRG1_INIT_DATA_IN,
      MED_INIT_PACKET_NUM_IN  => MED_TRG1_INIT_PACKET_NUM_IN,
      MED_INIT_READ_OUT       => MED_TRG1_INIT_READ_OUT,
      MED_INIT_ERROR_IN       => (others => '0'),
      MED_REPLY_DATAREADY_OUT => MED_TRG1_REPLY_DATAREADY_OUT,
      MED_REPLY_DATA_OUT      => MED_TRG1_REPLY_DATA_OUT,
      MED_REPLY_PACKET_NUM_OUT=> MED_TRG1_REPLY_PACKET_NUM_OUT,
      MED_REPLY_READ_IN       => MED_TRG1_REPLY_READ_IN,
      MED_REPLY_DATAREADY_IN  => MED_TRG1_REPLY_DATAREADY_IN,
      MED_REPLY_DATA_IN       => MED_TRG1_REPLY_DATA_IN,
      MED_REPLY_PACKET_NUM_IN => MED_TRG1_REPLY_PACKET_NUM_IN,
      MED_REPLY_READ_OUT      => MED_TRG1_REPLY_READ_OUT,
      MED_REPLY_ERROR_IN      => (others => '0'),
      -- Internal direction port
      INT_INIT_DATAREADY_OUT => buf_to_apl_TRG1_INIT_DATAREADY,
      INT_INIT_DATA_OUT      => buf_to_apl_TRG1_INIT_DATA,
      INT_INIT_PACKET_NUM_OUT=> buf_to_apl_TRG1_INIT_PACKET_NUM,
      INT_INIT_READ_IN       => buf_to_apl_TRG1_INIT_READ,
      INT_INIT_DATAREADY_IN  => apl_to_buf_TRG1_INIT_DATAREADY,
      INT_INIT_DATA_IN       => apl_to_buf_TRG1_INIT_DATA,
      INT_INIT_PACKET_NUM_IN => apl_to_buf_TRG1_INIT_PACKET_NUM,
      INT_INIT_READ_OUT      => apl_to_buf_TRG1_INIT_READ,
      INT_REPLY_HEADER_IN     => '0',
      INT_REPLY_DATAREADY_OUT => buf_to_apl_TRG1_REPLY_DATAREADY,
      INT_REPLY_DATA_OUT      => buf_to_apl_TRG1_REPLY_DATA,
      INT_REPLY_PACKET_NUM_OUT=> buf_to_apl_TRG1_REPLY_PACKET_NUM,
      INT_REPLY_READ_IN       => buf_to_apl_TRG1_REPLY_READ,
      INT_REPLY_DATAREADY_IN  => apl_to_buf_TRG1_REPLY_DATAREADY,
      INT_REPLY_DATA_IN       => apl_to_buf_TRG1_REPLY_DATA,
      INT_REPLY_PACKET_NUM_IN => apl_to_buf_TRG1_REPLY_PACKET_NUM,
      INT_REPLY_READ_OUT      => apl_to_buf_TRG1_REPLY_READ,
      -- Status and control port
      STAT_GEN               => STAT_TRG1_GEN,
      STAT_LOCKED            => STAT_TRG1_LOCKED,
      STAT_INIT_BUFFER       => STAT_TRG1_INIT_BUFFER,
      STAT_REPLY_BUFFER      => STAT_TRG1_REPLY_BUFFER,
      CTRL_GEN               => CTRL_TRG1_GEN,
      CTRL_LOCKED            => CTRL_TRG1_LOCKED,
      STAT_CTRL_INIT_BUFFER  => STAT_TRG1_CTRL_INIT_BUFFER,
      STAT_CTRL_REPLY_BUFFER => STAT_TRG1_CTRL_REPLY_BUFFER
      );

  TRG2_IOBUF: trb_net16_iobuf
    generic map(
      INIT_DEPTH  => TRG2_INIT_DEPTH,
      REPLY_DEPTH => TRG2_REPLY_DEPTH
      )
    port map (
      --  Misc
      CLK     => CLK ,
      RESET   => RESET,
      CLK_EN  => CLK_EN,
      --  Media direction port
      MED_INIT_DATAREADY_OUT  => MED_TRG2_INIT_DATAREADY_OUT,
      MED_INIT_DATA_OUT       => MED_TRG2_INIT_DATA_OUT,
      MED_INIT_PACKET_NUM_OUT => MED_TRG2_INIT_PACKET_NUM_OUT,
      MED_INIT_READ_IN        => MED_TRG2_INIT_READ_IN,
      MED_INIT_DATAREADY_IN   => MED_TRG2_INIT_DATAREADY_IN,
      MED_INIT_DATA_IN        => MED_TRG2_INIT_DATA_IN,
      MED_INIT_PACKET_NUM_IN  => MED_TRG2_INIT_PACKET_NUM_IN,
      MED_INIT_READ_OUT       => MED_TRG2_INIT_READ_OUT,
      MED_INIT_ERROR_IN       => (others => '0'),
      MED_REPLY_DATAREADY_OUT => MED_TRG2_REPLY_DATAREADY_OUT,
      MED_REPLY_DATA_OUT      => MED_TRG2_REPLY_DATA_OUT,
      MED_REPLY_PACKET_NUM_OUT=> MED_TRG2_REPLY_PACKET_NUM_OUT,
      MED_REPLY_READ_IN       => MED_TRG2_REPLY_READ_IN,
      MED_REPLY_DATAREADY_IN  => MED_TRG2_REPLY_DATAREADY_IN,
      MED_REPLY_DATA_IN       => MED_TRG2_REPLY_DATA_IN,
      MED_REPLY_PACKET_NUM_IN => MED_TRG2_REPLY_PACKET_NUM_IN,
      MED_REPLY_READ_OUT      => MED_TRG2_REPLY_READ_OUT,
      MED_REPLY_ERROR_IN      => (others => '0'),
      -- Internal direction port
      INT_INIT_DATAREADY_OUT => buf_to_apl_TRG2_INIT_DATAREADY,
      INT_INIT_DATA_OUT      => buf_to_apl_TRG2_INIT_DATA,
      INT_INIT_PACKET_NUM_OUT=> buf_to_apl_TRG2_INIT_PACKET_NUM,
      INT_INIT_READ_IN       => buf_to_apl_TRG2_INIT_READ,
      INT_INIT_DATAREADY_IN  => apl_to_buf_TRG2_INIT_DATAREADY,
      INT_INIT_DATA_IN       => apl_to_buf_TRG2_INIT_DATA,
      INT_INIT_PACKET_NUM_IN => apl_to_buf_TRG2_INIT_PACKET_NUM,
      INT_INIT_READ_OUT      => apl_to_buf_TRG2_INIT_READ,
      INT_REPLY_HEADER_IN     => '0',
      INT_REPLY_DATAREADY_OUT => buf_to_apl_TRG2_REPLY_DATAREADY,
      INT_REPLY_DATA_OUT      => buf_to_apl_TRG2_REPLY_DATA,
      INT_REPLY_PACKET_NUM_OUT=> buf_to_apl_TRG2_REPLY_PACKET_NUM,
      INT_REPLY_READ_IN       => buf_to_apl_TRG2_REPLY_READ,
      INT_REPLY_DATAREADY_IN  => apl_to_buf_TRG2_REPLY_DATAREADY,
      INT_REPLY_DATA_IN       => apl_to_buf_TRG2_REPLY_DATA,
      INT_REPLY_PACKET_NUM_IN => apl_to_buf_TRG2_REPLY_PACKET_NUM,
      INT_REPLY_READ_OUT      => apl_to_buf_TRG2_REPLY_READ,
      -- Status and control port
      STAT_GEN               => STAT_TRG2_GEN,
      STAT_LOCKED            => STAT_TRG2_LOCKED,
      STAT_INIT_BUFFER       => STAT_TRG2_INIT_BUFFER,
      STAT_REPLY_BUFFER      => STAT_TRG2_REPLY_BUFFER,
      CTRL_GEN               => CTRL_TRG2_GEN,
      CTRL_LOCKED            => CTRL_TRG2_LOCKED,
      STAT_CTRL_INIT_BUFFER  => STAT_TRG2_CTRL_INIT_BUFFER,
      STAT_CTRL_REPLY_BUFFER => STAT_TRG2_CTRL_REPLY_BUFFER
      );

  MPLEX: trb_net16_io_multiplexer
    generic map (
      DATA_WIDTH  => DATA_WIDTH,
      NUM_WIDTH   => NUM_WIDTH,
      MUX_WIDTH   => MUX_WIDTH,
      MUX_SECURE_MODE => MUX_SECURE_MODE
      )
    port map (
      CLK    =>   CLK,
      RESET    => RESET,
      CLK_EN   => CLK_EN,
      MED_DATAREADY_IN  => MED_DATAREADY_IN,
      MED_DATA_IN  => MED_DATA_IN,
      MED_PACKET_NUM_IN => MED_PACKET_NUM_IN,
      MED_READ_OUT  => MED_READ_OUT,
      MED_DATAREADY_OUT => MED_DATAREADY_OUT,
      MED_DATA_OUT => MED_DATA_OUT,
      MED_PACKET_NUM_OUT => MED_PACKET_NUM_OUT,
      MED_READ_IN => MED_READ_IN,
      INT_DATAREADY_OUT => m_DATAREADY_IN,
      INT_DATA_OUT =>m_DATA_IN,
      INT_PACKET_NUM_OUT => m_PACKET_NUM_IN,
      INT_READ_IN =>m_READ_OUT,
      INT_DATAREADY_IN =>m_DATAREADY_OUT,
      INT_DATA_IN =>m_DATA_OUT,
      INT_PACKET_NUM_IN => m_PACKET_NUM_OUT,
      INT_READ_OUT =>m_READ_IN,
      CTRL => MPLEX_CTRL
      );
  
  TRG1_INIT : trb_net16_term
    generic map (
      FIFO_TERM_BUFFER_DEPTH => 0,
      SECURE_MODE => TRG1_SECURE_MODE
      )
    port map(
      --  Misc
      CLK     => CLK,
      RESET   => RESET,
      CLK_EN  => CLK_EN,
      INT_DATAREADY_OUT     => apl_to_buf_TRG1_REPLY_DATAREADY,
      INT_DATA_OUT          => apl_to_buf_TRG1_REPLY_DATA,
      INT_PACKET_NUM_OUT    => apl_to_buf_TRG1_REPLY_PACKET_NUM,
      INT_READ_IN           => apl_to_buf_TRG1_REPLY_READ,
      INT_DATAREADY_IN      => buf_to_apl_TRG1_INIT_DATAREADY,
      INT_DATA_IN           => buf_to_apl_TRG1_INIT_DATA,
      INT_PACKET_NUM_IN     => buf_to_apl_TRG1_INIT_PACKET_NUM,
      INT_READ_OUT          => buf_to_apl_TRG1_INIT_READ,
      -- "mini" APL, just to see the triggers coming in
      APL_DTYPE_OUT         => TRG1_DTYPE_OUT,
      APL_ERROR_PATTERN_OUT => TRG1_ERROR_PATTERN_OUT,
      APL_SEQNR_OUT         => TRG1_SEQNR_OUT,
      APL_GOT_TRM           => TRG1_GOT_TRIGGER_OUT,
      APL_RELEASE_TRM       => TRG1_RELEASE_IN,
      APL_ERROR_PATTERN_IN  => TRG1_ERROR_PATTERN_IN
      -- Status and control port
      );

  TRG2_INIT : trb_net16_term
    generic map (
      FIFO_TERM_BUFFER_DEPTH => 0,
      SECURE_MODE => TRG2_SECURE_MODE
      )
    port map(
      --  Misc
      CLK     => CLK,
      RESET   => RESET,
      CLK_EN  => CLK_EN,
      INT_DATAREADY_OUT     => apl_to_buf_TRG2_REPLY_DATAREADY,
      INT_DATA_OUT          => apl_to_buf_TRG2_REPLY_DATA,
      INT_PACKET_NUM_OUT    => apl_to_buf_TRG2_REPLY_PACKET_NUM,
      INT_READ_IN           => apl_to_buf_TRG2_REPLY_READ,
      INT_DATAREADY_IN      => buf_to_apl_TRG2_INIT_DATAREADY,
      INT_DATA_IN           => buf_to_apl_TRG2_INIT_DATA,
      INT_PACKET_NUM_IN     => buf_to_apl_TRG2_INIT_PACKET_NUM,
      INT_READ_OUT          => buf_to_apl_TRG2_INIT_READ,
      -- "mini" APL, just to see the triggers coming in
      APL_DTYPE_OUT         => TRG2_DTYPE_OUT,
      APL_ERROR_PATTERN_OUT => TRG2_ERROR_PATTERN_OUT,
      APL_SEQNR_OUT         => TRG2_SEQNR_OUT,
      APL_GOT_TRM           => TRG2_GOT_TRIGGER_OUT,
      APL_RELEASE_TRM       => TRG2_RELEASE_IN,
      APL_ERROR_PATTERN_IN  => TRG2_ERROR_PATTERN_IN
      -- Status and control port
      );

apl_to_buf_TRG1_INIT_DATAREADY <= '0';
apl_to_buf_TRG1_INIT_DATA <= (others => '0');
apl_to_buf_TRG1_INIT_PACKET_NUM <= (others => '0');
buf_to_apl_TRG1_REPLY_READ <= '1';

apl_to_buf_TRG2_INIT_DATAREADY <= '0';
apl_to_buf_TRG2_INIT_DATA <= (others => '0');
apl_to_buf_TRG2_INIT_PACKET_NUM <= (others => '0');
buf_to_apl_TRG2_REPLY_READ <= '1';
end architecture;
