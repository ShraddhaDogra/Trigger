`timescale 1ns / 1ps

module FineTimeBit (
    input  wire DIn,
    input  wire [5:0]clk,	
    output reg [31:0]Result
    );

reg [31:0]c;
reg CIn0,CIn3 = 0;



always @(posedge clk[5] or posedge CIn3) begin
		if (CIn3) CIn0<= 1'b0;
			else CIn0 <= 1;				
		end
		
always @(posedge clk[0]) begin
    c[28]<=c[24];	
    c[24]<=c[20];	
    c[20]<=c[16];	
    c[16]<=c[12];	
    c[12]<=c[8];	
    c[8]<=c[4];	
    c[4]<=c[0];	
 //   c[0]<=c[31];	
     c[0]<=CIn0;
	end
always @(posedge clk[1]) begin
    c[29]<=c[25];	
    c[25]<=c[21];	
    c[21]<=c[17];	
    c[17]<=c[13];	
    c[13]<=c[9];	
    c[9]<=c[5];	
    c[5]<=c[1];	
    c[1]<=CIn0;	
	end

always @(posedge clk[2]) begin
    c[30]<=c[26];	
    c[26]<=c[22];	
    c[22]<=c[18];	
    c[18]<=c[14];	
    c[14]<=c[10];	
    c[10]<=c[6];	
    c[6]<=c[2];	
    c[2]<=CIn0;	
	end

always @(posedge clk[3]) begin
    c[31]<=c[27];	
    c[27]<=c[23];	
    c[23]<=c[19];	
    c[19]<=c[15];	
    c[15]<=c[11];	
    c[11]<=c[7];	
    c[7]<=c[3];	
    c[3]<=CIn0;	
	CIn3<=CIn0;
	end
	
always @(posedge DIn) begin
		Result<=c;
		end

endmodule