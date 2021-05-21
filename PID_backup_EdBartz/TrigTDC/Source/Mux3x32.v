//-----------------------------------------------------                                  
// Design Name	: Mux3x32                                                         
// File Name	: Mux3x32.v                                                       
// Function		: 32 bit 3 to 1 mux                                                 
// Written By	: Ed Bartz
// Notes		:                                                
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module Mux3x32 (
    input wire [31:0]D0,
    input wire [31:0]D1,
    input wire [31:0]D2,
    input  wire [1:0]S,
    input  wire clk,	
    output reg [31:0]Q
    );
	
    parameter S0=0,S1=1,S2=2;
 	
		always @(posedge clk) begin

		case (S)
			S0:Q<=D0;
			S1:Q<=D1;
			S2:Q<=D2;
		endcase
		end
endmodule