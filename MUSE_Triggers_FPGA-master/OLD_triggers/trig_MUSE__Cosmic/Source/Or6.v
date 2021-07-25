`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2016 02:29:06 PM
// Design Name: 
// Module Name: Or18
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


module Or6(
    input [5:0]in,
    output out
    );

   
assign out = in[5]&in[4]&in[3]&in[2]&in[1]&in[0];

endmodule