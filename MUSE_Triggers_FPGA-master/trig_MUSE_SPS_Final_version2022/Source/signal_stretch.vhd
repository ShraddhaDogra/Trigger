--Ievgen Lavrukhin: -------------------------------------------------------------
--Stretch Signal for  number of clock cycles  -----------------------------------
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

library work;
use work.trb_net_std.all;


entity signal_stretch is
  generic(
    Stretch : integer := 1  -- number of clock cycles during which the signal will be stretched
    );
  port(
  sig_in   : in  std_logic;
    --sig_in   : in  std_logic_vector (47 downto 0); -- input signal should be longer that clock period;
    clk_in   : in  std_logic; -- 100 MHz clocks;
	sig_out  : out std_logic
   -- sig_out  : out std_logic_vector (47 downto 0)  -- stretched signal output;
	);
end signal_stretch;

architecture arch of signal_stretch is

  signal latch_stretched	: std_logic_vector(Stretch - 1 downto 0) := (others => '0');
  
begin
  StretchProc : process(clk_in) begin
    if (rising_edge(clk_in)) then
    	latch_stretched(0) <= sig_in;
    	latch_stretched(Stretch - 1 downto 1) <= latch_stretched(Stretch - 2 downto 0); 
    end if;
  end process StretchProc;

  sig_out <= or_all(latch_stretched) OR sig_in;

end architecture; 
