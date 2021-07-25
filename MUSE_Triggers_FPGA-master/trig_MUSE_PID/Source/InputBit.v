module Input_Bit( 
    input in, 
    input clk, 
    output out
    );

reg c = 0;
reg rst = 0;

//Rising edge of input sets output,	falling edge of reset(diff) resets it.  Reset dominates.	
always @(posedge in or posedge rst )  //Rising edge of input sets output,
	begin
	if (rst) c <= 1'b0;
		else c <= 1'b1;
end

always @(negedge clk)  //Rising edge of input sets output,
	rst <= c;

assign out = c;// | rst;


endmodule