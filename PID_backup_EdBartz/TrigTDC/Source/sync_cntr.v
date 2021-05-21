//-----------------------------------------------------                                  
// Design Name	: sync_counter                                                         
// File Name	: sync_cntr.v                                                       
// Function	: 16bit counter with load,clr,enable,carry                                                   
// Written By	: Ed Bartz
// Notes	: Not a 163, en does not control carry                                                   
//-----------------------------------------------------   
`timescale 1 ps / 1 ps
                               
module sync_counter #(
	  parameter MAX=16'd50000
//    parameter MAX=16'hFff0
//	  parameter MAX=16'h0003
    )(
input wire [15:0] d, // Parallel load for the counter
input wire ld, 	// Parallel load enable
input wire en,	// Enable counting
input wire clk,	// clock input
input wire clr,	// reset input
output wire [15:0] q,// Output of the counter
output reg cy 	// Carry out when count = Max
);

reg [15:0] cnt=0;

always @(posedge clk)begin
//clr,ld,increment counter
if (clr) begin
  cnt <= 16'b0 ;
end 
else if (ld) begin
  cnt <= d;
end 
//else if (en & ~cy) begin
else if (en) begin
  cnt <= cnt + 1;
	end
	
//Carry, always even if not enabled	
if (cnt >= MAX)cy <= 1'd1;
  	else cy <= 1'd0;


end

assign q = cnt;

endmodule  