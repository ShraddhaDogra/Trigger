library ieee;
USE IEEE.std_logic_1164.ALL;
--Use IEEE.Numeric_Std_Unsigned

entity Or_back_bars is
port(
	  input1: in std_logic_vector(27 downto 0);
      output1: out std_logic);  
end Or_back_bars;

architecture structure_Or_back_bars of or_back_bars is
 signal out0: std_logic_vector(4 downto 0);
 signal out1: std_logic;

 
 begin
 
 out0(4) <= input1(27) or input1(26) or input1(25) or input1(24) or input1(23) or input1(22);
 out0(3) <= input1(21) or input1(20) or input1(19) or input1(18) or input1(17) or input1(16);
 out0(2) <= input1(15) or input1(14) or input1(13) or input1(12) or input1(11) or input1(10);
 out0(1) <= input1(9) or input1(8) or input1(7) or input1(6) or input1(5) or input1(4);
 out0(0) <= input1(3) or input1(2) or input1(1) or input1(0);
 
 out1 <= out0(4) or out0(3) or out0(2) or out0(1) or out0(0);
 
 Output1<= out1;
 end structure_Or_back_bars;
 