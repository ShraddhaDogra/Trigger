library  ieee;
use  ieee.std_logic_1164.all;

library work;
use work.trb_net_std.all;

entity BM_Trig_Logic is
	  port(
	  in_clk: in std_logic;
	  in_BM: in std_logic_vector (63 downto 0);
	  out_BM: out std_logic_vector(31 downto 0)
	        );
end BM_Trig_Logic;

architecture BM of BM_Trig_Logic is
 signal  out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11,
out12, out13, out14, out15, out16, out17, out18, out19, out20, out21, out22, out23, out24, out25, out26, 
out27, out28, out29, out30, out31:std_logic;
 --signal out_or: std_logic;
	
 begin
 --this mapping is wrong################################
 -- check it!!!!!!!!!!!!!!!!!!!!!!!!!!!!111
	out0<= in_BM(24) and in_BM(16);
	out1<= in_BM(20) and in_BM(17);
	out2<= in_BM(22) and in_BM(20);
	out3<= in_BM(30) and in_BM(21);
	out4<= in_BM(26) and in_BM(18);
	out5<= in_BM(27) and in_BM(19);
	out6<= in_BM(22) and in_BM(24);
	out7<= in_BM(23) and in_BM(25);
	out8<= in_BM(28) and in_BM(20);
	out9<= in_BM(29) and in_BM(21);
	out10<= in_BM(24) and in_BM(26);
	out11<= in_BM(25) and in_BM(27);
	out12<= in_BM(30) and in_BM(22);
	out13<= in_BM(31) and in_BM(23);
	out14<= in_BM(26) and in_BM(28);
	out15<= in_BM(27) and in_BM(29);
	out16<= in_BM(24) and in_BM(16);
	out17<= in_BM(20) and in_BM(17);
	out18<= in_BM(22) and in_BM(20);
	out19<= in_BM(30) and in_BM(21);
	out20<= in_BM(26) and in_BM(18);
	out21<= in_BM(27) and in_BM(19);
	out22<= in_BM(22) and in_BM(24);
	out23<= in_BM(23) and in_BM(25);
	out24<= in_BM(28) and in_BM(20);
	out25<= in_BM(29) and in_BM(21);
	out26<= in_BM(24) and in_BM(26);
	out27<= in_BM(25) and in_BM(27);
	out28<= in_BM(30) and in_BM(22);
	out29<= in_BM(31) and in_BM(23);
	out30<= in_BM(26) and in_BM(28);
	out31<= in_BM(27) and in_BM(29);
	
	
	--ANded outputs--------------------------
	
	out_BM(0)<= out0; 
	out_BM(1)<= out1;
	out_BM(2)<= out2;
	out_BM(3)<= out3;
	out_BM(4)<= out4;
	out_BM(5)<= out5;
	out_BM(6)<= out6;
	out_BM(7)<= out7;
	out_BM(8)<= out8;
	out_BM(9)<= out9;
	out_BM(10)<= out10;
	out_BM(11)<= out11;
	out_BM(12)<= out12;
	out_BM(13)<= out13;
	out_BM(14)<= out14;
	out_BM(15)<= out15;
	out_BM(16)<= out16;
	out_BM(17)<= out17;
	out_BM(18)<= out18;
	out_BM(19)<= out19;
	out_BM(20)<= out20;
	out_BM(21)<= out21;
	out_BM(22)<= out22;
	out_BM(23)<= out23;
	out_BM(24)<= out24;
	out_BM(25)<= out25;
	out_BM(26)<= out26;
	out_BM(27)<= out27;
	out_BM(28)<= out28;
	out_BM(29)<= out29;
	out_BM(30)<= out30;
	out_BM(31)<= out31;
	
 end BM;
	