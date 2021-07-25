//-----------------------------------------------------                                  
// Design Name	: ComTrans                                                         
// File Name	: ComTrans.v                                                       
// Function		: Translate TRBNet to local write only net                                                 
// Written By	: Ed Bartz
// Notes		: Address space = 0x90xx                                                 
//-----------------------------------------------------     
`timescale 1ns / 1ps

module ComTrans(
input wire[31:0] data, 	// 32 bits data to TBC
input wire [15:0] addr,	// 16 bit address of register
output reg [31:0] rdata,// 32 bits data from TBC //originally reg
input wire Cclk,    	// Clock
output reg ack,		// data acknownledge
output reg unknown,	// unknown address
output reg nack,		// not acknownledge?
input wire wr,			// Data Write
input wire rd,			// Data Read
//Local Bus.
output reg [31:0] DataOut,
input wire [31:0] DataIn,
output reg [7:0] Address,
output reg Read,
output reg Write,
input wire clk_100_i
);

reg [7:0]upperaddress=8'h00;
reg rw = 1'b0;

//assign ack = (addr[15:8]==upperaddress);
//reg [31:0] rq;
//		if(rd)rq<=DataIn;
//assign Write = wr & rw;
//assign Read = rd & rw;
/*
always @(posedge clk_100_i) begin
DataOut <= data;
rdata <= DataIn;
Write <= ~wr;
Read <= rd;
unknown <= 1'b0;
nack <= 1'b0;
ack <= 1'b1;
Address <= addr[7:0];
end
*/
/*
wire rack;
assign rack = ack & Read;


always @ (posedge rack) rdata <= DataIn;
//always @ (posedge wr) DataOut <= data;

always @(posedge clk_100_i) begin
	if (addr[15:8]==upperaddress) begin
		Address <= addr[7:0];
		DataOut <= data;
		if (wr==1 || rd==1) ack <= 1'b1;
            else ack <= 1'b0;
        if (wr==1) Write <= 1'b0;
		   else Write <= 1'b1;
		if (rd==1) Read <= 1'b1;
             else Read <= 1'b0;
		unknown <=0;
		nack <=0;
	  end
	else begin
	    if ((addr[15:8]!=upperaddress) & (Read | Write)) unknown <=1'b1;
	end
end
*/


//works without timeouts!!!!
//takes three reads, one to read old value, one to read new value but not all data there yet, last to fully read

always @(posedge clk_100_i) begin
//    if (Read==0 && Write==0) ack = 0;
	if(Read) rdata <= DataIn;
	if (addr[15:8]==upperaddress)begin
		Address <= addr[7:0];
		DataOut <= data;
		if (wr==1 || rd==1) ack <= 1'b1;
            else ack <= 1'b0;
        if (wr==1) Write <= 1'b0;
		   else Write <= 1'b1;
		if (rd==1) Read <= 1'b1;
             else Read <= 1'b0;
		unknown <=0;
		nack <=0;
	end
	else begin
		Address <= 8'h0;
		unknown <=1'b1;
		ack <= 1'b0;;
	end
end


//works with timeouts, uses 50 MHz clock
/*
always @(posedge Cclk) begin
	if (Read)begin
		rdata <= DataIn;
	end
	if (addr[15:8]==upperaddress)begin
		Address <= addr[7:0];
		DataOut <= data;
		rw <= 1;
		ack1 <= 1;
		ack <= ack1;
		unknown <=0;
		nack <=0;
	end
	else begin
		Address <= 8'h0;
		unknown <=1;
		ack <=0;
		rw <=0;
	end
end			
*/


//Example from trbnet code
/* 
always @(posedge Cclk) begin

proc_reg : process begin
  wait until rising_edge(CLK);
  BUS_TX.ack     <= '0';
  BUS_TX.nack    <= '0';
  BUS_TX.unknown <= '0';
  
  if BUS_RX.write = '1' then
    BUS_TX.ack <= '1';
    case BUS_RX.addr(1 downto 0) is
      when "00"   => control_i <= BUS_RX.data;
      when others => BUS_TX.ack <= '0'; BUS_TX.unknown <= '1';
    end case;
  elsif BUS_RX.read = '1' then
    BUS_TX.ack <= '1';
    case BUS_RX.addr(1 downto 0) is
      when "00"   => BUS_TX.data <= control_i;
      when "01"   => BUS_TX.data <= status_i;
      when others => BUS_TX.ack <= '0'; BUS_TX.unknown <= '1';
    end case;
  end if;
end process;
*/

endmodule