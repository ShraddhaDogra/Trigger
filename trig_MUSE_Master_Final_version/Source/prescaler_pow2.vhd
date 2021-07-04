library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use Ieee.std_logic_UNSIGNED.all;

library work;
use work.trb_net_std.all;

entity prescaler_pow2 is
port(
	input        	 : in  std_logic;
	clk_in			 : in  std_logic;
	prescale_power	 : in  std_logic_vector (3 downto 0); -- this is a power of prescale 2^0 to 2^15
	reset         	 : in  std_logic;
	output       	 : out std_logic
	);
end prescaler_pow2;


architecture prescaler_pow2_arch of prescaler_pow2 is
	signal divider		: unsigned(14 downto 0):= (others=>'0');
	signal temp 	 	: std_logic_vector(15 downto 0);
	signal prescale_out	: std_logic_vector(15 downto 0);
	signal max_power	: integer range 0 to 15;
	
	--Ievgen:  this is a new function that replaces "signal_stretch_48" module
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
 
begin
	
	p_divider: process(reset,input)
	begin
		if(reset='1') then
			divider   <= (others=>'0');
		elsif(rising_edge(input)) then
			divider   <= divider + 1;
		end if;
	end process p_divider;

	max_power	<= to_integer(unsigned(prescale_power));
	temp(0)				<= input;
	temp (15 downto 1)	<= std_logic_vector(divider(14 downto 0));

Stretched_50ns:
	PulseStretch generic map(
			STAGES	=> 5,
			WIDTH	=> 16
		)
		port map(
			sig_in	=> temp,
			clk		=> clk_in,		
			sig_out =>  prescale_out
		);


	output <= prescale_out(max_power);
	
--output <= input when prescale_power = "0000" else
--		  and_all(std_logic_vector(divider(to_integer(unsigned(prescale_power)) -1 downto 0))) and input;
															 
															 
end  prescaler_pow2_arch;