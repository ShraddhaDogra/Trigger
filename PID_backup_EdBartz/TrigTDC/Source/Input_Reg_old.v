`timescale 1 ps / 1 ps

module Input_Reg #(
    parameter WIDTH=46
    )( 
    input [WIDTH-1:0] D, 
    input clk, 
    output [WIDTH-1:0] Q
    );

reg [WIDTH-1:0] c=0;
reg [WIDTH-1:0] rst=0;

//Rising edge of input sets output,falling edge of reset(diff) resets it.  Reset dominates.
genvar i;

generate
	for ( i = 0; i < WIDTH; i = i+1 )
	
	always @(posedge D[i] or posedge rst[i] )  //Rising edge of input sets output,
	begin
	if (rst[i]) c[i] <= 1'b0;
		else c[i] <= 1'b1;
	end
endgenerate

always @(negedge clk)  //Rising edge of input sets output,
	rst <= c;

assign Q = c | rst;

endmodule