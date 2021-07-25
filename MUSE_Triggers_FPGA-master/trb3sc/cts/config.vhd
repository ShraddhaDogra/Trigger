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
    constant USE_BACKPLANE : integer := c_NO;
    constant USE_ADDON     : integer := c_YES;
    constant INCLUDE_GBE   : integer := c_YES;  --c_NO doesn't work

--Runs with 120 MHz instead of 100 MHz     
    constant USE_120_MHZ            : integer := c_NO; 
    constant USE_200MHZOSCILLATOR   : integer := c_YES;
    constant USE_EXTERNAL_CLOCK     : integer := c_YES; --'no' not implemented.
    constant CLOCK_FAST_SELECT      : integer := c_YES; --fast clock select (135us) or slow (280ms)?
    
--Use sync mode, RX clock for all parts of the FPGA
    constant USE_RXCLOCK            : integer := c_NO;
   
--Address settings   
    constant INIT_ADDRESS           : std_logic_vector := x"F3C0";
    constant BROADCAST_SPECIAL_ADDR : std_logic_vector := x"62";  --62 for SFP, 63 for backplane
   

    constant INCLUDE_UART           : integer  := c_YES;
    constant INCLUDE_SPI            : integer  := c_YES;
    constant INCLUDE_LCD            : integer  := c_NO;
    constant INCLUDE_DEBUG_INTERFACE: integer  := c_YES;

    --input monitor and trigger generation logic
    constant INCLUDE_TDC            : integer  := c_YES;
    constant INCLUDE_TRIGGER_LOGIC  : integer  := c_NO;
    constant INCLUDE_STATISTICS     : integer  := c_YES;
    constant TRIG_GEN_INPUT_NUM     : integer  := 0;
    constant TRIG_GEN_OUTPUT_NUM    : integer  := 0;
    constant MONITOR_INPUT_NUM      : integer  := 32;    

    
    constant FPGA_TYPE               : integer  := 3;  --3: ECP3, 5: ECP5
    constant PINOUT   : integer := 2;
    -- 0: KEL on board
    -- 1: Canadian
    constant NUM_TDC_MODULES         : integer range 1 to 4  := 1;  -- number of tdc modules to implement
    constant NUM_TDC_CHANNELS        : integer range 1 to 65 := 12; -- number of tdc channels per module
    constant NUM_TDC_CHANNELS_POWER2 : integer range 0 to 6  := 4;  --the nearest power of two, for convenience reasons 
    constant DOUBLE_EDGE_TYPE        : integer range 0 to 3  := 3;  --double edge type:  0, 1, 2,  3
    -- 0: single edge only,
    -- 1: same channel,
    -- 2: alternating channels,
    -- 3: same channel with stretcher
    constant RING_BUFFER_SIZE        : integer range 0 to 7  := 7;  --ring buffer size:  0, 1, 2,  3,  7   --> change names in constraints file
                                                                    --ring buffer size: 32,64,96,128,dyn
    constant TDC_DATA_FORMAT         : integer := 0;                                                                  

    constant EVENT_BUFFER_SIZE       : integer range 9 to 13 := 13; -- size of the event buffer, 2**N
    constant EVENT_MAX_SIZE          : integer := 1023;             --maximum event size. Should not exceed 
    
    constant GEN_BUSY_OUTPUT : integer := c_NO;
    
    constant TRIGGER_COIN_COUNT      : integer := 1;
    constant TRIGGER_PULSER_COUNT    : integer := 3;
    constant TRIGGER_RAND_PULSER     : integer := 1;
    constant TRIGGER_ADDON_COUNT     : integer := 2;
    constant PERIPH_TRIGGER_COUNT    : integer := 0;      
    constant ADDON_LINE_COUNT        : integer := 18;    
    constant CTS_OUTPUT_MULTIPLEXERS : integer := 1;
--TODO:    
--     constant INCLUDE_MBS_MASTER : integer range c_NO to c_YES := c_NO; 
--Which external trigger module (ETM) to use?
--     constant INCLUDE_ETM : integer range c_NO to c_YES := c_NO;
--     type ETM_CHOICE_type is (ETM_CHOICE_MBS_VULOM, ETM_CHOICE_MAINZ_A2, ETM_CHOICE_CBMNET, ETM_CHOICE_M26);
--     constant ETM_CHOICE : ETM_CHOICE_type := ETM_CHOICE_MBS_VULOM;
--     constant ETM_ID : std_logic_vector(7 downto 0);

   constant INCLUDE_TIMESTAMP_GENERATOR : integer := c_YES;
    
    
    
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


    type hub_mii_t is array(0 to 3) of integer;    
    type hub_ct    is array(0 to 16) of integer;
    type hub_cfg_t is array(0 to 3) of hub_ct;    
    type hw_info_t is array(0 to 3) of std_logic_vector(31 downto 0);
    type intlist_t is array(0 to 7) of integer;
--  0     opt. link      opt. link
--  1-8   SFP 1-4
--  1(9)  CTS read-out   internal         0 1 -   X X O   --downlink only
--  2(10)  CTS TRG        Sctrl GbE        2 3 4   X X X   --uplink only

    --Order:
    --       no backplane, no AddOn, 1x SFP, 1x GBE
    --       no backplane, 4x AddOn, 1x SFP, 1x GBE
-- -- --     --       no backplane, 8x AddOn, 1x SFP, 1x GBE
    --          backplane,           9x backplane, 1x GBE
    constant SFP_NUM_ARR    : hub_mii_t := (1,5,0,0);    
    constant INTERFACE_NUM_ARR    : hub_mii_t := (1,5,9,10);
--                                                 0 1 2 3 4 5 6 7 8 9 a b c d e f 
    constant IS_UPLINK_ARR        : hub_cfg_t := ((0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
                                                  (0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0),  
--                                                   (0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0),  
                                                  (0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0),
                                                  (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
    constant IS_DOWNLINK_ARR      : hub_cfg_t := ((1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),     
                                                  (1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0),  
--                                                   (1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0),  
                                                  (1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0),
                                                  (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
    constant IS_UPLINK_ONLY_ARR   : hub_cfg_t := ((0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
                                                  (0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0),  
                                                  (0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0),  
--                                                   (0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0),  
                                                  (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)); 
                          
    constant INTERFACE_NUM        : integer;
    constant IS_UPLINK            : hub_ct;
    constant IS_DOWNLINK          : hub_ct;
    constant IS_UPLINK_ONLY       : hub_ct;
   
------------------------------------------------------------------------------
--Select settings by configuration 
------------------------------------------------------------------------------
    constant cts_rdo_additional_ports : integer := INCLUDE_TDC + INCLUDE_TIMESTAMP_GENERATOR; --for TDC
    
    constant HW_INFO_BASE            : unsigned(31 downto 0) := x"9500A000";
    
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

  constant CFG_MODE : integer := USE_ADDON;--*2 + USE_BACKPLANE;
  
  constant INTERFACE_NUM        : integer := INTERFACE_NUM_ARR(CFG_MODE);
  constant IS_UPLINK            : hub_ct  := IS_UPLINK_ARR(CFG_MODE);
  constant IS_DOWNLINK          : hub_ct  := IS_DOWNLINK_ARR(CFG_MODE);
  constant IS_UPLINK_ONLY       : hub_ct  := IS_UPLINK_ONLY_ARR(CFG_MODE); 

--   function etm_id_func return std_logic_vector is
--    variable res : unsigned(7 downto 0);
--   begin
--    res := x"00";
--    if INCLUDE_ETM=c_YES then
--       res := x"60";
--       res := res + TO_UNSIGNED(ETM_CHOICE_type'pos(ETM_CHOICE), 4);
--    end if;
--    return std_logic_vector(res);
--   end function;
  
  constant ETM_ID : std_logic_vector(7 downto 0) := x"00";--etm_id_func;
   
  
function generateIncludedFeatures return std_logic_vector is
  variable t : std_logic_vector(63 downto 0);
  begin
    t               := (others => '0');
    t(63 downto 56) := std_logic_vector(to_unsigned(1,8)); --table version 1
    t(3 downto 0)   := x"0"; --std_logic_vector(TO_UNSIGNED(ETM_CHOICE_type'pos(ETM_CHOICE), 4));
    t(11 downto 8)  := std_logic_vector(to_unsigned(DOUBLE_EDGE_TYPE,4));
    t(14 downto 12) := std_logic_vector(to_unsigned(RING_BUFFER_SIZE,3));
    t(15 downto 15) := std_logic_vector(to_unsigned(INCLUDE_TDC,1)); --TDC
    t(16 downto 16) := std_logic_vector(to_unsigned(INCLUDE_GBE,1)); --data via GbE
    t(17 downto 17) := std_logic_vector(to_unsigned(INCLUDE_GBE,1)); --sctrl via GbE
    t(23 downto 23) := std_logic_vector(to_unsigned(INCLUDE_GBE,1));
    t(26 downto 24) := std_logic_vector(to_unsigned(SFP_NUM_ARR(CFG_MODE),3)); --num SFPs with TrbNet
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
