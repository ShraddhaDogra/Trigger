-------------------------------------------------------------
------------------- Ievgen Lavrukhin ------------------------
-- This is a test bench for  Master trigger logic for MUSE --
-------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY tb_couter_32bit IS
END tb_couter_32bit;

ARCHITECTURE behavior OF tb_couter_32bit IS

-- Component Declaration for the Unit Under Test (UUT)

component counter_32bit is
	port (input 		: in std_logic;
		  reset 		:in std_logic;	   
		  write_enable	: in std_logic;
		  count 		: out std_logic_vector(31 downto 0)  --output of the design. 4 bit count value.
	);
end component counter_32bit;

--Inputs
signal clk 				: std_logic := '0';
signal reset		    : std_logic := '0';
signal write_enable		: std_logic	:= '0';
--Outputs
signal count : std_logic_vector(31 downto 0);



BEGIN
-- Instantiate the Unit Under Test (UUT)
uut: counter_32bit port map (
						input   	 => clk,
						reset  		 => reset,  
						write_enable => write_enable,
						count  		 => count
					);
	  

-------------------- Stimulus process ----------------------------

stim_proc: process
begin

-- First 
wait for 100 ns;
reset   <= '1';
wait for 20 ns;
reset   <= '0';

write_enable <='0';
-- Geneateration input for TB:	 
for i in 0 to 50 loop	  
	wait for 30 ns;
	clk <= '1';		
	wait for 10 ns;
	clk <= '0';
end loop;		 

write_enable <='1';
for i in 0 to 100 loop	  
	wait for 30 ns;
	clk <= '1';		
	wait for 10 ns;
	clk <= '0';
end loop;

-- First 
wait for 100 ns;
reset   <= '1';
wait for 20 ns;
reset   <= '0';


write_enable <='0';
-- Geneateration input for TB:	 
for i in 0 to 50 loop	  
	wait for 10 ns;
	clk <= '1';		
	wait for 10 ns;
	clk <= '0';
end loop;		 

write_enable <='1';
for i in 51 to 100 loop	  
	wait for 10 ns;
	clk <= '1';		
	wait for 10 ns;
	clk <= '0';
end loop;

  



wait for 2000 ns;
wait;
end process;

END;