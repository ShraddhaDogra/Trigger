`timescale 1ns / 1ps

module FineTimeBit #(
    parameter Length=8
    )(
    input  wire DIn,
    input  wire [5:0]clk,	
    output reg [(4*Length-1):0]Result
    );

reg [(4*Length-1):0]c;
reg [4:0]CIn = 5'd0;
reg switch = 1'd0;
reg switch1 = 1'd1;

//always @(posedge clk[5] or posedge CIn[3]) begin
always @(posedge clk[4] or posedge CIn[3]) begin
//		if (CIn[3]) CIn[0]<= 1'b0;
//			else CIn[0] <= 1'b1;	
//		c[0]<=CIn[0];
		if (CIn[3]) CIn[4]<= 1'b0;
			else CIn[4] <= 1'b1;	
		end
genvar i,j;
generate
for (i = 0; i < 4; i = i + 1)
	for (j = 0; j < (Length - 1); j = j + 1)
		begin
//				always @(posedge clk[0]) c[(4*(i+1))] <= c[(4*i)];
				always @(posedge clk[i])c[(i+4*(j+1))] <= c[(i+4*j)];
		end
endgenerate	
			
always @(posedge clk[0]) begin
     c[0]<=CIn[0];
	 CIn[1]<=CIn[0];
	end
	
always @(posedge clk[1]) begin
//    c[1]<=CIn[0];
//	 CIn[2]<=CIn[0];	
    c[1]<=CIn[1];
	 CIn[2]<=CIn[1];	
	end

always @(posedge clk[2]) begin
    c[2]<=CIn[2];
	 CIn[3]<=CIn[2];	
	end

always @(posedge clk[3]) begin
	c[3]<=CIn[3];
	CIn[0]<=CIn[4];
	end

reg [35:0] l1,l2;
wire [35:0] d;
reg [31:0] f;

always @(posedge DIn or posedge clk[4]) begin
//always @(posedge DIn) begin
	l1 <=36'd0;
	l2 <=36'd0;
//	if (DIn == 1'd1) begin
		l1[31:0]<=c;
	    l1[35:32]<=c[3:0];	
//		l2[31:0]<=c;
//	    l2[35:32]<=c[3:0];	
//		end
		
/*
	if (switch == 1'd1)	begin
		l1[31:0]<=c;
	    l1[35:32]<=c[3:0];	
		end
	else begin
		l2[31:0]<=c;
	    l2[35:32]<=c[3:0];		
		end
		*/
	end

assign d = l1;// | l2;

genvar k,l;
generate
for (k = 0; k < 32; k = k + 1)
	begin
		always @(posedge clk[4])begin
			f[k] <= ((d[k] | ~d[k+4]) & d[k+1] & d[k+2] & d[k+3]);
			switch <= ~switch;
		end
	end
endgenerate	

always @(posedge clk[4]) begin	
	Result <= f;
	end


endmodule