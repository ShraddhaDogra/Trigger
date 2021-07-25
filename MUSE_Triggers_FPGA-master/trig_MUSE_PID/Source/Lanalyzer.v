//-----------------------------------------------------                                  
// Design Name	: Lanalyzer                                                         
// File Name	: Lanalyzer  .v                                                       
// Function		: Uses Fifo like Logic analyzer                                                 
// Written By	: Ed Bartz
// Notes		: Read out 32 bit data, at single address 0x90xx                                                 
//-----------------------------------------------------     
`timescale 1ns / 1ps

module Lanalyzer #(
    parameter MYAD=8'hFF,
    parameter TrigAD=8'hFE,
    parameter ContAD=8'hFD
    )(
input wire [31:0] Data,
input wire DClk,   
//Com Link
output wire [31:0] DataOut,
input wire [31:0] DataIn,
input wire [7:0] Address,
input wire Read,
input wire Write,
input wire rdclk,
input wire rst,
output reg ack
);

wire [31:0] DataOut1, DataOut2, DataOut3;

assign DataOut = DataOut1 | DataOut2 | DataOut3;

wire [31:0] Trigger;
Register #(TrigAD,32'h0) Trigger1
(
	.DataOut(DataOut1),
	.DataIn(DataIn),
	.Address(Address),
	.Read(Read),
	.Write(Write),
	.rst(rst),
	.Q(Trigger),
	.ack()
);

wire [31:0] Cont;
Register #(ContAD,32'h0) Cont1//8'hFD
(
	.DataOut(DataOut2),
	.DataIn(DataIn),
	.Address(Address),
	.Read(Read),
	.Write(Write),
	.rst(rst),
	.Q(Cont),
	.ack()
);

wire full, en, addred;
reg Ren, RenBlk;
wire [31:0] Q;
wire test;

assign addred = (Address==MYAD);
assign en = Cont[0] & ~full;

// Read single value from FIFO
always @(negedge rdclk)
		begin
			if (addred & Read & ~RenBlk)Ren <=1'b1;
				else Ren <=1'b0;
		end

always @(posedge rdclk)
		begin
			if ((addred & Read & RenBlk) | Ren) RenBlk <=1'b1;
				else RenBlk <=1'b0;
		end

genvar i;

generate
	for ( i = 0; i < 32; i = i+1 )	
assign DataOut3[i] = addred & Read & Q[i];
endgenerate


LA_FIFO Laf(
	.Data(Data), 
	.WrClock(DClk), 
	.RdClock(rdclk), 
	.WrEn(en),
	.RdEn(Ren),
	.Reset(Cont[1]),
	.RPReset(Cont[1]), 
	.Q(Q), 
	.Empty(), 
	.Full(full), 
	.AlmostEmpty(), 
	.AlmostFull()
	);
    
    
endmodule