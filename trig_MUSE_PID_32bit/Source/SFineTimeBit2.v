//-----------------------------------------------------                                  
// Design Name	: SFineTimeBit                                                         
// File Name	: SFineTimeBit.v                                                       
// Function		: Split 50MHz into 32 time slices                                                  
// Written By	: Ed Bartz
// Notes		: Special version for logic analyzer                                               
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module SFineTimeBit2 #(
    parameter Ch=6'd0
    )(
    input  wire DIn,
    input  wire [5:0]clk,
    output wire Electron,
    output wire Muon,
    output wire Pion,	
    output reg [31:0]Result,
    //Communications-Local Bus.
	output wire [31:0] DataOut,
	input wire [31:0] DataIn,
	input wire [7:0] Address,
	input wire Read,
	input wire Write,
	input wire rst,
	output wire [6:0]test
    );

//*********************************************************************
// Control Register Creation

wire [31:0] CFig, EW, PW, MW, DataOutC,DataOutE,DataOutP,DataOutM,DataOutLA;
assign DataOut = DataOutC | DataOutE | DataOutP | DataOutM | DataOutLA;

Register #({Ch,2'b00},32'hFFFFFFFF) Cf
(
	.DataOut(DataOutC),
	.DataIn(DataIn),
	.Address(Address),
	.Read(Read),
	.Write(Write),
	.rst(rst),
	.Q(CFig),
	.ack()
);

Register #({Ch,2'b01},32'hFFFFFFFF) ElectW
(
	.DataOut(DataOutE),
	.DataIn(DataIn),
	.Address(Address),
	.Read(Read),
	.Write(Write),
	.rst(rst),
	.Q(EW),
	.ack()
);

Register #({Ch,2'b10},32'h0000F000) PionW
(
	.DataOut(DataOutP),
	.DataIn(DataIn),
	.Address(Address),
	.Read(Read),
	.Write(Write),
	.rst(rst),
	.Q(PW),
	.ack()
);

Register #({Ch,2'b11},32'h0F000000) MuonW
(
	.DataOut(DataOutM),
	.DataIn(DataIn),
	.Address(Address),
	.Read(Read),
	.Write(Write),
	.rst(rst),
	.Q(MW),
	.ack()
);

//*********************************************************************
// Time Marker Register Creation


reg [6:0]CIn = 7'd0;  //Input bit for each shift reg
//assign test = {c1[0],c2[0],c3[0],c4[0],CIn[5],CIn[6]};
//assign test = {c1[7],c2[7],c3[7],c4[7],CIn[4],CIn[5],CIn[6]};

//**********************
//Fout Shift Regs start pulses
/*always @(posedge clk[1]) begin
	 CIn[5]<=~clk[2]; 
	 CIn[6]<=CIn[5];
	 CIn[3]<=CIn[6];
	 CIn[4]<=CIn[5]&~CIn[3];
	end
*/
/*
always @(negedge clk[0]) begin
//	 CIn[0]<=~CIn[0] & CIn[4]; //Setup first
	 CIn[0]<=CIn[4]; //Setup first
//	 CIn[0]<=CIn[4]; //Setup first

	end

always @(negedge clk[1]) begin
//	 CIn[1]<=~CIn[1] & CIn[0];  //Setup second 
	 CIn[1]<=CIn[0];  //Setup second 
    end
	
always @(posedge clk[0]) begin
//	 CIn[2]<=~CIn[2] & CIn[0]; //Setup third
	 CIn[2]<=CIn[0]; //Setup third
	end
*/
/*	
always @(posedge clk[1]) begin	
	CIn[3]<=~CIn[3] & CIn[1];  //Setup forth
	end
*/
/*	
always @(posedge clk[0]) begin
	 CIn[0]<=~CIn[0] & CIn[4]; //Setup first
	end

always @(posedge clk[1]) begin
	 CIn[1]<=~CIn[1] & CIn[0];  //Setup second 
    end
	
always @(negedge clk[0]) begin
	 CIn[2]<=~CIn[2] & CIn[0]; //Setup third
	end
	
always @(negedge clk[1]) begin	
	CIn[3]<=~CIn[3] & CIn[1];  //Setup forth
	end
*/	
always @(negedge clk[0]) begin
	 CIn[0]<=clk[2]; 
	end
wire [7:0]c1,c2,c3,c4;
wire [31:0] c; //Total length of full Time Marker reg

assign test = {CIn[6],CIn[5],CIn[4],c4[7],c3[7],c2[7],c1[7]};
//**********************
//Fout Shift Regs
Ltch8 Deg0(	
.clk(clk[0]),    		
.en(1'b1),
//.Din({c1[6:0],CIn[0]}),
.Din({c1[6:0],clk[2]}),
.Q(c1)
);
Ltch8 Deg90(	
.clk(clk[1]),    		
.en(1'b1),
.Din({c2[6:0],c1[0]}),
//.Din({c2[6:0],clk[2]}),
.Q(c2)
);
Ltch8 Deg180(	
.clk(~clk[0]),    		
.en(1'b1),
//.Din({c3[6:0],clk[2]}),
.Din({c3[6:0],c1[0]}),
.Q(c3)
);
Ltch8 Deg270(	
.clk(~clk[1]),    		
.en(1'b1),
//.Din({c4[6:0],clk[2]}),
.Din({c4[6:0],c2[0]}),
.Q(c4)
);
//**********************
assign c[0] = c1[0];
assign c[1] = c2[0];
assign c[2] = c3[0];
assign c[3] = c4[0];

assign c[4] = c1[1];
assign c[5] = c2[1];
assign c[6] = c3[1];
assign c[7] = c4[1];

assign c[8] = c1[2];
assign c[9] = c2[2];
assign c[10] = c3[2];
assign c[11] = c4[2];

assign c[12] = c1[3];
assign c[13] = c2[3];
assign c[14] = c3[3];
assign c[15] = c4[3];

assign c[16] = c1[4];
assign c[17] = c2[4];
assign c[18] = c3[4];
assign c[19] = c4[4];

assign c[20] = c1[5];
assign c[21] = c2[5];
assign c[22] = c3[5];
assign c[23] = c4[5];

assign c[24] = c1[6];
assign c[25] = c2[6];
assign c[26] = c3[6];
assign c[27] = c4[6];

assign c[28] = c1[7];
assign c[29] = c2[7];
assign c[30] = c3[7];
assign c[31] = c4[7];

//*********************************************************************

reg [31:0] TimeLtch;
reg [35:0] TimeLtch50;



//Latch sequence on DIn.
always @(posedge DIn) TimeLtch<=c;

//Move to 50MHz clock (clk[2]). Rearrangement for ease of decoding.
always @(posedge clk[2])begin
		TimeLtch50[6:0]  <= TimeLtch[19:13];
//		TimeLtch50[6:0]  <= TimeLtch[31:25];
	    TimeLtch50[35:7] <= TimeLtch[28:0];	
	end

// ***********Defining valid data.***************
//Toggle bit for switching between vd1 & vd2 for clearing hit register if no hit comes in.
reg switch = 1'd0;  

reg vd1a,vd1; 
reg vd2a,vd2; 
wire vd3;

always @(posedge clk[2])switch <= ~switch; //Ping/pong for valid data

//Valid data 1 bit
always @(posedge (DIn) or posedge vd2) begin
	if (vd2) vd2a <= 1'd0;
		else if(switch)vd2a <= 1'd1;
	end
	
//Valid data 2 bit.
always @(posedge (DIn) or posedge vd1) begin
	if (vd1) vd1a <= 1'd0;
		else if (!switch) vd1a <= 1'd1;
	end
	
//Produce Valid data bit, 1 clock period wide for either valid data chain.
always @(posedge clk[2]) begin
	vd1<=vd1a;
	vd2<=vd2a;
	end
	
//Multiplex between valid data bit, to produce vd3.
assign vd3 = (vd1 && switch) || (vd2 && ~switch);
//*****************************************

//Decode sequence to find leading edge, latch if vd3, otherwise clear.
// Technically the pattern should be 11110, but we have to deal with 01110 & 111110 as possiblilites due to timing issues.
// In the end, it was decided to just look for xxxx10, and be done. While it is concievable that somehow something 
// like 01010 might exist, and we get two hits, so what. Better extra hits, missed hits.


reg [31:0]decode = 32'b0;
genvar k;
generate
//for (k = 0; k < 32; k = k + 1)
for (k = 0; k < 20; k = k + 1)
	begin
		always @(posedge clk[2])begin
//			if (vd3) decode[k] <= ((TimeLtch50[k] | ~TimeLtch50[k+4]) & (TimeLtch50[k+1] & TimeLtch50[k+2] & TimeLtch50[k+3]));  
			if (vd3) decode[k] <= (TimeLtch50[k+1] & TimeLtch50[k+2] & TimeLtch50[k+3] & ~TimeLtch50[k+4]);  
//			if (vd3) decode[k] <= (TimeLtch50[k+2] & TimeLtch50[k+3] & ~TimeLtch50[k+4]);  
//			if (vd3) decode[k] <= (TimeLtch50[k+3] & ~TimeLtch50[k+4]);  
				else decode[k]<=1'd0;
		end
	end
endgenerate	

//Compare bits.
reg [31:0] tested;

genvar i;

generate
	for ( i = 0; i < 32; i = i+1 )
	
	always @(posedge clk[2] )  tested[i]<=decode[i] & EW[i];
endgenerate

Lanalyzer0 #(8'hE2,8'hFE,8'hFD)LA(
.Data(tested),
//.Data(Result),
.DClk(~clk[2]),   
//Com Link
.DataOut(DataOutLA),
.DataIn(DataIn),
.Address(Address),
.Read(Read),
.Write(Write),
.rdclk(clk[2]),
.rst(rst),
.ack()
);

always @(posedge clk[2])begin
	Result<=decode;
	end	
wire ME,MP,MM;	
wcomp El(
	.A(decode), 
	.B(EW), 
	.clk(clk[2]),	
	.match(ME)
);
wcomp Pn(
	.A(decode), 
	.B(PW), 
	.clk(clk[2]),	
	.match(MP)
);
wcomp Mn(
	.A(decode), 
	.B(MW), 
	.clk(clk[2]),	
	.match(MM)
);

assign Electron = ME & CFig[0];
assign Muon = MM & CFig[2];
assign Pion = MP & CFig[1];	

endmodule