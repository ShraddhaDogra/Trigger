`timescale 1ns / 1ps

module LeadDelay #(
 parameter STAGES=5, WIDTH=48
 )
(
    input  wire [WIDTH-1:0] DlyIn,
    input  wire [WIDTH-1:0] reTrig,	
    output wire [WIDTH-1:0] DlyOut,
    input wire clk
    );

//Create 48 bitwise delays
   genvar c;
   generate
      for (c = 0; c < WIDTH; c = c + 1) 
      begin: Bitwise_Delay
          DelayBit #(.STAGES(STAGES)) Dline(
            .DlyIn(DlyIn[c]),
            .reTrig(reTrig[c]),
            .DlyOut(DlyOut[c]),
            .clk(clk)
            );
      end
   endgenerate
endmodule