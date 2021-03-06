//   ==================================================================
//   >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
//   ------------------------------------------------------------------
//   Copyright (c) 2006 by Lattice Semiconductor Corporation
//   ------------------------------------------------------------------
//
//   IMPORTANT: THIS FILE IS AUTO-GENERATED BY THE LatticeMico32 System.
//
//   Permission:
//
//      Lattice Semiconductor grants permission to use this code
//      via the Lattice Open IP core license agreement.  Other use
//      of this code, including the selling or duplication of any
//      portion is strictly prohibited.
//
//   Disclaimer:
//
//      Lattice Semiconductor provides no warranty regarding the use or
//      functionality of this code. It is the user's responsibility to
//      verify their design for consistency and functionality through
//      the use of formal verification methods.
//
//   --------------------------------------------------------------------
//
//                  Lattice Semiconductor Corporation
//                  5555 NE Moore Court
//                  Hillsboro, OR 97214
//                  U.S.A
//
//                  TEL: 1-800-Lattice (USA and Canada)
//                         503-286-8001 (other locations)
//
//                  web: http://www.latticesemi.com/
//                  email: techsupport@latticesemi.com
//
//   --------------------------------------------------------------------
//
//      Project:           platformA
//      File:              platformA_inst.v
//      Date:              Fri, 22 Jan 2010 08:43:04 PST
//      Version:           7.2.01.18
//      Targeted Family:   ECP3
//
//   =======================================================================

`include "../components/lm32_top/rtl/verilog/lm32_include_all.v"
`include "../components/asram_top/rtl/verilog/asram_core.v"
`include "../components/asram_top/rtl/verilog/asram_top.v"
`include "../components/wb_ebr_ctrl/rtl/verilog/wb_ebr_ctrl.v"
`include "../components/uart_core/rtl/verilog/uart_core.v"
`include "../components/timer/rtl/verilog/timer.v"
`include "../components/gpio/rtl/verilog/gpio.v"
`include "../components/gpio/rtl/verilog/tpio.v"
platformA platformA_u ( 
.clk_i(clk_i),
.reset_n(reset_n)
, .sramsram_wen(sramsram_wen) // 
, .sramsram_data(sramsram_data) // [32-1:0]
, .sramsram_addr(sramsram_addr) // [23-1:0]
, .sramsram_csn(sramsram_csn) // 
, .sramsram_be(sramsram_be) // [4-1:0]
, .sramsram_oen(sramsram_oen) // 
, .uartSIN(uartSIN) // 
, .uartSOUT(uartSOUT) // 
, .LEDPIO_OUT(LEDPIO_OUT) // [8-1:0]
, .gpio_7SegsPIO_OUT(gpio_7SegsPIO_OUT) // [10-1:0]
);
