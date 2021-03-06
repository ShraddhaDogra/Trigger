// TOOL:     vlog2tf
// DATE:     Thu Feb 19 09:49:41 2015
 
// TITLE:    Lattice Semiconductor Corporation
// MODULE:   Top
// DESIGN:   Top
// FILENAME: TrigTDC_tf.v
// PROJECT:  Unknown
// VERSION:  2.0
// This file is auto generated by the Diamond 

`timescale 1 ps / 1 ps

// Define Module for Test Fixture
module TrigTDC_comcheck_tf();

parameter CLOCK_CYCLE = 10000;

// Inputs
	reg [31:0] rdata; 		
	reg Sclk;
	reg ack = 0;
	reg unknown = 0;
	reg nack = 0;
	reg SDa = 1;

    reg rst=1;
	
	// Outputs
	wire[31:0] data;
	wire[15:0] addr;
	wire wr;
	wire rd;
	wire timeout;
	
// Bidirs

// Global set/reset and power up reset signal drivers  For SIM ONLY (Note Active low signals).
     GSR GSR_INST (.GSR (~rst));
     PUR PUR_INST (.PUR (~rst));
	 defparam PUR_INST.RST_PULSE = 10;
	 
// Instantiate the UUT
comnet UUT(
	.data(data), 		
	.addr(addr), 
	.rdata(rdata), 
	.clk(Sclk),   
	.ack(ack),	
	.unknown(unknown),	
	.nack(nack),
	.wr(wr),	
	.rd(rd),	
	.timeout(timeout),
	.SDa(SDa),
	.SCl(Sclk)
);


	// define clock
	initial Sclk = 0;
        always #(CLOCK_CYCLE/2.0)
        	begin
        		Sclk = ~Sclk;
        	end

// Initialize Inputs
// You can add your stimulus here
    initial begin

			#10000 rst = 0;
			#17500 SDa = 0;
			#05000 SDa = 1;
			
			#80000 SDa = 0;
			
			#40000 SDa = 1;
			#40000 SDa = 0;
			#40000 SDa = 1;
			#40000 SDa = 0;
			#40000 SDa = 1;
			#40000 SDa = 0;
			#40000 SDa = 1;
			#40000 SDa = 0;
			#05000 SDa = 1;
			

//			#199300 INP=64'h0000000000000001;
//			#200000 INP=64'h0000000000000001;
//			#200900 INP=64'h0000000000000001;
//			#202100 INP=64'h0000000000000001;
			
			
			#(5000*CLOCK_CYCLE);
    end

endmodule // ScatterTrig_tf