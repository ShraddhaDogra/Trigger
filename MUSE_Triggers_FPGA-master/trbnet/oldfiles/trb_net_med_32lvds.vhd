-- media interface for the 32 lvds lines (16 in each direction)
-- for a description see HADES wiki
-- http://hades-wiki.gsi.de/cgi-bin/view/DaqSlowControl/NewTriggerBusMedia

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.trb_net_std.all;


entity trb_net_med_32lvds is

  port(
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;
    -- Internal direction port (MII)
    -- do not change this interface!!!
    -- 1st part: from the medium to the internal logic (trbnet)
    INT_DATAREADY_OUT: out STD_LOGIC;  --Data word is reconstructed from media
                                       --and ready to be read out
    INT_DATA_OUT:      out STD_LOGIC_VECTOR (55 downto 0); -- Data word
    INT_READ_IN:       in  STD_LOGIC; 
    INT_ERROR_OUT:     out STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    -- 2nd part: from the internal logic (trbnet) to the medium
    INT_DATAREADY_IN:  in  STD_LOGIC; -- Data word is offered by the Media (the IOBUF MUST read)
    INT_DATA_IN:       in  STD_LOGIC_VECTOR (55 downto 0); -- Data word
    INT_READ_OUT:      out STD_LOGIC; -- buffer reads a word from media
    INT_ERROR_IN:      in  STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    -- (end do not change this interface!!!) 

    
    --  Media direction port
    -- in this case for the cable => 32 lines in total
    MED_DATA_OUT:             out STD_LOGIC_VECTOR (12 downto 0); -- Data word
    MED_TRANSMISSION_CLK_OUT: out STD_LOGIC;
    MED_CARRIER_OUT:          out STD_LOGIC;
    MED_PARITY_OUT:           out STD_LOGIC;
    MED_DATA_IN:              out STD_LOGIC_VECTOR (12 downto 0); -- Data word
    MED_TRANSMISSION_CLK_IN:  out STD_LOGIC;
    MED_CARRIER_IN:           out STD_LOGIC;
    MED_PARITY_IN:            out STD_LOGIC;

    -- Status and control port => this never can hurt
    STAT:       out STD_LOGIC_VECTOR (31 downto 0);
    CTRL:       in  STD_LOGIC_VECTOR (31 downto 0);
    );
END trb_net_med_32lvds;
