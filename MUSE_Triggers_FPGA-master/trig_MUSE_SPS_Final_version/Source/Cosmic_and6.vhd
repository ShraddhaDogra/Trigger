
--  //// This is SPS trigger code for signal in any 6 adjacent bars.////
---- //// Written by Shraddha and Win.///////////////
library  ieee;
use  ieee.std_logic_1164.all;

library work;
use work.trb_net_std.all;

entity Cosmic_and6 is
port(
      in_clk: in std_logic;
	  in_front_bars: in std_logic_vector (17 downto 0);
	  in_back_bars: in std_logic_vector (27 downto 0);
	  out_cosmic_and6: out std_logic);
end Cosmic_and6;

architecture structural of Cosmic_and6 is
--signal outtemp: std_logic_vector (47 downto 0);
--signal oralltemp: std_logic;

 --component signal_stretch_48 is
 --   port(
 -- input : in std_logic_vector(47 downto 0);
 -- clk_in   : in  std_logic; -- 100 MHz clocks;
 -- output  : out std_logic_vector (47 downto 0));
 --end component signal_stretch_48;

 
 component PlaneOr is
    port ( 
		front_input : in std_logic_vector( 17 downto 0);
		back_input : in std_logic_vector ( 27 downto 0);
		or_output : out std_logic );
 end component PlaneOr;
 
 begin
	--stretching: signal_stretch_48                               
             --    port map( 
              --            input =>INP, 
			  --            clk_in =>CLK_PCLK_RIGHT,
			   --           output => outtemp);
--end generate GEN_STR;
   
 GEN_sig: PlaneOr
            port map(
			        front_input=> in_front_bars, 
			        back_input => in_back_bars,
                    or_output => out_cosmic_and6);
			
--end process;
end structural;



