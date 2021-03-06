// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2006 (c) Lattice Semiconductor Corporation
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
// Project          : LatticeMico32 EBR Component
// File             : WB_EBR_CTRL.v
// Title            : Top-level of EBR Memory Controller
// Dependencies     : system_conf.v
// =============================================================================
//                        REVISION HISTORY
// Version          : 1.0
// Mod. Date        : Jun 27, 2005
// Changes Made     : Initial Creation
//
// Version          : 7.0SP2, 3.0
// Mod. Date        : Oct 16 2007
// Changes Made     : Support EBR size which is not 2's power
//                    Fix the PMI Memory's reset mode to be sync mode
//
// Version          : 3.1
// Mod. Date        : Jan 14, 2007
// Changes Made     : Single Read/Write command is changed from 3 cycle to
//                    2 cycle. First transfer of write burst is also made to
//                    2 cycle.                    
//
// Version          : 3.2
// Mod. Date        : April 23, 2009
// Changes Made     : Support for Wishbone Burst Cycles for sub-word sizes
// =============================================================================

`ifndef WB_EBR_CTRL_FILE
 `define WB_EBR_CTRL_FILE
 `timescale 1ns/100ps
 `include "system_conf.v"
module wb_ebr_ctrl 
  #(parameter SIZE=4096,
    parameter EBR_DATA_WIDTH = 32,
    parameter INIT_FILE_FORMAT="hex",
    parameter INIT_FILE_NAME="none"
    ) 
   (
    input CLK_I,
    input RST_I,
    
    input [31:0] EBR_ADR_I,
    input [31:0] EBR_DAT_I,
    input EBR_WE_I,
    input EBR_CYC_I,
    input EBR_STB_I,
    input [3:0] EBR_SEL_I,
    input [2:0] EBR_CTI_I,
    input [1:0] EBR_BTE_I,
    input EBR_LOCK_I,
    
    output reg [31:0] EBR_DAT_O,
    output reg EBR_ACK_O,
    output reg EBR_ERR_O,
    output reg EBR_RTY_O
    );
   
   function integer clogb2;
      input [31:0] value;
      reg [31:0] i;
      reg [31:0] temp;
      begin
	 temp = 0;
	 i    = 0;
	 for (i = 0; temp < value; i = i + 1)  
           temp = 1<<i;
	 clogb2 = i-1;
      end
   endfunction // clogb2
   
   parameter UDLY    = 1;
   parameter EBR_ADDR_WIDTH = clogb2(SIZE/4);
   parameter EBR_ADDR_DEPTH = SIZE/4;
   
   /*----------------------------------------------------------------------
    Internal Nets and Registers
    ----------------------------------------------------------------------*/
   wire [EBR_DATA_WIDTH-1:0] data;         // Data read from RAM
   reg 			     write_enable; // RAM write enable
   reg [EBR_DATA_WIDTH-1:0]  write_data, write_data_d;   // RAM write data
   reg [EBR_ADDR_WIDTH-1:0]  pmi_address, pmi_address_nxt;
   reg [EBR_ADDR_WIDTH-1:0]  read_address, write_address;   
   reg 			     EBR_ACK_O_nxt;
   reg [EBR_DATA_WIDTH-1:0]  read_data;
   reg 			     read_enable;
   reg 			     raw_hazard, raw_hazard_nxt;
   reg [EBR_DATA_WIDTH-1:0]  EBR_DAT_I_d;
   reg [3:0] 		     EBR_SEL_I_d;
   reg 			     delayed_write;
      
   /*----------------------------------------------------------------------
    State Machine
    ----------------------------------------------------------------------*/
   reg [2:0] state, state_nxt;
   parameter ST_IDLE  = 3'b000;
   parameter ST_BURST = 3'b001;
   parameter ST_END   = 3'b010;
   parameter ST_SUBRD = 3'b100;
   parameter ST_SUB   = 3'b101;
   parameter ST_SUBWR = 3'b110;
      
   always @(/*AUTOSENSE*/EBR_ACK_O or EBR_CTI_I or EBR_CYC_I
	    or EBR_SEL_I or EBR_STB_I or EBR_WE_I or state)
     case (state)
       ST_IDLE:
	 if (EBR_STB_I && EBR_CYC_I && (EBR_ACK_O == 1'b0))
	   if ((EBR_CTI_I == 3'b000) || (EBR_CTI_I == 3'b111))
	     state_nxt = ST_END;
	   else
	     if (EBR_WE_I && (EBR_SEL_I != 4'b1111))
	       state_nxt = ST_SUBRD;
	     else
	       state_nxt = ST_BURST;
	 else
	   state_nxt = state;
       
       ST_BURST:
	 if (EBR_CTI_I == 3'b111)
	   state_nxt = ST_IDLE;
	 else
	   state_nxt = state;
       
       ST_SUBRD:
	 state_nxt = ST_SUB;
       
       ST_SUB:
	 if (EBR_CTI_I == 3'b111)
	   state_nxt = ST_SUBWR;
	 else
	   state_nxt = state;
       
       default:
	 state_nxt = ST_IDLE;
     endcase
   
   /*----------------------------------------------------------------------
    
    ----------------------------------------------------------------------*/
   always @(/*AUTOSENSE*/read_address or state or write_address)
     if ((state == ST_SUB) && (read_address == write_address))
       raw_hazard_nxt = 1'b1;
     else
       raw_hazard_nxt = 1'b0;
   
   /*----------------------------------------------------------------------
    Set up read to EBR
    ----------------------------------------------------------------------*/
   always @(/*AUTOSENSE*/EBR_CTI_I or EBR_SEL_I or EBR_WE_I or data
	    or raw_hazard or raw_hazard_nxt or state or write_data_d)
     begin
	if ((EBR_WE_I == 1'b0)
	    || (EBR_WE_I
		&& (((state == ST_IDLE) && ((EBR_CTI_I == 3'b000) || (EBR_CTI_I == 3'b111) || (EBR_SEL_I != 4'b1111)))
		    || (state == ST_SUBRD)
		    || ((state == ST_SUB) && (raw_hazard_nxt == 1'b0)))))
	  read_enable = 1'b1;
	else
	  read_enable = 1'b0;
	
	read_data = raw_hazard ? write_data_d : data;
     end
   
   /*----------------------------------------------------------------------
    Set up write to EBR
    ----------------------------------------------------------------------*/
   always @(/*AUTOSENSE*/EBR_CTI_I or EBR_CYC_I or EBR_DAT_I
	    or EBR_DAT_I_d or EBR_SEL_I or EBR_SEL_I_d or EBR_STB_I
	    or EBR_WE_I or data or read_data or state)
     begin
	if ((EBR_WE_I
	     && (// Word Burst Write (first write in a sequence)
		 ((state == ST_IDLE) 
		  && EBR_CYC_I && EBR_STB_I && (EBR_CTI_I != 3'b000) && (EBR_CTI_I != 3'b111) && (EBR_SEL_I == 4'b1111))
		 // Single Write
		 || (state == ST_END)
		 // Burst Write (all writes beyond first write)
		 || (state == ST_BURST)))
	    // Sub-Word Burst Write
	    || ((state == ST_SUB) || (state == ST_SUBWR)))
	  write_enable = 1'b1;
	else
	  write_enable = 1'b0;

	if ((state == ST_SUBRD) || (state == ST_SUB) || (state == ST_SUBWR))
	  delayed_write = 1'b1;
	else
	  delayed_write = 1'b0;
		
	write_data[7:0]   = (delayed_write
			     ? (EBR_SEL_I_d[0] ? EBR_DAT_I_d[7:0] : read_data[7:0])
			     : (EBR_SEL_I[0] ? EBR_DAT_I[7:0] : data[7:0]));
	write_data[15:8]  = (delayed_write
			     ? (EBR_SEL_I_d[1] ? EBR_DAT_I_d[15:8] : read_data[15:8])
			     : (EBR_SEL_I[1] ? EBR_DAT_I[15:8] : data[15:8]));
	write_data[23:16] = (delayed_write
			     ? (EBR_SEL_I_d[2] ? EBR_DAT_I_d[23:16] : read_data[23:16])
			     : (EBR_SEL_I[2] ? EBR_DAT_I[23:16] : data[23:16]));
	write_data[31:24] = (delayed_write
			     ? (EBR_SEL_I_d[3] ? EBR_DAT_I_d[31:24] : read_data[31:24])
			     : (EBR_SEL_I[3] ? EBR_DAT_I[31:24] : data[31:24]));
     end
   
   /*----------------------------------------------------------------------
    Set up address to EBR
    ----------------------------------------------------------------------*/
   always @(/*AUTOSENSE*/EBR_ADR_I or EBR_WE_I or pmi_address or state)
     begin
	if (// First address of any access is obtained from Wishbone signals
	    (state == ST_IDLE)
	    // Read for a Sub-Word Wishbone Burst Write
	    || (state == ST_SUB))
	  read_address = EBR_ADR_I[EBR_ADDR_WIDTH+1:2];
	else
	  read_address = pmi_address;
	
	if ((state == ST_SUB) || (state == ST_SUBWR))
	  write_address = pmi_address;
	else
	  write_address = EBR_ADR_I[EBR_ADDR_WIDTH+1:2];
	
	// Keep track of first address and subsequently increment it by 4
	// bytes on a burst read
	if (EBR_WE_I)
	  pmi_address_nxt = EBR_ADR_I[EBR_ADDR_WIDTH+1:2];
	else
	  if (state == ST_IDLE)
	    pmi_address_nxt = EBR_ADR_I[EBR_ADDR_WIDTH+1:2] + 1'b1;
	  else
	    pmi_address_nxt = pmi_address + 1'b1;
     end
   
   /*----------------------------------------------------------------------
    Set up outgoing wishbone signals
    ----------------------------------------------------------------------*/
   always @(/*AUTOSENSE*/EBR_ACK_O or EBR_CYC_I or EBR_STB_I or data
	    or state)
     begin
	if (((state == ST_IDLE) && EBR_CYC_I && EBR_STB_I && (EBR_ACK_O == 1'b0))
	    || (state == ST_BURST)
	    || (state == ST_SUBRD)
	    || (state == ST_SUB))
	  EBR_ACK_O_nxt = 1'b1;
	else
	  EBR_ACK_O_nxt = 1'b0;
	
	EBR_DAT_O = data;
	EBR_RTY_O = 1'b0;
	EBR_ERR_O = 1'b0;
     end
   
   /*----------------------------------------------------------------------
    Sequential Logic
    ----------------------------------------------------------------------*/
   always @(posedge CLK_I)
     if (RST_I)
       begin
	  EBR_ACK_O <= #UDLY 1'b0;
	  EBR_DAT_I_d <= #UDLY 0;
	  EBR_SEL_I_d <= #UDLY 0;
	  state <= #UDLY ST_IDLE;
	  pmi_address <= #UDLY 0;
	  write_data_d <= #UDLY 0;
	  raw_hazard <= #UDLY 0;
       end
     else
       begin
	  EBR_ACK_O <= #UDLY EBR_ACK_O_nxt;
	  EBR_DAT_I_d <= #UDLY EBR_DAT_I;
	  EBR_SEL_I_d <= #UDLY EBR_SEL_I;
	  state <= #UDLY state_nxt;
	  pmi_address <= #UDLY pmi_address_nxt;
	  write_data_d <= #UDLY write_data;
	  raw_hazard <= #UDLY raw_hazard_nxt;
       end
   
   /*----------------------------------------------------------------------
    Actual EBR Instantiation
    ----------------------------------------------------------------------*/
   pmi_ram_dp 
     #(
       .pmi_wr_addr_depth    (EBR_ADDR_DEPTH),
       .pmi_wr_addr_width    (EBR_ADDR_WIDTH),
       .pmi_wr_data_width    (EBR_DATA_WIDTH),
       .pmi_rd_addr_depth    (EBR_ADDR_DEPTH),
       .pmi_rd_addr_width    (EBR_ADDR_WIDTH),
       .pmi_rd_data_width    (EBR_DATA_WIDTH),
       .pmi_regmode          ("noreg"),
       .pmi_init_file        (INIT_FILE_NAME),
       .pmi_init_file_format (INIT_FILE_FORMAT),
       .pmi_gsr              ("enable"),
       .pmi_resetmode        ("sync"),
       .pmi_family           (`LATTICE_FAMILY),
       .module_type          ("pmi_ram_dp")
       )
   ram
     (
      // ----- Inputs -------
      .Reset              (RST_I),
      .WrClock            (CLK_I),
      .RdClock            (CLK_I),
      .WrClockEn          (1'b1),
      .RdClockEn          (read_enable),
      .RdAddress          (read_address),
      .WrAddress          (write_address),
      .Data               (write_data),
      .WE                 (write_enable),
      // ----- Outputs -------
      .Q                  (data)
      );

endmodule
`endif // WB_EBR_CTRL_FILE
