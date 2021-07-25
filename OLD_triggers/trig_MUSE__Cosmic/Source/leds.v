`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2016 03:38:52 PM
// Design Name: 
// Module Name: BackOr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module leds(
	input wire clk,
    output wire green,
    output wire yellow,
    output wire orange,
    output wire red	
    );

reg [31:0] count;
reg a,b,c;


always @(posedge clk) begin  //divide clock down, so leds are slowly changing.
	count <= count +1;
	a<=~count[31];
	b<=~count[30];
	c<=~count[29];
	end
	
	assign green = 1'b0;
	assign red = a;
	assign orange = b;
	assign yellow = c;
	
endmodule
