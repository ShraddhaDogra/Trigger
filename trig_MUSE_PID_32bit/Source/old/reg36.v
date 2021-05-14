module reg36(
 input wire [31:0]d,
 input wire clk, clr,
 output reg[35:0] q
 );
 always @(posedge clk or posedge clr) begin
	 if (clr) q <=36'd0;
		 else begin
			 q[31:0]<=d;
			 q[35:32]<=d[3:0];
			 end
	 end
endmodule