-- VHDL netlist generated by SCUBA Diamond_1.1_Production (517)
-- Module  Version: 4.8
--/d/sugar/lattice/diamond/1.1/ispfpga/bin/lin/scuba -w -n lattice_scm_fifo_18x1k -lang vhdl -synth synplify -bus_exp 7 -bb -arch or5s00 -type ebfifo -sync_mode -depth 1024 -width 18 -no_enable -pe -1 -pf -1 -fill -e 

-- Mon Dec 13 11:46:24 2010

library IEEE;
use IEEE.std_logic_1164.all;
-- synopsys translate_off
library SCM;
use SCM.COMPONENTS.all;
-- synopsys translate_on

entity lattice_scm_fifo_18x1k is
    port (
        Data: in  std_logic_vector(17 downto 0); 
        Clock: in  std_logic; 
        WrEn: in  std_logic; 
        RdEn: in  std_logic; 
        Reset: in  std_logic; 
        Q: out  std_logic_vector(17 downto 0); 
        WCNT: out  std_logic_vector(10 downto 0); 
        Empty: out  std_logic; 
        Full: out  std_logic);
end lattice_scm_fifo_18x1k;

architecture Structure of lattice_scm_fifo_18x1k is

    -- internal signal declarations
    signal invout_1: std_logic;
    signal invout_0: std_logic;
    signal rden_i_inv: std_logic;
    signal fcnt_en: std_logic;
    signal empty_i: std_logic;
    signal empty_d: std_logic;
    signal full_i: std_logic;
    signal full_d: std_logic;
    signal ifcount_0: std_logic;
    signal ifcount_1: std_logic;
    signal ifcount_2: std_logic;
    signal ifcount_3: std_logic;
    signal co0: std_logic;
    signal ifcount_4: std_logic;
    signal ifcount_5: std_logic;
    signal co1: std_logic;
    signal ifcount_6: std_logic;
    signal ifcount_7: std_logic;
    signal co2: std_logic;
    signal ifcount_8: std_logic;
    signal ifcount_9: std_logic;
    signal co3: std_logic;
    signal ifcount_10: std_logic;
    signal co5: std_logic;
    signal cnt_con: std_logic;
    signal co4: std_logic;
    signal rden_i: std_logic;
    signal co0_1: std_logic;
    signal co1_1: std_logic;
    signal co2_1: std_logic;
    signal co3_1: std_logic;
    signal cmp_le_1: std_logic;
    signal co4_1: std_logic;
    signal fcount_0: std_logic;
    signal fcount_1: std_logic;
    signal co0_2: std_logic;
    signal fcount_2: std_logic;
    signal fcount_3: std_logic;
    signal co1_2: std_logic;
    signal fcount_4: std_logic;
    signal fcount_5: std_logic;
    signal co2_2: std_logic;
    signal fcount_6: std_logic;
    signal fcount_7: std_logic;
    signal co3_2: std_logic;
    signal wren_i: std_logic;
    signal fcount_8: std_logic;
    signal fcount_9: std_logic;
    signal cmp_ge_d1: std_logic;
    signal co4_2: std_logic;
    signal wren_i_inv: std_logic;
    signal fcount_10: std_logic;
    signal iwcount_0: std_logic;
    signal iwcount_1: std_logic;
    signal wcount_0: std_logic;
    signal wcount_1: std_logic;
    signal iwcount_2: std_logic;
    signal iwcount_3: std_logic;
    signal wcount_2: std_logic;
    signal wcount_3: std_logic;
    signal co0_3: std_logic;
    signal iwcount_4: std_logic;
    signal iwcount_5: std_logic;
    signal wcount_4: std_logic;
    signal wcount_5: std_logic;
    signal co1_3: std_logic;
    signal iwcount_6: std_logic;
    signal iwcount_7: std_logic;
    signal wcount_6: std_logic;
    signal wcount_7: std_logic;
    signal co2_3: std_logic;
    signal iwcount_8: std_logic;
    signal iwcount_9: std_logic;
    signal wcount_8: std_logic;
    signal wcount_9: std_logic;
    signal co3_3: std_logic;
    signal iwcount_10: std_logic;
    signal co5_1: std_logic;
    signal wcount_10: std_logic;
    signal co4_3: std_logic;
    signal ircount_0: std_logic;
    signal ircount_1: std_logic;
    signal rcount_0: std_logic;
    signal rcount_1: std_logic;
    signal scuba_vhi: std_logic;
    signal ircount_2: std_logic;
    signal ircount_3: std_logic;
    signal rcount_2: std_logic;
    signal rcount_3: std_logic;
    signal co0_4: std_logic;
    signal ircount_4: std_logic;
    signal ircount_5: std_logic;
    signal rcount_4: std_logic;
    signal rcount_5: std_logic;
    signal co1_4: std_logic;
    signal ircount_6: std_logic;
    signal ircount_7: std_logic;
    signal rcount_6: std_logic;
    signal rcount_7: std_logic;
    signal co2_4: std_logic;
    signal ircount_8: std_logic;
    signal ircount_9: std_logic;
    signal rcount_8: std_logic;
    signal rcount_9: std_logic;
    signal co3_4: std_logic;
    signal ircount_10: std_logic;
    signal co5_2: std_logic;
    signal rcount_10: std_logic;
    signal scuba_vlo: std_logic;
    signal co4_4: std_logic;

    -- local component declarations
    component ROM16X1
    -- synopsys translate_off
        generic (initval : in String);
    -- synopsys translate_on
        port (AD3: in  std_logic; AD2: in  std_logic; AD1: in  std_logic; 
            AD0: in  std_logic; DO0: out  std_logic);
    end component;
    component AND2
        port (A: in  std_logic; B: in  std_logic; Z: out  std_logic);
    end component;
    component XOR2
        port (A: in  std_logic; B: in  std_logic; Z: out  std_logic);
    end component;
    component INV
        port (A: in  std_logic; Z: out  std_logic);
    end component;
    component VHI
        port (Z: out  std_logic);
    end component;
    component VLO
        port (Z: out  std_logic);
    end component;
    component CU2
        port (CI: in  std_logic; PC1: in  std_logic; PC0: in  std_logic; 
            CO: out  std_logic; NC1: out  std_logic; NC0: out  std_logic);
    end component;
    component CB2
        port (CI: in  std_logic; PC1: in  std_logic; PC0: in  std_logic; 
            CON: in  std_logic; CO: out  std_logic; NC1: out  std_logic; 
            NC0: out  std_logic);
    end component;
    component AGEB2
        port (A1: in  std_logic; A0: in  std_logic; B1: in  std_logic; 
            B0: in  std_logic; CI: in  std_logic; GE: out  std_logic);
    end component;
    component ALEB2
        port (A1: in  std_logic; A0: in  std_logic; B1: in  std_logic; 
            B0: in  std_logic; CI: in  std_logic; LE: out  std_logic);
    end component;
    component FD1P3DX
    -- synopsys translate_off
        generic (GSR : in String);
    -- synopsys translate_on
        port (D: in  std_logic; SP: in  std_logic; CK: in  std_logic; 
            CD: in  std_logic; Q: out  std_logic);
    end component;
    component FD1S3BX
    -- synopsys translate_off
        generic (GSR : in String);
    -- synopsys translate_on
        port (D: in  std_logic; CK: in  std_logic; PD: in  std_logic; 
            Q: out  std_logic);
    end component;
    component FD1S3DX
    -- synopsys translate_off
        generic (GSR : in String);
    -- synopsys translate_on
        port (D: in  std_logic; CK: in  std_logic; CD: in  std_logic; 
            Q: out  std_logic);
    end component;
    component PDP16KA
    -- synopsys translate_off
        generic (GSR : in String; 
                CSDECODE_R : in std_logic_vector(2 downto 0); 
                CSDECODE_W : in std_logic_vector(2 downto 0); 
                RESETMODE : in String; REGMODE : in String; 
                DATA_WIDTH_R : in Integer; DATA_WIDTH_W : in Integer);
    -- synopsys translate_on
        port (DI0: in  std_logic; DI1: in  std_logic; DI2: in  std_logic; 
            DI3: in  std_logic; DI4: in  std_logic; DI5: in  std_logic; 
            DI6: in  std_logic; DI7: in  std_logic; DI8: in  std_logic; 
            DI9: in  std_logic; DI10: in  std_logic; DI11: in  std_logic; 
            DI12: in  std_logic; DI13: in  std_logic; 
            DI14: in  std_logic; DI15: in  std_logic; 
            DI16: in  std_logic; DI17: in  std_logic; 
            DI18: in  std_logic; DI19: in  std_logic; 
            DI20: in  std_logic; DI21: in  std_logic; 
            DI22: in  std_logic; DI23: in  std_logic; 
            DI24: in  std_logic; DI25: in  std_logic; 
            DI26: in  std_logic; DI27: in  std_logic; 
            DI28: in  std_logic; DI29: in  std_logic; 
            DI30: in  std_logic; DI31: in  std_logic; 
            DI32: in  std_logic; DI33: in  std_logic; 
            DI34: in  std_logic; DI35: in  std_logic; 
            ADW0: in  std_logic; ADW1: in  std_logic; 
            ADW2: in  std_logic; ADW3: in  std_logic; 
            ADW4: in  std_logic; ADW5: in  std_logic; 
            ADW6: in  std_logic; ADW7: in  std_logic; 
            ADW8: in  std_logic; ADW9: in  std_logic; 
            ADW10: in  std_logic; ADW11: in  std_logic; 
            ADW12: in  std_logic; ADW13: in  std_logic; 
            CEW: in  std_logic; CLKW: in  std_logic; WE: in  std_logic; 
            CSW0: in  std_logic; CSW1: in  std_logic; 
            CSW2: in  std_logic; ADR0: in  std_logic; 
            ADR1: in  std_logic; ADR2: in  std_logic; 
            ADR3: in  std_logic; ADR4: in  std_logic; 
            ADR5: in  std_logic; ADR6: in  std_logic; 
            ADR7: in  std_logic; ADR8: in  std_logic; 
            ADR9: in  std_logic; ADR10: in  std_logic; 
            ADR11: in  std_logic; ADR12: in  std_logic; 
            ADR13: in  std_logic; CER: in  std_logic; 
            CLKR: in  std_logic; CSR0: in  std_logic; 
            CSR1: in  std_logic; CSR2: in  std_logic; RST: in  std_logic; 
            DO0: out  std_logic; DO1: out  std_logic; 
            DO2: out  std_logic; DO3: out  std_logic; 
            DO4: out  std_logic; DO5: out  std_logic; 
            DO6: out  std_logic; DO7: out  std_logic; 
            DO8: out  std_logic; DO9: out  std_logic; 
            DO10: out  std_logic; DO11: out  std_logic; 
            DO12: out  std_logic; DO13: out  std_logic; 
            DO14: out  std_logic; DO15: out  std_logic; 
            DO16: out  std_logic; DO17: out  std_logic; 
            DO18: out  std_logic; DO19: out  std_logic; 
            DO20: out  std_logic; DO21: out  std_logic; 
            DO22: out  std_logic; DO23: out  std_logic; 
            DO24: out  std_logic; DO25: out  std_logic; 
            DO26: out  std_logic; DO27: out  std_logic; 
            DO28: out  std_logic; DO29: out  std_logic; 
            DO30: out  std_logic; DO31: out  std_logic; 
            DO32: out  std_logic; DO33: out  std_logic; 
            DO34: out  std_logic; DO35: out  std_logic);
    end component;
    attribute initval : string; 
    attribute MEM_LPC_FILE : string; 
    attribute MEM_INIT_FILE : string; 
    attribute CSDECODE_R : string; 
    attribute CSDECODE_W : string; 
    attribute RESETMODE : string; 
    attribute REGMODE : string; 
    attribute DATA_WIDTH_R : string; 
    attribute DATA_WIDTH_W : string; 
    attribute GSR : string; 
    attribute initval of LUT4_1 : label is "0x3232";
    attribute initval of LUT4_0 : label is "0x3232";
    attribute MEM_LPC_FILE of pdp_ram_0_0_0 : label is "lattice_scm_fifo_18x1k.lpc";
    attribute MEM_INIT_FILE of pdp_ram_0_0_0 : label is "";
    attribute CSDECODE_R of pdp_ram_0_0_0 : label is "0b000";
    attribute CSDECODE_W of pdp_ram_0_0_0 : label is "0b000";
    attribute GSR of pdp_ram_0_0_0 : label is "DISABLED";
    attribute RESETMODE of pdp_ram_0_0_0 : label is "ASYNC";
    attribute REGMODE of pdp_ram_0_0_0 : label is "NOREG";
    attribute DATA_WIDTH_R of pdp_ram_0_0_0 : label is "18";
    attribute DATA_WIDTH_W of pdp_ram_0_0_0 : label is "18";
    attribute GSR of FF_34 : label is "ENABLED";
    attribute GSR of FF_33 : label is "ENABLED";
    attribute GSR of FF_32 : label is "ENABLED";
    attribute GSR of FF_31 : label is "ENABLED";
    attribute GSR of FF_30 : label is "ENABLED";
    attribute GSR of FF_29 : label is "ENABLED";
    attribute GSR of FF_28 : label is "ENABLED";
    attribute GSR of FF_27 : label is "ENABLED";
    attribute GSR of FF_26 : label is "ENABLED";
    attribute GSR of FF_25 : label is "ENABLED";
    attribute GSR of FF_24 : label is "ENABLED";
    attribute GSR of FF_23 : label is "ENABLED";
    attribute GSR of FF_22 : label is "ENABLED";
    attribute GSR of FF_21 : label is "ENABLED";
    attribute GSR of FF_20 : label is "ENABLED";
    attribute GSR of FF_19 : label is "ENABLED";
    attribute GSR of FF_18 : label is "ENABLED";
    attribute GSR of FF_17 : label is "ENABLED";
    attribute GSR of FF_16 : label is "ENABLED";
    attribute GSR of FF_15 : label is "ENABLED";
    attribute GSR of FF_14 : label is "ENABLED";
    attribute GSR of FF_13 : label is "ENABLED";
    attribute GSR of FF_12 : label is "ENABLED";
    attribute GSR of FF_11 : label is "ENABLED";
    attribute GSR of FF_10 : label is "ENABLED";
    attribute GSR of FF_9 : label is "ENABLED";
    attribute GSR of FF_8 : label is "ENABLED";
    attribute GSR of FF_7 : label is "ENABLED";
    attribute GSR of FF_6 : label is "ENABLED";
    attribute GSR of FF_5 : label is "ENABLED";
    attribute GSR of FF_4 : label is "ENABLED";
    attribute GSR of FF_3 : label is "ENABLED";
    attribute GSR of FF_2 : label is "ENABLED";
    attribute GSR of FF_1 : label is "ENABLED";
    attribute GSR of FF_0 : label is "ENABLED";
    attribute syn_keep : boolean;

begin
    -- component instantiation statements
    AND2_t3: AND2
        port map (A=>WrEn, B=>invout_1, Z=>wren_i);

    INV_3: INV
        port map (A=>full_i, Z=>invout_1);

    AND2_t2: AND2
        port map (A=>RdEn, B=>invout_0, Z=>rden_i);

    INV_2: INV
        port map (A=>empty_i, Z=>invout_0);

    AND2_t1: AND2
        port map (A=>wren_i, B=>rden_i_inv, Z=>cnt_con);

    XOR2_t0: XOR2
        port map (A=>wren_i, B=>rden_i, Z=>fcnt_en);

    INV_1: INV
        port map (A=>rden_i, Z=>rden_i_inv);

    INV_0: INV
        port map (A=>wren_i, Z=>wren_i_inv);

    LUT4_1: ROM16X1
        -- synopsys translate_off
        generic map (initval=> "0x3232")
        -- synopsys translate_on
        port map (AD3=>scuba_vlo, AD2=>cmp_le_1, AD1=>wren_i, 
            AD0=>empty_i, DO0=>empty_d);

    LUT4_0: ROM16X1
        -- synopsys translate_off
        generic map (initval=> "0x3232")
        -- synopsys translate_on
        port map (AD3=>scuba_vlo, AD2=>cmp_ge_d1, AD1=>rden_i, 
            AD0=>full_i, DO0=>full_d);

    pdp_ram_0_0_0: PDP16KA
        -- synopsys translate_off
        generic map (CSDECODE_R=> "000", CSDECODE_W=> "000", GSR=> "DISABLED", 
        RESETMODE=> "ASYNC", REGMODE=> "NOREG", DATA_WIDTH_R=>  18, 
        DATA_WIDTH_W=>  18)
        -- synopsys translate_on
        port map (DI0=>Data(0), DI1=>Data(1), DI2=>Data(2), DI3=>Data(3), 
            DI4=>Data(4), DI5=>Data(5), DI6=>Data(6), DI7=>Data(7), 
            DI8=>Data(8), DI9=>Data(9), DI10=>Data(10), DI11=>Data(11), 
            DI12=>Data(12), DI13=>Data(13), DI14=>Data(14), 
            DI15=>Data(15), DI16=>Data(16), DI17=>Data(17), 
            DI18=>scuba_vlo, DI19=>scuba_vlo, DI20=>scuba_vlo, 
            DI21=>scuba_vlo, DI22=>scuba_vlo, DI23=>scuba_vlo, 
            DI24=>scuba_vlo, DI25=>scuba_vlo, DI26=>scuba_vlo, 
            DI27=>scuba_vlo, DI28=>scuba_vlo, DI29=>scuba_vlo, 
            DI30=>scuba_vlo, DI31=>scuba_vlo, DI32=>scuba_vlo, 
            DI33=>scuba_vlo, DI34=>scuba_vlo, DI35=>scuba_vlo, 
            ADW0=>scuba_vhi, ADW1=>scuba_vhi, ADW2=>scuba_vlo, 
            ADW3=>scuba_vlo, ADW4=>wcount_0, ADW5=>wcount_1, 
            ADW6=>wcount_2, ADW7=>wcount_3, ADW8=>wcount_4, 
            ADW9=>wcount_5, ADW10=>wcount_6, ADW11=>wcount_7, 
            ADW12=>wcount_8, ADW13=>wcount_9, CEW=>wren_i, CLKW=>Clock, 
            WE=>scuba_vhi, CSW0=>scuba_vlo, CSW1=>scuba_vlo, 
            CSW2=>scuba_vlo, ADR0=>scuba_vlo, ADR1=>scuba_vlo, 
            ADR2=>scuba_vlo, ADR3=>scuba_vlo, ADR4=>rcount_0, 
            ADR5=>rcount_1, ADR6=>rcount_2, ADR7=>rcount_3, 
            ADR8=>rcount_4, ADR9=>rcount_5, ADR10=>rcount_6, 
            ADR11=>rcount_7, ADR12=>rcount_8, ADR13=>rcount_9, 
            CER=>rden_i, CLKR=>Clock, CSR0=>scuba_vlo, CSR1=>scuba_vlo, 
            CSR2=>scuba_vlo, RST=>Reset, DO0=>Q(0), DO1=>Q(1), DO2=>Q(2), 
            DO3=>Q(3), DO4=>Q(4), DO5=>Q(5), DO6=>Q(6), DO7=>Q(7), 
            DO8=>Q(8), DO9=>Q(9), DO10=>Q(10), DO11=>Q(11), DO12=>Q(12), 
            DO13=>Q(13), DO14=>Q(14), DO15=>Q(15), DO16=>Q(16), 
            DO17=>Q(17), DO18=>open, DO19=>open, DO20=>open, DO21=>open, 
            DO22=>open, DO23=>open, DO24=>open, DO25=>open, DO26=>open, 
            DO27=>open, DO28=>open, DO29=>open, DO30=>open, DO31=>open, 
            DO32=>open, DO33=>open, DO34=>open, DO35=>open);

    FF_34: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ifcount_0, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_0);

    FF_33: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ifcount_1, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_1);

    FF_32: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ifcount_2, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_2);

    FF_31: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ifcount_3, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_3);

    FF_30: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ifcount_4, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_4);

    FF_29: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ifcount_5, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_5);

    FF_28: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ifcount_6, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_6);

    FF_27: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ifcount_7, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_7);

    FF_26: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ifcount_8, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_8);

    FF_25: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ifcount_9, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_9);

    FF_24: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ifcount_10, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_10);

    FF_23: FD1S3BX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>empty_d, CK=>Clock, PD=>Reset, Q=>empty_i);

    FF_22: FD1S3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>full_d, CK=>Clock, CD=>Reset, Q=>full_i);

    FF_21: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>iwcount_0, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_0);

    FF_20: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>iwcount_1, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_1);

    FF_19: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>iwcount_2, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_2);

    FF_18: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>iwcount_3, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_3);

    FF_17: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>iwcount_4, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_4);

    FF_16: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>iwcount_5, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_5);

    FF_15: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>iwcount_6, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_6);

    FF_14: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>iwcount_7, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_7);

    FF_13: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>iwcount_8, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_8);

    FF_12: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>iwcount_9, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_9);

    FF_11: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>iwcount_10, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_10);

    FF_10: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ircount_0, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_0);

    FF_9: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ircount_1, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_1);

    FF_8: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ircount_2, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_2);

    FF_7: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ircount_3, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_3);

    FF_6: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ircount_4, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_4);

    FF_5: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ircount_5, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_5);

    FF_4: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ircount_6, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_6);

    FF_3: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ircount_7, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_7);

    FF_2: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ircount_8, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_8);

    FF_1: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ircount_9, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_9);

    FF_0: FD1P3DX
        -- synopsys translate_off
        generic map (GSR=> "ENABLED")
        -- synopsys translate_on
        port map (D=>ircount_10, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_10);

    bdcnt_bctr_0: CB2
        port map (CI=>cnt_con, PC1=>fcount_1, PC0=>fcount_0, 
            CON=>cnt_con, CO=>co0, NC1=>ifcount_1, NC0=>ifcount_0);

    bdcnt_bctr_1: CB2
        port map (CI=>co0, PC1=>fcount_3, PC0=>fcount_2, CON=>cnt_con, 
            CO=>co1, NC1=>ifcount_3, NC0=>ifcount_2);

    bdcnt_bctr_2: CB2
        port map (CI=>co1, PC1=>fcount_5, PC0=>fcount_4, CON=>cnt_con, 
            CO=>co2, NC1=>ifcount_5, NC0=>ifcount_4);

    bdcnt_bctr_3: CB2
        port map (CI=>co2, PC1=>fcount_7, PC0=>fcount_6, CON=>cnt_con, 
            CO=>co3, NC1=>ifcount_7, NC0=>ifcount_6);

    bdcnt_bctr_4: CB2
        port map (CI=>co3, PC1=>fcount_9, PC0=>fcount_8, CON=>cnt_con, 
            CO=>co4, NC1=>ifcount_9, NC0=>ifcount_8);

    bdcnt_bctr_5: CB2
        port map (CI=>co4, PC1=>scuba_vlo, PC0=>fcount_10, CON=>cnt_con, 
            CO=>co5, NC1=>open, NC0=>ifcount_10);

    e_cmp_0: ALEB2
        port map (A1=>fcount_1, A0=>fcount_0, B1=>scuba_vlo, B0=>rden_i, 
            CI=>scuba_vhi, LE=>co0_1);

    e_cmp_1: ALEB2
        port map (A1=>fcount_3, A0=>fcount_2, B1=>scuba_vlo, 
            B0=>scuba_vlo, CI=>co0_1, LE=>co1_1);

    e_cmp_2: ALEB2
        port map (A1=>fcount_5, A0=>fcount_4, B1=>scuba_vlo, 
            B0=>scuba_vlo, CI=>co1_1, LE=>co2_1);

    e_cmp_3: ALEB2
        port map (A1=>fcount_7, A0=>fcount_6, B1=>scuba_vlo, 
            B0=>scuba_vlo, CI=>co2_1, LE=>co3_1);

    e_cmp_4: ALEB2
        port map (A1=>fcount_9, A0=>fcount_8, B1=>scuba_vlo, 
            B0=>scuba_vlo, CI=>co3_1, LE=>co4_1);

    e_cmp_5: ALEB2
        port map (A1=>scuba_vlo, A0=>fcount_10, B1=>scuba_vlo, 
            B0=>scuba_vlo, CI=>co4_1, LE=>cmp_le_1);

    g_cmp_0: AGEB2
        port map (A1=>fcount_1, A0=>fcount_0, B1=>wren_i, B0=>wren_i, 
            CI=>scuba_vhi, GE=>co0_2);

    g_cmp_1: AGEB2
        port map (A1=>fcount_3, A0=>fcount_2, B1=>wren_i, B0=>wren_i, 
            CI=>co0_2, GE=>co1_2);

    g_cmp_2: AGEB2
        port map (A1=>fcount_5, A0=>fcount_4, B1=>wren_i, B0=>wren_i, 
            CI=>co1_2, GE=>co2_2);

    g_cmp_3: AGEB2
        port map (A1=>fcount_7, A0=>fcount_6, B1=>wren_i, B0=>wren_i, 
            CI=>co2_2, GE=>co3_2);

    g_cmp_4: AGEB2
        port map (A1=>fcount_9, A0=>fcount_8, B1=>wren_i, B0=>wren_i, 
            CI=>co3_2, GE=>co4_2);

    g_cmp_5: AGEB2
        port map (A1=>scuba_vlo, A0=>fcount_10, B1=>scuba_vlo, 
            B0=>wren_i_inv, CI=>co4_2, GE=>cmp_ge_d1);

    w_ctr_0: CU2
        port map (CI=>scuba_vhi, PC1=>wcount_1, PC0=>wcount_0, CO=>co0_3, 
            NC1=>iwcount_1, NC0=>iwcount_0);

    w_ctr_1: CU2
        port map (CI=>co0_3, PC1=>wcount_3, PC0=>wcount_2, CO=>co1_3, 
            NC1=>iwcount_3, NC0=>iwcount_2);

    w_ctr_2: CU2
        port map (CI=>co1_3, PC1=>wcount_5, PC0=>wcount_4, CO=>co2_3, 
            NC1=>iwcount_5, NC0=>iwcount_4);

    w_ctr_3: CU2
        port map (CI=>co2_3, PC1=>wcount_7, PC0=>wcount_6, CO=>co3_3, 
            NC1=>iwcount_7, NC0=>iwcount_6);

    w_ctr_4: CU2
        port map (CI=>co3_3, PC1=>wcount_9, PC0=>wcount_8, CO=>co4_3, 
            NC1=>iwcount_9, NC0=>iwcount_8);

    w_ctr_5: CU2
        port map (CI=>co4_3, PC1=>scuba_vlo, PC0=>wcount_10, CO=>co5_1, 
            NC1=>open, NC0=>iwcount_10);

    scuba_vhi_inst: VHI
        port map (Z=>scuba_vhi);

    r_ctr_0: CU2
        port map (CI=>scuba_vhi, PC1=>rcount_1, PC0=>rcount_0, CO=>co0_4, 
            NC1=>ircount_1, NC0=>ircount_0);

    r_ctr_1: CU2
        port map (CI=>co0_4, PC1=>rcount_3, PC0=>rcount_2, CO=>co1_4, 
            NC1=>ircount_3, NC0=>ircount_2);

    r_ctr_2: CU2
        port map (CI=>co1_4, PC1=>rcount_5, PC0=>rcount_4, CO=>co2_4, 
            NC1=>ircount_5, NC0=>ircount_4);

    r_ctr_3: CU2
        port map (CI=>co2_4, PC1=>rcount_7, PC0=>rcount_6, CO=>co3_4, 
            NC1=>ircount_7, NC0=>ircount_6);

    r_ctr_4: CU2
        port map (CI=>co3_4, PC1=>rcount_9, PC0=>rcount_8, CO=>co4_4, 
            NC1=>ircount_9, NC0=>ircount_8);

    scuba_vlo_inst: VLO
        port map (Z=>scuba_vlo);

    r_ctr_5: CU2
        port map (CI=>co4_4, PC1=>scuba_vlo, PC0=>rcount_10, CO=>co5_2, 
            NC1=>open, NC0=>ircount_10);

    WCNT(0) <= fcount_0;
    WCNT(1) <= fcount_1;
    WCNT(2) <= fcount_2;
    WCNT(3) <= fcount_3;
    WCNT(4) <= fcount_4;
    WCNT(5) <= fcount_5;
    WCNT(6) <= fcount_6;
    WCNT(7) <= fcount_7;
    WCNT(8) <= fcount_8;
    WCNT(9) <= fcount_9;
    WCNT(10) <= fcount_10;
    Empty <= empty_i;
    Full <= full_i;
end Structure;

-- synopsys translate_off
library SCM;
configuration Structure_CON of lattice_scm_fifo_18x1k is
    for Structure
        for all:ROM16X1 use entity SCM.ROM16X1(V); end for;
        for all:AND2 use entity SCM.AND2(V); end for;
        for all:XOR2 use entity SCM.XOR2(V); end for;
        for all:INV use entity SCM.INV(V); end for;
        for all:VHI use entity SCM.VHI(V); end for;
        for all:VLO use entity SCM.VLO(V); end for;
        for all:CU2 use entity SCM.CU2(V); end for;
        for all:CB2 use entity SCM.CB2(V); end for;
        for all:AGEB2 use entity SCM.AGEB2(V); end for;
        for all:ALEB2 use entity SCM.ALEB2(V); end for;
        for all:FD1P3DX use entity SCM.FD1P3DX(V); end for;
        for all:FD1S3BX use entity SCM.FD1S3BX(V); end for;
        for all:FD1S3DX use entity SCM.FD1S3DX(V); end for;
        for all:PDP16KA use entity SCM.PDP16KA(V); end for;
    end for;
end Structure_CON;

-- synopsys translate_on
