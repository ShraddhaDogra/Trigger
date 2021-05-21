// ==============================================================================
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
// ==============================================================================/
//                        FILE DETAILS
// Project          : Async SRAM Controller
// File             : asram_core.v
// Title            : Asynchronous SRAM Controller
// Dependencies     : asram_params.v
// Description      : Implements the logic to interface async SRAM with Wishbone
//                    bus.
// ==============================================================================
//                        REVISION HISTORY
// Version          : 7.0
// Mod. Date        : Jun 27, 2005
// Changes Made     : Initial Creation
//
// Version          : 7.0SP2, 3.0
// Mod. Date        : 27 Sept. 2007
// Changes Made     : Endianess corrections, and full support for 8 and 16-bit
//                    operational modes.
//
// ==============================================================================
`ifndef ASRAM_CORE_FILE
 `define ASRAM_CORE_FILE
 `timescale 1ns/100ps
 `include "system_conf.v"

module asram_core #(parameter SRAM_DATA_WIDTH = 8,
                    parameter SRAM_ADDR_WIDTH = 23,
                    parameter READ_LATENCY = 1,
                    parameter WRITE_LATENCY = 1
                    )
  (// Clock and reset
   clk_i,
   rst_i,
   // Wishbone side interface
   cti_i,
   bte_i,
   addr_i,
   dat_i,
   sel_i,
   we_i,
   stb_i,
   cyc_i,
   ack_o,
   dat_o,
   // SRAM side interface
   sram_addr,
   sram_data_in,
   sram_data_out,
   sram_csn,
   sram_be,
   sram_wen,
   sram_oen);

   parameter                  SRAM_CYCLE     = 32/SRAM_DATA_WIDTH;
   parameter                  SRAM_BE_WIDTH  = SRAM_DATA_WIDTH/8;

   //////////////////////////////////////////////////////////////////////////////
                              //clock and reset inputs
   input                      clk_i;
   input                      rst_i;
   //Wishbone side interface
   input [2:0]                cti_i;
   input [1:0]                bte_i;
   input [31:0]               addr_i;
   input [31:0]               dat_i;
   input [3:0]                sel_i;
   input                      we_i;
   input                      stb_i;
   input                      cyc_i;
   output                     ack_o;
   output [31:0]              dat_o;
   //SRAM side interface
   output [SRAM_ADDR_WIDTH-1:0] sram_addr;
   output                       sram_csn;
   output [SRAM_BE_WIDTH-1:0]   sram_be;
   output                       sram_wen;
   output                       sram_oen;
   input [SRAM_DATA_WIDTH-1:0]  sram_data_in;
   output [SRAM_DATA_WIDTH-1:0] sram_data_out;

   ///////////////////////////////////////////////////////////////////////////
   // Internal registers and wires
              reg [31:0] dat_o;
   reg [2:0]             main_sm;
   reg                   ack_o;
   reg                   sram_wen;
   reg [3:0]             read_latency_cnt;
   reg [3:0]             write_latency_cnt;
   reg [2:0]             cycle;
   wire                  sram_data_width_32 = (SRAM_DATA_WIDTH == 32 ? 1 : 0);
   wire                  sram_data_width_16 = (SRAM_DATA_WIDTH == 16 ? 1 : 0);
   wire                  sram_data_width_8  = (SRAM_DATA_WIDTH == 8  ? 1 : 0);
   wire [SRAM_ADDR_WIDTH-1:0]           sram_addr_cls;
   reg  [SRAM_ADDR_WIDTH-1:0]           sram_addr_bst;
   reg                   we_bst,rd_bst ;

   wire 		 burst_enabled = 1;

 `define IDLE    3'b000
 `define READ1   3'b001
 `define READ2   3'b010
 `define READ3   3'b011
 `define RD_BST  3'b100
 `define WRITE1  3'b101
 `define WRITE2  3'b110
 `define WRITE3  3'b111

   // Main State Machine which controls the WishBone and SRAM interface
   always @ (posedge rst_i or posedge clk_i) begin
      if (rst_i) begin
         main_sm <=  `IDLE;
         read_latency_cnt  <= READ_LATENCY;
         write_latency_cnt <= WRITE_LATENCY;
         dat_o             <= {32{1'b0}};
         cycle             <= 3'h0;
         sram_wen          <= 1'b1;
         ack_o             <= 1'b0;
         we_bst            <= 1'b0;
         rd_bst            <= 1'b0;
         sram_addr_bst     <= {SRAM_ADDR_WIDTH{1'b0}};
      end else begin
         case (main_sm)
           `IDLE: begin
              if (cyc_i && stb_i && ~ack_o)
                if (we_i) begin
                   ack_o <= 1'b0;
                   sram_wen     <=  1'b0;
                   write_latency_cnt <=  WRITE_LATENCY;
                   main_sm      <=  `WRITE1;
                   rd_bst       <= 0;
                   // classic cycle or single cycle or data width < 32
                   if (cti_i == 3'b000 || cti_i == 3'b111 || !sram_data_width_32) begin
                      we_bst        <= 1'b0;
                      sram_addr_bst <= 0;
                   end else begin
                      sram_addr_bst <= addr_i[SRAM_ADDR_WIDTH-1:0];
                      we_bst        <= 1'b1;
                   end
                   // classic cycle or if data width < 32
                end else if (cti_i == 3'b000 || cti_i == 3'b111 || !sram_data_width_32) begin
                   we_bst            <= 1'b0;
                   rd_bst            <= 0;
                   sram_addr_bst     <= 0;
                   read_latency_cnt  <=  READ_LATENCY - 1;
 `ifdef NO_READ_WAIT
                   main_sm <=  `READ2;
                   if (sram_data_width_32)
                     ack_o <=  1'b1;
                   else
                     ack_o <=  1'b0;
                   dat_o[SRAM_DATA_WIDTH - 1 : 0] <=  sram_data_in;
 `else
                   main_sm <=  `READ1;
                   ack_o <=  1'b0;
 `endif
                end else begin                  // burst read cycle
                   main_sm          <= `RD_BST;
                   ack_o            <= 1'b0;
                   we_bst           <= 1'b0;
                   rd_bst           <= 1'b1;
                   sram_addr_bst    <= addr_i[SRAM_ADDR_WIDTH-1:0];
                   read_latency_cnt <=  READ_LATENCY - 1;
                end
              else begin
                 main_sm  <=  `IDLE;
                 sram_wen <= 1'b1;
                 ack_o    <=  1'b0;
                 we_bst   <= 1'b0;
		 rd_bst   <= 1'b0;
              end
              cycle <= ((sel_i == 4'b0011) || (sel_i == 4'b1100))                                            & sram_data_width_16 ? 3'b001 :
                       ((sel_i == 4'b0011) || (sel_i == 4'b1100))                                            & sram_data_width_8  ? 3'b010 :
                       ((sel_i == 4'b0001) || (sel_i == 4'b0010) || (sel_i == 4'b0100) || (sel_i == 4'b1000))& sram_data_width_8  ? 3'b001 :
                       ((sel_i == 4'b0001) || (sel_i == 4'b0010) || (sel_i == 4'b0100) || (sel_i == 4'b1000))& sram_data_width_16 ? 3'b001 :
                        SRAM_CYCLE;

              dat_o <=  0;
           end
           `READ1: if (read_latency_cnt != 4'b0000)
             read_latency_cnt <=  read_latency_cnt - 1;
           else begin
              main_sm <=  `READ2;
              ack_o   <= (cycle == 1) ? 1'b1 : 1'b0;
              if (sram_data_width_32)
                dat_o <= sram_data_in;
              if (sram_data_width_16) begin
                 // performing a dword or word access return MSB's
                 if (cycle == 2)                                 dat_o[31:16] <= sram_data_in;
                 else if ((cycle == 1) && (sel_i[1:0] == 2'b00)) dat_o[31:16] <= sram_data_in;
                 else                                            dat_o[15:0]  <= sram_data_in;
              end
              if (sram_data_width_8) begin
                 // performing single byte accesses
                 if      (sel_i == 4'b0001) dat_o[7:0]                     <= sram_data_in;
                 else if (sel_i == 4'b0010) dat_o[15:8]                    <= sram_data_in;
                 else if (sel_i == 4'b0100) dat_o[23:16]                   <= sram_data_in;
                 else if (sel_i == 4'b1000) dat_o[31:24]                   <= sram_data_in;
                 // performing a word access
                 else if ((sel_i == 4'b1100) && (cycle == 2)) dat_o[31:24] <= sram_data_in;
                 else if ((sel_i == 4'b1100) && (cycle == 1)) dat_o[23:16] <= sram_data_in;
                 else if ((sel_i == 4'b0011) && (cycle == 2)) dat_o[15:8]  <= sram_data_in;
                 else if ((sel_i == 4'b0011) && (cycle == 1)) dat_o[7:0]   <= sram_data_in;
                 // performing a dword access
                 else if ((cycle == 4) && (sel_i == 4'b1111)) dat_o[31:24] <= sram_data_in;
                 else if ((cycle == 3) && (sel_i == 4'b1111)) dat_o[23:16] <= sram_data_in;
                 else if ((cycle == 2) && (sel_i == 4'b1111)) dat_o[15:8]  <= sram_data_in;
                 else                                         dat_o[7:0]   <= sram_data_in;
              end
           end
           `READ2: begin
              ack_o <=  1'b0;
              main_sm <=  `READ3;
              read_latency_cnt <=  READ_LATENCY;
              if (cycle == 1)
                cycle <= SRAM_CYCLE;
              else
                cycle <= cycle - 1; end
           `READ3: begin
              if (cycle != SRAM_CYCLE) begin
 `ifdef NO_READ_WAIT
                 if (sram_data_width_32)
                   dat_o <= sram_data_in;
                 if (sram_data_width_16) begin
                    // performing a dword or word access return MSB's
                    if (cycle == 2)                                 dat_o[31:16] <= sram_data_in;
                    else if ((cycle == 1) && (sel_i[1:0] == 2'b00)) dat_o[31:16] <= sram_data_in;
                    else                                            dat_o[15:0]  <= sram_data_in;
                 end
                 if (sram_data_width_8) begin
                    // performing single byte accesses
                    if      (sel_i == 4'b0001) dat_o[7:0]                     <= sram_data_in;
                    else if (sel_i == 4'b0010) dat_o[15:8]                    <= sram_data_in;
                    else if (sel_i == 4'b0100) dat_o[23:16]                   <= sram_data_in;
                    else if (sel_i == 4'b1000) dat_o[31:24]                   <= sram_data_in;
                    // performing a word access
                    else if ((sel_i == 4'b1100) && (cycle == 2)) dat_o[31:24] <= sram_data_in;
                    else if ((sel_i == 4'b1100) && (cycle == 1)) dat_o[23:16] <= sram_data_in;
                    else if ((sel_i == 4'b0011) && (cycle == 2)) dat_o[15:8]  <= sram_data_in;
                    else if ((sel_i == 4'b0011) && (cycle == 1)) dat_o[7:0]   <= sram_data_in;
                    // performing a dword access
                    else if ((cycle == 4) && (sel_i == 4'b1111)) dat_o[31:24] <= sram_data_in;
                    else if ((cycle == 3) && (sel_i == 4'b1111)) dat_o[23:16] <= sram_data_in;
                    else if ((cycle == 2) && (sel_i == 4'b1111)) dat_o[15:8]  <= sram_data_in;
                    else                                         dat_o[7:0]   <= sram_data_in;
                 end
                 ack_o <= (cycle == 1) ? 1'b1 : 1'b0;
                 main_sm <=  `READ2;
 `else
                 main_sm <=  `READ1;
                 ack_o <=  1'b0;
 `endif
              end
              else if (cyc_i & stb_i) begin
                 read_latency_cnt  <=  READ_LATENCY;
 `ifdef NO_READ_WAIT
                 main_sm <=  `READ2;
                 if (SRAM_DATA_WIDTH == 32)
                   ack_o <=  1'b1;
                 else
                   ack_o <=  1'b0;
                 dat_o[SRAM_DATA_WIDTH - 1 : 0] <=  sram_data_in;
 `else
                 main_sm <=  `READ1;
                 ack_o   <=  1'b0;
 `endif
                 cycle <= SRAM_CYCLE;
              end else begin
                 main_sm <=  `IDLE;
                 ack_o   <=  1'b0;
              end
           end
           `RD_BST: begin
              if (read_latency_cnt == 0) begin
                 dat_o         <= sram_data_in;
                 ack_o         <= 1'b1;
                 sram_addr_bst <= sram_addr_bst + 4; // always four because 32 bit array
                 if (cti_i == 3'b111 || cti_i == 3'b000) begin
                    main_sm          <= `IDLE;
                 end else begin
                    read_latency_cnt <= READ_LATENCY - 1;
                    main_sm          <= `RD_BST;
                 end
              end else begin
                 ack_o            <= 1'b0;
                 read_latency_cnt <= read_latency_cnt - 1;
                 main_sm          <= `RD_BST;
              end
           end
           `WRITE1: begin
              if (write_latency_cnt == 0) begin
                 ack_o         <=  (cycle == 1) ? 1'b1 : 1'b0;
                 main_sm       <= `WRITE2;
                 sram_addr_bst <= sram_addr_bst + 4; // always four because 32 bit array
                 if (we_bst) begin
                    if (cti_i == 3'b111 || cti_i == 3'b000) begin
                       sram_wen <=  1'b1;
                       we_bst   <= 0;
                    end
                 end else begin
                    sram_wen <=  1'b1;
                 end
              end else begin
                 ack_o             <=  1'b0;
                 sram_wen          <=  1'b0;
                 write_latency_cnt <=  write_latency_cnt - 1;
              end
           end
           `WRITE2: begin
              ack_o <=  1'b0;
              if (cycle != 1) begin
                 cycle             <= cycle - 1;
                 main_sm           <= `WRITE1;
                 write_latency_cnt <= WRITE_LATENCY + 1;
              end else begin
                 cycle   <= SRAM_CYCLE;
                 main_sm <=  `IDLE;
              end
           end
         endcase
      end
   end

   assign  sram_addr_cls = 
                           // single byte access on an 8-bit memory
                           (cyc_i && (SRAM_CYCLE == 4) && (sel_i == 4'b0001))                    ? {addr_i[31:2],2'b11} :
                           (cyc_i && (SRAM_CYCLE == 4) && (sel_i == 4'b0010))                    ? {addr_i[31:2],2'b10} :
                           (cyc_i && (SRAM_CYCLE == 4) && (sel_i == 4'b0100))                    ? {addr_i[31:2],2'b01} :
                           (cyc_i && (SRAM_CYCLE == 4) && (sel_i == 4'b1000))                    ? {addr_i[31:2],2'b00} :
                           // dword size access on an 8-bit memory
                           (cyc_i && (SRAM_CYCLE == 4) && (sel_i == 4'b1111) && (cycle == 4))    ? {addr_i[31:2],2'b00} :
                           (cyc_i && (SRAM_CYCLE == 4) && (sel_i == 4'b1111) && (cycle == 3))    ? {addr_i[31:2],2'b01} :
                           (cyc_i && (SRAM_CYCLE == 4) && (sel_i == 4'b1111) && (cycle == 2))    ? {addr_i[31:2],2'b10} :
                           (cyc_i && (SRAM_CYCLE == 4) && (sel_i == 4'b1111) && (cycle == 1))    ? {addr_i[31:2],2'b11} :
                           // word size acces on an 8-bit memory
                           (cyc_i && (SRAM_CYCLE == 4) && (sel_i == 4'b1100) && (cycle == 2))    ? {addr_i[31:2],2'b00} :
                           (cyc_i && (SRAM_CYCLE == 4) && (sel_i == 4'b1100) && (cycle == 1))    ? {addr_i[31:2],2'b01} :
                           (cyc_i && (SRAM_CYCLE == 4) && (sel_i == 4'b0011) && (cycle == 2))    ? {addr_i[31:2],2'b10} :
                           (cyc_i && (SRAM_CYCLE == 4) && (sel_i == 4'b0011) && (cycle == 1))    ? {addr_i[31:2],2'b11} :
                           // dword size access on a 16-bit memory
                           (cyc_i && (SRAM_CYCLE == 2) && (cycle == 2) && (sel_i == 4'b1111))     ? {addr_i[31:2],2'b00} :
                           (cyc_i && (SRAM_CYCLE == 2) && (cycle == 1) && (sel_i == 4'b1111))     ? {addr_i[31:2],2'b10} :
                           // byte/word size access on a 16-bit memory
                           (cyc_i && (SRAM_CYCLE == 2) && (cycle == 1) && (sel_i[1:0] == 2'b00)) ? {addr_i[31:2],2'b00} :
                           (cyc_i && (SRAM_CYCLE == 2) && (cycle == 1) && (sel_i[3:2] == 2'b00)) ? {addr_i[31:2],2'b10} :
                           // dword/word/byte access on a 32-bit memory (just use the BE's)
                           (cyc_i && (SRAM_CYCLE == 1))                                          ? {addr_i[31:2],2'b00} :
                           0;
   
   assign  sram_addr = ((rd_bst | we_bst) ? sram_addr_bst : sram_addr_cls);

   assign  sram_oen  = ~(stb_i && cyc_i && ~we_i);
   assign  sram_csn  = ~(stb_i && cyc_i);
   assign  sram_be   = 
                       ((SRAM_CYCLE == 4) && (sel_i == 4'b0001))                    ? {SRAM_BE_WIDTH{1'b0}} :
                       ((SRAM_CYCLE == 4) && (sel_i == 4'b0010))                    ? {SRAM_BE_WIDTH{1'b0}} :
                       ((SRAM_CYCLE == 4) && (sel_i == 4'b0100))                    ? {SRAM_BE_WIDTH{1'b0}} :
                       ((SRAM_CYCLE == 4) && (sel_i == 4'b1000))                    ? {SRAM_BE_WIDTH{1'b0}} :
                       ((SRAM_CYCLE == 4) && (sel_i == 4'b1111) && (cycle == 4))    ? {SRAM_BE_WIDTH{1'b0}} :
                       ((SRAM_CYCLE == 4) && (sel_i == 4'b1111) && (cycle == 3))    ? {SRAM_BE_WIDTH{1'b0}} :
                       ((SRAM_CYCLE == 4) && (sel_i == 4'b1111) && (cycle == 2))    ? {SRAM_BE_WIDTH{1'b0}} :
                       ((SRAM_CYCLE == 4) && (sel_i == 4'b1111) && (cycle == 1))    ? {SRAM_BE_WIDTH{1'b0}} :
                       ((SRAM_CYCLE == 4) && (sel_i == 4'b1100) && (cycle == 2) )   ? {SRAM_BE_WIDTH{1'b0}} :
                       ((SRAM_CYCLE == 4) && (sel_i == 4'b1100) && (cycle == 1) )   ? {SRAM_BE_WIDTH{1'b0}} :
                       ((SRAM_CYCLE == 4) && (sel_i == 4'b0011) && (cycle == 2) )   ? {SRAM_BE_WIDTH{1'b0}} :
                       ((SRAM_CYCLE == 4) && (sel_i == 4'b0011) && (cycle == 1) )   ? {SRAM_BE_WIDTH{1'b0}} :
                       ((SRAM_CYCLE == 2) && (cycle == 2) && (sel_i == 4'b1111))    ? ~sel_i[3:2] :
                       ((SRAM_CYCLE == 2) && (cycle == 1) && (sel_i == 4'b1111))    ? ~sel_i[1:0] :
                       ((SRAM_CYCLE == 2) && (cycle == 1) && (sel_i[3:2] == 2'b00)) ? ~sel_i[1:0] :
                       ((SRAM_CYCLE == 2) && (cycle == 1) && (sel_i[1:0] == 2'b00)) ? ~sel_i[3:2] :
                       ((SRAM_CYCLE == 1))                                          ? ~sel_i      :
                       {SRAM_BE_WIDTH{1'b1}};

   assign  sram_data_out =  sram_data_width_32 ? dat_i :
                            sram_data_width_16 ? ( (sel_i[3:2] == 2'b00)                   ? dat_i[15:0]  :
                                                   (sel_i[1:0] == 2'b00)                   ? dat_i[31:16] :
                                                   (cycle == 2)                            ? dat_i[31:16] :
                                                   ((cycle == 1) && (sel_i[1:0] == 2'b00)) ? dat_i[31:16] :
                                                    dat_i[15:0])                                          :
                             ((sel_i == 4'b0001)                   ? dat_i[7:0]   :
                              (sel_i == 4'b0010)                   ? dat_i[15:8]  :
                              (sel_i == 4'b0100)                   ? dat_i[23:16] :
                              (sel_i == 4'b1000)                   ? dat_i[31:24] :
                              ((sel_i == 4'b1100) && (cycle == 2)) ? dat_i[31:24] :
                              ((sel_i == 4'b1100) && (cycle == 1)) ? dat_i[23:16] :
                              ((sel_i == 4'b0011) && (cycle == 2)) ? dat_i[15:8]  :
                              ((sel_i == 4'b0011) && (cycle == 1)) ? dat_i[7:0]   :
                              ((sel_i == 4'b1111) && (cycle == 4)) ? dat_i[31:24] :
                              ((sel_i == 4'b1111) && (cycle == 3)) ? dat_i[23:16] :
                              ((sel_i == 4'b1111) && (cycle == 2)) ? dat_i[15:8]  :
                              ((sel_i == 4'b1111) && (cycle == 1)) ? dat_i[7:0]   : 0);

endmodule
`endif // ASRAM_CORE_FILE
