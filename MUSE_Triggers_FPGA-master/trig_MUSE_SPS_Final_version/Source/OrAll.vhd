library ieee;
USE IEEE.std_logic_1164.ALL;
--Use IEEE.Numeric_Std_Unsigned

entity OrAll is
port( input2: in std_logic_vector(17 downto 0);
	  input1: in std_logic_vector(27 downto 0);
      output1: out std_logic);  
end OrAll;

architecture structure_Orall of OrAll is
 signal out0: std_logic_vector(7 downto 0);
 signal out1: std_logic;
 signal out2: std_logic;
 
 begin
 
 out0(0) <= input2(17) or input2(16) or input2(15) or input2(14) or input2(13) or input2(12);
 out0(1) <= input2(11) or input2(10) or input2(9) or input2(8) or input2(7) or input2(6);
 out0(2) <= input2(5) or input2(4) or input2(3) or input2(2) or input2(1) or input2(0);
 
 out0(3) <= input1(27) or input1(26) or input1(25) or input1(24) or input1(23) or input1(22);
 out0(4) <= input1(21) or input1(20) or input1(19) or input1(18) or input1(17) or input1(16);
 out0(5) <= input1(15) or input1(14) or input1(13) or input1(12) or input1(11) or input1(10);
 out0(6) <= input1(9) or input1(8) or input1(7) or input1(6) or input1(5) or input1(4);
 out0(7) <= input1(3) or input1(2) or input1(1) or input1(0);
 
 out1 <= out0(0) or out0(1) or out0(2);
 out2 <= out0(3) or out0(4) or out0(5) or out0(6) or out0(7);
 
 Output1<= out1 or out2;
 end structure_Orall;
 