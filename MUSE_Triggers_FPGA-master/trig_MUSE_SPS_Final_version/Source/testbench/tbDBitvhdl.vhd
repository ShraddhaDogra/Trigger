library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity tbDBitvhdl is  -- Name of tb entity
--  Port ( );
end tbDBitvhdl;

architecture archDB of tbDBitvhdl is  -- architechture name of tb entity.
--Component name and original_entity's name must be the same
--ports must be same 
 component DelayBit_vhdl is
  Port (DlyIn: in std_logic;    
        reTrig : in std_logic;	
        DlyOut : out std_logic;
        clk   : in std_logic);
end component;

--inputs and outputs for itb_module the names are different from module I/p and O/p.
--signal tb_res: std_logic_vector(7 downto 0):=(others=> '0');

signal tb_clk: std_logic:='0';
signal tb_reTrig: std_logic:='0';
signal tb_In: std_logic:='0';
signal tb_Out: std_logic:='0';

--signal input(1): std_logic:= '0';
--signal input(2): std_logic:= '0';
--signal input(3): std_logic:= '0';
--signal input(4): std_logic:= '0';
--signal input(5): std_logic:= '0';
--signal input(6): std_logic:= '0';
--signal input(7): std_logic:= '0';


begin
-- we assign actual module I/p O/P to  tb_module I/P, O/P.
test_name:DelayBit_vhdl PORT MAP(clk => tb_clk, DlyIn => tb_In, reTrig =>tb_reTrig,
                       DlyOut=>tb_Out);

stim_proc:process
begin

wait for 5ns;
tb_clk<= not tb_clk after 5ns;
tb_reTrig <='1';
tb_In <='1';


wait for 5ns;

tb_clk<= not tb_clk after 5ns;

--tb_clk <='0';  --wait for 5ns; 
tb_reTrig <='0';
tb_In <='1';




wait for 5ns;

tb_clk<= not tb_clk after 5ns;

--tb_clk <='1'; --wait for 5ns;
tb_reTrig <='1';
tb_In <='0';


wait for 5ns;

tb_clk<= not tb_clk after 5ns;
--tb_clk <='0';
tb_reTrig <='1';
tb_In <='1';

end process;
end archDB;