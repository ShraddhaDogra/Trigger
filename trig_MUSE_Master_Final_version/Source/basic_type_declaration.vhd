library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use Ieee.std_logic_unsigned.all; 


-- Package declaration
package basic_type_declaration is
	-- each trigger channel has 5 bit trigger_delay mask that delays signals by up to 31x5ns = 155 ns
	type array48 is array (natural range <>) of std_logic_vector(47 downto 0);
	type array32 is array (natural range <>) of std_logic_vector(31 downto 0);
	type array5  is array (natural range <>) of std_logic_vector(4 downto 0);
    type array4  is array (integer range <>) of std_logic_vector(3 downto 0); -- Ievgen: May 24, 2019

end package basic_type_declaration;