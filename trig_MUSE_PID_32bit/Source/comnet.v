//-----------------------------------------------------                                  
// Design Name	: comnet                                                         
// File Name	: comenet.v                                                       
// Function		: readout test of tdc                                                   
// Written By	: Ed Bartz
// Notes		: Memory address 0x9000 to 0x9fff                                              
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module comnet(
	output wire[31:0] data, // 32 bits data to TBC
	output wire [15:0] addr,// 16 bit address of register
	input wire [31:0] rdata,// 32 bits data from TBC
	input wire clk,    		// Clock
	input wire ack,			// data acknownledge
	input wire unknown,		// unknown address
	input wire nack,		// not acknownledge?
	output wire wr,			// Data Write
	output wire rd,			// Data Read
	output wire timeout,	// What timeout?
	input wire SDa,			// Serial Data line
	input wire SCl,			// Serial Clk line
	output wire RDa,			// Serial return data line
	output wire [4:0]test
);
    parameter S1=0,S2=1,S3=2,S4=3,S5=4,S6=5,S7=6,S8=7;
    reg [2:0] State=3'b0;
	reg write = 1'b0;
	reg read = 1'b0;
	reg [7:0]upperaddress=8'h00;
	reg Rld = 1'b0;
	wire rw;
	
//*******************************************************************
wire start;
//	assign timeout = start;
	assign timeout = wr;

StrSt findstart(	
	.SDa(SDa),    		
	.SCl(SCl),
	.start(start),
	.stop(test[0])
);

	always @(posedge clk) begin: Machine

		case (State)
		S1:  //Waiting for start
			begin
				if (start) State = S2;
			end
		S2:  //Clear counters
			begin
				if (!start)begin
					State = S3;
					end
			end
 
		S3: //Taking data - Waiting for max (.i.e. done taking data).
		   begin
			   State = S4;
			end
		  
		S4:  
			begin
					if (rw) read <= 1'b1;
						else write <= 1'b1;
					State = S5;
			end
		S5:
			begin			
					if (!SCl) begin
						Rld <= 1'b1;
						State = S6;
						end
			end
		S6:
			begin
					if (SCl) State = S7;
			end
		S7:
			begin
					if (!SCl) begin
						Rld <= 1'b0;
						State = S8;
						end
			end
		S8:
			begin
			    write<=0;
			    read<=0;				
				if (!start)begin
					State = S1;
					end			
			end
		endcase
	end// End Process.
		
	assign wr = write;
	assign rd = read;

		
	Shift42 shft42(
		.data(data), 		// 32 time slices,each gets a counter
		.rw(rw),
		.addr(addr[7:0]), 		// 32 time slices,each gets a counter
		.clk(SCl),    		// Output Serial Data Clock
		.en(start),
		.sda(SDa),
		.t()
		);
		
		
	assign addr[15:8] = upperaddress;
	
	     Shiftout32 ComOut(
		.data(rdata), 		// 32 time slices,each gets a counter
		.clk(SCl),    		// Output Serial Data Clock
		.ld(Rld),
		.RDa(RDa)
);

endmodule