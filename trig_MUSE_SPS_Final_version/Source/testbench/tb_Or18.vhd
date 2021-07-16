library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity tb_Or18 is
--  Port ( );
end tb_Or18;

architecture Behavioral of tb_Or18 is
--Component name and entity's name must be same
--ports must be same 
 component Or18 is
  Port (input1: in std_logic_vector(17 downto 0);
      output1: out std_logic);
end component;
--inputs
signal A: std_logic_vector(17 downto 0):=(others=> '0');
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
test_name:Or18 PORT MAP(input1=> A, 
                        output1=>B);

stim_proc:process
begin

wait for 20ns;
A<="000000000000000001";

wait for 20ns;
A<="000000000000000010";

wait for 20ns;
A<="000000000000000110";

wait for 20ns;
A<= (others=> '0');

wait for 40ns;
A<= "000000000000001000";

wait for 20ns;
A<="000000000000000110";

wait for 20ns;
A<="000000000000001110";

wait for 20ns;
A<= (others=> '0');
wait for 30ns;

A<= "000000000000000001"; 
--- below is how to generate time shifted waveforms corresponding to the previous waveform.
wait for 10ns;
A<= "000000000000000011";

wait for 10ns;
A<= "000000000000000010";

wait for 10ns;
A<= (others=> '0');

wait for 20ns;
A<="000000000000001100";


wait for 5ns;
A<="000000000000011100";


wait for 20ns;
A<="000000000000111100";


wait for 20ns;
A<="000000000001101100";

wait for 40ns;
A<="000000000011101100";

wait for 40ns;
A<="000000000111001100";




end process;
end Behavioral;






