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


module Or18(
    input [17:0] in,
    output out
    );
wire outa,outb,outc,outd,oute,outf;
wire out1,out2;

    
assign outa = in[17]|in[16]|in[15];
assign outb = in[14]|in[13]|in[12];
assign outc = in[11]|in[10]|in[9];
assign outd = in[8]|in[7]|in[6];
assign oute = in[5]|in[4]|in[3];
assign outf = in[2]|in[1]|in[0];

assign out1 = outa|outb|outc;
assign out2 = outd|oute|outf;

assign out = out1|out2;


endmodule
