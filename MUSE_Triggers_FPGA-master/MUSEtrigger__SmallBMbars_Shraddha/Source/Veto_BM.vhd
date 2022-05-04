-- //// This is a vhdl Veto_BM Trigger function.
--/////
--/////////////////// Shraddha Dogra///////////
--//////////////////  ////////////
-------------------------------------------------------------------------------------

library  ieee;
use  ieee.std_logic_1164.all;


library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb3_components.all;
use work.config.all;
use work.version.all;
use work.basic_type_declaration.all;  -- Ievgen: File with different type declarations.


entity Veto_BM is
	  port( 
	  INP 			    : in std_logic_vector(63 downto 0); --using only first 16.
      INP_mask          : in array64(63 downto 0);
	  bar_enable_mask   : in std_logic_vector (63 downto 0);
	  CLK_PCLK_RIGHT	: in std_logic;
	  OutpA				: out std_logic_vector(2 downto 0);
	  OutpB				: out std_logic_vector(2 downto 0);
	  OutpC				: out std_logic_vector(2 downto 0)
	      )  ; 
end Veto_BM;





architecture structural of Veto_BM is
 signal BM_temp_out: std_logic_vector (31 downto 0):= (others => '0');
 
 signal BM_enabled1: std_logic_vector(63 downto 0):= (others => '0');
 --signal BM_enabled2: std_logic_vector(7 downto 0):= (others => '0');
 signal new_vector:std_logic_vector(63 downto 0);
 -- signal bm_temp_out: std_logic_vector(63 downto 0);
 signal BM_ored: std_logic;
  
 
 -- INP_mask_reg: for i in 0 to 63 loop
--if i == INP_mask.addr;
 --INP(i)=> new_vector(INP_mask.data(i)); --bars#8 INP will be substituted. mask.data->bar# in trbcmd. 
 --END LOOP INP_mask_reg;
 
 
 
 
 --for i in 0 to 63
-- if i== INP_mask.address
---- INP(i)=> new_vector(INP_mask.data(i));
 
 component BM_control is	
	port (
		in_sig		 	: in std_logic_vector(63 downto 0):= (others => '1'); --trigger input channels on 4ConnBoard
		bar_enable_mask	: in std_logic_vector(63 downto 0) := (others => '1'); --mask of connected trigger channels (each bit correspods to the channel enable/disable)
		out_sig 		: out std_logic_vector(63 downto 0)  -- trigger logic output
	);
end component BM_control;

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
 

 
 component BM_Trig_Logic is
  port(
      in_clk: in std_logic;
	  in_BM: in std_logic_vector (63 downto 0);
	  out_BM: out std_logic_vector(31 downto 0)
	    );
 end component BM_Trig_Logic; 
 
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
 
 BM_Control1: BM_control
	              port map (
		             in_sig          => INP,	 
		             bar_enable_mask	=> bar_enable_mask,  --mask of connected trigger channels (each bit correspods to the channel enable/disable)
		             out_sig         => BM_enabled1);  -- trigger logic output

							
 BM_trig: BM_Trig_Logic
	               port map(
				            in_clk => CLK_PCLK_RIGHT,
				            in_BM => BM_enabled1,
		                    out_BM => BM_temp_out);							
							

BM_ored <= BM_temp_out(0) or BM_temp_out(1) or BM_temp_out(2) or BM_temp_out(3) or BM_temp_out(4)
           or BM_temp_out(5) or BM_temp_out(6) or BM_temp_out(7) or BM_temp_out(8) or BM_temp_out(9) or
		   BM_temp_out(10) or BM_temp_out(11) or BM_temp_out(12) or BM_temp_out(13) or BM_temp_out(14) or BM_temp_out(15) or
           BM_temp_out(16) or BM_temp_out(17) or BM_temp_out(18) or BM_temp_out(19) or BM_temp_out(20) or BM_temp_out(21) or
		   BM_temp_out(22) or BM_temp_out(23) or BM_temp_out(24) or BM_temp_out(25) or BM_temp_out(26) or BM_temp_out(27) or
		   BM_temp_out(28) or BM_temp_out(29) or BM_temp_out(30) or BM_temp_out(31);




--Str1_60ns: signal_stretch generic map(  --   Stretch => 1  -- number of clock cycles during which the signal will be stretched
    --  )
  --port map(
    --sig_in   => BM_ored, -- input signal should be longer that clock period;
    --sig_in   : in  std_logic_vector (47 downto 0); 
    --clk_in   => CLK_PCLK_RIGHT,
	--sig_out  =>B_out_str_60ns
    -- );
		
-- Str2_60ns: signal_stretch generic map(
                             --               Stretch => 1  -- number of clock cycles during which the signal will be stretched
                               --       )
  --port map(
    --sig_in   => Veto_ored,
    --clk_in   => CLK_PCLK_RIGHT ,
	--sig_out  => V_out_str_60ns
	--);
	
  OutpA(0) <= BM_ored;

  


end structural;

