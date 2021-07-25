-- VHDL netlist generated by SCUBA ispLever_v8.1_PROD_Build (20)
-- Module  Version: 5.2
--/d/sugar/lattice/ispLEVER8.1/isptools/ispfpga/bin/lin/scuba -w -n pll_in100_out25 -lang vhdl -synth synplify -arch ep5m00 -type pll -fin 100 -phase_cntl STATIC -mdiv 4 -ndiv 1 -vdiv 48 -delay_cntl GPLL_NO_DELAY -fb_mode CLOCKTREE -extcap DISABLED -noclkos -noclkok -norst -e 

-- Thu Aug 19 13:30:58 2010

library IEEE;
use IEEE.std_logic_1164.all;
-- synopsys translate_off
library ecp2m;
use ecp2m.components.all;
-- synopsys translate_on

entity pll_in100_out25 is
    port (
        CLK: in std_logic; 
        CLKOP: out std_logic; 
        LOCK: out std_logic);
 attribute dont_touch : boolean;
 attribute dont_touch of pll_in100_out25 : entity is true;
end pll_in100_out25;

architecture Structure of pll_in100_out25 is

    -- internal signal declarations
    signal CLKOP_t: std_logic;
    signal scuba_vlo: std_logic;
    signal CLK_t: std_logic;

    -- local component declarations
    component VLO
        port (Z: out std_logic);
    end component;
    component EPLLD
    -- synopsys translate_off
        generic (PLLCAP : in String; CLKOK_BYPASS : in String; 
                CLKOS_BYPASS : in String; CLKOP_BYPASS : in String; 
                DUTY : in Integer; PHASEADJ : in String; 
                PHASE_CNTL : in String; CLKOK_DIV : in Integer; 
                CLKFB_DIV : in Integer; CLKOP_DIV : in Integer; 
                CLKI_DIV : in Integer);
    -- synopsys translate_on
        port (CLKI: in std_logic; CLKFB: in std_logic; RST: in std_logic; 
            RSTK: in std_logic; DPAMODE: in std_logic; DRPAI3: in std_logic; 
            DRPAI2: in std_logic; DRPAI1: in std_logic; DRPAI0: in std_logic; 
            DFPAI3: in std_logic; DFPAI2: in std_logic; DFPAI1: in std_logic; 
            DFPAI0: in std_logic; CLKOP: out std_logic; CLKOS: out std_logic; 
            CLKOK: out std_logic; LOCK: out std_logic; CLKINTFB: out std_logic);
    end component;
    attribute PLLCAP : string; 
    attribute PLLTYPE : string; 
    attribute CLKOK_BYPASS : string; 
    attribute FREQUENCY_PIN_CLKOK : string; 
    attribute CLKOK_DIV : string; 
    attribute CLKOS_BYPASS : string; 
    attribute FREQUENCY_PIN_CLKOP : string; 
    attribute CLKOP_BYPASS : string; 
    attribute PHASE_CNTL : string; 
    attribute FDEL : string; 
    attribute DUTY : string; 
    attribute PHASEADJ : string; 
    attribute FREQUENCY_PIN_CLKI : string; 
    attribute CLKOP_DIV : string; 
    attribute CLKFB_DIV : string; 
    attribute CLKI_DIV : string; 
    attribute FIN : string; 
    attribute PLLCAP of PLLDInst_0 : label is "DISABLED";
    attribute PLLTYPE of PLLDInst_0 : label is "GPLL";
    attribute CLKOK_BYPASS of PLLDInst_0 : label is "DISABLED";
    attribute FREQUENCY_PIN_CLKOK of PLLDInst_0 : label is "50.000000";
    attribute CLKOK_DIV of PLLDInst_0 : label is "2";
    attribute CLKOS_BYPASS of PLLDInst_0 : label is "DISABLED";
    attribute FREQUENCY_PIN_CLKOP of PLLDInst_0 : label is "25.000000";
    attribute CLKOP_BYPASS of PLLDInst_0 : label is "DISABLED";
    attribute PHASE_CNTL of PLLDInst_0 : label is "STATIC";
    attribute FDEL of PLLDInst_0 : label is "0";
    attribute DUTY of PLLDInst_0 : label is "8";
    attribute PHASEADJ of PLLDInst_0 : label is "0.0";
    attribute FREQUENCY_PIN_CLKI of PLLDInst_0 : label is "100.000000";
    attribute CLKOP_DIV of PLLDInst_0 : label is "48";
    attribute CLKFB_DIV of PLLDInst_0 : label is "1";
    attribute CLKI_DIV of PLLDInst_0 : label is "4";
    attribute FIN of PLLDInst_0 : label is "100.000000";
    attribute syn_keep : boolean;
    attribute syn_noprune : boolean;
    attribute syn_noprune of Structure : architecture is true;

begin
    -- component instantiation statements
    scuba_vlo_inst: VLO
        port map (Z=>scuba_vlo);

    PLLDInst_0: EPLLD
        -- synopsys translate_off
        generic map (PLLCAP=> "DISABLED", CLKOK_BYPASS=> "DISABLED", 
        CLKOK_DIV=>  2, CLKOS_BYPASS=> "DISABLED", CLKOP_BYPASS=> "DISABLED", 
        PHASE_CNTL=> "STATIC", DUTY=>  8, PHASEADJ=> "0.0", CLKOP_DIV=>  48, 
        CLKFB_DIV=>  1, CLKI_DIV=>  4)
        -- synopsys translate_on
        port map (CLKI=>CLK_t, CLKFB=>CLKOP_t, RST=>scuba_vlo, 
            RSTK=>scuba_vlo, DPAMODE=>scuba_vlo, DRPAI3=>scuba_vlo, 
            DRPAI2=>scuba_vlo, DRPAI1=>scuba_vlo, DRPAI0=>scuba_vlo, 
            DFPAI3=>scuba_vlo, DFPAI2=>scuba_vlo, DFPAI1=>scuba_vlo, 
            DFPAI0=>scuba_vlo, CLKOP=>CLKOP_t, CLKOS=>open, CLKOK=>open, 
            LOCK=>LOCK, CLKINTFB=>open);

    CLKOP <= CLKOP_t;
    CLK_t <= CLK;
end Structure;

-- synopsys translate_off
library ecp2m;
configuration Structure_CON of pll_in100_out25 is
    for Structure
        for all:VLO use entity ecp2m.VLO(V); end for;
        for all:EPLLD use entity ecp2m.EPLLD(V); end for;
    end for;
end Structure_CON;

-- synopsys translate_on
