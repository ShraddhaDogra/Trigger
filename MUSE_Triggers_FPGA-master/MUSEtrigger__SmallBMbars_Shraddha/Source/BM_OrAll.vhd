

library  ieee;
use  ieee.std_logic_1164.all;

library work;
use work.trb_net_std.all;

entity BM_OrAll is
	  port(
	  in_clk: in std_logic;
	  in_BM: in std_logic_vector (7 downto 0);
	  out_BM: out std_logic
	        );
end BM_OrAll;

architecture BM of BM_OrAll is
 signal outa, outb, outc, outd :std_logic;
 
	
 begin
	outa<= in_BM(7) OR in_BM(6);
	outb<= in_BM(5) OR in_BM(4);
	outc<= in_BM(3) OR in_BM(2);
	outd<= in_BM(1) OR in_BM(0);
	
	out_BM <= outa OR outb OR outc OR outd;
	
	
 end BM;
	
	
