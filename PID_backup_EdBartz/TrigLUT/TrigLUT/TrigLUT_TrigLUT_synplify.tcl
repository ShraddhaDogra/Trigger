#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology LATTICE-ECP3
set_option -part LFE3_150EA
set_option -package FN672C
set_option -speed_grade -8

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
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


#-- add_file options
set_option -include_path {D:/bartz/Documents/Lattice/TrigLUT}
add_file -verilog {D:/bartz/Documents/Lattice/TrigLUT/Source/BackOr.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigLUT/Source/BackOr5.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigLUT/Source/DelayBit.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigLUT/Source/Input_Reg.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigLUT/Source/LeadDelay.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigLUT/Source/PulseStretch.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigLUT/Source/retrigger.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigLUT/Source/ScatterTrig.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigLUT/Source/SR_Latch.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigLUT/Source/SR_Reg.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigLUT/Source/T_ff_clr.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigLUT/Source/T_ff_pset.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigLUT/Source/TrigLUT_tf.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigLUT/Source/Or8.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigLUT/Source/Or18.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigLUT/leds.v}

#-- top module name
set_option -top_module ScatterTrig

#-- set result format/file last
project -result_file {D:/bartz/Documents/Lattice/TrigLUT/TrigLUT/TrigLUT_TrigLUT.edi}

#-- error message log file
project -log_file {TrigLUT_TrigLUT.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run
