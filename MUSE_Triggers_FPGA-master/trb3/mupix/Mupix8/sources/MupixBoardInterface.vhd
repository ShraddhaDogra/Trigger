----------------------------------------------------------------------------
-- Synchronize signals from mupix board
-- Tobias Weber
-- Ruhr Unversitaet Bochum
-----------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity MupixBoardInterface is
  port(
    clk_in              : in  std_logic;  --slow clock
    fast_clk_in         : in  std_logic;  --fast clock 
    reset               : in  std_logic;  --reset signal
    --input signals from mupix sensorboard
    ctrl_dout           :  in  std_logic; --serial data from mupix
    spi_dout_adc        :  in  std_logic; --adc serial data from board
    spi_dout_dac        :  in  std_logic; --dac serial data from board
    dac4_dout           :  in  std_logic; --serial data in from dac 4??
    hitbus              :  in  std_logic; --hitbus signal
    hit                 :  in  std_logic; --hit signal (replacement for priout?)
    trigger             :  in  std_logic; --external trigger
    --synchronized signals to FPGA logic
    ctrl_dout_sync      :  out std_logic;
    spi_dout_adc_sync   :  out std_logic;
    spi_dout_dac_sync   :  out std_logic;
    dac4_dout_sync      :  out std_logic;
    hitbus_sync         :  out std_logic;
    trigger_sync        :  out std_logic;
    hitbus_sync_fast    :  out std_logic; --sampled with 200 MHz clock
    trigger_sync_fast   :  out std_logic; --sampled with 200 MHz clock
    hit_sync            :  out std_logic);          
end entity MupixBoardInterface;


architecture rtl of MupixBoardInterface is


	component InputSynchronizer
		generic(depth : integer);
		port(
			clk         : in  std_logic;
			rst         : in  std_logic;
			input       : in  std_logic;
			sync_output : out std_logic
		);
	end component InputSynchronizer;
 	
begin

	sync_ctrl_dout : component InputSynchronizer
	    generic map(depth => 2)
		port map(clk_in, reset, ctrl_dout, ctrl_dout_sync);
		
	sync_spi_dout_adc : component InputSynchronizer
	    generic map(depth => 2)
		port map(clk_in, reset, spi_dout_adc, spi_dout_adc_sync);
		
	sync_spi_dout_dac : component InputSynchronizer
	    generic map(depth => 2)
		port map(clk_in, reset, spi_dout_dac, spi_dout_dac_sync);
		
	sync_dac4_dout : component InputSynchronizer
	    generic map(depth => 2)
		port map(clk_in, reset, dac4_dout, dac4_dout_sync);
		
	sync_hitbus : component InputSynchronizer
	    generic map(depth => 2)
		port map(clk_in, reset, hitbus, hitbus_sync);
		
	sync_trigger : component InputSynchronizer
	    generic map(depth => 2)
		port map(clk_in, reset, trigger, trigger_sync);
		
	sync_hit : component InputSynchronizer
	    generic map(depth => 2)
		port map(clk_in, reset, hit, hit_sync);
		
	sync_fast_hitbus : component InputSynchronizer
	    generic map(depth => 2)
		port map(fast_clk_in, reset, hitbus, hitbus_sync_fast);
		
	sync_fast_trigger : component InputSynchronizer
	    generic map(depth => 2)
		port map(fast_clk_in, reset, trigger, trigger_sync_fast);	
  
end architecture rtl;
