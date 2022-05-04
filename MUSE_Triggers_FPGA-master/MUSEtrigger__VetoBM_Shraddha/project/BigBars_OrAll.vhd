library ieee;
USE IEEE.std_logic_1164.ALL;
--Use IEEE.Numeric_Std_Unsigned

entity BigBars_OrAll is
port( 
 in_clk: in std_logic;
       input: in std_logic_vector(8 downto 0);
      output: out std_logic);  
end  BigBars_OrAll;

architecture structure_Orall of OrAll is
 signal out0: std_logic;
 

 
 begin
 
 out0 <= input(7) or input(6) or input(5) or input(4) or input(3) or input(2) or input(1) or input(0);
 
 Output<= out0 ;
 
 end structure_Orall;
 