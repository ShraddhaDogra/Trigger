`timescale 1 ps / 1 ps

module Input_Reg #(
    parameter WIDTH=48
    )( 
    input wire [WIDTH-1:0] D, 
    input wire clk, 
	input wire testsignal,
	input wire enTS,
    output wire [WIDTH-1:0] Q
    );

reg [WIDTH-1:0] c=0;
reg [WIDTH-1:0] t=0;
reg [WIDTH-1:0] rst=0;


//Rising edge of input sets output,falling edge of reset(diff) resets it.  Reset dominates.
genvar i;

generate
	for ( i = 0; i < WIDTH; i = i+1 )
			
	always @(posedge D[i] or posedge rst[i] )  //Rising edge of input sets output,
	begin
	if (rst[i]) c[i] <= 1'b0;
		else 
			begin
				if (!enTS) c[i] <= 1'b1;
			end
	end
endgenerate

genvar j;

generate
	for ( j = 0; j < WIDTH; j = j+1 )
	always @(posedge testsignal or posedge rst[j] )  //Rising edge of input sets output,
	begin
	if (rst[j]) t[j] <= 1'b0;
		else 
			begin
				if (enTS) t[j] <= 1'b1;
			end
	end
endgenerate

always @(negedge clk)  //Falling edge of clock resets output,
	rst <= c | t;

assign Q = c | rst | t;

endmodule