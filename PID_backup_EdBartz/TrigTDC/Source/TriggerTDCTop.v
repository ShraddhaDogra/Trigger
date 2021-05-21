//----------------------------------------------------------
// Top  
//----------------------------------------------------------
`timescale 1 ps / 1 ps

module TriggerTDCTop(
input wire MCLK,
input wire [47:0] INP, 	//Data input
input wire IN_pA,  		// Input signal
input wire IN_pB, 
input wire IN_pC,
input wire IN_pD,
input wire reset_i,
output [2:0] OUT_pA,   	// Output signal
output [2:0] OUT_pB, 
output [2:0] OUT_pC,
output [1:0] OUT_pD,
output wire LED_GREEN, 	//LEDs
output wire LED_ORANGE, 
output wire LED_RED, 
output wire LED_YELLOW,
output wire [7:0] TestLED,
output wire [11:0] TestOut,
input wire [13:0] TestIn
);

wire [5:0] clk;

wire rst;
//assign rst = ~reset_i;


//********************************
//Make lights blink so we know something is happening.
leds Blink(
    .clk(clk[3]),
    .green(LED_GREEN),
    .yellow(LED_YELLOW),
    .orange(LED_ORANGE),
    .red(LED_RED)	
    );
//********************************

	wire[31:0] data; 	// 32 bits data to TBC
	wire [15:0] addr; 	// 16 bit address of register
	wire [31:0] rdata;	// 32 bits data from TBC
	wire ack;			// data acknownledge
	wire unknown;		// unknown address
	wire nack;			// not acknownledge?
	wire wr;			// Data Write
	wire rd;			// Data Read
	wire timeout;		// What timeout?
	
	wire [6:0]test;
	
	wire SDa1;			// Serial Data line
	wire  SCl1, SDa, SCl, RDa;
	
	assign SDa1 = TestIn[12];
	assign SCl1 = TestIn[13];
	assign OUT_pD[1] = RDa;
//	assign OUT_pD[1] = clk[3];
	assign OUT_pD[0] = RDa; //to give it something to do.

DeBounce SDaA(
	.D(SDa1),			
	.clk(clk[2]),		
	.Q(SDa)			
);

DeBounce SClA(
	.D(SCl1),			
	.clk(clk[2]),		
	.Q(SCl)			
);
wire Electron, Muon, Pion;

	assign TestOut[0] = MCLK;
	assign TestOut[1] = test[1];
	assign TestOut[2] = test[2];
	assign TestOut[3] = test[3];
	
	assign TestOut[4] = Electron;
	assign TestOut[6] = Muon;
	assign TestOut[5] = Pion;
	assign TestOut[7] = SDa1;
	
	assign TestOut[8] = SDa;
	assign TestOut[9] = SCl;
	assign TestOut[10] = RDa;	
	assign TestOut[11] = test[4];
//	assign TestOut[11] = timeout;
	
//assign 	TestLED = data[7:0];


assign OUT_pA[0] = Electron;
assign OUT_pA[1] = Muon;
assign OUT_pA[2] = Pion;

/*
assign OUT_pA[0] = clk[0];
assign OUT_pA[1] = clk[1];
assign OUT_pA[2] = clk[2];
*/
//assign TestLED = ~data[7:0];
comnet FEC(
	.data(data), // 32 bits data to TBC
	.addr(addr),// 16 bit address of register
	.rdata(rdata),// 32 bits data from TBC
	.clk(clk[2]),    		// Clock
	.ack(ack),			// data acknownledge
	.unknown(unknown),		// unknown address
	.nack(nack),		// not acknownledge?
	.wr(wr),			// Data Write
	.rd(rd),			// Data Read
	.timeout(timeout),	// What timeout?
	.SDa(SDa),			// Serial Data line
	.SCl(SCl),			// Serial Clk line
	.RDa(RDa),			// Return Serial Data line
	.test()  //c[0]
);


TriggerTDC  TDC(
	    .MCLK(MCLK),
        .INP(INP), 
        .IN_pD(IN_pD),
		.rst(rst),
		.Electron(Electron),
		.Muon(Muon),
		.Pion(Pion),
        .OUT_pD(OUT_pD),
		.TestLED(TestLED),
		.TestOut(),
		.TestIn(TestIn),
//Communications 
		.data(data), 		// 32 bits data to TBC
		.addr(addr),		// 16 bit address of register
		.rdata(rdata),		// 32 bits data from TBC
		.Cclk(clk[2]),  		// Clock
		.ack(ack),			// data acknownledge
		.unknown(unknown),		// unknown address
		.nack(nack),		// not acknownledge?
		.wr(wr),			// Data Write
		.rd(rd),			// Data Read
		.clk(clk),
		.test(test)
        );	
endmodule