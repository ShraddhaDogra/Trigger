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
// Project          : LatticeMico32
// File             : lm32_ram.v
// Title            : Pseudo dual-port RAM.
// Version          : 6.1.17
//                  : Initial Release
// Version          : 7.0SP2, 3.0
//                  : No Change
// Version          : 3.1
//                  : Options added to select EBRs (True-DP, Psuedo-DP, DQ, or
//                  : Distributed RAM).
// Version          : 3.2
//                  : EBRs use SYNC resets instead of ASYNC resets.
// Version          : 3.5
//                  : Added read-after-write hazard resolution when using true
//                  : dual-port EBRs
// =============================================================================

`include "lm32_include.v"

/////////////////////////////////////////////////////
// Module interface
/////////////////////////////////////////////////////

module lm32_ram 
  (
   // ----- Inputs -------
   read_clk,
   write_clk,
   reset,
   enable_read,
   read_address,
   enable_write,
   write_address,
   write_data,
   write_enable,
   // ----- Outputs -------
   read_data
   );
   
   /*----------------------------------------------------------------------
    Parameters
    ----------------------------------------------------------------------*/
   parameter data_width = 1;               // Width of the data ports
   parameter address_width = 1;            // Width of the address ports
   parameter RAM_IMPLEMENTATION = "AUTO";  // Implement memory in EBRs, else
                                           // let synthesis tool select best 
                                           // possible solution (EBR or LUT)
   parameter RAM_TYPE = "RAM_DP";          // Type of EBR to be used
   
   /*----------------------------------------------------------------------
    Inputs
    ----------------------------------------------------------------------*/
   input read_clk;                         // Read clock
   input write_clk;                        // Write clock
   input reset;                            // Reset
   
   input enable_read;                      // Access enable
   input [address_width-1:0] read_address; // Read/write address
   input enable_write;                     // Access enable
   input [address_width-1:0] write_address;// Read/write address
   input [data_width-1:0] write_data;      // Data to write to specified address
   input write_enable;                     // Write enable
   
   /*----------------------------------------------------------------------
    Outputs
    ----------------------------------------------------------------------*/
   output [data_width-1:0] read_data;      // Data read from specified addess
   wire   [data_width-1:0] read_data;
   
   generate
      
      if ( RAM_IMPLEMENTATION == "EBR" )
	begin
	   if ( RAM_TYPE == "RAM_DP" )
	     begin
		pmi_ram_dp 
		  #( 
		     // ----- Parameters -----
		     .pmi_wr_addr_depth(1<<address_width),
		     .pmi_wr_addr_width(address_width),
		     .pmi_wr_data_width(data_width),
		     .pmi_rd_addr_depth(1<<address_width),
		     .pmi_rd_addr_width(address_width),
		     .pmi_rd_data_width(data_width),
		     .pmi_regmode("noreg"),
		     .pmi_gsr("enable"),
		     .pmi_resetmode("sync"),
		     .pmi_init_file("none"),
		     .pmi_init_file_format("binary"),
		     .pmi_family(`LATTICE_FAMILY),
		     .module_type("pmi_ram_dp")
		     )
		lm32_ram_inst
		  (
		   // ----- Inputs -----
		   .Data(write_data),
		   .WrAddress(write_address),
		   .RdAddress(read_address),
		   .WrClock(write_clk),
		   .RdClock(read_clk),
		   .WrClockEn(enable_write),
		   .RdClockEn(enable_read),
		   .WE(write_enable),
		   .Reset(reset),
		   // ----- Outputs -----
		   .Q(read_data)
		   );
	     end
	   else
	     begin
		// True Dual-Port EBR
		wire   [data_width-1:0] read_data_A, read_data_B;
		reg [data_width-1:0] 	raw_data, raw_data_nxt;
		reg 			raw, raw_nxt;
		
		/*----------------------------------------------------------------------
		 Is a read being performed in the same cycle as a write? Indicate this
		 event with a RAW hazard signal that is released only when a new read
		 or write occurs later.
		 ----------------------------------------------------------------------*/
		always @(/*AUTOSENSE*/enable_read or enable_write
			 or raw or raw_data or read_address
			 or write_address or write_data
			 or write_enable)
		  if (// Read
		      enable_read
		      // Write
		      && enable_write && write_enable
		      // Read and write address match
		      && (read_address == write_address))
		    begin
		       raw_data_nxt = write_data;
		       raw_nxt = 1'b1;
		    end
		  else
		    if (raw && (enable_read == 1'b0) && (enable_write == 1'b0))
		      begin
			 raw_data_nxt = raw_data;
			 raw_nxt = 1'b1;
		      end
		    else
		      begin
			 raw_data_nxt = raw_data;
			 raw_nxt = 1'b0;
		      end
		
		// Send back write data in case of a RAW hazard; else send back
		// data from memory
		assign read_data = raw ? raw_data : read_data_B;
		
		/*----------------------------------------------------------------------
		 Sequential Logic
		 ----------------------------------------------------------------------*/
		always @(posedge read_clk)
		  if (reset)
		    begin
		       raw_data <= #1 0;
		       raw <= #1 1'b0;
		    end
		  else
		    begin
		       raw_data <= #1 raw_data_nxt;
		       raw <= #1 raw_nxt;
		    end
		
		pmi_ram_dp_true 
		  #( 
		     // ----- Parameters -----
		     .pmi_addr_depth_a(1<<address_width),
		     .pmi_addr_width_a(address_width),
		     .pmi_data_width_a(data_width),
		     .pmi_addr_depth_b(1<<address_width),
		     .pmi_addr_width_b(address_width),
		     .pmi_data_width_b(data_width),
		     .pmi_regmode_a("noreg"),
		     .pmi_regmode_b("noreg"),
		     .pmi_gsr("enable"),
		     .pmi_resetmode("sync"),
		     .pmi_init_file("none"),
		     .pmi_init_file_format("binary"),
		     .pmi_family(`LATTICE_FAMILY),
		     .module_type("pmi_ram_dp_true")
		     )
		lm32_ram_inst
		  (
		   // ----- Inputs -----
		   .DataInA(write_data),
		   .DataInB(write_data),
		   .AddressA(write_address),
		   .AddressB(read_address),
		   .ClockA(write_clk),
		   .ClockB(read_clk),
		   .ClockEnA(enable_write),
		   .ClockEnB(enable_read),
		   .WrA(write_enable),
		   .WrB(`FALSE),
		   .ResetA(reset),
		   .ResetB(reset),
		   // ----- Outputs -----
		   .QA(read_data_A),
		   .QB(read_data_B)
		   );
	     end
	end
	else if ( RAM_IMPLEMENTATION == "SLICE" )
	  begin
	     reg [address_width-1:0] ra; // Registered read address
	     
	     pmi_distributed_dpram 
	       #(
		 // ----- Parameters -----
		 .pmi_addr_depth(1<<address_width),
		 .pmi_addr_width(address_width),
		 .pmi_data_width(data_width),
		 .pmi_regmode("noreg"),
		 .pmi_init_file("none"),
		 .pmi_init_file_format("binary"),
		 .pmi_family(`LATTICE_FAMILY),
		 .module_type("pmi_distributed_dpram")
		 )
	     pmi_distributed_dpram_inst
	       (
		// ----- Inputs -----
		.WrAddress(write_address),
		.Data(write_data),
		.WrClock(write_clk),
		.WE(write_enable),
		.WrClockEn(enable_write),
		.RdAddress(ra),
		.RdClock(read_clk),
		.RdClockEn(enable_read),
		.Reset(reset),
		// ----- Outputs -----
		.Q(read_data)
		);
	     
	     always @(posedge read_clk)
	       if (enable_read)
		 ra <= read_address;
	  end
      
	else 
	  begin
	     /*----------------------------------------------------------------------
	      Internal nets and registers
	      ----------------------------------------------------------------------*/
	     reg [data_width-1:0]    mem[0:(1<<address_width)-1]; // The RAM
	     reg [address_width-1:0] ra; // Registered read address
	     
	     /*----------------------------------------------------------------------
	      Combinational Logic
	      ----------------------------------------------------------------------*/
	     // Read port
	     assign read_data = mem[ra]; 
	     
	     /*----------------------------------------------------------------------
	      Sequential Logic
	      ----------------------------------------------------------------------*/
	     // Write port
	     always @(posedge write_clk)
	       if ((write_enable == `TRUE) && (enable_write == `TRUE))
		 mem[write_address] <= write_data; 
	     
	     // Register read address for use on next cycle
	     always @(posedge read_clk)
	       if (enable_read)
		 ra <= read_address;
	     
	  end

   endgenerate

endmodule
