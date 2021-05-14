//-----------------------------------------------------                                  
// Design Name	: Mux16x32                                                         
// File Name	: Mux16x32.v                                                       
// Function		: 32 bit 16 to 1 mux                                                 
// Written By	: Ed Bartz
// Notes		:                                                
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module Mux16x32 (
    input wire [31:0]D0,
    input wire [31:0]D1,
    input wire [31:0]D2,
    input wire [31:0]D3,
    input wire [31:0]D4,
    input wire [31:0]D5,
    input wire [31:0]D6,
    input wire [31:0]D7,
    input wire [31:0]D8,
    input wire [31:0]D9,
    input wire [31:0]D10,
    input wire [31:0]D11,
    input wire [31:0]D12,
    input wire [31:0]D13,
    input wire [31:0]D14,
    input wire [31:0]D15,
    input  wire [3:0]S,
    input  wire clk,	
    output reg [31:0]Q
    );
	
    parameter S0=0,S1=1,S2=2,S3=3,S4=4,S5=5,S6=6,S7=7;
    parameter S8=8,S9=9,S10=10,S11=11,S12=12,S13=13,S14=14,S15=15;	
		always @(posedge clk) begin
		
		case (S)
			S0:Q<=D0;
			S1:Q<=D1;
			S2:Q<=D2;
			S3:Q<=D3;
			S4:Q<=D4;
			S5:Q<=D5;
			S6:Q<=D6;
			S7:Q<=D7;
			S8:Q<=D8;
			S9:Q<=D9;
			S10:Q<=D10;
			S11:Q<=D11;
			S12:Q<=D12;
			S13:Q<=D13;
			S14:Q<=D14;
			S15:Q<=D15;
		endcase
		end
endmodule