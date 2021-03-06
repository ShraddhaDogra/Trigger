library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.trb_net_std.all;

entity read_Memory is
    generic (
       calibration_value_max : unsigned(19 downto 0):="11111111111111111111"
    );
    Port ( 
        CLK             : in  std_logic;
        DIN             : in  std_logic_vector(31 downto 0);
        DIN_b_r		: in  std_logic;
        DIN_data_w	: in  std_logic;
        DIN_data_f	: in  std_logic;
        FPGA_in         : in  std_logic_vector( 3 downto 0);
        chnl_in         : in  std_logic_vector(6 downto 0);
        cal_cnt         : in  unsigned(19 downto 0);
        dflt_cnt        : in  std_logic;
        write_cal_cnt   : out std_logic;
        write_dflt_cnt  : out std_logic;
        cal_cnt_out     : out unsigned(19 downto 0);
        dflt_cnt_out    : out std_logic;
        read_next       : out std_logic;
        read_curr       : out std_logic;
        Cal_chng_flag   : out std_logic;
        do_cal          : out std_logic;
        FPGA            : out std_logic_vector( 3 downto 0);
        chnl            : out std_logic_vector( 6 downto 0);
        DIN_out         : out std_logic_vector(31 downto 0);
        DIN_out_b_r     : out std_logic;
        DIN_out_data_w  : out std_logic;
        DIN_out_data_f  : out std_logic;
        Default_val     : out std_logic--;
        --cal_cnt_dbug    : out unsigned(19 downto 0)
    );
end read_Memory;

architecture Behavioral of read_Memory is
 -- type unsigned_2D is array (3 downto 0,6 downto 0) of unsigned (7 downto 0); --(channel)
  --type bit_2D is array (3 downto 0,6 downto 0) of std_logic; --(channel)
  --signal cal_cnt   : unsigned_2D := (others => (others => "00000000"));
  --signal FPGA_i    : std_logic_vector(3 downto 0);
  --signal Default_val_i : bit_2D := (others => (others => '1'));
  signal dflt_cnt_last : std_logic;
begin

   Start_Calib : process (CLK)
   begin
     if rising_edge(CLK) then
         if DIN(31) = '1' then
            dflt_cnt_last <= dflt_cnt;
            --Do  Calibration
            do_cal <= '1';
            
            if cal_cnt = to_unsigned(0,20) then
                --lese Wert aus Mem_next
                if dflt_cnt = '1' then
                    Cal_chng_flag <= '0';
                    read_curr <= '0';
                    write_dflt_cnt <= '1'; -- gebe dflt_cnt auch die neue /alte adresse (FPGA und channel)
                    dflt_cnt_out <= '0';
                    Default_val <='1';
                else
                  if dflt_cnt_last = '0' then
                    write_dflt_cnt <= '0';
                    Cal_chng_flag <= '1';
                  end if;
                    Default_val <='0';
                    read_curr <= '1';
                end if;
                read_next <= '1';
                cal_cnt_out <= cal_cnt + 1 ;
            elsif cal_cnt < calibration_value_max then
                Default_val <='0';
                Cal_chng_flag <= '0';
                read_next <= '1';
                read_curr <= '1';
                cal_cnt_out <= cal_cnt + 1 ;
                write_dflt_cnt <= '0';
            else
                Default_val <= '0';
                Cal_chng_flag <= '0';
                read_next <= '1';
                read_curr <= '1';
                cal_cnt_out <= to_unsigned(0,20);--(others => '0');--"00000000000000000000";
                write_dflt_cnt <= '1';
                dflt_cnt_out <= '0';
            end if;
            write_cal_cnt <= '1';
            chnl <= DIN(28 downto 22);
            
         else -- DIN(31) = '0' -> no TDC
             write_dflt_cnt <= '0';
             do_cal  <= '0';
             read_next <= '0';
             read_curr <= '0';
             --FPGA_i  <= DIN( 3 downto 0);
             write_cal_cnt <= '0';    
             Default_val <='0';  
             Cal_chng_flag <= '0';
         end if;--DIN(31)
         
         DIN_out	 <= DIN;
         DIN_out_b_r	 <= DIN_b_r;
         DIN_out_data_w	 <= DIN_data_w;
         DIN_out_data_f  <= DIN_data_f;
         
         FPGA <= FPGA_in;
     end if; --rising_edge
   end process;
   
   
 --FPGA <= FPGA_i;
end Behavioral;
