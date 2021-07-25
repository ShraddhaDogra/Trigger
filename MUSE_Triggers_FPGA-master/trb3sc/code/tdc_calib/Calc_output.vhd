library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity calc_output is
    Port (       
        CLK	       : in  std_logic;
        DIN_in 	       : in  std_logic_vector(31 downto 0);
        DIN_in_b_r     : in  std_logic;
        DIN_in_data_w  : in  std_logic;
        DIN_in_data_f  : in  std_logic;
        do_cal_in      : in  std_logic;
        overshoot_in   : in  std_logic := '0';
        undershoot_in  : in  std_logic := '0';
        slope          : in  std_logic_vector(11 downto 0);
        factor         : in  std_logic_vector( 9 downto 0);
        DIN_out	       : out std_logic_vector(31 downto 0);
        DIN_out_b_r    : out std_logic;
        DIN_out_data_w : out std_logic;
        DIN_out_data_f : out std_logic;
        do_cal_out     : out std_logic;
        overshoot_out  : out std_logic := '0';
        undershoot_out : out std_logic := '0';
        Cal_Data_out   : out std_logic_vector(21 downto 0)
          );
end calc_output;

architecture Behavioral of calc_output is
  
begin
 cnt : process (CLK,factor,slope)
 begin
  if rising_edge(CLK) then
   
   Cal_Data_out    <= std_logic_vector( (unsigned(factor) * unsigned(slope)) + to_unsigned(512,9));
   DIN_out	   <= DIN_in;
   DIN_out_b_r	   <= DIN_in_b_r;
   DIN_out_data_w  <= DIN_in_data_w;
   DIN_out_data_f  <= DIN_in_data_f;
   do_cal_out	   <= do_cal_in;
   overshoot_out   <= overshoot_in;
   undershoot_out  <= undershoot_in;
   
  end if; 
 end process;

end Behavioral;
