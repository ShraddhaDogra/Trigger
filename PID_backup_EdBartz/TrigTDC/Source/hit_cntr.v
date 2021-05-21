//-----------------------------------------------------                                  
// Design Name	: ehit_counter                                                         
// File Name	: ehit_cntr.v                                                       
// Function	: 16bit counter with load,clr,enable,carry                                                   
// Written By	: Ed Bartz
// Notes	: Not a full 163, en does not control carry                                                   
//-----------------------------------------------------      
`timescale 1 ps / 1 ps


module hit_counter (
input [31:0] hit, // 32 time slices,each gets a counter
input ld, 	// Parallel load enable
input ce,   // Count enable
input clk,	// clock input
input clr,	// reset input
output [15:0] q,// Output of the counter
output max 	// max out when first count = Max
);

wire [15:0] c1,c2,c3,c4,c5,c6,c7,c8,c9,c10;
wire [15:0] c11,c12,c13,c14,c15,c16,c17,c18,c19,c20;
wire [15:0] c21,c22,c23,c24,c25,c26,c27,c28,c29,c30;
wire [15:0] c31;
wire [31:0] cy;
reg [31:0] ehit;

parameter zero=16'd0;

always @(negedge clk) if (ce&~max)ehit<=hit; else ehit<=32'd0; //count enable

sync_counter cnt0(
.d(zero), 
.ld(ld),
.en(ehit[0]),
.clk(clk),
.clr(clr),
.q(c1),
.cy(cy[0])
);

sync_counter cnt1(
.d(c1), 
.ld(ld),
.en(ehit[1]),
.clk(clk),
.clr(clr),
.q(c2),
.cy(cy[1])
);

sync_counter cnt2(
.d(c2), 
.ld(ld),
.en(ehit[2]),
.clk(clk),
.clr(clr),
.q(c3),
.cy(cy[2])
);

sync_counter cnt3(
.d(c3), 
.ld(ld),
.en(ehit[3]),
.clk(clk),
.clr(clr),
.q(c4),
.cy(cy[3])
);

sync_counter cnt4(
.d(c4), 
.ld(ld),
.en(ehit[4]),
.clk(clk),
.clr(clr),
.q(c5),
.cy(cy[4])
);

sync_counter cnt5(
.d(c5), 
.ld(ld),
.en(ehit[5]),
.clk(clk),
.clr(clr),
.q(c6),
.cy(cy[5])
);

sync_counter cnt6(
.d(c6), 
.ld(ld),
.en(ehit[6]),
.clk(clk),
.clr(clr),
.q(c7),
.cy(cy[6])
);

sync_counter cnt7(
.d(c7), 
.ld(ld),
.en(ehit[7]),
.clk(clk),
.clr(clr),
.q(c8),
.cy(cy[7])
);

sync_counter cnt8(
.d(c8), 
.ld(ld),
.en(ehit[8]),
.clk(clk),
.clr(clr),
.q(c9),
.cy(cy[8])
);

sync_counter cnt9(
.d(c9), 
.ld(ld),
.en(ehit[9]),
.clk(clk),
.clr(clr),
.q(c10),
.cy(cy[9])
);

sync_counter cnt10(
.d(c10), 
.ld(ld),
.en(ehit[10]),
.clk(clk),
.clr(clr),
.q(c11),
.cy(cy[10])
);

sync_counter cnt11(
.d(c11), 
.ld(ld),
.en(ehit[11]),
.clk(clk),
.clr(clr),
.q(c12),
.cy(cy[11])
);

sync_counter cnt12(
.d(c12), 
.ld(ld),
.en(ehit[12]),
.clk(clk),
.clr(clr),
.q(c13),
.cy(cy[12])
);

sync_counter cnt13(
.d(c13), 
.ld(ld),
.en(ehit[13]),
.clk(clk),
.clr(clr),
.q(c14),
.cy(cy[13])
);

sync_counter cnt14(
.d(c14), 
.ld(ld),
.en(ehit[14]),
.clk(clk),
.clr(clr),
.q(c15),
.cy(cy[14])
);

sync_counter cnt15(
.d(c15), 
.ld(ld),
.en(ehit[15]),
.clk(clk),
.clr(clr),
.q(c16),
.cy(cy[15])
);

sync_counter cnt16(
.d(c16), 
.ld(ld),
.en(ehit[16]),
.clk(clk),
.clr(clr),
.q(c17),
.cy(cy[16])
);

sync_counter cnt17(
.d(c17), 
.ld(ld),
.en(ehit[17]),
.clk(clk),
.clr(clr),
.q(c18),
.cy(cy[17])
);

sync_counter cnt18(
.d(c18), 
.ld(ld),
.en(ehit[18]),
.clk(clk),
.clr(clr),
.q(c19),
.cy(cy[18])
);

sync_counter cnt19(
.d(c19), 
.ld(ld),
.en(ehit[19]),
.clk(clk),
.clr(clr),
.q(c20),
.cy(cy[19])
);

sync_counter cnt20(
.d(c20), 
.ld(ld),
.en(ehit[20]),
.clk(clk),
.clr(clr),
.q(c21),
.cy(cy[20])
);

sync_counter cnt21(
.d(c21), 
.ld(ld),
.en(ehit[21]),
.clk(clk),
.clr(clr),
.q(c22),
.cy(cy[21])
);

sync_counter cnt22(
.d(c22), 
.ld(ld),
.en(ehit[22]),
.clk(clk),
.clr(clr),
.q(c23),
.cy(cy[22])
);

sync_counter cnt23(
.d(c23), 
.ld(ld),
.en(ehit[23]),
.clk(clk),
.clr(clr),
.q(c24),
.cy(cy[23])
);

sync_counter cnt24(
.d(c24), 
.ld(ld),
.en(ehit[24]),
.clk(clk),
.clr(clr),
.q(c25),
.cy(cy[24])
);

sync_counter cnt25(
.d(c25), 
.ld(ld),
.en(ehit[25]),
.clk(clk),
.clr(clr),
.q(c26),
.cy(cy[25])
);

sync_counter cnt26(
.d(c26), 
.ld(ld),
.en(ehit[26]),
.clk(clk),
.clr(clr),
.q(c27),
.cy(cy[26])
);

sync_counter cnt27(
.d(c27), 
.ld(ld),
.en(ehit[27]),
.clk(clk),
.clr(clr),
.q(c28),
.cy(cy[27])
);

sync_counter cnt28(
.d(c28), 
.ld(ld),
.en(ehit[28]),
.clk(clk),
.clr(clr),
.q(c29),
.cy(cy[28])
);

sync_counter cnt29(
.d(c29), 
.ld(ld),
.en(ehit[29]),
.clk(clk),
.clr(clr),
.q(c30),
.cy(cy[29])
);

sync_counter cnt30(
.d(c30), 
.ld(ld),
.en(ehit[30]),
.clk(clk),
.clr(clr),
.q(c31),
.cy(cy[30])
);

sync_counter cnt31(
.d(c31), 
.ld(ld),
.en(ehit[31]),
.clk(clk),
.clr(clr),
.q(q),
.cy(cy[31])
);

assign max = cy[0] | cy[1] | cy[2] | cy[3] | cy[4] | cy[5] | cy[6] | cy[7] | cy[8] | cy[9] | cy[10] | cy[11] | cy[12] | cy[13] | cy[14] | cy[15] | cy[16] | cy[17] | cy[18] | cy[19] | cy[20] | cy[21] | cy[22] | cy[23] | cy[24] | cy[25] | cy[26] | cy[27] | cy[28] | cy[29] | cy[30] | cy[31];
endmodule  