--------------------------------------------------------------------------------
-- Company:  GSI
-- Engineer: Davide Leoni
--
-- Create Date:    9/3/07
-- Design Name:    vulom3
-- Module Name:    trig_box1 - Behavioral
-- Project Name:   triggerbox
-- Target Device:  XC4VLX25-10SF363
-- Tool versions:  
-- Description: Triggerbox
-- NOTE (1): To enable TOF/MDC part comment lines (a) and (b) and uncomment (c)
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;																						
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity trig_box1 is
		port (clk_50MHz : in std_logic; 
				clk_300MHz : in std_logic;
				clk_100MHz : in std_logic;
				ECL : in std_logic_vector(16 downto 1);
				ECO : out std_logic_vector(16 downto 1);				
				IOO : in std_logic_vector(16 downto 1);
				TIN : out std_logic_vector(16 downto 1);
				LEMIN	: in std_logic_vector(2 downto 1);
				LEMOU	: out std_logic_vector(2 downto 1);
				INPUT_ENABLE : in std_logic_vector(7 downto 1);
				DOWNSCALE_REGISTER_1 : in std_logic_vector(3 downto 0);
				DELAY_REGISTER_1 : in std_logic_vector(3 downto 0);
				WIDTH_REGISTER_1 : in std_logic_vector(3 downto 0);
				DOWNSCALE_REGISTER_2 : in std_logic_vector(3 downto 0);
				DELAY_REGISTER_2 : in std_logic_vector(3 downto 0);
				WIDTH_REGISTER_2 : in std_logic_vector(3 downto 0);
				DOWNSCALE_REGISTER_3 : in std_logic_vector(3 downto 0);
				DELAY_REGISTER_3 : in std_logic_vector(3 downto 0);
				WIDTH_REGISTER_3 : in std_logic_vector(3 downto 0);
				DOWNSCALE_REGISTER_4 : in std_logic_vector(3 downto 0);
				DELAY_REGISTER_4 : in std_logic_vector(3 downto 0);
				WIDTH_REGISTER_4 : in std_logic_vector(3 downto 0);
				DOWNSCALE_REGISTER_5 : in std_logic_vector(3 downto 0);
				DELAY_REGISTER_5 : in std_logic_vector(3 downto 0);
				WIDTH_REGISTER_5 : in std_logic_vector(3 downto 0);
				DOWNSCALE_REGISTER_TS : in std_logic_vector(3 downto 0);
				DELAY_REGISTER_TS : in std_logic_vector(3 downto 0);
				WIDTH_REGISTER_TS : in std_logic_vector(3 downto 0);
				DOWNSCALE_REGISTER_VS : in std_logic_vector(3 downto 0);
				DELAY_REGISTER_VS : in std_logic_vector(3 downto 0);
				WIDTH_REGISTER_VS : in std_logic_vector(3 downto 0);
				DOWNSCALE_REGISTER_CLOCK : in std_logic_vector(3 downto 0);			
				BRANCH_EN_with_MDC_TOF_WIDTH : in std_logic_vector(4 downto 0);		--(4) enables branch, (3 downto 0) is the width value
				WIDTH_OUTPUT : in std_logic_vector(3 downto 0);
				MUX_SELECTOR_1 : in std_logic_vector(3 downto 0);
				MUX_SELECTOR_2 : in std_logic_vector(3 downto 0);
				OR_ON_OFF : in std_logic_vector(7 downto 0);
				SCALER_PTI1 : out std_logic_vector(31 downto 0);
				SCALER_PTI2 : out std_logic_vector(31 downto 0);
				SCALER_PTI3 : out std_logic_vector(31 downto 0);				
				SCALER_PTI4 : out std_logic_vector(31 downto 0);
				SCALER_PTI5 : out std_logic_vector(31 downto 0);				
				SCALER_TS : out std_logic_vector(31 downto 0);
				SCALER_VS : out std_logic_vector(31 downto 0);
				SCALER_MDC_TOF_SELECT : in std_logic_vector(7 downto 0);  -- x"yz"  y= mdc channel select, z= tof channel select
				SCALER_MDC : out std_logic_vector(31 downto 0);				
				SCALER_TOF : out std_logic_vector(31 downto 0);				
				SCALER_RESET : in std_logic_vector(7 downto 0);
				PTI5_TS_ALTERNATIVE : in std_logic_vector(7 downto 0);
				DELAY_REGISTER_BEAM : in std_logic_vector(7 downto 0);
				WIDTH_INHIBIT_REGISTER_BEAM : in std_logic_vector(7 downto 0);
				WIDTH_EXTERNAL_REGISTER_BEAM : in std_logic_vector(7 downto 0);
				SCALER_DEAD : out std_logic_vector(31 downto 0);
				TS_GATING_DISABLE : in std_logic_vector(7 downto 1);
				SCALER_PTI1_ACCEPTED : out std_logic_vector(31 downto 0);
				SCALER_PTI2_ACCEPTED : out std_logic_vector(31 downto 0);
				SCALER_PTI3_ACCEPTED : out std_logic_vector(31 downto 0);				
				SCALER_PTI4_ACCEPTED : out std_logic_vector(31 downto 0);
				SCALER_PTI5_ACCEPTED : out std_logic_vector(31 downto 0);				
				SCALER_TS_ACCEPTED : out std_logic_vector(31 downto 0);
				SCALER_VS_ACCEPTED : out std_logic_vector(31 downto 0);
				SCALER_MUX1 : out std_logic_vector(31 downto 0);
				SCALER_MUX2 : out std_logic_vector(31 downto 0);
                                DTU_CODE_SELECT              : in  std_logic_vector(4 downto 0);
				CAL_TRIGGER_DISABLE : in std_logic;
				COM_RUN : in std_logic;
				DTU_ERROR : inout std_logic;
				hpv : inout std_logic_vector(15 downto 0);
				hpw : inout std_logic_vector(15 downto 0);
                                DEBUG_REG_00 : out std_logic_vector(31 downto 0);
                                TRB_BUSY_ENABLE : in std_logic
					);
end trig_box1;


architecture RTL of trig_box1 is

component ONE_CLOCK_LONG port (
	clk       : in std_logic;
	en_clk    : in std_logic;
	signal_in : in std_logic;
	pulse     : out std_logic);
end component;

component DELAY port (
	clk           : in std_logic;
	to_be_delayed : in std_logic;
	delay_value   : in std_logic_vector(3 downto 0);
	delayed_pulse : out std_logic);
end component;

component DOWNSCALE port (
	clk				  : in std_logic;
	disable			  : in std_logic;
	to_be_downscaled : in std_logic;
	downscale_value  : in std_logic_vector(3 downto 0);
	downscaled       : out std_logic);
end component; 

component SET_WIDTH port (
	clk                  : in std_logic;
	to_be_set            : in std_logic;
	width_value          : in std_logic_vector(3 downto 0);
	width_adjusted_pulse : out std_logic);
end component;

component SET_WIDTH_special port (
	clk                  : in std_logic;
	to_be_set            : in std_logic;
	width_value          : in std_logic_vector(3 downto 0);
	width_adjusted_pulse : out std_logic);
end component;
  
component SCALER port (
	clk			: in std_logic;
	input_pulse : in std_logic;
	scaler_reset : in std_logic;
	scaler_value  : out std_logic_vector(19 downto 0));
end component;

component SCALER_S port (
	clk_300MHz	: in std_logic;
	clk_100MHz	: in std_logic;
	input_pulse : in std_logic;
	scaler_reset : in std_logic;
	scaler_value  : out std_logic_vector(31 downto 0));
end component;

component ECO_DELAY port (
	clk			: in std_logic;
	signal_in	: in std_logic;
	signal_out	: out std_logic);
end component;

COMPONENT new_downscale_ck
PORT(
	downscale_value : IN std_logic_vector(3 downto 0);
	clk : IN std_logic;          
	downscaled : OUT std_logic;
	output_disable : IN std_logic;
        global_inhibit : in std_logic;
	scaler_reset : OUT std_logic;
	cal_inhibit : OUT std_logic;
	cal_trigger : OUT std_logic
	);
END COMPONENT;

COMPONENT beam_ramp
PORT(
	clk_300MHz : IN std_logic;
	clk_50MHz : IN std_logic;
	input : IN std_logic;
	delay_value : IN std_logic_vector(7 downto 0);
	width_value_inhibit : IN std_logic_vector(7 downto 0);
	width_value_external : IN std_logic_vector(7 downto 0);
	output_inhibit : OUT std_logic;
	output_external : OUT std_logic
	);
END COMPONENT;

COMPONENT bus_data_com5
PORT(
	clk_300MHz : IN std_logic;
	clk_100MHz : IN std_logic;
	gts_pulse : IN std_logic;
	cal_trigger : IN std_logic;
	bus_busy : IN std_logic;								--not used
	bus_ack : in std_logic;
	bus_retx : in std_logic;
	latch : IN std_logic_vector(6 downto 0);
	latch_dsc : IN std_logic_vector(6 downto 0);
	scaler_pti1 : IN std_logic_vector(31 downto 0);
	scaler_pti2 : IN std_logic_vector(31 downto 0);
	scaler_pti3 : IN std_logic_vector(31 downto 0);
	scaler_pti4 : IN std_logic_vector(31 downto 0);
	scaler_pti5 : IN std_logic_vector(31 downto 0);
	scaler_ts : IN std_logic_vector(31 downto 0);
	scaler_vs : IN std_logic_vector(31 downto 0);
	scaler_dead : IN std_logic_vector(31 downto 0);          
	bus_inhibit : OUT std_logic;
	dtu_inhibit : out std_logic;													
	ecl_bus_data : OUT std_logic_vector(1 downto 0);
	ecl_bus_clk : OUT std_logic;
	com_run : IN std_logic;
	dtu_bus_t : out std_logic;
	dtu_bus_ts : out std_logic;
	dtu_bus_td : out std_logic_vector (3 downto 0);
        DTU_CODE_SELECT              : in  std_logic_vector(4 downto 0);
        DEBUG_REG_01 : out std_logic_vector(15 downto 0);
        cal_inhibit : in std_logic;
	out_inhibit : in std_logic;
        TRB_BUSY_ENABLE : in std_logic
	);
END COMPONENT;


signal PTI1_ONE_CLOCK, PTI1_DELAYED, PTI1_READY, PTI1_DOWNSCALED, PTI1_SELF_COIN : std_logic;
signal PTI2_ONE_CLOCK, PTI2_DELAYED, PTI2_READY, PTI2_DOWNSCALED, PTI2_SELF_COIN : std_logic;
signal PTI3_ONE_CLOCK, PTI3_DELAYED, PTI3_READY, PTI3_DOWNSCALED, PTI3_SELF_COIN : std_logic;
signal PTI4_ONE_CLOCK, PTI4_DELAYED, PTI4_READY, PTI4_DOWNSCALED, PTI4_SELF_COIN : std_logic;
signal PTI5_ONE_CLOCK, PTI5_DELAYED, PTI5_READY, PTI5_DOWNSCALED, PTI5_SELF_COIN : std_logic;
signal TS_ONE_CLOCK, TS_DELAYED, TS_READY, dead, TS_SELF_COIN : std_logic;
signal VS_ONE_CLOCKS, VS_DELAYED, VS_READY, VS_WIDTH_SET, VS_SELF_COIN : std_logic;
signal CLOCK_DOWNSCALED, CLOCK_READY : std_logic;
signal cal_inhibit, cal_trigger, out_inhibit, beam_inhibit, bus_inhibit : std_logic;
signal GLOBAL_TIMING_SIGNAL_OUT, OR_out : std_logic; 
signal PTI1_and_GTS, PTI2_and_GTS, PTI3_and_GTS, PTI4_and_GTS, PTI5_and_GTS : std_logic;
signal lemin_s, lemin_s1, mux_out : std_logic_vector(1 downto 0);
signal mdc_tof_or, mdc_tof_or_width_set, tof_or, tof_or_delayed, tof_mult_2, tof_mult_2_one, mdc_tof_trigger, mdc_tof_trigger_width_set : std_logic;
signal eco_s, eco_out : std_logic_vector(16 downto 1);
signal tof_one_clock, tof_del, tof_s, tof_s1, mdc_s, mdc_s1 : std_logic_vector(5 downto 0);
signal tof_mux, mdc_mux, pti5_mux, ts_mux, mdc_one_clock : std_logic;
signal scaler_pti1_count, scaler_pti2_count, scaler_pti3_count, scaler_pti4_count, scaler_pti5_count, 
			scaler_ts_count, scaler_vs_count, scaler_dead_count : std_logic_vector(31 downto 0);
signal self_coin_delay_1, self_coin_delay_2, self_coin_delay_3, self_coin_delay_4, self_coin_delay_5 : std_logic_vector(3 downto 0);
signal scaler_reset_internal : std_logic;
signal dtu_bus_t, dtu_bus_ts, dtu_bus_tb_s, dtu_inhibit : std_logic;
signal dtu_bus_td : std_logic_vector(3 downto 0);
signal GTS_to_databus, CAL_to_databus : std_logic;

begin

-------------------------------------------------------------ONE CLOCK LONG	
one1: ONE_CLOCK_LONG port map (
	clk => clk_300MHz,
	en_clk => INPUT_ENABLE(1),
	signal_in => IOO(1),					
	pulse => PTI1_ONE_CLOCK);
	
one2: ONE_CLOCK_LONG port map (
	clk => clk_300MHz,
	en_clk => INPUT_ENABLE(2),
	signal_in => IOO(2),	
	pulse => PTI2_ONE_CLOCK);

one3: ONE_CLOCK_LONG port map (
	clk => clk_300MHz,
	en_clk => INPUT_ENABLE(3),
	signal_in => IOO(3),	
	pulse => PTI3_ONE_CLOCK);

one4: ONE_CLOCK_LONG port map (											--Directly connected to the OR of TOF, so ECL input n°4 is unused
	clk => clk_300MHz,
	en_clk => INPUT_ENABLE(4),
	signal_in => tof_or,															
	pulse => PTI4_ONE_CLOCK);

one5: ONE_CLOCK_LONG port map (
	clk => clk_300MHz,
	en_clk => INPUT_ENABLE(5),
	signal_in => IOO(5),	
	pulse => PTI5_ONE_CLOCK);

one6: ONE_CLOCK_LONG port map (
	clk => clk_300MHz,
	en_clk => INPUT_ENABLE(6),
	signal_in => IOO(6),	
	pulse => TS_ONE_CLOCK);

one7: ONE_CLOCK_LONG port map (
	clk => clk_300MHz,
	en_clk => INPUT_ENABLE(7),
	signal_in => IOO(7),	
	pulse => VS_ONE_CLOCKS);
		
one_mdc: ONE_CLOCK_LONG port map (						--used only for scaler
	clk => clk_300MHz,
	en_clk => '1',													
	signal_in => mdc_mux,
	pulse => mdc_one_clock);
	
tof_generate_oneclock : for i in 9 to 14 generate			
	one_tof: ONE_CLOCK_LONG port map (
		clk => clk_300MHz,
		en_clk => '1',											--tof always enabled			
		signal_in => ECL(i),
		pulse => tof_one_clock(i-9));
end generate;
---------------------------------------------
multiplicity: ONE_CLOCK_LONG port map (
	clk => clk_300MHz,
	en_clk => '1',
	signal_in => tof_mult_2,
	pulse => tof_mult_2_one);
---------------------------------------------
one_ck: ONE_CLOCK_LONG port map (
	clk => clk_300MHz,
	en_clk => '1',
	signal_in => CLOCK_DOWNSCALED,
	pulse => CLOCK_READY);

-------------------------------------------------------------------------DELAY
del1: DELAY port map (
	clk => clk_300MHz,
	to_be_delayed => PTI1_ONE_CLOCK,
	delay_value => DELAY_REGISTER_1(3 downto 0),
	delayed_pulse => PTI1_DELAYED);

del2: DELAY port map (
	clk => clk_300MHz,
	to_be_delayed => PTI2_ONE_CLOCK,
	delay_value => DELAY_REGISTER_2(3 downto 0),
	delayed_pulse => PTI2_DELAYED);

del3: DELAY port map (
	clk => clk_300MHz,
	to_be_delayed => PTI3_ONE_CLOCK,
	delay_value => DELAY_REGISTER_3(3 downto 0),
	delayed_pulse => PTI3_DELAYED);

del4: DELAY port map (
	clk => clk_300MHz,
	to_be_delayed => PTI4_ONE_CLOCK,
	delay_value => DELAY_REGISTER_4(3 downto 0),
	delayed_pulse => PTI4_DELAYED);

del5: DELAY port map (
	clk => clk_300MHz,
	to_be_delayed => pti5_mux,
	delay_value => DELAY_REGISTER_5(3 downto 0),
	delayed_pulse => PTI5_DELAYED);

del6: DELAY port map (
	clk => clk_300MHz,
	to_be_delayed => ts_mux,
	delay_value => DELAY_REGISTER_TS(3 downto 0),
	delayed_pulse => TS_DELAYED);

del7: DELAY port map (
	clk => clk_300MHz,
	to_be_delayed => VS_ONE_CLOCKS,
	delay_value => DELAY_REGISTER_VS(3 downto 0),
	delayed_pulse => VS_DELAYED);
	
self_coin_delay_1 <= '0' & WIDTH_REGISTER_1(3 downto 1);					--automatic delay = width / 2
self_coin_delay_2 <= '0' & WIDTH_REGISTER_2(3 downto 1);
self_coin_delay_3 <= '0' & WIDTH_REGISTER_3(3 downto 1);
self_coin_delay_4 <= '0' & WIDTH_REGISTER_4(3 downto 1);
self_coin_delay_5 <= '0' & WIDTH_REGISTER_5(3 downto 1);
	
del1_self: DELAY port map (
	clk => clk_300MHz,
	to_be_delayed => PTI1_DOWNSCALED,
	delay_value => self_coin_delay_1,					
	delayed_pulse => PTI1_SELF_COIN);
	
del2_self: DELAY port map (
	clk => clk_300MHz,
	to_be_delayed => PTI2_DOWNSCALED,
	delay_value => self_coin_delay_2,					
	delayed_pulse => PTI2_SELF_COIN);
	
del3_self: DELAY port map (
	clk => clk_300MHz,
	to_be_delayed => PTI3_DOWNSCALED,
	delay_value => self_coin_delay_3,					
	delayed_pulse => PTI3_SELF_COIN);
	
del4_self: DELAY port map (
	clk => clk_300MHz,
	to_be_delayed => PTI4_DOWNSCALED,
	delay_value => self_coin_delay_4,					
	delayed_pulse => PTI4_SELF_COIN);
	
del5_self: DELAY port map (
	clk => clk_300MHz,
	to_be_delayed => PTI5_DOWNSCALED,
	delay_value => self_coin_delay_5,					
	delayed_pulse => PTI5_SELF_COIN);
	
tof_generate_delay : for t in 0 to 5 generate			
	del_tof: DELAY port map (
		clk => clk_300MHz,
		to_be_delayed => tof_one_clock(t),
		delay_value => DELAY_REGISTER_4(3 downto 0),					
		delayed_pulse => tof_del(t));
end generate;

-------------------------------------------------------------------------SCALER
scal1: SCALER_S port map (												
	clk_300MHz => clk_300MHz,													
	clk_100MHz => clk_100MHz,													--PTI1÷5 before inhibit
	input_pulse => PTI1_DELAYED,
	scaler_reset => scaler_reset_internal, 
	scaler_value => SCALER_PTI1_count);

scal2: SCALER_S port map (
	clk_300MHz => clk_300MHz,
	clk_100MHz => clk_100MHz,
	input_pulse => PTI2_DELAYED,
	scaler_reset => scaler_reset_internal,  
	scaler_value => SCALER_PTI2_count);

scal3: SCALER_S port map (
	clk_300MHz => clk_300MHz,
	clk_100MHz => clk_100MHz,
	input_pulse => PTI3_DELAYED,
	scaler_reset => scaler_reset_internal, 
	scaler_value => SCALER_PTI3_count);

scal4: SCALER_S port map (
	clk_300MHz => clk_300MHz,
	clk_100MHz => clk_100MHz,
	input_pulse => PTI4_DELAYED,
	scaler_reset => scaler_reset_internal, 
	scaler_value => SCALER_PTI4_count);

scal5: SCALER_S port map (
	clk_300MHz => clk_300MHz,
	clk_100MHz => clk_100MHz,
	input_pulse => PTI5_DELAYED,
	scaler_reset => scaler_reset_internal, 
	scaler_value => SCALER_PTI5_count);
	
scal1a: SCALER_S port map (
	clk_300MHz => clk_300MHz,														
	clk_100MHz => clk_100MHz,														--PTI1÷5 after inhibit
	input_pulse => eco_s(9),
	scaler_reset => scaler_reset_internal, 
	scaler_value => SCALER_PTI1_ACCEPTED);
	
scal2a: SCALER_S port map (
	clk_300MHz => clk_300MHz,
	clk_100MHz => clk_100MHz,														
	input_pulse => eco_s(10),
	scaler_reset => scaler_reset_internal,
	scaler_value => SCALER_PTI2_ACCEPTED);
	
scal3a: SCALER_S port map (
	clk_300MHz => clk_300MHz,
	clk_100MHz => clk_100MHz,														
	input_pulse => eco_s(11),
	scaler_reset => scaler_reset_internal,  
	scaler_value => SCALER_PTI3_ACCEPTED);
	
scal4a: SCALER_S port map (
	clk_300MHz => clk_300MHz,
	clk_100MHz => clk_100MHz,														
	input_pulse => eco_s(12),
	scaler_reset => scaler_reset_internal,  
	scaler_value => SCALER_PTI4_ACCEPTED);
	
scal5a: SCALER_S port map (
	clk_300MHz => clk_300MHz,
	clk_100MHz => clk_100MHz,														
	input_pulse => eco_s(13),
	scaler_reset => scaler_reset_internal, 
	scaler_value => SCALER_PTI5_ACCEPTED);

scalts: SCALER_S port map (
	clk_300MHz => clk_300MHz,														
	clk_100MHz => clk_100MHz,														--TS, VS and dead
	input_pulse => TS_DELAYED,
	scaler_reset => scaler_reset_internal,  
	scaler_value => SCALER_TS_count);

scalvs: SCALER_S port map (
	clk_300MHz => clk_300MHz,
	clk_100MHz => clk_100MHz,
	input_pulse => VS_DELAYED,
	scaler_reset => scaler_reset_internal, 
	scaler_value => SCALER_VS_count);
		
scaldead: SCALER_S port map (
	clk_300MHz => clk_300MHz,
	clk_100MHz => clk_100MHz,
	input_pulse => dead,
	scaler_reset => scaler_reset_internal,  
	scaler_value => SCALER_DEAD_count);
	
scalmdc: SCALER_S port map (
	clk_300MHz => clk_300MHz,														
	clk_100MHz => clk_100MHz,														--MDC and TOF
	input_pulse => mdc_one_clock,
	scaler_reset => scaler_reset_internal,  
	scaler_value => SCALER_MDC);
	
scaltof: SCALER_S port map (
	clk_300MHz => clk_300MHz,
	clk_100MHz => clk_100MHz,
	input_pulse => tof_mux,
	scaler_reset => scaler_reset_internal, 
	scaler_value => SCALER_TOF);
	
scalmux1: SCALER_S port map (
	clk_300MHz => clk_300MHz,
	clk_100MHz => clk_100MHz,														
	input_pulse => mux_out(0),
	scaler_reset => scaler_reset_internal, 
	scaler_value => SCALER_MUX1);
	
scalmux2: SCALER_S port map (
	clk_300MHz => clk_300MHz,
	clk_100MHz => clk_100MHz,														
	input_pulse => mux_out(1),
	scaler_reset => scaler_reset_internal,  
	scaler_value => SCALER_MUX2);

---------------------------------------------------------------------------DOWNSCALE
dwsc1: DOWNSCALE port map (
	clk => clk_300MHz,
	disable => out_inhibit,
	to_be_downscaled => PTI1_DELAYED,
	downscale_value  => DOWNSCALE_REGISTER_1(3 downto 0),
	downscaled => PTI1_DOWNSCALED);

dwsc2: DOWNSCALE port map (
	clk => clk_300MHz,
	disable => out_inhibit,
	to_be_downscaled => PTI2_DELAYED,
	downscale_value  => DOWNSCALE_REGISTER_2(3 downto 0),
	downscaled => PTI2_DOWNSCALED);

dwsc3: DOWNSCALE port map (
	clk => clk_300MHz,
	disable => out_inhibit,
	to_be_downscaled => PTI3_DELAYED,
	downscale_value  => DOWNSCALE_REGISTER_3(3 downto 0),
	downscaled => PTI3_DOWNSCALED);

dwsc4: DOWNSCALE port map (
	clk => clk_300MHz,
	disable => out_inhibit,
	to_be_downscaled => PTI4_DELAYED,
	downscale_value  => DOWNSCALE_REGISTER_4(3 downto 0),
	downscaled => PTI4_DOWNSCALED);

dwsc5: DOWNSCALE port map (
	clk => clk_300MHz,
	disable => out_inhibit,
	to_be_downscaled => PTI5_DELAYED,
	downscale_value  => DOWNSCALE_REGISTER_5(3 downto 0),
	downscaled => PTI5_DOWNSCALED);

dwscts: DOWNSCALE port map (
	clk => clk_300MHz,
	disable => out_inhibit,
	to_be_downscaled => TS_DELAYED,
	downscale_value  => DOWNSCALE_REGISTER_TS(3 downto 0),
	downscaled => TS_READY);

dwscvs: DOWNSCALE port map (
	clk => clk_300MHz,
	disable => out_inhibit,
	to_be_downscaled => VS_DELAYED,
	downscale_value  => DOWNSCALE_REGISTER_VS(3 downto 0),
	downscaled => VS_READY);

-------------------------------------------------------------------------------WIDTH
setw1: SET_WIDTH port map (
	clk => clk_300MHz,
	to_be_set => PTI1_DOWNSCALED,
	width_value => WIDTH_REGISTER_1(3 downto 0),
	width_adjusted_pulse => PTI1_READY);

setw2: SET_WIDTH port map (
	clk => clk_300MHz,
	to_be_set => PTI2_DOWNSCALED,
	width_value => WIDTH_REGISTER_2(3 downto 0),
	width_adjusted_pulse => PTI2_READY);

setw3: SET_WIDTH port map (
	clk => clk_300MHz,
	to_be_set => PTI3_DOWNSCALED,
	width_value => WIDTH_REGISTER_3(3 downto 0),
	width_adjusted_pulse => PTI3_READY);

setw4: SET_WIDTH port map (
	clk => clk_300MHz,
	to_be_set => PTI4_DOWNSCALED,
	width_value => WIDTH_REGISTER_4(3 downto 0),
	width_adjusted_pulse => PTI4_READY);

setw5: SET_WIDTH port map (
	clk => clk_300MHz,
	to_be_set => PTI5_DOWNSCALED,
	width_value => WIDTH_REGISTER_5(3 downto 0),
	width_adjusted_pulse => PTI5_READY);

setw7: SET_WIDTH port map (
	clk => clk_300MHz,
	to_be_set => VS_DELAYED,
	width_value => WIDTH_REGISTER_VS(3 downto 0),
	width_adjusted_pulse => VS_WIDTH_SET);
	
--*/*/*///*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/							--READ NOTE 1)
mdc_tof_trigger_width_set <= '1';												--(a)
--*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*
	
setw_mdc_tof_trigger: SET_WIDTH port map (				
	clk => clk_300MHz,
	to_be_set => mdc_tof_or,
	width_value => BRANCH_EN_with_MDC_TOF_WIDTH(3 downto 0),
--	width_adjusted_pulse => mdc_tof_trigger_width_set);					--(c)
	width_adjusted_pulse => open);												--(b)	

setwout: SET_WIDTH_special port map (
	clk => clk_300MHz,
	to_be_set => GLOBAL_TIMING_SIGNAL_OUT,
	width_value => x"6", 						-- fixed to 20 ns
	width_adjusted_pulse => LEMOU(1));							

------------------------------------------------------------------------------------------OUTPUT
delaygen1 : for i in 1 to 7 generate		
	delay_out : ECO_DELAY port map (
		clk => clk_300MHz,
		signal_in => eco_s(i),
		signal_out => eco_out(i));												
end generate;

ECO(7 downto 1) <= eco_out(7 downto 1);

setmux1: SET_WIDTH port map (							
	clk => clk_300MHz,
	to_be_set => mux_out(0),
	width_value => "0010",
	width_adjusted_pulse => ECO(8));	

delaygen2 : for i in 9 to 15 generate
	delay_out : ECO_DELAY port map (
		clk => clk_300MHz,
		signal_in => eco_s(i),
		signal_out => eco_out(i));												
end generate;

ECO(15 downto 9) <= eco_out(15 downto 9);

setmux2: SET_WIDTH port map (							
	clk => clk_300MHz,
	to_be_set => mux_out(1),
	width_value => "0010",
	width_adjusted_pulse => ECO(16));

Inst_new_downscale_ck: new_downscale_ck PORT MAP(
	downscale_value => DOWNSCALE_REGISTER_CLOCK(3 downto 0),
	clk => clk_300MHz,
	output_disable => CAL_TRIGGER_DISABLE,
	scaler_reset => scaler_reset_internal,
	downscaled => CLOCK_DOWNSCALED,
        global_inhibit => out_inhibit,
	cal_inhibit => cal_inhibit,
	cal_trigger => cal_trigger);
	

LEMOU(2) <= out_inhibit;--OR_out;-- GLOBAL_TIMING_SIGNAL_OUT;											--Now calib pulse is coming out from lemo n°1, this output is unused

Inst_beam_ramp: beam_ramp PORT MAP(
	clk_300MHz => clk_300MHz,
	clk_50MHz => clk_50MHz,
	input => lemin_s(1),
	output_inhibit => beam_inhibit,  
	output_external => TIN(12),
	delay_value => DELAY_REGISTER_BEAM,
	width_value_inhibit => WIDTH_INHIBIT_REGISTER_BEAM,
	width_value_external =>	WIDTH_EXTERNAL_REGISTER_BEAM);
	
--------------BUS COMMUNICATION

Inst_bus_data_com5: bus_data_com5 PORT MAP(
	clk_300MHz => clk_300MHz,
	clk_100MHz => clk_100MHz,
	gts_pulse => GTS_to_databus,
	cal_trigger => cal_trigger,
	bus_busy => IOO(16),											--not used
	bus_ack => IOO(15),
	bus_retx => IOO(14),
	latch => eco_out(7 downto 1),
	latch_dsc => eco_out(15 downto 9),
	scaler_pti1 => scaler_pti1_count,
	scaler_pti2 => scaler_pti2_count,
	scaler_pti3 => scaler_pti3_count,
	scaler_pti4 => scaler_pti4_count,
	scaler_pti5 => scaler_pti5_count,
	scaler_ts => scaler_ts_count,
	scaler_vs => scaler_vs_count,
	scaler_dead => scaler_dead_count,
	bus_inhibit => bus_inhibit,
	dtu_inhibit => dtu_inhibit,													
	ecl_bus_data => TIN(11 downto 10),
	ecl_bus_clk => open,--TIN(9),
	com_run => com_run,
	dtu_bus_t => dtu_bus_t,					
	dtu_bus_ts => dtu_bus_ts,
	dtu_bus_td => dtu_bus_td,
        DTU_CODE_SELECT => DTU_CODE_SELECT,
        DEBUG_REG_01 => DEBUG_REG_00(15 downto 0),
        cal_inhibit => cal_inhibit,
	out_inhibit => out_inhibit,
        TRB_BUSY_ENABLE => TRB_BUSY_ENABLE
	);

	--/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
	hpv(14) <= not dtu_bus_t;	--This is a "firmware patch": the VME connector 
	hpw(14) <= not dtu_bus_ts;	--for DTU is reversed (mistake in pcb layout) so 
	hpw(10) <= not dtu_bus_td(3);	--all the I/Os must be inverted
	hpv(10) <= not dtu_bus_td(2);
	hpw(12) <= not dtu_bus_td(1);
	hpv(12) <= not dtu_bus_td(0);								
	hpw(8) <= 'Z';
	----------------------
	hpv(15) <= dtu_bus_ts;		--With this connections all the DTU signals are
	hpv(11) <= dtu_bus_td(3);	--on one debug socket (hplv or hplw) that can conveniently
	hpv(13) <= dtu_bus_td(1);	--plugged to a logic analyzer. Be aware though, some signals
	hpv(9) <= '0';			--are inverted
	hpv(7 downto 0) <= x"00";	--unused
	
	hpw(15) <= dtu_bus_t;
	hpw(11) <= dtu_bus_td(2);
	hpw(13) <= dtu_bus_td(0);
	hpw(9) <= '0';
	hpw(7 downto 0) <= x"00";	--unused
	--/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/

		SCALER_PTI1 <= SCALER_PTI1_count;	
		SCALER_PTI2 <= SCALER_PTI2_count;	
		SCALER_PTI3 <= SCALER_PTI3_count;		
		SCALER_PTI4 <= SCALER_PTI4_count;	
		SCALER_PTI5 <= SCALER_PTI5_count;
		SCALER_TS <= SCALER_TS_count;
		SCALER_VS <= SCALER_VS_count;
		SCALER_dead <= SCALER_dead_count;

TIN(16 downto 13) <= "0000";

--------------PTI5 & TS mux

mdc_tof_mux: process(clk_300MHz)
begin
	if rising_edge(clk_300MHz) then
		
--		case tof_one_clock is									--multiplicity 2 detector
		case ecl(14 downto 9) is									--multiplicity 2 detector
			when "000011"	=> tof_mult_2 <= '1';
			when "000101"	=> tof_mult_2 <= '1';
			when "001001"	=> tof_mult_2 <= '1';
			when "010001"	=> tof_mult_2 <= '1';
			when "100001"	=> tof_mult_2 <= '1';
			when "000110"	=> tof_mult_2 <= '1';
			when "001010"	=> tof_mult_2 <= '1';
			when "010010"	=> tof_mult_2 <= '1';
			when "100010"	=> tof_mult_2 <= '1';
			when "001100"	=> tof_mult_2 <= '1';
			when "010100"	=> tof_mult_2 <= '1';
			when "100100"	=> tof_mult_2 <= '1';
			when "011000"	=> tof_mult_2 <= '1';
			when "101000"	=> tof_mult_2 <= '1';
			when "110000"	=> tof_mult_2 <= '1';
			when others		=>	tof_mult_2 <= '0';
		end case;
	
		case PTI5_TS_ALTERNATIVE(4) is
			when '0' 		=> pti5_mux <= PTI5_ONE_CLOCK;
			when '1' 		=> pti5_mux <= tof_mult_2_one;
			when others 	=> pti5_mux <= 'X';			
		end case;

		case PTI5_TS_ALTERNATIVE(0) is
			when '0' 		=> ts_mux <= TS_ONE_CLOCK;
			when '1' 		=> ts_mux <= tof_or;
			when others 	=> ts_mux <= 'X';		
		end case;
	end if;
end process mdc_tof_mux;

--------------MDC & TOF scaler mux

pti5_ts_mux: process(clk_300MHz)
begin
	if rising_edge(clk_300MHz) then
		case SCALER_MDC_TOF_SELECT(7 downto 4) is
			when x"0" 		=> mdc_mux <= mdc_s1(0);
			when x"1" 		=> mdc_mux <= mdc_s1(1);
			when x"2" 		=> mdc_mux <= mdc_s1(2);
			when x"3" 		=> mdc_mux <= mdc_s1(3);
			when x"4" 		=> mdc_mux <= mdc_s1(4);
			when x"5" 		=> mdc_mux <= mdc_s1(5);
			when others 	=> mdc_mux <= '0';			
		end case;

		case SCALER_MDC_TOF_SELECT(3 downto 0) is
			when x"0" 		=> tof_mux <= tof_one_clock(0);
			when x"1" 		=> tof_mux <= tof_one_clock(1);
			when x"2" 		=> tof_mux <= tof_one_clock(2);
			when x"3" 		=> tof_mux <= tof_one_clock(3);
			when x"4" 		=> tof_mux <= tof_one_clock(4);
			when x"5" 		=> tof_mux <= tof_one_clock(5);
			when others 	=> tof_mux <= '0';			
		end case;
	end if;
end process pti5_ts_mux; 			

-------------- TOF & MDC logic

tof_mdc_logic: process(clk_300Mhz)
begin
  if rising_edge(clk_300MHz) then
    
    mdc_s <= ECL(6 downto 1);
    tof_s <= ECL(14 downto 9);
    mdc_s1 <= mdc_s;
    tof_s1 <= tof_s;								
  
    mdc_tof_or <= (((tof_del(0) and not mdc_s1(0)) or (tof_del(1) and not mdc_s1(1)) or
                  (tof_del(2) and not mdc_s1(2)) or (tof_del(3) and not mdc_s1(3)) or
                  (tof_del(4) and not mdc_s1(4)) or (tof_del(5) and not mdc_s1(5)))
                   and BRANCH_EN_with_MDC_TOF_WIDTH(4));
									  
    tof_or <= (ecl(9) or ecl(10) or ecl(11) or ecl(12) or ecl(13) or ecl(14));

	end if;
end process tof_mdc_logic;

-------------- Final AND-OR logic function

logic: process(clk_300MHz)
begin
	if rising_edge(clk_300MHz) then
	
			--------------------------------------		GATE SELECT SINGLE

		PTI1_and_GTS <= ((PTI1_READY and (TS_DELAYED and not VS_WIDTH_SET) and mdc_tof_trigger_width_set and not TS_GATING_DISABLE(1))
									or (PTI1_SELF_COIN and TS_GATING_DISABLE(1)));
		PTI2_and_GTS <= ((PTI2_READY and (TS_DELAYED and not VS_WIDTH_SET) and mdc_tof_trigger_width_set and not TS_GATING_DISABLE(2))
									or (PTI2_SELF_COIN and TS_GATING_DISABLE(2)));
		PTI3_and_GTS <= ((PTI3_READY and (TS_DELAYED and not VS_WIDTH_SET) and mdc_tof_trigger_width_set and not TS_GATING_DISABLE(3))
									or (PTI3_SELF_COIN and TS_GATING_DISABLE(3)));
		PTI4_and_GTS <= ((PTI4_READY and (TS_DELAYED and not VS_WIDTH_SET) and mdc_tof_trigger_width_set and not TS_GATING_DISABLE(4))
									or (PTI4_SELF_COIN and TS_GATING_DISABLE(4)));
		PTI5_and_GTS <= ((PTI5_READY and (TS_DELAYED and not VS_WIDTH_SET) and mdc_tof_trigger_width_set and not TS_GATING_DISABLE(5))
									or (PTI5_SELF_COIN and TS_GATING_DISABLE(5)));

		OR_out <=	(PTI1_and_GTS and OR_ON_OFF(0)) or			
						(PTI2_and_GTS and OR_ON_OFF(1)) or
						(PTI3_and_GTS and OR_ON_OFF(2)) or
						(PTI4_and_GTS and OR_ON_OFF(3)) or
						(PTI5_and_GTS and OR_ON_OFF(4)) or
						(TS_READY and OR_ON_OFF(5)) or
						(VS_READY and OR_ON_OFF(6)) or
						(CLOCK_READY and OR_ON_OFF(7));
						
		lemin_s <= LEMIN;
		lemin_s1 <=  lemin_s;
		dtu_bus_tb_s <= not hpv(8);																--dtu trigger busy
		
		dead <= TS_DELAYED and (not out_inhibit);
																								
		out_inhibit <= lemin_s1(0) or beam_inhibit or bus_inhibit or dtu_inhibit;--
                --or dtu_bus_tb_s;--
                --or (not com_run);
                TIN(9) <= cal_trigger;
		GLOBAL_TIMING_SIGNAL_OUT <= (OR_out and (not out_inhibit) and (not cal_inhibit));
--                and not out_inhibit) or (OR_out and (not out_inhibit) and (not cal_inhibit));    
		GTS_to_databus <= OR_out and not out_inhibit and not cal_inhibit;

		
	end if;
end process logic;
DEBUG_REG_00(31 downto 29) <= OR_out & out_inhibit & cal_inhibit;
DEBUG_REG_00(28 downto 24) <= lemin_s1(0) & beam_inhibit & bus_inhibit & dtu_inhibit & dtu_bus_tb_s;
---------------- Outputs

assign: process(clk_300MHz)
begin
	if rising_edge(clk_300MHz) then
		
		eco_s(1)  <=	PTI1_DELAYED;														-- Latches before downscale
		eco_s(2)  <=	PTI2_DELAYED;
		eco_s(3)  <=	PTI3_DELAYED;
		eco_s(4)  <=	PTI4_DELAYED;
		eco_s(5)  <=	PTI5_DELAYED;
		eco_s(6)  <=	TS_DELAYED;
		eco_s(7)  <=	VS_DELAYED;
--		ECO(8) is mux 0
		eco_s(9)  <=	(OR_ON_OFF(0) and ((PTI1_DOWNSCALED and TS_GATING_DISABLE(1))
                                                   or (PTI1_and_GTS and not TS_GATING_DISABLE(1))));
		eco_s(10) <=	(OR_ON_OFF(1) and ((PTI2_DOWNSCALED and TS_GATING_DISABLE(2))
                                                   or (PTI2_and_GTS and not TS_GATING_DISABLE(2))));
		eco_s(11) <=	(OR_ON_OFF(2) and ((PTI3_DOWNSCALED and TS_GATING_DISABLE(3))
                                                   or (PTI3_and_GTS and not TS_GATING_DISABLE(3))));
		eco_s(12) <=	(OR_ON_OFF(3) and ((PTI4_DOWNSCALED and TS_GATING_DISABLE(4))
                                                   or (PTI4_and_GTS and not TS_GATING_DISABLE(4))));
		eco_s(13) <=	(OR_ON_OFF(4) and ((PTI5_DOWNSCALED and TS_GATING_DISABLE(5))
                                                   or (PTI5_and_GTS and not TS_GATING_DISABLE(5))));

		eco_s(14) <=	TS_READY and OR_ON_OFF(5);
		eco_s(15) <=	VS_READY and OR_ON_OFF(6);
--		ECO(16) is mux 1

----------------- Multiplexers

	case MUX_SELECTOR_1 is		--0x5c										
				
			when  "0000"	=>	mux_out(0) <=	PTI1_DELAYED;		--0
			when  "0001"	=>	mux_out(0) <=	PTI2_DELAYED;	
			when  "0010"	=>	mux_out(0) <=	PTI3_DELAYED;		--2	
			when  "0011"	=>	mux_out(0) <=	PTI4_DELAYED;	
			when  "0100"	=>	mux_out(0) <=	PTI5_DELAYED;		--4	
			when  "0101"	=>	mux_out(0) <=	TS_DELAYED;
			when  "0110"	=>	mux_out(0) <=	VS_DELAYED;			--6
			when  "0111"	=>	mux_out(0) <=	PTI1_and_GTS;
			when  "1000"	=>	mux_out(0) <=	PTI2_and_GTS;		--8	
			when  "1001"	=>	mux_out(0) <=	PTI3_and_GTS;
			when  "1010"	=>	mux_out(0) <=	PTI4_and_GTS;		--a
			when  "1011"	=>	mux_out(0) <=	PTI5_and_GTS;
			when  "1100"	=>	mux_out(0) <=	TS_READY;			--c
			when  "1101"	=>	mux_out(0) <=	VS_READY;
			when  "1110"	=>	mux_out(0) <=	OR_out;				--e
			when	"1111"	=>	mux_out(0) <= 	GLOBAL_TIMING_SIGNAL_OUT;
			when others						=> mux_out(0) <=	'X';

	end case;
	

	case MUX_SELECTOR_2 is		--0x60										
		
			when  "0000"	=>	mux_out(1) <=		PTI1_DELAYED;								--0		
			when  "0001"	=>	mux_out(1) <=		PTI2_DELAYED;	
			when  "0010"	=>	mux_out(1) <=		PTI3_DELAYED;								--2	
			when  "0011"	=>	mux_out(1) <=		PTI4_DELAYED;	
			when  "0100"	=>	mux_out(1) <=		PTI5_DELAYED;								--4	
			when  "0101"	=>	mux_out(1) <=		TS_DELAYED;
			when  "0110"	=>	mux_out(1) <=		VS_DELAYED;									--6		
			when  "0111"	=>	mux_out(1) <=tof_mux;						--PTI1_READY;
			when  "1000"	=>	mux_out(1) <='0';		--PTI2_READY;	--8	
			when  "1001"	=>	mux_out(1) <='0';				--PTI3_READY;
			when  "1010"	=>	mux_out(1) <='0';			--PTI4_READY;	--a
			when  "1011"	=>	mux_out(1) <=mdc_tof_trigger_width_set;--PTI5_READY;
			when  "1100"	=>	mux_out(1) <=		TS_READY;									--c		
			when  "1101"	=>	mux_out(1) <=		VS_READY;											
			when  "1110"	=>	mux_out(1) <=		CLOCK_READY;								--e
			when	"1111"	=> mux_out(1) <=mdc_mux;						--VS_WIDTH_SET;
			when others		=> mux_out(1) <=	'X';

	end case;

	end if;
end process assign;

end RTL;
