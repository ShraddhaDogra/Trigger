-----------------------------------------------------------------------------
-- Mupix 8 injection generator
-- Tobias Weber
-- Ruhr Unversitaet Bochum
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity injection_generator is
  port (
    rst                  : in  std_logic;--! reset input
    clk                  : in  std_logic;--! clock input
    pulse_length         : in  std_logic_vector(15 downto 0); --! length of injection pulse
    pulse_start          : in  std_logic;--! start generation of pulse
    pulse_o              : out std_logic --! output signal to mupix board
    );
end injection_generator;


architecture rtl of injection_generator is

	type injection_generator_type is (idle, gen);
	signal injection_generator_fsm : injection_generator_type := idle;  
	signal counter : unsigned(15 downto 0) := (others => '0');
	
begin

 	injection_gen : process(clk) is
 	begin
 		if rising_edge(clk) then
 			if rst = '1' then
 				counter <= (others => '0');
 				injection_generator_fsm <= idle;
 				pulse_o <= '0';
 			else
 				case injection_generator_fsm is  
 					when idle =>
 						pulse_o <= '0';
 				  		counter <= (others => '0');
 				  		if pulse_start = '1' then
 				  			injection_generator_fsm <= gen;
 				  		else
 				  			injection_generator_fsm <= idle;
 				  		end if;
 				  	when gen =>
 				  		pulse_o <= '1';
 				  		counter <= counter + 1;
 				  		if counter = unsigned(pulse_length) then
 				  			injection_generator_fsm <= idle;
 				  		else
 				  			injection_generator_fsm <= gen;
 				  		end if;
 				end case; 
 			end if;
 		end if;
 	end process injection_gen;
 	
  
end rtl;
