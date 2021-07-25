---------------------------------------------------------------------------------------------------------------
--Implementation of a pulse generator, with single channel output.
---------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;

entity single_channel_pulser is
  
    port(
      CLK					: in std_logic;
      RESET				: in std_logic;
      FREQUENCY		: in unsigned(23 downto 0);
      PULSE_WIDTH	: in unsigned(23 downto 0);
      OFFSET      : in unsigned(23 downto 0);
      ENABLE      : in std_logic;
      PULSE				: out std_logic_vector(3 downto 0)
    );
    
end entity;
  
architecture single_channel_pulser_arch of single_channel_pulser is

signal timer								:	unsigned(23 downto 0) := (others => '0');  
signal last_timer           : unsigned(23 downto 0) := (others => '0');  
signal reset_counter				:	std_logic;
signal frequency_in         : unsigned(23 downto 0);  
signal frequency_i					:	unsigned(23 downto 0);	
signal reset_delay					:	std_logic;
signal pulse_width_in       : unsigned(23 downto 0);
signal pulse_width_i				:	unsigned(23 downto 0);

type state_type is (idle, generate_pulse, finish);
signal state : state_type;


begin

PROC_REGS : process begin
  wait until rising_edge(CLK);
  if RESET = '1' then
    pulse_width_in <= PULSE_WIDTH;
    frequency_in <= FREQUENCY;
  end if;  
end process;  

	PROC_TIMER : process (CLK)		--it counts 
		begin
			if rising_edge(CLK) then
				if reset_counter = '1' then	
					timer <= (others => '0'); 
				else 
					timer <= timer+1;
				end if;
			end if;
		end process;

	PROC_FREQUENCY : process (CLK)	--It eliminates the offset of -3 for the frequency  
		begin
			if rising_edge(CLK) then
				if frequency_in >= x"000003" then
					frequency_i <= frequency_in-3;
				end if;
			reset_delay <= RESET;	--I want the timer to start again after the operations with the frequency
      end if;
    end process;


	PROC_RESET_COUNTER: process (CLK)	--it resets (reset_counter active high) when timer=FREQUENCY or reset_delay=1 or the FF change	
		begin
			if rising_edge(CLK) then
				if reset_delay = '1' or last_timer = frequency_i or RESET = '1' then --was FREQUENCY
					reset_counter <= '1';
				else
				 	reset_counter <= '0';
				end if;      
      end if;
		end process;
  
  
last_timer <= timer when rising_edge(CLK);  
  
	PROC_PULSE_MANAGER  : process(CLK)	
	  variable p : std_logic_vector(3 downto 0);
		begin	
			if RESET = '1' then 
				state <= idle;			
				
			elsif rising_edge(CLK) then
				
				case state is
				
					when idle =>	
            p := "0000";
            pulse_width_i <= pulse_width_in;
            
						if last_timer = OFFSET and ENABLE = '1' then
							state <= generate_pulse;
						end if;
						
					when generate_pulse =>
						if pulse_width_i = x"000002" then 
							p := "0011";
						elsif pulse_width_i = x"000003" then 
							p := "0111";
						elsif pulse_width_i >= x"000004" then 
							p := "1111"; 
						else 
							p := "0001";
						end if;
            pulse_width_i <= pulse_width_i-4;
            
						if pulse_width_i <= 4 then
							state <= finish;
						else 
							state <= generate_pulse;
						end if;
						
					when finish =>
						state <= idle;
						p := "0000";

				end case;
				
				PULSE <= p;
				
			end if;	
			
			

		end process;
	

end architecture;

  