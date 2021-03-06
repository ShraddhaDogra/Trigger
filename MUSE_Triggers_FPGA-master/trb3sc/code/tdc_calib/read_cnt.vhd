library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.trb_net_std.all;

entity read_cnt is
    Port ( CLK   	  : in  std_logic;
           DIN_in 	  : in  std_logic_vector(31 downto 0);
           DIN_in_b_r 	  : in  std_logic;
           DIN_in_data_w  : in  std_logic;
           DIN_in_data_f  : in  std_logic;
           chnl  	  : out std_logic_vector( 6 downto 0);
           FPGA_out 	  : out std_logic_vector( 3 downto 0);
           DIN_out	  : out std_logic_vector(31 downto 0);
           DIN_out_b_r 	  : out std_logic;
           DIN_out_data_w : out std_logic;
           DIN_out_data_f : out std_logic;
           Do_Cal	  : out std_logic
     );
end read_cnt;

architecture Behavioral of read_cnt is

  signal FPGA_i : std_logic_vector( 3 downto 0);
  
begin

  rd_cnt : process(CLK)
  begin
    if rising_edge(CLK) then
        if DIN_in(31) = '1' then
            chnl 	  <= DIN_in(28 downto 22);
            FPGA_out 	  <= FPGA_i;
            if DIN_in(21 downto 12) = "1111111111" then
               Do_Cal <= '0';
            else
               Do_Cal <= '1';
            end if;
        else
           FPGA_i 	  <= "0000";
           Do_Cal	  <= '0';
        end if;
        DIN_out 	  <= DIN_in;
        DIN_out_b_r	  <= DIN_in_b_r;
        DIN_out_data_w	  <= DIN_in_data_w;
        DIN_out_data_f 	  <= DIN_in_data_f;
    end if;
  end process;

end Behavioral;
