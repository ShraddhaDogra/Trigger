library ieee;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.trb_net_std.all;

package config is
------------------------------------------------------------------------------
--Begin of configuration
------------------------------------------------------------------------------

   constant INCLUDE_CTS : integer range c_NO to c_YES := c_YES;
   constant INCLUDE_CBMNET : integer range c_NO to c_YES := c_NO;
   constant INCLUDE_MBS_MASTER : integer range c_NO to c_YES := c_NO;
   constant INCLUDE_TIMESTAMP_GENERATOR : integer := c_NO;
   
--include TDC for all four trigger input lines

   constant INCLUDE_TDC : integer range c_NO to c_YES := c_NO;
   constant TDC_CHANNEL_NUMBER : integer := 5;
   constant DOUBLE_EDGE_TYPE        : integer range 0 to 3  := 0;  --double edge type:  0, 1, 2,  3
   -- 0: single edge only,
   -- 1: same channel,
   -- 2: alternating channels,
   -- 3: same channel with stretcher
   constant RING_BUFFER_SIZE        : integer range 0 to 7  := 7;  --ring buffer size:  0, 1, 2,  3,  7
                                                                   --ring buffer size: 32,64,96,128,dyn
-- Include SFP power readout
   constant INCLUDE_SFP_DDM : integer range c_NO to c_YES := c_NO;
   
--use all four SFP (1-4) as downlink to other boards (only w/o CBMNET)
    constant USE_4_SFP   : integer range c_NO to c_YES := c_NO;

    
--Run wih 125 MHz instead of 100 MHz     
    constant USE_125_MHZ : integer range c_NO to c_YES := c_NO;    

--Run external 200 MHz clock source
    constant USE_EXTERNAL_CLOCK : integer range c_NO to c_YES := c_YES;    
       
--Which external trigger module (ETM) to use?
    constant INCLUDE_ETM : integer range c_NO to c_YES := c_YES;
    type ETM_CHOICE_type is (ETM_CHOICE_MBS_VULOM, ETM_CHOICE_MAINZ_A2, ETM_CHOICE_CBMNET, ETM_CHOICE_M26);
    constant ETM_CHOICE : ETM_CHOICE_type := ETM_CHOICE_M26;
    
    constant ETM_ID : std_logic_vector(7 downto 0);

--output busy signal on pair 4 of Trigger RJ45?    
    constant GEN_BUSY_OUTPUT : integer := c_NO;
    
    constant TRIGGER_COIN_COUNT   : integer := 1;
    constant TRIGGER_PULSER_COUNT : integer := 2;
    constant TRIGGER_RAND_PULSER  : integer := 1;
    constant TRIGGER_ADDON_COUNT  : integer := 1;
    constant PERIPH_TRIGGER_COUNT : integer := 1;      

--Address settings   
    constant INIT_ADDRESS           : std_logic_vector := x"F3CE";
    constant BROADCAST_SPECIAL_ADDR : std_logic_vector := x"60";    
    
------------------------------------------------------------------------------
--End of configuration
------------------------------------------------------------------------------
   
--Ports:
--        LVL1/IPU       SCtrl
--  0     FPGA 1         FPGA 1
--  1     FPGA 2         FPGA 2
--  2     FPGA 3         FPGA 3
--  3     FPGA 4         FPGA 4
--  4     opt. link      opt. link
--  5-7   SFP 2-4
--  5(8)  CTS read-out   internal         0 1 -   X X O   --downlink only
--  6(9)  CTS TRG        Sctrl GbE        2 3 4   X X X   --uplink only
 
------------------------------------------------------------------------------
--Hub configuration 
------------------------------------------------------------------------------
    type hub_mii_t is array(0 to 1) of integer;    
    type hub_ct    is array(0 to 16) of integer;
    type hub_cfg_t is array(0 to 1) of hub_ct;    
    type hw_info_t is array(0 to 1) of std_logic_vector(31 downto 0);
    
  --this is used to select the proper configuration in the main code    
    constant CFG_MODE : integer;
    
    
  --first entry is normal CTS with one optical output, second one is with four optical outputs
  --slow-control is accepted on SFP1 only, triggers are sent to all used SFP
    constant INTERNAL_NUM_ARR     : hub_mii_t := (5,5);
    constant INTERFACE_NUM_ARR    : hub_mii_t := (5,8);
--                                                 0 1 2 3 4 5 6 7 8 9 a b c d e f 
    constant IS_UPLINK_ARR        : hub_cfg_t := ((0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0),
                                                  (0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0));
    constant IS_DOWNLINK_ARR      : hub_cfg_t := ((1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0),
                                                  (1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0));
    constant IS_UPLINK_ONLY_ARR   : hub_cfg_t := ((0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0),
                                                  (0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0)); 
    constant HARDWARE_INFO_ARR    : hw_info_t := (x"9000CEE0",x"9000CEE2");
                          
    constant CLOCK_FREQUENCY : integer := 100;                      
    constant INTERNAL_NUM         : integer;
    constant INTERFACE_NUM        : integer;
    constant IS_UPLINK            : hub_ct;
    constant IS_DOWNLINK          : hub_ct;
    constant IS_UPLINK_ONLY       : hub_ct;
    constant HARDWARE_INFO        : std_logic_vector(31 downto 0);
    
    -- MII_NUMBER        => 5, --(8)
    -- INT_NUMBER        => 5,
    -- INT_CHANNELS      => (0,1,0,1,3),

    -- No trigger / sctrl sent to optical link, slow control receiving possible
    -- MII_IS_UPLINK        => (0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0);
    -- MII_IS_DOWNLINK      => (1,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0);
    -- MII_IS_UPLINK_ONLY   => (0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0);

    -- Trigger / sctrl sent to optical link, slow control receiving possible
    -- MII_IS_UPLINK        => (0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0);
    -- MII_IS_DOWNLINK      => (1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0);
    -- MII_IS_UPLINK_ONLY   => (0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0);
    -- & disable port 4 in c0 and c1 -- no triggers from/to optical link

    -- Trigger / sctrl sent to 4 optical links
    -- MII_IS_UPLINK        => (0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0);
    -- MII_IS_DOWNLINK      => (1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0);
    -- MII_IS_UPLINK_ONLY   => (0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0);
    -- & disable port 4 in c0 and c1 -- no triggers from/to optical link

------------------------------------------------------------------------------
--CTS configuration
------------------------------------------------------------------------------
    constant cts_rdo_additional_ports : integer;

end;

package body config is
--compute correct configuration mode
  constant CFG_MODE : integer := USE_4_SFP;
  constant cts_rdo_additional_ports : integer := 1 + INCLUDE_TDC + INCLUDE_CBMNET + INCLUDE_MBS_MASTER;

  constant HARDWARE_INFO        : std_logic_vector (31 downto 0) := HARDWARE_INFO_ARR(INCLUDE_TDC);
  constant INTERNAL_NUM         : integer := INTERNAL_NUM_ARR(CFG_MODE);
  constant INTERFACE_NUM        : integer := INTERFACE_NUM_ARR(CFG_MODE);
  constant IS_UPLINK            : hub_ct  := IS_UPLINK_ARR(CFG_MODE);
  constant IS_DOWNLINK          : hub_ct  := IS_DOWNLINK_ARR(CFG_MODE);
  constant IS_UPLINK_ONLY       : hub_ct  := IS_UPLINK_ONLY_ARR(CFG_MODE); 
  
  function etm_id_func return std_logic_vector is
   variable res : unsigned(7 downto 0);
  begin
   res := x"00";
   if INCLUDE_ETM=c_YES then
      res := x"60";
      res := res + TO_UNSIGNED(ETM_CHOICE_type'pos(ETM_CHOICE), 4);
   end if;
   return std_logic_vector(res);
  end function;
  
  constant ETM_ID : std_logic_vector(7 downto 0) := etm_id_func;
  
end package body;
