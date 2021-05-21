`timescale 1ns / 1ps

module ShiftTime #(
    parameter Length=8
    )(
    input  wire [5:0]clk,	
    output wire [(4*Length-1):0]q,
    output wire [(4*Length-1):0]q1
    );

reg [(4*Length-1):0]c;
reg [4:0]CIn = 5'd0;

always @(posedge clk[4] or posedge CIn[3]) begin
		if (CIn[3]) CIn[4]<= 1'b0;
			else CIn[4] <= 1'b1;	
		end
		
genvar i,j;
generate
for (i = 0; i < 4; i = i + 1)
	for (j = 0; j < (Length - 1); j = j + 1)
		begin
			always @(posedge clk[i])c[(i+4*(j+1))] <= c[(i+4*j)];
		end
endgenerate	
			
always @(posedge clk[0]) begin
     c[0]<=CIn[0];
	 CIn[1]<=CIn[0];
	end
	
always @(posedge clk[1]) begin
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
assign q = c;
assign q1 = c;
endmodule