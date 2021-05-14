

library  ieee;
use  ieee.std_logic_1164.all;

library work;
use work.trb_net_std.all;

entity Veto_Logic is
	  port(
	  in_clk: in std_logic;
	  in_veto: in std_logic_vector (7 downto 0);
	  out_veto: out std_logic_vector (3 downto 0)
	        );
end Veto_Logic;

architecture Veto of Veto_Logic is
 signal outa, outb, outc, outd :std_logic;
 --signal out_or, out_not: std_logic;
	
 begin
	outa<= in_veto(7) and in_veto(6);
	outb<= in_veto(5) and in_veto(4);
	outc<= in_veto(3) and in_veto(2);
	outd<= in_veto(1) and in_veto(0);
	
	out_veto(0)<= outa;
	out_veto(1)<= outb;
	out_veto(2)<= outc;
	out_veto(3)<= outd;
	--out_or<= outa or outb or outc or outd;
	--out_not<= not(out_or);
	
	--out_veto<= out_not;
 end Veto;
	
	
