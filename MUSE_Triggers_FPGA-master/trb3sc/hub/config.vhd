library ieee;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.trb_net_std.all;
use work.trb_net16_hub_func.all;

package config is


------------------------------------------------------------------------------
--Begin of design configuration
------------------------------------------------------------------------------

--design options: backplane or front SFP, with or without GBE
    constant USE_BACKPLANE : integer := c_YES;
    constant INCLUDE_GBE   : integer := c_NO;

--Runs with 120 MHz instead of 100 MHz     
    constant USE_120_MHZ            : integer := c_NO; 
    constant USE_200MHZOSCILLATOR   : integer := c_YES;
    constant USE_EXTERNAL_CLOCK     : integer := c_YES; --'no' not implemented.
    constant CLOCK_FAST_SELECT      : integer := c_NO; --fast clock select (135us) or slow (280ms)?
    
--Use sync mode, RX clock for all parts of the FPGA
    constant USE_RXCLOCK            : integer := c_NO;
   
--Address settings   
    constant INIT_ADDRESS           : std_logic_vector := x"F3CD";
    
   

    constant INCLUDE_UART           : integer  := c_YES;
    constant INCLUDE_SPI            : integer  := c_YES;
    constant INCLUDE_LCD            : integer  := c_NO;
    constant INCLUDE_DEBUG_INTERFACE: integer  := c_YES;

    --input monitor and trigger generation logic
    constant INCLUDE_TRIGGER_LOGIC  : integer  := c_NO;
    constant INCLUDE_STATISTICS     : integer  := c_NO;
    constant TRIG_GEN_INPUT_NUM     : integer  := 0;
    constant TRIG_GEN_OUTPUT_NUM    : integer  := 0;
    constant MONITOR_INPUT_NUM      : integer  := 0;    
    
------------------------------------------------------------------------------
--End of design configuration
------------------------------------------------------------------------------

  type data_t is array (0 to 1023) of std_logic_vector(7 downto 0);
  constant LCD_DATA : data_t := (
      x"36",x"48",x"3A",x"55",x"29",x"2A",x"00",x"00", --config don't touch
      x"00",x"EF",x"2B",x"00",x"00",x"01",x"3F",x"2C", --config don't touch
      x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00", --config don't touch
      x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00", --config don't touch
      
      x"48", x"75", x"62", x"41", x"64", x"64", x"4f", x"6e", x"0a",
      x"0a",
      x"41", x"64", x"64", x"72", x"65", x"73", x"73", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"80",                     x"0a",                            
      x"43", x"6f", x"6d", x"70", x"69", x"6c", x"65", x"54", x"69", x"6d", x"65", x"20", x"20", x"84",                      x"83",                     x"0a", 
      x"54", x"69", x"6d", x"65", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"82",                      x"81",                     x"0a",
      others => x"00");



--With GbE:
-- for MII_NUMBER=5 (4 downlinks, 1 uplink):
-- port 0,1,2,3: downlinks to other FPGA
-- port MII-1: LVL1/Data channel on uplink to CTS, but internal endpoint on SCTRL
-- port MII:   SCTRL channel on uplink to CTS
-- port MII+1: SCTRL channel from GbE interface

    type hub_mii_t is array(0 to 3) of integer;    
    type hub_ct    is array(0 to 16) of integer;
    type hub_cfg_t is array(0 to 3) of hub_ct;    
    type hw_info_t is array(0 to 3) of std_logic_vector(31 downto 0);
    type intlist_t is array(0 to 7) of integer;


    --order: no backplane, no GBE  8x AddOn, SFP downlink, SFP uplink
    --          backplane, no GBE  8x AddOn, 2x SFP downlink, backplane uplink
    --       no backplane,    GBE  7x AddOn, 1x SFP uplink, GBE sctrl
    --          backplane,    GBE  8x AddOn, backplane uplink, GBE sctrl
    
    constant INTERFACE_NUM_ARR    : hub_mii_t := (10,11,8,9);
--                                                 0 1 2 3 4 5 6 7 8 9 a b c d e f 
    constant IS_UPLINK_ARR        : hub_cfg_t := ((0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0),  
                                                  (0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0),  
                                                  (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0),  
                                                  (0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0));
    constant IS_DOWNLINK_ARR      : hub_cfg_t := ((1,1,1,1,1,1,1,1,1,0,1,0,0,0,0,0,0),  
                                                  (1,1,1,1,1,1,1,1,1,1,0,1,0,0,0,0,0),  
                                                  (1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0),  
                                                  (1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0));
    constant IS_UPLINK_ONLY_ARR   : hub_cfg_t := ((0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0),  
                                                  (0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0),  
                                                  (0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0),  
                                                  (0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0)); 
                          
    constant INTERFACE_NUM        : integer;
    constant IS_UPLINK            : hub_ct;
    constant IS_DOWNLINK          : hub_ct;
    constant IS_UPLINK_ONLY       : hub_ct;
   
------------------------------------------------------------------------------
--Select settings by configuration 
------------------------------------------------------------------------------

    constant HW_INFO_BASE            : unsigned(31 downto 0) := x"9500A000";
    
    constant CLOCK_FREQUENCY_ARR  : intlist_t := (100,120, others => 0);
    constant MEDIA_FREQUENCY_ARR  : intlist_t := (200,240, others => 0);
                          
  --declare constants, filled in body                          
    constant HARDWARE_INFO        : std_logic_vector(31 downto 0);
    constant CLOCK_FREQUENCY      : integer;
    constant MEDIA_FREQUENCY      : integer;
    constant INCLUDED_FEATURES    : std_logic_vector(63 downto 0);
    constant BROADCAST_SPECIAL_ADDR : std_logic_vector;
    
end;

package body config is
--compute correct configuration mode
  
  constant HARDWARE_INFO        : std_logic_vector(31 downto 0) := std_logic_vector(
                                      HW_INFO_BASE );
  constant CLOCK_FREQUENCY      : integer := CLOCK_FREQUENCY_ARR(USE_120_MHZ);
  constant MEDIA_FREQUENCY      : integer := MEDIA_FREQUENCY_ARR(USE_120_MHZ);

  constant CFG_MODE : integer := INCLUDE_GBE*2 + USE_BACKPLANE;
  
  constant INTERFACE_NUM        : integer := INTERFACE_NUM_ARR(CFG_MODE);
  constant IS_UPLINK            : hub_ct  := IS_UPLINK_ARR(CFG_MODE);
  constant IS_DOWNLINK          : hub_ct  := IS_DOWNLINK_ARR(CFG_MODE);
  constant IS_UPLINK_ONLY       : hub_ct  := IS_UPLINK_ONLY_ARR(CFG_MODE); 
  constant BROADCAST_SPECIAL_ADDR : std_logic_vector := std_logic_vector(to_unsigned(100+CFG_MODE,8));
  
  
function generateIncludedFeatures return std_logic_vector is
  variable t : std_logic_vector(63 downto 0);
  begin
    t               := (others => '0');
    t(63 downto 56) := std_logic_vector(to_unsigned(1,8)); --table version 1
    if INCLUDE_GBE = c_YES then
      t(22 downto 16) := "0100111"; --sctrl via GbE
    end if;  
    t(23 downto 23) := std_logic_vector(to_unsigned(INCLUDE_GBE,1));
    t(27 downto 24) := std_logic_vector(to_unsigned(INTERFACE_NUM-USE_BACKPLANE,4)); --num SFPs with TrbNet
    t(28 downto 28) := std_logic_vector(to_unsigned(USE_BACKPLANE,1));
    t(40 downto 40) := std_logic_vector(to_unsigned(INCLUDE_LCD,1));
    t(42 downto 42) := std_logic_vector(to_unsigned(INCLUDE_SPI,1));
    t(43 downto 43) := std_logic_vector(to_unsigned(INCLUDE_UART,1));
    t(44 downto 44) := std_logic_vector(to_unsigned(INCLUDE_STATISTICS,1));
    t(51 downto 48) := std_logic_vector(to_unsigned(INCLUDE_TRIGGER_LOGIC,4));
    t(52 downto 52) := std_logic_vector(to_unsigned(USE_120_MHZ,1));
    t(53 downto 53) := std_logic_vector(to_unsigned(USE_RXCLOCK,1));
    t(54 downto 54) := std_logic_vector(to_unsigned(USE_EXTERNAL_CLOCK,1));
    t(55 downto 55) := std_logic_vector(to_unsigned(USE_200MHZOSCILLATOR,1));
    return t;
  end function;  

  constant INCLUDED_FEATURES : std_logic_vector(63 downto 0) := generateIncludedFeatures;    

end package body;
