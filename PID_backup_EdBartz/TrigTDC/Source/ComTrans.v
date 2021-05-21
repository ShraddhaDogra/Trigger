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
output reg [31:0] rdata,// 32 bits data from TBC
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
output wire Read,
output wire Write
);

reg [7:0]upperaddress=8'h90;
reg rw = 1'b0;
//reg [31:0] rq;
//		if(rd)rq<=DataIn;
assign Write = wr & rw;
assign Read = rd & rw;

always @(posedge Cclk) begin
	rdata <= DataIn;
	if (addr[15:8]==upperaddress)begin
		Address <= addr[7:0];
		DataOut <= data;
		rw <= 1;
		ack <= 1;
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