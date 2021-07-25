----------------------------------------------------------------------------------
-- Company: GSI
-- Engineer: Davide Leoni
-- 
-- Create Date:    09:54:15 07/11/2007 
-- Design Name: 	 vulom3
-- Module Name:    bus_data_com4 - Behavioral 
-- Project Name: 	triggerbox
-- Target Devices: XC4VLX25-10SF363
-- Tool versions: 
-- Description: Data communication to TRB
--
-- Dependencies: 															
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: Whole datastream with 16 bit summer usead as error check
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bus_data_com5 is
	PORT(
		clk_300MHz : in std_logic;
		clk_100MHz : in std_logic;
		gts_pulse : in std_logic;
		cal_trigger : in std_logic;
		bus_busy : in std_logic;				-- not used
		bus_ack : in std_logic;
		bus_retx : in std_logic;
		latch : in std_logic_vector(6 downto 0);
		latch_dsc : in std_logic_vector(6 downto 0);
		scaler_pti1 : in std_logic_vector(31 downto 0);
		scaler_pti2 : in std_logic_vector(31 downto 0);
		scaler_pti3 : in std_logic_vector(31 downto 0);
		scaler_pti4 : in std_logic_vector(31 downto 0);
		scaler_pti5 : in std_logic_vector(31 downto 0);
		scaler_ts : in std_logic_vector(31 downto 0);
		scaler_vs : in std_logic_vector(31 downto 0);
		scaler_dead : in std_logic_vector(31 downto 0);
		bus_inhibit : out std_logic;
		dtu_inhibit : out std_logic;													
		ecl_bus_data : out std_logic_vector(1 downto 0);
		ecl_bus_clk : out std_logic;
		com_run : in std_logic;
		dtu_bus_t : out std_logic;
		dtu_bus_ts : out std_logic;
		dtu_bus_td : out std_logic_vector (3 downto 0);
                DTU_CODE_SELECT : in std_logic_vector(4 downto 0);
		out_inhibit : in std_logic;
                cal_inhibit : in std_logic;
                DEBUG_REG_01 : out std_logic_vector(15 downto 0);
                TRB_BUSY_ENABLE : in std_logic
		);
		
end bus_data_com5;

architecture Behavioral of bus_data_com5 is
signal count : integer range 0 to 300 := 0;
signal tag_counter_trb, tag_counter_dtu : std_logic_vector(15 downto 0):=x"0000";
signal cal_trigger_s, cal_trigger_d1, cal_trigger_pulse, cal_trigger_pulse_d, bus_busy_s, bus_busy_d1 : std_logic := '0';
type state_type_a is (ready, start_sequence_0, start_sequence_1, start_sequence_2, start_sequence_3,
							start_sequence_4, start_sequence_5, start_sequence_6, start_sequence_7,
							normal_code_0, normal_code_1, calib_code_0, calib_code_1, 
							xfer_0, xfer_0alter, xfer_1, xfer_2, xfer_3, xfer_4, xfer_5, xfer_6, 
							xfer_7, xfer_8, xfer_9, xfer_10, xfer_11, xfer_12, xfer_13, xfer_14, xfer_15,
							wait_for_busy, hold_busy);
signal state_a : state_type_a;
type state_type_b is (tag, latches, scalers_0, scalers_1, scalers_2, scalers_3, scalers_4, scalers_5, 
							scalers_6, scalers_7, scalers_8, scalers_9, scalers_10, scalers_11, scalers_12, 
							scalers_13, scalers_14, scalers_15, checksum_0, checksum_1, finished);
signal state_b : state_type_b;
type state_type_c is (idle, begin_run_0, begin_run_1, end_run_0, end_run_1, norm_event_0, norm_event_1, 
							calib_event_0, calib_event_1, tag_low_0, tag_low_1, tag_high_0, tag_high_1, 
							tag_prio_0, tag_prio_1, wait_last, count_incr, wait_for_trb);
signal state_c : state_type_c;
							
signal xfer_buffer : std_logic_vector(15 downto 0):=x"0000";
signal latch_s, latch_dsc_s : std_logic_vector(6 downto 0):="0000000";
signal gts_trb_r, gts_trb_q, gts_q_d, gts_dtu_r, gts_dtu_q : std_logic := '0';
signal checksum : std_logic_vector(31 downto 0):=x"00000000";
signal scaler_pti1_s, scaler_pti2_s, scaler_pti3_s, scaler_pti4_s, scaler_pti5_s, scaler_ts_s,
			scaler_vs_s, scaler_dead_s : std_logic_vector(31 downto 0);
signal com_run_s, trb_run, trb_run_s, bus_ack_s, bus_retx_s : std_logic:='0';
signal ack_accu, retx_accu : std_logic_vector(3 downto 0);
signal gts_from_trb, cal_trigger_from_trb : std_logic:='0';
signal trb_go_norm, trb_go_norm_s, trb_go_calib, trb_go_calib_s, trb_finished : std_logic;
signal dtu_start : std_logic;
signal dtu_code : std_logic_vector(3 downto 0);
signal prepared_code : std_logic_vector(3 downto 0);
begin
  delay : process(clk_100MHz)
  begin
    if rising_edge(clk_100MHz) then						
      scaler_pti1_s <= scaler_pti1;
      scaler_pti2_s <= scaler_pti2;
      scaler_pti3_s <= scaler_pti3;
      scaler_pti4_s <= scaler_pti4;
      scaler_pti5_s <= scaler_pti5;
      scaler_ts_s <= scaler_ts;
      scaler_vs_s <= scaler_vs;
      scaler_dead_s <= scaler_dead;
      latch_s <= latch;
      latch_dsc_s <= latch_dsc;			
      bus_busy_s <= bus_busy;	
      bus_ack_s <= bus_ack;
      bus_retx_s <= bus_retx;			
    end if;
  end process;
  input_gts : process(clk_300MHz)
  begin
    if rising_edge(clk_300MHz) then			
      if gts_dtu_r = '1' then			 --gts latch for trb bus
        gts_dtu_q <= '0';
      elsif gts_pulse = '1' then		
        gts_dtu_q <= '1';
      end if;
        dtu_inhibit <= (not com_run) or dtu_start;
--      dtu_inhibit <= dtu_start;											
    end if;
  end process;
  input_cal : process(clk_100MHz)
  begin
    if rising_edge(clk_100MHz) then						
      cal_trigger_s <= cal_trigger;
      cal_trigger_d1 <= cal_trigger_s;
      cal_trigger_pulse <= cal_trigger_s and not cal_trigger_d1 and not out_inhibit;				
    end if;
  end process;
----------------------------------------------------------------------	TRB comm
  fsm : process(clk_100MHz)												--TX lenght: 3.1-3.2 µs
  begin
    if rising_edge(clk_100MHz) then
      if com_run = '0' then
        state_a    <= ready;
      else
      case state_a is
        when ready =>
          DEBUG_REG_01(4 downto 0) <= "00001";
          ecl_bus_data <= "00";
          ecl_bus_clk <= '0';
          bus_inhibit <= '0';
          trb_finished <= '1';
          trb_go_norm_s <= trb_go_norm;
          trb_go_calib_s <= trb_go_calib;
          if (trb_go_norm or trb_go_calib) = '1' then		
            state_a <= start_sequence_0;
          else state_a <= ready;
          end if;					
----------------------------				
        when start_sequence_0 =>
          DEBUG_REG_01(4 downto 0) <= "00010";
          trb_finished <= '0';
          bus_inhibit <= '1';
          ecl_bus_data <= "01";
          ecl_bus_clk <= '0';
          ack_accu <= "0000";
          retx_accu <= "0000";
          state_a <= start_sequence_1;
        when start_sequence_1 =>
          DEBUG_REG_01(4 downto 0) <= "00011";
          gts_trb_r <= '1';
          ecl_bus_clk <= '1';
          state_a <= start_sequence_2;
        when start_sequence_2 =>
          DEBUG_REG_01(4 downto 0) <= "00100";
          ecl_bus_data <= "10";
          ecl_bus_clk <= '0';
          state_a <= start_sequence_3;
        when start_sequence_3 =>
          DEBUG_REG_01(4 downto 0) <= "00101";
          ecl_bus_clk <= '1';
          state_a <= start_sequence_4; 
        when start_sequence_4 =>
          DEBUG_REG_01(4 downto 0) <= "00110";
          ecl_bus_data <= "01";
          ecl_bus_clk <= '0';
          state_a <= start_sequence_5;
        when start_sequence_5 =>
          DEBUG_REG_01(4 downto 0) <= "00111";
          ecl_bus_clk <= '1';
          state_a <= start_sequence_6;
        when start_sequence_6 =>
          DEBUG_REG_01(4 downto 0) <= "01000";
          ecl_bus_data <= "10";
          ecl_bus_clk <= '0';
          state_a <= start_sequence_7;
        when start_sequence_7 =>
          DEBUG_REG_01(4 downto 0) <= "01001";
          ecl_bus_clk <= '1';
          if trb_go_norm_s = '1' then
            state_a <= normal_code_0;
          elsif trb_go_calib_s = '1' then
            state_a <= calib_code_0;
          else state_a <= ready;
          end if;											
----------------------------------------------				
        when normal_code_0 =>
          DEBUG_REG_01(4 downto 0) <= "01010";
          ecl_bus_data <= "01";
          ecl_bus_clk <= '0';
          state_a <= normal_code_1;
        when normal_code_1 =>
          DEBUG_REG_01(4 downto 0) <= "01011";        
          checksum <= x"00000001";
          ecl_bus_clk <= '1';
          state_a <= xfer_0;					
        when calib_code_0 =>
          DEBUG_REG_01(4 downto 0) <= "01100";
          ecl_bus_data <= "11";
          ecl_bus_clk <= '0';
          state_a <= calib_code_1;
        when calib_code_1 =>
          DEBUG_REG_01(4 downto 0) <= "01101";
          checksum <= x"00000003";
          ecl_bus_clk <= '1';
          state_a <= xfer_0;					
---------------------------------------------------					
        when xfer_0 =>
          DEBUG_REG_01(4 downto 0) <= "01110";
          checksum <= checksum + xfer_buffer;
          ecl_bus_data <= xfer_buffer(1 downto 0);
          ecl_bus_clk <= '0';
          state_a <= xfer_1;
        when xfer_0alter =>
          DEBUG_REG_01(4 downto 0) <= "01111";
          ecl_bus_data <= xfer_buffer(1 downto 0);
          ecl_bus_clk  <= '0';
          state_a      <= xfer_1;
        when xfer_1 =>
          DEBUG_REG_01(4 downto 0) <= "10000";
          ecl_bus_clk  <= '1';
          state_a      <= xfer_2;
        when xfer_2 =>
          DEBUG_REG_01(4 downto 0) <= "10001";
          ecl_bus_data <= xfer_buffer(3 downto 2);
          ecl_bus_clk  <= '0';
          state_a      <= xfer_3;
        when xfer_3 =>
          DEBUG_REG_01(4 downto 0) <= "10010";
          ecl_bus_clk <= '1';
          state_a     <= xfer_4;
        when xfer_4 =>
          DEBUG_REG_01(4 downto 0) <= "10011";
          ecl_bus_data <= xfer_buffer(5 downto 4);
          ecl_bus_clk  <= '0';
          state_a      <= xfer_5;
        when xfer_5 =>
          DEBUG_REG_01(4 downto 0) <= "10100";
          ecl_bus_clk <= '1';
          state_a     <= xfer_6;
        when xfer_6 =>
          DEBUG_REG_01(4 downto 0) <= "10101";
          ecl_bus_data <= xfer_buffer(7 downto 6);
          ecl_bus_clk  <= '0';
          state_a      <= xfer_7;
        when xfer_7 =>
          DEBUG_REG_01(4 downto 0) <= "10110";
          ecl_bus_clk <= '1';
          state_a     <= xfer_8;
        when xfer_8 =>
          DEBUG_REG_01(4 downto 0) <= "10111";
          ecl_bus_data <= xfer_buffer(9 downto 8);
          ecl_bus_clk  <= '0';
          state_a      <= xfer_9;
        when xfer_9 =>
          DEBUG_REG_01(4 downto 0) <= "11000";
          ecl_bus_clk <= '1';
          state_a     <= xfer_10;
        when xfer_10 =>
          DEBUG_REG_01(4 downto 0) <= "11001";
          ecl_bus_data <= xfer_buffer(11 downto 10);
          ecl_bus_clk  <= '0';
          state_a      <= xfer_11;

        when xfer_11 =>
          DEBUG_REG_01(4 downto 0) <= "11010";
          ecl_bus_clk <= '1';
          state_a     <= xfer_12;
        when xfer_12 =>
          DEBUG_REG_01(4 downto 0) <= "11011";
          ecl_bus_data <= xfer_buffer(13 downto 12);
          ecl_bus_clk  <= '0';
          state_a      <= xfer_13;
        when xfer_13 =>
          DEBUG_REG_01(4 downto 0) <= "11100";
          ecl_bus_clk <= '1';
          state_a     <= xfer_14;
        when xfer_14 =>
          DEBUG_REG_01(4 downto 0) <= "11101";
          ecl_bus_data <= xfer_buffer(15 downto 14);
          ecl_bus_clk  <= '0';
          state_a      <= xfer_15;
        when xfer_15 =>
          DEBUG_REG_01(4 downto 0) <= "11110";
          ecl_bus_clk  <= '1';
          state_a      <= xfer_6;
          if state_b = checksum_0 then
            state_a    <= xfer_0alter;
          elsif state_b = checksum_1 then
            state_a    <= xfer_0alter;
          elsif state_b = finished then
            state_a    <= wait_for_busy;
          else state_a <= xfer_0;
          end if;
-----------------------------------------------------
        when wait_for_busy =>
          DEBUG_REG_01(4 downto 0) <= "11110";
          ecl_bus_clk  <= '0';
          ecl_bus_data <= "00";
          state_a      <= hold_busy;
        when hold_busy =>
          DEBUG_REG_01(4 downto 0) <= "11111";
          if bus_ack_s = '0' and ack_accu /= "0000" then  --ack accumulator
            ack_accu <= ack_accu - 1;
          elsif bus_ack_s = '1' and ack_accu /= "1111" then
            ack_accu <= ack_accu + 1;
          end if;
          if bus_retx_s = '0' and retx_accu /= "0000" then  --retransmit accumulator
            retx_accu <= retx_accu - 1;
          elsif bus_retx_s = '1' and retx_accu /= "1111" then
            retx_accu <= retx_accu + 1;
          end if;
          if retx_accu = 10 then
            state_a    <= start_sequence_0;
          elsif (ack_accu = 10 or com_run = '0') or TRB_BUSY_ENABLE = '0' then
            state_a    <= ready;
          else state_a <= hold_busy;
          end if;
---------------------------------------------------------------------
        when others =>
          DEBUG_REG_01(4 downto 0) <= "00000";
          state_a      <= ready;
      end case;
    end if;
    end if;
  end process;
  fsm2 : process(clk_100MHz)
  begin
    if rising_edge(clk_100MHz) then
      if com_run = '0' then
        state_b    <= tag;
      else
      case state_b is
        when tag =>
          DEBUG_REG_01(9 downto 5) <= "00001";
          xfer_buffer  <= tag_counter_dtu - 1;
          if state_a = xfer_13 then
            state_b    <= latches;
          else state_b <= tag;
          end if;
        when latches =>
          DEBUG_REG_01(9 downto 5) <= "00010";
          xfer_buffer  <= '0' & latch_dsc_s & '0' & latch_s;
          if state_a = xfer_13 then
            state_b    <= scalers_0;
          else state_b <= latches;
          end if;
        when scalers_0 =>
          DEBUG_REG_01(9 downto 5) <= "00011";
          xfer_buffer  <= scaler_pti1_s(15 downto 0);
          if state_a = xfer_13 then
            state_b    <= scalers_1;
          else state_b <= scalers_0;
          end if;
        when scalers_1 =>
          DEBUG_REG_01(9 downto 5) <= "00100";
          xfer_buffer  <= scaler_pti1_s(31 downto 16);
          if state_a = xfer_13 then
            state_b    <= scalers_2;
          else state_b <= scalers_1;
          end if;
        when scalers_2 =>
          DEBUG_REG_01(9 downto 5) <= "00101";
          xfer_buffer  <= scaler_pti2_s(15 downto 0);
          if state_a = xfer_13 then
            state_b    <= scalers_3;
          else state_b <= scalers_2;
          end if;
        when scalers_3 =>
          DEBUG_REG_01(9 downto 5) <= "00110";
          xfer_buffer  <= scaler_pti2_s(31 downto 16);
          if state_a = xfer_13 then
            state_b    <= scalers_4;
          else state_b <= scalers_3;
          end if;
        when scalers_4 =>
          DEBUG_REG_01(9 downto 5) <= "00111";
          xfer_buffer  <= scaler_pti3_s(15 downto 0);
          if state_a = xfer_13 then
            state_b    <= scalers_5;
          else state_b <= scalers_4;
          end if;
        when scalers_5 =>
          DEBUG_REG_01(9 downto 5) <= "01000";
          xfer_buffer  <= scaler_pti3_s(31 downto 16);
          if state_a = xfer_13 then
            state_b    <= scalers_6;
          else state_b <= scalers_5;
          end if;
        when scalers_6 =>
          DEBUG_REG_01(9 downto 5) <= "01001";
          xfer_buffer  <= scaler_pti4_s(15 downto 0);
          if state_a = xfer_13 then
            state_b    <= scalers_7;
          else state_b <= scalers_6;
          end if;
        when scalers_7 =>
          DEBUG_REG_01(9 downto 5) <= "01010";
          xfer_buffer  <= scaler_pti4_s(31 downto 16);
          if state_a = xfer_13 then
            state_b    <= scalers_8;
          else state_b <= scalers_7;
          end if;
        when scalers_8 =>
          DEBUG_REG_01(9 downto 5) <= "01011";
          xfer_buffer  <= scaler_pti5_s(15 downto 0);
          if state_a = xfer_13 then
            state_b    <= scalers_9;
          else state_b <= scalers_8;
          end if;
        when scalers_9 =>
          DEBUG_REG_01(9 downto 5) <= "01100";
          xfer_buffer  <= scaler_pti5_s(31 downto 16);
          if state_a = xfer_13 then
            state_b    <= scalers_10;
          else state_b <= scalers_9;
          end if;
        when scalers_10 =>
          DEBUG_REG_01(9 downto 5) <= "01110";
          xfer_buffer  <= scaler_ts_s(15 downto 0);
          if state_a = xfer_13 then
            state_b    <= scalers_11;
          else state_b <= scalers_10;
          end if;
        when scalers_11 =>
          DEBUG_REG_01(9 downto 5) <= "01111";
          xfer_buffer  <= scaler_ts_s(31 downto 16);
          if state_a = xfer_13 then
            state_b    <= scalers_12;
          else state_b <= scalers_11;
          end if;
        when scalers_12 =>
          DEBUG_REG_01(9 downto 5) <= "10000";
          xfer_buffer  <= scaler_vs_s(15 downto 0);
          if state_a = xfer_13 then
            state_b    <= scalers_13;
          else state_b <= scalers_12;
          end if;
        when scalers_13 =>
          DEBUG_REG_01(9 downto 5) <= "10001";
          xfer_buffer  <= scaler_vs_s(31 downto 16);
          if state_a = xfer_13 then
            state_b    <= scalers_14;
          else state_b <= scalers_13;
          end if;
        when scalers_14 =>
          DEBUG_REG_01(9 downto 5) <= "10010";
          xfer_buffer  <= scaler_dead_s(15 downto 0);
          if state_a = xfer_13 then
            state_b    <= scalers_15;
          else state_b <= scalers_14;
          end if;
        when scalers_15 =>
          DEBUG_REG_01(9 downto 5) <= "10011";
          xfer_buffer  <= scaler_dead_s(31 downto 16);
          if state_a = xfer_13 then
            state_b    <= checksum_0;
          else state_b <= scalers_15;
          end if;
        when checksum_0 =>
          DEBUG_REG_01(9 downto 5) <= "10101";
          xfer_buffer <= checksum(15 downto 0);					
          if state_a = xfer_13 then
            state_b <= checksum_1;
          else state_b <= checksum_0;
          end if;
        when checksum_1 =>
          DEBUG_REG_01(9 downto 5) <= "10110";
          xfer_buffer <= checksum(31 downto 16);
          if state_a = xfer_13 then
            state_b <= finished;
          else state_b <= checksum_1;
          end if;
        when finished =>
          DEBUG_REG_01(9 downto 5) <= "10111";
          xfer_buffer <= x"0000";
          if state_a = wait_for_busy then
            state_b <= tag;
          else state_b <= finished;
          end if;
        when others =>
          DEBUG_REG_01(9 downto 5) <= "00000";
          state_b <= tag;
      end case;
    end if;
    end if;
  end process;
----------------------------------------------------------------------	DTU comm
  PREPARE_CODE_FOR_DTU: process (clk_100MHz)
  begin  -- process PREPARE_CODE_FOR_DTU
    if rising_edge(clk_100MHz) then
      if com_run_s = '0' then
        prepared_code <= x"d";
      elsif com_run_s = '1' and cal_inhibit = '0' then
        prepared_code <= dtu_code;
      elsif com_run_s = '1' and cal_inhibit = '1' then
        prepared_code <= x"9";
      else
        prepared_code <= dtu_code;
      end if;
    end if;
  end process PREPARE_CODE_FOR_DTU;
  DTU_CODE_CHANGE : process (clk_100MHz)
  begin  -- process DTU_CODE_CHANGE
    if rising_edge (clk_100MHz) then
      if DTU_CODE_SELECT(4) = '0' then
        dtu_code <= x"1";
      else
        dtu_code <= DTU_CODE_SELECT(3 downto 0);
      end if;
    end if;
  end process DTU_CODE_CHANGE;
  fsm3 : process(clk_100MHz)            --TX lenght: 470 ns + wait time (currently 2.5 µs total)
  begin
    if rising_edge(clk_100MHz) then
      if com_run = '0' then
        state_c    <= idle;
        com_run_s  <= '0';
        dtu_bus_t       <= '0';
        dtu_bus_ts      <= '0';
        dtu_bus_td      <= x"d";
        count           <= 0;
        trb_go_norm     <= '0';
        trb_go_calib    <= '0';
        gts_dtu_r       <= '0';
        dtu_start       <= '0';        
      else
        -- implemented default value
        dtu_bus_t       <= '0';
        dtu_bus_ts      <= '0';
--        dtu_bus_td      <= x"d";
        dtu_bus_td  <= prepared_code;
      case state_c is
        when idle        =>
          DEBUG_REG_01(14 downto 10)<= "00001";
          dtu_bus_t       <= '0';
          dtu_bus_ts      <= '0';
--          dtu_bus_td      <= x"d";
          count           <= 0;
          trb_go_norm     <= '0';
          trb_go_calib    <= '0';
          gts_dtu_r       <= '0';
          dtu_start       <= '0';
--          com_run_s       <= com_run;
--          if com_run = '1' and com_run_s = '0' then
          if com_run = '1' and com_run_s = '0' then
            state_c       <= begin_run_0;
--           elsif com_run = '0' and com_run_s = '1' then
--             state_c       <= end_run_0;
          elsif gts_dtu_q = '1' and com_run = '1' then
            state_c       <= norm_event_0;
          elsif cal_trigger_pulse = '1' and com_run = '1' then
            state_c       <= calib_event_0;
          else state_c    <= idle;
          end if;
------------------------------------
        when begin_run_0 =>
          DEBUG_REG_01(14 downto 10)<= "00010";
          dtu_bus_t       <= '1';
          dtu_bus_ts      <= '0';
          dtu_bus_td      <= x"d";
 --       trb_go_norm     <= '1';
          tag_counter_dtu <= x"0000";
          com_run_s <= '1';
          dtu_start       <= '1';
          count           <= count + 1;
          if count = 4+5 then
            state_c       <= begin_run_1;
          else state_c    <= begin_run_0;
          end if;
        when begin_run_1 =>
          DEBUG_REG_01(14 downto 10)<= "00011";
          dtu_bus_t    <= '0';
          dtu_bus_ts   <= '0';
          dtu_bus_td      <= x"d";
          count        <= count + 1;
          if count = 9+10 then
            state_c    <= tag_low_0;
          else state_c <= begin_run_1;
          end if;
-------------------------------------
        when end_run_0   =>
          DEBUG_REG_01(14 downto 10)<= "00100";
          trb_run_s    <= '0';
          dtu_bus_t    <= '1';
          dtu_bus_ts   <= '0';
          dtu_bus_td   <= x"e";
          count        <= count + 1;
          if count = 4+5 then
            state_c    <= end_run_1;
          else state_c <= end_run_0;
          end if;
        when end_run_1    =>
          DEBUG_REG_01(14 downto 10)<= "00101";
          trb_run      <= '0';
          dtu_bus_t    <= '0';
          dtu_bus_ts   <= '0';
          count        <= count + 1;
          if count = 9+10 then
            state_c    <= tag_low_0;
          else state_c <= end_run_1;
          end if;
--------------------------------------
        when norm_event_0 =>
          DEBUG_REG_01(14 downto 10)<= "00110";
          trb_go_norm  <= '1';
          dtu_bus_t    <= '1';
          dtu_bus_ts   <= '0';
          dtu_bus_td   <= dtu_code;--    "1";
          count        <= count + 1;
          if count = 4+5 then
            state_c    <= norm_event_1;
          else state_c <= norm_event_0;
          end if;
        when norm_event_1  =>
          DEBUG_REG_01(14 downto 10)<= "00111";
          trb_go_norm  <= '0';
          dtu_bus_t    <= '0';
          dtu_bus_ts   <= '0';
          dtu_bus_td   <= dtu_code;
          count        <= count + 1;
          if count = 9+10 then
            state_c    <= tag_low_0;
          else state_c <= norm_event_1;
          end if;
---------------------------------------
        when calib_event_0 =>
          DEBUG_REG_01(14 downto 10)<= "01000";
          trb_go_calib <= '1';
          dtu_bus_t    <= '1';
          dtu_bus_ts   <= '0';
          dtu_bus_td   <= x"9";
          count        <= count + 1;
          if count = 4+5 then
            state_c    <= calib_event_1;
          else state_c <= calib_event_0;
          end if;
        when calib_event_1 =>
          DEBUG_REG_01(14 downto 10)<= "01001";
          trb_go_calib <= '0';
          dtu_bus_t    <= '0';
          dtu_bus_ts   <= '0';
          dtu_bus_td   <= x"9";
          count        <= count + 1;
          if count = 9+10 then
            state_c    <= tag_low_0;
          else state_c <= calib_event_1;
          end if;
---------------------------------------------------------
        when tag_low_0     =>
          DEBUG_REG_01(14 downto 10)<= "01010";
          dtu_bus_t    <= '0';
          dtu_bus_ts   <= '1';
          dtu_bus_td   <= tag_counter_dtu(3 downto 0);
          count        <= count + 1;
          if count = 14+15 then
            state_c    <= tag_low_1;
          else state_c <= tag_low_0;
          end if;
        when tag_low_1 =>
          DEBUG_REG_01(14 downto 10)<= "01011";
          dtu_bus_t    <= '0';
          dtu_bus_ts   <= '0';
          dtu_bus_td   <= tag_counter_dtu(3 downto 0);
          count        <= count + 1;
          if count = 19+20 then
            state_c    <= tag_high_0;
          else state_c <= tag_low_1;
          end if;
        when tag_high_0 =>
          DEBUG_REG_01(14 downto 10)<= "01100";
          dtu_bus_t    <= '0';
          dtu_bus_ts   <= '1';
          dtu_bus_td   <= tag_counter_dtu(7 downto 4);
          count        <= count + 1;
          if count = 24+25 then
            state_c    <= tag_high_1;
          else state_c <= tag_high_0;
          end if;
        when tag_high_1 =>
          DEBUG_REG_01(14 downto 10)<= "01101";
          dtu_bus_t    <= '0';
          dtu_bus_ts   <= '0';
          dtu_bus_td   <= tag_counter_dtu(7 downto 4);
          count        <= count + 1;
          if count = 29+30 then
            state_c    <= tag_prio_0;
          else state_c <= tag_high_1;
          end if;
        when tag_prio_0 =>
          DEBUG_REG_01(14 downto 10)<= "01110";
          dtu_bus_t    <= '0';
          dtu_bus_ts   <= '1';
          dtu_bus_td   <= tag_counter_dtu(7 downto 4);
          count        <= count + 1;
          if count = 34+35 then
            state_c    <= tag_prio_1;
          else state_c <= tag_prio_0;
          end if;
        when tag_prio_1 =>
          DEBUG_REG_01(14 downto 10)<= "01111";
          dtu_bus_t    <= '0';
          dtu_bus_ts   <= '0';
          count        <= count + 1;
          dtu_bus_td   <= tag_counter_dtu(7 downto 4);
          if count = 39+40 then
            state_c    <= wait_last;
          else state_c <= tag_prio_1;
          end if;
        when wait_last =>
          DEBUG_REG_01(14 downto 10)<= "10000";
          dtu_bus_t    <= '0';
          dtu_bus_ts   <= '0';
--          dtu_bus_td   <= "0000";
          count        <= count + 1;
          if count = 244 then           --change this to increase wait time (44 default)
            state_c    <= wait_for_trb;
          else state_c <= wait_last;
          end if;
        when wait_for_trb =>
          DEBUG_REG_01(14 downto 10)<= "10001";
          dtu_bus_t    <= '0';
          dtu_bus_ts   <= '0';
--          dtu_bus_td   <= "0000";
          if trb_finished = '1' or dtu_start = '1' then
            state_c    <= count_incr;
          else state_c <= wait_for_trb;
          end if;
        when count_incr =>
          dtu_bus_t    <= '0';
          dtu_bus_ts   <= '0';
--          dtu_bus_td   <= "0000";
          DEBUG_REG_01(14 downto 10)<= "10010";
          gts_dtu_r       <= '1';
          tag_counter_dtu <= tag_counter_dtu + 1;
          state_c         <= idle;
        when others =>
          dtu_bus_t    <= '0';
          dtu_bus_ts   <= '0';
--          dtu_bus_td   <= "0000";
          DEBUG_REG_01(14 downto 10)<= "00000";      
          state_c <= idle;
      end case;
    end if;
    end if;
  end process;
end Behavioral;
