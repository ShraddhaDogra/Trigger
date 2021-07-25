module SR_Latch (input rst, input set, output q); 

wire qbar;

assign #2 q_i = q; 
assign #2 qbar_i = qbar; 
assign #2 q = ~ (rst | qbar); 
//assign #2 qbar = ~ ((set & ~rst) | q); 
assign #2 qbar = ~ ((set) | q); 
endmodule