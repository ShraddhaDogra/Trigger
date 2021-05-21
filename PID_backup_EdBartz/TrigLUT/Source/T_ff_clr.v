module
T_ff_clr( input T, input clr, output Q);

reg C=0;

always @(posedge T or posedge clr ) 
	if (clr) C <= 1'b0;
		else C <= ~C;
			

assign Q = C;
endmodule