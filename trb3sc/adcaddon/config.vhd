library ieee;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.trb_net_std.all;

package config is


------------------------------------------------------------------------------
--Begin of design configuration
------------------------------------------------------------------------------

--Runs with 120 MHz instead of 100 MHz     
    constant USE_120_MHZ            : integer := c_NO; 
    constant USE_EXTERNAL_CLOCK     : integer := c_NO;
    constant CLOCK_FAST_SELECT        : integer := c_NO; --fast clock select (135us) or slow (280ms)?
    
--Use sync mode, RX clock for all parts of the FPGA
    constant USE_RXCLOCK            : integer := c_NO;
   
--Address settings   
    constant INIT_ADDRESS           : std_logic_vector := x"F3CC";
    constant BROADCAST_SPECIAL_ADDR : std_logic_vector := x"68";
   
--set to 0 for backplane serdes, set to 3 for front SFP serdes
    constant SERDES_NUM             : integer := 3;
   
    constant INCLUDE_UART           : integer  := c_YES;
    constant INCLUDE_SPI            : integer  := c_YES;
    constant INCLUDE_LCD            : integer  := c_YES;
    constant INCLUDE_DEBUG_INTERFACE: integer  := c_NO;
   
    --input monitor and trigger generation logic
    constant INCLUDE_TRIGGER_LOGIC  : integer  := c_NO;
    constant INCLUDE_STATISTICS     : integer  := c_NO;
    constant TRIG_GEN_INPUT_NUM     : integer  := 18;
    constant TRIG_GEN_OUTPUT_NUM    : integer  := 4;
    constant MONITOR_INPUT_NUM      : integer  := 22;

    constant USE_DUMMY_READOUT      : integer := c_NO;  --use slowcontrol for readout, no trigger logic
    
--ADC sampling frequency (only 40 MHz supported a.t.m.)
    constant ADC_SAMPLING_RATE      : integer := 40;
    
--These are currently used for the included features table only
    constant ADC_PROCESSING_TYPE    : integer := 0;
    constant ADC_BASELINE_LOGIC     : integer := c_YES;
    constant ADC_TRIGGER_LOGIC      : integer := c_YES;
    constant ADC_CHANNELS           : integer := 48;
    
------------------------------------------------------------------------------
--End of design configuration
------------------------------------------------------------------------------

  type data_t is array (0 to 1023) of std_logic_vector(7 downto 0);
  constant LCD_DATA : data_t := (
      x"36",x"48",x"3A",x"55",x"29",x"2A",x"00",x"00", --config don't touch
      x"00",x"EF",x"2B",x"00",x"00",x"01",x"3F",x"2C", --config don't touch
      x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00", --config don't touch
      x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00", --config don't touch
      
      x"54", x"72", x"62", x"33", x"73", x"63", x"0a",
      x"0a",
      x"41", x"64", x"64", x"72", x"65", x"73", x"73", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"80",                     x"0a",                            
      x"43", x"6f", x"6d", x"70", x"69", x"6c", x"65", x"54", x"69", x"6d", x"65", x"20", x"20", x"84",                      x"83",                     x"0a", 
      x"54", x"69", x"6d", x"65", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"82",                      x"81",                     x"0a",
      others => x"00");


------------------------------------------------------------------------------
--Select settings by configuration 
------------------------------------------------------------------------------
    type intlist_t is array(0 to 7) of integer;
    type hw_info_t is array(0 to 7) of unsigned(31 downto 0);
    constant HW_INFO_BASE            : unsigned(31 downto 0) := x"95009000";
    
    constant CLOCK_FREQUENCY_ARR  : intlist_t := (100,120, others => 0);
    constant MEDIA_FREQUENCY_ARR  : intlist_t := (200,240, others => 0);
                          
  --declare constants, filled in body                          
    constant HARDWARE_INFO        : std_logic_vector(31 downto 0);
    constant CLOCK_FREQUENCY      : integer;
    constant MEDIA_FREQUENCY      : integer;
    constant INCLUDED_FEATURES      : std_logic_vector(63 downto 0);
    
    
end;

package body config is
--compute correct configuration mode
  
  constant HARDWARE_INFO        : std_logic_vector(31 downto 0) := std_logic_vector(
                                      HW_INFO_BASE );
  constant CLOCK_FREQUENCY      : integer := CLOCK_FREQUENCY_ARR(USE_120_MHZ);
  constant MEDIA_FREQUENCY      : integer := MEDIA_FREQUENCY_ARR(USE_120_MHZ);

  
  
function generateIncludedFeatures return std_logic_vector is
  variable t : std_logic_vector(63 downto 0);
begin
  t               := (others => '0');
  t(63 downto 56) := std_logic_vector(to_unsigned(4,8)); --table version 4
  t(7 downto 0)   := std_logic_vector(to_unsigned(ADC_SAMPLING_RATE,8));
  t(11 downto 8)  := std_logic_vector(to_unsigned(ADC_PROCESSING_TYPE,4)); --processing type
  t(14 downto 14) := std_logic_vector(to_unsigned(ADC_BASELINE_LOGIC,1));
  t(15 downto 15) := std_logic_vector(to_unsigned(ADC_TRIGGER_LOGIC,1));
  t(23 downto 16) := std_logic_vector(to_unsigned(ADC_CHANNELS,8));
  t(40 downto 40) := std_logic_vector(to_unsigned(INCLUDE_LCD,1));
  t(42 downto 42) := std_logic_vector(to_unsigned(INCLUDE_SPI,1));
  t(43 downto 43) := std_logic_vector(to_unsigned(INCLUDE_UART,1));
  t(51 downto 48) := std_logic_vector(to_unsigned(INCLUDE_TRIGGER_LOGIC,4));
  t(52 downto 52) := std_logic_vector(to_unsigned(USE_120_MHZ,1));
  t(53 downto 53) := std_logic_vector(to_unsigned(USE_RXCLOCK,1));
  t(54 downto 54) := std_logic_vector(to_unsigned(USE_EXTERNAL_CLOCK,1));
  return t;
end function;  

  constant INCLUDED_FEATURES : std_logic_vector(63 downto 0) := generateIncludedFeatures;    

end package body;
