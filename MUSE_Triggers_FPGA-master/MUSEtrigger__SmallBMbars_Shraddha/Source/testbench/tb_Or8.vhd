library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity tb_Or8 is
--  Port ( );
end tb_Or8;

architecture Behavioral of tb_Or8 is
--Component name and entity's name must be same
--ports must be same 
 component Or8 is
  Port (input1: in std_logic_vector(7 downto 0);
      output1: out std_logic);
end component;
--inputs
signal A: std_logic_vector(7 downto 0):=(others=> '0');
--signal input(1): std_logic:= '0';
--signal input(2): std_logic:= '0';
--signal input(3): std_logic:= '0';
--signal input(4): std_logic:= '0';
--signal input(5): std_logic:= '0';
--signal input(6): std_logic:= '0';
--signal input(7): std_logic:= '0';

---outputs
signal B : std_logic;


begin
test_name:Or8 PORT MAP(input1=> A, 
                        output1=>B);

stim_proc:process
begin

wait for 10ns;
A<="11000011";

wait for 10ns;
A<= "11110000";

end process;
end Behavioral;






