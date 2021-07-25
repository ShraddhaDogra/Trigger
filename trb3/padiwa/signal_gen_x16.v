//`timescale 1ns / 1ps

module signal_gen_x16(
    pulse_out, // LVDS 16 identical output signals generated wit clock
    spare_out, // LVDS spare output that goes to trigger input
    clk //clock signal , clk_i = 133MHz <= Clocks on padiwa 
);

//We want to have 30 ns wide output pulses with frequency around 10kHz.
// 133 MHz = 7.5 ns => pulse should be 4 periods wide.
//Then it should be dead for 90000 ns = 12000 clock periods.
// Assignng I/0 and registers;
input clk;
output reg[15:0] pulse_out = 0;
output reg spare_out = 0;


parameter PULSE_WIDTH = 4; //width of pulse;
parameter PULSE_DEAD = 12000-PULSE_WIDTH; //dead time after pulse;
reg [13:0] counter = 0; // 14 bit clock period counter to count 12000 clock periods

// Your code Code 
always @(posedge clk) 
begin
    counter = counter + 1;
    if(counter == PULSE_DEAD) 
    begin
        pulse_out[15:0] = 16'hFFFF;
        spare_out = 1;
    end
    else if (counter == (PULSE_DEAD + PULSE_WIDTH))
    begin
        pulse_out[15:0] = 16'h0000;
        spare_out = 0;
        counter = 0;
    end
 end

endmodule 
