#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology MACHXO2
set_option -part LCMXO2_4000HC
set_option -package FTG256C
set_option -speed_grade -6

#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog 2001 standard option
set_option -vlog_std v2001

#map options
set_option -frequency auto
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -disable_io_insertion false
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0
set_option -dup false

set_option -default_enum_encoding default

#simulation options


#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 1
set_option -update_models_cp 1
set_option -resolve_multiple_driver 0
set_option -vhdl2008 1

#-- add_file options
set_option -include_path {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trb3/padiwa/project}
add_file -vhdl -lib "work" {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trb3/padiwa/padiwalcd.vhd}
add_file -vhdl -lib "work" {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trb3/wasa/source/ffarray.vhd}
add_file -vhdl -lib "work" {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trb3/wasa/source/pwm.vhd}
add_file -vhdl -lib "work" {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trb3/wasa/source/spi_slave.vhd}
add_file -verilog {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trb3/wasa/cores/efb_define_def.v}
add_file -vhdl -lib "work" {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trb3/wasa/cores/fifo_1kx8.vhd}
add_file -vhdl -lib "work" {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trb3/wasa/cores/flash.vhd}
add_file -vhdl -lib "work" {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trb3/wasa/cores/flashram.vhd}
add_file -vhdl -lib "work" {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trb3/wasa/cores/pll_shifted_clocks.vhd}
add_file -vhdl -lib "work" {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trb3/wasa/cores/pll.vhd}
add_file -verilog {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trb3/wasa/cores/UFM_WB.v}
add_file -vhdl -lib "work" {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trbnet/trb_net_std.vhd}
add_file -vhdl -lib "work" {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trbnet/trb_net_components.vhd}
add_file -vhdl -lib "work" {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trbnet/trb_net_onewire.vhd}
add_file -vhdl -lib "work" {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trb3/wasa/source/lcd.vhd}
add_file -vhdl -lib "work" {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/padiwa_GSI/pulser/lcd_config.vhd}
add_file -verilog {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trb3/padiwa/signal_gen_x16.v}

#-- top module name
set_option -top_module panda_dirc_wasa

#-- set result format/file last
project -result_file {C:/Users/lavry/Google Drive/FPGA_programming/padiwa/trb3/padiwa/project/padiwalcd/padiwalcd_padiwalcd.edi}

#-- error message log file
project -log_file {padiwalcd_padiwalcd.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run hdl_info_gen -fileorder
project -run
