-- Thsi code is a testbench for PlaneOr function.
-- this testbench is written by Win.



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PlaneOr_tb is
end PlaneOr_tb;

architecture Behavioral of PlaneOr_tb is
--Component name and entity's name must be same
--ports must be same 
 component PlaneOr 
  Port (
		front_input : in std_logic_vector(17 downto 0);
		back_input : in std_logic_vector(27 downto 0);
		or_output : out std_logic );
end component;
--inputs
signal front_input_tb : std_logic_vector(17 downto 0):= (others => '0');
signal back_input_tb : std_logic_vector(27 downto 0):= (others => '0');
--outputs
signal output_tb : std_logic;

begin
test: PlaneOr PORT MAP(
					front_input => front_input_tb,
					back_input => back_input_tb,
					or_output => output_tb);
--Stimulus Process
stim_proc:process
begin

wait for 10ns;
front_input_tb(0) <= '1';

wait for 10ns;
front_input_tb(0) <= '0';

wait for 10ns;
front_input_tb(7) <= '1';

wait for 10ns;
front_input_tb(7) <= '0';

wait for 10 ns;
front_input_tb(5 downto 0) <= "111111";

wait for 10ns;
front_input_tb(5 downto 0) <= "000000";

wait for 10 ns;
front_input_tb(10 downto 8) <= "111";

wait for 10ns;
front_input_tb(10 downto 8) <= "000";

wait for 10ns;
back_input_tb(2) <= '1';

wait for 10ns;
back_input_tb(2) <= '0';

wait for 10ns;
back_input_tb(15) <= '1';

wait for 10ns;
back_input_tb(15) <= '0';

wait for 10ns;
back_input_tb(9 downto 4) <= "111111";

wait for 10ns;
back_input_tb(9 downto 4) <= "000000";

wait for 10ns;
back_input_tb(25 downto 22) <= "1111";

wait for 10ns;
back_input_tb(25 downto 22) <= "0000";

wait for 10ns;
front_input_tb(7 downto 6) <= "11";
back_input_tb(25 downto 23) <= "111";
front_input_tb(12) <= '1';

wait for 10ns;
front_input_tb(7 downto 6) <= "00";
back_input_tb(25 downto 23) <= "000";
front_input_tb(12) <= '0';

wait for 100ns;

end process;
end Behavioral;
