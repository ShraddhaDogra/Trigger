-- VHDL netlist generated by SCUBA Diamond (64-bit) 3.6.0.83.4
-- Module  Version: 5.8
--/d/jspc29/lattice/diamond/3.6_x64/ispfpga/bin/lin64/scuba -w -n lattice_ecp3_fifo_18x16_dualport_oreg -lang vhdl -synth synplify -bus_exp 7 -bb -arch sa5p00m -type ebfifo -depth 16 -width 18 -rwidth 18 -regout -no_enable -reset_rel SYNC -pe -1 -pf 7 -fdc /d/jspc22/trb/git/trbnet/lattice/ecp5/lattice_ecp3_fifo_18x16_dualport_oreg/lattice_ecp3_fifo_18x16_dualport_oreg.fdc 

-- Mon Jan 11 11:48:08 2016

library IEEE;
use IEEE.std_logic_1164.all;
library ecp5um;
use ecp5um.components.all;

entity lattice_ecp3_fifo_18x16_dualport_oreg is
    port (
        Data: in  std_logic_vector(17 downto 0); 
        WrClock: in  std_logic; 
        RdClock: in  std_logic; 
        WrEn: in  std_logic; 
        RdEn: in  std_logic; 
        Reset: in  std_logic; 
        RPReset: in  std_logic; 
        Q: out  std_logic_vector(17 downto 0); 
        Empty: out  std_logic; 
        Full: out  std_logic; 
        AlmostFull: out  std_logic);
end lattice_ecp3_fifo_18x16_dualport_oreg;

architecture Structure of lattice_ecp3_fifo_18x16_dualport_oreg is

    -- internal signal declarations
    signal invout_1: std_logic;
    signal invout_0: std_logic;
    signal w_gdata_0: std_logic;
    signal w_gdata_1: std_logic;
    signal w_gdata_2: std_logic;
    signal w_gdata_3: std_logic;
    signal wptr_0: std_logic;
    signal wptr_1: std_logic;
    signal wptr_2: std_logic;
    signal wptr_3: std_logic;
    signal wptr_4: std_logic;
    signal r_gdata_0: std_logic;
    signal r_gdata_1: std_logic;
    signal r_gdata_2: std_logic;
    signal r_gdata_3: std_logic;
    signal rptr_0: std_logic;
    signal rptr_1: std_logic;
    signal rptr_2: std_logic;
    signal rptr_3: std_logic;
    signal rptr_4: std_logic;
    signal w_gcount_0: std_logic;
    signal w_gcount_1: std_logic;
    signal w_gcount_2: std_logic;
    signal w_gcount_3: std_logic;
    signal w_gcount_4: std_logic;
    signal r_gcount_0: std_logic;
    signal r_gcount_1: std_logic;
    signal r_gcount_2: std_logic;
    signal r_gcount_3: std_logic;
    signal r_gcount_4: std_logic;
    signal w_gcount_r20: std_logic;
    signal w_gcount_r0: std_logic;
    signal w_gcount_r21: std_logic;
    signal w_gcount_r1: std_logic;
    signal w_gcount_r22: std_logic;
    signal w_gcount_r2: std_logic;
    signal w_gcount_r23: std_logic;
    signal w_gcount_r3: std_logic;
    signal w_gcount_r24: std_logic;
    signal w_gcount_r4: std_logic;
    signal r_gcount_w20: std_logic;
    signal r_gcount_w0: std_logic;
    signal r_gcount_w21: std_logic;
    signal r_gcount_w1: std_logic;
    signal r_gcount_w22: std_logic;
    signal r_gcount_w2: std_logic;
    signal r_gcount_w23: std_logic;
    signal r_gcount_w3: std_logic;
    signal r_gcount_w24: std_logic;
    signal r_gcount_w4: std_logic;
    signal empty_i: std_logic;
    signal rRst: std_logic;
    signal full_i: std_logic;
    signal iwcount_0: std_logic;
    signal iwcount_1: std_logic;
    signal w_gctr_ci: std_logic;
    signal iwcount_2: std_logic;
    signal iwcount_3: std_logic;
    signal co0: std_logic;
    signal iwcount_4: std_logic;
    signal co2: std_logic;
    signal co1: std_logic;
    signal wcount_4: std_logic;
    signal ircount_0: std_logic;
    signal ircount_1: std_logic;
    signal r_gctr_ci: std_logic;
    signal ircount_2: std_logic;
    signal ircount_3: std_logic;
    signal co0_1: std_logic;
    signal ircount_4: std_logic;
    signal co2_1: std_logic;
    signal co1_1: std_logic;
    signal rcount_4: std_logic;
    signal rden_i: std_logic;
    signal cmp_ci: std_logic;
    signal wcount_r0: std_logic;
    signal w_g2b_xor_cluster_0: std_logic;
    signal rcount_0: std_logic;
    signal rcount_1: std_logic;
    signal co0_2: std_logic;
    signal wcount_r2: std_logic;
    signal wcount_r3: std_logic;
    signal rcount_2: std_logic;
    signal rcount_3: std_logic;
    signal co1_2: std_logic;
    signal empty_cmp_clr: std_logic;
    signal empty_cmp_set: std_logic;
    signal empty_d: std_logic;
    signal empty_d_c: std_logic;
    signal cmp_ci_1: std_logic;
    signal wcount_0: std_logic;
    signal wcount_1: std_logic;
    signal co0_3: std_logic;
    signal wcount_2: std_logic;
    signal wcount_3: std_logic;
    signal co1_3: std_logic;
    signal full_cmp_clr: std_logic;
    signal full_cmp_set: std_logic;
    signal full_d: std_logic;
    signal full_d_c: std_logic;
    signal iaf_setcount_0: std_logic;
    signal iaf_setcount_1: std_logic;
    signal af_set_ctr_ci: std_logic;
    signal iaf_setcount_2: std_logic;
    signal iaf_setcount_3: std_logic;
    signal co0_4: std_logic;
    signal iaf_setcount_4: std_logic;
    signal co2_2: std_logic;
    signal co1_4: std_logic;
    signal af_setcount_4: std_logic;
    signal wren_i: std_logic;
    signal cmp_ci_2: std_logic;
    signal rcount_w0: std_logic;
    signal r_g2b_xor_cluster_0: std_logic;
    signal af_setcount_0: std_logic;
    signal af_setcount_1: std_logic;
    signal co0_5: std_logic;
    signal rcount_w2: std_logic;
    signal rcount_w3: std_logic;
    signal af_setcount_2: std_logic;
    signal af_setcount_3: std_logic;
    signal co1_5: std_logic;
    signal af_set_cmp_clr: std_logic;
    signal af_set_cmp_set: std_logic;
    signal af_set: std_logic;
    signal scuba_vhi: std_logic;
    signal scuba_vlo: std_logic;
    signal af_set_c: std_logic;

    attribute MEM_LPC_FILE : string; 
    attribute MEM_INIT_FILE : string; 
    attribute GSR : string; 
    attribute MEM_LPC_FILE of pdp_ram_0_0_0 : label is "lattice_ecp3_fifo_18x16_dualport_oreg.lpc";
    attribute MEM_INIT_FILE of pdp_ram_0_0_0 : label is "";
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
    AND2_t10: AND2
        port map (A=>WrEn, B=>invout_1, Z=>wren_i);

    INV_1: INV
        port map (A=>full_i, Z=>invout_1);

    AND2_t9: AND2
        port map (A=>RdEn, B=>invout_0, Z=>rden_i);

    INV_0: INV
        port map (A=>empty_i, Z=>invout_0);

    OR2_t8: OR2
        port map (A=>Reset, B=>RPReset, Z=>rRst);

    XOR2_t7: XOR2
        port map (A=>wcount_0, B=>wcount_1, Z=>w_gdata_0);

    XOR2_t6: XOR2
        port map (A=>wcount_1, B=>wcount_2, Z=>w_gdata_1);

    XOR2_t5: XOR2
        port map (A=>wcount_2, B=>wcount_3, Z=>w_gdata_2);

    XOR2_t4: XOR2
        port map (A=>wcount_3, B=>wcount_4, Z=>w_gdata_3);

    XOR2_t3: XOR2
        port map (A=>rcount_0, B=>rcount_1, Z=>r_gdata_0);

    XOR2_t2: XOR2
        port map (A=>rcount_1, B=>rcount_2, Z=>r_gdata_1);

    XOR2_t1: XOR2
        port map (A=>rcount_2, B=>rcount_3, Z=>r_gdata_2);

    XOR2_t0: XOR2
        port map (A=>rcount_3, B=>rcount_4, Z=>r_gdata_3);

    LUT4_13: ROM16X1A
        generic map (initval=> X"6996")
        port map (AD3=>w_gcount_r21, AD2=>w_gcount_r22, 
            AD1=>w_gcount_r23, AD0=>w_gcount_r24, 
            DO0=>w_g2b_xor_cluster_0);

    LUT4_12: ROM16X1A
        generic map (initval=> X"6996")
        port map (AD3=>w_gcount_r23, AD2=>w_gcount_r24, AD1=>scuba_vlo, 
            AD0=>scuba_vlo, DO0=>wcount_r3);

    LUT4_11: ROM16X1A
        generic map (initval=> X"6996")
        port map (AD3=>w_gcount_r22, AD2=>w_gcount_r23, 
            AD1=>w_gcount_r24, AD0=>scuba_vlo, DO0=>wcount_r2);

    LUT4_10: ROM16X1A
        generic map (initval=> X"6996")
        port map (AD3=>w_gcount_r20, AD2=>w_gcount_r21, 
            AD1=>w_gcount_r22, AD0=>wcount_r3, DO0=>wcount_r0);

    LUT4_9: ROM16X1A
        generic map (initval=> X"6996")
        port map (AD3=>r_gcount_w21, AD2=>r_gcount_w22, 
            AD1=>r_gcount_w23, AD0=>r_gcount_w24, 
            DO0=>r_g2b_xor_cluster_0);

    LUT4_8: ROM16X1A
        generic map (initval=> X"6996")
        port map (AD3=>r_gcount_w23, AD2=>r_gcount_w24, AD1=>scuba_vlo, 
            AD0=>scuba_vlo, DO0=>rcount_w3);

    LUT4_7: ROM16X1A
        generic map (initval=> X"6996")
        port map (AD3=>r_gcount_w22, AD2=>r_gcount_w23, 
            AD1=>r_gcount_w24, AD0=>scuba_vlo, DO0=>rcount_w2);

    LUT4_6: ROM16X1A
        generic map (initval=> X"6996")
        port map (AD3=>r_gcount_w20, AD2=>r_gcount_w21, 
            AD1=>r_gcount_w22, AD0=>rcount_w3, DO0=>rcount_w0);

    LUT4_5: ROM16X1A
        generic map (initval=> X"0410")
        port map (AD3=>rptr_4, AD2=>rcount_4, AD1=>w_gcount_r24, 
            AD0=>scuba_vlo, DO0=>empty_cmp_set);

    LUT4_4: ROM16X1A
        generic map (initval=> X"1004")
        port map (AD3=>rptr_4, AD2=>rcount_4, AD1=>w_gcount_r24, 
            AD0=>scuba_vlo, DO0=>empty_cmp_clr);

    LUT4_3: ROM16X1A
        generic map (initval=> X"0140")
        port map (AD3=>wptr_4, AD2=>wcount_4, AD1=>r_gcount_w24, 
            AD0=>scuba_vlo, DO0=>full_cmp_set);

    LUT4_2: ROM16X1A
        generic map (initval=> X"4001")
        port map (AD3=>wptr_4, AD2=>wcount_4, AD1=>r_gcount_w24, 
            AD0=>scuba_vlo, DO0=>full_cmp_clr);

    LUT4_1: ROM16X1A
        generic map (initval=> X"4c32")
        port map (AD3=>af_setcount_4, AD2=>wcount_4, AD1=>r_gcount_w24, 
            AD0=>wptr_4, DO0=>af_set_cmp_set);

    LUT4_0: ROM16X1A
        generic map (initval=> X"8001")
        port map (AD3=>af_setcount_4, AD2=>wcount_4, AD1=>r_gcount_w24, 
            AD0=>wptr_4, DO0=>af_set_cmp_clr);

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
            ADA11=>scuba_vlo, ADA10=>scuba_vlo, ADA9=>scuba_vlo, 
            ADA8=>scuba_vlo, ADA7=>wptr_3, ADA6=>wptr_2, ADA5=>wptr_1, 
            ADA4=>wptr_0, ADA3=>scuba_vlo, ADA2=>scuba_vlo, 
            ADA1=>scuba_vhi, ADA0=>scuba_vhi, CEA=>wren_i, OCEA=>wren_i, 
            CLKA=>WrClock, WEA=>scuba_vhi, CSA2=>scuba_vlo, 
            CSA1=>scuba_vlo, CSA0=>scuba_vlo, RSTA=>Reset, 
            DIB17=>scuba_vlo, DIB16=>scuba_vlo, DIB15=>scuba_vlo, 
            DIB14=>scuba_vlo, DIB13=>scuba_vlo, DIB12=>scuba_vlo, 
            DIB11=>scuba_vlo, DIB10=>scuba_vlo, DIB9=>scuba_vlo, 
            DIB8=>scuba_vlo, DIB7=>scuba_vlo, DIB6=>scuba_vlo, 
            DIB5=>scuba_vlo, DIB4=>scuba_vlo, DIB3=>scuba_vlo, 
            DIB2=>scuba_vlo, DIB1=>scuba_vlo, DIB0=>scuba_vlo, 
            ADB13=>scuba_vlo, ADB12=>scuba_vlo, ADB11=>scuba_vlo, 
            ADB10=>scuba_vlo, ADB9=>scuba_vlo, ADB8=>scuba_vlo, 
            ADB7=>rptr_3, ADB6=>rptr_2, ADB5=>rptr_1, ADB4=>rptr_0, 
            ADB3=>scuba_vlo, ADB2=>scuba_vlo, ADB1=>scuba_vlo, 
            ADB0=>scuba_vlo, CEB=>rden_i, OCEB=>scuba_vhi, CLKB=>RdClock, 
            WEB=>scuba_vlo, CSB2=>scuba_vlo, CSB1=>scuba_vlo, 
            CSB0=>scuba_vlo, RSTB=>Reset, DOA17=>open, DOA16=>open, 
            DOA15=>open, DOA14=>open, DOA13=>open, DOA12=>open, 
            DOA11=>open, DOA10=>open, DOA9=>open, DOA8=>open, DOA7=>open, 
            DOA6=>open, DOA5=>open, DOA4=>open, DOA3=>open, DOA2=>open, 
            DOA1=>open, DOA0=>open, DOB17=>Q(17), DOB16=>Q(16), 
            DOB15=>Q(15), DOB14=>Q(14), DOB13=>Q(13), DOB12=>Q(12), 
            DOB11=>Q(11), DOB10=>Q(10), DOB9=>Q(9), DOB8=>Q(8), 
            DOB7=>Q(7), DOB6=>Q(6), DOB5=>Q(5), DOB4=>Q(4), DOB3=>Q(3), 
            DOB2=>Q(2), DOB1=>Q(1), DOB0=>Q(0));

    FF_57: FD1P3BX
        port map (D=>iwcount_0, SP=>wren_i, CK=>WrClock, PD=>Reset, 
            Q=>wcount_0);

    FF_56: FD1P3DX
        port map (D=>iwcount_1, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>wcount_1);

    FF_55: FD1P3DX
        port map (D=>iwcount_2, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>wcount_2);

    FF_54: FD1P3DX
        port map (D=>iwcount_3, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>wcount_3);

    FF_53: FD1P3DX
        port map (D=>iwcount_4, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>wcount_4);

    FF_52: FD1P3DX
        port map (D=>w_gdata_0, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>w_gcount_0);

    FF_51: FD1P3DX
        port map (D=>w_gdata_1, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>w_gcount_1);

    FF_50: FD1P3DX
        port map (D=>w_gdata_2, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>w_gcount_2);

    FF_49: FD1P3DX
        port map (D=>w_gdata_3, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>w_gcount_3);

    FF_48: FD1P3DX
        port map (D=>wcount_4, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>w_gcount_4);

    FF_47: FD1P3DX
        port map (D=>wcount_0, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>wptr_0);

    FF_46: FD1P3DX
        port map (D=>wcount_1, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>wptr_1);

    FF_45: FD1P3DX
        port map (D=>wcount_2, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>wptr_2);

    FF_44: FD1P3DX
        port map (D=>wcount_3, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>wptr_3);

    FF_43: FD1P3DX
        port map (D=>wcount_4, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>wptr_4);

    FF_42: FD1P3BX
        port map (D=>ircount_0, SP=>rden_i, CK=>RdClock, PD=>rRst, 
            Q=>rcount_0);

    FF_41: FD1P3DX
        port map (D=>ircount_1, SP=>rden_i, CK=>RdClock, CD=>rRst, 
            Q=>rcount_1);

    FF_40: FD1P3DX
        port map (D=>ircount_2, SP=>rden_i, CK=>RdClock, CD=>rRst, 
            Q=>rcount_2);

    FF_39: FD1P3DX
        port map (D=>ircount_3, SP=>rden_i, CK=>RdClock, CD=>rRst, 
            Q=>rcount_3);

    FF_38: FD1P3DX
        port map (D=>ircount_4, SP=>rden_i, CK=>RdClock, CD=>rRst, 
            Q=>rcount_4);

    FF_37: FD1P3DX
        port map (D=>r_gdata_0, SP=>rden_i, CK=>RdClock, CD=>rRst, 
            Q=>r_gcount_0);

    FF_36: FD1P3DX
        port map (D=>r_gdata_1, SP=>rden_i, CK=>RdClock, CD=>rRst, 
            Q=>r_gcount_1);

    FF_35: FD1P3DX
        port map (D=>r_gdata_2, SP=>rden_i, CK=>RdClock, CD=>rRst, 
            Q=>r_gcount_2);

    FF_34: FD1P3DX
        port map (D=>r_gdata_3, SP=>rden_i, CK=>RdClock, CD=>rRst, 
            Q=>r_gcount_3);

    FF_33: FD1P3DX
        port map (D=>rcount_4, SP=>rden_i, CK=>RdClock, CD=>rRst, 
            Q=>r_gcount_4);

    FF_32: FD1P3DX
        port map (D=>rcount_0, SP=>rden_i, CK=>RdClock, CD=>rRst, 
            Q=>rptr_0);

    FF_31: FD1P3DX
        port map (D=>rcount_1, SP=>rden_i, CK=>RdClock, CD=>rRst, 
            Q=>rptr_1);

    FF_30: FD1P3DX
        port map (D=>rcount_2, SP=>rden_i, CK=>RdClock, CD=>rRst, 
            Q=>rptr_2);

    FF_29: FD1P3DX
        port map (D=>rcount_3, SP=>rden_i, CK=>RdClock, CD=>rRst, 
            Q=>rptr_3);

    FF_28: FD1P3DX
        port map (D=>rcount_4, SP=>rden_i, CK=>RdClock, CD=>rRst, 
            Q=>rptr_4);

    FF_27: FD1S3DX
        port map (D=>w_gcount_0, CK=>RdClock, CD=>Reset, Q=>w_gcount_r0);

    FF_26: FD1S3DX
        port map (D=>w_gcount_1, CK=>RdClock, CD=>Reset, Q=>w_gcount_r1);

    FF_25: FD1S3DX
        port map (D=>w_gcount_2, CK=>RdClock, CD=>Reset, Q=>w_gcount_r2);

    FF_24: FD1S3DX
        port map (D=>w_gcount_3, CK=>RdClock, CD=>Reset, Q=>w_gcount_r3);

    FF_23: FD1S3DX
        port map (D=>w_gcount_4, CK=>RdClock, CD=>Reset, Q=>w_gcount_r4);

    FF_22: FD1S3DX
        port map (D=>r_gcount_0, CK=>WrClock, CD=>rRst, Q=>r_gcount_w0);

    FF_21: FD1S3DX
        port map (D=>r_gcount_1, CK=>WrClock, CD=>rRst, Q=>r_gcount_w1);

    FF_20: FD1S3DX
        port map (D=>r_gcount_2, CK=>WrClock, CD=>rRst, Q=>r_gcount_w2);

    FF_19: FD1S3DX
        port map (D=>r_gcount_3, CK=>WrClock, CD=>rRst, Q=>r_gcount_w3);

    FF_18: FD1S3DX
        port map (D=>r_gcount_4, CK=>WrClock, CD=>rRst, Q=>r_gcount_w4);

    FF_17: FD1S3DX
        port map (D=>w_gcount_r0, CK=>RdClock, CD=>Reset, 
            Q=>w_gcount_r20);

    FF_16: FD1S3DX
        port map (D=>w_gcount_r1, CK=>RdClock, CD=>Reset, 
            Q=>w_gcount_r21);

    FF_15: FD1S3DX
        port map (D=>w_gcount_r2, CK=>RdClock, CD=>Reset, 
            Q=>w_gcount_r22);

    FF_14: FD1S3DX
        port map (D=>w_gcount_r3, CK=>RdClock, CD=>Reset, 
            Q=>w_gcount_r23);

    FF_13: FD1S3DX
        port map (D=>w_gcount_r4, CK=>RdClock, CD=>Reset, 
            Q=>w_gcount_r24);

    FF_12: FD1S3DX
        port map (D=>r_gcount_w0, CK=>WrClock, CD=>rRst, Q=>r_gcount_w20);

    FF_11: FD1S3DX
        port map (D=>r_gcount_w1, CK=>WrClock, CD=>rRst, Q=>r_gcount_w21);

    FF_10: FD1S3DX
        port map (D=>r_gcount_w2, CK=>WrClock, CD=>rRst, Q=>r_gcount_w22);

    FF_9: FD1S3DX
        port map (D=>r_gcount_w3, CK=>WrClock, CD=>rRst, Q=>r_gcount_w23);

    FF_8: FD1S3DX
        port map (D=>r_gcount_w4, CK=>WrClock, CD=>rRst, Q=>r_gcount_w24);

    FF_7: FD1S3BX
        port map (D=>empty_d, CK=>RdClock, PD=>rRst, Q=>empty_i);

    FF_6: FD1S3DX
        port map (D=>full_d, CK=>WrClock, CD=>Reset, Q=>full_i);

    FF_5: FD1P3DX
        port map (D=>iaf_setcount_0, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>af_setcount_0);

    FF_4: FD1P3BX
        port map (D=>iaf_setcount_1, SP=>wren_i, CK=>WrClock, PD=>Reset, 
            Q=>af_setcount_1);

    FF_3: FD1P3DX
        port map (D=>iaf_setcount_2, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>af_setcount_2);

    FF_2: FD1P3BX
        port map (D=>iaf_setcount_3, SP=>wren_i, CK=>WrClock, PD=>Reset, 
            Q=>af_setcount_3);

    FF_1: FD1P3DX
        port map (D=>iaf_setcount_4, SP=>wren_i, CK=>WrClock, CD=>Reset, 
            Q=>af_setcount_4);

    FF_0: FD1S3DX
        port map (D=>af_set, CK=>WrClock, CD=>Reset, Q=>AlmostFull);

    w_gctr_cia: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vlo, A1=>scuba_vhi, B0=>scuba_vlo, 
            B1=>scuba_vhi, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>'X', S0=>open, S1=>open, COUT=>w_gctr_ci);

    w_gctr_0: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>wcount_0, A1=>wcount_1, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>w_gctr_ci, S0=>iwcount_0, S1=>iwcount_1, 
            COUT=>co0);

    w_gctr_1: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>wcount_2, A1=>wcount_3, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co0, S0=>iwcount_2, S1=>iwcount_3, 
            COUT=>co1);

    w_gctr_2: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>wcount_4, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co1, S0=>iwcount_4, S1=>open, COUT=>co2);

    r_gctr_cia: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vlo, A1=>scuba_vhi, B0=>scuba_vlo, 
            B1=>scuba_vhi, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>'X', S0=>open, S1=>open, COUT=>r_gctr_ci);

    r_gctr_0: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>rcount_0, A1=>rcount_1, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>r_gctr_ci, S0=>ircount_0, S1=>ircount_1, 
            COUT=>co0_1);

    r_gctr_1: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>rcount_2, A1=>rcount_3, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co0_1, S0=>ircount_2, S1=>ircount_3, 
            COUT=>co1_1);

    r_gctr_2: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>rcount_4, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co1_1, S0=>ircount_4, S1=>open, 
            COUT=>co2_1);

    empty_cmp_ci_a: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vlo, A1=>rden_i, B0=>scuba_vlo, B1=>rden_i, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>'X', S0=>open, S1=>open, COUT=>cmp_ci);

    empty_cmp_0: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>rcount_0, A1=>rcount_1, B0=>wcount_r0, 
            B1=>w_g2b_xor_cluster_0, C0=>scuba_vhi, C1=>scuba_vhi, 
            D0=>scuba_vhi, D1=>scuba_vhi, CIN=>cmp_ci, S0=>open, 
            S1=>open, COUT=>co0_2);

    empty_cmp_1: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>rcount_2, A1=>rcount_3, B0=>wcount_r2, 
            B1=>wcount_r3, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co0_2, S0=>open, S1=>open, COUT=>co1_2);

    empty_cmp_2: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>empty_cmp_set, A1=>scuba_vlo, B0=>empty_cmp_clr, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co1_2, S0=>open, S1=>open, 
            COUT=>empty_d_c);

    a0: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vlo, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>empty_d_c, S0=>empty_d, S1=>open, 
            COUT=>open);

    full_cmp_ci_a: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vlo, A1=>wren_i, B0=>scuba_vlo, B1=>wren_i, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>'X', S0=>open, S1=>open, COUT=>cmp_ci_1);

    full_cmp_0: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>wcount_0, A1=>wcount_1, B0=>rcount_w0, 
            B1=>r_g2b_xor_cluster_0, C0=>scuba_vhi, C1=>scuba_vhi, 
            D0=>scuba_vhi, D1=>scuba_vhi, CIN=>cmp_ci_1, S0=>open, 
            S1=>open, COUT=>co0_3);

    full_cmp_1: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>wcount_2, A1=>wcount_3, B0=>rcount_w2, 
            B1=>rcount_w3, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co0_3, S0=>open, S1=>open, COUT=>co1_3);

    full_cmp_2: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>full_cmp_set, A1=>scuba_vlo, B0=>full_cmp_clr, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co1_3, S0=>open, S1=>open, 
            COUT=>full_d_c);

    a1: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vlo, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>full_d_c, S0=>full_d, S1=>open, 
            COUT=>open);

    af_set_ctr_cia: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vlo, A1=>scuba_vhi, B0=>scuba_vlo, 
            B1=>scuba_vhi, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>'X', S0=>open, S1=>open, 
            COUT=>af_set_ctr_ci);

    af_set_ctr_0: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>af_setcount_0, A1=>af_setcount_1, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>af_set_ctr_ci, S0=>iaf_setcount_0, 
            S1=>iaf_setcount_1, COUT=>co0_4);

    af_set_ctr_1: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>af_setcount_2, A1=>af_setcount_3, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co0_4, S0=>iaf_setcount_2, 
            S1=>iaf_setcount_3, COUT=>co1_4);

    af_set_ctr_2: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>af_setcount_4, A1=>scuba_vlo, B0=>scuba_vlo, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co1_4, S0=>iaf_setcount_4, S1=>open, 
            COUT=>co2_2);

    af_set_cmp_ci_a: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"66AA", 
        INIT0=> X"66AA")
        port map (A0=>scuba_vlo, A1=>wren_i, B0=>scuba_vlo, B1=>wren_i, 
            C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, D1=>scuba_vhi, 
            CIN=>'X', S0=>open, S1=>open, COUT=>cmp_ci_2);

    af_set_cmp_0: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>af_setcount_0, A1=>af_setcount_1, B0=>rcount_w0, 
            B1=>r_g2b_xor_cluster_0, C0=>scuba_vhi, C1=>scuba_vhi, 
            D0=>scuba_vhi, D1=>scuba_vhi, CIN=>cmp_ci_2, S0=>open, 
            S1=>open, COUT=>co0_5);

    af_set_cmp_1: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>af_setcount_2, A1=>af_setcount_3, B0=>rcount_w2, 
            B1=>rcount_w3, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co0_5, S0=>open, S1=>open, COUT=>co1_5);

    af_set_cmp_2: CCU2C
        generic map (INJECT1_1=> "NO", INJECT1_0=> "NO", INIT1=> X"99AA", 
        INIT0=> X"99AA")
        port map (A0=>af_set_cmp_set, A1=>scuba_vlo, B0=>af_set_cmp_clr, 
            B1=>scuba_vlo, C0=>scuba_vhi, C1=>scuba_vhi, D0=>scuba_vhi, 
            D1=>scuba_vhi, CIN=>co1_5, S0=>open, S1=>open, 
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

    Empty <= empty_i;
    Full <= full_i;
end Structure;
