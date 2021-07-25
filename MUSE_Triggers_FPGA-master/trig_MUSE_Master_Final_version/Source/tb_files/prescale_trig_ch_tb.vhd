-------------------------------------------------------------
------------------- Ievgen Lavrukhin ------------------------
-- This is a test bench for  Trigger Prescaller logic for MUSE --
-------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.basic_type_declaration.all;



ENTITY tb_prescale_trig_ch IS
END tb_prescale_trig_ch;

ARCHITECTURE behavior OF tb_prescale_trig_ch IS

-- Component Declaration for the Unit Under Test (UUT)

component prescale_trig_ch is
  generic(
    NUMBER : integer := 10  -- number of input channels 
    );
  port(
    sig_in  	  : in  std_logic_vector(NUMBER-1 downto 0); -- input channels from the trigger ;
	clk_in		  : in std_logic;
    prescale_ch   : in  array4(0 to NUMBER-1); -- prescale power for each channel;
	reset		  : in  std_logic; -- reset option;
    sig_out 	  : out std_logic_vector(NUMBER-1 downto 0)  -- output channels after prescaler;
	);
end component;


--Inputs
signal reset		: std_logic := '0';
signal clk_in		: std_logic := '0';
signal sig_in		: std_logic_vector(9 downto 0) :=(others => '0');
signal prescale_ch	: array4(0 to 9):=(others => (others => '0'));
--Outputs
signal sig_out		: std_logic_vector(9 downto 0);



BEGIN
-- Instantiate the Unit Under Test (UUT)
uut: prescale_trig_ch generic map(
							NUMBER => 10
					  )
					  port map (
							sig_in    => sig_in,
							clk_in	  => clk_in,
							prescale_ch   =>  prescale_ch,
							reset   => reset,
							sig_out  =>  sig_out
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

for i in 0 to 9 loop
	prescale_ch(i) <= std_logic_vector(to_unsigned(i, 4));
end loop;


for j in 0 to 300 loop
	wait for 30 ns;
	sig_in <= "1111111111";		
	wait for 10 ns;
	sig_in <= "0000000000";
end loop;

wait for 2000 ns;
wait;
end process;

END;




