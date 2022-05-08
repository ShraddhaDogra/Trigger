library  ieee;
use  ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

library work;
use work.trb_net_std.all;

entity trig_selector is
 generic (N: integer :=4);-- no. of inputs can't increase 16 (0 to 15).
 port (in_trig_signal: in std_logic_vector (N-1 downto 0);
       out_trig_selector: out std_logic;
	   trig_select: in std_logic_vector (3 downto 0)
	   );
end trig_selector;

architecture structural of trig_selector is
 --signal the_integer: std_logic_vector(N-1 downto 0);
   signal temp : integer range 0 to N-1;
   
 begin 
 
 temp <= to_integer(unsigned(trig_select));
 out_trig_selector <= in_trig_signal(temp);
  
end structural;
  
	   
	   
	   
	   
	   
	   
	   
	   
	   
	   
	   
	   