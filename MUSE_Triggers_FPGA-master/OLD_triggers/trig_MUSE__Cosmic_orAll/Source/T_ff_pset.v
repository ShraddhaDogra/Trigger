module
T_ff_pset( input T, input pset, output Q, output Qb);

reg C=1'b1;
reg Cb=1'b0;

always @(posedge T or posedge pset ) begin
	if (pset) begin
			Cb <= 1'b0;
			C <= 1'b1;
			end
		else begin
			Cb <=C;
			C <= ~C;
			end
	end

assign Q = C;
assign Qb = Cb;
endmodule