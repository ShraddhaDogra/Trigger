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

ENTITY tb_prescaler_pow2 IS
END tb_prescaler_pow2;

ARCHITECTURE behavior OF tb_prescaler_pow2 IS

-- Component Declaration for the Unit Under Test (UUT)

component prescaler_pow2 is
    port (
      input              : in  std_logic;
	  clk_in			 : in std_logic;
	  prescale_power	 : in  std_logic_vector (3 downto 0);
	  reset 			 : in std_logic;
      output  			 : out std_logic
	);
end component prescaler_pow2;

--Inputs
signal reset 				: std_logic := '0';
signal input			    : std_logic := '0';
signal clk_in			    : std_logic := '0';
signal prescale_power 	    : std_logic_vector(3 downto 0) :=(others => '0');
--Outputs
signal output : std_logic;



BEGIN
-- Instantiate the Unit Under Test (UUT)
uut: prescaler_pow2 port map (
						input   => input,
						clk_in	=>  clk_in,
						prescale_power  => prescale_power,
						reset   => reset,
						output  => output
					);
	  
clk_in <= not clk_in after 5ns;
-------------------- Stimulus process ----------------------------

stim_proc: process
begin

-- First 
wait for 100 ns;
reset   <= '1';
wait for 20 ns;
reset   <= '0';
prescale_power <= "0000";

-- Geneateration input for TB:	 
for i in 0 to 20 loop
	wait for 100 ns;
	input <= '1';		
	wait for i*1 ns;
	input <= '0';
end loop;


wait for 100 ns;
reset   <= '1';
wait for 20 ns;
reset   <= '0';
prescale_power <= "0001";

-- Geneateration input for TB:	 
for i in 0 to 20 loop
	wait for 100 ns;
	input <= '1';		
	wait for i*1 ns;
	input <= '0';
end loop;


wait for 100 ns;
reset   <= '1';
wait for 20 ns;
reset   <= '0';
prescale_power <= "0010";

-- Geneateration input for TB:	 
for i in 0 to 20 loop
	wait for 100 ns;
	input <= '1';		
	wait for i*1 ns;
	input <= '0';
end loop;

wait for 100 ns;
reset   <= '1';
wait for 20 ns;
reset   <= '0';
prescale_power <= "0011";

-- Geneateration input for TB:	 
for i in 0 to 20 loop
	wait for 100 ns;
	input <= '1';		
	wait for i*1 ns;
	input <= '0';
end loop;

wait for 2000 ns;
wait;
end process;

END;