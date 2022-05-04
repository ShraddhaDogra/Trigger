-- This is 48 bit implementaion of 1-bit signal stretch function written by Ievgen.
-- ////////////////////// Written by Shraddha Dogra.//////////



library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

library work;
use work.trb_net_std.all;


entity signal_stretch_48 is
 --generic(
    --Width : integer := 1;
 ----   Stretch : integer := 5  
 --   );
  port(
  input : in std_logic_vector(45 downto 0);
  clk_in   : in  std_logic; -- 100 MHz clocks;
  output : out std_logic_vector(45 downto 0);
  front_str_30  : out std_logic_vector (17 downto 0);
  front_str_50  : out std_logic_vector (17 downto 0);
  back_str_50  : out std_logic_vector (27 downto 0);
  back_str_100  : out std_logic_vector (27 downto 0)
  );
end signal_stretch_48;

architecture arch of signal_stretch_48 is

signal out_front_str_30: std_logic_vector (17 downto 0);
signal out_front_str_50: std_logic_vector(17 downto 0);
signal out_back_str_50: std_logic_vector (27 downto 0);
signal out_back_str_100: std_logic_vector (27 downto 0);


signal out_temp_back: std_logic_vector (27 downto 0);
component signal_stretch is
  generic(
    Stretch : integer := 1  -- number of clock cycles during which the signal will be stretched
    );
  port(
    sig_in   : in  std_logic; -- input signal should be longer that clock period;
    clk_in   : in  std_logic; -- 100 MHz clocks;
    sig_out  : out std_logic  -- stretched signal output;
	);
end component signal_stretch;

begin
-- this is structure of the for loop as in Ievgen's code.
GEN_STR_1: 
       for i in 0 to 17 generate
	   stretching: signal_stretch generic map(
                                  Stretch => 3) -- number of clock cycles during which the signal will be stretched
                   port map( 
                           sig_in=>input(i), 
			               clk_in=>clk_in,
			               sig_out=> out_front_str_30(i));
end generate GEN_STR_1;


GEN_STR_2: 
       for i in 0 to 17 generate
	   stretching: signal_stretch generic map(
                                  Stretch => 5) -- number of clock cycles during which the signal will be stretched
                   port map( 
                           sig_in=>input(i), 
			               clk_in=>clk_in,
			               sig_out=> out_front_str_50(i));
end generate GEN_STR_2;

GEN_STR_3: 
       for i in 0 to 27 generate
	   stretching: signal_stretch generic map(
                                  Stretch => 5) -- number of clock cycles during which the signal will be stretched
                   port map( 
                           sig_in=>input(i+16), 
			               clk_in=>clk_in,
			               sig_out=> out_back_str_50(i));
end generate GEN_STR_3;


GEN_STR_4: 
       for i in 0 to 27 generate
	   stretching: signal_stretch generic map(
                                  Stretch => 10) -- number of clock cycles during which the signal will be stretched
                   port map( 
                           sig_in=>input(i+16), 
			               clk_in=>clk_in,
			               sig_out=> out_back_str_100(i));
end generate GEN_STR_4;

  front_str_30  <= out_front_str_30;
  front_str_50  <= out_front_str_50;
  back_str_50  <= out_back_str_50;
  back_str_100  <= out_back_str_100;
end architecture;
