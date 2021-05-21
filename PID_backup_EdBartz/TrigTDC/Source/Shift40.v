//-----------------------------------------------------                                  
// Design Name	: Shift40                                                         
// File Name	: Shift40.v                                                       
// Function		: readout test of tdc                                                   
// Written By	: Ed Bartz
// Notes		: Temp test using John Doroshenkos readout hardware                                                 
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module Shift40(
	output wire [31:0] data, 		// 32 time slices,each gets a counter
	output wire [7:0] addr, 		// 32 time slices,each gets a counter
	input wire clk,    		// Output Serial Data Clock
	input wire en,
	input wire sda,
	output wire t
);

wire [40:0]c;
wire [40:0]ca; 

Ltch40 Pos(	
.clk(clk),    		
.en(en),
.Din({ca[39:0],sda}),
.Q(c)
);

Ltch40 Neg(	
.clk(~clk),    		
.en(en),
.Din(c),
.Q(ca)
);

assign data = c[32:1];
assign addr = c[40:33];
assign t = c[0];

endmodule