module Input_Reg #(
    parameter WIDTH=48
    )( 
    input [47:0] set,rst, 
    input clk, 
    output [47:0] Q
    );

reg [WIDTH-1:0] C=0;
reg [WIDTH-1:0] rst1=1;
wire [WIDTH-1:0] diff;
genvar i;

generate
	for ( i = 0; i < WIDTH; i = i+1 )
	begin : input_reg
		
always @(negedge clk) rst1[i]<=~rst[i]; //Used to narrow reset to half a clock period.

//Rising edge of input sets output,	falling edge of reset(diff) resets it.  Reset dominates.	
always @(posedge set[i] or posedge diff[i] )  //Rising edge of input sets output,
	if (diff[i]) C[i] <= 1'b0;
		else C[i] <= 1'b1;
end
endgenerate

assign diff = rst & rst1; //Used to narrow reset to half a clock period.
assign Q = C;

endmodule