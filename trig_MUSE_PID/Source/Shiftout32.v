//-----------------------------------------------------                                  
// Design Name	: Shiftout32                                                         
// File Name	: Shiftout32.v                                                       
// Function		: readout test of tdc                                                   
// Written By	: Ed Bartz
// Notes		: Temp test using John Doroshenkos readout hardware                                                 
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module Shiftout32(
	input wire [31:0] data, 		// 32 time slices,each gets a counter
	input wire clk,    		// Output Serial Data Clock
	input wire ld,
	output wire RDa
);

wire [31:0]c;
wire [31:0]ca; 
wire [31:0]cb;
wire [31:0]cc;

genvar i;

generate
	for ( i = 1; i < 32; i = i+1 )	begin
		assign c[i] = (ld & data[i]) | (~ld & ca[i-1]);
		assign cb[i] = ld & data[i];
		assign cc[i] = ~ld & ca[i-1];
		end
endgenerate
assign c[0] = (ld & data[0]);

Ltch32 RDaLtch(	
	.clk(~clk),    		
	.en(1'b1),
	.Din(c),
	.Q(ca)
);

assign RDa = ca[31];

/*
reg [31:0]c;
reg [31:0]ca; 

	always @(negedge clk) 
		begin
			if(ld)c<=data;
				else c<=ca;
		end
		
	always @(posedge clk) ca<={c[30:0],1'b0};

assign RDa = c[31];
*/
endmodule