// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2004 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                            408-826-6000 (other locations)
// Hillsboro, OR 97124                     web  : http://www.latticesemi.com/
// U.S.A                                   email: techsupport@latticesemi.com
// =============================================================================/
//                         FILE DETAILS
// Project          : GPIO for LM32
// File             : gpio.v
// Title            : General Purpose IO Component 
// Dependencies     : system_conf.v
// Description      : Implements the logic to interface general purpuse IO with 
//                    Wishbone bus.
// =============================================================================
//                        REVISION HISTORY
// Version          : 7.0
// Mod. Date        : Jun 27, 2005
// Changes Made     : Initial Creation
//
// Version          : 7.0SP2, 3.0
// Mod. Date        : 20 Nov. 2007
// Changes Made     : Code clean up.
//
// Version          : 3.1
// Mod. Date        : 11 Oct. 2008
// Changes Made     : Update the Edge Capture Register clean method
//                    Make IRQ Mask register readable
// =============================================================================
`ifndef GPIO_V
`define GPIO_V
`timescale 1ns/100 ps
`include "system_conf.v"
module gpio #(parameter DATA_WIDTH = 16,
              parameter INPUT_WIDTH = 16,
              parameter OUTPUT_WIDTH = 16,
              parameter IRQ_MODE = 0,
              parameter LEVEL = 0,
              parameter EDGE = 0,
              parameter POSE_EDGE_IRQ = 0,
              parameter NEGE_EDGE_IRQ = 0,
              parameter EITHER_EDGE_IRQ = 0,
              parameter INPUT_PORTS_ONLY = 1,
              parameter OUTPUT_PORTS_ONLY = 0,
              parameter BOTH_INPUT_AND_OUTPUT = 0,
              parameter TRISTATE_PORTS = 0)
     (
     //system clock and reset
     CLK_I,
     RST_I,
     //wishbone interface signals
     GPIO_ADR_I,
     GPIO_CYC_I,
     GPIO_DAT_I,
     GPIO_SEL_I,
     GPIO_STB_I,
     GPIO_WE_I,
     GPIO_LOCK_I,
     GPIO_CTI_I,
     GPIO_BTE_I,
     GPIO_ACK_O,
     GPIO_RTY_O,
     GPIO_DAT_O,
     GPIO_ERR_O,
     IRQ_O, //bit_or of all IRQs
     //PIO side
     PIO_IN,
     PIO_OUT,
     PIO_IO,
     PIO_BOTH_IN,
     PIO_BOTH_OUT
     );

//---------------------------------------------------------------------
// inputs
   //
   input                   CLK_I;
   input                   RST_I;
   input [31:0]            GPIO_ADR_I;
   input                   GPIO_CYC_I;
   input [31:0]            GPIO_DAT_I;
   input [3:0]             GPIO_SEL_I;
   input                   GPIO_STB_I;
   input                   GPIO_WE_I;
   input                   GPIO_LOCK_I;
   input [2:0]             GPIO_CTI_I;
   input [1:0]             GPIO_BTE_I;   
   input [DATA_WIDTH-1:0]  PIO_IN;
   input [INPUT_WIDTH-1:0] PIO_BOTH_IN;
//---------------------------------------------------------------------
// outputs
//
   output                    GPIO_ACK_O;
   output                    GPIO_RTY_O;
   output [31:0]             GPIO_DAT_O;
   output                    GPIO_ERR_O;
   output                    IRQ_O;
   output [DATA_WIDTH-1:0]   PIO_OUT;
   output [OUTPUT_WIDTH-1:0] PIO_BOTH_OUT;
//----------------
//inout mode
   inout [DATA_WIDTH-1:0]    PIO_IO;
//----------------
//process
   
   parameter    UDLY     = 1;
   
   wire         ADR_0;
   wire         ADR_4;
   wire         ADR_8;
   wire         ADR_C;
   wire         read_addr_0;   
   wire         read_addr_4;   
   wire         read_addr_8;   
   wire         read_addr_C;   
   wire         GPIO_RTY_O;
   wire         GPIO_ERR_O;
   wire [31:0]  GPIO_DAT_O;
   wire         IRQ_O;
   wire [DATA_WIDTH-1:0]   PIO_OUT;
   wire [OUTPUT_WIDTH-1:0] PIO_BOTH_OUT;
   wire [DATA_WIDTH-1:0]   tpio_out;
   wire                    PIO_DATA_WR_EN;
   wire                    PIO_TRI_WR_EN;
   wire                    IRQ_MASK_WR_EN;
   wire                    EDGE_CAP_WR_EN;
   wire                    PIO_DATA_RE_EN;
   wire                    PIO_TRI_RE_EN;
   wire                    IRQ_MASK_RE_EN;
   wire [DATA_WIDTH-1:0]   IRQ_TRI_TEMP;
   reg [DATA_WIDTH-1:0]    PIO_DATA;
   reg [DATA_WIDTH-1:0]    IRQ_MASK;
   reg [INPUT_WIDTH-1:0]   IRQ_MASK_BOTH;
   reg [DATA_WIDTH-1:0]    IRQ_TEMP;
   reg [INPUT_WIDTH-1:0]   IRQ_TEMP_BOTH;
   reg [DATA_WIDTH-1:0]    EDGE_CAPTURE;
   reg [INPUT_WIDTH-1:0]   EDGE_CAPTURE_BOTH;
   reg [DATA_WIDTH-1:0]    PIO_DATA_DLY;
   reg [INPUT_WIDTH-1:0]   PIO_DATA_DLY_BOTH;
   reg [OUTPUT_WIDTH-1:0]  PIO_DATAO; 
   reg [INPUT_WIDTH-1 :0]  PIO_DATAI;
   reg                     GPIO_ACK_O;

   assign GPIO_RTY_O = 1'b0;
   assign GPIO_ERR_O = 1'b0;
   assign ADR_0 = (GPIO_ADR_I[3:0] == 4'b0000 ? 1'b1 : 0); // IO Data           
   assign ADR_4 = (GPIO_ADR_I[3:0] == 4'b0100 ? 1'b1 : 0); // Tri-state Control 
   assign ADR_8 = (GPIO_ADR_I[3:0] == 4'b1000 ? 1'b1 : 0); // IRQ Mask          
   assign ADR_C = (GPIO_ADR_I[3:0] == 4'b1100 ? 1'b1 : 0); // Edge Capture      
   assign read_addr_0 =                   (ADR_0 & GPIO_STB_I & ~GPIO_WE_I) ;   
   assign read_addr_4 =                   (ADR_4 & GPIO_STB_I & ~GPIO_WE_I) ;   
   assign read_addr_8 = (IRQ_MODE == 1 && (ADR_8 & GPIO_STB_I & ~GPIO_WE_I));   
   assign read_addr_C = (IRQ_MODE == 1 && (ADR_C & GPIO_STB_I & ~GPIO_WE_I));   

   always @(posedge CLK_I or posedge RST_I)
     if(RST_I)
       GPIO_ACK_O       <= #UDLY 1'b0;
     else if( GPIO_STB_I && !GPIO_ACK_O)
       GPIO_ACK_O       <= #UDLY 1'b1;
     else
       GPIO_ACK_O       <= #UDLY 1'b0;   

   generate
      if (INPUT_PORTS_ONLY == 1) begin   
         always @(posedge CLK_I or posedge RST_I)
           if (RST_I)
             PIO_DATA <= #UDLY 0;
           else if (GPIO_STB_I && !GPIO_ACK_O && !GPIO_WE_I && ADR_0 == 1'b1 && GPIO_SEL_I == 4'b1111)       
             PIO_DATA <= #UDLY PIO_IN;
         end
   endgenerate
 
   generate   
      if (OUTPUT_PORTS_ONLY == 1) begin
        always @(posedge CLK_I or posedge RST_I)
          if (RST_I)
            PIO_DATA <= #UDLY 0;
          else if (GPIO_STB_I && !GPIO_ACK_O && GPIO_WE_I && ADR_0 == 1'b1 && GPIO_SEL_I == 4'b1111)
            PIO_DATA <= #UDLY GPIO_DAT_I[DATA_WIDTH-1:0];   
            
        assign  PIO_OUT = PIO_DATA;
        end
   endgenerate
   
   generate
      if (BOTH_INPUT_AND_OUTPUT == 1) begin   
        always @(posedge CLK_I or posedge RST_I)
          if (RST_I) begin
            PIO_DATAI <= #UDLY 0;
            PIO_DATAO <= #UDLY 0;
          end else if (GPIO_STB_I && !GPIO_ACK_O && !GPIO_WE_I && (ADR_0 == 1'b1) && GPIO_SEL_I == 4'b1111)
            PIO_DATAI <= #UDLY PIO_BOTH_IN;
          else if (GPIO_STB_I && GPIO_ACK_O && GPIO_WE_I && (ADR_0 == 1'b1) && GPIO_SEL_I == 4'b1111)
            PIO_DATAO <= #UDLY GPIO_DAT_I[OUTPUT_WIDTH-1:0];
               
        assign  PIO_BOTH_OUT = PIO_DATAO[OUTPUT_WIDTH-1:0];
        end
   endgenerate
   
   assign  PIO_DATA_RE_EN = GPIO_STB_I && !GPIO_ACK_O && !GPIO_WE_I && (ADR_0 == 1'b1) && GPIO_SEL_I == 4'b1111;
   assign  PIO_TRI_RE_EN  = GPIO_STB_I &&  GPIO_ACK_O && !GPIO_WE_I && (ADR_4 == 1'b1) && GPIO_SEL_I == 4'b1111;
   assign  IRQ_MASK_RE_EN = GPIO_STB_I &&  GPIO_ACK_O && !GPIO_WE_I && (ADR_8 == 1'b1) && GPIO_SEL_I == 4'b1111;
   assign  PIO_DATA_WR_EN = GPIO_STB_I &&  GPIO_ACK_O &&  GPIO_WE_I && (ADR_0 == 1'b1) && GPIO_SEL_I == 4'b1111;
   assign  PIO_TRI_WR_EN  = GPIO_STB_I &&  GPIO_ACK_O &&  GPIO_WE_I && (ADR_4 == 1'b1) && GPIO_SEL_I == 4'b1111;
   assign  IRQ_MASK_WR_EN = GPIO_STB_I &&  GPIO_ACK_O &&  GPIO_WE_I && (ADR_8 == 1'b1) && GPIO_SEL_I == 4'b1111;
   assign  EDGE_CAP_WR_EN = GPIO_STB_I &&  GPIO_ACK_O &&  GPIO_WE_I && (ADR_C == 1'b1) && GPIO_SEL_I == 4'b1111;
   
   generate
      genvar     ti;
      for (ti = 0 ; ti < DATA_WIDTH; ti = ti + 1)
         begin : tio_inst
            TRI_PIO #(.DATA_WIDTH(DATA_WIDTH),
               .IRQ_MODE(IRQ_MODE),
               .LEVEL(LEVEL),
               .EDGE(EDGE),
               .POSE_EDGE_IRQ(POSE_EDGE_IRQ),
               .NEGE_EDGE_IRQ(NEGE_EDGE_IRQ),
               .EITHER_EDGE_IRQ(EITHER_EDGE_IRQ))
            TP (.CLK_I(CLK_I),
           .RST_I(RST_I),
           .DAT_I(GPIO_DAT_I[ti]),
           .DAT_O(tpio_out[ti]),
           .PIO_IO(PIO_IO[ti]),
           .IRQ_O(IRQ_TRI_TEMP[ti]),
           .PIO_TRI_WR_EN(PIO_TRI_WR_EN),
           .PIO_TRI_RE_EN(PIO_TRI_RE_EN),
           .PIO_DATA_WR_EN(PIO_DATA_WR_EN),
           .PIO_DATA_RE_EN(PIO_DATA_RE_EN),
           .IRQ_MASK_WR_EN(IRQ_MASK_WR_EN),
           .IRQ_MASK_RE_EN(IRQ_MASK_RE_EN),
           .EDGE_CAP_WR_EN(EDGE_CAP_WR_EN));
         end
   endgenerate

   generate      
     if (INPUT_PORTS_ONLY == 1)
       assign GPIO_DAT_O = read_addr_0 ? PIO_DATA : 
                           read_addr_8 ? IRQ_MASK :
                           read_addr_C ? EDGE_CAPTURE :
                           0;
     else if (BOTH_INPUT_AND_OUTPUT == 1)
       assign GPIO_DAT_O = read_addr_0 ? PIO_DATAI : 
                           read_addr_8 ? IRQ_MASK_BOTH :
                           read_addr_C ? EDGE_CAPTURE_BOTH :
                           0;
     else if (TRISTATE_PORTS == 1)
       assign GPIO_DAT_O = read_addr_0 ? tpio_out : 
                           read_addr_4 ? tpio_out : 
                           read_addr_8 ? tpio_out :
                           read_addr_C ? IRQ_TRI_TEMP :
                           0;
     else
       assign GPIO_DAT_O = 0;
   endgenerate
   
//-----------------------------------------------------------------------------
//-------------------------------IRQ Generation--------------------------------
//-----------------------------------------------------------------------------
   generate
      if (IRQ_MODE == 1) begin
        always @(posedge CLK_I or posedge RST_I)
          if (RST_I) begin
            IRQ_MASK      <= #UDLY 0;
            IRQ_MASK_BOTH <= #UDLY 0;
          end else if (IRQ_MASK_WR_EN) begin
            IRQ_MASK      <= #UDLY GPIO_DAT_I[DATA_WIDTH-1:0];   
            IRQ_MASK_BOTH <= #UDLY GPIO_DAT_I[INPUT_WIDTH-1:0];   
          end
        end
   endgenerate

   generate 
      //--------------------------------
      //--INPUT_PORTS_ONLY MODE IRQ
      //--------------------------------
      if (IRQ_MODE == 1 && INPUT_PORTS_ONLY == 1 && LEVEL == 1) begin   
         //level mode IRQ
         always @(posedge CLK_I or posedge RST_I)
           if (RST_I)
             IRQ_TEMP <= #UDLY 0;
           else if (IRQ_MASK_WR_EN)
             IRQ_TEMP <= #UDLY IRQ_TEMP & GPIO_DAT_I[DATA_WIDTH-1:0];
              else
             IRQ_TEMP <= #UDLY PIO_IN & IRQ_MASK;//bit-and   
         assign   IRQ_O = |IRQ_TEMP;
      end else if (IRQ_MODE == 1 && INPUT_PORTS_ONLY == 1 && EDGE == 1) begin   
         always @(posedge CLK_I or posedge RST_I)
           if (RST_I)
             PIO_DATA_DLY <= #UDLY 0;
           else
             PIO_DATA_DLY <= PIO_IN;

         // edge-capture register bits are treated as individual bits.
         genvar i;
         for( i = 0; i < DATA_WIDTH; i = i + 1)
         begin
             always @(posedge CLK_I or posedge RST_I)
                 if (RST_I)
                   EDGE_CAPTURE[i] <= #UDLY 0;
                 else if (|(PIO_IN[i] & ~PIO_DATA_DLY[i]) && (POSE_EDGE_IRQ == 1))
                   EDGE_CAPTURE[i] <= #UDLY PIO_IN[i] & ~PIO_DATA_DLY[i];
                 else if (|(~PIO_IN[i] & PIO_DATA_DLY[i]) && (NEGE_EDGE_IRQ == 1))
                   EDGE_CAPTURE[i] <= #UDLY ~PIO_IN[i] & PIO_DATA_DLY[i];
                 else if (|(PIO_IN[i] & ~PIO_DATA_DLY[i]) && (EITHER_EDGE_IRQ == 1))
                   EDGE_CAPTURE[i] <= #UDLY PIO_IN[i] & ~PIO_DATA_DLY[i];
                 else if (|(~PIO_IN[i] & PIO_DATA_DLY[i]) && (EITHER_EDGE_IRQ == 1))
                   EDGE_CAPTURE[i] <= #UDLY ~PIO_IN[i] & PIO_DATA_DLY[i];
                 else if ( (~IRQ_MASK[i]) & GPIO_DAT_I[i] & IRQ_MASK_WR_EN )
                   // interrupt mask is being set, so clear edge-capture
                   EDGE_CAPTURE[i] <= #UDLY 0;
                 else if (EDGE_CAP_WR_EN)
                   // user's writing to the edge register, so update edge capture
                   // register
                   EDGE_CAPTURE[i] <= #UDLY EDGE_CAPTURE[i] & GPIO_DAT_I[i];
         end
         assign  IRQ_O = |(EDGE_CAPTURE & IRQ_MASK);

     //----------------------------------
     //--BOTH_INPUT_AND_OUTPUT MODE IRQ
     //----------------------------------
     end else if  (IRQ_MODE == 1 && BOTH_INPUT_AND_OUTPUT == 1 && LEVEL == 1) begin
         always @(posedge CLK_I or posedge RST_I)
            if (RST_I)
              IRQ_TEMP_BOTH <= #UDLY 0;
            else if (IRQ_MASK_WR_EN)
              IRQ_TEMP_BOTH <= #UDLY IRQ_TEMP_BOTH & GPIO_DAT_I[INPUT_WIDTH-1:0];   
            else 
              IRQ_TEMP_BOTH <= #UDLY PIO_BOTH_IN & IRQ_MASK_BOTH;   
         assign   IRQ_O = |IRQ_TEMP_BOTH;

     //edge mode IRQ
     end else if  (IRQ_MODE == 1 && BOTH_INPUT_AND_OUTPUT == 1 && EDGE == 1) begin   
         always @(posedge CLK_I or posedge RST_I)
           if (RST_I)
             PIO_DATA_DLY_BOTH <= #UDLY 0;
           else
             PIO_DATA_DLY_BOTH <= PIO_BOTH_IN;

         // edge-capture register bits are treated as individual bits.
         genvar i_both;
         for( i_both = 0; i_both < INPUT_WIDTH; i_both = i_both + 1)
         begin
         always @(posedge CLK_I or posedge RST_I)
           if (RST_I)
             EDGE_CAPTURE_BOTH[i_both] <= #UDLY 0;
           else if (|(PIO_BOTH_IN[i_both] & ~PIO_DATA_DLY_BOTH[i_both]) && POSE_EDGE_IRQ == 1)
             EDGE_CAPTURE_BOTH[i_both] <= #UDLY PIO_BOTH_IN[i_both] & ~PIO_DATA_DLY_BOTH[i_both];
           else if (|(~PIO_BOTH_IN[i_both] & PIO_DATA_DLY_BOTH[i_both]) &&  NEGE_EDGE_IRQ == 1)
             EDGE_CAPTURE_BOTH[i_both] <= #UDLY ~PIO_BOTH_IN[i_both] & PIO_DATA_DLY_BOTH[i_both];
           else if (|(PIO_BOTH_IN[i_both] & ~PIO_DATA_DLY_BOTH[i_both]) && EITHER_EDGE_IRQ == 1)
             EDGE_CAPTURE_BOTH[i_both] <= #UDLY PIO_BOTH_IN[i_both] & ~PIO_DATA_DLY_BOTH[i_both];
           else if (|(~PIO_BOTH_IN[i_both] & PIO_DATA_DLY_BOTH[i_both]) && EITHER_EDGE_IRQ == 1)
             EDGE_CAPTURE_BOTH[i_both] <= #UDLY ~PIO_BOTH_IN[i_both] & PIO_DATA_DLY_BOTH[i_both];
           else if ( (~IRQ_MASK_BOTH[i_both]) & GPIO_DAT_I[i_both] & IRQ_MASK_WR_EN )
             // interrupt mask is being set, so clear edge-capture
             EDGE_CAPTURE_BOTH[i_both] <= #UDLY 0;
           else if (EDGE_CAP_WR_EN)
             // user's writing to the edge register, so update edge capture
             // register
             EDGE_CAPTURE_BOTH[i_both] <= #UDLY EDGE_CAPTURE_BOTH[i_both] & GPIO_DAT_I[i_both];
         end
         assign   IRQ_O = |(EDGE_CAPTURE_BOTH & IRQ_MASK_BOTH);

     end else if (IRQ_MODE == 1 && TRISTATE_PORTS == 1) begin
         assign  IRQ_O = |IRQ_TRI_TEMP; 
     end else
         assign  IRQ_O = 1'b0;
   endgenerate   

endmodule
`endif // GPIO_V
