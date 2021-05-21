//-----------------------------------------------------                                  
// Design Name	: Shift32                                                         
// File Name	: Shift32.v                                                       
// Function		: readout test of tdc                                                   
// Written By	: Ed Bartz
// Notes		: Temp test using John Doroshenkos readout hardware                                                 
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module Shift33(
	output wire [32:0] data, 		// 32 time slices,each gets a counter
	input wire clk,    		// Output Serial Data Clock
	input wire en,
	input wire sda
);

wire [32:0]c;
wire [32:0]ca; 

Ltch40 Pos(	
.clk(clk),    		
.en(en),
.Din({ca[32:0],sda}),
.Q(c)
);

Ltch40 Neg(	
.clk(~clk),    		
.en(en),
.Din(c),
.Q(ca)
);

assign data = c[32:0];
endmodule