--Ievgen Lavrukhin: -------------------------------------------------------------
--Stretch Signal for  number of clock cycles  -----------------------------------
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

library work;
use work.basic_type_declaration.all;


entity prescale_trig_ch is
  generic(
    NUMBER : integer := 10  -- number of input channels 
    );
  port(
    sig_in  	  : in  std_logic_vector(NUMBER-1 downto 0); -- input channels from the trigger ;
	clk_in		  : in std_logic;
    prescale_ch   : in  array4(0 to NUMBER-1); -- prescale power for each channel;
	reset		  : in  std_logic; -- reset option;
    sig_out 	  : out std_logic_vector(NUMBER-1 downto 0)  -- output channels after prescaler;
	);
end entity;

architecture arch of prescale_trig_ch is

	component prescaler_pow2 is
		port (
			input			: in  std_logic;
			clk_in			: in std_logic;
			prescale_power	: in  std_logic_vector (3 downto 0);
			reset 			: in std_logic;
			output			: out std_logic
		);
	end component prescaler_pow2;
 
  
begin

---------------------------------  CODE: -----------------------------------------------------

GEN_PRESCALER:
	for i in 0 to NUMBER-1 generate
	P_PRESCALER:
			prescaler_pow2 port map (
								input			=> sig_in(i),
								clk_in			=> clk_in,
								prescale_power	=> prescale_ch(i),
								reset 			=> reset,
								output			=> sig_out(i)
							);	
end generate GEN_PRESCALER;





end architecture;
