-------------------------------------------------------------------------------
--Test bench for cyclic redundancy check computation
--We use the CRC5 polynomial f(x) = 1 + x^2 + x^ 5 used by the USB2.0 protocol
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CRCTest is
end entity CRCTest;

architecture simulation of CRCTest is
	
	component CRC
		port(
			clk     : in  std_logic;
			rst     : in  std_logic;
			enable  : in  std_logic;
			data_in : in  std_logic;
			crc_out : out std_logic_vector(4 downto 0)
		);
	end component CRC;
	
	signal clk : std_logic;
	signal rst : std_logic := '0';
	signal enable : std_logic := '0';
	signal data_in : std_logic := '0';
	signal crc_out : std_logic_vector(4 downto 0);
	
	constant clk_period : time :=  10 ns;
	constant message : std_logic_vector(10 downto 0) := "10100111010";
	
begin
	
	dut : entity work.CRC
		port map(
			clk     => clk,
			rst     => rst,
			enable  => enable,
			data_in => data_in,
			crc_out => crc_out
		);
	
	clk_gen : process is
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process clk_gen;
	
	stimulus : process is
	begin
		wait for 50 ns;
		for i in 10 downto 0 loop
			enable <= '1';
			data_in <= message(i);
			wait for clk_period;
		end loop;
		enable <= '0';
		assert crc_out = "11000" report "error during crc calculation" severity error;
		
		wait;
	end process stimulus;
	
	
end architecture simulation;
