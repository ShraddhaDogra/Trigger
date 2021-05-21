//-----------------------------------------------------                                  
// Design Name	: StrSt                                                         
// File Name	: StrSt.v                                                       
// Function		: readout test of tdc                                                   
// Written By	: Ed Bartz
// Notes		: Temp test using John Doroshenkos readout hardware                                                 
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module StrSt(	
	input wire SDa,    		
	input wire SCl,
	output wire start,
	output wire stop	
);
wire x1,x2,x3,x4;

assign x1 = start | SCl;
assign x2 = start & SCl;
assign x3 = ~start;
assign x4 = ~SDa;


FD1P3DX StartFF
(
.D(x1),
.SP(1'b1),
.CK(x4),
.CD(stop),
.Q(start)
);

FD1P3DX StopFF
(
.D(x2),
.SP(1'b1),
.CK(SDa),
.CD(x3),
.Q(stop)
);

endmodule