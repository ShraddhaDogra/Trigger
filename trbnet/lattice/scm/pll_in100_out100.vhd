-- VHDL netlist generated by SCUBA Diamond_1.1_Production (517)
-- Module  Version: 5.2
--/d/sugar/lattice/diamond/1.1/ispfpga/bin/lin/scuba -w -n pll_in100_out100 -lang vhdl -synth synplify -bus_exp 7 -bb -arch or5s00 -type pll -fin 100 -mfreq 100 -nfreq 100 -tap 0 -clkos_fdel 0 -fb 0 -clki_del 0 -clki_fdel 0 -clkfb_del 0 -clkfb_fdel 0 -mtol 0.0 -ntol 0.0 -bw LOW -e 

-- Fri Dec 10 17:18:17 2010

library IEEE;
use IEEE.std_logic_1164.all;
-- synopsys translate_off
library SCM;
use SCM.COMPONENTS.all;
-- synopsys translate_on

entity pll_in100_out100 is
    generic (
        SMI_OFFSET : in String := "0x410"
    );
    port (
        clk: in  std_logic; 
        clkop: out  std_logic; 
        clkos: out  std_logic; 
        lock: out  std_logic);
 attribute dont_touch : boolean;
 attribute dont_touch of pll_in100_out100 : entity is true;
end pll_in100_out100;

architecture Structure of pll_in100_out100 is

    -- internal signal declarations
    signal scuba_vlo: std_logic;
    signal scuba_vhi: std_logic;
    signal clkos_t: std_logic;
    signal fb: std_logic;
    signal clkop_t: std_logic;
    signal clk_t: std_logic;

    attribute module_type : string;
    -- local component declarations
    component VHI
        port (Z: out  std_logic);
    end component;
    component VLO
        port (Z: out  std_logic);
    end component;
    component EHXPLLA
        generic (SMI_OFFSET : in String
                -- synopsys translate_off
                ; GSR : in String; CLKOS_DIV : in Integer; 
                CLKOP_DIV : in Integer; CLKFB_DIV : in Integer; 
                CLKI_DIV : in Integer; CLKOS_FDEL : in Integer; 
                CLKFB_FDEL : in Integer; CLKI_FDEL : in Integer; 
                CLKOS_MODE : in String; CLKOP_MODE : in String; 
                PHASEADJ : in Integer; CLKOS_VCODEL : in Integer
                -- synopsys translate_on
                );
        port (SMIADDR9: in  std_logic; SMIADDR8: in  std_logic; 
            SMIADDR7: in  std_logic; SMIADDR6: in  std_logic; 
            SMIADDR5: in  std_logic; SMIADDR4: in  std_logic; 
            SMIADDR3: in  std_logic; SMIADDR2: in  std_logic; 
            SMIADDR1: in  std_logic; SMIADDR0: in  std_logic; 
            SMIRD: in  std_logic; SMIWR: in  std_logic; 
            SMICLK: in  std_logic; SMIWDATA: in  std_logic; 
            SMIRSTN: in  std_logic; CLKI: in  std_logic; 
            CLKFB: in  std_logic; RSTN: in  std_logic; 
            CLKOS: out  std_logic; CLKOP: out  std_logic; 
            LOCK: out  std_logic; CLKINTFB: out  std_logic; 
            SMIRDATA: out  std_logic);
    end component;
    attribute module_type of EHXPLLA : component is "EHXPLLA";
    attribute ip_type : string; 
    attribute FREQUENCY_PIN_CLKOS : string; 
    attribute FREQUENCY_PIN_CLKOP : string; 
    attribute FREQUENCY_PIN_CLKI : string; 
    attribute VCO_LOWERFREQ : string; 
    attribute GMCFREQSEL : string; 
    attribute GSR : string; 
    attribute SPREAD_DIV2 : string; 
    attribute SPREAD_DIV1 : string; 
    attribute SPREAD_DRIFT : string; 
    attribute SPREAD : string; 
    attribute CLKFB_FDEL : string; 
    attribute CLKI_FDEL : string; 
    attribute CLKFB_PDEL : string; 
    attribute CLKI_PDEL : string; 
    attribute LF_RESISTOR : string; 
    attribute LF_IX5UA : string; 
    attribute CLKOS_FDEL : string; 
    attribute CLKOS_VCODEL : string; 
    attribute PHASEADJ : string; 
    attribute CLKOS_MODE : string; 
    attribute CLKOP_MODE : string; 
    attribute CLKOS_DIV : string; 
    attribute CLKOP_DIV : string; 
    attribute CLKFB_DIV : string; 
    attribute CLKI_DIV : string; 
    attribute ip_type of pll_in100_out100_0_0 : label is "EHXPLLA";
    attribute FREQUENCY_PIN_CLKOS of pll_in100_out100_0_0 : label is "100.000000";
    attribute FREQUENCY_PIN_CLKOP of pll_in100_out100_0_0 : label is "100.000000";
    attribute FREQUENCY_PIN_CLKI of pll_in100_out100_0_0 : label is "100.000000";
    attribute VCO_LOWERFREQ of pll_in100_out100_0_0 : label is "DISABLED";
    attribute GMCFREQSEL of pll_in100_out100_0_0 : label is "HIGH";
    attribute GSR of pll_in100_out100_0_0 : label is "ENABLED";
    attribute SPREAD_DIV2 of pll_in100_out100_0_0 : label is "2";
    attribute SPREAD_DIV1 of pll_in100_out100_0_0 : label is "2";
    attribute SPREAD_DRIFT of pll_in100_out100_0_0 : label is "1";
    attribute SPREAD of pll_in100_out100_0_0 : label is "DISABLED";
    attribute CLKFB_FDEL of pll_in100_out100_0_0 : label is "0";
    attribute CLKI_FDEL of pll_in100_out100_0_0 : label is "0";
    attribute CLKFB_PDEL of pll_in100_out100_0_0 : label is "DEL0";
    attribute CLKI_PDEL of pll_in100_out100_0_0 : label is "DEL0";
    attribute LF_RESISTOR of pll_in100_out100_0_0 : label is "0b111010";
    attribute LF_IX5UA of pll_in100_out100_0_0 : label is "31";
    attribute CLKOS_FDEL of pll_in100_out100_0_0 : label is "0";
    attribute CLKOS_VCODEL of pll_in100_out100_0_0 : label is "0";
    attribute PHASEADJ of pll_in100_out100_0_0 : label is "0";
    attribute CLKOS_MODE of pll_in100_out100_0_0 : label is "DIV";
    attribute CLKOP_MODE of pll_in100_out100_0_0 : label is "DIV";
    attribute CLKOS_DIV of pll_in100_out100_0_0 : label is "6";
    attribute CLKOP_DIV of pll_in100_out100_0_0 : label is "6";
    attribute CLKFB_DIV of pll_in100_out100_0_0 : label is "6";
    attribute CLKI_DIV of pll_in100_out100_0_0 : label is "1";
    attribute syn_keep : boolean;
    attribute syn_noprune : boolean;
    attribute syn_noprune of Structure : architecture is true;

begin
    -- component instantiation statements
    scuba_vlo_inst: VLO
        port map (Z=>scuba_vlo);

    scuba_vhi_inst: VHI
        port map (Z=>scuba_vhi);

    pll_in100_out100_0_0: EHXPLLA
        generic map (SMI_OFFSET=>  SMI_OFFSET
        -- synopsys translate_off
                     , GSR=> "ENABLED", CLKFB_FDEL=>  0, CLKI_FDEL=>  0, 
        CLKOS_FDEL=>  0, CLKOS_VCODEL=>  0, PHASEADJ=>  0, CLKOS_MODE=> "DIV", 
        CLKOP_MODE=> "DIV", CLKOS_DIV=>  6, CLKOP_DIV=>  6, CLKFB_DIV=>  6, 
        CLKI_DIV=>  1
        -- synopsys translate_on
                     )
        port map (SMIADDR9=>scuba_vlo, SMIADDR8=>scuba_vlo, 
            SMIADDR7=>scuba_vlo, SMIADDR6=>scuba_vlo, 
            SMIADDR5=>scuba_vlo, SMIADDR4=>scuba_vlo, 
            SMIADDR3=>scuba_vlo, SMIADDR2=>scuba_vlo, 
            SMIADDR1=>scuba_vlo, SMIADDR0=>scuba_vlo, SMIRD=>scuba_vlo, 
            SMIWR=>scuba_vlo, SMICLK=>scuba_vlo, SMIWDATA=>scuba_vlo, 
            SMIRSTN=>scuba_vlo, CLKI=>clk_t, CLKFB=>fb, RSTN=>scuba_vhi, 
            CLKOS=>clkos_t, CLKOP=>clkop_t, LOCK=>lock, CLKINTFB=>fb, 
            SMIRDATA=>open);

    clkos <= clkos_t;
    clkop <= clkop_t;
    clk_t <= clk;
end Structure;

-- synopsys translate_off
library SCM;
configuration Structure_CON of pll_in100_out100 is
    for Structure
        for all:VHI use entity SCM.VHI(V); end for;
        for all:VLO use entity SCM.VLO(V); end for;
        for all:EHXPLLA use entity SCM.EHXPLLA(V); end for;
    end for;
end Structure_CON;

-- synopsys translate_on
