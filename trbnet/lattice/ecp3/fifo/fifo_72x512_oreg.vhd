-- VHDL netlist generated by SCUBA Diamond (64-bit) 3.4.0.80
-- Module  Version: 5.0
--/d/jspc29/lattice/diamond/3.4_x64/ispfpga/bin/lin64/scuba -w -n fifo_72x512_oreg -lang vhdl -synth synplify -bus_exp 7 -bb -arch ep5c00 -type ebfifo -depth 512 -width 72 -depth 512 -regout -no_enable -pe -1 -pf 0 -fill 

-- Fri Mar  6 17:35:52 2015

library IEEE;
use IEEE.std_logic_1164.all;
-- synopsys translate_off
library ecp3;
use ecp3.components.all;
-- synopsys translate_on

entity fifo_72x512_oreg is
    port (
        Data: in  std_logic_vector(71 downto 0); 
        Clock: in  std_logic; 
        WrEn: in  std_logic; 
        RdEn: in  std_logic; 
        Reset: in  std_logic; 
        AmFullThresh: in  std_logic_vector(8 downto 0); 
        Q: out  std_logic_vector(71 downto 0); 
        WCNT: out  std_logic_vector(9 downto 0); 
        Empty: out  std_logic; 
        Full: out  std_logic; 
        AlmostFull: out  std_logic);
end fifo_72x512_oreg;

architecture Structure of fifo_72x512_oreg is

    -- internal signal declarations
    signal invout_2: std_logic;
    signal invout_1: std_logic;
    signal rden_i_inv: std_logic;
    signal invout_0: std_logic;
    signal r_nw: std_logic;
    signal fcnt_en: std_logic;
    signal empty_i: std_logic;
    signal empty_d: std_logic;
    signal full_i: std_logic;
    signal full_d: std_logic;
    signal wptr_0: std_logic;
    signal wptr_1: std_logic;
    signal wptr_2: std_logic;
    signal wptr_3: std_logic;
    signal wptr_4: std_logic;
    signal wptr_5: std_logic;
    signal wptr_6: std_logic;
    signal wptr_7: std_logic;
    signal wptr_8: std_logic;
    signal wptr_9: std_logic;
    signal rptr_9: std_logic;
    signal ifcount_0: std_logic;
    signal ifcount_1: std_logic;
    signal bdcnt_bctr_ci: std_logic;
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
    signal co4: std_logic;
    signal co3: std_logic;
    signal cmp_ci: std_logic;
    signal rden_i: std_logic;
    signal co0_1: std_logic;
    signal co1_1: std_logic;
    signal co2_1: std_logic;
    signal co3_1: std_logic;
    signal cmp_le_1: std_logic;
    signal cmp_le_1_c: std_logic;
    signal cmp_ci_1: std_logic;
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
    signal wren_i_inv: std_logic;
    signal fcount_8: std_logic;
    signal fcount_9: std_logic;
    signal cmp_ge_d1: std_logic;
    signal cmp_ge_d1_c: std_logic;
    signal iwcount_0: std_logic;
    signal iwcount_1: std_logic;
    signal w_ctr_ci: std_logic;
    signal iwcount_2: std_logic;
    signal iwcount_3: std_logic;
    signal co0_3: std_logic;
    signal iwcount_4: std_logic;
    signal iwcount_5: std_logic;
    signal co1_3: std_logic;
    signal iwcount_6: std_logic;
    signal iwcount_7: std_logic;
    signal co2_3: std_logic;
    signal iwcount_8: std_logic;
    signal iwcount_9: std_logic;
    signal co4_1: std_logic;
    signal co3_3: std_logic;
    signal wcount_9: std_logic;
    signal scuba_vhi: std_logic;
    signal ircount_0: std_logic;
    signal ircount_1: std_logic;
    signal r_ctr_ci: std_logic;
    signal rcount_0: std_logic;
    signal rcount_1: std_logic;
    signal ircount_2: std_logic;
    signal ircount_3: std_logic;
    signal co0_4: std_logic;
    signal rcount_2: std_logic;
    signal rcount_3: std_logic;
    signal ircount_4: std_logic;
    signal ircount_5: std_logic;
    signal co1_4: std_logic;
    signal rcount_4: std_logic;
    signal rcount_5: std_logic;
    signal ircount_6: std_logic;
    signal ircount_7: std_logic;
    signal co2_4: std_logic;
    signal rcount_6: std_logic;
    signal rcount_7: std_logic;
    signal ircount_8: std_logic;
    signal ircount_9: std_logic;
    signal co4_2: std_logic;
    signal co3_4: std_logic;
    signal rcount_8: std_logic;
    signal rcount_9: std_logic;
    signal wcnt_sub_0: std_logic;
    signal precin: std_logic;
    signal cnt_con_inv: std_logic;
    signal rptr_0: std_logic;
    signal cnt_con: std_logic;
    signal wcount_0: std_logic;
    signal wcnt_sub_1: std_logic;
    signal wcnt_sub_2: std_logic;
    signal co0_5: std_logic;
    signal rptr_1: std_logic;
    signal rptr_2: std_logic;
    signal wcount_1: std_logic;
    signal wcount_2: std_logic;
    signal wcnt_sub_3: std_logic;
    signal wcnt_sub_4: std_logic;
    signal co1_5: std_logic;
    signal rptr_3: std_logic;
    signal rptr_4: std_logic;
    signal wcount_3: std_logic;
    signal wcount_4: std_logic;
    signal wcnt_sub_5: std_logic;
    signal wcnt_sub_6: std_logic;
    signal co2_5: std_logic;
    signal rptr_5: std_logic;
    signal rptr_6: std_logic;
    signal wcount_5: std_logic;
    signal wcount_6: std_logic;
    signal wcnt_sub_7: std_logic;
    signal wcnt_sub_8: std_logic;
    signal co3_5: std_logic;
    signal rptr_7: std_logic;
    signal rptr_8: std_logic;
    signal wcount_7: std_logic;
    signal wcount_8: std_logic;
    signal wcnt_sub_9: std_logic;
    signal co4_3: std_logic;
    signal wcnt_sub_msb: std_logic;
    signal wren_i: std_logic;
    signal cmp_ci_2: std_logic;
    signal wcnt_reg_0: std_logic;
    signal wcnt_reg_1: std_logic;
    signal co0_6: std_logic;
    signal wcnt_reg_2: std_logic;
    signal wcnt_reg_3: std_logic;
    signal co1_6: std_logic;
    signal wcnt_reg_4: std_logic;
    signal wcnt_reg_5: std_logic;
    signal co2_6: std_logic;
    signal wcnt_reg_6: std_logic;
    signal wcnt_reg_7: std_logic;
    signal co3_6: std_logic;
    signal wcnt_reg_8: std_logic;
    signal wcnt_reg_9: std_logic;
    signal af_set: std_logic;
    signal af_set_c: std_logic;
    signal scuba_vlo: std_logic;

    -- local component declarations
    component AGEB2
        port (A0: in  std_logic; A1: in  std_logic; B0: in  std_logic; 
            B1: in  std_logic; CI: in  std_logic; GE: out  std_logic);
    end component;
    component ALEB2
        port (A0: in  std_logic; A1: in  std_logic; B0: in  std_logic; 
            B1: in  std_logic; CI: in  std_logic; LE: out  std_logic);
    end component;
    component AND2
        port (A: in  std_logic; B: in  std_logic; Z: out  std_logic);
    end component;
    component CU2
        port (CI: in  std_logic; PC0: in  std_logic; PC1: in  std_logic; 
            CO: out  std_logic; NC0: out  std_logic; NC1: out  std_logic);
    end component;
    component CB2
        port (CI: in  std_logic; PC0: in  std_logic; PC1: in  std_logic; 
            CON: in  std_logic; CO: out  std_logic; NC0: out  std_logic; 
            NC1: out  std_logic);
    end component;
    component FADD2B
        port (A0: in  std_logic; A1: in  std_logic; B0: in  std_logic; 
            B1: in  std_logic; CI: in  std_logic; COUT: out  std_logic; 
            S0: out  std_logic; S1: out  std_logic);
    end component;
    component FSUB2B
        port (A0: in  std_logic; A1: in  std_logic; B0: in  std_logic; 
            B1: in  std_logic; BI: in  std_logic; BOUT: out  std_logic; 
            S0: out  std_logic; S1: out  std_logic);
    end component;
    component FD1P3BX
        port (D: in  std_logic; SP: in  std_logic; CK: in  std_logic; 
            PD: in  std_logic; Q: out  std_logic);
    end component;
    component FD1P3DX
        port (D: in  std_logic; SP: in  std_logic; CK: in  std_logic; 
            CD: in  std_logic; Q: out  std_logic);
    end component;
    component FD1S3BX
        port (D: in  std_logic; CK: in  std_logic; PD: in  std_logic; 
            Q: out  std_logic);
    end component;
    component FD1S3DX
        port (D: in  std_logic; CK: in  std_logic; CD: in  std_logic; 
            Q: out  std_logic);
    end component;
    component INV
        port (A: in  std_logic; Z: out  std_logic);
    end component;
    component ROM16X1A
        generic (INITVAL : in std_logic_vector(15 downto 0));
        port (AD3: in  std_logic; AD2: in  std_logic; AD1: in  std_logic; 
            AD0: in  std_logic; DO0: out  std_logic);
    end component;
    component VHI
        port (Z: out  std_logic);
    end component;
    component VLO
        port (Z: out  std_logic);
    end component;
    component XOR2
        port (A: in  std_logic; B: in  std_logic; Z: out  std_logic);
    end component;
    component PDPW16KC
        generic (GSR : in String; CSDECODE_R : in String; 
                CSDECODE_W : in String; REGMODE : in String; 
                DATA_WIDTH_R : in Integer; DATA_WIDTH_W : in Integer);
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
            ADW8: in  std_logic; BE0: in  std_logic; BE1: in  std_logic; 
            BE2: in  std_logic; BE3: in  std_logic; CEW: in  std_logic; 
            CLKW: in  std_logic; CSW0: in  std_logic; 
            CSW1: in  std_logic; CSW2: in  std_logic; 
            ADR0: in  std_logic; ADR1: in  std_logic; 
            ADR2: in  std_logic; ADR3: in  std_logic; 
            ADR4: in  std_logic; ADR5: in  std_logic; 
            ADR6: in  std_logic; ADR7: in  std_logic; 
            ADR8: in  std_logic; ADR9: in  std_logic; 
            ADR10: in  std_logic; ADR11: in  std_logic; 
            ADR12: in  std_logic; ADR13: in  std_logic; 
            CER: in  std_logic; CLKR: in  std_logic; CSR0: in  std_logic; 
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
    attribute MEM_LPC_FILE : string; 
    attribute MEM_INIT_FILE : string; 
    attribute RESETMODE : string; 
    attribute GSR : string; 
    attribute MEM_LPC_FILE of pdp_ram_0_0_1 : label is "fifo_72x512_oreg.lpc";
    attribute MEM_INIT_FILE of pdp_ram_0_0_1 : label is "";
    attribute RESETMODE of pdp_ram_0_0_1 : label is "SYNC";
    attribute MEM_LPC_FILE of pdp_ram_0_1_0 : label is "fifo_72x512_oreg.lpc";
    attribute MEM_INIT_FILE of pdp_ram_0_1_0 : label is "";
    attribute RESETMODE of pdp_ram_0_1_0 : label is "SYNC";
    attribute GSR of FF_62 : label is "ENABLED";
    attribute GSR of FF_61 : label is "ENABLED";
    attribute GSR of FF_60 : label is "ENABLED";
    attribute GSR of FF_59 : label is "ENABLED";
    attribute GSR of FF_58 : label is "ENABLED";
    attribute GSR of FF_57 : label is "ENABLED";
    attribute GSR of FF_56 : label is "ENABLED";
    attribute GSR of FF_55 : label is "ENABLED";
    attribute GSR of FF_54 : label is "ENABLED";
    attribute GSR of FF_53 : label is "ENABLED";
    attribute GSR of FF_52 : label is "ENABLED";
    attribute GSR of FF_51 : label is "ENABLED";
    attribute GSR of FF_50 : label is "ENABLED";
    attribute GSR of FF_49 : label is "ENABLED";
    attribute GSR of FF_48 : label is "ENABLED";
    attribute GSR of FF_47 : label is "ENABLED";
    attribute GSR of FF_46 : label is "ENABLED";
    attribute GSR of FF_45 : label is "ENABLED";
    attribute GSR of FF_44 : label is "ENABLED";
    attribute GSR of FF_43 : label is "ENABLED";
    attribute GSR of FF_42 : label is "ENABLED";
    attribute GSR of FF_41 : label is "ENABLED";
    attribute GSR of FF_40 : label is "ENABLED";
    attribute GSR of FF_39 : label is "ENABLED";
    attribute GSR of FF_38 : label is "ENABLED";
    attribute GSR of FF_37 : label is "ENABLED";
    attribute GSR of FF_36 : label is "ENABLED";
    attribute GSR of FF_35 : label is "ENABLED";
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
    attribute NGD_DRC_MASK : integer;
    attribute NGD_DRC_MASK of Structure : architecture is 1;

begin
    -- component instantiation statements
    AND2_t5: AND2
        port map (A=>WrEn, B=>invout_2, Z=>wren_i);

    INV_5: INV
        port map (A=>full_i, Z=>invout_2);

    AND2_t4: AND2
        port map (A=>RdEn, B=>invout_1, Z=>rden_i);

    INV_4: INV
        port map (A=>empty_i, Z=>invout_1);

    AND2_t3: AND2
        port map (A=>wren_i, B=>rden_i_inv, Z=>cnt_con);

    XOR2_t2: XOR2
        port map (A=>wren_i, B=>rden_i, Z=>fcnt_en);

    INV_3: INV
        port map (A=>rden_i, Z=>rden_i_inv);

    INV_2: INV
        port map (A=>wren_i, Z=>wren_i_inv);

    LUT4_1: ROM16X1A
        generic map (initval=> X"3232")
        port map (AD3=>scuba_vlo, AD2=>cmp_le_1, AD1=>wren_i, 
            AD0=>empty_i, DO0=>empty_d);

    LUT4_0: ROM16X1A
        generic map (initval=> X"3232")
        port map (AD3=>scuba_vlo, AD2=>cmp_ge_d1, AD1=>rden_i, 
            AD0=>full_i, DO0=>full_d);

    AND2_t1: AND2
        port map (A=>rden_i, B=>invout_0, Z=>r_nw);

    INV_1: INV
        port map (A=>wren_i, Z=>invout_0);

    XOR2_t0: XOR2
        port map (A=>wcount_9, B=>rptr_9, Z=>wcnt_sub_msb);

    INV_0: INV
        port map (A=>cnt_con, Z=>cnt_con_inv);

    pdp_ram_0_0_1: PDPW16KC
        generic map (CSDECODE_R=> "0b001", CSDECODE_W=> "0b001", GSR=> "DISABLED", 
        REGMODE=> "OUTREG", DATA_WIDTH_R=>  36, DATA_WIDTH_W=>  36)
        port map (DI0=>Data(0), DI1=>Data(1), DI2=>Data(2), DI3=>Data(3), 
            DI4=>Data(4), DI5=>Data(5), DI6=>Data(6), DI7=>Data(7), 
            DI8=>Data(8), DI9=>Data(9), DI10=>Data(10), DI11=>Data(11), 
            DI12=>Data(12), DI13=>Data(13), DI14=>Data(14), 
            DI15=>Data(15), DI16=>Data(16), DI17=>Data(17), 
            DI18=>Data(18), DI19=>Data(19), DI20=>Data(20), 
            DI21=>Data(21), DI22=>Data(22), DI23=>Data(23), 
            DI24=>Data(24), DI25=>Data(25), DI26=>Data(26), 
            DI27=>Data(27), DI28=>Data(28), DI29=>Data(29), 
            DI30=>Data(30), DI31=>Data(31), DI32=>Data(32), 
            DI33=>Data(33), DI34=>Data(34), DI35=>Data(35), ADW0=>wptr_0, 
            ADW1=>wptr_1, ADW2=>wptr_2, ADW3=>wptr_3, ADW4=>wptr_4, 
            ADW5=>wptr_5, ADW6=>wptr_6, ADW7=>wptr_7, ADW8=>wptr_8, 
            BE0=>scuba_vhi, BE1=>scuba_vhi, BE2=>scuba_vhi, 
            BE3=>scuba_vhi, CEW=>wren_i, CLKW=>Clock, CSW0=>scuba_vhi, 
            CSW1=>scuba_vlo, CSW2=>scuba_vlo, ADR0=>scuba_vlo, 
            ADR1=>scuba_vlo, ADR2=>scuba_vlo, ADR3=>scuba_vlo, 
            ADR4=>scuba_vlo, ADR5=>rptr_0, ADR6=>rptr_1, ADR7=>rptr_2, 
            ADR8=>rptr_3, ADR9=>rptr_4, ADR10=>rptr_5, ADR11=>rptr_6, 
            ADR12=>rptr_7, ADR13=>rptr_8, CER=>scuba_vhi, CLKR=>Clock, 
            CSR0=>rden_i, CSR1=>scuba_vlo, CSR2=>scuba_vlo, RST=>Reset, 
            DO0=>Q(18), DO1=>Q(19), DO2=>Q(20), DO3=>Q(21), DO4=>Q(22), 
            DO5=>Q(23), DO6=>Q(24), DO7=>Q(25), DO8=>Q(26), DO9=>Q(27), 
            DO10=>Q(28), DO11=>Q(29), DO12=>Q(30), DO13=>Q(31), 
            DO14=>Q(32), DO15=>Q(33), DO16=>Q(34), DO17=>Q(35), 
            DO18=>Q(0), DO19=>Q(1), DO20=>Q(2), DO21=>Q(3), DO22=>Q(4), 
            DO23=>Q(5), DO24=>Q(6), DO25=>Q(7), DO26=>Q(8), DO27=>Q(9), 
            DO28=>Q(10), DO29=>Q(11), DO30=>Q(12), DO31=>Q(13), 
            DO32=>Q(14), DO33=>Q(15), DO34=>Q(16), DO35=>Q(17));

    pdp_ram_0_1_0: PDPW16KC
        generic map (CSDECODE_R=> "0b001", CSDECODE_W=> "0b001", GSR=> "DISABLED", 
        REGMODE=> "OUTREG", DATA_WIDTH_R=>  36, DATA_WIDTH_W=>  36)
        port map (DI0=>Data(36), DI1=>Data(37), DI2=>Data(38), 
            DI3=>Data(39), DI4=>Data(40), DI5=>Data(41), DI6=>Data(42), 
            DI7=>Data(43), DI8=>Data(44), DI9=>Data(45), DI10=>Data(46), 
            DI11=>Data(47), DI12=>Data(48), DI13=>Data(49), 
            DI14=>Data(50), DI15=>Data(51), DI16=>Data(52), 
            DI17=>Data(53), DI18=>Data(54), DI19=>Data(55), 
            DI20=>Data(56), DI21=>Data(57), DI22=>Data(58), 
            DI23=>Data(59), DI24=>Data(60), DI25=>Data(61), 
            DI26=>Data(62), DI27=>Data(63), DI28=>Data(64), 
            DI29=>Data(65), DI30=>Data(66), DI31=>Data(67), 
            DI32=>Data(68), DI33=>Data(69), DI34=>Data(70), 
            DI35=>Data(71), ADW0=>wptr_0, ADW1=>wptr_1, ADW2=>wptr_2, 
            ADW3=>wptr_3, ADW4=>wptr_4, ADW5=>wptr_5, ADW6=>wptr_6, 
            ADW7=>wptr_7, ADW8=>wptr_8, BE0=>scuba_vhi, BE1=>scuba_vhi, 
            BE2=>scuba_vhi, BE3=>scuba_vhi, CEW=>wren_i, CLKW=>Clock, 
            CSW0=>scuba_vhi, CSW1=>scuba_vlo, CSW2=>scuba_vlo, 
            ADR0=>scuba_vlo, ADR1=>scuba_vlo, ADR2=>scuba_vlo, 
            ADR3=>scuba_vlo, ADR4=>scuba_vlo, ADR5=>rptr_0, ADR6=>rptr_1, 
            ADR7=>rptr_2, ADR8=>rptr_3, ADR9=>rptr_4, ADR10=>rptr_5, 
            ADR11=>rptr_6, ADR12=>rptr_7, ADR13=>rptr_8, CER=>scuba_vhi, 
            CLKR=>Clock, CSR0=>rden_i, CSR1=>scuba_vlo, CSR2=>scuba_vlo, 
            RST=>Reset, DO0=>Q(54), DO1=>Q(55), DO2=>Q(56), DO3=>Q(57), 
            DO4=>Q(58), DO5=>Q(59), DO6=>Q(60), DO7=>Q(61), DO8=>Q(62), 
            DO9=>Q(63), DO10=>Q(64), DO11=>Q(65), DO12=>Q(66), 
            DO13=>Q(67), DO14=>Q(68), DO15=>Q(69), DO16=>Q(70), 
            DO17=>Q(71), DO18=>Q(36), DO19=>Q(37), DO20=>Q(38), 
            DO21=>Q(39), DO22=>Q(40), DO23=>Q(41), DO24=>Q(42), 
            DO25=>Q(43), DO26=>Q(44), DO27=>Q(45), DO28=>Q(46), 
            DO29=>Q(47), DO30=>Q(48), DO31=>Q(49), DO32=>Q(50), 
            DO33=>Q(51), DO34=>Q(52), DO35=>Q(53));

    FF_62: FD1P3DX
        port map (D=>ifcount_0, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_0);

    FF_61: FD1P3DX
        port map (D=>ifcount_1, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_1);

    FF_60: FD1P3DX
        port map (D=>ifcount_2, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_2);

    FF_59: FD1P3DX
        port map (D=>ifcount_3, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_3);

    FF_58: FD1P3DX
        port map (D=>ifcount_4, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_4);

    FF_57: FD1P3DX
        port map (D=>ifcount_5, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_5);

    FF_56: FD1P3DX
        port map (D=>ifcount_6, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_6);

    FF_55: FD1P3DX
        port map (D=>ifcount_7, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_7);

    FF_54: FD1P3DX
        port map (D=>ifcount_8, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_8);

    FF_53: FD1P3DX
        port map (D=>ifcount_9, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_9);

    FF_52: FD1S3BX
        port map (D=>empty_d, CK=>Clock, PD=>Reset, Q=>empty_i);

    FF_51: FD1S3DX
        port map (D=>full_d, CK=>Clock, CD=>Reset, Q=>full_i);

    FF_50: FD1P3BX
        port map (D=>iwcount_0, SP=>wren_i, CK=>Clock, PD=>Reset, 
            Q=>wcount_0);

    FF_49: FD1P3DX
        port map (D=>iwcount_1, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_1);

    FF_48: FD1P3DX
        port map (D=>iwcount_2, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_2);

    FF_47: FD1P3DX
        port map (D=>iwcount_3, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_3);

    FF_46: FD1P3DX
        port map (D=>iwcount_4, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_4);

    FF_45: FD1P3DX
        port map (D=>iwcount_5, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_5);

    FF_44: FD1P3DX
        port map (D=>iwcount_6, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_6);

    FF_43: FD1P3DX
        port map (D=>iwcount_7, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_7);

    FF_42: FD1P3DX
        port map (D=>iwcount_8, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_8);

    FF_41: FD1P3DX
        port map (D=>iwcount_9, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_9);

    FF_40: FD1P3BX
        port map (D=>ircount_0, SP=>rden_i, CK=>Clock, PD=>Reset, 
            Q=>rcount_0);

    FF_39: FD1P3DX
        port map (D=>ircount_1, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_1);

    FF_38: FD1P3DX
        port map (D=>ircount_2, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_2);

    FF_37: FD1P3DX
        port map (D=>ircount_3, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_3);

    FF_36: FD1P3DX
        port map (D=>ircount_4, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_4);

    FF_35: FD1P3DX
        port map (D=>ircount_5, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_5);

    FF_34: FD1P3DX
        port map (D=>ircount_6, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_6);

    FF_33: FD1P3DX
        port map (D=>ircount_7, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_7);

    FF_32: FD1P3DX
        port map (D=>ircount_8, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_8);

    FF_31: FD1P3DX
        port map (D=>ircount_9, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_9);

    FF_30: FD1P3DX
        port map (D=>wcount_0, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_0);

    FF_29: FD1P3DX
        port map (D=>wcount_1, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_1);

    FF_28: FD1P3DX
        port map (D=>wcount_2, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_2);

    FF_27: FD1P3DX
        port map (D=>wcount_3, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_3);

    FF_26: FD1P3DX
        port map (D=>wcount_4, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_4);

    FF_25: FD1P3DX
        port map (D=>wcount_5, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_5);

    FF_24: FD1P3DX
        port map (D=>wcount_6, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_6);

    FF_23: FD1P3DX
        port map (D=>wcount_7, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_7);

    FF_22: FD1P3DX
        port map (D=>wcount_8, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_8);

    FF_21: FD1P3DX
        port map (D=>wcount_9, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_9);

    FF_20: FD1P3DX
        port map (D=>rcount_0, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_0);

    FF_19: FD1P3DX
        port map (D=>rcount_1, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_1);

    FF_18: FD1P3DX
        port map (D=>rcount_2, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_2);

    FF_17: FD1P3DX
        port map (D=>rcount_3, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_3);

    FF_16: FD1P3DX
        port map (D=>rcount_4, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_4);

    FF_15: FD1P3DX
        port map (D=>rcount_5, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_5);

    FF_14: FD1P3DX
        port map (D=>rcount_6, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_6);

    FF_13: FD1P3DX
        port map (D=>rcount_7, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_7);

    FF_12: FD1P3DX
        port map (D=>rcount_8, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_8);

    FF_11: FD1P3DX
        port map (D=>rcount_9, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_9);

    FF_10: FD1S3DX
        port map (D=>wcnt_sub_0, CK=>Clock, CD=>Reset, Q=>wcnt_reg_0);

    FF_9: FD1S3DX
        port map (D=>wcnt_sub_1, CK=>Clock, CD=>Reset, Q=>wcnt_reg_1);

    FF_8: FD1S3DX
        port map (D=>wcnt_sub_2, CK=>Clock, CD=>Reset, Q=>wcnt_reg_2);

    FF_7: FD1S3DX
        port map (D=>wcnt_sub_3, CK=>Clock, CD=>Reset, Q=>wcnt_reg_3);

    FF_6: FD1S3DX
        port map (D=>wcnt_sub_4, CK=>Clock, CD=>Reset, Q=>wcnt_reg_4);

    FF_5: FD1S3DX
        port map (D=>wcnt_sub_5, CK=>Clock, CD=>Reset, Q=>wcnt_reg_5);

    FF_4: FD1S3DX
        port map (D=>wcnt_sub_6, CK=>Clock, CD=>Reset, Q=>wcnt_reg_6);

    FF_3: FD1S3DX
        port map (D=>wcnt_sub_7, CK=>Clock, CD=>Reset, Q=>wcnt_reg_7);

    FF_2: FD1S3DX
        port map (D=>wcnt_sub_8, CK=>Clock, CD=>Reset, Q=>wcnt_reg_8);

    FF_1: FD1S3DX
        port map (D=>wcnt_sub_9, CK=>Clock, CD=>Reset, Q=>wcnt_reg_9);

    FF_0: FD1S3DX
        port map (D=>af_set, CK=>Clock, CD=>Reset, Q=>AlmostFull);

    bdcnt_bctr_cia: FADD2B
        port map (A0=>scuba_vlo, A1=>cnt_con, B0=>scuba_vlo, B1=>cnt_con, 
            CI=>scuba_vlo, COUT=>bdcnt_bctr_ci, S0=>open, S1=>open);

    bdcnt_bctr_0: CB2
        port map (CI=>bdcnt_bctr_ci, PC0=>fcount_0, PC1=>fcount_1, 
            CON=>cnt_con, CO=>co0, NC0=>ifcount_0, NC1=>ifcount_1);

    bdcnt_bctr_1: CB2
        port map (CI=>co0, PC0=>fcount_2, PC1=>fcount_3, CON=>cnt_con, 
            CO=>co1, NC0=>ifcount_2, NC1=>ifcount_3);

    bdcnt_bctr_2: CB2
        port map (CI=>co1, PC0=>fcount_4, PC1=>fcount_5, CON=>cnt_con, 
            CO=>co2, NC0=>ifcount_4, NC1=>ifcount_5);

    bdcnt_bctr_3: CB2
        port map (CI=>co2, PC0=>fcount_6, PC1=>fcount_7, CON=>cnt_con, 
            CO=>co3, NC0=>ifcount_6, NC1=>ifcount_7);

    bdcnt_bctr_4: CB2
        port map (CI=>co3, PC0=>fcount_8, PC1=>fcount_9, CON=>cnt_con, 
            CO=>co4, NC0=>ifcount_8, NC1=>ifcount_9);

    e_cmp_ci_a: FADD2B
        port map (A0=>scuba_vhi, A1=>scuba_vhi, B0=>scuba_vhi, 
            B1=>scuba_vhi, CI=>scuba_vlo, COUT=>cmp_ci, S0=>open, 
            S1=>open);

    e_cmp_0: ALEB2
        port map (A0=>fcount_0, A1=>fcount_1, B0=>rden_i, B1=>scuba_vlo, 
            CI=>cmp_ci, LE=>co0_1);

    e_cmp_1: ALEB2
        port map (A0=>fcount_2, A1=>fcount_3, B0=>scuba_vlo, 
            B1=>scuba_vlo, CI=>co0_1, LE=>co1_1);

    e_cmp_2: ALEB2
        port map (A0=>fcount_4, A1=>fcount_5, B0=>scuba_vlo, 
            B1=>scuba_vlo, CI=>co1_1, LE=>co2_1);

    e_cmp_3: ALEB2
        port map (A0=>fcount_6, A1=>fcount_7, B0=>scuba_vlo, 
            B1=>scuba_vlo, CI=>co2_1, LE=>co3_1);

    e_cmp_4: ALEB2
        port map (A0=>fcount_8, A1=>fcount_9, B0=>scuba_vlo, 
            B1=>scuba_vlo, CI=>co3_1, LE=>cmp_le_1_c);

    a0: FADD2B
        port map (A0=>scuba_vlo, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, CI=>cmp_le_1_c, COUT=>open, S0=>cmp_le_1, 
            S1=>open);

    g_cmp_ci_a: FADD2B
        port map (A0=>scuba_vhi, A1=>scuba_vhi, B0=>scuba_vhi, 
            B1=>scuba_vhi, CI=>scuba_vlo, COUT=>cmp_ci_1, S0=>open, 
            S1=>open);

    g_cmp_0: AGEB2
        port map (A0=>fcount_0, A1=>fcount_1, B0=>wren_i, B1=>wren_i, 
            CI=>cmp_ci_1, GE=>co0_2);

    g_cmp_1: AGEB2
        port map (A0=>fcount_2, A1=>fcount_3, B0=>wren_i, B1=>wren_i, 
            CI=>co0_2, GE=>co1_2);

    g_cmp_2: AGEB2
        port map (A0=>fcount_4, A1=>fcount_5, B0=>wren_i, B1=>wren_i, 
            CI=>co1_2, GE=>co2_2);

    g_cmp_3: AGEB2
        port map (A0=>fcount_6, A1=>fcount_7, B0=>wren_i, B1=>wren_i, 
            CI=>co2_2, GE=>co3_2);

    g_cmp_4: AGEB2
        port map (A0=>fcount_8, A1=>fcount_9, B0=>wren_i, B1=>wren_i_inv, 
            CI=>co3_2, GE=>cmp_ge_d1_c);

    a1: FADD2B
        port map (A0=>scuba_vlo, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, CI=>cmp_ge_d1_c, COUT=>open, S0=>cmp_ge_d1, 
            S1=>open);

    w_ctr_cia: FADD2B
        port map (A0=>scuba_vlo, A1=>scuba_vhi, B0=>scuba_vlo, 
            B1=>scuba_vhi, CI=>scuba_vlo, COUT=>w_ctr_ci, S0=>open, 
            S1=>open);

    w_ctr_0: CU2
        port map (CI=>w_ctr_ci, PC0=>wcount_0, PC1=>wcount_1, CO=>co0_3, 
            NC0=>iwcount_0, NC1=>iwcount_1);

    w_ctr_1: CU2
        port map (CI=>co0_3, PC0=>wcount_2, PC1=>wcount_3, CO=>co1_3, 
            NC0=>iwcount_2, NC1=>iwcount_3);

    w_ctr_2: CU2
        port map (CI=>co1_3, PC0=>wcount_4, PC1=>wcount_5, CO=>co2_3, 
            NC0=>iwcount_4, NC1=>iwcount_5);

    w_ctr_3: CU2
        port map (CI=>co2_3, PC0=>wcount_6, PC1=>wcount_7, CO=>co3_3, 
            NC0=>iwcount_6, NC1=>iwcount_7);

    w_ctr_4: CU2
        port map (CI=>co3_3, PC0=>wcount_8, PC1=>wcount_9, CO=>co4_1, 
            NC0=>iwcount_8, NC1=>iwcount_9);

    scuba_vhi_inst: VHI
        port map (Z=>scuba_vhi);

    r_ctr_cia: FADD2B
        port map (A0=>scuba_vlo, A1=>scuba_vhi, B0=>scuba_vlo, 
            B1=>scuba_vhi, CI=>scuba_vlo, COUT=>r_ctr_ci, S0=>open, 
            S1=>open);

    r_ctr_0: CU2
        port map (CI=>r_ctr_ci, PC0=>rcount_0, PC1=>rcount_1, CO=>co0_4, 
            NC0=>ircount_0, NC1=>ircount_1);

    r_ctr_1: CU2
        port map (CI=>co0_4, PC0=>rcount_2, PC1=>rcount_3, CO=>co1_4, 
            NC0=>ircount_2, NC1=>ircount_3);

    r_ctr_2: CU2
        port map (CI=>co1_4, PC0=>rcount_4, PC1=>rcount_5, CO=>co2_4, 
            NC0=>ircount_4, NC1=>ircount_5);

    r_ctr_3: CU2
        port map (CI=>co2_4, PC0=>rcount_6, PC1=>rcount_7, CO=>co3_4, 
            NC0=>ircount_6, NC1=>ircount_7);

    r_ctr_4: CU2
        port map (CI=>co3_4, PC0=>rcount_8, PC1=>rcount_9, CO=>co4_2, 
            NC0=>ircount_8, NC1=>ircount_9);

    precin_inst380: FADD2B
        port map (A0=>scuba_vlo, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, CI=>scuba_vlo, COUT=>precin, S0=>open, 
            S1=>open);

    wcnt_0: FSUB2B
        port map (A0=>cnt_con, A1=>wcount_0, B0=>cnt_con_inv, B1=>rptr_0, 
            BI=>precin, BOUT=>co0_5, S0=>open, S1=>wcnt_sub_0);

    wcnt_1: FSUB2B
        port map (A0=>wcount_1, A1=>wcount_2, B0=>rptr_1, B1=>rptr_2, 
            BI=>co0_5, BOUT=>co1_5, S0=>wcnt_sub_1, S1=>wcnt_sub_2);

    wcnt_2: FSUB2B
        port map (A0=>wcount_3, A1=>wcount_4, B0=>rptr_3, B1=>rptr_4, 
            BI=>co1_5, BOUT=>co2_5, S0=>wcnt_sub_3, S1=>wcnt_sub_4);

    wcnt_3: FSUB2B
        port map (A0=>wcount_5, A1=>wcount_6, B0=>rptr_5, B1=>rptr_6, 
            BI=>co2_5, BOUT=>co3_5, S0=>wcnt_sub_5, S1=>wcnt_sub_6);

    wcnt_4: FSUB2B
        port map (A0=>wcount_7, A1=>wcount_8, B0=>rptr_7, B1=>rptr_8, 
            BI=>co3_5, BOUT=>co4_3, S0=>wcnt_sub_7, S1=>wcnt_sub_8);

    wcnt_5: FSUB2B
        port map (A0=>wcnt_sub_msb, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, BI=>co4_3, BOUT=>open, S0=>wcnt_sub_9, 
            S1=>open);

    af_set_cmp_ci_a: FADD2B
        port map (A0=>scuba_vlo, A1=>wren_i, B0=>scuba_vlo, B1=>wren_i, 
            CI=>scuba_vlo, COUT=>cmp_ci_2, S0=>open, S1=>open);

    af_set_cmp_0: AGEB2
        port map (A0=>wcnt_reg_0, A1=>wcnt_reg_1, B0=>AmFullThresh(0), 
            B1=>AmFullThresh(1), CI=>cmp_ci_2, GE=>co0_6);

    af_set_cmp_1: AGEB2
        port map (A0=>wcnt_reg_2, A1=>wcnt_reg_3, B0=>AmFullThresh(2), 
            B1=>AmFullThresh(3), CI=>co0_6, GE=>co1_6);

    af_set_cmp_2: AGEB2
        port map (A0=>wcnt_reg_4, A1=>wcnt_reg_5, B0=>AmFullThresh(4), 
            B1=>AmFullThresh(5), CI=>co1_6, GE=>co2_6);

    af_set_cmp_3: AGEB2
        port map (A0=>wcnt_reg_6, A1=>wcnt_reg_7, B0=>AmFullThresh(6), 
            B1=>AmFullThresh(7), CI=>co2_6, GE=>co3_6);

    af_set_cmp_4: AGEB2
        port map (A0=>wcnt_reg_8, A1=>wcnt_reg_9, B0=>AmFullThresh(8), 
            B1=>scuba_vlo, CI=>co3_6, GE=>af_set_c);

    scuba_vlo_inst: VLO
        port map (Z=>scuba_vlo);

    a2: FADD2B
        port map (A0=>scuba_vlo, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, CI=>af_set_c, COUT=>open, S0=>af_set, 
            S1=>open);

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
    Empty <= empty_i;
    Full <= full_i;
end Structure;

-- synopsys translate_off
library ecp3;
configuration Structure_CON of fifo_72x512_oreg is
    for Structure
        for all:AGEB2 use entity ecp3.AGEB2(V); end for;
        for all:ALEB2 use entity ecp3.ALEB2(V); end for;
        for all:AND2 use entity ecp3.AND2(V); end for;
        for all:CU2 use entity ecp3.CU2(V); end for;
        for all:CB2 use entity ecp3.CB2(V); end for;
        for all:FADD2B use entity ecp3.FADD2B(V); end for;
        for all:FSUB2B use entity ecp3.FSUB2B(V); end for;
        for all:FD1P3BX use entity ecp3.FD1P3BX(V); end for;
        for all:FD1P3DX use entity ecp3.FD1P3DX(V); end for;
        for all:FD1S3BX use entity ecp3.FD1S3BX(V); end for;
        for all:FD1S3DX use entity ecp3.FD1S3DX(V); end for;
        for all:INV use entity ecp3.INV(V); end for;
        for all:ROM16X1A use entity ecp3.ROM16X1A(V); end for;
        for all:VHI use entity ecp3.VHI(V); end for;
        for all:VLO use entity ecp3.VLO(V); end for;
        for all:XOR2 use entity ecp3.XOR2(V); end for;
        for all:PDPW16KC use entity ecp3.PDPW16KC(V); end for;
    end for;
end Structure_CON;

-- synopsys translate_on
