`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2016 04:13:32 PM
// Design Name: 
// Module Name: PulseStretch
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


module PulseStretch#(
 parameter STAGES=4,
 parameter WIDTH=48
 )(
    input [WIDTH-1:0] in,
    input clk,
    output [WIDTH-1:0] out
    );
    
    wire [WIDTH-1:0] res,InLtch,retr;
//    wire clk;
    
    Input_Reg #(
        .WIDTH(WIDTH)
        )ireg(  //Input latch for rising edges
    .set(in[WIDTH-1:0]),
    .rst(res),
    .clk(clk),
    .Q(out)
    );
    
    ReTrigger #(
        .WIDTH(WIDTH)
        )iretrig(  //Create retriggerability
    .Pulse(in[WIDTH-1:0]),
    .Act(out),
    .clk(clk),
    .Q(retr)
    );
    
    LeadDelay #(   // Pulse width extrension, using 200MHz clock.
     .STAGES(STAGES),  //Number of 5ns increments for delay
     .WIDTH(WIDTH)
     )leadEdgeDelay(
        .DlyIn(out),
        .reTrig(retr),    
        .DlyOut(res),
        .clk(clk)
        );
endmodule
