//-----------------------------------------------------                                  
// Design Name	: teststate                                                         
// File Name	: teststate.v                                                       
// Function	: State machine for readout test of tdc                                                   
// Written By	: Ed Bartz
// Notes	: Temp test using johns readout hardware                                                 
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module teststate(
	input wire start,
	input max,  // max out when first count = Max
	input wire clk,		// clock input
	input wire empty,
	output wire EnOut,
	output reg ld, 	// Parallel load enable
	output reg ce,   // Count enable
	output reg clr	// reset 
);
    parameter S1=0,S2=1,S3=2,S4=3,S5=4,S6=5,S7=6,S8=7;
    reg [2:0] State=0;
	
	reg [5:0]i;
	reg rden=0;
	//*******************************************************************

	always @(posedge clk) begin: Machine

		case (State)
		S1:  //Waiting for start
			begin
				ce <=0;
				ld <=0;
				clr<=1;
				if (start) State = S2;
			end
		S2:  //Clear counters
			begin
				clr <=1;
				State = S3;
			end
 
		S3: //Taking data - Waiting for max (.i.e. done taking data).
		   begin
			   i<=0;
			   clr <=0;
			   ce <=1;
			   if (max)State = S4;
			   if (!start) State = S1;
			end
		  
		S4:  
			begin
			   if (!start) State = S1;
				if(i<32)begin
					ld <=1;
					i <= i + 1;
					end
					else begin
						ld<=0;
						State = S5;
						end
			end
		S5:
			begin
			    if (!start) State = S1;
				if (!empty)begin				
					State = S6;
					end
			end
		S6:
			begin
			    if (!start) State = S1;
			    rden<=1;
				if (empty | !start)begin
					rden<=0;					
					State = S7;
					end
			end
		S7:
			begin
				  if (!start) State = S1;
			end
		S8:
			begin
				State = S1;				
			end

		endcase
	end// End Process.
assign EnOut = rden;

endmodule
