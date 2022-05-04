library  ieee;
use  ieee.std_logic_1164.all;

library work;
use work.trb_net_std.all;

entity SmallBars_TrigLogic is
	  port(
	  in_clk: in std_logic;
	  in_BM: in std_logic_vector (31 downto 0);
	  out_BM_SmallBars: out std_logic
	        );
end SmallBars_TrigLogic;

architecture BM of SmallBars_TrigLogic is
 signal  out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11,
out12, out13, out14, out15 :std_logic;

	
 begin
	out0<= in_BM(8) and in_BM(0);
	out1<= in_BM(9) and in_BM(1);
	out2<= in_BM(16) and in_BM(24);
	out3<= in_BM(17) and in_BM(25);
	out4<= in_BM(10) and in_BM(2);
	out5<= in_BM(11) and in_BM(3);
	out6<= in_BM(26) and in_BM(18);
	out7<= in_BM(27) and in_BM(19);
	out8<= in_BM(12) and in_BM(4);
	out9<= in_BM(13) and in_BM(5);
	out10<= in_BM(28) and in_BM(20);
	out11<= in_BM(29) and in_BM(21);
	out12<= in_BM(14) and in_BM(6);
	out13<= in_BM(15) and in_BM(7);
	out14<= in_BM(31) and in_BM(22);
	out15<= in_BM(30) and in_BM(23);
	
	
	--ANded outputs--------------------------
	
	out_BM_SmallBars<= out0 or out1 or out2 or out3 or out4 or out5 or 
	                   out6 or out7 or out8 or out9 or out10 or out11 
					   or out12 or out13 or out14 or out15;
	                        	
 end BM;
	