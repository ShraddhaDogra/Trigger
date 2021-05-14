library  ieee;
use  ieee.std_logic_1164.all;

library work;
use work.trb_net_std.all;

-- comment for vhdl

entity And6 is 
	port ( 
		input : in std_logic_vector(5 downto 0);
		output : out std_logic );
end And6;

architecture apply_and of And6 is
	
begin
	output <= input(0) AND input(1) AND input(2) AND input(3) AND input(4) AND input(5);
	
end apply_and;
