library ieee;

use ieee.std_logic_1164.all;

USE ieee.std_logic_signed.ALL;

USE ieee.std_logic_arith.ALL;

USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;

entity trb_net_active_api_testbench is

end trb_net_active_api_testbench;

architecture trb_net_active_api_testbench_arch of trb_net_active_api_testbench is

  signal clk : std_logic := '0';
  signal reset : std_logic := '1';

  signal apl_data_in     : std_logic_vector(47 downto 0) := (others => '0');
  signal apl_write_in    : std_logic := '0';
  signal apl_send_in    : std_logic := '0';

  signal int_init_data_out    : std_logic_vector(50 downto 0) := (others => '0');
  signal int_init_dataready_out   : std_logic := '0';
  signal int_init_dataready_in   : std_logic := '0';
  signal int_init_data_in    : std_logic_vector(50 downto 0) := (others => '0');
  signal read_type : std_logic_vector(2 downto 0) := (others => '0');
  signal read_xf2   : std_logic_vector(3 downto 0) := (others => '0');
  signal read_xf1   : std_logic_vector(3 downto 0) := (others => '0');

  signal int_init_read_out : std_logic := '0';
  signal int_reply_data_out  : std_logic_vector(50 downto 0) := (others => '0');
  signal int_reply_dataready_out: std_logic := '0';
      
  signal read_f1   : std_logic_vector(3 downto 0) := (others => '0');
  
component trb_net_active_api

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
    APL_ERROR_PATTERN: in  STD_LOGIC_VECTOR (31 downto 0); -- see NewTriggerBusNetworkDescr
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
    
    -- Internal direction port
    -- This is just a clone from trb_net_iobuf 
    
    INT_INIT_DATAREADY_OUT: out STD_LOGIC;
    INT_INIT_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_INIT_READ_IN:       in  STD_LOGIC; 
    INT_INIT_ERROR_OUT:     out STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    INT_INIT_DATAREADY_IN:  in  STD_LOGIC;
    INT_INIT_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_INIT_READ_OUT:      out STD_LOGIC; 
    INT_INIT_ERROR_IN:      in  STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    
    INT_REPLY_HEADER_IN:     in  STD_LOGIC; -- Concentrator kindly asks to resend the last
                                      -- header (only for the reply path)
    INT_REPLY_DATAREADY_OUT: out STD_LOGIC;
    INT_REPLY_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_REPLY_READ_IN:       in  STD_LOGIC; 
    INT_REPLY_ERROR_OUT:     out STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    INT_REPLY_DATAREADY_IN:  in  STD_LOGIC;
    INT_REPLY_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_REPLY_READ_OUT:      out STD_LOGIC; 
    INT_REPLY_ERROR_IN:      in  STD_LOGIC_VECTOR (2 downto 0)   -- Status bits
    -- Status and control port

    -- not needed now, but later

    );
END component;
  
begin

UUT: trb_net_active_api
    generic map (
      FIFO_TERM_BUFFER_DEPTH => 3)
    port map (
      CLK             => clk,
      RESET           => reset,
      CLK_EN          => '1',

      APL_DATA_IN => apl_data_in,
      APL_WRITE_IN => apl_write_in,
      APL_SHORT_TRANSFER_IN => '0',
      APL_DTYPE_IN => (others => '0'),
      APL_ERROR_PATTERN => x"12341234",
      APL_SEND_IN => apl_send_in,
      APL_TARGET_ADDRESS_IN => x"0010",

      APL_READ_IN => '0',
      APL_MY_ADDRESS_IN => x"0009",

      
      INT_INIT_READ_IN => '1',          --advanced read
      INT_INIT_DATAREADY_OUT  => int_init_dataready_out,
      INT_INIT_DATA_IN => int_init_data_in,
      INT_INIT_DATAREADY_IN => int_init_dataready_in,
      INT_INIT_READ_OUT => int_init_read_out,
      INT_INIT_ERROR_IN => (others => '0'),
      INT_INIT_DATA_OUT => int_init_data_out,

      INT_REPLY_DATA_OUT => int_reply_data_out,
      INT_REPLY_DATAREADY_OUT => int_reply_dataready_out,
      INT_REPLY_DATAREADY_IN => '0',
      INT_REPLY_HEADER_IN => '0',
      INT_REPLY_READ_IN => '1',
      INT_REPLY_DATA_IN => (others => '0'),
      INT_REPLY_ERROR_IN => (others => '0')
      );
  
  clk <= not clk after 10ns;

  apl_data_in(3 downto 0) <= read_f1;
  
  int_init_data_in(50 downto 48) <= read_type;
  int_init_data_in(19 downto 16) <= read_xf2;-- target
  int_init_data_in(35 downto 32) <= read_xf1;  -- source
  
  
  
  DO_RESET : process
  begin
    reset <= '1';
    wait for 30ns;
    reset <= '0';
    wait;
  end process DO_RESET;

  STIMULI: process (clk)
    file protokoll : text open read_mode is "in_active_api.txt";
    variable myoutline : line;
    variable leer : character;
    variable var1, var2 : std_logic;
    variable varx1 : std_logic_vector(2 downto 0);
    variable varx2, varx3 : std_logic_vector(3 downto 0);
    begin
    if falling_edge(CLK) then
      if (not endfile(protokoll)) then
        readline(protokoll,myoutline);

        read(myoutline,var1);
        apl_write_in <= var1;
        read(myoutline,leer);
        
        read(myoutline,var2);
        apl_send_in <= var2;
        read(myoutline,leer);

        read(myoutline,varx2);
        read_f1 <= varx2;
        
      end if;
    end if;
 end process STIMULI;

  TB_STIMULI: process (clk)
    file protokoll : text open read_mode is "in_active_api_tb.txt";
    variable myoutline : line;
    variable leer : character;
    variable var1, var2 : std_logic;
    variable varx1 : std_logic_vector(2 downto 0);
    variable varx2, varx3 : std_logic_vector(3 downto 0);
    begin
    if falling_edge(CLK) then
      if (not endfile(protokoll)) then
        readline(protokoll,myoutline);

        read(myoutline,var1);
        int_init_dataready_in <= var1;
        read(myoutline,leer);

        read(myoutline,varx1);
        read_type <= varx1;
        read(myoutline,leer);

        read(myoutline,varx2);
        read_xf2 <= varx2;
        read(myoutline,leer);

        read(myoutline,varx3);
        read_xf1 <= varx3;

        
      end if;
    end if;
 end process TB_STIMULI;
  
end trb_net_active_api_testbench_arch;


-- fuse -prj trb_net_active_api_testbench_beh.prj  -top trb_net_active_api_testbench -o trb_net_active_api_testbench

-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/trb_net_std.vhd" 
-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/trb_net_fifo.vhd"
-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/xilinx/arch_trb_net_fifo.vhd"
-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/xilinx/generic_fifo.vhd"   
-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/xilinx/generic_shift.vhd"  
-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/trb_net_fifo_testbench.vhd"

-- trb_net_active_api_testbench -tclbatch testsim.tcl

-- ntrace select -o on -m / -l this
-- ntrace start
-- run 1000 ns
-- quit

-- isimwave isimwavedata.xwv

