module ReTrigger #(
 parameter WIDTH=48
 )
 ( 
 input [WIDTH-1:0] Pulse,Act, 
 input clk, 
 output [WIDTH-1:0] Q
 );

reg [47:0]retr=48'hffffffffffff;
reg [47:0]fin;
genvar i;

generate
	for ( i = 0; i < WIDTH; i = i+1 )
	begin : retrigger
		always @(posedge Pulse[i] or posedge fin[i]) begin
			if(~fin[i] & Act[i]) begin
				retr[i] <= 0;
				end
				else retr[i]<=1;
		end
			
		always @(posedge clk) begin
			fin[i]<= ~retr[i];
		end
	end
endgenerate

assign Q = retr;

endmodule