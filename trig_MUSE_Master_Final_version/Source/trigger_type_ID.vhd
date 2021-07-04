-------------------------------------------------------------------------------------
----------- Ievgen Lavrukhin --------------------------------------------------------
-- This is a logic to form a trigger_type ID word for further trigger decoding ------
-------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use Ieee.std_logic_UNSIGNED.all;

library work;
use work.trb_net_std.all;
use work.basic_type_declaration.all;

entity trigger_type_ID is
	generic(
		INP_NUMBER : integer := 16 -- number of input trigger gate cahnnels 
	);
	port (
		trig_logic_inputs	: in std_logic_vector (INP_NUMBER -1 downto 0);
		trig_final			: in std_logic; 
		clk_in				: in std_logic;
		trig_type_word		: out std_logic_vector (31 downto 0)
	);
end trigger_type_ID;

architecture  arch of trigger_type_ID is
------ Signals:
signal trig_logic_inputs_del	: std_logic_vector (INP_NUMBER -1 downto 0):= (others => '0');
signal trig_final_str			:  std_logic := '0'; 
signal temp_type				: std_logic_vector (INP_NUMBER -1 downto 0) := (others => '0');

------ Components definition:

	component signal_delay is  
		generic (
			Width : integer;
			Delay : integer
		);
		port (
			clk_in		: in  std_logic;
			write_en_in	: in std_logic;
			delay_in	: in  std_logic_vector(Delay - 1 downto 0);
			sig_in   	: in  std_logic_vector(Width - 1 downto 0);
			sig_out  	: out std_logic_vector(Width - 1 downto 0)
		);
	end component signal_delay;

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
 


--------------------------------------- CODE -------------------------------------------
begin


----- delay all "trig_logic_inputs" by 20 ns to make sure that they arrive after master trigger output:
INP_DELAY:	signal_delay
				generic map (
					Width => INP_NUMBER,
					Delay => 4 
				)
				port map (
					clk_in   	=> clk_in,
					write_en_in => '1', 
					delay_in	=> x"2", -- 2 clock cycles 
					sig_in   =>  trig_logic_inputs,
					sig_out  =>  trig_logic_inputs_del
				);

----- Stretch master trigger dicision input to 60 ns;
Trig_FINAL_Stretch_60ns:
	PulseStretch generic map(
			STAGES	=> 6,
			WIDTH	=> 1
		)
		port map(
			sig_in(0)	=> trig_final,
			clk			=> clk_in,		
			sig_out(0)	=>  trig_final_str
		);

----- Construct the trigget type ID word:
trig_type_word(31 downto 28) <= "1010";
trig_type_word(27 downto INP_NUMBER) <= (others => '0');
--trig_type_word(INP_NUMBER -1 downto 0) <= (others => '1');

TRIG_TYPE_PROCESS: process(trig_final_str, trig_logic_inputs_del) is
begin
	if trig_final_str = '1' then  
		for i in 0 to INP_NUMBER -1 loop
			if trig_logic_inputs_del(i) = '1' then
				temp_type(i) <= '1';
			end if;   
		end loop;
		trig_type_word(INP_NUMBER -1 downto 0) <= temp_type;
	else
		temp_type <= (others => '0');
	end if;
	
end process TRIG_TYPE_PROCESS;


end arch;
