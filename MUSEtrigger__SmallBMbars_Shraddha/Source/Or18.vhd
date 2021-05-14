library ieee;
USE IEEE.std_logic_1164.ALL;
--Use IEEE.Numeric_Std_Unsigned

entity Or18 is
port( input1: in std_logic_vector(17 downto 0);
      output1: out std_logic);  
end Or18;

architecture structure_Or18 of Or18 is
 signal outa, outb, outc, outd, oute, outf, out1, out2: std_logic;
 begin
 outa <= input1(17) or input1(16) or input1(15);
 outb <= input1(14) or input1(13) or input1(12);
 outc <= input1(11) or input1(10) or input1(9);
 outd <= input1(8) or input1(7) or input1(6);
 oute <= input1(5) or input1(4) or input1(3);
 outf <= input1(2) or input1(1) or input1(0);
 
 out1 <= outa or outb or outc;
 out2 <= oute or outd or outf;
 
 Output1<= out1 or out2;
 end structure_Or18;
 