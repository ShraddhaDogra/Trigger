library ieee;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.trb_net_std.all;
use work.trb_net16_hub_func.all;

package config is


------------------------------------------------------------------------------
--Begin of design configuration
------------------------------------------------------------------------------

--Runs with 120 MHz instead of 100 MHz     
    constant USE_120_MHZ            : integer := c_NO; 
    constant USE_200MHZOSCILLATOR   : integer := c_YES;
    constant USE_EXTERNAL_CLOCK     : integer := c_YES; --'no' not implemented.
    constant CLOCK_FAST_SELECT      : integer := c_YES; --fast clock select (135us) or slow (280ms)?
    
--Use sync mode, RX clock for all parts of the FPGA
    constant USE_RXCLOCK            : integer := c_NO;
   
--Address settings   
    constant INIT_ADDRESS           : std_logic_vector := x"F3CE";
    constant BROADCAST_SPECIAL_ADDR : std_logic_vector := x"61"; --61 with GbE, 60 without
   

    constant INCLUDE_UART           : integer  := c_YES;
    constant INCLUDE_SPI            : integer  := c_YES;
    constant INCLUDE_LCD            : integer  := c_NO;
    constant INCLUDE_DEBUG_INTERFACE: integer  := c_YES;
    
    --input monitor and trigger generation logic
    constant INCLUDE_TRIGGER_LOGIC  : integer  := c_YES;
    constant INCLUDE_STATISTICS     : integer  := c_YES;
    constant TRIG_GEN_INPUT_NUM     : integer  := 18;
    constant TRIG_GEN_OUTPUT_NUM    : integer  := 4;
    constant MONITOR_INPUT_NUM      : integer  := 22;

    constant INCLUDE_GBE            : integer  := c_NO;

    
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
      x"55", x"49", x"44", x"20", x"20", x"89",                      x"88",                      x"87",                      x"86",                     x"0a", 
      x"43", x"6f", x"6d", x"70", x"69", x"6c", x"65", x"54", x"69", x"6d", x"65", x"20", x"20", x"84",                      x"83",                     x"0a", 
      x"54", x"69", x"6d", x"65", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"82",                      x"81",                     x"0a",
      x"54", x"65", x"6d", x"70", x"65", x"72", x"61", x"74", x"75", x"72", x"65", x"20", x"20", x"20", x"20", x"20", x"20", x"85",                     x"0a",
      others => x"00");



    type hub_mii_t is array(0 to 1) of integer;    
    type hub_ct    is array(0 to 16) of integer;
    type hub_cfg_t is array(0 to 1) of hub_ct;


--With GbE:
-- for MII_NUMBER=10
-- port 0-8: downlinks to other FPGA
-- port 9: LVL1/Data channel on uplink to CTS, but internal endpoint on SCTRL
-- port 10: SCTRL channel on uplink to CTS
-- port 11: SCTRL channel from GbE interface

--Without GbE:
-- for MII_NUMBER=11
-- port 0-8: downlinks to other FPGA
-- port 9: SFP2 (outer) slow control
-- port 10: SFP1 (inner) trigger
-- port 11: internal sctrl

  constant INTERFACE_NUM_ARR    : hub_mii_t := (11,10);
  constant IS_UPLINK_ARR        : hub_cfg_t := ((0,0,0,0,0,0,0,0,0, 1,1,0,0,0,0,0,0),  
                                                (0,0,0,0,0,0,0,0,0, 1,1,1,0,0,0,0,0));
  constant IS_DOWNLINK_ARR      : hub_cfg_t := ((1,1,1,1,1,1,1,1,1, 0,1,1,0,0,0,0,0),  
                                                (1,1,1,1,1,1,1,1,1, 1,0,0,0,0,0,0,0));
  constant IS_UPLINK_ONLY_ARR   : hub_cfg_t := ((0,0,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0),
                                                (0,0,0,0,0,0,0,0,0, 0,1,1,0,0,0,0,0));

                                                
  constant INTERFACE_NUM        : integer;
  constant MII_IS_UPLINK            : hub_ct;
  constant MII_IS_DOWNLINK          : hub_ct;
  constant MII_IS_UPLINK_ONLY       : hub_ct;
  
------------------------------------------------------------------------------
--Select settings by configuration 
------------------------------------------------------------------------------
    type intlist_t is array(0 to 7) of integer;
    type hw_info_t is array(0 to 7) of unsigned(31 downto 0);
    constant HW_INFO_BASE            : unsigned(31 downto 0) := x"95000000";
    
    constant CLOCK_FREQUENCY_ARR  : intlist_t := (100,120, others => 0);
    constant MEDIA_FREQUENCY_ARR  : intlist_t := (200,240, others => 0);
                          
  --declare constants, filled in body                          
    constant HARDWARE_INFO        : std_logic_vector(31 downto 0);
    constant CLOCK_FREQUENCY      : integer;
    constant MEDIA_FREQUENCY      : integer;
    constant INCLUDED_FEATURES    : std_logic_vector(63 downto 0);
    
    
end;

package body config is
--compute correct configuration mode
  
  constant HARDWARE_INFO        : std_logic_vector(31 downto 0) := std_logic_vector(
                                      HW_INFO_BASE );
  constant CLOCK_FREQUENCY      : integer := CLOCK_FREQUENCY_ARR(USE_120_MHZ);
  constant MEDIA_FREQUENCY      : integer := MEDIA_FREQUENCY_ARR(USE_120_MHZ);
  
  constant CFG_MODE             : integer := INCLUDE_GBE;
  constant INTERFACE_NUM        : integer := INTERFACE_NUM_ARR(CFG_MODE);
  constant MII_IS_UPLINK            : hub_ct  := IS_UPLINK_ARR(CFG_MODE);
  constant MII_IS_DOWNLINK          : hub_ct  := IS_DOWNLINK_ARR(CFG_MODE);
  constant MII_IS_UPLINK_ONLY       : hub_ct  := IS_UPLINK_ONLY_ARR(CFG_MODE); 
    

function generateIncludedFeatures return std_logic_vector is
  variable t : std_logic_vector(63 downto 0);
  begin
    t               := (others => '0');
    t(63 downto 56) := std_logic_vector(to_unsigned(1,8)); --table version 1
--     t(16 downto 16) := std_logic_vector(to_unsigned(USE_ETHERNET,1));
    if INCLUDE_GBE = c_YES then
      t(22 downto 16) := "0100111"; --sctrl via GbE
    end if;  
    t(23 downto 23) := std_logic_vector(to_unsigned(INCLUDE_GBE,1));
    t(28 downto 28) := std_logic_vector(to_unsigned(1,1));
    t(27 downto 24) := std_logic_vector(to_unsigned(2-INCLUDE_GBE,4)); --num SFPs with TrbNet
    t(40 downto 40) := std_logic_vector(to_unsigned(INCLUDE_LCD,1));
    t(42 downto 42) := std_logic_vector(to_unsigned(INCLUDE_SPI,1));
    t(43 downto 43) := std_logic_vector(to_unsigned(INCLUDE_UART,1));
    t(44 downto 44) := std_logic_vector(to_unsigned(INCLUDE_STATISTICS,1));
    t(51 downto 48) := std_logic_vector(to_unsigned(INCLUDE_TRIGGER_LOGIC,4));
    t(52 downto 52) := std_logic_vector(to_unsigned(USE_120_MHZ,1));
    t(53 downto 53) := std_logic_vector(to_unsigned(USE_RXCLOCK,1));
    t(54 downto 54) := std_logic_vector(to_unsigned(USE_EXTERNAL_CLOCK,1));
    return t;
  end function;  

  constant INCLUDED_FEATURES : std_logic_vector(63 downto 0) := generateIncludedFeatures;    

end package body;
