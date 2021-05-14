//-----------------------------------------------------                                  
// Design Name	: SFineTimeBit                                                         
// File Name	: SFineTimeBit.v                                                       
// Function		: Split 50MHz into 32 time slices                                                  
// Written By	: Ed Bartz
// Notes		: Special version for logic analyzer                                               
//-----------------------------------------------------                                  
`timescale 1ns / 1ps

module SFineTimeBit #(
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
	input wire rst
    );

//*********************************************************************
// Control Register Creation

wire [31:0] CFig, EW, PW, MW, DataOutC,DataOutE,DataOutP,DataOutM,DataOutLA;
assign DataOut = DataOutC | DataOutE | DataOutP | DataOutM | DataOutLA;

Register #({Ch,2'b00},32'h00000000) Cf
(
	.DataOut(DataOutC),
	.DataIn(DataIn),
	.Address(Address),
	.Read(Read),
	.Write(Write),
	.rst(rst),
	.Q(CFig)
);

Register #({Ch,2'b01},32'h000000F0) ElectW
(
	.DataOut(DataOutE),
	.DataIn(DataIn),
	.Address(Address),
	.Read(Read),
	.Write(Write),
	.rst(rst),
	.Q(EW)
);

Register #({Ch,2'b10},32'h0000F000) PionW
(
	.DataOut(DataOutP),
	.DataIn(DataIn),
	.Address(Address),
	.Read(Read),
	.Write(Write),
	.rst(rst),
	.Q(PW)
);

Register #({Ch,2'b11},32'h0F000000) MuonW
(
	.DataOut(DataOutM),
	.DataIn(DataIn),
	.Address(Address),
	.Read(Read),
	.Write(Write),
	.rst(rst),
	.Q(MW)
);

//*********************************************************************
// Time Marker Register Creation


reg [4:0]CIn = 5'd0;  //Input bit for each shift reg

always @(posedge clk[4] or posedge CIn[0]) begin  //Start of shifting
		if (CIn[0]) CIn[4]<= 1'b0;
			else CIn[4] <= 1'b1;	
		end
always @(posedge clk[0]) begin
	 CIn[2]<=CIn[1]; //Setup third
	end
	
always @(posedge clk[1]) begin	
	CIn[3]<=CIn[2];  //Setup forth
	end

always @(negedge clk[0]) begin
	 CIn[0]<=CIn[4]; //Setup first
	end

always @(negedge clk[1]) begin
	 CIn[1]<=CIn[0];  //Setup second 
    end
	
wire [7:0]c1,c2,c3,c4;
wire [31:0] c; //Total length of full Time Marker reg

Ltch8 Deg0(	
.clk(clk[0]),    		
.en(1'b1),
.Din({c1[6:0],CIn[0]}),
.Q(c1)
);
Ltch8 Deg90(	
.clk(clk[1]),    		
.en(1'b1),
.Din({c2[6:0],CIn[1]}),
.Q(c2)
);
Ltch8 Deg180(	
.clk(~clk[0]),    		
.en(1'b1),
.Din({c3[6:0],CIn[2]}),
.Q(c3)
);
Ltch8 Deg270(	
.clk(~clk[1]),    		
.en(1'b1),
.Din({c4[6:0],CIn[3]}),
.Q(c4)
);
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

/*
reg [31:0] c; //Total length of full Time Marker reg
always @(posedge clk[0])begin 
    c[0] <= CIn[0];	//Start first reg     
	c[4] <= c[0];         
	c[8] <= c[4];         
	c[12]<= c[8];         
	c[16]<=c[12];         
	c[20]<=c[16];         
	c[24]<=c[20];         
	c[28]<=c[24];         
	end                   
                              
always @(posedge clk[1])begin 
    c[1] <= CIn[1];  //Start Second reg
	c[5] <= c[1];         
	c[9] <= c[5];         
	c[13]<= c[9];         
	c[17]<=c[13];         
	c[21]<=c[17];         
	c[25]<=c[21];         
	c[29]<=c[25];         
	end                   
                              
always @(negedge clk[0])begin 
	 c[2]<= CIn[2];  //Start third reg         
	 c[6]<= c[2];         
	c[10]<= c[6];         
	c[14]<=c[10];         
	c[18]<=c[14];         
	c[22]<=c[18];         
	c[26]<=c[22];         
	c[30]<=c[26];         
	end                   
                              
always @(negedge clk[1])begin 
	 c[3]<= CIn[3];   //Start forth reg       
	 c[7]<= c[3];         
	c[11]<= c[7];         
	c[15]<=c[11];         
	c[19]<=c[15];         
	c[23]<=c[19];         
	c[27]<=c[23];         
	c[31]<=c[27];         
	end    
*/	
//*********************************************************************

reg [31:0] TimeLtch;
reg [35:0] TimeLtch50;

Lanalyzer LA(
.Data(TimeLtch),
.DClk(clk[4]),   
//Com Link
.DataOut(DataOutLA),
.DataIn(DataIn),
.Address(Address),
.Read(Read),
.Write(Write),
.rdclk(clk[4]),
.rst(rst),
.ack()
);

//Latch sequence on DIn.
always @(posedge DIn) TimeLtch<=c;

//Move to 50MHz clock (clk[4]). Rearrangement for ease of decoding.
always @(posedge clk[4])begin
		TimeLtch50[6:0]  <= TimeLtch[31:25];
	    TimeLtch50[35:7] <= TimeLtch[28:0];	
	end


// ***********Defining valid data.***************
//Toggle bit for switching between vd1 & vd2 for clearing hit register if no hit comes in.
reg switch = 1'd0;  

reg vd1a,vd1; 
reg vd2a,vd2; 
wire vd3;

always @(posedge clk[4])switch <= ~switch; //Ping/pong for valid data

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
always @(posedge clk[4]) begin
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


reg [31:0]decode;
genvar k;
generate
for (k = 0; k < 32; k = k + 1)
	begin
		always @(posedge clk[4])begin
//			if (vd3) decode[k] <= ((TimeLtch50[k] | ~TimeLtch50[k+4]) & (TimeLtch50[k+1] & TimeLtch50[k+2] & TimeLtch50[k+3]));  
//			if (vd3) decode[k] <= (TimeLtch50[k+1] & TimeLtch50[k+2] & TimeLtch50[k+3] & ~TimeLtch50[k+4]);  
			if (vd3) decode[k] <= (TimeLtch50[k+2] & TimeLtch50[k+3] & ~TimeLtch50[k+4]);  
//			if (vd3) decode[k] <= (TimeLtch50[k+3] & ~TimeLtch50[k+4]);  
				else decode[k]<=1'd0;
		end
	end
endgenerate	
/*
wire [31:0]decode;
assign decode = TimeLtch50[31:0];
*/
always @(posedge clk[4])begin
	Result<=decode;
	end	
wire ME,MP,MM;	
wcomp El(
	.A(decode), 
	.B(EW), 
	.clk(clk[4]),	
	.match(ME)
);
wcomp Pn(
	.A(decode), 
	.B(PW), 
	.clk(clk[4]),	
	.match(MP)
);
wcomp Mn(
	.A(decode), 
	.B(MW), 
	.clk(clk[4]),	
	.match(MM)
);

assign Electron = ME & CFig[0];
assign Muon = MM & CFig[2];
assign Pion = MP & CFig[1];	

endmodule