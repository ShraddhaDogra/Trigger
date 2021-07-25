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

wire [17:0] frontbarsleft;
wire [27:0] frontbarsright;

assign frontbarsleft[17:0] = Pout6[17:0];assign frontbarsright[27:0] = Pout6[45:18];

//wire [17:0] frontand;
wire totalorleft;
wire totalorright;
//assign frontand = (frontbarsleft & frontbarsright);
wire left1,left2,left3,left4,left5,left6,left7,left8,left9,left10,left11,left12,left13;
wire right1,right2,right3,right4,right5,right6,right7,right8,right9,right10,right11,right12,right13,right14,right15,right16,right17,right18,right19,right20,righ21,right22,right23;
Or6 combineleft1(
	.in(frontbarsleft[5:0]),
	.out(left1)
);
Or6 combineleft2(
	.in(frontbarsleft[6:1]),
	.out(left2)
);
Or6 combineleft3(
	.in(frontbarsleft[7:2]),
	.out(left3)
);
Or6 combineleft4(
	.in(frontbarsleft[8:3]),
	.out(left4)
);
Or6 combineleft5(
	.in(frontbarsleft[9:4]),
	.out(left5)
);
Or6 combineleft6(
	.in(frontbarsleft[10:5]),
	.out(left6)
);
Or6 combineleft7(
	.in(frontbarsleft[11:6]),
	.out(left7)
);
Or6 combineleft8(
	.in(frontbarsleft[12:7]),
	.out(left8)
);
Or6 combineleft9(
	.in(frontbarsleft[13:8]),
	.out(left9)
);
Or6 combineleft10(
	.in(frontbarsleft[14:9]),
	.out(left10)
);
Or6 combineleft11(
	.in(frontbarsleft[15:10]),
	.out(left11)
);
Or6 combineleft12(
	.in(frontbarsleft[16:11]),
	.out(left12)
);
Or6 combineleft13(
	.in(frontbarsleft[17:12]),
	.out(left13)
);
//Right bars
Or6 combineright1(
	.in(frontbarsright[5:0]),
	.out(right1)
);
Or6 combineright2(
	.in(frontbarsright[6:1]),
	.out(right2)
);
Or6 combineright3(
	.in(frontbarsright[7:2]),
	.out(right3)
);
Or6 combineright4(
	.in(frontbarsright[8:3]),
	.out(right4)
);
Or6 combineright5(
	.in(frontbarsright[9:4]),
	.out(right5)
);
Or6 combineright6(
	.in(frontbarsright[10:5]),
	.out(right6)
);
Or6 combineright7(
	.in(frontbarsright[11:6]),
	.out(right7)
);
Or6 combineright8(
	.in(frontbarsright[12:7]),
	.out(right8)
);
Or6 combineright9(
	.in(frontbarsright[13:8]),
	.out(right9)
);
Or6 combineright10(
	.in(frontbarsright[14:9]),
	.out(right10)
);
Or6 combineright11(
	.in(frontbarsright[15:10]),
	.out(right11)
);
Or6 combineright12(
	.in(frontbarsright[16:11]),
	.out(right12)
);
Or6 combineright13(
	.in(frontbarsright[17:12]),
	.out(right13)
);

Or6 combineright14(
	.in(frontbarsright[18:13]),
	.out(right14)
);
Or6 combineright15(
	.in(frontbarsright[19:14]),
	.out(right15)
);
Or6 combineright16(
	.in(frontbarsright[20:15]),
	.out(right16)
);
Or6 combineright17(
	.in(frontbarsright[21:16]),
	.out(right17)
);
Or6 combineright18(
	.in(frontbarsright[22:17]),
	.out(right18)
);
Or6 combineright19(
	.in(frontbarsright[23:18]),
	.out(right19)
);
Or6 combineright20(
	.in(frontbarsright[24:19]),
	.out(right20)
);
Or6 combineright21(
	.in(frontbarsright[25:20]),
	.out(right21)
);
Or6 combineright22(
	.in(frontbarsright[26:21]),
	.out(right22)
);
Or6 combineright23(
	.in(frontbarsright[27:22]),
	.out(right23)
);

//assign fire=(left1&right1)|(left2&right2)|(left3&right3)|(left4&right4)|(left5&right5)|(left6&right6)|(left7&right7)|(left8&right8)|(left9&right9)|(left10&right10)|(left11&right11)|(left12&right12)|(left13&right13);
assign firefront = left1|left2|left3|left4|left5|left6|left7|left8|left9|left10|left11|left12|left13;
assign fireback = right1|right2|right3|right4|right5|right6|right7|right8|right9|right10|right11|right12|right13|right14|right15|right16|right17|right18|right19|right20|right21|right22|right23;
assign fire = firefront | fireback;



// Untill here there was simple 6_Or logic assignment. 
// And of 6 and or togather. 
// the output is "fire" signal



Or18 out18left(
	.in(frontbarsleft[17:0]),
	.out(totalorleft)
);


//" Frontbarsright" is a 28 bit word that corresponds to the last 28 inputs on TDC ---> back  wall., Why OR18 ------------------------------------- ????????????????????
Or18 out18right(
	.in(frontbarsright[17:0]),
	.out(totalorright)
);


/// -------------------------------------------------------------- 


wire fire1;
wire firefront1;
wire fireback1;
wire firelatch;


    PulseStretch #(
         .STAGES(6), //Number of 200MHz clocks to extend pulse width.
         .WIDTH (1)
        )LatchAnd3C(                                                                 
            .in(fire),
            .clk(clk),
            .out(fire1)
            );
   PulseStretch #(
         .STAGES(6), //Number of 200MHz clocks to extend pulse width.
         .WIDTH (1)
        )LatchAnd5C(                                                                 
            .in(firefront),
            .clk(clk),
            .out(firefront1)
            );
    PulseStretch #(
         .STAGES(6), //Number of 200MHz clocks to extend pulse width.
         .WIDTH (1)
        )LatchAnd7C(                                                                 
            .in(fireback),
            .clk(clk),
            .out(fireback1)
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





////////////////////////// THis should work just fine : 
//8 Input OR test. Using port 3 inputs

wire OrOut2,OrOut4,OrOut6;

//30 Input pules
Or8 outOr4(
    .in(Pout6[39:32]),
    .out(OrOut4)
    );

Or8 outOr2(
    .in(Pout6[39:32]),
    .out(OrOut2)
    );

Or8 outOr6(
    .in(Pout6[39:32]),
    .out(OrOut6)
    );
	
// Or output sahould be clock independent:
//always @ (posedge clk) OutpC[1] <= OrOut4; // --> Old 
//always @ (posedge clk) OutpC[0] <= OrOut2;
//always @ (posedge clk) OutpC[2] <= OrOut6;

always @(OrOut6 or OrOut2 or OrOut4)
	OutpC[2:0] <= {OrOut6,OrOut2,OrOut4};





//Make lights blink so we know something is happening.
leds Blink(
	.clk(clk),
    .green(LED_GREEN),
    .yellow(LED_YELLOW),
    .orange(LED_ORANGE),
    .red(LED_RED)	
    );

endmodule