module signal_gen_x16(
pulse_out, // LVDS 16 identical output signals generated wit clock
spare_out, // LVDS spare output that goes to trigger input
clk //clock signal , clk_i = 133MHz <= Clocks on padiwa 
);

//We want to have 30 ns wide output pulses with frequenchy around 10kHz.
// 133 MHz = 7.5 ns => pulse should be 4 periods wide.
//Then it should be dead for 90000 ns = 12000 clock periods.
// Assing I/0 and registers:
input clk;
output [15:0] pulse_out;
output spare_out;

parameter PULSE_WIDTH = 4; //width of pulse;
parameter PULSE_DEAD = 12000-PULSE_WIDTH; //dead time after pulse;
reg [13:0] counter; // 14 bit clock period counter to count 12000 clock periods
reg pulse; 


// Code:
initial counter = 0;

always @(posedge clk)
   begin
     if (counter == PULSE_DEAD) // period, count from 0 to n-1
        counter <= 0;
     else
        counter <= counter + 1'b1;

     // synchronous output without glitches
     if (counter < PULSE_WIDTH) // duty cycle, m cycles high
        pulse <= 1'b1;
     else
        pulse <= 1'b0;
   end

// assign outputs to the pulse value;
assign spare_out = pulse; 
assign pulse_out = {16{pulse}};

endmodule 