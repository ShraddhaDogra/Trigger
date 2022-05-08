-- //// This is a vhdl version of Ievgen's Cosmic TRiugger function.
--///// This function stretches and then ORs all of the inputs of the function.
--/////////////////// Shraddha Dogra///////////
--//////////////////  April 4, 2109////////////
-------------------------------------------------------------------------------------

library  ieee;
use  ieee.std_logic_1164.all;

library work;
use work.trb_net_std.all;

entity Cos_or_all is
	  port(
	  in_clk: in std_logic;
	  in_front_bars: in std_logic_vector (17 downto 0);
	  in_back_bars: in std_logic_vector (27 downto 0);
	  out_cos_or_all: out std_logic);
	  
end Cos_or_all;

architecture structural of Cos_or_all is

component OrAll is
port ( input2 : in std_logic_vector(17 downto 0); 
       input1 : in std_logic_vector(27 downto 0);
	output1 : out std_logic );
end component OrAll;


--component signal_stretch_48 is
    
  --port(
  --input : in std_logic_vector(47 downto 0);
 -- clk_in   : in  std_logic; -- 100 MHz clocks;
 -- output  : out std_logic_vector (47 downto 0)
	--  );
--end component signal_stretch_48;

begin
	 --stretching: signal_stretch_48                               
                  -- port map( 
                      --     input => data_in, 
			           --    clk_in =>input_clk,
			            --   output => outtemp);
--end generate GEN_STR;
   
ORing: OrAll 
   port map (input1=>  in_back_bars, 
            input2 => in_front_bars,
            output1=> out_cos_or_all);
   
--end process;
end structural;



