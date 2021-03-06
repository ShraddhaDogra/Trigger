library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.trb_net_std.all;

entity compare_old is
    Port ( CLK   	  : in  std_logic;
           DIN_in 	  : in  std_logic_vector(31 downto 0);
           DIN_in_b_r 	  : in  std_logic;
           DIN_in_data_w  : in  std_logic;
           DIN_in_data_f  : in  std_logic;
           FPGA_in   	  : in  std_Logic_vector( 3 downto 0);
           CHNL_in	  : in  std_logic_vector( 6 downto 0);
           Do_Cal_in	  : in  std_Logic;
           CHNL_out  	  : out std_logic_vector( 6 downto 0);
           FPGA_out 	  : out std_logic_vector( 3 downto 0);
           DIN_out	  : out std_logic_vector(31 downto 0);
           DIN_out_b_r 	  : out std_logic;
           DIN_out_data_w : out std_logic;
           DIN_out_data_f : out std_logic;
           Do_Cal_out	  : out std_logic;
           read		  : out std_logic
     );
end compare_old;

architecture Behavioral of compare_old is

  signal FPGA_i : std_logic_vector( 3 downto 0):="0001";
  signal CHNL_i : std_logic_vector( 6 downto 0);
  
begin

  rd_cnt : process(CLK)
  begin
    if rising_edge(CLK) then
        
        if (Do_Cal_in = '1') then
	  if (FPGA_in = FPGA_i) and (CHNL_in = CHNL_i) then  -- same channel and fpga as before, no need to reread
	    read     <= '0';
	    FPGA_out <= FPGA_i;
	    CHNL_out <= CHNL_i;
	  else				-- different fpga/channel -> read again!
	    read     <= '1';
	    FPGA_i   <= FPGA_in;
	    CHNL_i   <= CHNL_in;
	    FPGA_out <= FPGA_in;
	    CHNL_out <= CHNL_in;
	  end if;
	else
	
	  read	    <= '0';
        end if;
        --loop through entity
        DIN_out 	  <= DIN_in;
        DIN_out_b_r	  <= DIN_in_b_r;
        DIN_out_data_w	  <= DIN_in_data_w;
        DIN_out_data_f 	  <= DIN_in_data_f;
        Do_Cal_out	  <= Do_Cal_in;
    end if;
  end process;

end Behavioral;
