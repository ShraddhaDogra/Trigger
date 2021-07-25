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


module Or8(
    input [7:0] in,
    output out
    );
wire outa,outb,outc;

assign outa = in[7]|in[6];
assign outb = in[5]|in[4]|in[3];
assign outc = in[2]|in[1]|in[0];

assign out = outa|outb|outc;

endmodule
