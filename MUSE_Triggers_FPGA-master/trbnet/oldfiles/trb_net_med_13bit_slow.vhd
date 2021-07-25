--This entity provides data transfer (64bit) via a smaller (16bit) Bus
--with three bits for debugging (13bit data + 3bit control)
--first 56bit via Bus are for dataword, transmitted Bits 64 downto 56 Bits 
--are for debugging


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.trb_net_std.all;

entity trb_net_med_13bit_slow is
generic( 
  TRANSMISSION_CLOCK_DIVIDER: integer range 2 to 62 := 2   --even values only!
  );


  port(
    --  Misc
    CLK    : in std_logic;      
    RESET  : in std_logic;    
    CLK_EN : in std_logic;
    -- Internal direction port (MII)
    -- do not change this interface!!! 
    -- 1st part: from the medium to the internal logic (trbnet)
    INT_DATAREADY_OUT: out STD_LOGIC;  --Data word is reconstructed from media
                                       --and ready to be read out (the IOBUF MUST read)
    INT_DATA_OUT:      out STD_LOGIC_VECTOR (55 downto 0); -- Data word
    INT_READ_IN:       in  STD_LOGIC; 
    INT_ERROR_OUT:     out STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    -- 2nd part: from the internal logic (trbnet) to the medium
    INT_DATAREADY_IN:  in  STD_LOGIC; -- Data word is offered for the Media 
    INT_DATA_IN:       in  STD_LOGIC_VECTOR (55 downto 0); -- Data word
    INT_READ_OUT:      out STD_LOGIC; -- offered word is read
    INT_ERROR_IN:      in  STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    -- (end do not change this interface!!!) 

    
    --  Media direction port
    -- in this case for the cable => 32 lines in total
    MED_DATA_OUT:             out STD_LOGIC_VECTOR (12 downto 0); -- Data word 
                          --(incl. debugging errorbits)
    MED_TRANSMISSION_CLK_OUT: out STD_LOGIC;
    MED_CARRIER_OUT:          out STD_LOGIC;
    MED_PARITY_OUT:           out STD_LOGIC;
    MED_DATA_IN:              in  STD_LOGIC_VECTOR (12 downto 0); -- Data word
    MED_TRANSMISSION_CLK_IN:  in  STD_LOGIC;
    MED_CARRIER_IN:           in  STD_LOGIC;
    MED_PARITY_IN:            in  STD_LOGIC;

    -- Status and control port => this never can hurt
    STAT: out STD_LOGIC_VECTOR (31 downto 0);
              --STAT(0): Busy reading from media
              --STAT(1): Busy writing to media
              --STAT(31 downto 28): packets_in (mod 16)
              --STAT(27 downto 24): packets_out (mod 16)
              --STAT(11 downto 8): INT2MED state
              --STAT(15 downto 12): MED2INT state
              
    CTRL: in  STD_LOGIC_VECTOR (31 downto 0)   
              --CTRL(24..31) -> lvds-data(63 downto 56) via lvds 
                     --once for each packet

    );
end trb_net_med_13bit_slow;

architecture trb_net_med_13bit_slow_arch of trb_net_med_13bit_slow is
  signal INT2MED_state, next_INT2MED_state : std_logic_vector (3 downto 0); 
  
  type MED2INT_STATE_t is (IDLE, RECV2, RECV3, RECV4, RECV5);
  signal MED2INT_state, next_MED2INT_state:  MED2INT_STATE_t;

  signal DAT_MED2INT, next_DAT_MED2INT     :std_logic_vector(51 downto 0);
  signal buf_INT_DATA_IN, next_buf_INT_DATA_IN   :std_logic_vector(55 downto 0);

  signal next_INT_DATA_OUT, buf_INT_DATA_OUT:    std_logic_vector(55 downto 0);
  signal next_buf_MED_DATA_OUT, buf_MED_DATA_OUT: std_logic_vector(12 downto 0);
  signal next_INT_DATAREADY_OUT, buf_INT_DATAREADY_OUT:  std_logic;
  signal next_buf_INT_READ_OUT, buf_INT_READ_OUT: std_logic;
  
  signal buf_MED_TRANSMISSION_CLK_OUT: std_logic;
  signal buf_MED_CARRIER_OUT, next_MED_CARRIER_OUT:          STD_LOGIC;
  signal buf_MED_PARITY_OUT, next_MED_PARITY_OUT:           STD_LOGIC;
  signal my_error,next_my_error :  std_logic_vector(2 downto 0);
  signal fatal_error, media_not_connected : std_logic;
  signal next_media_not_connected : std_logic;
  signal transmission_clk_Counter : std_logic_vector(4 downto 0); 
  signal next_transmission_clk_Counter : std_logic_vector(4 downto 0);
  signal next_TRANSMISSION_CLK: std_logic;
  signal buf_CTRL, next_STAT, buf_STAT : std_logic_vector(31 downto 0);
  signal next_RECV_STAT, RECV_STAT : std_logic_vector(8 downto 0);

  signal last_TRCLK, this_TRCLK: std_logic;
  signal CLK_counter,next_CLK_counter: std_logic_vector(7 downto 0);

  signal packets_in_counter, next_packets_in_counter: std_logic_vector(7 downto 0);
  signal packets_in_compl_counter, next_packets_in_compl_counter: std_logic_vector(3 downto 0);
  signal packets_out_counter, next_packets_out_counter: std_logic_vector(3 downto 0);
  
  signal last_MED_TRANSMISSION_CLK_IN : std_logic;
  signal reg_MED_DATA_IN : std_logic_vector(12 downto 0);
  signal reg_MED_TRANSMISSION_CLK_IN, reg_MED_CARRIER_IN : std_logic;
  signal reg_MED_PARITY_IN : std_logic;
  signal med2int_state_sig :std_logic_vector(2 downto 0);

begin
INT_DATAREADY_OUT <= buf_INT_DATAREADY_OUT;
INT_DATA_OUT <= buf_INT_DATA_OUT(55 downto 0);
INT_ERROR_OUT <= my_error;
INT_READ_OUT <= buf_INT_READ_OUT;
STAT <= buf_STAT;

MED_DATA_OUT(12 downto 0) <= buf_MED_DATA_OUT;
MED_TRANSMISSION_CLK_OUT <= buf_MED_TRANSMISSION_CLK_OUT;
MED_CARRIER_OUT <= buf_MED_CARRIER_OUT;
MED_PARITY_OUT <= buf_MED_PARITY_OUT;


--TODO:
--------------------------------
fatal_error <= '0';



--Status word
--------------------------------
gen_STAT_WORD: process(MED2INT_state,INT2MED_state,buf_INT_DATAREADY_OUT,RECV_STAT,buf_STAT)
  begin
    next_STAT <= (others => '0');
    if  MED2INT_state = IDLE then
      next_STAT(0) <= '0';
     else
      next_STAT(0) <= '1';
    end if;
    if  INT2MED_state = 0 then
      next_STAT(1) <= '0';
     else
      next_STAT(1) <= '1';
    end if;
    next_STAT(11 downto 8) <= INT2MED_state;
    --next_STAT(15 downto 12) <= MED2INT_state;
    next_STAT(16) <= media_not_connected;
    next_STAT(31 downto 24) <= packets_in_counter;
    --next_STAT(27 downto 24) <= packets_in_compl_counter;
    if buf_INT_DATAREADY_OUT = '1' then
      next_STAT(24 downto 16) <= RECV_STAT(8 downto 0);
     else
      next_STAT(24 downto 16) <= buf_STAT(24 downto 16);
    end if;
  end process;
  
STAT_reg: process (CLK,RESET)
  begin
    if RESET = '1' then
      buf_STAT <= (others => '0');
      elsif rising_edge(CLK) then
      buf_STAT <= next_STAT;
      else
      buf_STAT <= buf_STAT;
    end if;
  end process;


--CTRL register
--------------------------------
CTRL_reg: process (CLK,RESET)
  begin
    if RESET = '1' then
      buf_CTRL <= (others => '0');
     elsif rising_edge(CLK) then
      buf_CTRL <= CTRL;
      --buf_CTRL(31 downto 24) <= packets_in_counter;
      --buf_CTRL(27 downto 24) <= packets_in_compl_counter;
     else
      buf_CTRL <= buf_CTRL;
    end if;
  end process;



--My error bits
--------------------------------
gen_my_error: process(media_not_connected,fatal_error)
  begin
    if media_not_connected = '1' then
      next_my_error <= "100";
     elsif fatal_error = '1' then
      next_my_error <= "011";
     else
      next_my_error <= "000";
    end if;
  end process;


reg_my_error:  process(CLK,RESET)
  begin
    if RESET = '1' then
      my_error <= "000";
     elsif rising_edge(CLK) then
      my_error <= next_my_error;
     else
      my_error <= my_error;
    end if;
  end process;


--Transmission clock generator
--------------------------------
trans_clk_counter: process (transmission_clk_Counter, buf_MED_TRANSMISSION_CLK_OUT)
  begin
    if transmission_clk_Counter = (TRANSMISSION_CLOCK_DIVIDER/2) - 1 then
      next_transmission_clk_Counter <= (others => '0');
      next_TRANSMISSION_CLK <= not buf_MED_TRANSMISSION_CLK_OUT;
     else
      next_transmission_clk_Counter <= transmission_clk_Counter + 1;
      next_TRANSMISSION_CLK <= buf_MED_TRANSMISSION_CLK_OUT;
    end if;
  end process;


trans_clk_counter_reg: process (CLK,RESET)
  begin
    if RESET = '1' then
      transmission_clk_Counter <= (others => '0');
      buf_MED_TRANSMISSION_CLK_OUT <= '0';
    elsif rising_edge(CLK) then
      transmission_clk_Counter <= next_transmission_clk_Counter;
      buf_MED_TRANSMISSION_CLK_OUT <= next_TRANSMISSION_CLK;
    else
      transmission_clk_Counter <= transmission_clk_Counter;
      buf_MED_TRANSMISSION_CLK_OUT <= buf_MED_TRANSMISSION_CLK_OUT;
    end if;
  end process;



--Transmission Clock detection
--------------------------------
trans_clk_reg: process (RESET,CLK)
  begin
    if RESET = '1' then
      last_TRCLK <= '0';
      this_TRCLK <= '0';
      CLK_counter <= (others => '0');
      media_not_connected <= '0';
    elsif rising_edge(CLK) then
      last_TRCLK <= this_TRCLK;
      this_TRCLK <= MED_TRANSMISSION_CLK_IN;
      CLK_counter <= next_CLK_counter;
      media_not_connected <= next_media_not_connected;
  	 else
      last_TRCLK <= last_TRCLK;
      this_TRCLK <= this_TRCLK;
      CLK_counter <= CLK_counter;
      media_not_connected <= media_not_connected;
    end if;
  end process;



transCLK_counter: process (this_TRCLK, last_TRCLK, CLK_counter,
                           buf_MED_DATA_OUT, buf_MED_CARRIER_OUT, 
                           buf_MED_PARITY_OUT, buf_CTRL)
  begin
    next_media_not_connected <= '0';
    if last_TRCLK = '0' and this_TRCLK = '1' then
      next_CLK_counter <= (others => '0');
    elsif CLK_counter = 255 then
      next_media_not_connected <= '1';
      next_CLK_counter <= CLK_counter;      
    else
      next_CLK_counter <= CLK_counter + 1;
    end if;
  end process;




--INT to MED direction
--------------------------------
INT2MED_fsm: process(buf_INT_DATA_IN,INT2MED_state, 
              INT_DATAREADY_IN, INT_DATA_IN, buf_INT_READ_OUT, 
              next_TRANSMISSION_CLK, buf_MED_TRANSMISSION_CLK_OUT, buf_MED_DATA_OUT, 
              buf_MED_CARRIER_OUT, buf_MED_PARITY_OUT, buf_CTRL)
     variable tmp: std_logic_vector(12 downto 0);
begin
    next_INT2MED_state <= "0000";
    next_buf_MED_DATA_OUT <= buf_MED_DATA_OUT;
    next_MED_CARRIER_OUT <= buf_MED_CARRIER_OUT;
    next_MED_PARITY_OUT <= buf_MED_PARITY_OUT;
    next_buf_INT_DATA_IN <= buf_INT_DATA_IN;
    next_buf_INT_READ_OUT <= buf_INT_READ_OUT;
    
    next_packets_out_counter <= packets_out_counter;
    case INT2MED_state is
      when "0000" =>
        if INT_DATAREADY_IN = '1' and buf_INT_READ_OUT = '1' then
          --generate data word to transmit
          next_buf_INT_DATA_IN(55 downto 0) <= INT_DATA_IN(55 downto 0);
          next_INT2MED_state <= "0001";
          next_buf_INT_READ_OUT <= '0';
          next_packets_out_counter <= packets_out_counter + 1;
         else
          next_buf_INT_READ_OUT <= '1';      
          next_MED_CARRIER_OUT <= '0';
          next_MED_PARITY_OUT <= '0';
        end if;
      when "0001" =>
        if  next_TRANSMISSION_CLK = '0' and buf_MED_TRANSMISSION_CLK_OUT = '1' then
          next_buf_MED_DATA_OUT(12 downto 0) <= buf_INT_DATA_IN(12 downto 0);
          next_MED_CARRIER_OUT <= '1';
          next_MED_PARITY_OUT <= xor_all(buf_INT_DATA_IN(12 downto 0));      
          next_INT2MED_state <= "0010";
         else
          next_INT2MED_state <= "0001";
        end if;
      when "0010" =>    
        if next_TRANSMISSION_CLK = '0'  and buf_MED_TRANSMISSION_CLK_OUT = '1' then
          next_buf_MED_DATA_OUT(12 downto 0) <= buf_INT_DATA_IN(25 downto 13);
          next_MED_PARITY_OUT <= xor_all(buf_INT_DATA_IN(25 downto 13));      
          next_INT2MED_state <= "0100";
         else
          next_INT2MED_state <= "0010";
        end if;  
      when "0100" =>    
        if next_TRANSMISSION_CLK = '0'  and buf_MED_TRANSMISSION_CLK_OUT = '1' then
          next_buf_MED_DATA_OUT(12 downto 0) <= buf_INT_DATA_IN(38 downto 26);
          next_MED_PARITY_OUT <= xor_all(buf_INT_DATA_IN(38 downto 26));      
          next_INT2MED_state <= "0110";
         else
          next_INT2MED_state <= "0100";
        end if;  
      when "0110" =>    
        if next_TRANSMISSION_CLK = '0'  and buf_MED_TRANSMISSION_CLK_OUT = '1' then
          next_buf_MED_DATA_OUT(12 downto 0) <= buf_INT_DATA_IN(51 downto 39);
          next_MED_PARITY_OUT <= xor_all(buf_INT_DATA_IN(51 downto 39));      
          next_INT2MED_state <= "1000";
         else
          next_INT2MED_state <= "0110";
        end if;  
      when "1000" =>    
        if next_TRANSMISSION_CLK = '0'  and buf_MED_TRANSMISSION_CLK_OUT = '1'  then
          
          tmp(3 downto 0) := buf_INT_DATA_IN(55 downto 52);
          tmp(11 downto 4) := buf_CTRL(31 downto 24);
          tmp(12) := buf_CTRL(0);
          
          next_buf_MED_DATA_OUT <= tmp;
          next_MED_PARITY_OUT <= xor_all(tmp);      
          next_INT2MED_state <= "1110";
         else
          next_INT2MED_state <= "1000";
        end if;  
      when "1110" =>
        if next_TRANSMISSION_CLK = '0' and buf_MED_TRANSMISSION_CLK_OUT = '1'  then
          next_INT2MED_state <= "0000";
          next_MED_CARRIER_OUT <= '0';
          next_buf_MED_DATA_OUT <= (others => '0');
        else
          next_INT2MED_state <= "1110";
        end if;
      when others =>
        next_INT2MED_state <= "0000";
    end case;
end process;    


INT2MED_fsm_reg: process(CLK,RESET)
  begin
    if RESET='1' then
      buf_MED_DATA_OUT <= (others => '0');
      INT2MED_state <= "0000";
      buf_INT_DATA_IN <= (others => '0');
      buf_INT_READ_OUT <= '0';
      buf_MED_CARRIER_OUT <= '0';
      buf_MED_PARITY_OUT <= '0';
      packets_out_counter <= (others => '0');
    elsif rising_edge(CLK) then
      INT2MED_state <= next_INT2MED_state;
      buf_INT_DATA_IN  <= next_buf_INT_DATA_IN;
      buf_INT_READ_OUT <= next_buf_INT_READ_OUT;      
      buf_MED_DATA_OUT(12 downto 0) <= next_buf_MED_DATA_OUT(12 downto 0);  
      buf_MED_CARRIER_OUT <= next_MED_CARRIER_OUT;
      buf_MED_PARITY_OUT <= next_MED_PARITY_OUT;      
      packets_out_counter <= next_packets_out_counter;
    else
      buf_MED_DATA_OUT <= buf_MED_DATA_OUT;
      buf_MED_CARRIER_OUT <= buf_MED_CARRIER_OUT;
      buf_MED_PARITY_OUT <= buf_MED_PARITY_OUT;
      INT2MED_state <= INT2MED_state;
      buf_INT_READ_OUT <= buf_INT_READ_OUT;
      buf_INT_DATA_IN  <= buf_INT_DATA_IN;
      packets_out_counter <= packets_out_counter;
    end if;
  end process;















--MED to INT direction
--------------------------------

MED2INT_fsm: process(reg_MED_PARITY_IN,MED2INT_state,CLK,reg_MED_DATA_IN,DAT_MED2INT,
          reg_MED_TRANSMISSION_CLK_IN,reg_MED_CARRIER_IN,INT_READ_IN, RECV_STAT,
		  media_not_connected,buf_INT_DATAREADY_OUT, buf_INT_DATA_OUT, last_MED_TRANSMISSION_CLK_IN
          )
  begin
    next_DAT_MED2INT <= DAT_MED2INT;
    next_INT_DATA_OUT <= buf_INT_DATA_OUT;
    next_INT_DATAREADY_OUT <= buf_INT_DATAREADY_OUT;    
    next_MED2INT_state <= IDLE;
    next_RECV_STAT <= RECV_STAT;
    next_packets_in_counter <= packets_in_counter;
    next_packets_in_compl_counter <= packets_in_compl_counter;

    case MED2INT_state is
      when IDLE =>
          if reg_MED_TRANSMISSION_CLK_IN = '1' and last_MED_TRANSMISSION_CLK_IN = '0' and reg_MED_CARRIER_IN = '1' then
            next_MED2INT_state <= RECV2;
            next_DAT_MED2INT(12 downto 0) <= reg_MED_DATA_IN(12 downto 0);
          end if;
      when RECV2 =>
          if reg_MED_TRANSMISSION_CLK_IN = '1' and last_MED_TRANSMISSION_CLK_IN = '0' and reg_MED_CARRIER_IN = '1' then
            next_MED2INT_state <= RECV3;
            next_DAT_MED2INT(25 downto 13) <= reg_MED_DATA_IN(12 downto 0);
           else
            next_MED2INT_state <= RECV2;
          end if;
      when RECV3 =>
          if reg_MED_TRANSMISSION_CLK_IN = '1' and last_MED_TRANSMISSION_CLK_IN = '0' and reg_MED_CARRIER_IN = '1' then
            next_MED2INT_state <= RECV4;
            next_DAT_MED2INT(38 downto 26) <= reg_MED_DATA_IN(12 downto 0);
           else
            next_MED2INT_state <= RECV3;
          end if;
      when RECV4 =>
          if reg_MED_TRANSMISSION_CLK_IN = '1' and last_MED_TRANSMISSION_CLK_IN = '0' and reg_MED_CARRIER_IN = '1' then
            next_MED2INT_state <= RECV5;
            next_DAT_MED2INT(51 downto 39) <= reg_MED_DATA_IN(12 downto 0);
           else
            next_MED2INT_state <= RECV4;
          end if;
      when RECV5 =>
          if reg_MED_TRANSMISSION_CLK_IN = '1' and last_MED_TRANSMISSION_CLK_IN = '0' and reg_MED_CARRIER_IN = '1' then
            next_INT_DATA_OUT(51 downto 0) <= DAT_MED2INT(51 downto 0);
            next_INT_DATA_OUT(55 downto 52) <= reg_MED_DATA_IN(3 downto 0);
            next_RECV_STAT <= reg_MED_DATA_IN(12 downto 4);
            next_INT_DATAREADY_OUT <= '1';
            next_MED2INT_state <= IDLE;
            next_packets_in_counter <= packets_in_counter + 1;
           else
            next_MED2INT_state <= RECV5;
          end if;
       when others =>
          next_MED2INT_state <= IDLE;
    end case;
    
    --clear dataready when read
    if buf_INT_DATAREADY_OUT = '1' and INT_READ_IN = '1' then
      next_INT_DATAREADY_OUT <= '0';
      next_INT_DATA_OUT <= (others => '0');
    end if;
    
    --check parity
    if reg_MED_TRANSMISSION_CLK_IN = '1' and last_MED_TRANSMISSION_CLK_IN = '0' then
      if(xor_all(reg_MED_DATA_IN(12 downto 0)) /= reg_MED_PARITY_IN) then 
        next_MED2INT_state <= IDLE;
      end if;
    end if;
    
    --reset on Carrier low
--    if reg_MED_TRANSMISSION_CLK_IN = '1' and last_MED_TRANSMISSION_CLK_IN = '0' and reg_MED_CARRIER_IN = '0' then
--      next_MED2INT_state <= IDLE;
--    end if;
    
    --reset on not connected
    if media_not_connected = '1' then
      next_MED2INT_state <= IDLE;
    end if;
  end process;


process(MED2INT_state)
begin
  case MED2INT_state is
  when IDLE  => med2int_state_sig <= "000";
  when RECV2 => med2int_state_sig <= "001";
  when RECV3 => med2int_state_sig <= "010";
  when RECV4 => med2int_state_sig <= "011";
  when RECV5 => med2int_state_sig <= "100";
  end case;
end process;


MED2INT_fsm_reg: process(CLK,RESET)
  begin
    if RESET='1' then
      MED2INT_state <= IDLE;
      buf_INT_DATAREADY_OUT <= '0';
      DAT_MED2INT <= (others => '0');
      buf_INT_DATA_OUT <= (others => '0');
      RECV_STAT <= (others => '0');
      packets_in_counter <= (others => '0');
      packets_in_compl_counter <= (others => '0');
      last_MED_TRANSMISSION_CLK_IN <= '1';
    elsif rising_edge(CLK) then
      DAT_MED2INT <= next_DAT_MED2INT;
      MED2INT_state <= next_MED2INT_state;
      buf_INT_DATA_OUT <= next_INT_DATA_OUT;
      buf_INT_DATAREADY_OUT <= next_INT_DATAREADY_OUT;
      RECV_STAT <= next_RECV_STAT;
      packets_in_counter <= next_packets_in_counter;
      packets_in_compl_counter <= next_packets_in_compl_counter;
      last_MED_TRANSMISSION_CLK_IN <= reg_MED_TRANSMISSION_CLK_IN;
    else 
      buf_INT_DATA_OUT <= buf_INT_DATA_OUT;
      MED2INT_state <= MED2INT_state;
      buf_INT_DATAREADY_OUT <= buf_INT_DATAREADY_OUT;
      DAT_MED2INT <= DAT_MED2INT;
      RECV_STAT <= RECV_STAT;
      packets_in_counter <= packets_in_counter;
      packets_in_compl_counter <= packets_in_compl_counter;
      last_MED_TRANSMISSION_CLK_IN <= last_MED_TRANSMISSION_CLK_IN;
    end if;
  end process;

LVDS_IN_reg: process(CLK, RESET)
  begin
    if RESET='1' then
       reg_MED_TRANSMISSION_CLK_IN <= '0';
       reg_MED_CARRIER_IN <= '0';
       reg_MED_PARITY_IN <= '0';
       reg_MED_DATA_IN <= (others => '0');
    elsif rising_edge(CLK) then
      reg_MED_TRANSMISSION_CLK_IN <= MED_TRANSMISSION_CLK_IN;
      reg_MED_CARRIER_IN <= MED_CARRIER_IN;
      reg_MED_PARITY_IN <= MED_PARITY_IN;
      reg_MED_DATA_IN <= MED_DATA_IN;
    else 
      reg_MED_TRANSMISSION_CLK_IN <= reg_MED_TRANSMISSION_CLK_IN;
      reg_MED_CARRIER_IN <= reg_MED_CARRIER_IN;
      reg_MED_PARITY_IN <= reg_MED_PARITY_IN;
      reg_MED_DATA_IN <= reg_MED_DATA_IN;
    end if;
  end process;


end trb_net_med_13bit_slow_arch;

