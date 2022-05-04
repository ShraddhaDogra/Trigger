
-- This code Ors five bars in the back SPS plane.
--//// written by Shraddha Dogra.


library ieee;
USE IEEE.std_logic_1164.ALL;
--Use IEEE.Numeric_Std_Unsigned

entity BackOr5 is
port( back: in std_logic_vector (27 downto 0);
   and_out: out std_logic_vector (17 downto 0)); 
end BackOr5;

architecture structure of BackOr5 is
 begin
 and_out(0) <= back(1) or  back(2) or  back(3) or  back(0) or back(4); 
 and_out(1) <= back(2) or  back(3) or  back(4) or  back(5) or back(1) or back(6);
 and_out(2) <= back(3) or  back(4) or  back(5) or  back(6) or back(2) or back(7);
 and_out(3) <= back(5) or  back(6) or  back(7) or  back(4) or back(8);
 and_out(4) <= back(6) or  back(7) or  back(8) or  back(9) or back(5) or back(10);
 and_out(5) <= back(7) or  back(8) or  back(9) or  back(10) or back(6) or back(11);
 and_out(6) <= back(9) or  back(10) or  back(11) or  back(8) or back(12);
 and_out(7) <= back(10) or  back(11) or  back(12) or  back(13) or  back(9) or back(14);
 and_out(8) <= back(12) or  back(13) or  back(14) or  back(11) or  back(15);
 and_out(9) <= back(13) or  back(14) or  back(15) or  back(12) or  back(16);
 and_out(10) <= back(14) or  back(15) or  back(16) or  back(17) or  back(13) or  back(18) ;
 and_out(11) <= back(16) or  back(17) or  back(18) or  back(15) or  back(19) ;
 and_out(12) <= back(17) or  back(18) or  back(19) or  back(20) or  back(16) or  back(21) ;
 and_out(13) <= back(18) or  back(19) or  back(20) or  back(21) or  back(17) or  back(22) ;
 and_out(14) <= back(20) or  back(21) or  back(22) or  back(19) or  back(23);
 and_out(15) <= back(21) or  back(22) or  back(23) or  back(24) or  back(20) or  back(25) ;
 and_out(16) <= back(22) or  back(23) or  back(24) or  back(25) or  back(21) or  back(26) ;
 and_out(17) <= back(24) or  back(25) or  back(26) or  back(23) or  back(27);
 
end structure;
 