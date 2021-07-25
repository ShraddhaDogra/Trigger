----------------------------------------------------------------------------
-- Synchronize input to signal to input clock domain
-- Tobias Weber
-- Ruhr Unversitaet Bochum
-----------------------------------------------------------------------------
 library ieee;
 use ieee.std_logic_1164.all;
 use ieee.numeric_std.all;
 
 entity InputSynchronizer is
 	generic(depth : integer := 2);
 	port(
 		clk : in std_logic; --input clock
 		rst : in std_logic; --reset
 		input : in std_logic; --asynchronous input signal
 		sync_output : out std_logic --synchronized signal
 	);
 end entity InputSynchronizer;
 
architecture RTL of InputSynchronizer is
	
	signal syncstage : std_logic_vector(depth - 1 downto 0) := (others => '0');
	
begin
	
	sync_process : process (clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				syncstage <= (others => '0');
			else
				syncstage <= syncstage(depth - 2 downto 0) & input;
			end if;
		end if;
	end process sync_process;
	
	sync_output <= syncstage(depth - 1);
	
end architecture RTL;
