LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;



entity ddr_off is
	port(
      Clk: in  std_logic;
      Data: in  std_logic_vector(1 downto 0);
      Q: out  std_logic_vector(0 downto 0)
	);
end entity;



architecture ddr_off_arch of ddr_off is





begin


	ODDR_inst : ODDR
	generic map(
		DDR_CLK_EDGE => "OPPOSITE_EDGE", 	-- "OPPOSITE_EDGE" or "SAME_EDGE"
		INIT => '0',   						-- Initial value for Q port ('1' or '0')
		SRTYPE => "SYNC") 					-- Reset Type ("ASYNC" or "SYNC")
	port map (
		Q => Q(0),   							-- 1-bit DDR output
		C => Clk,    						-- 1-bit clock input
		CE => '1',  						-- 1-bit clock enable input
		D1 => Data(0),  					-- 1-bit data input (positive edge)
		D2 => Data(1),  					-- 1-bit data input (negative edge)
		R => '0',    						-- 1-bit reset input
		S => '0'     						-- 1-bit set input
	);



end architecture;