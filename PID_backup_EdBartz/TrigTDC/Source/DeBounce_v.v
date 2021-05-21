//-----------------------------------------------------                                  
// Design Name	: DeBounce                                                   
// File Name	: DeBounce_v.v                                                      
// Function		: readout test of tdc                                                   
// Written By	: Ed Bartz
// Notes		: Memory address 0x9000 to 0x9fff                                              
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module DeBounce(
	input wire D,			
	input wire clk,		
	output wire Q			
);

wire i,j;
//Clock Line Debounce.
FD1P3AY ClkA
(
.D(D),
.SP(1'b1),
.CK(clk),
.Q(i)
);	
	
FD1P3AY ClkB
(
.D(D & i),
.SP(1'b1),
.CK(clk),
.Q(j)
);	

FD1P3AY ClkC
(
.D(D & i & j),
.SP(1'b1),
.CK(clk),
.Q(Q)
);	

endmodule