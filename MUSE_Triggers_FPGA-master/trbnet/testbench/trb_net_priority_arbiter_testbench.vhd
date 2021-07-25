library ieee;

use ieee.std_logic_1164.all;

USE ieee.std_logic_signed.ALL;

USE ieee.std_logic_arith.ALL;

USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;

entity trb_net_priority_arbiter_testbench is

end trb_net_priority_arbiter_testbench;

architecture trb_net_priority_arbiter_testbench_arch of trb_net_priority_arbiter_testbench is

  signal clk : std_logic := '0';
  signal reset : std_logic := '1';

  signal read_type : std_logic_vector(2 downto 0) := (others => '0');
  signal read_f2   : std_logic_vector(3 downto 0) := (others => '0');
  signal read_f1   : std_logic_vector(7 downto 0) := (others => '0');
  signal rol_mask  : std_logic := '0';
  signal ctrl: std_logic_vector(31 downto 0) := (others => '0');
  component trb_net_priority_arbiter is

  generic (WIDTH : integer := 32);     

  port(    
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;
    
    INPUT_IN  : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    RESULT_OUT: out STD_LOGIC_VECTOR (WIDTH-1 downto 0);

    CTRL:  in  STD_LOGIC_VECTOR (31 downto 0)
    );
END component;

  
begin

  UUT: trb_net_priority_arbiter
    generic map (
      WIDTH => 8
      )
    port map (
      CLK   =>clk,
      RESET => reset,
      CLK_EN => '1',
    
      INPUT_IN => read_f1,

      CTRL => ctrl
      );
  
  clk <= not clk after 10ns;
  ctrl(9) <= rol_mask;
  
  DO_RESET : process
  begin
    reset <= '1';
    wait for 30ns;
    reset <= '0';
--    ctrl(8 downto 0) <= "100000000";  --only fixed
--    ctrl(8 downto 0) <= "111111111";  --only rr
    ctrl(8 downto 0) <= "101010101";  --mixed
    wait for 20ns;
    ctrl(8 downto 0) <= "000000000";
    wait;
  end process DO_RESET;

  STIMULI: process (clk)
    file protokoll : text open read_mode is "in_priority_arbiter.txt";
    variable myoutline : line;
    variable leer : character;
    variable var1, var2 : std_logic;
    variable varx1 : std_logic_vector(2 downto 0);
    variable varx2, varx3 : std_logic_vector(7 downto 0);
    begin
    if falling_edge(CLK) then
      if (not endfile(protokoll)) then
        readline(protokoll,myoutline);

        read(myoutline,varx2);
        read_f1 <= varx2;
        read(myoutline,leer);
        
        read(myoutline,var1);
        rol_mask <= var1;
        
      end if;
    end if;
 end process STIMULI;

  
end trb_net_priority_arbiter_testbench_arch;

-- fuse -prj trb_net_priority_arbiter_testbench_beh.prj  -top trb_net_priority_arbiter_testbench -o trb_net_priority_arbiter_testbench

-- trb_net_priority_arbiter_testbench -tclbatch priority_arbiter_testsim.tcl

-- isimwave isimwavedata.xwv

