library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity tb_Orall is
--  Port ( );
end tb_Orall;

architecture Behavioral of tb_Orall is
--Component name and entity's name must be same
--ports must be same 
 component OrAll is
  Port (input1: in std_logic_vector(47 downto 0);
      output1: out std_logic);
end component;
--inputs
signal A: std_logic_vector(47 downto 0):=(others=> '0');
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
test_name:OrAll PORT MAP(input1=> A, 
                         output1=>B);

stim_proc:process
begin

wait for 20ns; 

A(0) <='1';
wait for 10ns;

A(0)<= '0';
wait for 10ns;

A(2)<= '1';
wait for 12ns;

A(2)<= '0';
wait for 50ns;

A(43)<= '1';
wait for 10 ns;

A(43)<= '0';
wait for 50ns;

A(0)<= '1';
wait for 15 ns;

A(5)<= '1';
wait for 20ns;

A(0)<= '0';
wait for 200 ns;

A(5)<='0';
wait for 200ns;

end process;
end Behavioral;






