-- http://hades-wiki.gsi.de/cgi-bin/view/DaqSlowControl/TrbNetFifo

library ieee;

use ieee.std_logic_1164.all;

USE ieee.std_logic_signed.ALL;

USE ieee.std_logic_arith.ALL;

USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;

entity trb_net_fifo_testbench is

end trb_net_fifo_testbench;

architecture trb_net_fifo_testbench_arch of trb_net_fifo_testbench is

  signal clk : std_logic := '0';
  signal reset : std_logic := '1';
  signal mydata_input: std_logic_vector(3 downto 0) := x"0";
  signal mywrite  : std_logic := '1';
  signal myread : std_logic := '0';
  signal mydata_output: std_logic_vector(3 downto 0) := x"0";
  signal myfull: std_logic := '0';
  signal myempty: std_logic := '0';
  signal mydepth: std_logic_vector(7 downto 0) := x"00";
  
  component trb_net_fifo 
    
    generic (WIDTH : integer := 8;  	-- FIFO word width
             DEPTH : integer := 4);     -- Depth of the FIFO, 2^(n+1)

    port (CLK    : in std_logic;  		
          RESET  : in std_logic;  	
          CLK_EN : in std_logic;
          
          DATA_IN         : in  std_logic_vector(WIDTH - 1 downto 0);  -- Input data
          WRITE_ENABLE_IN : in  std_logic;  		
          DATA_OUT        : out std_logic_vector(WIDTH - 1 downto 0);  -- Output data
          READ_ENABLE_IN  : in  std_logic; 
          FULL_OUT        : out std_logic;  	-- Full Flag
          EMPTY_OUT       : out std_logic;
          DEPTH_OUT       : out std_logic_vector(7 downto 0)
          );     
  end component;
  
begin

  FIFO : trb_net_fifo
    generic map (
      WIDTH => 4,
      DEPTH => 3)
    port map (
      CLK             => clk,
      RESET           => reset,
      CLK_EN          => '1',
      DATA_IN         => mydata_input,
      WRITE_ENABLE_IN => mywrite,
      READ_ENABLE_IN  => myread,
      DATA_OUT        => mydata_output,
      FULL_OUT        => myfull,
      EMPTY_OUT       => myempty,
      DEPTH_OUT       => mydepth);
  
  clk <= not clk after 10ns;

  DO_RESET : process
  begin
    reset <= '1';
    wait for 30ns;
    reset <= '0';
    wait;
  end process DO_RESET;

  STIMULI: process (clk)
    file protokoll : text open read_mode is "in_fifo.txt";
    variable myoutline : line;
    variable leer : character;
    variable var1, var2 : std_logic;
    variable varx : std_logic_vector(3 downto 0);
    begin
    if falling_edge(CLK) then
      if (not endfile(protokoll)) then
        readline(protokoll,myoutline);
        read(myoutline,var1);
        mywrite <= var1;
        read(myoutline,leer);
        read(myoutline,var2);
        myread  <= var2;
        read(myoutline,leer);
        read(myoutline,varx);
        mydata_input <= varx;
      end if;
    end if;
 end process STIMULI;
      
  
  RESPONSE: process (clk)
    file protokoll : text open write_mode is "out_fifo.txt";
    variable myoutline : line;
    
  begin  -- process RESPONSE
    if rising_edge(CLK) then  -- rising clock edge

      hwrite (myoutline, mydepth);
      writeline(protokoll, myoutline);
    end if;
  end process RESPONSE;
  
  
end trb_net_fifo_testbench_arch;


-- fuse -prj trb_net_fifo_testbench_beh.prj  -top trb_net_fifo_testbench -o trb_net_fifo_testbench

-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/trb_net_std.vhd" 
-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/trb_net_fifo.vhd"
-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/xilinx/arch_trb_net_fifo.vhd"
-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/xilinx/generic_fifo.vhd"   
-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/xilinx/generic_shift.vhd"  
-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/trb_net_fifo_testbench.vhd"

-- trb_net_fifo_testbench -tclbatch testsim.tcl

-- ntrace select -o on -m / -l this
-- ntrace start
-- run 1000 ns
-- quit

-- isimwave isimwavedata.xwv

