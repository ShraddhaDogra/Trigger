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

always @(negedge DIn)switch <= ~switch;

reg clr1,clr2;

always @(posedge (DIn & switch) or posedge clr1) begin
	if (clr1) l1 <=36'd0;
		else begin
		l1[31:0]<=c;
	    l1[35:32]<=c[3:0];	
		end
	end
always @(posedge (DIn & !switch) or posedge clr2) begin
	if (clr2) l2 <=36'd0;
		else begin
		l2[31:0]<=c;
	    l2[35:32]<=c[3:0];	
		end
	end
	
	
//**************************************************************************************************
//Create clr1 and clr 2, after neg edge clk[4] but narrow so load is not interfered with.  
//But remember switch over is controlled by negedge DIn.... Maybe that should changed....

//Put a thing here to replace assign d = l1 | l2; based on switch and clock l1/l2 -> d;  Mux I think.
//**************************************************************************************************





genvar k,l;
generate
for (k = 0; k < 32; k = k + 1)
	begin
		always @(posedge clk[4])begin
			f[k] <= ((d[k] | ~d[k+4]) & d[k+1] & d[k+2] & d[k+3]);
		end
	end
endgenerate	

always @(posedge clk[4]) begin	
	Result <= f;
	end


endmodule