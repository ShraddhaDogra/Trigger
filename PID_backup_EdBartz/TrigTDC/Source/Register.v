//-----------------------------------------------------                                  
// Design Name	: Register                                                         
// File Name	: Register.v                                                       
// Function		: Addressing one register                                                 
// Written By	: Ed Bartz
// Notes		: Single 32 bit register, at address 0x90xx                                                 
//-----------------------------------------------------     
`timescale 1ns / 1ps

module Register#(
    parameter MYAD=8'hC0,
	parameter DEFAULTVALUE=32'h00000000	
    )(
output wire [31:0] DataOut,
input wire [31:0] DataIn,
input wire [7:0] Address,
input wire Read,
input wire Write,
input wire rst,
output reg [31:0]Q,
output reg ack
);

always @(negedge Write or posedge rst) begin
	if(rst)Q<=DEFAULTVALUE;
	else if(Address==MYAD)Q<=DataIn;
	end

genvar i;

generate
	for ( i = 0; i < 32; i = i+1 )	
assign DataOut[i] = (Address==MYAD) & Read & Q[i];
endgenerate


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