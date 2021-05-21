//-----------------------------------------------------                                  
// Design Name	: timestatics                                                         
// File Name	: timestatics.v                                                       
// Function		: readout test of tdc                                                   
// Written By	: Ed Bartz
// Notes		: Temp test using John Doroshenkos readout hardware                                                 
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module timestatics #(
    parameter MYAD=8'hC4
    )(
	input wire start,		// Start signal
	input [31:0] hit, 		// 32 time slices,each gets a counter
	input wire [5:0]clk,	// clock 
	//Com Link
	output wire [31:0] DataOut,
	input wire [7:0] Address,
	input wire Read,
	input wire rst,
	output reg ack

);

wire ldfifo,takedata,empty,enout,done,tofifo;
wire [15:0] fifodata;
wire [5:0] WCNT;
wire [5:0] RCNT;


hit_counter hc(
	.hit(hit),  	// 32 time slices,each gets a counter
	.ld(ldfifo), 	// Parallel load enable
	.ce(takedata), 	// Count enable
	.clk(clk[2]),	// clock input
	.clr(rst),		// reset input
	.q(fifodata),	// Output of the counter
	.max(done) 		// max out when first count = Max
);
wire clrtest;
teststate sm(
	.start(start),
	.max(done),  // max out when first count = Max
	.clk(clk[2]),		// clock input
	.empty(empty),
	.EnOut(enout),
	.ld(ldfifo), 	// Parallel load enable
	.ce(takedata),   // Count enable
	.clr(clrtest)	// reset test, not normal reset.
);
wire full, en, rdclk, addred;
reg Ren, RenBlk;
wire [31:0] Q;
wire test;
assign addred = (Address==MYAD);

// Read single value from FIFO
always @(negedge clk[2])
		begin
			if (addred & Read & ~RenBlk)Ren <=1'b1;
				else Ren <=1'b0;
		end

always @(posedge clk[2])
		begin
			if ((addred & Read & RenBlk) | Ren) RenBlk <=1'b1;
				else RenBlk <=1'b0;
		end

//assign rdclk = (addred & Read) | ( ~addred & clk[2]);
assign rdclk = clk[2];

genvar i;

generate
	for ( i = 0; i < 16; i = i+1 )	
assign DataOut[i] = addred & Read & Q[i];
endgenerate

genvar j;

generate
	for ( j = 0; j < 6; j = j+1 )	
assign DataOut[j+16] = addred & Read & RCNT[j];
endgenerate
genvar k;
generate
	for ( k = 22; k < 32; k = k+1 )	
assign DataOut[k] = 1'b0;
endgenerate


// Buffer data and serialize data from 16 bit in, to 1 out.
readoutfifo rfif (
	.Data(fifodata), 
	.WrClock(~clk[2]), 
	.RdClock(rdclk), 
	.WrEn(ldfifo), 
	.RdEn(Ren), 
	.Reset(clrtest|rst), 
	.RPReset(clrtest|rst), 
	.Q(Q),
	.WCNT(WCNT),
	.RCNT(RCNT), 
	.Empty(empty), 
	.Full()
	);
/*
generate
	for ( i = 0; i < 32; i = i+1 )	
assign DataOut[i] = ~rdclk & Q[i];
endgenerate

// Buffer data and serialize data from 16 bit in, to 1 out.
readoutfifo rfif (
	.Data(fifodata), 
	.WrClock(clk[2]), 
	.RdClock(rdclk), 
	.WrEn(ldfifo), 
	.RdEn(Ren), 
	.Reset(clrtest), 
	.RPReset(clrtest), 
	.Q(Q),
	.WCNT(WCNT),
	.RCNT(RCNT), 
	.Empty(empty), 
	.Full()
	);
*/
endmodule