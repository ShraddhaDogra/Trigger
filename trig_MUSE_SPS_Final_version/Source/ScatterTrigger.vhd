-- This is the code for enabling different types of SPS triggers. This code stretches the input 
--and then parses it through different trigger modules. We can switch triggers based on different input values.
-- -------------------------------------------------------------------------------------------------------
-------------------//// Written by Shraddha Dogra.------------------------------------------------

library  ieee;
use  ieee.std_logic_1164.all;

library work;
use work.trb_net_std.all;

entity ScatterTrigger is
port(
        INP 				: in std_logic_vector(47 downto 0); --trigger input channels on 4ConnBoard;
		trig_sel       	 	: in std_logic_vector(3 downto 0);
		bar_enable_mask     : in std_logic_vector(47 downto 0); 
		clk					: in std_logic;
		OutpA				: out std_logic_vector(2 downto 0);
		OutpB				: out std_logic_vector(2 downto 0);
		OutpC				: out std_logic_vector(2 downto 0);
		LED_GREEN			: out std_logic;
		LED_ORANGE			: out std_logic;
		LED_RED				: out std_logic;
		LED_YELLOW			: out std_logic
	);
end ScatterTrigger;

architecture structural of ScatterTrigger is

signal outtemp: std_logic_vector (45 downto 0);
signal out_Scat_LUT5: std_logic;
signal out_Scat_LUT3: std_logic;
signal out_cos_or_all: std_logic;
signal out_cosmic_and6: std_logic;
signal in_trig_signal: std_logic;
signal trig_temp: std_logic;
signal temp_out_Pos_abs: std_logic;

signal in_front_delay : std_logic_vector(17 downto 0) := (others => '1');

--- Ievgen:
 signal INP_enabled: std_logic_vector (47 downto 0) := (others  => '0'); -- signal to store only signals from enabled SPS bars

 signal front_bars : std_logic_vector (17 downto 0) := (others => '0');
 signal back_bars  : std_logic_vector (27 downto 0) := (others => '0');
 
 signal  front_bars_40ns		:  std_logic_vector (17 downto 0) := (others => '0');
 signal  front_bars_40ns_d30ns	:  std_logic_vector (17 downto 0) := (others => '0');
 signal  back_bars_40ns			:  std_logic_vector (27 downto 0) := (others => '0');
 signal  back_bars_40ns_d30ns	:  std_logic_vector (27 downto 0) := (others => '0'); 
 signal  back_bars_100ns		:  std_logic_vector (27 downto 0) := (others => '0');
 

 component sps_control is	
  port(
		in_sig		 	: in std_logic_vector(47 downto 0); --trigger input channels on 4ConnBoard
		bar_enable_mask	: in std_logic_vector(47 downto 0); --mask of connected trigger channels (each bit correspods to the channel enable/disable)
		out_sig	 		: out std_logic_vector(47 downto 0)  -- trigger logic output
	  );
 end component sps_control;


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
   
   
 component Cos_or_all is
  port(
      in_clk: in std_logic;
	  in_front_bars: in std_logic_vector (17 downto 0);
	  in_back_bars: in std_logic_vector (27 downto 0);
	  out_cos_or_all: out std_logic);
 end component Cos_or_all;
	  

 component Cosmic_and6 is
  port(
     in_clk: in std_logic;
	 in_front_bars: in std_logic_vector (17 downto 0);  
	 in_back_bars: in std_logic_vector (27 downto 0);
	 out_cosmic_and6: out std_logic);
 end component Cosmic_and6;	 

 component Scat_LUT5 is
  port( 
     in_clk: in std_logic;
	 in_front_bars: in std_logic_vector (17 downto 0);
	 in_back_bars: in std_logic_vector (27 downto 0);
	 out_Scat_LUT5: out std_logic);
 end component Scat_LUT5;	   

 component Scat_LUT3 is
  port( 
     in_clk: in std_logic;
	 in_front_bars: in std_logic_vector (17 downto 0);
	 in_back_bars: in std_logic_vector (27 downto 0);
	 out_Scat_LUT3: out std_logic);
 end component Scat_LUT3;	
 
 
 component positron_absorption is
  port( 
	  in_clk		: in std_logic;
      in_front_bars	: in std_logic_vector (17 downto 0);
	  in_back_bars	: in std_logic_vector (27 downto 0);
	  Out_positron_absorption: out std_logic);    
 end component positron_absorption;

 component trig_selector is
  generic (N: integer :=4);
   port (in_trig_signal: in std_logic_vector (N-1 downto 0);
      out_trig_selector: out std_logic;
	  trig_select: in std_logic_vector (3 downto 0)
	  );	
 end component trig_selector;
 
 -- Delay each trigger intup by the value specified in trig_ch_delay:
 component signal_delay is
    generic (
			Width : integer;
			Delay : integer);
	port (
			clk_in   : in  std_logic;
			write_en_in : in std_logic;
			delay_in : in  std_logic_vector(Delay - 1 downto 0);
			sig_in   : in  std_logic_vector(Width - 1 downto 0);
			sig_out  : out std_logic_vector(Width - 1 downto 0)
	);
  end component signal_delay;
	
	
 ------------------------------------  CODE: ---------------------------------------------
 begin 
 
	-- Enable/Diable some bars that go to the trigger:
	spsControling: sps_control
                  port map( 
							in_sig =>	INP,
		                    bar_enable_mask => bar_enable_mask,
		                    out_sig => INP_enabled
				  ); 
	-- Assible Enabled bars to the front/back wall:
	front_bars	<= INP_enabled(17 downto 0);
	back_bars	<= INP_enabled(45 downto 18); 

	--- Generate trigger inputs of different width for further logic:
Front_40ns:
	PulseStretch generic map(
			STAGES	=> 4,
			WIDTH	=> 18
		)
		port map(
			sig_in	=> front_bars,
			clk		=> clk,		
			sig_out =>  front_bars_40ns
		);

Back_40ns:
	PulseStretch generic map(
			STAGES	=> 4,
			WIDTH	=> 28
		)
		port map(
			sig_in	=> back_bars,
			clk		=> clk,		
			sig_out =>  back_bars_40ns
		);

Back_100ns:
	PulseStretch generic map(
			STAGES	=> 10,
			WIDTH	=> 28
		)
		port map(
			sig_in	=> back_bars,
			clk		=> clk,		
			sig_out =>  back_bars_100ns
		);
	
	--- Delay front bar pulses and back bar 50ns by a 30ns:
DELAY_Front_40ns:	
	signal_delay generic map (
				Width => 18,
				Delay => 4)
			port map (
				clk_in       => clk,
				write_en_in  => '1',
				delay_in  	 => "0011", -- delay by 3 clock cycles = 30 ns
				sig_in 	  	 => front_bars_40ns,
				sig_out 	 => front_bars_40ns_d30ns
			);
		
DELAY_Back_40ns:	
	signal_delay generic map (
				Width => 28,
				Delay => 4)
			port map (
				clk_in       => clk,
				write_en_in  => '1',
				delay_in  	 => "0011", -- delay by 3 clock cycles = 30 ns
				sig_in 	  	 => back_bars_40ns,
				sig_out 	 => back_bars_40ns_d30ns
			);
		
							   
cosmicTrigg: Cos_or_all
             port map (
                   in_front_bars	=> front_bars_40ns_d30ns,
	               in_back_bars		=> back_bars_40ns_d30ns,
			       in_clk			=> clk,
				   out_cos_or_all	=> out_cos_or_all
			 );-- create temp variable and use it instead of OutpA
						
						
And6Trig:  Cosmic_and6
               port map(
                    in_clk => clk, 
	                in_front_bars => front_bars_40ns_d30ns,
	                in_back_bars =>  back_bars_40ns_d30ns,
	                out_cosmic_and6  => out_cosmic_and6 
				); 

ScatTrig: Scat_LUT5
               port map (
		           in_clk=> clk,
	               in_front_bars => front_bars_40ns_d30ns,
	               in_back_bars => back_bars_100ns,
	               out_Scat_LUT5 => out_Scat_LUT5
				);
				   
ScatTrig3: Scat_LUT3
				port map (
		           in_clk=> clk,
	               in_front_bars => front_bars_40ns_d30ns,
	               in_back_bars => back_bars_100ns,
	               out_Scat_LUT3 => out_Scat_LUT3
				);
				    
Positron_abs: positron_absorption
				port map( 
					in_clk		=> clk,
					in_front_bars => front_bars_40ns_d30ns,
					in_back_bars => back_bars_100ns,
					Out_positron_absorption => temp_out_Pos_abs
				);
			  
			  			  						
Out_Trigger_Selector: 
		trig_selector generic map (
						N=>4
				)
				port map(
						in_trig_signal(0)=> out_Scat_LUT5,
						in_trig_signal(1)=> out_cosmic_and6,
						in_trig_signal(2)=> out_cos_or_all,
						in_trig_signal(3) => out_Scat_LUT3, 
						out_trig_selector => trig_temp,
						trig_select => trig_sel
				);
						 
	OutpA(0) <= trig_temp;
	OutpA(1) <= temp_out_Pos_abs;
	OutpA(2) <= '0';
 
	OutpB(0) <= trig_temp;
	OutpB(1) <= temp_out_Pos_abs;
	OutpB(2) <= '0';
 
	OutpC(0) <= or_all(front_bars_40ns); 
	OutpC(1) <= or_all(front_bars_40ns_d30ns); 
	OutpC(2) <= or_all(back_bars_100ns); 
 
						 						
 
end structural;