--- This code is ANDing adjacent SPS bar outputs and Oring them together.
-- Thsi code is written by Win Lin, 4/5/2019.


library  ieee;
use  ieee.std_logic_1164.all;

library work;
use work.trb_net_std.all;

-- comment for vhdl

entity PlaneOr is 
	port ( 
		front_input : in std_logic_vector( 17 downto 0);
		back_input : in std_logic_vector ( 27 downto 0);
		or_output : out std_logic );
end PlaneOr;

architecture apply_plane_or of PlaneOr is
	signal front_and_out : std_logic_vector(12 downto 0);
	signal back_and_out : std_logic_vector(22 downto 0);
	signal or_temp : std_logic_vector(9 downto 0);
	
	component And6 is 
		port (
			input : in std_logic_vector(5 downto 0);
			output : out std_logic );
	end component And6;
	
begin
	
	and_front:
		for i in 0 to 12 generate
			andfront_loop: And6 port map (
				input => front_input((i+5) downto i),
				output => front_and_out(i));
	end generate and_front;
	
	and_back:
			for j in 0 to 22 generate
			andback_loop: And6 port map (
				input => back_input((j+5) downto j),
				output => back_and_out(j));
	end generate and_back;
	
	or_temp(0) <= front_and_out(0) OR front_and_out(1) OR front_and_out(2) OR front_and_out(3);
	or_temp(1) <= front_and_out(4) OR front_and_out(5) OR front_and_out(6) OR front_and_out(7);
	or_temp(2) <= front_and_out(8) OR front_and_out(9) OR front_and_out(10) OR front_and_out(11) OR front_and_out(12);
	
	or_temp(3) <= back_and_out(0) OR back_and_out(1) OR back_and_out(2) OR back_and_out(3) OR back_and_out(4);
	or_temp(4) <= back_and_out(5) OR back_and_out(6) OR back_and_out(7) OR back_and_out(8) OR back_and_out(9);
	or_temp(5) <= back_and_out(10) OR back_and_out(11) OR back_and_out(12) OR back_and_out(13) OR back_and_out(14);
	or_temp(6) <= back_and_out(15) OR back_and_out(16) OR back_and_out(17) OR back_and_out(18) OR back_and_out(19);
	or_temp(7) <= back_and_out(20) OR back_and_out(21) OR back_and_out(22);
	
	or_temp(8) <= or_temp(0) OR or_temp(1) OR or_temp(2);
	or_temp(9) <= or_temp(3) OR or_temp(4) OR or_temp(5) OR or_temp(6) OR or_temp(7);
	
	or_output <= or_temp(8) OR or_temp(9);
	
end apply_plane_or;
