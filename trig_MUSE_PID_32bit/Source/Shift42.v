//-----------------------------------------------------                                  
// Design Name	: Shift42                                                         
// File Name	: Shift42.v                                                       
// Function		: readout test of tdc                                                   
// Written By	: Ed Bartz
// Notes		: Temp test using John Doroshenkos readout hardware                                                 
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module Shift42(
	output wire [31:0] data, 		// 32 time slices,each gets a counter
	output wire rw,
	output wire [7:0] addr, 		// 32 time slices,each gets a counter
	input wire clk,    		// Output Serial Data Clock
	input wire en,
	input wire sda,
	output wire t
);

wire [41:0]c;
wire [41:0]ca; 

Ltch42 Pos(	
.clk(clk),    		
.en(en),
.Din({ca[40:0],sda}),
.Q(c)
);

Ltch42 Neg(	
.clk(~clk),    		
.en(en),
.Din(c),
.Q(ca)
);

//assign data = 32'hFFFFFFFF;
assign data = c[32:1];
assign rw = c[33];
assign addr = c[41:34];
assign t = c[0];

endmodule