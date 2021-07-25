module
SR_Reg ( input [47:0] set,rst, input clk, output [47:0] Q);

genvar i;

generate
	for ( i = 0; i < 48; i = i+1 )
	begin : mySRreg
		T_ff_clr ltch(.T(set[i]),.clr(rst[i]),.Q(Q[i]));
	end
endgenerate
endmodule