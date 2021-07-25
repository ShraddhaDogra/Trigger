library ieee;

use ieee.std_logic_1164.all;

USE ieee.std_logic_signed.ALL;

USE ieee.std_logic_arith.ALL;

USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;

entity trb_net_ibuf_testbench is

end trb_net_ibuf_testbench;

architecture trb_net_ibuf_testbench_arch of trb_net_ibuf_testbench is

  signal clk : std_logic := '0';
  signal reset : std_logic := '1';

  signal med_dataready_in: std_logic := '0';
  signal med_data_in     : std_logic_vector(50 downto 0) := (others => '0');
  signal med_read_out    : std_logic := '0';

  signal int_header_in   : std_logic := '0';
  signal int_dataready_out: std_logic := '0';
  signal int_data_out     : std_logic_vector(50 downto 0) := (others => '0');
  signal int_read_in     : std_logic := '0';

  signal write_data_out     : std_logic_vector(51 downto 0) := (others => '0');
  
  signal read_type : std_logic_vector(2 downto 0) := (others => '0');
  signal read_f2   : std_logic_vector(3 downto 0) := (others => '0');
  signal read_f1   : std_logic_vector(3 downto 0) := (others => '0');
  signal stat_buffer  : std_logic_vector(31 downto 0) := (others => '0');
  signal stat_locked  : std_logic_vector(15 downto 0) := (others => '0');
  
  signal waiter : std_logic := '0';
  
  
  component trb_net_ibuf 
    
   generic (DEPTH : integer := 3);     -- Depth of the FIFO, 2^(n+1)

  port(
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;
    --  Media direction port
    MED_DATAREADY_IN:  in  STD_LOGIC; -- Data word is offered by the Media (the IOBUF MUST read)
    MED_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
    MED_READ_OUT:      out STD_LOGIC; -- buffer reads a word from media
    MED_ERROR_IN:      in  STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    -- Internal direction port
    INT_HEADER_IN:     in  STD_LOGIC; -- Concentrator kindly asks to resend the last header
    INT_DATAREADY_OUT: out STD_LOGIC;
    INT_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_READ_IN:       in  STD_LOGIC; 
    INT_ERROR_OUT:     out STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    -- Status and control port
    STAT_LOCKED:       out STD_LOGIC_VECTOR (15 downto 0);
    CTRL_LOCKED:       in  STD_LOGIC_VECTOR (15 downto 0);
    STAT_BUFFER:       out STD_LOGIC_VECTOR (31 downto 0)
          );     
  end component;
  
begin

  IBUF : trb_net_ibuf
    port map (
      CLK             => clk,
      RESET           => reset,
      CLK_EN          => '1',

      MED_DATAREADY_IN => med_dataready_in,
      MED_DATA_IN     => med_data_in,
      MED_READ_OUT    => med_read_out,
      MED_ERROR_IN    => (others => '0'),
      INT_HEADER_IN   => int_header_in,
      INT_DATAREADY_OUT =>int_dataready_out,
      INT_DATA_OUT    => int_data_out,
      INT_READ_IN     => int_read_in,
      CTRL_LOCKED     => (others => '0'),
      STAT_BUFFER => stat_buffer,
      STAT_LOCKED => stat_locked
      );
  
  clk <= not clk after 10ns;
  --med_data_in <= (50 downto 48 => read_type, 35 downto 32 => read_f1, others => '0');
  --med_data_in <= (others => '0');
  med_data_in(50 downto 48) <= read_type;
  med_data_in(19 downto 16) <= read_f2;
  med_data_in(3 downto 0) <= read_f1;
  

  
  
  DO_RESET : process
  begin
    reset <= '1';
    wait for 30ns;
    reset <= '0';
    wait;
  end process DO_RESET;

  STIMULI: process (clk)
    file protokoll : text open read_mode is "in_ibuf.txt";
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
        med_dataready_in <= var1;
        read(myoutline,leer);
        
        read(myoutline,varx1);
        read_type <= varx1;
        read(myoutline,leer);

        read(myoutline,varx2);
        read_f2 <= varx2;
        read(myoutline,leer);

        read(myoutline,varx3);
        read_f1 <= varx3;
        
      end if;
    end if;
 end process STIMULI;

--    int_read_in <= int_dataready_out after 5ns;
    
READ_BUF: process
    file protokoll : text open read_mode is "out_ibuf.txt";
    variable myoutline : line;
    variable leer : character;
    variable var1, var2 : std_logic;
    variable varx1 : std_logic_vector(2 downto 0);
    variable varx2, varx3 : std_logic_vector(3 downto 0);
    begin
      wait on CLK;
      if rising_edge(CLK) then
        wait for 5ns;
        if (not endfile(protokoll)) then
          readline(protokoll,myoutline);
          read(myoutline,var1);
          read(myoutline,leer);
          read(myoutline,var2);

          if var1 = '1' and var2 = '0' then

            if int_dataready_out = '0' then
              int_read_in <= '0';
              waiter <= '1';
              wait until int_dataready_out = '1';
              waiter <= '0';
            end if;
            wait for 5ns;
            int_read_in <= '1';
            int_header_in <= '0';

          elsif var1 = '1' and var2 = '1' then
            wait for 5ns;
            int_read_in <= '1';
            int_header_in <= '1';
          else
            int_read_in <= '0';
            int_header_in <= '0';
          end if;
          
        end if;
    end if;
 end process;


    write_data_out(50 downto 0)<= int_data_out;
    write_data_out(51) <=  '0';
    
    RESPONSE: process (clk)
     file protokoll : text open write_mode is "result_out_ibuf.txt";
     variable myoutline : line;
   
   begin  -- process RESPONSE
     if rising_edge(CLK) and int_read_in='1' then  -- rising clock edge and I'm
                                                   -- reading
       hwrite (myoutline, write_data_out(51 downto 0));
       writeline(protokoll, myoutline);
     end if;
   end process RESPONSE;
  
  
end trb_net_ibuf_testbench_arch;


-- fuse -prj trb_net_ibuf_testbench_beh.prj  -top trb_net_ibuf_testbench -o trb_net_ibuf_testbench

-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/trb_net_std.vhd" 
-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/trb_net_fifo.vhd"
-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/xilinx/arch_trb_net_fifo.vhd"
-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/xilinx/generic_fifo.vhd"   
-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/xilinx/generic_shift.vhd"  
-- vhdl work "/home/hadaq/acromag/design/DX2002test/trbnet/trb_net_fifo_testbench.vhd"

-- trb_net_ibuf_testbench -tclbatch testsim.tcl

-- ntrace select -o on -m / -l this
-- ntrace start
-- run 1000 ns
-- quit

-- isimwave isimwavedata.xwv

