//-----------------------------------------------------                                  
// Design Name	: Ch32                                                         
// File Name	: CH32.v                                                       
// Function		: 32  channels of Fine time bits                                                 
// Written By	: Ed Bartz
// Notes		: Includes mux for testing.                                               
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module Ch32 (
    input  wire [31:0]DIn,
    input  wire [5:0]clk,
    output wire [31:0]Result,
    output wire Electron,
    output wire Muon,
    output wire Pion,
	output wire Electronup,
	output wire Electrondown,
	output wire Muonup,
	output wire Muondown,
	output wire Pionup,
	output wire Piondown,
	input wire [5:0]TestChNum,
	//Communications-Local Bus.
	output wire [31:0] DataOut,
	input wire [31:0] DataIn,
	input wire [7:0] Address,
	input wire Read,
	input wire Write,
	input wire rst,
	output wire [6:0]test
    );

wire [31:0]res0, DataOut0;
wire EL0,u0,P0;
FineTimeBit #(6'd0)fb0(
    .DIn(DIn[0]),
	.clk(clk),    
	.Electron(EL0),
    .Muon(u0),
    .Pion(P0),
    .Result(res0),
//Comm
    .DataOut(DataOut0),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res1, DataOut1;
wire EL1,u1,P1;
FineTimeBit #(6'd1)fb1(
    .DIn(DIn[1]),
	.clk(clk),    
	.Electron(EL1),
    .Muon(u1),
    .Pion(P1),
    .Result(res1),
//Comm
    .DataOut(DataOut1),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res2, DataOut2;
wire EL2,u2,P2;
FineTimeBit #(6'd2)fb2(
    .DIn(DIn[2]),
	.clk(clk),    
	.Electron(EL2),
    .Muon(u2),
    .Pion(P2),
    .Result(res2),
//Comm
    .DataOut(DataOut2),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res3, DataOut3;
wire EL3,u3,P3;
FineTimeBit #(6'd3)fb3(
    .DIn(DIn[3]),
	.clk(clk),    
	.Electron(EL3),
    .Muon(u3),
    .Pion(P3),
    .Result(res3),
//Comm
    .DataOut(DataOut3),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res4, DataOut4;
wire EL4,u4,P4;
FineTimeBit #(6'd4)fb4(
    .DIn(DIn[4]),
	.clk(clk),    
	.Electron(EL4),
    .Muon(u4),
    .Pion(P4),
    .Result(res4),
//Comm
    .DataOut(DataOut4),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res5, DataOut5;
wire EL5,u5,P5;
FineTimeBit #(6'd5)fb5(
    .DIn(DIn[5]),
	.clk(clk),    
	.Electron(EL5),
    .Muon(u5),
    .Pion(P5),
    .Result(res5),
//Comm
    .DataOut(DataOut5),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res6, DataOut6;
wire EL6,u6,P6;
FineTimeBit #(6'd6)fb6(
    .DIn(DIn[6]),
	.clk(clk),    
	.Electron(EL6),
    .Muon(u6),
    .Pion(P6),
    .Result(res6),
//Comm
    .DataOut(DataOut6),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res7, DataOut7;
wire EL7,u7,P7;
FineTimeBit #(6'd7)fb7(
    .DIn(DIn[7]),
	.clk(clk),    
	.Electron(EL7),
    .Muon(u7),
    .Pion(P7),
    .Result(res7),
//Comm
    .DataOut(DataOut7),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res8, DataOut8;
wire EL8,u8,P8;
FineTimeBit #(6'd8)fb8(
    .DIn(DIn[8]),
	.clk(clk),    
	.Electron(EL8),
    .Muon(u8),
    .Pion(P8),
    .Result(res8),
//Comm
    .DataOut(DataOut8),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res9, DataOut9;
wire EL9,u9,P9;
FineTimeBit #(6'd9)fb9(
    .DIn(DIn[9]),
	.clk(clk),    
	.Electron(EL9),
    .Muon(u9),
    .Pion(P9),
    .Result(res9),
//Comm
    .DataOut(DataOut9),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );

wire [31:0]res10, DataOut10;
wire EL10,u10,P10;
FineTimeBit #(6'd10)fb10(
    .DIn(DIn[10]),
	.clk(clk),    
	.Electron(EL10),
    .Muon(u10),
    .Pion(P10),
    .Result(res10),
//Comm
    .DataOut(DataOut10),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res11, DataOut11;
wire EL11,u11,P11;
FineTimeBit #(6'd11)fb11(
    .DIn(DIn[11]),
	.clk(clk),    
	.Electron(EL11),
    .Muon(u11),
    .Pion(P11),
    .Result(res11),
//Comm
    .DataOut(DataOut11),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res12, DataOut12;
wire EL12,u12,P12;
FineTimeBit #(6'd12)fb12(
    .DIn(DIn[12]),
	.clk(clk),    
	.Electron(EL12),
    .Muon(u12),
    .Pion(P12),
    .Result(res12),
//Comm
    .DataOut(DataOut12),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res13, DataOut13;
wire EL13,u13,P13;
FineTimeBit #(6'd13)fb13(
    .DIn(DIn[13]),
	.clk(clk),    
	.Electron(EL13),
    .Muon(u13),
    .Pion(P13),
    .Result(res13),
//Comm
    .DataOut(DataOut13),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res14, DataOut14;
wire EL14,u14,P14;
FineTimeBit #(6'd14)fb14(
    .DIn(DIn[14]),
	.clk(clk),    
	.Electron(EL14),
    .Muon(u14),
    .Pion(P14),
    .Result(res14),
//Comm
    .DataOut(DataOut14),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res15, DataOut15;
wire EL15,u15,P15;
FineTimeBit #(6'd15)fb15(
    .DIn(DIn[15]),
	.clk(clk),    
	.Electron(EL15),
    .Muon(u15),
    .Pion(P15),
    .Result(res15),
//Comm
    .DataOut(DataOut15),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res16, DataOut16;
wire EL16,u16,P16;
FineTimeBit #(6'd16)fb16(
    .DIn(DIn[16]),
	.clk(clk),    
	.Electron(EL16),
    .Muon(u16),
    .Pion(P16),
    .Result(res16),
//Comm
    .DataOut(DataOut16),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res17, DataOut17;
wire EL17,u17,P17;
FineTimeBit #(6'd17)fb17(
    .DIn(DIn[17]),
	.clk(clk),    
	.Electron(EL17),
    .Muon(u17),
    .Pion(P17),
    .Result(res17),
//Comm
    .DataOut(DataOut17),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res18, DataOut18;
wire EL18,u18,P18;
FineTimeBit #(6'd18)fb18(
    .DIn(DIn[18]),
	.clk(clk),    
	.Electron(EL18),
    .Muon(u18),
    .Pion(P18),
    .Result(res18),
//Comm
    .DataOut(DataOut18),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res19, DataOut19;
wire EL19,u19,P19;
FineTimeBit #(6'd19)fb19(
    .DIn(DIn[19]),
	.clk(clk),    
	.Electron(EL19),
    .Muon(u19),
    .Pion(P19),
    .Result(res19),
//Comm
    .DataOut(DataOut19),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res20, DataOut20;
wire EL20,u20,P20;
FineTimeBit #(6'd20)fb20(
    .DIn(DIn[20]),
	.clk(clk),    
	.Electron(EL20),
    .Muon(u20),
    .Pion(P20),
    .Result(res20),
//Comm
    .DataOut(DataOut20),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res21, DataOut21;
wire EL21,u21,P21;
FineTimeBit #(6'd21)fb21(
    .DIn(DIn[21]),
	.clk(clk),    
	.Electron(EL21),
    .Muon(u21),
    .Pion(P21),
    .Result(res21),
//Comm
    .DataOut(DataOut21),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res22, DataOut22;
wire EL22,u22,P22;
FineTimeBit #(6'd22)fb22(
    .DIn(DIn[22]),
	.clk(clk),    
	.Electron(EL22),
    .Muon(u22),
    .Pion(P22),
    .Result(res22),
//Comm
    .DataOut(DataOut22),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res23, DataOut23;
wire EL23,u23,P23;
FineTimeBit #(6'd23)fb23(
    .DIn(DIn[23]),
	.clk(clk),    
	.Electron(EL23),
    .Muon(u23),
    .Pion(P23),
    .Result(res23),
//Comm
    .DataOut(DataOut23),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res24, DataOut24;
wire EL24,u24,P24;
FineTimeBit #(6'd24)fb24(
    .DIn(DIn[24]),
	.clk(clk),    
	.Electron(EL24),
    .Muon(u24),
    .Pion(P24),
    .Result(res24),
//Comm
    .DataOut(DataOut24),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res25, DataOut25;
wire EL25,u25,P25;
FineTimeBit #(6'd25)fb25(
    .DIn(DIn[25]),
	.clk(clk),    
	.Electron(EL25),
    .Muon(u25),
    .Pion(P25),
    .Result(res25),
//Comm
    .DataOut(DataOut25),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res26, DataOut26;
wire EL26,u26,P26;
FineTimeBit #(6'd26)fb26(
    .DIn(DIn[26]),
	.clk(clk),    
	.Electron(EL26),
    .Muon(u26),
    .Pion(P26),
    .Result(res26),
//Comm
    .DataOut(DataOut26),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res27, DataOut27;
wire EL27,u27,P27;
FineTimeBit #(6'd27)fb27(
    .DIn(DIn[27]),
	.clk(clk),    
	.Electron(EL27),
    .Muon(u27),
    .Pion(P27),
    .Result(res27),
//Comm
    .DataOut(DataOut27),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res28, DataOut28;
wire EL28,u28,P28;
FineTimeBit #(6'd28)fb28(
    .DIn(DIn[28]),
	.clk(clk),    
	.Electron(EL28),
    .Muon(u28),
    .Pion(P28),
    .Result(res28),
//Comm
    .DataOut(DataOut28),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res29, DataOut29;
wire EL29,u29,P29;
FineTimeBit #(6'd29)fb29(
    .DIn(DIn[29]),
	.clk(clk),    
	.Electron(EL29),
    .Muon(u29),
    .Pion(P29),
    .Result(res29),
//Comm
    .DataOut(DataOut29),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res30, DataOut30;
wire EL30,u30,P30;
FineTimeBit #(6'd30)fb30(
    .DIn(DIn[30]),
	.clk(clk),    
	.Electron(EL30),
    .Muon(u30),
    .Pion(P30),
    .Result(res30),
//Comm
    .DataOut(DataOut30),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res31, DataOut31;
wire EL31,u31,P31;
FineTimeBit #(6'd31)fb31(
    .DIn(DIn[31]),
	.clk(clk),    
	.Electron(EL31),
    .Muon(u31),
    .Pion(P31),
    .Result(res31),
//Comm
    .DataOut(DataOut31),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res32, DataOut32;
wire EL32,u32,P32;
FineTimeBit #(6'd32)fb32(
    .DIn(DIn[32]),
	.clk(clk),    
	.Electron(EL32),
    .Muon(u32),
    .Pion(P32),
    .Result(res32),
//Comm
    .DataOut(DataOut32),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res33, DataOut33;
wire EL33,u33,P33;
FineTimeBit #(6'd33)fb33(
    .DIn(DIn[33]),
	.clk(clk),    
	.Electron(EL33),
    .Muon(u33),
    .Pion(P33),
    .Result(res33),
//Comm
    .DataOut(DataOut33),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res34, DataOut34;
wire EL34,u34,P34;
FineTimeBit #(6'd34)fb34(
    .DIn(DIn[34]),
	.clk(clk),    
	.Electron(EL34),
    .Muon(u34),
    .Pion(P34),
    .Result(res34),
//Comm
    .DataOut(DataOut34),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res35, DataOut35;
wire EL35,u35,P35;
FineTimeBit #(6'd35)fb35(
    .DIn(DIn[35]),
	.clk(clk),    
	.Electron(EL35),
    .Muon(u35),
    .Pion(P35),
    .Result(res35),
//Comm
    .DataOut(DataOut35),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res36, DataOut36;
wire EL36,u36,P36;
FineTimeBit #(6'd36)fb36(
    .DIn(DIn[36]),
	.clk(clk),    
	.Electron(EL36),
    .Muon(u36),
    .Pion(P36),
    .Result(res36),
//Comm
    .DataOut(DataOut36),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res37, DataOut37;
wire EL37,u37,P37;
FineTimeBit #(6'd37)fb37(
    .DIn(DIn[37]),
	.clk(clk),    
	.Electron(EL37),
    .Muon(u37),
    .Pion(P37),
    .Result(res37),
//Comm
    .DataOut(DataOut37),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res38, DataOut38;
wire EL38,u38,P38;
FineTimeBit #(6'd38)fb38(
    .DIn(DIn[38]),
	.clk(clk),    
	.Electron(EL38),
    .Muon(u38),
    .Pion(P38),
    .Result(res38),
//Comm
    .DataOut(DataOut38),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res39, DataOut39;
wire EL39,u39,P39;
FineTimeBit #(6'd39)fb39(
    .DIn(DIn[39]),
	.clk(clk),    
	.Electron(EL39),
    .Muon(u39),
    .Pion(P39),
    .Result(res39),
//Comm
    .DataOut(DataOut39),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res40, DataOut40;
wire EL40,u40,P40;
FineTimeBit #(6'd40)fb40(
    .DIn(DIn[40]),
	.clk(clk),    
	.Electron(EL40),
    .Muon(u40),
    .Pion(P40),
    .Result(res40),
//Comm
    .DataOut(DataOut40),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res41, DataOut41;
wire EL41,u41,P41;
FineTimeBit #(6'd41)fb41(
    .DIn(DIn[41]),
	.clk(clk),    
	.Electron(EL41),
    .Muon(u41),
    .Pion(P41),
    .Result(res41),
//Comm
    .DataOut(DataOut41),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res42, DataOut42;
wire EL42,u42,P42;
FineTimeBit #(6'd42)fb42(
    .DIn(DIn[42]),
	.clk(clk),    
	.Electron(EL42),
    .Muon(u42),
    .Pion(P42),
    .Result(res42),
//Comm
    .DataOut(DataOut42),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res43, DataOut43;
wire EL43,u43,P43;
FineTimeBit #(6'd43)fb43(
    .DIn(DIn[43]),
	.clk(clk),    
	.Electron(EL43),
    .Muon(u43),
    .Pion(P43),
    .Result(res43),
//Comm
    .DataOut(DataOut43),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res44, DataOut44;
wire EL44,u44,P44;
FineTimeBit #(6'd44)fb44(
    .DIn(DIn[44]),
	.clk(clk),    
	.Electron(EL44),
    .Muon(u44),
    .Pion(P44),
    .Result(res44),
//Comm
    .DataOut(DataOut44),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res45, DataOut45;
wire EL45,u45,P45;
FineTimeBit #(6'd45)fb45(
    .DIn(DIn[45]),
	.clk(clk),    
	.Electron(EL45),
    .Muon(u45),
    .Pion(P45),
    .Result(res45),
//Comm
    .DataOut(DataOut45),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res46, DataOut46;
wire EL46,u46,P46;
FineTimeBit #(6'd46)fb46(
    .DIn(DIn[46]),
	.clk(clk),    
	.Electron(EL46),
    .Muon(u46),
    .Pion(P46),
    .Result(res46),
//Comm
    .DataOut(DataOut46),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire [31:0]res47, DataOut47;
wire EL47,u47,P47;
FineTimeBit #(6'd47)fb47(
    .DIn(DIn[47]),
	.clk(clk),    
	.Electron(EL47),
    .Muon(u47),
    .Pion(P47),
    .Result(res47),
//Comm
    .DataOut(DataOut47),
    .DataIn(DataIn),
    .Address(Address),
    .Read(Read),
    .Write(Write),
    .rst(rst)
    );
    
wire ELA,ELB,ELC,ELD,ELE,ELF;
//assign ELA=EL0;
assign ELA=EL0|EL1|EL2|EL3|EL4|EL5|EL6|EL7;
assign ELB=EL8|EL9|EL10|EL11|EL12|EL13|EL14|EL15;
assign ELC=EL16|EL17|EL18|EL19|EL20|EL21|EL22|EL23;
assign ELD=EL24|EL25|EL26|EL27|EL28|EL29|EL30|EL31;
assign ELE=EL32|EL33|EL34|EL35|EL36|EL37|EL38|EL39;
assign ELF=EL40|EL41|EL42|EL43|EL44|EL45|EL46|EL47;
assign Electron=ELA|ELB|ELC|ELD|ELE|ELF;
assign Electronup = ELA|ELC;
assign Electrondown = ELB|ELD;
//assign Electron=ELA;


wire uA,uB,uC,uD,uE,uF;
//assign uA=u0;
assign uA=u0|u1|u2|u3|u4|u5|u6|u7;
assign uB=u8|u9|u10|u11|u12|u13|u14|u15;
assign uC=u16|u17|u18|u19|u20|u21|u22|u23;
assign uD=u24|u25|u26|u27|u28|u29|u30|u31;
assign uE=u32|u33|u34|u35|u36|u37|u38|u39;
assign uF=u40|u41|u42|u43|u44|u45|u46|u47;
assign Muon=uA|uB|uC|uD|uE|uF;
assign Muonup=uA|uC;
assign Muondown=uB|uD;
//assign Muon=uA;


wire PA,PB,PC,PD,PE,PF;
//assign PA=P0;
assign PA=P0|P1|P2|P3|P4|P5|P6|P7;
assign PB=P8|P9|P10|P11|P12|P13|P14|P15;
assign PC=P16|P17|P18|P19|P20|P21|P22|P23;
assign PD=P24|P25|P26|P27|P28|P29|P30|P31;
assign PE=P32|P33|P34|P35|P36|P37|P38|P39;
assign PF=P40|P41|P42|P43|P44|P45|P46|P47;
assign Pion=PA|PB|PC|PD|PE|PF;
assign Pionup=PA|PC;
assign Piondown=PB|PD;
//assign Pion=PA;

wire [31:0] DataOutA,DataOutB,DataOutC,DataOutD,DataOutE,DataOutF;
assign DataOutA=DataOut0|DataOut1|DataOut2|DataOut3|DataOut4|DataOut5|DataOut6|DataOut7;
assign DataOutB=DataOut8|DataOut9|DataOut10|DataOut11|DataOut12|DataOut13|DataOut14|DataOut15;
assign DataOutC=DataOut16|DataOut17|DataOut18|DataOut19|DataOut20|DataOut21|DataOut22|DataOut23;
assign DataOutD=DataOut24|DataOut25|DataOut26|DataOut27|DataOut28|DataOut29|DataOut30|DataOut31;
assign DataOutE=DataOut32|DataOut33|DataOut34|DataOut35|DataOut36|DataOut37|DataOut38|DataOut39;
assign DataOutF=DataOut40|DataOut41|DataOut42|DataOut43|DataOut44|DataOut45|DataOut46|DataOut47;
assign DataOut=DataOutA|DataOutB|DataOutC|DataOutD|DataOutE|DataOutF;

wire [31:0]m1;
Mux16x32 mux1(
    .D0(res0),
    .D1(res1),
    .D2(res2),
    .D3(res3),
    .D4(res4),
    .D5(res5),
    .D6(res6),
    .D7(res7),
    .D8(res8),
    .D9(res9),
    .D10(res10),
    .D11(res11),
    .D12(res12),
    .D13(res13),
    .D14(res14),
    .D15(res15),
    .S(TestChNum[3:0]),
    .clk(clk[2]),	
    .Q(m1)
    );
	
wire [31:0]m2;
Mux16x32 mux2(
    .D0(res16),
    .D1(res17),
    .D2(res18),
    .D3(res19),
    .D4(res20),
    .D5(res21),
    .D6(res22),
    .D7(res23),
    .D8(res24),
    .D9(res25),
    .D10(res26),
    .D11(res27),
    .D12(res28),
    .D13(res29),
    .D14(res30),
    .D15(res31),
    .S(TestChNum[3:0]),
    .clk(clk[2]),	
    .Q(m2)
    );
	
wire [31:0]m3;
Mux16x32 mux3(
    .D0(res32),
    .D1(res33),
    .D2(res34),
    .D3(res35),
    .D4(res36),
    .D5(res37),
    .D6(res38),
    .D7(res39),
    .D8(res40),
    .D9(res41),
    .D10(res42),
    .D11(res43),
    .D12(res44),
    .D13(res45),
    .D14(res46),
    .D15(res47),
    .S(TestChNum[3:0]),
    .clk(clk[2]),	
    .Q(m3)
    );
	

Mux3x32 mux4(
    .D0(m1),
    .D1(m2),
    .D2(m3),
    .S(TestChNum[5:4]),
    .clk(clk[2]),	
    .Q(Result)
    );
	endmodule