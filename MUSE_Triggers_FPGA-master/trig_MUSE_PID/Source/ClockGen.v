//-----------------------------------------------------                                  
// Design Name	: ClockGen                                                         
// File Name	: ClockGen.v                                                       
// Function		: readout test of tdc                                                   
// Written By	: Ed Bartz
// Notes		:                                                
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module ClockGen(
input wire MCLK,
output wire [5:0] clk,
output wire locked,
//Communications-Local Bus.
output wire [31:0] DataOut,
input wire [31:0] DataIn,
input wire [7:0] Address,
input wire Read,
input wire Write,
input wire rst,
output wire [7:0]LED
);
    parameter CA = 4'd0; //50Mhz phase - CFig [3:0]
    parameter FCA = 4'd0; //50MHz fine phase - CFig [7:4]
	
    parameter Ph0 = 4'd0; //0First 400Mhz phase - CFig [11:8]
    parameter FPh0 = 4'd0;//First 400Mhz fine phase - CFig [15:12]
    parameter DC0 = 4'd8;//First 400Mhz Duty Cycle - CFig [19:16]
	
    parameter Ph1 = 4'd4; //Second 400Mhz phase - CFig [23:20]
    parameter FPh1 = 4'd0; //Second 400Mhz fine phase - CFig [27:24]
    parameter DC1 = 4'd8;//Second 400Mhz 400Mhz Duty Cycle - CFig [31:28]


 wire [31:0] DataOut1, DataOut2;

assign DataOut = DataOut1 | DataOut2;

wire [31:0] CFig;
Register #(8'hC0,{DC1,Ph1,FPh1,DC0,Ph0,FPh0,CA,FCA}) Cf
(
	.DataOut(DataOut1),
	.DataIn(DataIn),
	.Address(Address),
	.Read(Read),
	.Write(Write),
	.rst(rst),
	.Q(CFig),
	.ack()
);
//Main clock - must change from 200MHz to 50 MHz external later	
Cpll PClk (
	.CLK(MCLK),
	.FINEDELB0(CFig[0]), 
	.FINEDELB1(CFig[1]), 
	.FINEDELB2(CFig[2]), 
    .FINEDELB3(CFig[3]), 
    .DPHASE0(CFig[4]), 
    .DPHASE1(CFig[5]), 
    .DPHASE2(CFig[6] ), 
    .DPHASE3(CFig[7] ),	
	.CLKOP(clk[2]), 
	.CLKOS(), 
	.CLKOK(), 
	.LOCK()
	);
/*
//0 Phase 400MHz
Cpll0 P0Clk (
	.CLK(clk[4]),
	.FINEDELB0(CFig[8]), 
	.FINEDELB1(CFig[9]), 
	.FINEDELB2(CFig[10]), 
    .FINEDELB3(CFig[11]), 
    .DPHASE0(CFig[12]), 
    .DPHASE1(CFig[13]), 
    .DPHASE2(CFig[14]), 
    .DPHASE3(CFig[15]),	
    .DDUTY0(CFig[16]),
    .DDUTY1(CFig[17]),
    .DDUTY2(CFig[18]),
    .DDUTY3(CFig[19]),
	.RSTK(1'b0), 
	.CLKOP(), 
	.CLKOS(clk[0]), 
	.CLKOK(), 
	.LOCK()
	);*/
//0 & 90 Phase 400MHz
Cpll1 P1Clk (
	.CLK(clk[2]),
	.FINEDELB0(CFig[20]), 
	.FINEDELB1(CFig[21]), 
	.FINEDELB2(CFig[22]), 
    .FINEDELB3(CFig[23]), 
    .DPHASE0(CFig[24]), 
    .DPHASE1(CFig[25]), 
    .DPHASE2(CFig[26]), 
    .DPHASE3(CFig[27]),		
    .DDUTY0(CFig[28]),
    .DDUTY1(CFig[29]),
    .DDUTY2(CFig[30]),
    .DDUTY3(CFig[31]),
	.CLKOP(clk[0]), 
	.CLKOS(clk[1]), 
	.LOCK(locked)
	);
	
assign LED[1:0] = DataIn[1:0];
//assign LED[3:2] = CFig1[1:0];
assign LED[4] = Write;
assign LED[5] = Read;
assign LED[6] = rst;

wire [31:0] CFig1;

Register #(8'hC3,32'h00000000) Cf1
(
	.DataOut(DataOut2),
	.DataIn(DataIn),
	.Address(Address),
	.Read(Read),
	.Write(Write),
	.rst(rst),
	.Q(CFig1),
	.ack()
);

//assign LED = ~CFig1[7:0];
//Test Signal 50MHz
Cpll2 P2Clk (
	.CLK(clk[2]),
	.FINEDELB0(CFig1[0]), 
	.FINEDELB1(CFig1[1]),
	.FINEDELB2(CFig1[2]), 
    .FINEDELB3(CFig1[3]), 
    .DPHASE0(CFig1[4]), 
    .DPHASE1(CFig1[5]), 
    .DPHASE2(CFig1[6]), 
    .DPHASE3(CFig1[7]),	
	.CLKOP(), 
	.CLKOS(clk[3]), 
	.LOCK()
	);
/*
    parameter Ph2 = 4'd4;
    parameter Ph3 = 4'd4;
    parameter Ph5 = 4'd0;
    parameter FPh2 = 4'd0;
    parameter FPh3 = 4'd0;
    parameter FPh5 = 4'd0;

//180 Phase 400MHz
Cpll2 P2Clk (
	.CLK(clk[1]),
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
	.CLK(clk[2]),
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
	.LOCK()
	);

	
//100MHz

Cpll4 P5Clk (
	.CLK(clk[3]),
	.FINEDELB0(FPh5[0]), 
	.FINEDELB1(FPh5[1]), 
	.FINEDELB2(FPh5[2]), 
    .FINEDELB3(FPh5[3]), 
    .DPHASE0(Ph5[0]), 
    .DPHASE1(Ph5[1]), 
    .DPHASE2(Ph5[2] ), 
    .DPHASE3(Ph5[3] ),		
	.CLKOP(), 
	.CLKOS(clk[5]), 
	.LOCK()
	);
*/

endmodule