//-----------------------------------------------------                                  
// Design Name	: wcomp                                                         
// File Name	: wcomp.v                                                       
// Function	: 32 bit comp                                                  
// Written By	: Ed Bartz
// Notes	: True if any A bits = any B bits                                                  
//-----------------------------------------------------   
`timescale 1 ps / 1 ps
                               
module wcomp (
input wire [31:0] A, // Input A
input wire [31:0] B, // Input B
input wire clk,	// clock input
output wire match    // True if any A bits = any B bits
);

//Compare bits.
reg [31:0] c;

genvar i;

generate
	for ( i = 0; i < 32; i = i+1 )
	
	always @(posedge clk )  c[i]<=A[i] & B[i];
endgenerate

wire d,e,f,g;
assign d = c[0] | c[1] | c[2] | c[3] | c[4] | c[5] | c[6] | c[7];
assign e = c[8] | c[9] | c[10] | c[11] | c[12] | c[13] | c[14] | c[15];
assign f = c[16] | c[17] | c[18] | c[19] | c[20] | c[21] | c[22] | c[23];
assign g = c[24] | c[25] | c[26] | c[27] | c[28] | c[29] | c[30] | c[31];
assign match = d | e | f |g;

endmodule  