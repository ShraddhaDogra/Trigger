//-----------------------------------------------------                                  
// Design Name	: Ltch33                                                         
// File Name	: Ltch33.v                                                       
// Function		: readout test of tdc                                                   
// Written By	: Ed Bartz
// Notes		: Temp test using John Doroshenkos readout hardware                                                 
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module Ltch33(	
	input wire clk,    		
	input wire en,
	input wire  [32:0] Din,
	output wire [32:0] Q
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

FD1P3AY d8
(
.D(Din[8]),
.SP(en),
.CK(clk),
.Q(Q[8])
);

FD1P3AY d9
(
.D(Din[9]),
.SP(en),
.CK(clk),
.Q(Q[9])
);
FD1P3AY d10
(
.D(Din[10]),
.SP(en),
.CK(clk),
.Q(Q[10])
);

FD1P3AY d11
(
.D(Din[11]),
.SP(en),
.CK(clk),
.Q(Q[11])
);

FD1P3AY d12
(
.D(Din[12]),
.SP(en),
.CK(clk),
.Q(Q[12])
);

FD1P3AY d13
(
.D(Din[13]),
.SP(en),
.CK(clk),
.Q(Q[13])
);

FD1P3AY d14
(
.D(Din[14]),
.SP(en),
.CK(clk),
.Q(Q[14])
);

FD1P3AY d15
(
.D(Din[15]),
.SP(en),
.CK(clk),
.Q(Q[15])
);

FD1P3AY d16
(
.D(Din[16]),
.SP(en),
.CK(clk),
.Q(Q[16])
);

FD1P3AY d17
(
.D(Din[17]),
.SP(en),
.CK(clk),
.Q(Q[17])
);

FD1P3AY d18
(
.D(Din[18]),
.SP(en),
.CK(clk),
.Q(Q[18])
);

FD1P3AY d19
(
.D(Din[19]),
.SP(en),
.CK(clk),
.Q(Q[19])
);

FD1P3AY d20
(
.D(Din[20]),
.SP(en),
.CK(clk),
.Q(Q[20])
);

FD1P3AY d21
(
.D(Din[21]),
.SP(en),
.CK(clk),
.Q(Q[21])
);

FD1P3AY d22
(
.D(Din[22]),
.SP(en),
.CK(clk),
.Q(Q[22])
);

FD1P3AY d23
(
.D(Din[23]),
.SP(en),
.CK(clk),
.Q(Q[23])
);

FD1P3AY d24
(
.D(Din[24]),
.SP(en),
.CK(clk),
.Q(Q[24])
);

FD1P3AY d25
(
.D(Din[25]),
.SP(en),
.CK(clk),
.Q(Q[25])
);

FD1P3AY d26
(
.D(Din[26]),
.SP(en),
.CK(clk),
.Q(Q[26])
);

FD1P3AY d27
(
.D(Din[27]),
.SP(en),
.CK(clk),
.Q(Q[27])
);

FD1P3AY d28
(
.D(Din[28]),
.SP(en),
.CK(clk),
.Q(Q[28])
);

FD1P3AY d29
(
.D(Din[29]),
.SP(en),
.CK(clk),
.Q(Q[29])
);

FD1P3AY d30
(
.D(Din[30]),
.SP(en),
.CK(clk),
.Q(Q[30])
);

FD1P3AY d31
(
.D(Din[31]),
.SP(en),
.CK(clk),
.Q(Q[31])
);

FD1P3AY d32
(
.D(Din[32]),
.SP(en),
.CK(clk),
.Q(Q[32])
);

endmodule