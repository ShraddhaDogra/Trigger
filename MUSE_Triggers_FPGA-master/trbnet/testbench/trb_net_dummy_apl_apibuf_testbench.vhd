library ieee;

use ieee.std_logic_1164.all;
USE ieee.std_logic_signed.ALL;
USE ieee.std_logic_arith.ALL;

USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;

entity trb_net_dummy_apl_apibuf_testbench is

end trb_net_dummy_apl_apibuf_testbench;

architecture trb_net_dummy_apl_apibuf_testbench_arch of trb_net_dummy_apl_apibuf_testbench is

  signal clk : std_logic := '0';
  signal reset : std_logic := '1';

component trb_net_active_apibuf is

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
    STAT_CTRL_REPLY_BUFFER: in  STD_LOGIC_VECTOR (31 downto 0)  
    );
END component;

  
component trb_net_dummy_apl 
    generic (TARGET_ADDRESS : STD_LOGIC_VECTOR (15 downto 0) := x"ffff";
             PREFILL_LENGTH  : integer := 3;
             TRANSFER_LENGTH  : integer := 6);  -- length of dummy data
  
    port(
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;

    -- APL Transmitter port
    APL_DATA_OUT:       out STD_LOGIC_VECTOR (47 downto 0); -- Data word "application to network"
    APL_WRITE_OUT:      out STD_LOGIC; -- Data word is valid and should be transmitted
    APL_FIFO_FULL_IN:   in STD_LOGIC; -- Stop transfer, the fifo is full
    APL_SHORT_TRANSFER_OUT: out STD_LOGIC; -- 
    APL_DTYPE_OUT:      out STD_LOGIC_VECTOR (3 downto 0);  -- see NewTriggerBusNetworkDescr
    APL_ERROR_PATTERN_OUT: out STD_LOGIC_VECTOR (31 downto 0); -- see NewTriggerBusNetworkDescr
    APL_SEND_OUT:       out STD_LOGIC; -- Release sending of the data
    APL_TARGET_ADDRESS_OUT: out STD_LOGIC_VECTOR (15 downto 0); -- Address of
                                                               -- the target (only for active APIs)

    -- Receiver port
    APL_DATA_IN:      in  STD_LOGIC_VECTOR (47 downto 0); -- Data word "network to application"
    APL_TYP_IN:       in  STD_LOGIC_VECTOR (2 downto 0);  -- Which kind of data word: DAT, HDR or TRM
    APL_DATAREADY_IN: in  STD_LOGIC; -- Data word is valid and might be read out
    APL_READ_OUT:     out STD_LOGIC; -- Read data word
    
    -- APL Control port
    APL_RUN_IN:       in STD_LOGIC; -- Data transfer is running
    APL_SEQNR_IN:     in STD_LOGIC_VECTOR (7 downto 0)
    );
END component;

signal apl_data_out_apl1:       STD_LOGIC_VECTOR (47 downto 0);
signal apl_write_apl1:          STD_LOGIC;
signal apl_fifo_full_apl1:      STD_LOGIC;
signal apl_short_transfer_apl1: STD_LOGIC;
signal apl_dtype_apl1:          STD_LOGIC_VECTOR (3 downto 0);
signal apl_error_pattern_apl1:  STD_LOGIC_VECTOR (31 downto 0);
signal apl_send_apl1:           STD_LOGIC;
signal apl_target_adress_apl1:  STD_LOGIC_VECTOR (15 downto 0);
signal apl_data_in_apl1:        STD_LOGIC_VECTOR (47 downto 0); 
signal apl_typ_apl1:            STD_LOGIC_VECTOR (2 downto 0);
signal apl_dataready_apl1:      STD_LOGIC;
signal apl_read_apl1:           STD_LOGIC;
signal apl_run_apl1:            STD_LOGIC;
signal apl_seqnr_apl1:          STD_LOGIC_VECTOR (7 downto 0);

signal apl_data_out_apl2:       STD_LOGIC_VECTOR (47 downto 0);
signal apl_write_apl2:          STD_LOGIC;
signal apl_fifo_full_apl2:      STD_LOGIC;
signal apl_short_transfer_apl2: STD_LOGIC;
signal apl_dtype_apl2:          STD_LOGIC_VECTOR (3 downto 0);
signal apl_error_pattern_apl2:  STD_LOGIC_VECTOR (31 downto 0);
signal apl_send_apl2:           STD_LOGIC;
signal apl_target_adress_apl2:  STD_LOGIC_VECTOR (15 downto 0);
signal apl_data_in_apl2:        STD_LOGIC_VECTOR (47 downto 0); 
signal apl_typ_apl2:            STD_LOGIC_VECTOR (2 downto 0);
signal apl_dataready_apl2:      STD_LOGIC;
signal apl_read_apl2:           STD_LOGIC;
signal apl_run_apl2:            STD_LOGIC;
signal apl_seqnr_apl2:          STD_LOGIC_VECTOR (7 downto 0);

signal MED_INIT_DATAREADY_1_to_2: STD_LOGIC;
signal MED_INIT_DATA_1_to_2:      STD_LOGIC_VECTOR (50 downto 0);
signal MED_INIT_READ_1_to_2:      STD_LOGIC;
signal MED_INIT_DATAREADY_2_to_1: STD_LOGIC;
signal MED_INIT_DATA_2_to_1:      STD_LOGIC_VECTOR (50 downto 0);
signal MED_INIT_READ_2_to_1:      STD_LOGIC;
signal MED_REPLY_DATAREADY_1_to_2: STD_LOGIC;
signal MED_REPLY_DATA_1_to_2:      STD_LOGIC_VECTOR (50 downto 0);
signal MED_REPLY_READ_1_to_2:      STD_LOGIC;
signal MED_REPLY_DATAREADY_2_to_1: STD_LOGIC;
signal MED_REPLY_DATA_2_to_1:      STD_LOGIC_VECTOR (50 downto 0);
signal MED_REPLY_READ_2_to_1:      STD_LOGIC;


begin


  clk <= not clk after 10ns;


  
  DO_RESET : process
  begin
    reset <= '1';
    wait for 30ns;
    reset <= '0';
    wait;
  end process DO_RESET;

-------------------------------------------------------------------------------
--  the 2 APLs
-------------------------------------------------------------------------------

APL1: trb_net_dummy_apl
    generic map (
      TARGET_ADDRESS => x"0002",
--      TARGET_ADDRESS => x"000f",
      PREFILL_LENGTH => 0,
--      TRANSFER_LENGTH => 2)
      TRANSFER_LENGTH => 16)
    port map (
      CLK             => clk,
      RESET           => reset,
      CLK_EN          => '1',

      -- APL Transmitter port
      APL_DATA_OUT           => apl_data_out_apl1,
      APL_WRITE_OUT          => apl_write_apl1,
      APL_FIFO_FULL_IN       => apl_fifo_full_apl1,
      APL_SHORT_TRANSFER_OUT => apl_short_transfer_apl1,
      APL_DTYPE_OUT          => apl_dtype_apl1,
      APL_ERROR_PATTERN_OUT  => apl_error_pattern_apl1,
      APL_SEND_OUT           => apl_send_apl1,
      APL_TARGET_ADDRESS_OUT => apl_target_adress_apl1,

      -- Receiver port
      APL_DATA_IN      => apl_data_in_apl1,
      APL_TYP_IN       => apl_typ_apl1,
      APL_DATAREADY_IN => apl_dataready_apl1,
      APL_READ_OUT     => apl_read_apl1,
    
      -- APL Control port
      APL_RUN_IN   => apl_run_apl1,
      APL_SEQNR_IN => apl_seqnr_apl1
      );
  
APL2: trb_net_dummy_apl
    generic map (
      TARGET_ADDRESS => x"0001",
      PREFILL_LENGTH => 0,
      TRANSFER_LENGTH => 2)
    port map (
      CLK             => clk,
      RESET           => reset,
      CLK_EN          => '1',

      -- APL Transmitter port
      APL_DATA_OUT           => apl_data_out_apl2,
      APL_WRITE_OUT          => apl_write_apl2,
      APL_FIFO_FULL_IN       => apl_fifo_full_apl2,
      APL_SHORT_TRANSFER_OUT => apl_short_transfer_apl2,
      APL_DTYPE_OUT          => apl_dtype_apl2,
      APL_ERROR_PATTERN_OUT  => apl_error_pattern_apl2,
      APL_SEND_OUT           => apl_send_apl2,
      APL_TARGET_ADDRESS_OUT => apl_target_adress_apl2,

      -- Receiver port
      APL_DATA_IN      => apl_data_in_apl2,
      APL_TYP_IN       => apl_typ_apl2,
      APL_DATAREADY_IN => apl_dataready_apl2,
      APL_READ_OUT     => apl_read_apl2,
    
      -- APL Control port
      APL_RUN_IN   => apl_run_apl2,
      APL_SEQNR_IN => apl_seqnr_apl2
      );

-------------------------------------------------------------------------------
-- the 2 APIs
-------------------------------------------------------------------------------  

API1: trb_net_active_apibuf
    generic map (
      FIFO_TERM_BUFFER_DEPTH => 3)
    port map (
      CLK             => clk,
      RESET           => reset,
      CLK_EN          => '1',
      
      -- APL Transmitter port
      APL_DATA_IN           => apl_data_out_apl1,
      APL_WRITE_IN          => apl_write_apl1,
      APL_FIFO_FULL_OUT     => apl_fifo_full_apl1,
      APL_SHORT_TRANSFER_IN => apl_short_transfer_apl1,
      APL_DTYPE_IN          => apl_dtype_apl1,
      APL_ERROR_PATTERN_IN  => apl_error_pattern_apl1,
      APL_SEND_IN           => apl_send_apl1,
      APL_TARGET_ADDRESS_IN => apl_target_adress_apl1,

      -- Receiver port
      APL_DATA_OUT      => apl_data_in_apl1,
      APL_TYP_OUT       => apl_typ_apl1,
      APL_DATAREADY_OUT => apl_dataready_apl1,
      APL_READ_IN       => apl_read_apl1,
    
      -- APL Control port
      APL_RUN_OUT   => apl_run_apl1,
      APL_SEQNR_OUT => apl_seqnr_apl1,
      APL_MY_ADDRESS_IN => x"0001",
    
      MED_INIT_DATAREADY_OUT => MED_INIT_DATAREADY_1_to_2,
      MED_INIT_DATA_OUT      => MED_INIT_DATA_1_to_2,
      MED_INIT_READ_IN       => MED_INIT_READ_1_to_2,      
      MED_INIT_DATAREADY_IN  => MED_INIT_DATAREADY_2_to_1,
      MED_INIT_DATA_IN       => MED_INIT_DATA_2_to_1,
      MED_INIT_ERROR_IN      => "000",
      MED_INIT_READ_OUT      => MED_INIT_READ_2_to_1,
    
      MED_REPLY_DATAREADY_OUT => MED_REPLY_DATAREADY_1_to_2,
      MED_REPLY_DATA_OUT      => MED_REPLY_DATA_1_to_2,
      MED_REPLY_READ_IN       => MED_REPLY_READ_1_to_2,
      MED_REPLY_DATAREADY_IN  => MED_REPLY_DATAREADY_2_to_1,
      MED_REPLY_DATA_IN       => MED_REPLY_DATA_2_to_1,
      MED_REPLY_ERROR_IN       => "000",
      MED_REPLY_READ_OUT      => MED_REPLY_READ_2_to_1,

      CTRL_LOCKED     => (others => '0'),
      CTRL_GEN        => (others => '0'),

      STAT_CTRL_INIT_BUFFER     => (others => '0'),
      STAT_CTRL_REPLY_BUFFER     => (others => '0')
      );

API2: trb_net_active_apibuf
    generic map (
      FIFO_TERM_BUFFER_DEPTH => 3)
    port map (
      CLK             => clk,
      RESET           => reset,
      CLK_EN          => '1',
      
      -- APL Transmitter port
      APL_DATA_IN           => apl_data_out_apl2,
      APL_WRITE_IN          => apl_write_apl2,
      APL_FIFO_FULL_OUT     => apl_fifo_full_apl2,
      APL_SHORT_TRANSFER_IN => apl_short_transfer_apl2,
      APL_DTYPE_IN          => apl_dtype_apl2,
      APL_ERROR_PATTERN_IN  => apl_error_pattern_apl2,
      APL_SEND_IN           => apl_send_apl2,
      APL_TARGET_ADDRESS_IN => apl_target_adress_apl2,

      -- Receiver port
      APL_DATA_OUT      => apl_data_in_apl2,
      APL_TYP_OUT       => apl_typ_apl2,
      APL_DATAREADY_OUT => apl_dataready_apl2,
      APL_READ_IN       => apl_read_apl2,
    
      -- APL Control port
      APL_RUN_OUT   => apl_run_apl2,
      APL_SEQNR_OUT => apl_seqnr_apl2,
      APL_MY_ADDRESS_IN => x"0002",
      
      MED_INIT_DATAREADY_OUT => MED_INIT_DATAREADY_2_to_1,
      MED_INIT_DATA_OUT      => MED_INIT_DATA_2_to_1,
      MED_INIT_READ_IN       => MED_INIT_READ_2_to_1,
      MED_INIT_DATAREADY_IN  => MED_INIT_DATAREADY_1_to_2,
      MED_INIT_DATA_IN       => MED_INIT_DATA_1_to_2,
      MED_INIT_ERROR_IN      => "000",
      MED_INIT_READ_OUT      => MED_INIT_READ_1_to_2,
    
      MED_REPLY_DATAREADY_OUT => MED_REPLY_DATAREADY_2_to_1,
      MED_REPLY_DATA_OUT      => MED_REPLY_DATA_2_to_1,
      MED_REPLY_READ_IN       => MED_REPLY_READ_2_to_1,
      MED_REPLY_DATAREADY_IN  => MED_REPLY_DATAREADY_1_to_2,
      MED_REPLY_DATA_IN       => MED_REPLY_DATA_1_to_2,
      MED_REPLY_ERROR_IN       => "000",
      MED_REPLY_READ_OUT      => MED_REPLY_READ_1_to_2,

      
      CTRL_LOCKED     => (others => '0'),
      CTRL_GEN        => (others => '0'),

      STAT_CTRL_INIT_BUFFER     => (others => '0'),
      STAT_CTRL_REPLY_BUFFER     => (others => '0')
      );
  
end trb_net_dummy_apl_apibuf_testbench_arch;


-- fuse -prj trb_net_dummy_apl_apibuf_testbench_beh.prj  -top trb_net_dummy_apl_apibuf_testbench -o trb_net_dummy_apl_apibuf_testbench

-- trb_net_dummy_apl_apibuf_testbench -tclbatch apl_apibuf_testsim.tcl

-- ntrace select -o on -m / -l this
-- ntrace start
-- run 1000 ns
-- quit

-- isimwave isimwavedata.xwv
-- gtkwave vcdfile.vcd settings_aplbuf.sav &
