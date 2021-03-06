----------------------------------------------------------------------------------
-- Company: JLU Giessen
-- Engineer: Adrian Weber
-- 
-- Create Date: 06.01.2017 13:32:05
-- Module Name: Calibration - Behavioral
-- Project Name: TDC Calibration
-- Target Devices: TrbSc
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.trb_net_std.all;

entity Calibration is
    Port ( 
        CLK      : in  std_logic;
        DIN      : in  READOUT_TX;
        DOUT     : out READOUT_TX;
        BUS_RX   : in  CTRLBUS_RX;
        BUS_TX   : out CTRLBUS_TX
    );
end Calibration;

architecture Behavioral of Calibration is
  signal Dout_int 	   		: std_logic_vector(21 downto 0);
  signal DIN_i_Mem         		: std_logic_vector(31 downto 0) := (others => '0');
  signal DIN_i_Mem_b_r     		: std_logic;
  signal DIN_i_Mem_data_w  		: std_logic;
  signal DIN_i_Mem_data_f  		: std_logic;
  signal Default_val_Mem   		: std_logic;
  signal DIN_o_Lim         		: std_logic_vector(31 downto 0) := (others => '0');
  signal DIN_o_Lim_b_r     		: std_logic;
  signal DIN_o_Lim_data_w  		: std_logic;
  signal DIN_o_Lim_data_f  		: std_logic; 
  signal min_out_Lim  			: std_logic_vector( 9 downto 0) := (others => '0');
  signal max_out_Lim  			: std_logic_vector( 9 downto 0) := (others => '0');
  signal Delta_Lim    			: std_logic_vector( 9 downto 0) := "0110110100";
  signal min_next_Lim 			: std_logic_vector( 9 downto 0) := (others => '0');
  signal max_next_Lim 			: std_logic_vector( 9 downto 0) := (others => '0');
  signal min_curr_Lim 			: std_logic_vector( 9 downto 0) := (others => '0');
  signal max_curr_Lim 			: std_logic_vector( 9 downto 0) := (others => '0');
  signal FPGA_Lim 			: std_logic_vector( 3 downto 0) ;
  signal chnl_Lim 			: std_logic_vector( 6 downto 0) := (others => '0');
  signal do_cal_LIM       		: std_logic;
  signal DIN_o_LUT        		: std_logic_vector(31 downto 0) := (others => '0');
  signal DIN_o_LUT_b_r    		: std_logic;
  signal DIN_o_LUT_data_w 		: std_logic;
  signal DIN_o_LUT_data_f 		: std_logic;
  signal min_out_LUT      		: std_logic_vector( 9 downto 0) := (others => '0');
  signal max_out_LUT      		: std_logic_vector( 9 downto 0) := (others => '1');
  signal Delta_LUT        		: std_logic_vector( 9 downto 0) := (others => '0');
  signal slope_LUT        		: std_logic_vector(11 downto 0) := (others => '0');
  signal cal_flag_LUT     		: std_logic := '0';
  signal cal_flag_LUT_out 		: std_logic := '0';
  signal FPGA_in_LUT      		: std_logic_vector( 3 downto 0);
  signal read_next        		: std_logic;
  signal write_next       		: std_logic;
  signal read_vld_next    		: std_logic; 
  signal write_vld_next   		: std_logic;   
  signal FPGA_next        		: std_logic_vector( 3 downto 0);
  signal chnl_next        		: std_logic_vector( 6 downto 0);
  signal min_next         		: std_logic_vector( 9 downto 0);
  signal max_next         		: std_logic_vector( 9 downto 0);
  signal min_in_next      		: std_logic_vector( 9 downto 0);
  signal max_in_next      		: std_logic_vector( 9 downto 0); 
  signal read_curr       		: std_logic;    
  signal write_curr       		: std_logic;
  signal FPGA_curr        		: std_logic_vector( 3 downto 0);
  signal chnl_curr        		: std_logic_vector( 6 downto 0);
  signal min_curr         		: std_logic_vector( 9 downto 0);
  signal max_curr         		: std_logic_vector( 9 downto 0);
  signal min_in_curr      		: std_logic_vector( 9 downto 0);
  signal max_in_curr      		: std_logic_vector( 9 downto 0); 
  signal factor           		: std_logic_vector( 9 downto 0);
  signal DIN_o_cnt        		: std_logic_vector(31 downto 0);
  signal DIN_o_cnt_b_r    		: std_logic;
  signal DIN_o_cnt_data_w 		: std_logic;
  signal DIN_o_cnt_data_f 		: std_logic;
  signal FPGA_o_cnt       		: std_logic_vector( 3 downto 0);
  signal read_cal_cnt     		: std_logic;
  signal read_dflt_cnt    		: std_logic;
  signal chnl_read_cnt    		: std_logic_vector( 6 downto 0);
  signal write_cal_cnt 			: std_logic;
  signal write_dflt_cnt			: std_logic;
  signal dflt_cnt_in 			: std_logic;
  signal dflt_cnt_out  			: std_logic;
  signal cal_cnt_in 			: unsigned(19 downto 0);
  signal cal_cnt_out 			: unsigned(19 downto 0);   
  signal FPGA_cnt_val 			: std_logic_vector( 3 downto 0);
  signal chnl_cnt_val 			: std_logic_vector( 6 downto 0);
  signal DIN_o_cnt_val        		: std_logic_vector(31 downto 0);
  signal DIN_o_cnt_val_b_r    		: std_logic;
  signal DIN_o_cnt_val_data_w 		: std_logic;
  signal DIN_o_cnt_val_data_f 		: std_logic;
  signal DIN_MemCurr_data   		: std_logic_vector(31 downto 0);
  signal DIN_MemCurr_b_r    		: std_logic;
  signal DIN_MemCurr_data_w 		: std_logic;
  signal DIN_MemCurr_data_f 		: std_logic;
  signal Do_Cal_read_cnt    		: std_logic;
  signal Do_Cal_compare_old 		: std_logic;
  signal DIN_out_data_compare_old	: std_logic_vector(31 downto 0);
  signal DIN_out_b_r_compare_old	: std_logic;
  signal DIN_out_data_w_compare_old	: std_logic;
  signal DIN_out_data_f_compare_old	: std_logic;
  signal read_compare_old		: std_logic;
  signal CHNL_out_compare_old		: std_logic_vector( 6 downto 0);
  signal FPGA_out_compare_old		: std_logic_vector( 3 downto 0);
  signal CHNL_out_Memory		: std_logic_vector( 6 downto 0);
  signal FPGA_out_Memory		: std_logic_vector( 3 downto 0);
  signal Do_Cal_Memory			: std_logic;
  signal write_chnl_cnt			: std_logic;
  signal new_data_Memory		: std_logic;
  signal chnl_out_write			: std_logic_vector( 6 downto 0);
  signal FPGA_out_write			: std_logic_vector( 3 downto 0);
  signal BUS_do_Cal			: std_logic := '1';
  signal overshoot_LUT			: std_logic := '0';
  signal undershoot_LUT			: std_logic := '0';
  signal Cal_Limit_reg			: unsigned(19 downto 0) := "00011000011010100000";
  signal cal_Limit_set			: unsigned(19 downto 0);    
  signal Do_cal_CalcOut			: std_logic := '0';
  signal DIN_o_CalcOut        		: std_logic_vector(31 downto 0);
  signal DIN_o_CalcOut_b_r    		: std_logic;
  signal DIN_o_CalcOut_data_w 		: std_logic;
  signal DIN_o_CalcOut_data_f 		: std_logic;
  signal overshoot_CalcOut		: std_logic := '0';
  signal undershoot_CalcOut		: std_logic := '0';
  signal Bus_Chnl			: std_logic_vector( 6 downto 0);
  signal Bus_min			: std_logic_vector( 9 downto 0);
  signal Bus_max			: std_logic_vector( 9 downto 0); 
  signal FPGA_out_curr 			: std_logic_vector( 3 downto 0);
  signal chnl_out_curr 			: std_logic_vector( 6 downto 0);
  signal BUS_Flash_value 		: std_logic_vector(27 downto 0);
  signal Flash_flag 			: std_logic;
  
begin

--BUS Handler
proc_reg : process begin
  wait until rising_edge(CLK);
  BUS_TX.ack     <= '0';
  BUS_TX.nack    <= '0';
  BUS_TX.unknown <= '0';
  Flash_flag	 <= '0';
  
  if BUS_RX.write = '1' then
    BUS_TX.ack <= '1';
    if BUS_RX.addr(11 downto 0) > x"006" and BUS_RX.addr(11 downto 0) < x"048" then
       BUS_Flash_value <= std_logic_vector(unsigned(BUS_RX.addr(7 downto 0))-7) & BUS_RX.data(19 downto 10) & BUS_RX.data(9 downto 0);
       Flash_flag <= '1';
    else
      case BUS_RX.addr(11 downto 0) is
	when x"000"   => BUS_do_Cal    <= BUS_RX.data(0);   			-- change between w/ and w/o FPGA based Calibration
	when x"001"   => Cal_Limit_reg <= unsigned(BUS_RX.data(19 downto 0));   -- Set Maximum Value for Calibration Counter
	when x"003"   => Bus_Chnl      <= BUS_RX.data(6 downto 0);		-- set channel for Min/Max Output
	when others   => BUS_TX.ack    <= '0'; BUS_TX.unknown <= '1';
      end case;
    end if;  
  elsif BUS_RX.read = '1' then
    BUS_TX.ack <= '1';
    case BUS_RX.addr(11 downto 0) is
      when x"000"   => BUS_TX.data(31 downto  1) <= "0000000000000000000000000000000";
		       BUS_TX.data(0) <= BUS_do_Cal;
      when x"001"   => BUS_TX.data(31 downto 20) <= "000000000000";
		       BUS_TX.data(19 downto  0) <= std_logic_vector(cal_Limit_set);
      when x"004"   => BUS_TX.data(31 downto 10) <= "0000000000000000000000";
		       BUS_TX.data( 9 downto  0) <= Bus_min;
      when x"005"   => BUS_TX.data(31 downto 10) <= "0000000000000000000000";
		       BUS_TX.data( 9 downto  0) <= Bus_max;
      when others   => BUS_TX.ack <= '0'; BUS_TX.unknown <= '1';
    end case;
  end if;
end process;



read_cntr : entity work.read_cnt
   port map(
       CLK           	=> CLK,
       chnl          	=> chnl_read_cnt,
       FPGA_out      	=> FPGA_o_cnt,
       DIN_in 	     	=> DIN_i_Mem,
       DIN_in_b_r    	=> DIN_i_Mem_b_r,
       DIN_in_data_w 	=> DIN_i_Mem_data_w,
       DIN_in_data_f 	=> DIN_i_Mem_data_f,
       DIN_out	     	=> DIN_o_cnt,
       DIN_out_b_r   	=> DIN_o_cnt_b_r,
       DIN_out_data_w	=> DIN_o_cnt_data_w,
       DIN_out_data_f	=> DIN_o_cnt_data_f,
       Do_Cal	 	=> Do_Cal_read_cnt
   );

 
 ent_compare_old : entity work.compare_old
   port map(
      CLK   	  	=> CLK,
      DIN_in 	  	=> DIN_o_cnt,
      DIN_in_b_r 	=> DIN_o_cnt_b_r,
      DIN_in_data_w  	=> DIN_o_cnt_data_w,
      DIN_in_data_f  	=> DIN_o_cnt_data_f,
      FPGA_in   	=> FPGA_o_cnt,
      CHNL_in	  	=> chnl_read_cnt,
      Do_Cal_in	  	=> Do_Cal_read_cnt,
      CHNL_out  	=> CHNL_out_compare_old,
      FPGA_out 		=> FPGA_out_compare_old,
      DIN_out		=> DIN_out_data_compare_old,
      DIN_out_b_r 	=> DIN_out_b_r_compare_old,
      DIN_out_data_w 	=> DIN_out_data_w_compare_old,
      DIN_out_data_f 	=> DIN_out_data_f_compare_old,
      Do_Cal_out	=> Do_Cal_compare_old,
      read		=> read_compare_old   
   );
   
ent_cnt_val : entity work.cnt_val
   port map(
      CLK 	     => CLK,
      read           => read_compare_old,
      write          => write_chnl_cnt,
      FPGA_read      => FPGA_out_compare_old,
      chnl_read      => CHNL_out_compare_old,
      FPGA_write     => FPGA_out_write,
      chnl_write     => chnl_out_write,
      cal_cnt        => cal_cnt_in, 
      cal_cnt_out    => cal_cnt_out,
      DIN_in 	     => DIN_out_data_compare_old,
      DIN_in_b_r     => DIN_out_b_r_compare_old,
      DIN_in_data_w  => DIN_out_data_w_compare_old,
      DIN_in_data_f  => DIN_out_data_f_compare_old,
      DIN_out	     => DIN_o_cnt_val,
      DIN_out_b_r    => DIN_o_cnt_val_b_r,
      DIN_out_data_w => DIN_o_cnt_val_data_w,
      DIN_out_data_f => DIN_o_cnt_val_data_f     
   );

ent_dflt_val : entity work.dflt_val
   port map(
      CLK	   => CLK,
      read         => read_compare_old,
      FPGA_read    => FPGA_out_compare_old,
      chnl_read	   => CHNL_out_compare_old,
      dflt_out     => Default_val_Mem
   );
   

 Mem_next : entity work.Memory
   port map(
    CLK	      	=> CLK,
    read      	=> read_compare_old,
    write     	=> write_next,
    FPGA_read   => FPGA_out_compare_old,
    chnl_read   => CHNL_out_compare_old,
    FPGA_write  => FPGA_out_write,
    chnl_write  => chnl_out_write,
    min       	=> min_next_Lim,
    max       	=> max_next_Lim,
    min_out   	=> min_next,
    max_out   	=> max_next,
    Do_Cal_in	=> Do_Cal_compare_old,
    DIN_data    => DIN_out_data_compare_old,
    DIN_b_r     => DIN_out_b_r_compare_old,
    DIN_data_w  => DIN_out_data_w_compare_old,
    DIN_data_f  => DIN_out_data_f_compare_old
  );

 Mem_curr : entity work.Memory_curr
  port map(
    CLK	        => CLK,
    read        => read_compare_old,
    write       => write_curr,
    FPGA_read   => FPGA_out_compare_old,
    chnl_read   => CHNL_out_compare_old,
    FPGA_write  => FPGA_out_curr,
    chnl_write  => chnl_out_curr,
    min         => min_curr_Lim,
    max         => max_curr_Lim,
    min_out     => min_curr,
    max_out     => max_curr,
    Do_Cal_in	=> Do_Cal_compare_old,
    DIN_data    => DIN_out_data_compare_old,
    DIN_b_r     => DIN_out_b_r_compare_old,
    DIN_data_w  => DIN_out_data_w_compare_old,
    DIN_data_f  => DIN_out_data_f_compare_old,
    DOUT_data   => DIN_MemCurr_data,
    DOUT_b_r    => DIN_MemCurr_b_r,
    DOUT_data_w => DIN_MemCurr_data_w,
    DOUT_data_f => DIN_MemCurr_data_f,
    FPGA_out	=> FPGA_out_Memory,
    CHNL_out	=> CHNL_out_Memory,
    Do_Cal_out	=> Do_Cal_Memory,
    new_data	=> new_data_Memory
  );

 Cal_Limits : entity work.Cal_Limits_v2
    generic map(
	cal_Limit_gen	=> "00000010011100010000" -- 10.000
    )
    port map(
        CLK            	=> CLK,
        cal_Limit_reg	=> Cal_Limit_reg,
        DIN_in         	=> DIN_MemCurr_data,
        DIN_in_b_r     	=> DIN_MemCurr_b_r,
        DIN_in_data_w  	=> DIN_MemCurr_data_w,
        DIN_in_data_f  	=> DIN_MemCurr_data_f,
        min_curr_in    	=> min_curr,
        max_curr_in    	=> max_curr,
        min_next_in    	=> min_next,
        max_next_in    	=> max_next,
        FPGA           	=> FPGA_out_Memory,
        FPGA_next      	=> FPGA_out_compare_old,
        chnl           	=> CHNL_out_Memory,
        chnl_next      	=> CHNL_out_compare_old,
        Do_Cal_in      	=> Do_Cal_Memory,
        chnl_cnt_in    	=> cal_cnt_out,
        new_data	=> new_data_Memory,
        write_curr     	=> write_curr,
        write_next     	=> write_next,
        min_next       	=> min_next_Lim,
        max_next       	=> max_next_Lim,
        min_curr       	=> min_curr_Lim,
        max_curr       	=> max_curr_Lim,
        min_out        	=> min_out_Lim,
        max_out        	=> max_out_Lim,
        Delta          	=> Delta_Lim,
        FPGA_out       	=> FPGA_Lim,
        chnl_out       	=> chnl_Lim,
        DIN_out        	=> DIN_o_Lim,
        DIN_out_b_r    	=> DIN_o_Lim_b_r,
        DIN_out_data_w 	=> DIN_o_Lim_data_w,
        DIN_out_data_f 	=> DIN_o_Lim_data_f,
        Do_Cal_out     	=> do_cal_LIM,
        chnl_cnt_out	=> cal_cnt_in,
        write_chnl_cnt  => write_chnl_cnt,
        chnl_out_write  => chnl_out_write,
        FPGA_out_write  => FPGA_out_write,
        FPGA_out_curr  	=> FPGA_out_curr,
        chnl_out_curr 	=> chnl_out_curr,
        cal_Limit_set   => cal_Limit_set,
        BUS_Flash_value => BUS_Flash_value,
        Flash_flag	=> Flash_flag
    );
    
 LUTs : entity work.LUT
    port map(
        CLK            => CLK,
        DIN_in         => DIN_o_Lim,
        DIN_in_b_r     => DIN_o_Lim_b_r,
        DIN_in_data_w  => DIN_o_Lim_data_w,
        DIN_in_data_f  => DIN_o_Lim_data_f,
        Delta          => Delta_Lim,
        min_in         => min_out_Lim,
        max_in         => max_out_Lim,
        do_cal_in      => do_cal_LIM,
        min_out        => min_out_LUT,
        max_out        => max_out_LUT,
        DIN_out        => DIN_o_LUT,
        DIN_out_b_r    => DIN_o_LUT_b_r,
        DIN_out_data_w => DIN_o_LUT_data_w,
        DIN_out_data_f => DIN_o_LUT_data_f,
        slope          => slope_LUT,
        do_cal_out     => cal_flag_LUT_out,
        factor         => factor,
        overshoot      => overshoot_LUT,
        undershoot     => undershoot_LUT
    );
    
 Calc_Output : entity work.calc_output
    port map(
        CLK	       => CLK,
        DIN_in 	       => DIN_o_LUT,
        DIN_in_b_r     => DIN_o_LUT_b_r,
        DIN_in_data_w  => DIN_o_LUT_data_w,
        DIN_in_data_f  => DIN_o_LUT_data_f,
        do_cal_in      => cal_flag_LUT_out,
        overshoot_in   => overshoot_LUT,
        undershoot_in  => undershoot_LUT,
        slope          => slope_LUT,
        factor         => factor,
        DIN_out	       => DIN_o_CalcOut,
        DIN_out_b_r    => DIN_o_CalcOut_b_r,
        DIN_out_data_w => DIN_o_CalcOut_data_w,
        DIN_out_data_f => DIN_o_CalcOut_data_f,
        do_cal_out     => Do_cal_CalcOut,
        overshoot_out  => overshoot_CalcOut,
        undershoot_out => undershoot_CalcOut,
        Cal_Data_out   => Dout_int
    );
    

  DIN_i_Mem         <= DIN.data;
  DIN_i_Mem_b_r     <= DIN.busy_release;
  DIN_i_Mem_data_w  <= DIN.data_write;
  DIN_i_Mem_data_f  <= DIN.data_finished;
 
  
  fine_out : process (CLK, Do_cal_CalcOut, slope_LUT, factor)
  begin  
  if rising_edge(CLK) then

    if ((Do_cal_CalcOut = '1') and (BUS_do_Cal = '1')) then
        DOUT.data(31 downto 22) <= DIN_o_CalcOut(31 downto 22);
	DOUT.data(11 downto  0) <= DIN_o_CalcOut(11 downto  0);
        if ((overshoot_CalcOut = '0') and (undershoot_CalcOut = '0')) then
	  DOUT.data(21 downto 12) <= Dout_int(19 downto 10);
	elsif (undershoot_CalcOut = '1') and (overshoot_CalcOut = '0') then
	  DOUT.data(21 downto 12) <= "1111110010";  --1010
	elsif (undershoot_CalcOut = '0') and (overshoot_CalcOut = '1') then
	  DOUT.data(21 downto 12) <= "1111110111";  --1015
	else
	  DOUT.data(21 downto 12) <= "1111111100";  --1020
        end if;
    else
        DOUT.data               <= DIN_o_CalcOut;
    end if;
    
    DOUT.busy_release   <= DIN_o_CalcOut_b_r;
    DOUT.data_write	<= DIN_o_CalcOut_data_w;
    DOUT.data_finished  <= DIN_o_CalcOut_data_f;
  end if;
  end process;
  
  
  debug : process (CLK)
  begin 
    if rising_edge(CLK) then
     if unsigned(Bus_Chnl) = unsigned(chnl_Lim) then
       Bus_min <= min_out_Lim;
       Bus_max <= max_out_Lim;
     end if;
    end if;
  end process;

  
  TX_statusbits : process (CLK)
  begin
  if rising_edge(CLK) then
    if (DIN.busy_release = '1') then
      DOUT.statusbits <= DIN.statusbits;
    end if;
  end if;
  end process;
  
end Behavioral;
