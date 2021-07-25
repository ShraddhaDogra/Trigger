//----------------------------------------------------------
// Top  
//----------------------------------------------------------


module ScatterTrig(CLK_PCLK_RIGHT,INP,OutpA, OutpB, OutpC, LED_GREEN, LED_ORANGE, LED_RED, LED_YELLOW, trig_mask, trig_out_OR, trig_out_dir, trig_out_lat, trig_out_50ns_lat,trig_out_150ns_lat);

input CLK_PCLK_RIGHT;
input [47:0] INP; //Data input

output [2:0] OutpA, OutpB, OutpC; //Data output
output LED_GREEN, LED_ORANGE, LED_RED, LED_YELLOW;
output trig_out_OR, trig_out_dir, trig_out_lat, trig_out_50ns_lat,trig_out_150ns_lat;
input [47:0] trig_mask;

wire [47:0] INP; 
wire InpA,InpB,InpC; 
reg [2:0] OutpA,OutpB,OutpC;

wire [47:0] res,InLtch,retr;

wire clk;

assign clk = CLK_PCLK_RIGHT;

wire [47:0] Pout2,Pout4,Pout5,Pout6;
 
//Stretch all inputs to 30ns wide 
PulseStretch #(
     .STAGES(6) //Number of 200MHz clocks to extend pulse width.
     )ps6(
        .in(INP[47:0]),
        .clk(clk),
        .out(Pout6)
        );

wire [17:0] front_bars;
wire [27:0] rare_bars;

assign front_bars[17:0] = Pout6[17:0];
assign rare_bars[27:0] = Pout6[45:18];

wire total_or_front;
wire total_or_rare;

assign total_or_front = |front_bars;
assign total_or_rare = | rare_bars;

wire fire;

assign fire = total_or_front | total_or_rare;

/// -------------------------------------------------------------- 
wire fire1;
wire firelatch;


    PulseStretch #(
         .STAGES(6), //Number of 200MHz clocks to extend pulse width.
         .WIDTH (1)
        )LatchAnd3C(                                                                 
            .in(fire),
            .clk(clk),
            .out(fire1)
            );

	//Output gate for MQDC
    PulseStretch #(
         .STAGES(20), //Number of 200MHz clocks to extend pulse width.
         .WIDTH (1) //100 ns
        )Latch(                                                                 
            .in(fire),
            .clk(clk),
            .out(firelatch)
            );	
			
			
always @ (posedge clk) OutpA[0] <= fire1;
always @ (posedge clk) OutpA[1] <= fire1;
always @ (posedge clk) OutpA[2] <= fire1;
always @ (posedge clk) OutpB[0] <= firelatch;
always @ (posedge clk) OutpB[1] <= firelatch;
always @ (posedge clk) OutpB[2] <= firelatch;



//Make lights blink so we know something is happening.
leds Blink(
	.clk(clk),
    .green(LED_GREEN),
    .yellow(LED_YELLOW),
    .orange(LED_ORANGE),
    .red(LED_RED)	
    );

endmodule