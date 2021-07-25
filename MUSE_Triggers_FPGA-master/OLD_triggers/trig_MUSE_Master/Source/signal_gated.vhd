--Ievgen Lavrukhin: -------------------------------------------------------------
--Produces a gated output  ------------------------------------------------------
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity signal_gated is
	generic(
		GateWidth: integer:= 100
	);
	port(
		sig_in   : in  std_logic;
		clk_in   : in  std_logic;
		sig_out  : out std_logic
	);
end entity;

architecture arch of signal_gated is
	signal output_signal: std_logic:='0'; -- this signal carries a logica information about the output
	signal gate			: std_logic;
	
	-- This entity stretches the signal by a number of clock cycles:
	component signal_stretch is
		generic(
			Stretch : integer  -- number of clock cycles during which the signal will be stretched
		);
		port(
			sig_in   : in  std_logic; -- input signal should be longer that clock period;
			clk_in   : in  std_logic; -- 100 MHz clocks;
			sig_out  : out std_logic  -- stretched signal output;
		);
	end component signal_stretch;
begin
-------------------------------  Code: ---------------------------------------------------


----- Producing a gate of the fixed length: 
GATE_Proc: 
	signal_stretch generic map(
			Stretch => GateWidth  -- stretched pulse should be 1 us = 100 x 10 ns;
		)
		port map(
			sig_in   => output_signal, 
			clk_in   => clk_in, 
			sig_out  => gate
		);


--- Logic to produce a gated signal:
Latch_Logic: process(output_signal, sig_in, gate) 
	begin
		if (gate = '0') OR (gate = '1' AND output_signal = '1') then
			output_signal <= sig_in;
		else
			output_signal <= '0';
		end if;
	end process Latch_Logic;

--- Assigning output signal:
	sig_out <= output_signal;

end architecture;
