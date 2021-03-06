library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.trb_net_std.all;

entity Cal_Limits is
    generic (
	cal_Limit_gen	: unsigned(19 downto 0) := "00000000000100000000"
    );    
    port (
        CLK            	: in  std_logic;
        cal_Limit_reg	: in  unsigned(19 downto 0);
        DIN_in        	: in  std_logic_vector(31 downto 0);
        DIN_in_b_r	: in  std_logic;
        DIN_in_data_w	: in  std_logic;
        DIN_in_data_f	: in  std_logic;
        min_curr_in    	: in  std_logic_vector( 9 downto 0);
        max_curr_in    	: in  std_logic_vector( 9 downto 0);
        min_next_in    	: in  std_logic_vector( 9 downto 0);
        max_next_in    	: in  std_logic_vector( 9 downto 0);
        FPGA           	: in  std_logic_vector( 3 downto 0);
        FPGA_next	: in  std_logic_vector( 3 downto 0);
        chnl           	: in  std_logic_vector( 6 downto 0);
        chnl_next      	: in  std_logic_vector( 6 downto 0);
        Do_Cal_in      	: in  std_logic;
        default_val_in 	: in  std_logic := '1';
        chnl_cnt_in	: in  unsigned(19 downto 0);
        new_data	: in  std_logic;
        write_curr     	: out std_logic;
        write_next     	: out std_logic;
        min_next       	: out std_logic_vector( 9 downto 0);
        max_next       	: out std_logic_vector( 9 downto 0);
        min_curr       	: out std_logic_vector( 9 downto 0);
        max_curr       	: out std_logic_vector( 9 downto 0);
        min_out        	: out std_logic_vector( 9 downto 0);
        max_out        	: out std_logic_vector( 9 downto 0);
        Delta          	: out std_logic_vector( 9 downto 0);
        FPGA_out       	: out std_logic_vector( 3 downto 0);
        chnl_out       	: out std_logic_vector( 6 downto 0);
        FPGA_out_curr  	: out std_logic_vector( 3 downto 0);
        chnl_out_curr 	: out std_logic_vector( 6 downto 0);
        DIN_out        	: out std_logic_vector(31 downto 0);
        DIN_out_b_r	: out std_logic;
        DIN_out_data_w	: out std_logic;
        DIN_out_data_f	: out std_logic;
        Do_Cal_out     	: out std_logic;
        chnl_cnt_out	: out unsigned (19 downto 0);--:="00000000000000000000";
        write_chnl_cnt  : out std_logic;
        chnl_out_write  : out std_logic_vector( 6 downto 0);
        FPGA_out_write  : out std_logic_vector( 3 downto 0);
        cal_Limit_set   : out unsigned (19 downto 0);
        BUS_Flash_value : in  std_logic_vector(26 downto 0);
        Flash_flag	: in  std_logic
    );
end Cal_Limits;

architecture Behavioral of Cal_Limits is

  signal FPGA_i     : std_logic_vector(3 downto 0);
  signal Delta_i    : std_logic_vector(9 downto 0) := "0110110100";
  
  signal min_curr_i : std_logic_vector( 9 downto 0);--:= "0000000001";
  signal max_curr_i : std_logic_vector( 9 downto 0);--:= "1000000001";
  signal min_next_i : std_logic_vector( 9 downto 0);--:= "0000000001";
  signal max_next_i : std_logic_vector( 9 downto 0);--:= "1000000001";

  signal min_curr_ii : std_logic_vector( 9 downto 0);--:= "0000000001";
  signal max_curr_ii : std_logic_vector( 9 downto 0);--:= "1000000001";
  signal min_next_ii : std_logic_vector( 9 downto 0);--:= "0000000001";
  signal max_next_ii : std_logic_vector( 9 downto 0);--:= "1000000001";

  signal min_curr_iii : std_logic_vector( 9 downto 0);--:= "0000000001";
  signal max_curr_iii : std_logic_vector( 9 downto 0);--:= "1000000001";
  signal min_next_iii : std_logic_vector( 9 downto 0);--:= "0000000001";
  signal max_next_iii : std_logic_vector( 9 downto 0);--:= "1000000001";
  
  signal cnt_i	    : unsigned(19 downto 0):="00000000000000000000";
  signal cnt_ii	    : unsigned(19 downto 0):="00000000000000000000";
  signal cnt_iii    : unsigned(19 downto 0):="00000000000000000000";

  signal chnl_i     : std_logic_vector( 6 downto 0);
  signal FPGA_ii    : std_logic_vector( 3 downto 0);
  signal chnl_ii    : std_logic_vector( 6 downto 0);
  signal use_old    : std_logic:='0';
  
  signal write_curr_i : std_logic;
  
  signal cal_Limit    : unsigned(19 downto 0):="00011000011010100000";--:="00011000011010100000";
  
  type array2D is array (1 downto 0, 0 to 64) of std_logic_vector(19 downto 0); --(FPGA)(channel)
  signal def_value : array2D := (others => ("10000000010000000010","10000000100000000010","10000000110000000010","10000001000000000010",
					    "10000001010000000010","10000001100000000010","10000001110000000010","10000010000000000010",
					    "10000010010000000010","10000010100000000010","10000010110000000010","10000011000000000010",
					    "10000011010000000010","10000011100000000010", others => "11111000010000001111" ));
  
  --signal write_curr_ii : std_logic;
  
begin

   Limit : process (CLK)
   begin
    if rising_edge(CLK) then 
    
      if (cal_Limit_reg <= cal_Limit_gen) then
         cal_Limit     <= cal_Limit_gen;
         cal_Limit_set <= cal_Limit_gen;
      else
         cal_Limit     <= cal_Limit_reg;
         cal_Limit_set <= cal_Limit_reg;
      end if;
    
    end if;
   end process;

   Count : process (CLK)
   begin
     if rising_edge(CLK) then
        if Do_Cal_in = '1' then
           if new_data = '0' then
             if cnt_i < cal_Limit then
	        cnt_i        <= cnt_i + 1;
	        chnl_cnt_out <= cnt_i + 1;
	     else
		cnt_i <= to_unsigned(0,20);
		chnl_cnt_out <= to_unsigned(0,20);
	     end if;
	     write_chnl_cnt <= '0';
	     use_old <= '0'; 
           else -- new data
             chnl_cnt_out   <= cnt_i;
             write_chnl_cnt <= '1';
             
             if FPGA_next = FPGA_i and chnl_next = chnl_i then
               use_old <= '1';
             else
               use_old <= '0';
             end if;
             
             if use_old = '0' then
               if chnl_cnt_in < cal_Limit then
	        cnt_i <= chnl_cnt_in + 1;
               else
                cnt_i <= to_unsigned(0,20);
               end if;
             else
               if cnt_ii < cal_Limit then
	        cnt_i <= cnt_ii + 1;
               else
                cnt_i <= to_unsigned(0,20);
               end if;
             end if;
           end if; --new data
           
           FPGA_out         <= FPGA;

           FPGA_i           <= FPGA;
           FPGA_ii	    <= FPGA_i;

	   chnl_out	    <= chnl;
           chnl_i	    <= chnl;
           chnl_ii	    <= chnl_i;

           cnt_ii	    <= cnt_i;
	   cnt_iii 	    <= cnt_ii;
	   
	   FPGA_out_write <= FPGA_i;
	   chnl_out_write <= chnl_i;
	   
	   FPGA_out_curr <= FPGA;
	   chnl_out_curr <= chnl;
        else
          write_chnl_cnt <= '0';
        end if;
     end if;
   end process;
   
   
   Mem_next : process(CLK)--DIN_in
   begin
    if rising_edge(CLK) then
     if Do_Cal_in = '1' then
       if new_data = '0' then -- old Data/ FPGA/CHNL
         if cnt_i /= to_unsigned(0,20) then --next memory
	   if unsigned(DIN_in(21 downto 12)) > unsigned(max_next_i) then
	      max_next_i <= DIN_in(21 downto 12);   
	   end if; 
	   if unsigned(DIN_in(21 downto 12)) < unsigned(min_next_i) then
	      min_next_i <= DIN_in(21 downto 12);   
	   end if; 
	 else
	   min_next_i   <= DIN_in(21 downto 12);--"1111111111";
	   max_next_i   <= DIN_in(21 downto 12);--"0000000000";
	 end if;
	 write_next <= '0';
	 min_next <= min_next_i;
	 max_next <= max_next_i;
       else -- new data/FPGA/CHNL
	 write_next <= '1';
	 min_next <= min_next_i;
	 max_next <= max_next_i;
	 if use_old = '1' then
	    if cnt_ii /= to_unsigned(0,20) then
		if unsigned(DIN_in(21 downto 12)) >= unsigned(max_next_ii) then
	      	   max_next_i <= DIN_in(21 downto 12);
	       	   if unsigned(DIN_in(21 downto 12)) < unsigned(min_next_ii) then
		      min_next_i <= DIN_in(21 downto 12);
	           else
	              min_next_i <= min_next_ii;
	           end if; 
	        else
	           max_next_i <= max_next_ii;
	           if unsigned(DIN_in(21 downto 12)) < unsigned(min_next_in) then
	              min_next_i <= DIN_in(21 downto 12);
	           else
	              min_next_i <= min_next_ii;
	           end if; 
	        end if;
	    else
	   	min_next_i   <= DIN_in(21 downto 12);--"1111111111";
	  	max_next_i   <= DIN_in(21 downto 12);--"0000000000";
	    end if;
	 else -- fpga/=fpga_ii and chnl_iii /= chnl
	    if chnl_cnt_in /= to_unsigned(0,20) then --next memory
	       if unsigned(DIN_in(21 downto 12)) >= unsigned(max_next_in) then
	         max_next_i <= DIN_in(21 downto 12);
	         if unsigned(DIN_in(21 downto 12)) < unsigned(min_next_in) then
		   min_next_i <= DIN_in(21 downto 12);
	         else
	           min_next_i <= min_next_in;
	         end if; 
	       else
	         max_next_i <= max_next_in;
	         if unsigned(DIN_in(21 downto 12)) < unsigned(min_next_in) then
	           min_next_i <= DIN_in(21 downto 12);
	         else
	           min_next_i <= min_next_in;
	         end if; 
	       end if;
	    else
	       min_next_i   <= DIN_in(21 downto 12);--"1111111111";
	       max_next_i   <= DIN_in(21 downto 12);--"0000000000";
	    end if; --/= 0
	end if;
       end if;--new data

 	min_next_ii  <= min_next_i;
	max_next_ii  <= max_next_i;
	min_next_iii <= min_next_ii;
	max_next_iii <= max_next_ii;

     else
       write_next <= '0';
     end if;  
   end if;--rising_edge
  end process;
  
  
  Mem_curr : process(CLK)--DIN_in)
  begin
   if rising_edge(CLK) then
     if default_val_in = '0' then
       if Do_Cal_in = '1' then
         if new_data = '0' then
	   if cnt_i /= to_unsigned(0,20) then
	      min_out <= min_curr_i;
	      max_out <= max_curr_i;
	      if (unsigned(min_curr_i) < unsigned(max_curr_i)) then
		Delta_i <= std_logic_vector(unsigned(max_curr_i) - unsigned(min_curr_i));
	      else
		Delta_i <= "0110110100";
	      end if;
	      min_curr <= min_curr_i;
	      max_curr <= max_curr_i;
	      write_curr <= '0';
	   else
	      min_out    <= min_next_i;
	      max_out    <= max_next_i;
	      min_curr_i <= min_next_i;
	      max_curr_i <= max_next_i;
	      min_curr <= min_next_i;
	      max_curr <= max_next_i;
	      if (unsigned(min_next_i) < unsigned(max_next_i)) then
		Delta_i <= std_logic_vector(unsigned(max_next_i) - unsigned(min_next_i));
	      else
		Delta_i <= "0110110100";
	      end if;  
	      write_curr <= '1';
	   end if;
	   
	   --min_curr <= min_curr_i;
	   --max_curr <= max_curr_i;
	 else  -- new data
	   if use_old = '1' then 
	        --min_curr   <= min_curr_i;
	        --max_curr   <= max_curr_i;
             if cnt_ii = to_unsigned(0,20) then
	        write_curr <= '1';
	        min_curr_i <= min_next_ii;
	        max_curr_i <= max_next_ii;
	        min_out	   <= min_next_ii;
	        max_out	   <= max_next_ii;
	        min_curr   <= min_next_ii;
	        max_curr   <= max_next_ii;
	        if (unsigned(min_next_ii) < unsigned(max_next_ii)) then
		  Delta_i <= std_logic_vector(unsigned(max_next_ii) - unsigned(min_next_ii));
	        else
	 	  Delta_i <= "0110110100";
	        end if;
	     else
	        min_curr_i <= min_curr_ii;
	        max_curr_i <= max_curr_ii;
	        min_out    <= min_curr_ii;
	        max_out    <= max_curr_ii;
		min_curr   <= min_curr_ii;
	        max_curr   <= max_curr_ii;
	        if (unsigned(min_curr_ii) < unsigned(max_curr_ii)) then
		  Delta_i <= std_logic_vector(unsigned(max_curr_ii) - unsigned(min_curr_ii));
	        else
		  Delta_i <= "0110110100";
	        end if;
	        write_curr <= '0';
	     end if;
	   else	--use_old ='0'
	        --min_curr   <= min_curr_i;
	        --max_curr   <= max_curr_i;
             if chnl_cnt_in = to_unsigned(0,20) then
	        write_curr <= '1';
	        min_curr_i <= min_next_in;
	        max_curr_i <= max_next_in;
	        min_out	   <= min_next_in;
	        max_out	   <= max_next_in;
	        min_curr   <= min_next_in;
	        max_curr   <= max_next_in;
	        if (unsigned(min_next_in) < unsigned(max_next_in)) then
		  Delta_i <= std_logic_vector(unsigned(max_next_in) - unsigned(min_next_in));
	        else
	 	  Delta_i <= "0110110100";
	        end if;
	     else
	        min_curr_i <= min_curr_in;
	        max_curr_i <= max_curr_in;
	        min_out    <= min_curr_in;
	        max_out    <= max_curr_in;
	        min_curr   <= min_curr_in;
	        max_curr   <= max_curr_in;
	        if (unsigned(min_curr_in) < unsigned(max_curr_in)) then
		  Delta_i <= std_logic_vector(unsigned(max_curr_in) - unsigned(min_curr_in));
	        else
		  Delta_i <= "0110110100";
	        end if;
	        write_curr <= '0';
	     end if;
	   end if;  
         end if;
       else -- no calibr
         write_curr <= '0';
       end if;
     elsif default_val_in = '1' then
     --FLASH
        write_curr <= '1';
        min_out    <= def_value(0,to_integer(unsigned(chnl)))( 9 downto  0);
        max_out    <= def_value(0,to_integer(unsigned(chnl)))(19 downto 10);
        min_curr   <= def_value(0,to_integer(unsigned(chnl)))( 9 downto  0);
        max_curr   <= def_value(0,to_integer(unsigned(chnl)))(19 downto 10);
        min_curr_i <= def_value(0,to_integer(unsigned(chnl)))( 9 downto  0);
        max_curr_i <= def_value(0,to_integer(unsigned(chnl)))(19 downto 10);
        Delta_i    <= std_logic_vector(unsigned(def_value(0,to_integer(unsigned(chnl)))(19 downto 10)) - unsigned(def_value(0,to_integer(unsigned(chnl)))(9 downto 0)));
     else
         write_curr <= '0';
         min_out    <= "0000000100";
         max_out    <= "1000000000";
         min_curr   <= "0000000100";
         max_curr   <= "1000000000";
         min_curr_i <= "0000000100";
         max_curr_i <= "1000000000";
         Delta_i    <= "0111111011";--"0111111110";
     end if;--default value

 	min_curr_ii  <= min_curr_i;
	max_curr_ii  <= max_curr_i;
	min_curr_iii <= min_curr_ii;
	max_curr_iii <= max_curr_ii;
	--write_curr_ii   <= write_curr_i;
	--write_curr  <= write_curr_i;
	
	--max_curr <= "1000000001";
  end if;--rising_edge
 end process;
 
   proc_Flash_input : process (CLK)
   begin
     if rising_edge(CLK) then
       if Flash_flag = '1' then
	  def_value(0,to_integer(unsigned(BUS_Flash_value(26 downto 20))))( 19 downto  0) <= BUS_Flash_value(19 downto 0);
	  
       end if;
     end if;
   end process;
 
 
   --synchronous output
   proc_slope : process (CLK)
   begin
     if rising_edge(CLK) then
        DIN_out     	<= DIN_in;
        DIN_out_b_r	<= DIN_in_b_r;
        DIN_out_data_w	<= DIN_in_data_w;
        DIN_out_data_f 	<= DIN_in_data_f;
        Do_Cal_out  	<= Do_Cal_in;
     end if;
   end process;

   Delta <= Delta_i;
end Behavioral;