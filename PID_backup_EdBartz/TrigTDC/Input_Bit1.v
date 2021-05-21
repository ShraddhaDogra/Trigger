module Input_Bit1( 
    input in, 
    input  wire [5:0]clk,
    output [3:0]out
    );

reg [3:0]c = 0;
reg rst = 0;

//Rising edge of input sets output,	falling edge of reset(diff) resets it.  Reset dominates.	
always @(posedge in or posedge rst )  //Rising edge of input sets output,
	begin
	if (rst) c <= 1'b0;
		else c <= 1'b1;
end

always @(posedge clk)  //Rising edge of input sets output,
	rst <= c;

assign out = c;// | rst;


endmodule