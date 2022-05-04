

library  ieee;
use  ieee.std_logic_1164.all;

library work;
use work.trb_net_std.all;

entity Veto_OrAll is
	  port(
	  in_clk: in std_logic;
	  in_veto: in std_logic_vector (7 downto 0);
	  out_veto: out std_logic
	        );
end Veto_OrAll;

architecture Veto of Veto_OrAll is
 signal outa, outb, outc, outd :std_logic;
 
	
 begin
	outa<= in_veto(7) OR in_veto(6);
	outb<= in_veto(5) OR in_veto(4);
	outc<= in_veto(3) OR in_veto(2);
	outd<= in_veto(1) OR in_veto(0);
	
	out_veto <= outa OR outb OR outc OR outd;
	
	
 end Veto;
	
	
