`timescale 1ns / 1ps

module DelayBit #(
 parameter STAGES=4
 )(
    input  wire DlyIn,
    input  wire reTrig,	
    output wire DlyOut,
    input wire clk
    );

   reg [7:0] res;

always @(posedge clk or negedge DlyIn) begin 
     if(~DlyIn) begin
       res[0] <= 0;
	   res[1] <= 0;
       res[2] <= 0;
	   res[3] <= 0;
       res[4] <= 0;
	   res[5] <= 0;
       res[6] <= 0;
	   res[7] <= 0;
       end
      else begin
		  res[0] <= (DlyIn);
		  res[1] <= (res[0] && reTrig);
		  res[2] <= (res[1] && reTrig);
		  res[3] <= (res[2] && reTrig);
		  res[4] <= (res[3] && reTrig);
		  res[5] <= (res[4] && reTrig);
		  res[6] <= (res[5] && reTrig);
		  res[7] <= (res[6] && reTrig);
		  end
    end
 
   assign DlyOut = res[STAGES];

endmodule