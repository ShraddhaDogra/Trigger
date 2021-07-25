//----------------------------------------------------------
// Top  
//----------------------------------------------------------
module ScatterTrig(CLK_PCLK_RIGHT,INP,OutpA, OutpB, OutpC, LED_GREEN, LED_ORANGE, LED_RED, LED_YELLOW, trig_mask, trig_out_OR, trig_out_dir, trig_out_lat, trig_out_50ns_lat,trig_out_150ns_lat);

input CLK_PCLK_RIGHT;
input [47:0] INP; //Data input
//input  InpA, InpB, InpC;
output [2:0] OutpA, OutpB, OutpC; //Data output
output LED_GREEN, LED_ORANGE, LED_RED, LED_YELLOW;
output trig_out_OR, trig_out_dir, trig_out_lat, trig_out_50ns_lat,trig_out_150ns_lat;
input [47:0] trig_mask;

wire [47:0] INP; 
//wire InpA,InpB,InpC; 
reg [2:0] OutpA,OutpB,OutpC;

wire [47:0] res,InLtch,retr;

wire clk;

assign clk = CLK_PCLK_RIGHT;

wire [47:0] Pout2,Pout4,Pout5,Pout6;


//Stretch all inputs to 10ns wide
PulseStretch #(
 .STAGES(2) //Number of 200MHz clocks to extend pulse width.
)ps2(                                                                 
    .in(INP[47:0]),
    .clk(clk),
    .out(Pout2)
    );
 
 
//Stretch all inputs to 20ns wide 
PulseStretch #(
    .STAGES(4) //Number of 200MHz clocks to extend pulse width.
)ps4(                                                                 
    .in(INP[47:0]),
    .clk(clk),
    .out(Pout4)
    );

//Stretch all inputs to 25ns wide
PulseStretch #(
 .STAGES(5) //Number of 200MHz clocks to extend pulse width.
 )ps5(
    .in(INP[47:0]),
    .clk(clk),
    .out(Pout5)
    );
 
//Stretch all inputs to 30ns wide 
PulseStretch #(
     .STAGES(6) //Number of 200MHz clocks to extend pulse width.
     )ps6(
        .in(INP[47:0]),
        .clk(clk),
        .out(Pout6)
        );

wire [17:0] frontA,frontB,frontC;
wire [27:0] backA,backB,backC;

// This section Uses Pout4, with 20ns wide pulses for LUT coincidence
assign frontA[17:0] = Pout4[17:0];  //Temporarily rigged to use port 1 only
assign backA = Pout4[47:18];

wire [17:0]Ors3A;

//Or groups of 3/4 from the back row
BackOr3 BO3A(
    .back(backA), 
    .ret(Ors3A)
    );


//Or groups of 5/6 from the back row
wire [17:0]Ors5A;

BackOr5 BO5A(
    .back(backA), 
    .ret(Ors5A)
    );
 
//And Back Groups to Front row 
wire [17:0]And3A, And5A, And3A1, And5A1;
    
        assign And3A =(Ors3A & frontA);
        assign And5A =(Ors5A & frontA);
 
//Stretch from row Ands for final output widths
    PulseStretch #(
         .STAGES(6), //Number of 200MHz clocks to extend pulse width.
         .WIDTH (18)
        )LatchAnd3A(                                                                 
            .in(And3A),
            .clk(clk),
            .out(And3A1)
            );   

    PulseStretch #(
         .STAGES(6), //Number of 200MHz clocks to extend pulse width.
         .WIDTH (18)
         )LatchAnd5A(                                                                 
            .in(And5A),
            .clk(clk),
            .out(And5A1)
             );   

//Or Ands together for single bit outputs, and transmit.
wire tempA; 

Or18 outA(
    .in(And3A1),
    .out(tempA)
    );
    
always @ (posedge clk) OutpA[0] <= tempA;

wire tempD; 
         
         Or18 outD(
             .in(And5A1),
             .out(tempD)
             );

always @ (posedge clk) OutpB[0] <= tempD;


// This section Uses Pout5, with 25ns wide pulses for LUT coincidence

assign frontB[17:0] = Pout5[17:0];  //Temporarily rigged to use port 1 only
assign backB = Pout5[47:18];

wire [17:0]Ors3B;

//Or groups of 3/4 from the back row
BackOr3 BO3B(
    .back(backB), 
    .ret(Ors3B)
    );
	
//Or groups of 5/6 from the back row
wire [17:0]Ors5B;

BackOr5 BO5B(
    .back(backB), 
    .ret(Ors5B)
    );
	
 //And Back Groups to Front row    
wire [17:0]And3B, And5B, And3B1, And5B1;
    
        assign And3B =(Ors3B & frontB);
        assign And5B =(Ors5B & frontB);
        
//Stretch from row Ands for final output widths
    PulseStretch #(
         .STAGES(6), //Number of 200MHz clocks to extend pulse width.
         .WIDTH (18)
        )LatchAnd3B(                                                                 
            .in(And3B),
            .clk(clk),
            .out(And3B1)
            );   
            
    PulseStretch #(
         .STAGES(6), //Number of 200MHz clocks to extend pulse width.
         .WIDTH (18)
         )LatchAnd5B(                                                                 
            .in(And5B),
            .clk(clk),
            .out(And5B1)
            );   

//Or Ands together for single bit outputs, and transmit.
wire tempB; 

Or18 outB(
    .in(And3B1),
    .out(tempB)
    );
    
//always @ (posedge clk) OutpA[1] <= tempB;
initial OutpA[1]=0;
always @ (posedge clk) OutpA[1]=~OutpA[1];
	
wire tempE; 
         
         Or18 outE(
             .in(And5B1),
             .out(tempE)
             );

always @ (posedge clk) OutpB[1] <= tempE;



// This section Uses Pout6, with 30ns wide pulses
//Temporarily rigged to use port 1 only
assign frontC[17:0] = Pout6[17:0];
assign backC = Pout6[47:18];

//Or groups of 3/4 from the back row
wire [17:0]Ors3C;

BackOr3 BO3C(
    .back(backC), 
    .ret(Ors3C)
    );

//Or groups of 5/6 from the back row
wire [17:0]Ors5C;

BackOr5 BO5C(
    .back(backC), 
    .ret(Ors5C)
    );
    
//And Back Groups to Front row 
wire [17:0]And3C, And5C, And3C1, And5C1;
    
    assign And3C =(Ors3C & frontC);
    assign And5C =(Ors5C & frontC);
        
//Stretch from row Ands for final output widths
    PulseStretch #(
         .STAGES(6), //Number of 200MHz clocks to extend pulse width.
         .WIDTH (18)
        )LatchAnd3C(                                                                 
            .in(And3C),
            .clk(clk),
            .out(And3C1)
            );
               
    PulseStretch #(
        .STAGES(6), //Number of 200MHz clocks to extend pulse width.
        .WIDTH (18)
        )LatchAnd5C(                                                                 
           .in(And5C),
           .clk(clk),
           .out(And5C1)
           );   


//Or Ands together for single bit outputs, and transmit.
wire tempC; 

Or18 outC(
    .in(And3C1),
    .out(tempC)
    );
    
always @ (posedge clk) OutpA[2] <= tempC;

wire tempF; 
         
Or18 outF(
      .in(And5C1),
      .out(tempF)
      );

always @ (posedge clk) OutpB[2] <= tempF;

//8 Input OR test. Using port 3 inputs

wire OrOut2,OrOut4,OrOut6;

//20 Input pules
Or8 outOr4(
    .in(Pout4[39:32]),
    .out(OrOut4)
    );


always @ (posedge clk) OutpC[1] <= OrOut4;
	
//10ns input pulses
Or8 outOr2(
    .in(Pout2[39:32]),
    .out(OrOut2)
    );

always @ (posedge clk) OutpC[0] <= OrOut2;

//30ns input pulses
Or8 outOr6(
    .in(Pout6[39:32]),
    .out(OrOut6)
    );

always @ (posedge clk) OutpC[2] <= OrOut6;

//Make lights blink so we know something is happening.
leds Blink(
	.clk(clk),
    .green(LED_GREEN),
    .yellow(LED_YELLOW),
    .orange(LED_ORANGE),
    .red(LED_RED)	
    );


endmodule