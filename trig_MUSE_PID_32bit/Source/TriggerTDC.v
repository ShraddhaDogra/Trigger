//----------------------------------------------------------
// The actual TDC 
//----------------------------------------------------------
`timescale 1 ps / 1 ps

module TriggerTDC(
input wire MCLK,
input wire [31:0] INP, 	//Data input
input wire IN_pD,  		// Input signal
output wire rst,
output wire Electron,
output wire Muon,
output wire Pion,
output wire Electronup,
output wire Electrondown,
output wire Muonup,
output wire Muondown,
output wire Pionup,
output wire Piondown,
output [1:0] OUT_pD,
output wire [7:0] TestLED,
output wire [11:0] TestOut,
input wire [13:0] TestIn,
//Communications
input wire[31:0] data, 	// 32 bits data to TDC
input wire [15:0] addr,	// 16 bit address of register
output wire [31:0] rdata,// 32 bits data from TDC
input wire Cclk,    	// Clock
output wire ack,		// data acknownledge
output wire unknown,	// unknown address
output wire nack,		// not acknownledge?
input wire wr,			// Data Write
input wire rd,			// Data Read
output wire [5:0] clk,
output wire [6:0]test,
input wire clk_100_i
);

//wire [5:

wire locked;
wire [31:0] SData;
wire [31:0] RData5;
wire [31:0] RData4;
wire [31:0] RData1;
wire [31:0] RData2;
wire [31:0] RData3;
wire [31:0] RData0;

assign RData0 = RData1 | RData2 | RData3 | RData4 | RData5; // Combine data from various sources.
wire [7:0] Address;
wire Read;
wire Write;
wire [5:0]TestChNum;
wire StartTest;

//Control Register- Histogram Test/Input Test Signal
wire [31:0] CFig;

Register #(8'hC1,32'h00000040) Cf
(
	.DataOut(RData3),
	.DataIn(SData),
	.Address(Address),
	.Read(Read),
	.Write(Write),
	.rst(rst),
	.Q(CFig),
	.ack()
);

//Control Register- Histogram Test/Input Test Signal

wire [31:0] CFig2;

Register #(8'hC2,32'h80000000) Cf4
(
	.DataOut(RData5),
	.DataIn(SData),
	.Address(Address),
	.Read(Read),
	.Write(Write),
	.rst(rst),
	.Q(CFig2),
	.ack()
);

//Test Signal
wire testsignal,enTestSignal;
assign testsignal = clk[3];//default clk[3]
assign enTestSignal = CFig2[31];

//Histogram Test
wire stIn;
assign TestChNum = CFig[5:0];
assign stIn = CFig[6];

ComTrans CT(
//TRB Net
		.data(data), 		// 32 bits data to TBC
		.addr(addr),		// 16 bit address of register
		.rdata(rdata),		// 32 bits data from TBC
		.Cclk(Cclk),  		// Clock -- default Cclk
		.ack(ack),			// data acknownledge
		.unknown(unknown),	// unknown address
		.nack(nack),		// not acknownledge?
		.wr(wr),			// Data Write
		.rd(rd),		    // Data Read
//Local Bus.
		.DataOut(SData),
		.DataIn(RData0),
		.Address(Address),
		.Read(Read),
		.Write(Write),
		.clk_100_i(clk_100_i)
);

//assign TestLED = ~addr[7:0];
//assign TestLED = ~SData[7:0];

ClockGen CG(
	.MCLK(MCLK),
	.clk(clk),
	.locked(locked),
//Communications
	.DataOut(RData1),
	.DataIn(SData),
	.Address(Address),
	.Read(Read),
	.Write(Write),
	.rst(rst),
	.LED(TestLED)
);

assign rst = ~locked;

wire [47:0] DIn1;
wire [31:0] res;

Input_Reg #(.WIDTH(32)) DataInReg ( 
    .D(INP[31:0]), 
    .clk(clk[0]), 
	.testsignal(testsignal),
	.enTS(enTestSignal),
    .Q(DIn1)
    );

//assign TestOut[8] = DIn1[0];
//Comment out for faster compiling without the channels
//assign res = 32'b0;
//assign test = 6'b0;
//assign Electron = 0;
//assign Muon = 0;
//assign Pion = 0;
//assign RData2 = 32'b0;

Ch32 Tdc(
    .DIn(DIn1),
	.clk(clk),
    .Result(res),
	.TestChNum(TestChNum),
    .Electron(Electron),
    .Muon(Muon),
    .Pion(Pion),
	.Electronup(Electronup),
	.Electrondown(Electrondown),
	.Muonup(Muonup),
	.Muondown(Muondown),
	.Pionup(Pionup),
	.Piondown(Piondown),
	//Communications
	.DataOut(RData2),
	.DataIn(SData),
	.Address(Address),
	.Read(Read),
	.Write(Write),
	.rst(rst),
	.test(test)
    );




//Does the counting on each time slice, then outputs results when full.
timestatics ts(
	.start(stIn),
	.hit(res), 
	.clk(clk),		// clock input
		//Com Link
	.DataOut(RData4),
	.Address(Address),
	.Read(Read),
	.rst(rst),
	.ack()
	);
//********************************	

endmodule