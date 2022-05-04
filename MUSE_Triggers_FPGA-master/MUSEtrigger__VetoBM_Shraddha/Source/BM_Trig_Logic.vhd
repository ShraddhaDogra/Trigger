library  ieee;
use  ieee.std_logic_1164.all; 

library work;
use work.trb_net_std.all;

entity BM_Trig_Logic is
	  port(
	  in_clk: in std_logic;
	  in_BM: in std_logic_vector (7 downto 0);
	  out_BM: out std_logic_vector(3 downto 0)
	        );
end BM_Trig_Logic;

architecture BM of BM_Trig_Logic is
 signal outa, outb, outc, outd :std_logic;
 --signal out_or: std_logic;
	
 begin
	outa<= in_BM(7) and in_BM(6);
	outb<= in_BM(5) and in_BM(4);
	outc<= in_BM(3) and in_BM(2);
	outd<= in_BM(1) and in_BM(0);
	
	--out_or<= outa or outb or outc or outd;
	out_BM(3)<= outd; 
	out_BM(2)<= outc;
    out_BM(1)<= outb; 	
	out_BM(0)<= outa;
	
 end BM;
	