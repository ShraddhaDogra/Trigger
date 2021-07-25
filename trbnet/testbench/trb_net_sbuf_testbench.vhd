library ieee;

use ieee.std_logic_1164.all;

USE ieee.std_logic_signed.ALL;

USE ieee.std_logic_arith.ALL;

USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;

entity trb_net_sbuf_testbench is

end trb_net_sbuf_testbench;

architecture trb_net_sbuf_testbench_arch of trb_net_sbuf_testbench is

  signal clk : std_logic := '0';
  signal reset : std_logic := '1';

  signal dr_in,syn_rd : std_logic := '0';

component trb_net_sbuf is

  generic (DATA_WIDTH : integer := 56;
           VERSION: integer := 1);
--  generic (DATA_WIDTH : integer := 1);
  
  port(
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;
    --  port to combinatorial logic
    COMB_DATAREADY_IN:  in  STD_LOGIC;  --comb logic provides data word
    COMB_next_READ_OUT: out STD_LOGIC;  --sbuf can read in NEXT cycle
    COMB_READ_IN:       in  STD_LOGIC;  --comb logic IS reading
    -- the COMB_next_READ_OUT should be connected via comb. logic to a register
    -- to provide COMB_READ_IN (feedback path with 1 cycle delay)
    -- The "REAL" READ_OUT can be constructed in the comb via COMB_next_READ_
    -- OUT and the READ_IN: If one of these is ='1', no problem to read in next
    -- step.
    COMB_DATA_IN:       in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0); -- Data word
    -- Port to synchronous output.
    SYN_DATAREADY_OUT:  out STD_LOGIC; 
    SYN_DATA_OUT:       out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0); -- Data word
    SYN_READ_IN:        in  STD_LOGIC; 
    -- Status and control port
    STAT_BUFFER:        out STD_LOGIC
    );
END component;
  
begin

UUT:  trb_net_sbuf
    generic map (DATA_WIDTH => 1,
           VERSION => 0)
    port map (
      CLK             => clk,
      RESET           => reset,
      CLK_EN          => '1',

      COMB_DATAREADY_IN => dr_in,
      COMB_READ_IN=> '1',
      COMB_DATA_IN => (others =>  '0'),
      SYN_READ_IN => syn_rd
      );
      
  
  clk <= not clk after 10ns;

  
  DO_RESET : process
  begin
    reset <= '1';
    wait for 30ns;
    reset <= '0';
    wait;
  end process DO_RESET;

  STIMULI: process (clk)
    file protokoll : text open read_mode is "in_sbuf.txt";
    variable myoutline : line;
    variable leer : character;
    variable var1, var2 : std_logic;

    begin
    if falling_edge(CLK) then
      if (not endfile(protokoll)) then
        readline(protokoll,myoutline);

        read(myoutline,var1);
        dr_in <= var1;
        read(myoutline,leer);
        
        read(myoutline,var2);
        syn_rd <= var2;

        
      end if;
    end if;
 end process STIMULI;

end trb_net_sbuf_testbench_arch;


-- fuse -prj trb_net_sbuf_testbench_beh.prj  -top trb_net_sbuf_testbench -o trb_net_sbuf_testbench

-- trb_net_sbuf_testbench -tclbatch sbuf_testsim.tcl
-- gtkwave vcdfile.vcd settings_sbuf.sav
