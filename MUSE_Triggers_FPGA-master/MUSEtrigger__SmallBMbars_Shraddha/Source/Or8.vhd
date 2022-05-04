library ieee;
USE IEEE.std_logic_1164.ALL;
--Use IEEE.Numeric_Std_Unsigned

entity Or8 is
port( input1: in std_logic_vector(7 downto 0);
      output1: out std_logic);  
end Or8;

architecture structure_Or8 of Or8 is
 signal outa, outb, outc: std_logic;
 begin
 outa <= input1(7) or input1(6) or input1(5);
 outb <= input1(4) or input1(3) or input1(2);
 outc <= input1(1) or input1(0);
 output1 <= outa or outb or outc;
 end structure_Or8;
 

