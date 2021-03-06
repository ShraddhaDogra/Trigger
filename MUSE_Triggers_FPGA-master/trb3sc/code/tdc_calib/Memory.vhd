library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Memory is
    Port (
        CLK	    : in  std_logic;
        read        : in  std_logic;
        write       : in  std_logic;
        FPGA_read   : in  std_logic_vector(3 downto 0);
        chnl_read   : in  std_logic_vector(6 downto 0);
        FPGA_write  : in  std_logic_vector(3 downto 0);
        chnl_write  : in  std_logic_vector(6 downto 0);
        Min         : in  std_logic_vector(9 downto 0);
        Max         : in  std_logic_vector(9 downto 0);
        Do_Cal_in   : in  std_logic;
        DIN_data    : in  std_logic_vector(31 downto 0);
        DIN_b_r     : in  std_logic;
        DIN_data_w  : in  std_logic;
        DIN_data_f  : in  std_logic;
	Min_out     : out std_logic_vector(9 downto 0):= "1111111111";
        Max_out     : out std_logic_vector(9 downto 0):= "0000000000"
    );
end Memory;

architecture Behavioral of Memory is

  type array2D is array (15 downto 0, 63 downto 0) of std_logic_vector(9 downto 0); --(FPGA)(channel)
  signal Max_Bin_i : array2D := (others => (others => ("0000000000")));
  signal Min_Bin_i : array2D := (others => (others => ("1111111101")));
  
begin

  mem : process (CLK,read,write)
  begin
   if rising_edge(CLK) then
        
    if (read = '1' and Do_Cal_in = '1') then --read
      if (FPGA_read = FPGA_write) and (chnl_read = chnl_write) then
	Max_out <= Max;
	Min_out <= Min;
      else
	Max_out <= Max_Bin_i(to_integer(unsigned(FPGA_read)),to_integer(unsigned(chnl_read)));
        Min_out <= Min_Bin_i(to_integer(unsigned(FPGA_read)),to_integer(unsigned(chnl_read)));
      end if;  
    end if;   
    if (write = '1') then --write
       Max_Bin_i(to_integer(unsigned(FPGA_write)),to_integer(unsigned(chnl_write))) <= Max;
       Min_Bin_i(to_integer(unsigned(FPGA_write)),to_integer(unsigned(chnl_write))) <= Min;
    end if;
    
    
   end if;
  end process;
  
end Behavioral;
