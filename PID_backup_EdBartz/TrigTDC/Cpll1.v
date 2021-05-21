/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.9.0.99.2 */
/* Module Version: 5.7 */
/* D:\Cad\lscc39\diamond\3.9_x64\ispfpga\bin\nt64\scuba.exe -w -n Cpll1 -lang verilog -synth synplify -arch ep5c00 -type pll -fin 50 -phase_cntl DYNAMIC -mdiv 1 -ndiv 4 -vdiv 4 -fb_mode CLOCKTREE -noclkok -norst -noclkok2 -bw  */
/* Mon Apr 10 12:20:51 2017 */


`timescale 1 ns / 1 ps
module Cpll1 (CLK, FINEDELB0, FINEDELB1, FINEDELB2, FINEDELB3, DPHASE0, 
    DPHASE1, DPHASE2, DPHASE3, DDUTY0, DDUTY1, DDUTY2, DDUTY3, CLKOP, 
    CLKOS, LOCK)/* synthesis NGD_DRC_MASK=1 */;
    input wire CLK;
    input wire FINEDELB0;
    input wire FINEDELB1;
    input wire FINEDELB2;
    input wire FINEDELB3;
    input wire DPHASE0;
    input wire DPHASE1;
    input wire DPHASE2;
    input wire DPHASE3;
    input wire DDUTY0;
    input wire DDUTY1;
    input wire DDUTY2;
    input wire DDUTY3;
    output wire CLKOP;
    output wire CLKOS;
    output wire LOCK;

    wire dfpai_add_carry;
    wire CLKOS_t;
    wire DFPAI3;
    wire DFPAI2;
    wire DFPAI1;
    wire DFPAI0;
    wire CLKOP_t;
    wire scuba_vlo;

    FADD2B dd_add_0 (.A0(DPHASE0), .A1(DPHASE1), .B0(DDUTY0), .B1(DDUTY1), 
        .CI(scuba_vlo), .COUT(dfpai_add_carry), .S0(DFPAI0), .S1(DFPAI1));

    FADD2B dd_add_1 (.A0(DPHASE2), .A1(DPHASE3), .B0(DDUTY2), .B1(DDUTY3), 
        .CI(dfpai_add_carry), .COUT(), .S0(DFPAI2), .S1(DFPAI3));

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam PLLInst_0.FEEDBK_PATH = "CLKOP" ;
    defparam PLLInst_0.CLKOK_BYPASS = "DISABLED" ;
    defparam PLLInst_0.CLKOS_BYPASS = "DISABLED" ;
    defparam PLLInst_0.CLKOP_BYPASS = "DISABLED" ;
    defparam PLLInst_0.CLKOK_INPUT = "CLKOP" ;
    defparam PLLInst_0.DELAY_PWD = "DISABLED" ;
    defparam PLLInst_0.DELAY_VAL = 0 ;
    defparam PLLInst_0.CLKOS_TRIM_DELAY = 0 ;
    defparam PLLInst_0.CLKOS_TRIM_POL = "RISING" ;
    defparam PLLInst_0.CLKOP_TRIM_DELAY = 0 ;
    defparam PLLInst_0.CLKOP_TRIM_POL = "RISING" ;
    defparam PLLInst_0.PHASE_DELAY_CNTL = "DYNAMIC" ;
    defparam PLLInst_0.DUTY = 8 ;
    defparam PLLInst_0.PHASEADJ = "0.0" ;
    defparam PLLInst_0.CLKOK_DIV = 2 ;
    defparam PLLInst_0.CLKOP_DIV = 4 ;
    defparam PLLInst_0.CLKFB_DIV = 4 ;
    defparam PLLInst_0.CLKI_DIV = 1 ;
    defparam PLLInst_0.FIN = "50.000000" ;
    EHXPLLF PLLInst_0 (.CLKI(CLK), .CLKFB(CLKOP_t), .RST(scuba_vlo), .RSTK(scuba_vlo), 
        .WRDEL(scuba_vlo), .DRPAI3(DPHASE3), .DRPAI2(DPHASE2), .DRPAI1(DPHASE1), 
        .DRPAI0(DPHASE0), .DFPAI3(DFPAI3), .DFPAI2(DFPAI2), .DFPAI1(DFPAI1), 
        .DFPAI0(DFPAI0), .FDA3(FINEDELB3), .FDA2(FINEDELB2), .FDA1(FINEDELB1), 
        .FDA0(FINEDELB0), .CLKOP(CLKOP_t), .CLKOS(CLKOS_t), .CLKOK(), .CLKOK2(), 
        .LOCK(LOCK), .CLKINTFB())
             /* synthesis FREQUENCY_PIN_CLKOP="200.000000" */
             /* synthesis FREQUENCY_PIN_CLKOS="200.000000" */
             /* synthesis FREQUENCY_PIN_CLKI="50.000000" */;

    assign CLKOS = CLKOS_t;
    assign CLKOP = CLKOP_t;


    // exemplar begin
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKOP 200.000000
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKOS 200.000000
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKI 50.000000
    // exemplar end

endmodule
