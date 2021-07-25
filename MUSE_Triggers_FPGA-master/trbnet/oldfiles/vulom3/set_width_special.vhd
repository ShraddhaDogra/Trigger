--------------------------------------------------------------------------------
-- Company: 	GSI
-- Engineer:	Davide Leoni
--
-- Create Date:   8/3/07
-- Design Name:   vulom3 
-- Module Name:   set_width_special - Behavioral
-- Project Name:  triggerbox 
-- Target Device:	XC4VLX25-10SF363  
-- Tool versions:  		
-- Description: 16 clock cycle programmable pulse shaper specific for output 
--					 (it can handle pulses wider than 1 ck cycle)
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.vcomponents.all;

entity set_width_special is port (
  clk : in std_logic;
   to_be_set : in std_logic;
   width_value : in std_logic_vector(3 downto 0);
   width_adjusted_pulse : out std_logic);
end set_width_special;

architecture Behavioral of set_width_special is
signal reset_timing_signal, clocked_timing_signal : std_logic;
signal timing_signal_counter : std_logic_vector(5 downto 0);
signal start_pulse, end_pulse : std_logic;
signal during_pulse, to_be_set_synch, to_be_set_synch_delayed : std_logic;

begin
  
  SYNCH_TO_BE_SET: process (CLK)
  begin 
    if rising_edge(CLK) then
      to_be_set_synch <= to_be_set;
      to_be_set_synch_delayed <= to_be_set_synch;
    end if;
  end process SYNCH_TO_BE_SET;
  MAKE_START: process (CLK)
  begin  
    if rising_edge(CLK) then
      if to_be_set_synch_delayed = '0' and to_be_set_synch = '1' then
        start_pulse <=  '1';
        end_pulse <=  '0';
      elsif to_be_set_synch_delayed = '1' and to_be_set_synch = '0' then
        start_pulse <=  '0';
        end_pulse <=  '1';
      else
        start_pulse <=  '0';
        end_pulse <=  '0';
      end if;
    end if;
  end process MAKE_START;
  DURING_PULSE_PROC: process (CLK)
  begin 
    if rising_edge(CLK) then
      if start_pulse = '1' then
        during_pulse <= '1';
      elsif timing_signal_counter(5) = '1' then
        during_pulse <= '0';
      end if;
    end if;
  end process DURING_PULSE_PROC;


  PULSER_LENGHT_COUNTER: process (CLK)
  begin  
    if rising_edge(CLK) then
      if during_pulse = '1' then
        timing_signal_counter <= timing_signal_counter + 1;
      elsif start_pulse = '1' then
        timing_signal_counter <= (others => '0');
      else
        timing_signal_counter <= timing_signal_counter;
      end if;
    end if;
  end process PULSER_LENGHT_COUNTER;
  width_adjusted_pulse <= during_pulse;--to_be_set or during_pulse;
end Behavioral;
