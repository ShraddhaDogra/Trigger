
-- This is to be rewritten before it can be fully used. It is not approbriate 
-- to use full apis in a hub - rewriting every header takes way too much time
-- and too much buffers

--LIMITATIONS:
--------------
-- long transfers are not transmitted, since the addresses do not match!
-- no check for fifo_full on active apis
-- seqnr are not synchronized
-- all outputs must be connected


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.trb_net_std.all;


entity trb_net_fanout_hub is
  generic(
    OUTPUT_PORTS : integer range 1 to 8 := 4
    );
  port(
    CLK: in std_logic;
    CLK_EN: in std_logic;
    RESET: in std_logic;
    
    
    STAT: out std_logic_vector(31 downto 0)
    );
end entity;


architecture trb_net_fanout_hub_arch of trb_net_fanout_hub is

component trb_net_passive_apimbuf is
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
    CTRL_GEN:          in  STD_LOGIC_VECTOR (31 downto 0); 
    CTRL_LOCKED:       in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_INIT_BUFFER:  in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_REPLY_BUFFER: in  STD_LOGIC_VECTOR (31 downto 0);
    MPLEX_CTRL: in  STD_LOGIC_VECTOR (31 downto 0);
    API_STAT_FIFO_TO_INT: out std_logic_vector(31 downto 0);
    API_STAT_FIFO_TO_APL: out std_logic_vector(31 downto 0)
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
    CTRL_GEN:          in  STD_LOGIC_VECTOR (31 downto 0); 
    CTRL_LOCKED:       in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_INIT_BUFFER:  in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_REPLY_BUFFER: in  STD_LOGIC_VECTOR (31 downto 0);
    MPLEX_CTRL: in  STD_LOGIC_VECTOR (31 downto 0);
    API_STAT_FIFO_TO_INT: out std_logic_vector(31 downto 0);
    API_STAT_FIFO_TO_APL: out std_logic_vector(31 downto 0)
    );
  end component;



type logic_1_array   is array (OUTPUT_PORTS downto 0) of std_logic;
type vector_3_array  is array (OUTPUT_PORTS downto 0) of std_logic_vector(2  downto 0);
type vector_4_array  is array (OUTPUT_PORTS downto 0) of std_logic_vector(3  downto 0);
type vector_8_array  is array (OUTPUT_PORTS downto 0) of std_logic_vector(7  downto 0);
type vector_16_array is array (OUTPUT_PORTS downto 0) of std_logic_vector(15 downto 0);
type vector_32_array is array (OUTPUT_PORTS downto 0) of std_logic_vector(31 downto 0);
type vector_48_array is array (OUTPUT_PORTS downto 0) of std_logic_vector(47 downto 0);
type vector_52_array is array (OUTPUT_PORTS downto 0) of std_logic_vector(51 downto 0);

--(0) of each array is the passive input api
--(x) all others are the active output apis


signal MED_DATAREADY_OUT :   logic_1_array;
signal MED_DATA_OUT:         vector_52_array;
signal MED_READ_IN:          logic_1_array;
signal MED_DATAREADY_IN:     logic_1_array;
signal MED_DATA_IN:          vector_52_array;
signal MED_READ_OUT:         logic_1_array;
signal MED_ERROR_IN:         vector_3_array;
signal APL_DATA_IN:          vector_48_array;
signal APL_WRITE_IN:         logic_1_array;
signal APL_FIFO_FULL_OUT:    logic_1_array;
signal APL_SHORT_TRANSFER_IN:logic_1_array;
signal APL_DTYPE_IN:         vector_4_array;
signal APL_ERROR_PATTERN_IN: vector_32_array;
signal APL_SEND_IN:          logic_1_array;
signal APL_TARGET_ADDRESS_IN:vector_16_array;
signal APL_DATA_OUT:         vector_48_array;
signal APL_TYP_OUT:          vector_3_array;
signal APL_DATAREADY_OUT:    logic_1_array;
signal APL_READ_IN:          logic_1_array;
signal APL_RUN_OUT:          logic_1_array;
signal APL_MY_ADDRESS_IN:    vector_16_array;
signal APL_SEQNR_OUT:        vector_8_array;
signal STAT_GEN:             vector_32_array;
signal STAT_LOCKED:          vector_32_array;
signal STAT_INIT_BUFFER:     vector_32_array;
signal STAT_REPLY_BUFFER:    vector_32_array;
signal STAT_api_control_signals: vector_32_array;
signal CTRL_GEN:             vector_32_array;
signal CTRL_LOCKED:          vector_32_array;
signal STAT_CTRL_INIT_BUFFER:    vector_32_array;
signal STAT_CTRL_REPLY_BUFFER:   vector_32_array;
signal MPLEX_CTRL:           vector_32_array;
signal API_STAT_FIFO_TO_INT: vector_32_array;
signal API_STAT_FIFO_TO_APL: vector_32_array;

signal this_APL_RUN_OUT, last_APL_RUN_OUT : logic_1_array;
signal APL_RUN_OUT_fallen, next_APL_RUN_OUT_fallen : logic_1_array;
signal next_APL_SEND_IN : logic_1_array;



begin

---------------------------------------
--generate all apis
---------------------------------------

  output_api: for i in 1 to OUTPUT_PORTS generate
    output_api: trb_net_active_apimbuf
      --no generic map, using defaults
      port map(
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        MED_DATAREADY_OUT  => MED_DATAREADY_OUT(i),
        MED_DATA_OUT       => MED_DATA_OUT(i),
        MED_READ_IN        => MED_READ_IN(i),
        MED_DATAREADY_IN   => MED_DATAREADY_IN(i),
        MED_DATA_IN        => MED_DATA_IN(i),
        MED_READ_OUT       => MED_READ_OUT(i),
        MED_ERROR_IN       => MED_ERROR_IN(i),
        APL_DATA_IN           => APL_DATA_IN(1),
        APL_WRITE_IN          => APL_WRITE_IN(1),
        APL_FIFO_FULL_OUT     => APL_FIFO_FULL_OUT(i),
        APL_SHORT_TRANSFER_IN => APL_SHORT_TRANSFER_IN(1),
        APL_DTYPE_IN          => APL_DTYPE_IN(1),
        APL_ERROR_PATTERN_IN  => APL_ERROR_PATTERN_IN(1),
        APL_SEND_IN           => APL_SEND_IN(1),
        APL_TARGET_ADDRESS_IN => APL_TARGET_ADDRESS_IN(1),
        APL_DATA_OUT          => APL_DATA_OUT(i),
        APL_TYP_OUT           => APL_TYP_OUT(i),
        APL_DATAREADY_OUT     => APL_DATAREADY_OUT(i),
        APL_READ_IN           => APL_READ_IN(1),
        APL_RUN_OUT           => APL_RUN_OUT(i),
        APL_MY_ADDRESS_IN     => APL_MY_ADDRESS_IN(1),
        APL_SEQNR_OUT         => APL_SEQNR_OUT(i),
        STAT_GEN                 => STAT_GEN(i),
        STAT_LOCKED              => STAT_LOCKED(i),
        STAT_INIT_BUFFER         => STAT_INIT_BUFFER(i),
        STAT_REPLY_BUFFER        => STAT_REPLY_BUFFER(i),
        STAT_api_control_signals => STAT_api_control_signals(i),
        CTRL_GEN                 => CTRL_GEN(i),
        CTRL_LOCKED              => CTRL_LOCKED(i),
        STAT_CTRL_INIT_BUFFER    => STAT_CTRL_INIT_BUFFER(i),
        STAT_CTRL_REPLY_BUFFER   => STAT_CTRL_REPLY_BUFFER(i),
        MPLEX_CTRL               => MPLEX_CTRL(i),
        API_STAT_FIFO_TO_INT     => API_STAT_FIFO_TO_INT(i),
        API_STAT_FIFO_TO_APL     => API_STAT_FIFO_TO_APL(i)
        );
    end generate;


  input_api: trb_net_passive_apimbuf
      --no generic map, using defaults
      port map(
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        MED_DATAREADY_OUT  => MED_DATAREADY_OUT(0),
        MED_DATA_OUT       => MED_DATA_OUT(0),
        MED_READ_IN        => MED_READ_IN(0),
        MED_DATAREADY_IN   => MED_DATAREADY_IN(0),
        MED_DATA_IN        => MED_DATA_IN(0),
        MED_READ_OUT       => MED_READ_OUT(0),
        MED_ERROR_IN       => MED_ERROR_IN(0),
        ---
        APL_DATA_IN           => APL_DATA_IN(0),
        APL_WRITE_IN          => APL_WRITE_IN(0),
        APL_FIFO_FULL_OUT     => APL_FIFO_FULL_OUT(0),
        APL_SHORT_TRANSFER_IN => APL_SHORT_TRANSFER_IN(0),
        APL_DTYPE_IN          => APL_DTYPE_IN(0),
        APL_ERROR_PATTERN_IN  => APL_ERROR_PATTERN_IN(0),
        APL_SEND_IN           => APL_SEND_IN(0),
        APL_TARGET_ADDRESS_IN => APL_TARGET_ADDRESS_IN(0),
        APL_DATA_OUT          => APL_DATA_OUT(0),
        APL_TYP_OUT           => APL_TYP_OUT(0),
        APL_DATAREADY_OUT     => APL_DATAREADY_OUT(0),
        APL_READ_IN           => APL_READ_IN(0),
        APL_RUN_OUT           => APL_RUN_OUT(0),
        APL_MY_ADDRESS_IN     => APL_MY_ADDRESS_IN(0),
        APL_SEQNR_OUT         => APL_SEQNR_OUT(0),
        ---
        STAT_GEN                 => STAT_GEN(0),
        STAT_LOCKED              => STAT_LOCKED(0),
        STAT_INIT_BUFFER         => STAT_INIT_BUFFER(0),
        STAT_REPLY_BUFFER        => STAT_REPLY_BUFFER(0),
        STAT_api_control_signals => STAT_api_control_signals(0),
        CTRL_GEN                 => CTRL_GEN(0),
        CTRL_LOCKED              => CTRL_LOCKED(0),
        STAT_CTRL_INIT_BUFFER    => STAT_CTRL_INIT_BUFFER(0),
        STAT_CTRL_REPLY_BUFFER   => STAT_CTRL_REPLY_BUFFER(0),
        MPLEX_CTRL               => MPLEX_CTRL(0),
        API_STAT_FIFO_TO_INT     => API_STAT_FIFO_TO_INT(0),
        API_STAT_FIFO_TO_APL     => API_STAT_FIFO_TO_APL(0)
        );




  APL_DATA_IN(1) <= (others => '0');
  APL_SHORT_TRANSFER_IN(1) <= '1';
  APL_SHORT_TRANSFER_IN(0) <= '1';
  APL_ERROR_PATTERN_IN(1) <= APL_DATA_OUT(0)(47 downto 16);
  APL_WRITE_IN(1) <= '0';
  APL_WRITE_IN(0) <= '0';
  
  APL_DTYPE_IN(1) <= APL_DATA_OUT(0)(3 downto 0);
  APL_SEND_IN(1)  <= APL_DATAREADY_OUT(0);
  APL_TARGET_ADDRESS_IN(1) <= (others => '0');
  APL_READ_IN(1) <= '1';
  APL_READ_IN(0) <= '1';
  APL_MY_ADDRESS_IN(1) <= (others => '0');

--merge all errorpatterns
-------------------------
  process(APL_DATA_OUT)
    variable tmp :  std_logic_vector(31 downto 0);
    begin
      tmp := (others => '0');
      for i in 1 to OUTPUT_PORTS loop
        tmp := tmp or APL_DATA_OUT(i)(47 downto 16);
      end loop;
      APL_ERROR_PATTERN_IN(0) <= tmp;
    end process;


--check for falling run_out for all output apis
-----------------------------------------------
  process(last_APL_RUN_OUT, this_APL_RUN_OUT, APL_RUN_OUT_fallen)
    variable tmp : std_logic;
    begin
      next_APL_RUN_OUT_fallen <= APL_RUN_OUT_fallen;
      next_APL_SEND_IN(0) <= '0';
      for i in 1 to OUTPUT_PORTS loop
        if last_APL_RUN_OUT(i)= '1' and this_APL_RUN_OUT(i) = '0' then
          next_APL_RUN_OUT_fallen(i) <= '1';
        end if;
      end loop;
      tmp := '1';
      for i in 1 to OUTPUT_PORTS loop
        tmp := tmp and APL_RUN_OUT_fallen(i);
      end loop;
      if tmp = '1' then
        next_APL_SEND_IN(0) <= '1';
        next_APL_RUN_OUT_fallen <= (others => '0');
      end if;
    end process;


  process(CLK) 
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          this_APL_RUN_OUT <= (others => '0');
          last_APL_RUN_OUT <= (others => '0');
          APL_RUN_OUT_fallen <= (others => '0');
          APL_SEND_IN(0) <= '0';
        else
          this_APL_RUN_OUT <= APL_RUN_OUT;
          last_APL_RUN_OUT <= this_APL_RUN_OUT;
          APL_RUN_OUT_fallen <= next_APL_RUN_OUT_fallen;
          APL_SEND_IN(0) <= next_APL_SEND_IN(0);
        end if;
      end if;
    end process;


end architecture;



