library ieee;

use ieee.std_logic_1164.all;
USE ieee.std_logic_signed.ALL;
USE ieee.std_logic_arith.ALL;

USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;

entity trb_net_lvds_chain_testbench is

end trb_net_lvds_chain_testbench;

architecture trb_net_lvds_chain_testbench_arch of trb_net_lvds_chain_testbench is

  signal clk : std_logic := '0';
  signal clk2 : std_logic := '1';
  signal reset : std_logic := '1';

component trb_net_med_13bit_slow is
generic( 
  TRANSMISSION_CLOCK_DIVIDER: integer := 1 
  );


  port(
    --  Misc
    CLK    : in std_logic;      
    RESET  : in std_logic;    
    CLK_EN : in std_logic;
    -- Internal direction port (MII)
    -- do not change this interface!!! 
    -- 1st part: from the medium to the internal logic (trbnet)
    INT_DATAREADY_OUT: out STD_LOGIC;  --Data word is reconstructed from media
                                       --and ready to be read out (the IOBUF MUST read)
    INT_DATA_OUT:      out STD_LOGIC_VECTOR (55 downto 0); -- Data word
    INT_READ_IN:       in  STD_LOGIC; 
    INT_ERROR_OUT:     out STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    -- 2nd part: from the internal logic (trbnet) to the medium
    INT_DATAREADY_IN:  in  STD_LOGIC; -- Data word is offered for the Media 
    INT_DATA_IN:       in  STD_LOGIC_VECTOR (55 downto 0); -- Data word
    INT_READ_OUT:      out STD_LOGIC; -- offered word is read
    INT_ERROR_IN:      in  STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    -- (end do not change this interface!!!) 

    
    --  Media direction port
    -- in this case for the cable => 32 lines in total
    MED_DATA_OUT:             out STD_LOGIC_VECTOR (12 downto 0); -- Data word 
                          --(incl. debugging errorbits)
    MED_TRANSMISSION_CLK_OUT: out STD_LOGIC;
    MED_CARRIER_OUT:          out STD_LOGIC;
    MED_PARITY_OUT:           out STD_LOGIC;
    MED_DATA_IN:              in  STD_LOGIC_VECTOR (12 downto 0); -- Data word
    MED_TRANSMISSION_CLK_IN:  in  STD_LOGIC;
    MED_CARRIER_IN:           in  STD_LOGIC;
    MED_PARITY_IN:            in  STD_LOGIC;

    -- Status and control port => this never can hurt
    STAT: out STD_LOGIC_VECTOR (31 downto 0);
              --STAT(0): Busy reading from media
              --STAT(1): Busy writing to media
              --STAT(31 downto 24): Datain(63 downto 56
    CTRL: in  STD_LOGIC_VECTOR (31 downto 0)   
              --CTRL(24..31) -> lvds-data(63 downto 56) via lvds 
                     --once for each packet
              --CTRL(16..18) -> debugbits updated every CLK 
					    --lvds(12 downto 10)(10bit-version only)
              --CTRL(0..5) -> lvds-data(69 downto 64) (10bit-version only)
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
    CTRL_GEN:          in  STD_LOGIC_VECTOR (31 downto 0); 
    CTRL_LOCKED:       in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_INIT_BUFFER:  in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_REPLY_BUFFER: in  STD_LOGIC_VECTOR (31 downto 0);
    MPLEX_CTRL: in  STD_LOGIC_VECTOR (31 downto 0)
    );
END component;

  
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
    CTRL_GEN:          in  STD_LOGIC_VECTOR (31 downto 0); 
    CTRL_LOCKED:       in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_INIT_BUFFER:  in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_REPLY_BUFFER: in  STD_LOGIC_VECTOR (31 downto 0);
    MPLEX_CTRL: in  STD_LOGIC_VECTOR (31 downto 0)
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


component trb_net_dummy_passive_apl 
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


signal MED_DATAREADY_1_to_2_api1: STD_LOGIC;
signal MED_DATAREADY_1_to_2_api2: STD_LOGIC;
signal MED_DATA_1_to_2_api1:      STD_LOGIC_VECTOR (51 downto 0);
signal MED_DATA_1_to_2_api1_m:      STD_LOGIC_VECTOR (55 downto 0);
signal MED_DATA_1_to_2_api2:      STD_LOGIC_VECTOR (51 downto 0);
signal MED_DATA_1_to_2_api2_m:      STD_LOGIC_VECTOR (55 downto 0);
signal MED_READ_1_to_2_api1:      STD_LOGIC;
signal MED_READ_1_to_2_api2:      STD_LOGIC;
signal MED_DATAREADY_2_to_1_api1: STD_LOGIC;
signal MED_DATAREADY_2_to_1_api2: STD_LOGIC;
signal MED_DATA_2_to_1_api1:      STD_LOGIC_VECTOR (51 downto 0);
signal MED_DATA_2_to_1_api1_m:      STD_LOGIC_VECTOR (55 downto 0);
signal MED_DATA_2_to_1_api2:      STD_LOGIC_VECTOR (51 downto 0);
signal MED_DATA_2_to_1_api2_m:      STD_LOGIC_VECTOR (55 downto 0);
signal MED_READ_2_to_1_api1:      STD_LOGIC;
signal MED_READ_2_to_1_api2:      STD_LOGIC;

signal lvds: std_logic_vector(31 downto 0) := (others => '0');

signal ctrl: std_logic_vector(31 downto 0) := (others => '0');

begin


  clk <= not clk after 15.15ns;
  clk2 <= not clk2 after 15.00ns;
  
  MED_DATA_1_to_2_api1_m(51 downto 0) <= MED_DATA_1_to_2_api1;
  MED_DATA_1_to_2_api1_m(55 downto 52) <= "0000";  --set CID to 0
  MED_DATA_2_to_1_api1 <= MED_DATA_2_to_1_api1_m(51 downto 0);
  
  MED_DATA_2_to_1_api2_m(51 downto 0) <= MED_DATA_2_to_1_api2;
  MED_DATA_1_to_2_api2 <= MED_DATA_1_to_2_api2_m(51 downto 0);
  MED_DATA_2_to_1_api2_m(55 downto 52) <= "0000";  --set CID to 0
  
                           
  DO_RESET : process
  begin
    reset <= '1';
    wait for 300ns;
    reset <= '0';
    ctrl(8 downto 0) <= "100000000";  --only fixed
--    ctrl(8 downto 0) <= "111111111";  --only rr
--    ctrl(8 downto 0) <= "101010101";  --mixed
    wait for 20ns;
    ctrl(8 downto 0) <= "000000000";
    wait;
  end process DO_RESET;

-------------------------------------------------------------------------------
--  the 2 APLs
-------------------------------------------------------------------------------

APL1: trb_net_dummy_apl
    generic map (
      TARGET_ADDRESS => x"0002",
--      TARGET_ADDRESS => x"000f",
      PREFILL_LENGTH => 3,
      TRANSFER_LENGTH => 6)
--      TRANSFER_LENGTH => 16)
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
  
APL2: trb_net_dummy_passive_apl
    generic map (
      TARGET_ADDRESS => x"0001",
      PREFILL_LENGTH => 0,
--      TRANSFER_LENGTH => 2)
      TRANSFER_LENGTH => 8)
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

API1: trb_net_active_apimbuf
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
    
      MED_DATAREADY_OUT => MED_DATAREADY_1_to_2_api1,
      MED_DATA_OUT      => MED_DATA_1_to_2_api1,
      MED_READ_IN       => MED_READ_1_to_2_api1,
      MED_ERROR_IN => (others => '0'),
      MED_DATAREADY_IN  => MED_DATAREADY_2_to_1_api1,
      MED_DATA_IN       => MED_DATA_2_to_1_api1,
      MED_READ_OUT      => MED_READ_2_to_1_api1,
    
      CTRL_LOCKED     => (others => '0'),
      CTRL_GEN        => (others => '0'),

      STAT_CTRL_INIT_BUFFER     => (others => '0'),
      STAT_CTRL_REPLY_BUFFER     => (others => '0'),
      MPLEX_CTRL => ctrl
      );

API2: trb_net_passive_apimbuf
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
      
      MED_DATAREADY_OUT => MED_DATAREADY_2_to_1_api2,
      MED_DATA_OUT      => MED_DATA_2_to_1_api2,
      MED_READ_IN       => MED_READ_2_to_1_api2,
      MED_ERROR_IN => (others => '0'),
      MED_DATAREADY_IN  => MED_DATAREADY_1_to_2_api2,
      MED_DATA_IN       => MED_DATA_1_to_2_api2,
      MED_READ_OUT      => MED_READ_1_to_2_api2,
    
     
      CTRL_LOCKED     => (others => '0'),
      CTRL_GEN        => (others => '0'),

      STAT_CTRL_INIT_BUFFER     => (others => '0'),
      STAT_CTRL_REPLY_BUFFER     => (others => '0'),
      MPLEX_CTRL => ctrl
      );

-------------------------------------------------------------------------------
-- 2 LVDS slow media
-------------------------------------------------------------------------------

LVDS1: trb_net_med_13bit_slow
  generic map( 
    TRANSMISSION_CLOCK_DIVIDER => 4
  )
  port map(
    --  Misc
    CLK                => clk,
    RESET              => reset,
    CLK_EN             => '1',

    INT_DATAREADY_OUT => MED_DATAREADY_2_to_1_api1,
    INT_DATA_OUT      => MED_DATA_2_to_1_api1_m,
    INT_READ_IN       => MED_READ_2_to_1_api1,
--    INT_ERROR_OUT

    INT_DATAREADY_IN  => MED_DATAREADY_1_to_2_api1,
    INT_DATA_IN       => MED_DATA_1_to_2_api1_m,
    INT_READ_OUT      => MED_READ_1_to_2_api1,
    INT_ERROR_IN      => "000",
    
    --  Media direction port
    -- in this case for the cable => 32 lines in total
    MED_DATA_OUT             => lvds(12 downto 0),
    MED_TRANSMISSION_CLK_OUT => lvds(13),
    MED_CARRIER_OUT          => lvds(14),
    MED_PARITY_OUT           => lvds(15),
    MED_DATA_IN              => lvds(28 downto 16),
    MED_TRANSMISSION_CLK_IN  => lvds(29),
    MED_CARRIER_IN           => lvds(30),
    MED_PARITY_IN            => lvds(31),

    -- Status and control port => this never can hurt
--    STAT
              --STAT(0): Busy reading from media
              --STAT(1): Busy writing to media
              --STAT(31 downto 24): Datain(63 downto 56
    CTRL => x"00000000"
              --CTRL(24..31) -> lvds-data(63 downto 56) via lvds 
                     --once for each packet
              --CTRL(16..18) -> debugbits updated every CLK 
					    --lvds(12 downto 10)(10bit-version only)
              --CTRL(0..5) -> lvds-data(69 downto 64) (10bit-version only)
    );
  
LVDS2: trb_net_med_13bit_slow
  generic map( 
    TRANSMISSION_CLOCK_DIVIDER => 4
  )
  port map(
    --  Misc
    CLK                => clk,
    RESET              => reset,
    CLK_EN             => '1',

    INT_DATAREADY_OUT => MED_DATAREADY_1_to_2_api2,
    INT_DATA_OUT      => MED_DATA_1_to_2_api2_m,
    INT_READ_IN       => MED_READ_1_to_2_api2,
--    INT_ERROR_OUT

    INT_DATAREADY_IN  => MED_DATAREADY_2_to_1_api2,
    INT_DATA_IN       => MED_DATA_2_to_1_api2_m,
    INT_READ_OUT      => MED_READ_2_to_1_api2,
    INT_ERROR_IN      => "000",
    
    --  Media direction port
    -- in this case for the cable => 32 lines in total
    MED_DATA_OUT             => lvds(28 downto 16),
    MED_TRANSMISSION_CLK_OUT => lvds(29),
    MED_CARRIER_OUT          => lvds(30),
    MED_PARITY_OUT           => lvds(31),
    MED_DATA_IN              => lvds(12 downto 0),
    MED_TRANSMISSION_CLK_IN  => lvds(13),
    MED_CARRIER_IN           => lvds(14),
    MED_PARITY_IN            => lvds(15),

    -- Status and control port => this never can hurt
--    STAT
              --STAT(0): Busy reading from media
              --STAT(1): Busy writing to media
              --STAT(31 downto 24): Datain(63 downto 56
    CTRL => x"00000000"
              --CTRL(24..31) -> lvds-data(63 downto 56) via lvds 
                     --once for each packet
              --CTRL(16..18) -> debugbits updated every CLK 
					    --lvds(12 downto 10)(10bit-version only)
              --CTRL(0..5) -> lvds-data(69 downto 64) (10bit-version only)
    );
  
end trb_net_lvds_chain_testbench_arch;

-- fuse -prj ise/trb_net_lvds_chain_testbench_beh.prj  -top trb_net_lvds_chain_testbench -o trb_net_lvds_chain_testbench

-- trb_net_lvds_chain_testbench -tclbatch trbnetendpoint_testbench.tcl

-- ntrace select -o on -m / -l this
-- ntrace start
-- run 1000 ns
-- quit

-- isimwave isimwavedata.xwv
-- gtkwave vcdfile.vcd settings_lvds_chain.sav &
