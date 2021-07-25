//-----------------------------------------------------                                  
// Design Name	: comnet                                                         
// File Name	: comenet.v                                                       
// Function		: readout test of tdc                                                   
// Written By	: Ed Bartz
// Notes		: Memory address 0x9000 to 0x9fff                                              
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module comnet(
	output reg[31:0] data, // 32 bits data to TBC
	output reg[15:0] addr,// 16 bit address of register
	input wire [31:0] rdata,// 32 bits data from TBC
	input wire clk,    		// Clock
	input wire ack,			// data acknownledge
	input wire unknown,		// unknown address
	input wire nack,		// not acknownledge?
	output reg wr,			// Data Write
	output reg rd,			// Data Read
	output wire timeout,	// What timeout?
	input wire SDa,			// Serial Data line
	input wire SCl,			// Serial Clk line
	input wire RDa,			// Serial return data line
	output wire [4:0]test
);
    parameter S1=0,S2=1,S3=2,S4=3,S5=4,S6=5,S7=6,S8=7;
    reg [2:0] State=0;
	reg write=0;
	reg [7:0]upperaddress=8'h90;
	reg [5:0] cnt;
	wire [32:0] Din;
	reg Rld=0;
//*******************************************************************
wire start;
//	assign timeout = start;
//	assign test[2:0] = cnt[2:0];

//assign test[3] = SCl;
//assign test[4] = SDa;

StrSt findstart(	
	.SDa(SDa),    		
	.SCl(SCl),
	.start(start),
	.stop()
//	.stop(test)
);
	always @(posedge SCl) begin
		if(start)cnt<= cnt+6'b1;
			else cnt <=6'b0;
	end
	
	always @(posedge SCl) begin: Machine
		case (State)
		S1:  //Waiting for start
			begin
//				addr <= 16'h0;
				rd<=1'b0;
				wr<=1'b0;
				if (start) State = S2;
			end
		S2:  //Taking data - Waiting for r/w 
 		   	begin
			if (cnt ==  6'd9)
				begin
					rd <= Din[0];
					addr <= {upperaddress,Din[8:1]};
					State = S3;
				end
			end
		S3:  //NEED TO CREATE Rld for READs, then one clk later turn off RLd
			begin
			    if (cnt ==  6'd14)
					begin
						Rld <= rd;
						State = S4;
					end
			end
		S4: 
			begin
				Rld <= 1'b0;				
				State = S5;
			end
		S5:
			begin	
			    if (cnt ==  6'd41)
					begin
						data <= Din[31:0];
						State = S6;
					end
			end
		S6:
			begin
				rd<=1'b0;
				State = S7;
			end
		S7:
			begin
				if(~rd)wr<=1'b1;
			    State = S8;
			end
		S8:
			begin
				wr<=1'b0;
				if(!start) State = S1;				
			end
		endcase
	end// End Process.
	
	Shift33 ComIn(
		.data(Din), 		// 32 time slices,each gets a counter
		.clk(SCl),    		// Output Serial Data Clock
		.en(start),
		.sda(SDa)
		);
		
     Shiftout32 ComOut(
		.data(rdata), 		// 32 time slices,each gets a counter
		.clk(SCl),    		// Output Serial Data Clock
		.ld(Rld),
		.RDa(RDa)
);	
endmodule