-- //// This is a vhdl Veto_BM Trigger function.
--/////
--/////////////////// Shraddha Dogra///////////
--//////////////////  ////////////
-------------------------------------------------------------------------------------

library  ieee;
use  ieee.std_logic_1164.all;

library work;
use work.trb_net_std.all;

entity Veto_BM is
	  port( 
	  INP 			    : in std_logic_vector(47 downto 0); -- using first 16  for (16 small bars up and down).
	  bar_enable_mask   : in std_logic_vector (15 downto 0);
	  CLK_PCLK_RIGHT	: in std_logic;
	  OutpA				: out std_logic_vector(2 downto 0);
	  OutpB				: out std_logic_vector(2 downto 0);
	  OutpC				: out std_logic_vector(2 downto 0)
	      )  ; 
end Veto_BM;

architecture structural of Veto_BM is

 signal BM_temp_out: std_logic_vector (3 downto 0):= (others => '0');
 
 signal Bar_enabled: std_logic_vector(15 downto 0):= (others => '0');
 --signal BM_enabled2: std_logic_vector(7 downto 0):= (others => '0');
 
  signal BM_enabled: std_logic_vector(7 downto 0):= (others => '0');
  signal Veto_enabled: std_logic_vector(7 downto 0):= (others => '0');
 
 signal V_out_str_40ns: std_logic_vector(7 downto 0) := (others => '0'); 
 signal B_out_str_40ns: std_logic_vector (7 downto 0) := (others => '0');

 signal veto_temp_out: std_logic_vector(3 downto 0);
 signal Veto_out_temp_OrAll: std_logic;

 --signal SmallBars_out_OrAll: std_logic;
 --signal SmallBars_temp_Trig: std_logic;
 
 signal BM_out_temp_OrAll: std_logic;
 
 signal BM_ored: std_logic;
 signal Veto_ored: std_logic;
 signal Veto_not: std_logic;
 signal B_out_str_60ns: std_logic;
 signal V_out_str_60ns: std_logic;
 signal BM_Trig_stretched40: std_logic;
 signal Veto_notstretched50: std_logic;

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
 

 
 
 component Veto_OrAll is
	  port(
	  in_clk: in std_logic;
	  in_veto: in std_logic_vector (7 downto 0);
	  out_veto: out std_logic
	        );
end component Veto_OrAll;

component BM_OrAll is
	  port(
	  in_clk: in std_logic;
	  in_BM: in std_logic_vector (7 downto 0);
	  out_BM: out std_logic
	        );
end component BM_OrAll;
 
 
 
 component signal_stretch is
  generic(
    Stretch : integer := 1  -- number of clock cycles during which the signal will be stretched
    );
  port(
  sig_in   : in  std_logic;
    --sig_in   : in  std_logic_vector (47 downto 0); -- input signal should be longer that clock period;
    clk_in   : in  std_logic; -- 100 MHz clocks;
	sig_out  : out std_logic
	);
end component signal_stretch;
 
  component Veto_Logic is
  port(
	   in_clk: in std_logic;
	   in_veto: in std_logic_vector (7 downto 0);
	   out_veto: out std_logic_vector (3 downto 0)
	   );
 end component Veto_Logic;
 
 
 component BM_Trig_Logic is
  port(
      in_clk: in std_logic;
	  in_BM: in std_logic_vector (7 downto 0);
	  out_BM: out std_logic_vector(3 downto 0)
	    );
 end component BM_Trig_Logic;
 
 
 component BM_control is	
	port (
		in_sig		 	: in std_logic_vector(15 downto 0);
		bar_enable_mask	: in std_logic_vector(15 downto 0); 
		out_sig 		: out std_logic_vector(15 downto 0)
	);
end component BM_control;



component signalDelay is
  generic(
    Width : integer := 1;
    Delay : integer := 5  -- 2**Delay-1
    );
  port(
    clk_in   : in  std_logic;
    write_en_in : in  std_logic;
    delay_in : in  std_logic_vector(Delay - 1 downto 0);
    sig_in   : in  std_logic_vector(Width - 1 downto 0);
    sig_out  : out std_logic_vector(Width - 1 downto 0));
end component signalDelay;


----------------------------------------- CODE ----------------------------------------

 begin
  --- BM inputs are 15:8. Veto inputs are 7:0.
 --- enable the big BM bars----
  BMControling1: BM_control
                  port map( 
							in_sig => INP(15 downto 0),
		                    bar_enable_mask => bar_enable_mask,
		                    out_sig => Bar_enabled			  ); 	
							
							
							BM_enabled <= Bar_enabled(15 downto 8);
							Veto_enabled <= Bar_enabled(7 downto 0);
							
							
				  	
 -- Keeping the stretching of BM signa for reference. It will probbaly be deleted later.
 --Str_40ns:PulseStretch generic map(
	--		STAGES	=> 2, -- stages= 1 gives ~8 ns wide O/p signal 
	    --    WIDTH	=> 8
		--)
		--port map(
			--sig_in	=> BM_enabled1,
			--clk		=> CLK_PCLK_RIGHT,		
			--sig_out => B_out_str_40ns
		--);
		

	-------------------------------- Trigger Logic: OR of ANDs----------------------------	
		
 Veto_trig: Veto_Logic
                  port map( in_clk => CLK_PCLK_RIGHT,
							in_veto => Veto_enabled,
		                    out_veto => veto_temp_out);
							
						
  BM_trig: BM_Trig_Logic
	               port map(in_clk => CLK_PCLK_RIGHT,
				            in_BM => BM_enabled,
		                    out_BM => BM_temp_out);
							
						

  BM_ored <= BM_temp_out(0) or BM_temp_out(1) or BM_temp_out(2) or BM_temp_out(3);

  Veto_ored <= veto_temp_out(0) or veto_temp_out(1) or veto_temp_out(2) or veto_temp_out(3); 
  Veto_not <= not(Veto_ored);
  
  							
  Stretch_BM_out:
    signal_stretch  generic map(
     Stretch => 4  -- number of clock cycles during which the signal will be stretched
            )
      port map(
      sig_in   =>BM_ored,
      clk_in   => CLK_PCLK_RIGHT, -- 100 MHz clocks;
	  sig_out  =>BM_Trig_stretched40);
	

  							
  Stretch_VetoNot_out: signal_stretch  generic map(
     Stretch  => 5  -- number of clock cycles during which the signal will be stretched
            )
      port map(
      sig_in   =>Veto_not,
      clk_in   => CLK_PCLK_RIGHT, -- 100 MHz clocks;
	  sig_out  =>Veto_notstretched50);
	  
	  
	  --Str2_60ns: signal_stretch generic map(
                                    --        Stretch => 2  -- number of clock cycles during which the signal will be stretched
                                     -- )
  --port map(
   -- sig_in   => Veto_ored,
   -- clk_in   => CLK_PCLK_RIGHT ,
	--sig_out  => V_out_str_60ns
	--);

	  
	  
  -------------------------------- Calib triggers: OR All--------------------------------
  
 -- SmallBarsTrig: SmallBars_TrigLogic 
	       --    port map(
	             --in_clk=> CLK_PCLK_RIGHT,
	             --in_BM=> INP (31 downto 0),
	             --out_BM_SmallBars=> SmallBars_temp_Trig
	             --);
  
 
						
  BM_Or: BM_OrAll 
	           port map(in_clk=> CLK_PCLK_RIGHT,
	                    in_bm=> INP (15 downto 8),
	                    out_bm=> BM_out_temp_OrAll
						);
	        
  

  Veto_Or: Veto_OrAll
	            port map(in_clk=> CLK_PCLK_RIGHT,
						in_veto=> INP(7 downto 0),
						out_veto=> Veto_out_temp_OrAll
						);

	
	
  OutpA(0) <= BM_Trig_stretched40; -- Or od ANds
  OutpA(1) <= '0';
  OutpA(2) <= Veto_notstretched50;
  
  OutpB(0) <= Veto_out_temp_OrAll;
  OutpB(1) <= BM_out_temp_OrAll; -- big bars Or All
  OutpB(2) <= '0';
  
  OutpC(0) <= '0';
  OutpC(1) <= '0';
  OutpC(2) <= '0';

end structural;



