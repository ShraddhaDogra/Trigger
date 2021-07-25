
//   ===========================================================================
//   >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
//   ---------------------------------------------------------------------------
//   Copyright (c) 2015 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED 
//   ------------------------------------------------------------------
//
//   Permission:
//
//      Lattice SG Pte. Ltd. grants permission to use this code
//      pursuant to the terms of the Lattice Reference Design License Agreement. 
//
//
//   Disclaimer:
//
//      This VHDL or Verilog source code is intended as a design reference
//      which illustrates how these types of functions can be implemented.
//      It is the user's responsibility to verify their design for
//      consistency and functionality through the use of formal
//      verification methods.  Lattice provides no warranty
//      regarding the use or functionality of this code.
//
//   ---------------------------------------------------------------------------
//
//                  Lattice SG Pte. Ltd.
//                  101 Thomson Road, United Square #07-02 
//                  Singapore 307591
//
//
//                  TEL: 1-800-Lattice (USA and Canada)
//                       +65-6631-2000 (Singapore)
//                       +1-503-268-8001 (other locations)
//
//                  web: http://www.latticesemi.com/
//                  email: techsupport@latticesemi.com
//
//   ---------------------------------------------------------------------------
//
// =============================================================================
//                         FILE DETAILS         
// Project               : SLL - Soft Loss Of Lock(LOL) Logic
// File                  : sll_core.v
// Title                 : Top-level file for SLL 
// Dependencies          : 1.
//                       : 2.
// Description           : 
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0
// Author(s)             : AV
// Mod. Date             : March 2, 2015
// Changes Made          : Initial Creation
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.1
// Author(s)             : AV
// Mod. Date             : June 8, 2015
// Changes Made          : Following updates were made 
//                         1. Changed all the PLOL status logic and FSM to run
//                            on sli_refclk. 
//                         2. Added the HB logic for presence of tx_pclk 
//                         3. Changed the lparam assignment scheme for 
//                            simulation purposes. 
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.2
// Author(s)             : AV
// Mod. Date             : June 24, 2015
// Changes Made          : Updated the gearing logic for SDI dynamic rate change
// =============================================================================


`timescale 1ns/10ps

module serdes_sync_0sll_core ( 
  //Reset and Clock inputs
  sli_rst,         //Active high asynchronous reset input
  sli_refclk,      //Refclk input to the Tx PLL
  sli_pclk,        //Tx pclk output from the PCS
  
  //Control inputs
  sli_div2_rate,   //Divide by 2 control; 0 - Full rate; 1 - Half rate
  sli_div11_rate,  //Divide by 11 control; 0 - Full rate; 1 - Div by 11
  sli_gear_mode,   //Gear mode control for PCS; 0 - 8/10; 1- 16/20
  
  //LOL Output
  slo_plol         //Tx PLL Loss of Lock output to the user logic
  );
  
// Inputs
input sli_rst;
input sli_refclk;
input sli_pclk;
input sli_div2_rate;
input sli_div11_rate;
input sli_gear_mode;

// Outputs
output slo_plol;


// Parameters
parameter PPROTOCOL              = "PCIE";     //Protocol selected by the User
parameter PLOL_SETTING           = 0;          //PLL LOL setting. Possible values are 0,1,2,3
parameter PDYN_RATE_CTRL         = "DISABLED"; //PCS Dynamic Rate control
parameter PDIFF_VAL_LOCK         = 20;         //Differential count value for Lock
parameter PDIFF_VAL_UNLOCK       = 39;         //Differential count value for Unlock
parameter PPCLK_TC               = 65535;      //Terminal count value for counter running on sli_pclk
parameter PDIFF_DIV11_VAL_LOCK   = 3;          //Differential count value for Lock for SDI Div11
parameter PDIFF_DIV11_VAL_UNLOCK = 3;          //Differential count value for Unlock for SDI Div11
parameter PPCLK_DIV11_TC         = 2383;       //Terminal count value (SDI Div11) for counter running on sli_pclk


// Local Parameters
localparam [1:0]  LPLL_LOSS_ST         = 2'b00;       //PLL Loss state
localparam [1:0]  LPLL_PRELOSS_ST      = 2'b01;       //PLL Pre-Loss state
localparam [1:0]  LPLL_PRELOCK_ST      = 2'b10;       //PLL Pre-Lock state
localparam [1:0]  LPLL_LOCK_ST         = 2'b11;       //PLL Lock state
localparam [15:0] LRCLK_TC             = 16'd65535;   //Terminal count value for counter running on sli_refclk
localparam [15:0] LRCLK_TC_PUL_WIDTH   = 16'd50;      //Pulse width for the Refclk terminal count pulse

// Input and Output reg and wire declarations
wire sli_rst;
wire sli_refclk;
wire sli_pclk;
wire sli_div2_rate;
wire sli_div11_rate;
wire sli_gear_mode;
wire slo_plol;

//-------------- Internal signals reg and wire declarations --------------------

//Signals running on sli_refclk
reg  [15:0] rcount;           //16-bit Counter
reg         rtc_pul;          //Terminal count pulse
reg         rtc_pul_p1;       //Terminal count pulse pipeline
reg         rtc_ctrl;         //Terminal count pulse control


reg  [7:0]  rhb_wait_cnt;     //Heartbeat wait counter

//Heatbeat synchronization and pipeline registers
reg         rhb_sync;         
reg         rhb_sync_p2;
reg         rhb_sync_p1;

//Pipeling registers for dynamic control mode
reg         rgear_p1;
reg         rdiv2_p1;
reg         rdiv11_p1;

reg         rstat_pclk;        //Pclk presence/absence status

reg  [21:0] rcount_tc;         //Tx_pclk terminal count register
reg  [15:0] rdiff_comp_lock;   //Differential comparison value for Lock
reg  [15:0] rdiff_comp_unlock; //Differential compariosn value for Unlock

reg  [1:0]  sll_state;         //Current-state register for LOL FSM

reg         pll_lock;          //PLL Lock signal

//Signals running on sli_pclk
//Synchronization and pipeline registers
reg         ppul_sync;
reg         ppul_sync_p1;
reg         ppul_sync_p2;
reg         ppul_sync_p3;

reg  [21:0] pcount;            //22-bit counter
reg  [21:0] pcount_diff;       //Differential value between Tx_pclk counter and theoritical value

//Heartbeat counter and heartbeat signal running on pclk
reg  [2:0]  phb_cnt;
reg         phb;

//Assignment scheme changed mainly for simulation purpose
wire [15:0] LRCLK_TC_w;
assign LRCLK_TC_w = LRCLK_TC;


// =============================================================================
// Refclk Counter, pulse generation logic and Heartbeat monitor logic
// =============================================================================
always @(posedge sli_refclk or posedge sli_rst) begin
  if (sli_rst == 1'b1) begin
    rcount     <= 16'd0;
    rtc_pul    <= 1'b0;
    rtc_ctrl   <= 1'b0;
    rtc_pul_p1 <= 1'b0;
  end
  else begin
    //Counter logic
    if (rcount != LRCLK_TC_w) begin
      rcount <= rcount + 1;
    end
    else begin
      rcount <= 16'd0;   
    end
    
    //Pulse control logic
    if (rcount == LRCLK_TC_w - 1) begin
      rtc_ctrl <= 1'b1;
    end
    
    //Pulse Generation logic
    if (rtc_ctrl == 1'b1) begin
      if ((rcount == LRCLK_TC_w) || (rcount < LRCLK_TC_PUL_WIDTH)) begin
        rtc_pul <= 1'b1;
	  end	
      else begin
        rtc_pul <= 1'b0;  
      end
    end
    
    rtc_pul_p1 <= rtc_pul;  
  end  
end


// =============================================================================
// Heartbeat synchronization and monitor logic
// =============================================================================
always @(posedge sli_refclk or posedge sli_rst) begin
  if (sli_rst == 1'b1) begin
    rhb_sync     <= 1'b0;
    rhb_sync_p1  <= 1'b0;
    rhb_sync_p2  <= 1'b0;
    rhb_wait_cnt <= 8'd0;
    rstat_pclk   <= 1'b0;
    rgear_p1     <= 1'b0;
    rdiv2_p1     <= 1'b0;
    rdiv11_p1    <= 1'b0;
  end
  else begin
    //Synchronization logic
    rhb_sync    <= phb;
    rhb_sync_p1 <= rhb_sync;
    rhb_sync_p2 <= rhb_sync_p1;
    
    //Pipeline stages of the Dynamic rate control signals
    rgear_p1  <= sli_gear_mode;
    rdiv2_p1  <= sli_div2_rate;
    rdiv11_p1 <= sli_div11_rate; 
    
    //Heartbeat wait counter and monitor logic
    if (rtc_ctrl == 1'b1) begin
      if (rhb_sync_p1 == 1'b1 && rhb_sync_p2 == 1'b0) begin
        rhb_wait_cnt <= 8'd0;
        rstat_pclk   <= 1'b1;
      end
      else if (rhb_wait_cnt == 8'd255) begin
        rhb_wait_cnt <= 8'd0;
        rstat_pclk   <= 1'b0;
      end
      else begin
        rhb_wait_cnt <= rhb_wait_cnt + 1;
      end
    end
  end  
end


// =============================================================================
// Synchronizing terminal count pulse to sli_pclk domain
// =============================================================================
always @(posedge sli_pclk or posedge sli_rst) begin
  if (sli_rst == 1'b1) begin
    ppul_sync    <= 1'b0;   
    ppul_sync_p1 <= 1'b0;
    ppul_sync_p2 <= 1'b0;
    ppul_sync_p3 <= 1'b0;
  end
  else begin
    ppul_sync    <= rtc_pul;   
    ppul_sync_p1 <= ppul_sync;
    ppul_sync_p2 <= ppul_sync_p1;
    ppul_sync_p3 <= ppul_sync_p2;
  end  
end
   

// =============================================================================
// Terminal count logic
// =============================================================================

//For SDI protocol with Dynamic rate control enabled
generate
if ((PDYN_RATE_CTRL == "ENABLED") && (PPROTOCOL == "SDI")) begin
always @(posedge sli_refclk or posedge sli_rst) begin
  if (sli_rst == 1'b1) begin
    rcount_tc         <= 22'd0;
    rdiff_comp_lock   <= 16'd0;
    rdiff_comp_unlock <= 16'd0;
  end
  else begin
    //Terminal count logic
    //Div by 11 is enabled
    if (sli_div11_rate == 1'b1) begin
      //Gear mode is 16/20
      if (sli_gear_mode == 1'b1) begin
        rcount_tc         <= PPCLK_DIV11_TC;
        rdiff_comp_lock   <= PDIFF_DIV11_VAL_LOCK;
        rdiff_comp_unlock <= PDIFF_DIV11_VAL_UNLOCK;
      end
      else begin
        rcount_tc         <= {PPCLK_DIV11_TC[20:0], 1'b0};
        rdiff_comp_lock   <= {PDIFF_DIV11_VAL_LOCK[14:0], 1'b0};
        rdiff_comp_unlock <= {PDIFF_DIV11_VAL_UNLOCK[14:0], 1'b0};
      end
    end
    //Div by 2 is enabled
    else if (sli_div2_rate == 1'b1) begin
      //Gear mode is 16/20
      if (sli_gear_mode == 1'b1) begin
        rcount_tc         <= {1'b0,PPCLK_TC[21:1]};
        rdiff_comp_lock   <= {1'b0,PDIFF_VAL_LOCK[15:1]};
        rdiff_comp_unlock <= {1'b0,PDIFF_VAL_UNLOCK[15:1]};
      end
      else begin
        rcount_tc         <= PPCLK_TC;
        rdiff_comp_lock   <= PDIFF_VAL_LOCK;
        rdiff_comp_unlock <= PDIFF_VAL_UNLOCK;
      end
    end
    //Both div by 11 and div by 2 are disabled
    else begin
      //Gear mode is 16/20
      if (sli_gear_mode == 1'b1) begin
        rcount_tc         <= PPCLK_TC;
        rdiff_comp_lock   <= PDIFF_VAL_LOCK;
        rdiff_comp_unlock <= PDIFF_VAL_UNLOCK;
      end
      else begin
        rcount_tc         <= {PPCLK_TC[20:0],1'b0};
        rdiff_comp_lock   <= {PDIFF_VAL_LOCK[14:0],1'b0};
        rdiff_comp_unlock <= {PDIFF_VAL_UNLOCK[14:0],1'b0};
      end
    end
  end  
end
end
endgenerate

//For CPRI or G8B10B protocols with Dynamic rate control enabled
generate
if ((PDYN_RATE_CTRL == "ENABLED") && (PPROTOCOL == "CPRI" || PPROTOCOL == "G8B10B")) begin
always @(posedge sli_refclk or posedge sli_rst) begin
  if (sli_rst == 1'b1) begin
    rcount_tc         <= 22'd0;
    rdiff_comp_lock   <= 16'd0;
    rdiff_comp_unlock <= 16'd0;
  end
  else begin
    //Terminal count logic
    //Div by 2 is enabled
    if (sli_div2_rate == 1'b1) begin
      rcount_tc         <= {1'b0,PPCLK_TC[21:1]};
      rdiff_comp_lock   <= {1'b0,PDIFF_VAL_LOCK[15:1]};
      rdiff_comp_unlock <= {1'b0,PDIFF_VAL_UNLOCK[15:1]};
    end
    else begin
      rcount_tc         <= PPCLK_TC;
      rdiff_comp_lock   <= PDIFF_VAL_LOCK;
      rdiff_comp_unlock <= PDIFF_VAL_UNLOCK;
    end
  end  
end
end
endgenerate


//For all protocols where Dynamic rate control is disabled
generate
if (PDYN_RATE_CTRL == "DISABLED") begin
always @(posedge sli_refclk or posedge sli_rst) begin
  if (sli_rst == 1'b1) begin
    rcount_tc         <= 22'd0;
    rdiff_comp_lock   <= 16'd0;
    rdiff_comp_unlock <= 16'd0;
  end
  else begin
    //Terminal count logic
    rcount_tc         <= PPCLK_TC;
    rdiff_comp_lock   <= PDIFF_VAL_LOCK;
    rdiff_comp_unlock <= PDIFF_VAL_UNLOCK;
  end  
end
end
endgenerate


// =============================================================================
// Tx_pclk counter, Heartbeat and Differential value logic
// =============================================================================
always @(posedge sli_pclk or posedge sli_rst) begin
  if (sli_rst == 1'b1) begin
    pcount      <= 22'd0;
    pcount_diff <= 22'd65535;
    phb_cnt     <= 3'd0;
    phb         <= 1'b0;
  end
  else begin
    //Counter logic
    if (ppul_sync_p1 == 1'b1 && ppul_sync_p2 == 1'b0) begin
      pcount <= 22'd0;
    end
    else begin
      pcount <= pcount + 1;
    end
    
    //Heartbeat logic
    phb_cnt <= phb_cnt + 1;
    
    if ((phb_cnt < 3'd4) && (phb_cnt >= 3'd0)) begin
      phb <= 1'b1;
    end  
    else begin
      phb <= 1'b0;  
    end 
    
    //Differential value logic
    if (ppul_sync_p1 == 1'b1 && ppul_sync_p2 == 1'b0) begin
      pcount_diff <= rcount_tc + ~(pcount) + 1;
    end  
    else if (ppul_sync_p2 == 1'b1 && ppul_sync_p3 == 1'b0) begin
      if (pcount_diff[21] == 1'b1) begin
        pcount_diff <= ~(pcount_diff) + 1;
      end
    end
  end  
end


// =============================================================================
// State transition logic for SLL FSM
// =============================================================================
always @(posedge sli_refclk or posedge sli_rst) begin
  if (sli_rst == 1'b1) begin
    sll_state <= LPLL_LOSS_ST; 
  end
  else begin
    if ((rstat_pclk == 1'b0) || (rgear_p1^sli_gear_mode == 1'b1) || (rdiv2_p1^sli_div2_rate == 1'b1) || (rdiv11_p1^sli_div11_rate == 1'b1)) begin
      sll_state <= LPLL_LOSS_ST;
    end
    else begin  
      case(sll_state)
        LPLL_LOSS_ST : begin
          if (rtc_pul_p1 == 1'b1 && rtc_pul == 1'b0) begin
            if (pcount_diff[15:0] > rdiff_comp_unlock) begin
              sll_state <= LPLL_LOSS_ST;
            end
            else if (pcount_diff[15:0] <= rdiff_comp_lock) begin
              if (PLOL_SETTING == 2'd0) begin
                sll_state <= LPLL_PRELOCK_ST;
              end
              else begin
                sll_state <= LPLL_LOCK_ST;
              end
            end
          end
        end
        
        
        LPLL_LOCK_ST : begin
          if (rtc_pul_p1 == 1'b1 && rtc_pul == 1'b0) begin
            if (pcount_diff[15:0] <= rdiff_comp_lock) begin
              sll_state <= LPLL_LOCK_ST;
  		      end	
            else begin
              if (PLOL_SETTING == 2'd0) begin
                sll_state <= LPLL_LOSS_ST;
              end
              else begin
                sll_state <= LPLL_PRELOSS_ST;
              end
            end
          end
        end
        
        
        LPLL_PRELOCK_ST : begin
          if (rtc_pul_p1 == 1'b1 && rtc_pul == 1'b0) begin
            if (pcount_diff[15:0] <= rdiff_comp_lock) begin
              sll_state <= LPLL_LOCK_ST;
            end
            else begin
              sll_state <= LPLL_PRELOSS_ST;
            end
          end
        end
        
        
        LPLL_PRELOSS_ST : begin
          if (rtc_pul_p1 == 1'b1 && rtc_pul == 1'b0) begin
            if (pcount_diff[15:0] > rdiff_comp_unlock) begin
              sll_state <= LPLL_PRELOSS_ST;
            end
            else if (pcount_diff[15:0] <= rdiff_comp_lock) begin
              sll_state <= LPLL_LOCK_ST;
            end
          end
        end
        
        default: begin
          sll_state <= LPLL_LOSS_ST;
        end
      endcase
    end  
  end  
end


// =============================================================================
// Logic for Tx PLL Lock
// =============================================================================
always @(posedge sli_refclk or posedge sli_rst) begin
  if (sli_rst == 1'b1) begin
    pll_lock <= 1'b0; 
  end
  else begin
    case(sll_state)
      LPLL_LOSS_ST : begin
        pll_lock <= 1'b0;
      end
      
      LPLL_LOCK_ST : begin
        pll_lock <= 1'b1;
      end
      
      LPLL_PRELOSS_ST : begin
        pll_lock <= 1'b0;
      end
      
      default: begin
        pll_lock <= 1'b0;
      end
    endcase
  end  
end

assign slo_plol = ~(pll_lock);

endmodule    

