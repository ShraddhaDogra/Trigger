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


module BackOr3(
    input [27:0] back, 
    output [17:0] ret
    );

assign ret[0]=back[1]|back[2]|back[3];//|back[0]|back[4];
assign ret[1]=back[2]|back[3]|back[4]|back[5];//|back[1]|back[6];
assign ret[2]=back[3]|back[4]|back[5]|back[6];//|back[2]|back[7];
assign ret[3]=back[5]|back[6]|back[7];//|back[4]|back[8];
assign ret[4]=back[6]|back[7]|back[8]|back[9];//|back[5]|back[10];
assign ret[5]=back[7]|back[8]|back[9]|back[10];//|back[6]|back[11];
assign ret[6]=back[9]|back[10]|back[11];//|back[8]|back[12];
assign ret[7]=back[10]|back[11]|back[12]|back[13];//|back[9]|back[14];
assign ret[8]=back[12]|back[13]|back[14];//|back[11]|back[15];
assign ret[9]=back[13]|back[14]|back[15];//|back[12]|back[16];
assign ret[10]=back[14]|back[15]|back[16]|back[17];//|back[13]|back[18];
assign ret[11]=back[16]|back[17]|back[18];//|back[15]|back[19];
assign ret[12]=back[17]|back[18]|back[19]|back[20];//|back[16]|back[21];
assign ret[13]=back[18]|back[19]|back[20]|back[21];//|back[17]|back[22];
assign ret[14]=back[20]|back[21]|back[22];//|back[19]|back[23];
assign ret[15]=back[21]|back[22]|back[23]|back[24];//|back[20]|back[25];
assign ret[16]=back[22]|back[23]|back[24]|back[25];//|back[21]|back[26];
assign ret[17]=back[24]|back[25]|back[26];//|back[23]|back[27];
endmodule
