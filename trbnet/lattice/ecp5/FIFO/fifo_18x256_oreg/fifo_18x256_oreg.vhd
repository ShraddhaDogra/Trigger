-- VHDL netlist generated by SCUBA Diamond (64-bit) 3.4.0.80
-- Module  Version: 5.0
--/opt/lattice/diamond/3.4_x64/ispfpga/bin/lin64/scuba -w -n fifo_18x256_oreg -lang vhdl -synth synplify -bus_exp 7 -bb -arch sa5p00m -type ebfifo -sync_mode -depth 256 -width 18 -regout -no_enable -pe -1 -pf 0 -reset_rel SYNC -fill -fdc /home/cugur/Projects/TDC_on_TRB3/trbnet/lattice/ecp5/FIFO/fifo_18x256_oreg/fifo_18x256_oreg.fdc 

-- Fri Mar 20 11:38:17 2015

library IEEE;
use IEEE.std_logic_1164.all;
library ecp5um;
use ecp5um.components.all;

entity fifo_18x256_oreg is
    port (
        Data: in  std_logic_vector(17 downto 0); 
        Clock: in  std_logic; 
        WrEn: in  std_logic; 
        RdEn: in  std_logic; 
        Reset: in  std_logic; 
        AmFullThresh: in  std_logic_vector(7 downto 0); 
        Q: out  std_logic_vector(17 downto 0); 
        WCNT: out  std_logic_vector(8 downto 0); 
        Empty: out  std_logic; 
        Full: out  std_logic; 
        AlmostFull: out  std_logic);
end fifo_18x256_oreg;

architecture Structure of fifo_18x256_oreg is

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
    signal rptr_8: std_logic;
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
    signal co4_1: std_logic;
    signal co3_3: std_logic;
    signal wcount_8: std_logic;
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
    signal co4_2: std_logic;
    signal co3_4: std_logic;
    signal rcount_8: std_logic;
    signal wcnt_sub_0: std_logic;
    signal rptr_0: std_logic;
    signal cnt_con_inv: std_logic;
    signal wcount_0: std_logic;
    signal cnt_con: std_logic;
    signal precin: std_logic;
    signal wcnt_sub_1: std_logic;
    signal wcnt_sub_2: std_logic;
    signal rptr_2: std_logic;
    signal rptr_1: std_logic;
    signal wcount_2: std_logic;
    signal wcount_1: std_logic;
    signal co0_5: std_logic;
    signal wcnt_sub_3: std_logic;
    signal wcnt_sub_4: std_logic;
    signal rptr_4: std_logic;
    signal rptr_3: std_logic;
    signal wcount_4: std_logic;
    signal wcount_3: std_logic;
    signal co1_5: std_logic;
    signal wcnt_sub_5: std_logic;
    signal wcnt_sub_6: std_logic;
    signal rptr_6: std_logic;
    signal rptr_5: std_logic;
    signal wcount_6: std_logic;
    signal wcount_5: std_logic;
    signal co2_5: std_logic;
    signal wcnt_sub_7: std_logic;
    signal wcnt_sub_8: std_logic;
    signal rptr_7: std_logic;
    signal wcnt_sub_msb: std_logic;
    signal wcount_7: std_logic;
    signal co3_5: std_logic;
    signal co4_3d: std_logic;
    signal co4_3: std_logic;
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
    signal af_set: std_logic;
    signal scuba_vhi: std_logic;
    signal scuba_vlo: std_logic;
    signal af_set_c: std_logic;

    attribute MEM_LPC_FILE : string; 
    attribute MEM_INIT_FILE : string; 
    attribute GSR : string; 
    attribute MEM_LPC_FILE of pdp_ram_0_0_0 : label is "fifo_18x256_oreg.lpc";
    attribute MEM_INIT_FILE of pdp_ram_0_0_0 : label is "";
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
        port map (A=>wcount_8, B=>rptr_8, Z=>wcnt_sub_msb);

    INV_0: INV
        port map (A=>cnt_con, Z=>cnt_con_inv);

    pdp_ram_0_0_0: DP16KD
        generic map (INIT_DATA=> "STATIC", ASYNC_RESET_RELEASE=> "SYNC", 
        CSDECODE_B=> "0b000", CSDECODE_A=> "0b000", WRITEMODE_B=> "NORMAL", 
        WRITEMODE_A=> "NORMAL", GSR=> "ENABLED", RESETMODE=> "ASYNC", 
        REGMODE_B=> "OUTREG", REGMODE_A=> "OUTREG", DATA_WIDTH_B=>  18, 
        DATA_WIDTH_A=>  18)
        port map (DIA17=>Data(17), DIA16=>Data(16), DIA15=>Data(15), 
            DIA14=>Data(14), DIA13=>Data(13), DIA12=>Data(12), 
            DIA11=>Data(11), DIA10=>Data(10), DIA9=>Data(9), 
            DIA8=>Data(8), DIA7=>Data(7), DIA6=>Data(6), DIA5=>Data(5), 
            DIA4=>Data(4), DIA3=>Data(3), DIA2=>Data(2), DIA1=>Data(1), 
            DIA0=>Data(0), ADA13=>scuba_vlo, ADA12=>scuba_vlo, 
            ADA11=>wptr_7, ADA10=>wptr_6, ADA9=>wptr_5, ADA8=>wptr_4, 
            ADA7=>wptr_3, ADA6=>wptr_2, ADA5=>wptr_1, ADA4=>wptr_0, 
            ADA3=>scuba_vlo, ADA2=>scuba_vlo, ADA1=>scuba_vhi, 
            ADA0=>scuba_vhi, CEA=>wren_i, OCEA=>wren_i, CLKA=>Clock, 
            WEA=>scuba_vhi, CSA2=>scuba_vlo, CSA1=>scuba_vlo, 
            CSA0=>scuba_vlo, RSTA=>Reset, DIB17=>scuba_vlo, 
            DIB16=>scuba_vlo, DIB15=>scuba_vlo, DIB14=>scuba_vlo, 
            DIB13=>scuba_vlo, DIB12=>scuba_vlo, DIB11=>scuba_vlo, 
            DIB10=>scuba_vlo, DIB9=>scuba_vlo, DIB8=>scuba_vlo, 
            DIB7=>scuba_vlo, DIB6=>scuba_vlo, DIB5=>scuba_vlo, 
            DIB4=>scuba_vlo, DIB3=>scuba_vlo, DIB2=>scuba_vlo, 
            DIB1=>scuba_vlo, DIB0=>scuba_vlo, ADB13=>scuba_vlo, 
            ADB12=>scuba_vlo, ADB11=>rptr_7, ADB10=>rptr_6, ADB9=>rptr_5, 
            ADB8=>rptr_4, ADB7=>rptr_3, ADB6=>rptr_2, ADB5=>rptr_1, 
            ADB4=>rptr_0, ADB3=>scuba_vlo, ADB2=>scuba_vlo, 
            ADB1=>scuba_vlo, ADB0=>scuba_vlo, CEB=>rden_i, 
            OCEB=>scuba_vhi, CLKB=>Clock, WEB=>scuba_vlo, 
            CSB2=>scuba_vlo, CSB1=>scuba_vlo, CSB0=>scuba_vlo, 
            RSTB=>Reset, DOA17=>open, DOA16=>open, DOA15=>open, 
            DOA14=>open, DOA13=>open, DOA12=>open, DOA11=>open, 
            DOA10=>open, DOA9=>open, DOA8=>open, DOA7=>open, DOA6=>open, 
            DOA5=>open, DOA4=>open, DOA3=>open, DOA2=>open, DOA1=>open, 
            DOA0=>open, DOB17=>Q(17), DOB16=>Q(16), DOB15=>Q(15), 
            DOB14=>Q(14), DOB13=>Q(13), DOB12=>Q(12), DOB11=>Q(11), 
            DOB10=>Q(10), DOB9=>Q(9), DOB8=>Q(8), DOB7=>Q(7), DOB6=>Q(6), 
            DOB5=>Q(5), DOB4=>Q(4), DOB3=>Q(3), DOB2=>Q(2), DOB1=>Q(1), 
            DOB0=>Q(0));

    FF_56: FD1P3DX
        port map (D=>ifcount_0, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_0);

    FF_55: FD1P3DX
        port map (D=>ifcount_1, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_1);

    FF_54: FD1P3DX
        port map (D=>ifcount_2, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_2);

    FF_53: FD1P3DX
        port map (D=>ifcount_3, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_3);

    FF_52: FD1P3DX
        port map (D=>ifcount_4, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_4);

    FF_51: FD1P3DX
        port map (D=>ifcount_5, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_5);

    FF_50: FD1P3DX
        port map (D=>ifcount_6, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_6);

    FF_49: FD1P3DX
        port map (D=>ifcount_7, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_7);

    FF_48: FD1P3DX
        port map (D=>ifcount_8, SP=>fcnt_en, CK=>Clock, CD=>Reset, 
            Q=>fcount_8);

    FF_47: FD1S3BX
        port map (D=>empty_d, CK=>Clock, PD=>Reset, Q=>empty_i);

    FF_46: FD1S3DX
        port map (D=>full_d, CK=>Clock, CD=>Reset, Q=>full_i);

    FF_45: FD1P3BX
        port map (D=>iwcount_0, SP=>wren_i, CK=>Clock, PD=>Reset, 
            Q=>wcount_0);

    FF_44: FD1P3DX
        port map (D=>iwcount_1, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_1);

    FF_43: FD1P3DX
        port map (D=>iwcount_2, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_2);

    FF_42: FD1P3DX
        port map (D=>iwcount_3, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_3);

    FF_41: FD1P3DX
        port map (D=>iwcount_4, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_4);

    FF_40: FD1P3DX
        port map (D=>iwcount_5, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_5);

    FF_39: FD1P3DX
        port map (D=>iwcount_6, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_6);

    FF_38: FD1P3DX
        port map (D=>iwcount_7, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_7);

    FF_37: FD1P3DX
        port map (D=>iwcount_8, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wcount_8);

    FF_36: FD1P3BX
        port map (D=>ircount_0, SP=>rden_i, CK=>Clock, PD=>Reset, 
            Q=>rcount_0);

    FF_35: FD1P3DX
        port map (D=>ircount_1, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_1);

    FF_34: FD1P3DX
        port map (D=>ircount_2, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_2);

    FF_33: FD1P3DX
        port map (D=>ircount_3, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_3);

    FF_32: FD1P3DX
        port map (D=>ircount_4, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_4);

    FF_31: FD1P3DX
        port map (D=>ircount_5, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_5);

    FF_30: FD1P3DX
        port map (D=>ircount_6, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_6);

    FF_29: FD1P3DX
        port map (D=>ircount_7, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_7);

    FF_28: FD1P3DX
        port map (D=>ircount_8, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rcount_8);

    FF_27: FD1P3DX
        port map (D=>wcount_0, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_0);

    FF_26: FD1P3DX
        port map (D=>wcount_1, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_1);

    FF_25: FD1P3DX
        port map (D=>wcount_2, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_2);

    FF_24: FD1P3DX
        port map (D=>wcount_3, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_3);

    FF_23: FD1P3DX
        port map (D=>wcount_4, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_4);

    FF_22: FD1P3DX
        port map (D=>wcount_5, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_5);

    FF_21: FD1P3DX
        port map (D=>wcount_6, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_6);

    FF_20: FD1P3DX
        port map (D=>wcount_7, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_7);

    FF_19: FD1P3DX
        port map (D=>wcount_8, SP=>wren_i, CK=>Clock, CD=>Reset, 
            Q=>wptr_8);

    FF_18: FD1P3DX
        port map (D=>rcount_0, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_0);

    FF_17: FD1P3DX
        port map (D=>rcount_1, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_1);

    FF_16: FD1P3DX
        port map (D=>rcount_2, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_2);

    FF_15: FD1P3DX
        port map (D=>rcount_3, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_3);

    FF_14: FD1P3DX
        port map (D=>rcount_4, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_4);

    FF_13: FD1P3DX
        port map (D=>rcount_5, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_5);

    FF_12: FD1P3DX
        port map (D=>rcount_6, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_6);

    FF_11: FD1P3DX
        port map (D=>rcount_7, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_7);

    FF_10: FD1P3DX
        port map (D=>rcount_8, SP=>rden_i, CK=>Clock, CD=>Reset, 
            Q=>rptr_8);

    FF_9: FD1S3DX
        port map (D=>wcnt_sub_0, CK=>Clock, CD=>Reset, Q=>wcnt_reg_0);

    FF_8: FD1S3DX
        port map (D=>wcnt_sub_1, CK=>Clock, CD=>Reset, Q=>wcnt_reg_1);

    FF_7: FD1S3DX
        port map (D=>wcnt_sub_2, CK=>Clock, CD=>Reset, Q=>wcnt_reg_2);

    FF_6: FD1S3DX
        port map (D=>wcnt_sub_3, CK=>Clock, CD=>Reset, Q=>wcnt_reg_3);

    FF_5: FD1S3DX
        port map (D=>wcnt_sub_4, CK=>Clock, CD=>Reset, Q=>wcnt_reg_4);

    FF_4: FD1S3DX
        port map (D=>wcnt_sub_5, CK=>Clock, CD=>Reset, Q=>wcnt_reg_5);

    FF_3: FD1S3DX
        port map (D=>wcnt_sub_6, CK=>Clock, CD=>Reset, Q=>wcnt_reg_6);

    FF_2: FD1S3DX
        port map (D=>wcnt_sub_7, CK=>Clock, CD=>Reset, Q=>wcnt_reg_7);

    FF_1: FD1S3DX
        port map (D=>wcnt_sub_8, CK=>Clock, CD=>Reset, Q=>wcnt_reg_8);

    FF_0: FD1S3DX
        port map (D=>af_set, CK=>Clock, CD=>Reset, Q=>AlmostFull);

    bdcnt_bctr_cia: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vlo, A1=>cnt_con, B0=>scuba_vlo, B1=>cnt_con, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>'X', S0=>open, S1=>open, COUT=>bdcnt_bctr_ci);

    bdcnt_bctr_0: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>fcount_0, A1=>fcount_1, B0=>cnt_con, B1=>cnt_con, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>bdcnt_bctr_ci, S0=>ifcount_0, S1=>ifcount_1, COUT=>co0);

    bdcnt_bctr_1: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>fcount_2, A1=>fcount_3, B0=>cnt_con, B1=>cnt_con, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>co0, S0=>ifcount_2, S1=>ifcount_3, COUT=>co1);

    bdcnt_bctr_2: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>fcount_4, A1=>fcount_5, B0=>cnt_con, B1=>cnt_con, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>co1, S0=>ifcount_4, S1=>ifcount_5, COUT=>co2);

    bdcnt_bctr_3: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>fcount_6, A1=>fcount_7, B0=>cnt_con, B1=>cnt_con, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>co2, S0=>ifcount_6, S1=>ifcount_7, COUT=>co3);

    bdcnt_bctr_4: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>fcount_8, A1=>scuba_vlo, B0=>cnt_con, B1=>cnt_con, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>co3, S0=>ifcount_8, S1=>open, COUT=>co4);

    e_cmp_ci_a: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vhi, A1=>scuba_vhi, B0=>scuba_vhi, 
            B1=>scuba_vhi, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>'X', S0=>open, S1=>open, COUT=>cmp_ci);

    e_cmp_0: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>rden_i, A1=>scuba_vlo, B0=>fcount_0, B1=>fcount_1, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>cmp_ci, S0=>open, S1=>open, COUT=>co0_1);

    e_cmp_1: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>scuba_vlo, A1=>scuba_vlo, B0=>fcount_2, 
            B1=>fcount_3, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co0_1, S0=>open, S1=>open, COUT=>co1_1);

    e_cmp_2: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>scuba_vlo, A1=>scuba_vlo, B0=>fcount_4, 
            B1=>fcount_5, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co1_1, S0=>open, S1=>open, COUT=>co2_1);

    e_cmp_3: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>scuba_vlo, A1=>scuba_vlo, B0=>fcount_6, 
            B1=>fcount_7, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co2_1, S0=>open, S1=>open, COUT=>co3_1);

    e_cmp_4: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>scuba_vlo, A1=>scuba_vlo, B0=>fcount_8, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co3_1, S0=>open, S1=>open, 
            COUT=>cmp_le_1_c);

    a0: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vlo, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>cmp_le_1_c, S0=>cmp_le_1, S1=>open, 
            COUT=>open);

    g_cmp_ci_a: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vhi, A1=>scuba_vhi, B0=>scuba_vhi, 
            B1=>scuba_vhi, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>'X', S0=>open, S1=>open, COUT=>cmp_ci_1);

    g_cmp_0: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>fcount_0, A1=>fcount_1, B0=>wren_i, B1=>wren_i, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>cmp_ci_1, S0=>open, S1=>open, COUT=>co0_2);

    g_cmp_1: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>fcount_2, A1=>fcount_3, B0=>wren_i, B1=>wren_i, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>co0_2, S0=>open, S1=>open, COUT=>co1_2);

    g_cmp_2: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>fcount_4, A1=>fcount_5, B0=>wren_i, B1=>wren_i, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>co1_2, S0=>open, S1=>open, COUT=>co2_2);

    g_cmp_3: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>fcount_6, A1=>fcount_7, B0=>wren_i, B1=>wren_i, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>co2_2, S0=>open, S1=>open, COUT=>co3_2);

    g_cmp_4: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>fcount_8, A1=>scuba_vlo, B0=>wren_i_inv, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co3_2, S0=>open, S1=>open, 
            COUT=>cmp_ge_d1_c);

    a1: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vlo, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>cmp_ge_d1_c, S0=>cmp_ge_d1, S1=>open, 
            COUT=>open);

    w_ctr_cia: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vlo, A1=>scuba_vhi, B0=>scuba_vlo, 
            B1=>scuba_vhi, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>'X', S0=>open, S1=>open, COUT=>w_ctr_ci);

    w_ctr_0: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>wcount_0, A1=>wcount_1, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>w_ctr_ci, S0=>iwcount_0, S1=>iwcount_1, 
            COUT=>co0_3);

    w_ctr_1: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>wcount_2, A1=>wcount_3, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co0_3, S0=>iwcount_2, S1=>iwcount_3, 
            COUT=>co1_3);

    w_ctr_2: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>wcount_4, A1=>wcount_5, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co1_3, S0=>iwcount_4, S1=>iwcount_5, 
            COUT=>co2_3);

    w_ctr_3: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>wcount_6, A1=>wcount_7, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co2_3, S0=>iwcount_6, S1=>iwcount_7, 
            COUT=>co3_3);

    w_ctr_4: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>wcount_8, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co3_3, S0=>iwcount_8, S1=>open, 
            COUT=>co4_1);

    r_ctr_cia: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vlo, A1=>scuba_vhi, B0=>scuba_vlo, 
            B1=>scuba_vhi, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>'X', S0=>open, S1=>open, COUT=>r_ctr_ci);

    r_ctr_0: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>rcount_0, A1=>rcount_1, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>r_ctr_ci, S0=>ircount_0, S1=>ircount_1, 
            COUT=>co0_4);

    r_ctr_1: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>rcount_2, A1=>rcount_3, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co0_4, S0=>ircount_2, S1=>ircount_3, 
            COUT=>co1_4);

    r_ctr_2: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>rcount_4, A1=>rcount_5, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co1_4, S0=>ircount_4, S1=>ircount_5, 
            COUT=>co2_4);

    r_ctr_3: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>rcount_6, A1=>rcount_7, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co2_4, S0=>ircount_6, S1=>ircount_7, 
            COUT=>co3_4);

    r_ctr_4: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>rcount_8, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co3_4, S0=>ircount_8, S1=>open, 
            COUT=>co4_2);

    precin_inst207: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"0000", 
        INIT0=> X"0000")
        port map (A0=>scuba_vhi, A1=>scuba_vhi, B0=>scuba_vhi, 
            B1=>scuba_vhi, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>'X', S0=>open, S1=>open, COUT=>precin);

    wcnt_0: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>cnt_con, A1=>wcount_0, B0=>cnt_con_inv, B1=>rptr_0, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>precin, S0=>open, S1=>wcnt_sub_0, COUT=>co0_5);

    wcnt_1: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>wcount_1, A1=>wcount_2, B0=>rptr_1, B1=>rptr_2, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>co0_5, S0=>wcnt_sub_1, S1=>wcnt_sub_2, COUT=>co1_5);

    wcnt_2: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>wcount_3, A1=>wcount_4, B0=>rptr_3, B1=>rptr_4, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>co1_5, S0=>wcnt_sub_3, S1=>wcnt_sub_4, COUT=>co2_5);

    wcnt_3: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>wcount_5, A1=>wcount_6, B0=>rptr_5, B1=>rptr_6, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>co2_5, S0=>wcnt_sub_5, S1=>wcnt_sub_6, COUT=>co3_5);

    wcnt_4: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>wcount_7, A1=>wcnt_sub_msb, B0=>rptr_7, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co3_5, S0=>wcnt_sub_7, S1=>wcnt_sub_8, 
            COUT=>co4_3);

    wcntd: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vlo, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co4_3, S0=>co4_3d, S1=>open, COUT=>open);

    af_set_cmp_ci_a: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vlo, A1=>wren_i, B0=>scuba_vlo, B1=>wren_i, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>'X', S0=>open, S1=>open, COUT=>cmp_ci_2);

    af_set_cmp_0: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>wcnt_reg_0, A1=>wcnt_reg_1, B0=>AmFullThresh(0), 
            B1=>AmFullThresh(1), C0=>scuba_vhi, C1=>scuba_vhi, 
            D0=>scuba_vhi, D1=>scuba_vhi, CIN=>cmp_ci_2, S0=>open, 
            S1=>open, COUT=>co0_6);

    af_set_cmp_1: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>wcnt_reg_2, A1=>wcnt_reg_3, B0=>AmFullThresh(2), 
            B1=>AmFullThresh(3), C0=>scuba_vhi, C1=>scuba_vhi, 
            D0=>scuba_vhi, D1=>scuba_vhi, CIN=>co0_6, S0=>open, S1=>open, 
            COUT=>co1_6);

    af_set_cmp_2: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>wcnt_reg_4, A1=>wcnt_reg_5, B0=>AmFullThresh(4), 
            B1=>AmFullThresh(5), C0=>scuba_vhi, C1=>scuba_vhi, 
            D0=>scuba_vhi, D1=>scuba_vhi, CIN=>co1_6, S0=>open, S1=>open, 
            COUT=>co2_6);

    af_set_cmp_3: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>wcnt_reg_6, A1=>wcnt_reg_7, B0=>AmFullThresh(6), 
            B1=>AmFullThresh(7), C0=>scuba_vhi, C1=>scuba_vhi, 
            D0=>scuba_vhi, D1=>scuba_vhi, CIN=>co2_6, S0=>open, S1=>open, 
            COUT=>co3_6);

    af_set_cmp_4: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>wcnt_reg_8, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co3_6, S0=>open, S1=>open, 
            COUT=>af_set_c);

    scuba_vhi_inst: VHI
        port map (Z=>scuba_vhi);

    scuba_vlo_inst: VLO
        port map (Z=>scuba_vlo);

    a2: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vlo, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>af_set_c, S0=>af_set, S1=>open, 
            COUT=>open);

    WCNT(0) <= fcount_0;
    WCNT(1) <= fcount_1;
    WCNT(2) <= fcount_2;
    WCNT(3) <= fcount_3;
    WCNT(4) <= fcount_4;
    WCNT(5) <= fcount_5;
    WCNT(6) <= fcount_6;
    WCNT(7) <= fcount_7;
    WCNT(8) <= fcount_8;
    Empty <= empty_i;
    Full <= full_i;
end Structure;
