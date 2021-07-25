library ieee;

use ieee.std_logic_1164.all;

USE ieee.std_logic_signed.ALL;

USE ieee.std_logic_arith.ALL;

USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;

entity trb_net_io_multiplexer_testbench is

end trb_net_io_multiplexer_testbench;

architecture trb_net_io_multiplexer_testbench_arch of trb_net_io_multiplexer_testbench is

  signal clk : std_logic := '0';
  signal reset : std_logic := '1';

  signal read_type : std_logic_vector(2 downto 0) := (others => '0');
  signal read_f2   : std_logic_vector(3 downto 0) := (others => '0');
  signal read_f1   : std_logic_vector(7 downto 0) := (others => '0');
  signal rol_mask  : std_logic := '0';
  signal ctrl: std_logic_vector(31 downto 0) := (others => '0');

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
    MED_DATA_IN:       in  STD_LOGIC_VECTOR (BUS_WIDTH-1 downto 0);  -- highest
                                                                   -- bits are
                                                                   -- mult.
    MED_READ_OUT:      out STD_LOGIC; 

    MED_DATAREADY_OUT: out  STD_LOGIC; 
    MED_DATA_OUT:      out  STD_LOGIC_VECTOR (BUS_WIDTH-1 downto 0);  -- highest
                                                                   -- bits are
                                                                   -- mult.
    MED_READ_IN:       in STD_LOGIC;
    
    -- Internal direction port
    INT_DATAREADY_OUT: out STD_LOGIC_VECTOR (2**MULT_WIDTH-1 downto 0);
    INT_DATA_OUT:      out STD_LOGIC_VECTOR ((BUS_WIDTH-MULT_WIDTH)*(2**MULT_WIDTH)-1 downto 0);  
    INT_READ_IN:       in  STD_LOGIC_VECTOR (2**MULT_WIDTH-1 downto 0);

    INT_DATAREADY_IN:  in STD_LOGIC_VECTOR (2**MULT_WIDTH downto 0);
    INT_DATA_IN:       in STD_LOGIC_VECTOR ((BUS_WIDTH-MULT_WIDTH)*(2**MULT_WIDTH)-1 downto 0);  
    INT_READ_OUT:      out  STD_LOGIC_VECTOR (2**MULT_WIDTH-1 downto 0);

    
    
    -- Status and control port
    CTRL:              in  STD_LOGIC_VECTOR (31 downto 0);
    STAT:              out STD_LOGIC_VECTOR (31 downto 0)
    );

  end component;                                 

  signal med_dataready_in, med_read_in,med_read_out : std_logic := '0';
  signal med_data_in: STD_LOGIC_VECTOR(3 downto 0) := "0000";
  signal int_read : STD_LOGIC_VECTOR(3 downto 0) := "0000";
  signal int_dataready : STD_LOGIC_VECTOR(3 downto 0) := "0000";
  signal int_data : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
begin

  UUT: trb_net_io_multiplexer
    generic map (
      BUS_WIDTH => 4,
      MULT_WIDTH => 2
      )
    port map (
      CLK   =>clk,
      RESET => reset,
      CLK_EN => '1',
    
      MED_DATAREADY_IN => med_dataready_in,
      MED_DATA_IN      => med_data_in,
      MED_READ_IN => med_read_in,
      MED_READ_OUT => med_read_out,
    
      -- Internal direction port
      -- INT_READ_IN => (others =>  '0'),
      INT_READ_IN  => int_read,
      INT_READ_OUT => int_read,
      INT_DATAREADY_IN => int_dataready,
      INT_DATAREADY_OUT => int_dataready,
      INT_DATA_IN  => int_data,
      INT_DATA_OUT => int_data,

      CTRL => ctrl
      
      );
  
  clk <= not clk after 10ns;
--  ctrl(9) <= rol_mask;
  
  DO_RESET : process
  begin
    reset <= '1';
    wait for 30ns;
    reset <= '0';
    ctrl(8 downto 0) <= "100000000";  --only fixed
--    ctrl(8 downto 0) <= "111111111";  --only rr
--    ctrl(8 downto 0) <= "101010101";  --mixed
    wait for 20ns;
    ctrl(8 downto 0) <= "000000000";
    wait;
  end process DO_RESET;

  STIMULI: process (clk)
    file protokoll : text open read_mode is "in_io_multiplexer.txt";
    variable myoutline : line;
    variable leer : character;
    variable var1, var2 : std_logic;
    variable varx1 : std_logic_vector(2 downto 0);
    variable varx2, varx3 : std_logic_vector(3 downto 0);
    begin
    if falling_edge(CLK) and med_read_out = '1' then
      if (not endfile(protokoll)) then
        readline(protokoll,myoutline);

        read(myoutline,varx2);
        med_data_in <= varx2;
        read(myoutline,leer);
        
        read(myoutline,var1);
        med_dataready_in <= var1;
        read(myoutline,leer);

        read(myoutline,var2);
        med_read_in <= var2;
        
      end if;
    end if;
 end process STIMULI;

  
end trb_net_io_multiplexer_testbench_arch;

-- fuse -prj trb_net_io_multiplexer_testbench_beh.prj  -top trb_net_io_multiplexer_testbench -o trb_net_io_multiplexer_testbench

-- trb_net_io_multiplexer_testbench -tclbatch io_multiplexer_testsim.tcl

-- gtkwave vcdfile.vcd io_multiplexer_settings.sav

