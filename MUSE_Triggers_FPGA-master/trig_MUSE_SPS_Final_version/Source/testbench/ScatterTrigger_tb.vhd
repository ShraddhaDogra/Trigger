library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use std.env.stop;

entity ScatterTrigger_tb is 
end ScatterTrigger_tb;

architecture Behavioral of ScatterTrigger_tb is  

component ScatterTrigger is
port(
	 INP 				: in std_logic_vector(47 downto 0); --trigger input channels on 4ConnBoard;
	 trig_sel        	: in std_logic_vector(3 downto 0); 
	 bar_enable_mask    : in std_logic_vector(47 downto 0);
	 clk				: in std_logic;
	 OutpA				: out std_logic_vector(2 downto 0);
	 OutpB				: out std_logic_vector(2 downto 0);
	 OutpC				: out std_logic_vector(2 downto 0);
	 LED_GREEN			: out std_logic;
	 LED_ORANGE			: out std_logic;
	 LED_RED			: out std_logic;
	 LED_YELLOW			: out std_logic
	 );
end component ScatterTrigger;

signal tb_input				 : std_logic_vector(47 downto 0):= (others=> '0');
signal tb_str_val			 : std_logic_vector(3 downto 0) := (others=> '0');
signal tb_trig_sel			 : std_logic_vector(3 downto 0) := (others=> '0'); 
signal tb_bar_enable_mask    : std_logic_vector(47 downto 0):= (others=> '1');
signal tb_clk				 : std_logic :='0';
signal tb_OutpA				 : std_logic_vector(2 downto 0);
signal tb_OutpB				 : std_logic_vector(2 downto 0);
signal tb_OutpC				 : std_logic_vector(2 downto 0);
signal tb_LED_GREEN			 : std_logic;
signal tb_LED_ORANGE		 : std_logic;
signal tb_LED_YELLOW		 : std_logic;

begin

test: ScatterTrigger PORT MAP(
					INP 			   => tb_input, 
					trig_sel 		   => tb_trig_sel,
					bar_enable_mask    => tb_bar_enable_mask,
					clk			 	   => tb_clk,
					OutpA 			   => tb_OutpA,
					OutpB			   => tb_OutpB,
					OutpC 			   => tb_OutpC,
					LED_GREEN 		   => tb_LED_GREEN,
					LED_ORANGE 		   => tb_LED_ORANGE,
					LED_YELLOW 		   => tb_LED_YELLOW
					);
					   
tb_clk <= not tb_clk after 5ns;

stim_proc:process
begin


tb_trig_sel <= "0001";
wait for 10 ns;

first_loop:
for i in 0 to 23 loop 	
	wait for 10 ns; 
	tb_input(i) <= '1';--(others => '1');
end loop first_loop;  	  

for i in 0 to 47 loop
	wait for i*1 ns; 
	tb_input(i) <= '0';--(others => '1');	 
end loop;

wait for 100 ns;



end process;

end Behavioral;
