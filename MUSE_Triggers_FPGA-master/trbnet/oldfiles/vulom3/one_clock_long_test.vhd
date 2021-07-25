
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:54:36 03/13/2007
-- Design Name:   one_clock_long
-- Module Name:   /home/davide/fuffa/one_clock_long_test.vhd
-- Project Name:  fuffa
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: one_clock_long
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY one_clock_long_test_vhd IS
END one_clock_long_test_vhd;

ARCHITECTURE behavior OF one_clock_long_test_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT one_clock_long
	PORT(
		clk : IN std_logic;
		en_clk : IN std_logic;
		signal_in : IN std_logic;          
		pulse : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	SIGNAL clk :  std_logic := '0';
	SIGNAL en_clk :  std_logic := '0';
	SIGNAL signal_in :  std_logic := '0';

	--Outputs
	SIGNAL pulse :  std_logic;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: one_clock_long PORT MAP(
		clk => clk,
		en_clk => en_clk,
		signal_in => signal_in,
		pulse => pulse
	);

	tb : PROCESS
	BEGIN

		clk <= '1';
		wait for 1.42 ns;
		clk <= '0';
		wait for 1.42 ns;
	
	END PROCESS;
	
	stim : process
	begin
	   en_clk <= '1';
		signal_in <= '0';
		wait for 12.78 ns;
		signal_in <= '1';
		wait for 14.2 ns;
		signal_in <= '0';
		wait for 14.2 ns;
		signal_in <= '1';
		wait for 1.42 ns;
		signal_in <= '0';
		wait for 14.2 ns;
		signal_in <= '1';
		wait for 14.2 ns;
		signal_in <= '0';
		wait;
	end process;

END;