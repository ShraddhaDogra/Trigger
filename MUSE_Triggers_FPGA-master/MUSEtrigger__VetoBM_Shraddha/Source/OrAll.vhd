library ieee;
USE IEEE.std_logic_1164.ALL;
--Use IEEE.Numeric_Std_Unsigned

entity OrAll is
port( 
      in_clk:in std_logic;
      input: in std_logic_vector(31 downto 0);
      output: out std_logic);  
end OrAll;

architecture structure_Orall of OrAll is
 signal out0: std_logic_vector(5 downto 0);
 signal out1: std_logic;

 
 begin
 
 out0(0) <= input(17) or input(16) or input(15) or input(14) or input(13) or input(12);
 out0(1) <= input(11) or input(10) or input(9) or input(8) or input(7) or input(6);
 out0(2) <= input(5) or input(4) or input(3) or input(2) or input(1) or input(0);
 out0(3) <= input(18) or input(19) or input(20) or input(21) or input(22) or input(23);
 out0(4) <= input(24) or input(25) or input(26) or input(27) or input(28) or input(29);
 out0(5) <=  input(30) or input(31);
 
 out1 <= out0(0) or out0(1) or out0(2) or out0(3) or out0(4) or out0(5)  ;
 
 
 output <= out1 ;
 end structure_Orall;
 