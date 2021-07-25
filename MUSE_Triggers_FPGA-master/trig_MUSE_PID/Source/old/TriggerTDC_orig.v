//----------------------------------------------------------
// Top  
//----------------------------------------------------------

module TriggerTDC(MCLK,INP,IN_pA,IN_pB,IN_pC,OUT_pA, OUT_pB, OUT_pC, LED_GREEN, LED_ORANGE, LED_RED, LED_YELLOW);

input MCLK;
input [63:0] INP; //Data input
input  IN_pA, IN_pB, IN_pC;
output [2:0] OUT_pA, OUT_pB, OUT_pC; //Data Output
output LED_GREEN, LED_ORANGE, LED_RED, LED_YELLOW;

wire [63:0] INP; 
wire IN_pA,IN_pB,IN_pC; 
reg [2:0] OUT_pA,OUT_pB,OUT_pC;

wire [5:0] clk;

//Make lights blink so we know something is happening.
leds Blink(
    .clk(MCLK),
    .green(),
    .yellow(LED_YELLOW),
    .orange(LED_ORANGE),
    .red(LED_RED)	
    );
 
    parameter CA = 4'd15;
    parameter FCA = 4'd7;
	
    parameter Ph0 = 4'd0;
    parameter Ph1 = 4'd4;
    parameter Ph2 = 4'd8;
    parameter Ph3 = 4'd12;
    parameter FPh0 = 4'd0;
    parameter FPh1 = 4'd0;
    parameter FPh2 = 4'd0;
    parameter FPh3 = 4'd0;
	
//Main clock - must change from 200MHz to 50 MHz external later	
Cpll PClk (
	.CLK(MCLK),
	.FINEDELB0(FCA[0]), 
	.FINEDELB1(FCA[1]), 
	.FINEDELB2(FCA[2]), 
    .FINEDELB3(FCA[3]), 
    .DPHASE0(CA[0]), 
    .DPHASE1(CA[1]), 
    .DPHASE2(CA[2] ), 
    .DPHASE3(CA[3] ),	
	.CLKOP(clk[4]), 
	.CLKOS(clk[5]), 
	.LOCK()
	);

//0 Phase 400MHz
Cpll0 P0Clk (
	.CLK(clk[4]),
	.FINEDELB0(FPh0[0]), 
	.FINEDELB1(FPh0[1]), 
	.FINEDELB2(FPh0[2]), 
    .FINEDELB3(FPh0[3]), 
    .DPHASE0(Ph0[0]), 
    .DPHASE1(Ph0[1]), 
    .DPHASE2(Ph0[2] ), 
    .DPHASE3(Ph0[3] ),		.RSTK(1'b0), 
	.CLKOP(), 
	.CLKOS(clk[0]), 
	.CLKOK(), 
	.LOCK()
	);
//90 Phase 400MHz
Cpll1 P1Clk (
	.CLK(clk[4]),
	.FINEDELB0(FPh1[0]), 
	.FINEDELB1(FPh1[1]), 
	.FINEDELB2(FPh1[2]), 
    .FINEDELB3(FPh1[3]), 
    .DPHASE0(Ph1[0]), 
    .DPHASE1(Ph1[1]), 
    .DPHASE2(Ph1[2] ), 
    .DPHASE3(Ph1[3] ),		
	.CLKOP( ), 
	.CLKOS(clk[1]), 
	.LOCK()
	);
//180 Phase 400MHz
Cpll2 P2Clk (
	.CLK(clk[4]),
	.FINEDELB0(FPh2[0]), 
	.FINEDELB1(FPh2[1]), 
	.FINEDELB2(FPh2[2]), 
    .FINEDELB3(FPh2[3]), 
    .DPHASE0(Ph2[0]), 
    .DPHASE1(Ph2[1]), 
    .DPHASE2(Ph2[2] ), 
    .DPHASE3(Ph2[3] ),		
	.CLKOP( ), 
	.CLKOS(clk[2]), 
	.LOCK()
	);
//270 Phase 400MHz
Cpll3 P3Clk (
	.CLK(clk[4]),
	.FINEDELB0(FPh3[0]), 
	.FINEDELB1(FPh3[1]), 
	.FINEDELB2(FPh3[2]), 
    .FINEDELB3(FPh3[3]), 
    .DPHASE0(Ph3[0]), 
    .DPHASE1(Ph3[1]), 
    .DPHASE2(Ph3[2] ), 
    .DPHASE3(Ph3[3] ),		
	.CLKOP(), 
	.CLKOS(clk[3]), 
	.LOCK(LED_GREEN)
	);

wire y;
Input_Bit TestIn( 
    .in(INP[0]), 
    .clk(clk[0]), 
    .out(y)
    );
	
wire [31:0]res;
FineTimeBit fb1(
    .DIn(y),
    .clk(clk),	
    .Result(res)
    );

endmodule