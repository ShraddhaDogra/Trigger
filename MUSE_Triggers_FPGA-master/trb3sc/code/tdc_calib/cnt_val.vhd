library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cnt_val is
    Port (       
        CLK	       : in  std_logic;
        read           : in  std_logic;
        write          : in  std_logic;
        FPGA_read      : in  std_logic_vector( 3 downto 0);
        chnl_read      : in  std_logic_vector( 6 downto 0);
        FPGA_write     : in  std_logic_vector( 3 downto 0);
        chnl_write     : in  std_logic_vector( 6 downto 0);
        cal_cnt        : in  unsigned(19 downto 0);
        DIN_in 	       : in  std_logic_vector(31 downto 0);
        DIN_in_b_r     : in  std_logic;
        DIN_in_data_w  : in  std_logic;
        DIN_in_data_f  : in  std_logic;
        cal_cnt_out    : out unsigned(19 downto 0);
        DIN_out	       : out std_logic_vector(31 downto 0);
        DIN_out_b_r    : out std_logic;
        DIN_out_data_w : out std_logic;
        DIN_out_data_f : out std_logic
          );
end cnt_val;

architecture Behavioral of cnt_val is

  type unsigned_2D is array (15 downto 0, 63 downto 0) of unsigned (19 downto 0); --(channel)
  signal cal_cnt_i   : unsigned_2D := (others => (others => "00000000000000000000"));
  
begin
 cnt : process (CLK,read,write)
 begin
  if rising_edge(CLK) then
   if (read = '1') then --read
	if (FPGA_read /= FPGA_write) or (chnl_read /= chnl_write) then
	   cal_cnt_out <= cal_cnt_i(to_integer(unsigned(FPGA_read)),to_integer(unsigned(chnl_read)));
	else
	   cal_cnt_out <= cal_cnt;-- if channel/fpage is same as 2 inputs before
	end if;
   end if;
   if (write = '1') then --write
      cal_cnt_i(to_integer(unsigned(FPGA_write)),to_integer(unsigned(chnl_write))) <= cal_cnt;
   end if;
      
   DIN_out	   <= DIN_in;
   DIN_out_b_r	   <= DIN_in_b_r;
   DIN_out_data_w  <= DIN_in_data_w;
   DIN_out_data_f  <= DIN_in_data_f;
   
  end if; 
 end process;

end Behavioral;
