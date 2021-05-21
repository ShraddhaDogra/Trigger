//-----------------------------------------------------                                  
// Design Name	: Ltch8                                                         
// File Name	: Ltch8.v                                                       
// Function		: readout test of tdc                                                   
// Written By	: Ed Bartz
// Notes		: Is this better than behavioral?                                           
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module Ltch8(	
	input wire clk,    		
	input wire en,
	input wire  [7:0] Din,
	output wire [7:0] Q
);

FD1P3AY d0
(
.D(Din[0]),
.SP(en),
.CK(clk),
.Q(Q[0])
);

FD1P3AY d1
(
.D(Din[1]),
.SP(en),
.CK(clk),
.Q(Q[1])
);

FD1P3AY d2
(
.D(Din[2]),
.SP(en),
.CK(clk),
.Q(Q[2])
);

FD1P3AY d3
(
.D(Din[3]),
.SP(en),
.CK(clk),
.Q(Q[3])
);

FD1P3AY d4
(
.D(Din[4]),
.SP(en),
.CK(clk),
.Q(Q[4])
);

FD1P3AY d5
(
.D(Din[5]),
.SP(en),
.CK(clk),
.Q(Q[5])
);

FD1P3AY d6
(
.D(Din[6]),
.SP(en),
.CK(clk),
.Q(Q[6])
);

FD1P3AY d7
(
.D(Din[7]),
.SP(en),
.CK(clk),
.Q(Q[7])
);

endmodule