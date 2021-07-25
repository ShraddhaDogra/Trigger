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
input wire [13:0] TestIn,
input wire [31:0] data, 	// 32 bits data to TDC
input wire [15:0] addr,	// 16 bit address of register
output wire[31:0] rdata,// 32 bits data from TDC
input wire rd,
input wire wr,
output wire ack,
output wire [5:0]clk,
input wire clk_100_i,
output wire [6:0]TRIG_OUT
);

//wire [5:0] clk;

wire rst;//wire netclk;
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
//	wire[31:0] data; 	// 32 bits data to TBC
//	wire [15:0] addr; 	// 16 bit address of register
//	wire [31:0] rdata;	// 32 bits data from TBC
//	wire ack;			// data acknownledge
	wire unknown;		// unknown address
	wire nack;			// not acknownledge?
//	wire wr;			// Data Write
//	wire rd;			// Data Read
	wire timeout;		// What timeout?
	assign timeout = wr;
	wire [6:0]test;

	//Code below is for communicating with John's external data taking board
	//should be rendered useless with trbnet
/*
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
*/
wire Electron, Muon, Pion,Electronup,Muonup,Pionup,Electrondown,Muondown,Piondown;
	//Temporarily removed for compile
	/*assign TestOut[0] = MCLK;
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
	assign TestOut[11] = test[4];*/
//	assign TestOut[11] = timeout;
	
//assign 	TestLED = data[7:0];

//pA OUTPUTs are partially covered by the data ribbon cable meaning the cable
//must be bent to access the outputs. So I (Ethan) am copying the pA OUTPUTs
//to pC as well just for ease of access.
assign OUT_pA[0] = Electronup;
assign OUT_pA[1] = Muonup;
assign OUT_pA[2] = Pionup;

assign OUT_pC[0] = Electrondown;
assign OUT_pC[1] = Muondown;
assign OUT_pC[2] = Piondown;

assign TRIG_OUT[0] = Electronup;
assign TRIG_OUT[1] = Muonup;
assign TRIG_OUT[2] = Pionup;
assign TRIG_OUT[3] = Electrondown;
assign TRIG_OUT[4] = Muondown;
assign TRIG_OUT[5] = Piondown;
assign TRIG_OUT[6] = Electronup|Muonup|Pionup|Electrondown|Muondown|Piondown;

assign OUT_pB[0] = Electronup|Muonup|Pionup|Electrondown|Muondown|Piondown;
assign OUT_pB[1] = Electronup|Muonup|Pionup;
assign OUT_pB[2] = Electrondown|Muondown|Piondown;

//assign TestLED = ~data[7:0];
//Function call to code using John's external data taking board
//should be rendered useless by trbnet
/*
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
*/

TriggerTDC  TDC(
	    .MCLK(MCLK),
        .INP(INP), 
        .IN_pD(IN_pD),
		.rst(rst),
		.Electron(Electron),
		.Muon(Muon),
		.Pion(Pion),
		.Electronup(Electronup),
		.Electrondown(Electrondown),
		.Muonup(Muonup),
		.Muondown(Muondown),
		.Pionup(Pionup),
		.Piondown(Piondown),
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
		.test(test),
		.clk_100_i(clk_100_i)
        );	
endmodule