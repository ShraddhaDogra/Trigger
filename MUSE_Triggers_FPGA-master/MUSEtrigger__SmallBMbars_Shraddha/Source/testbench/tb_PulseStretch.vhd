library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use std.env.stop;

entity tb_PulseStretch is 
end tb_PulseStretch;

architecture Behavioral of tb_PulseStretch is  


component PulseStretch is 
 generic(
	STAGES	: integer;
    WIDTH	: integer
 );
 port (
    sig_in	: in std_logic_vector(WIDTH -1 downto 0);
    clk		: in std_logic;		
    sig_out : out std_logic_vector(WIDTH -1 downto 0)
    );
end component PulseStretch;

signal clk_tb		: std_logic := '0';
signal sig_in_tb	: std_logic_vector(0 downto 0) := (others => '0');
signal sig_out_tb 	:  std_logic_vector(0 downto 0);

begin

test: PulseStretch
	generic map(
		STAGES	=> 10,
		WIDTH	=> 1
	)
	port map(
		sig_in	=> sig_in_tb,
		clk		=> clk_tb,		
		sig_out => sig_out_tb
	);



				
clk_tb <= not clk_tb after 5ns;

stim_proc:process
begin

wait for 7 ns;
for i in 0 to 20  loop 
	wait for 300 ns;
	sig_in_tb <= (others => '1');
	wait for i*4 ns;
	sig_in_tb <= (others => '0');
end loop;



end process;

end Behavioral;