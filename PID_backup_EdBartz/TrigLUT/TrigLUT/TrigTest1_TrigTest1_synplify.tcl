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
set_option -frequency 200
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -disable_io_insertion false
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0
set_option -dup true

set_option -default_enum_encoding default

#simulation options


#timing analysis options
set_option -num_critical_paths 10
set_option -num_startend_points 0

#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 1
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


#-- add_file options
set_option -include_path {D:/bartz/Documents/Lattice/TrigTest}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTest/TrigTest1/source/Delay_buf.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTest/TrigTest1/source/Mand3.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTest/TrigTest1/source/Mand4.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTest/TrigTest1/source/Mand5.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTest/TrigTest1/source/Stretcher.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTest/TrigTest1/source/Top.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTest/TrigTest1_tf.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTest/Source/Mand6.v}

#-- top module name
set_option -top_module Top

#-- set result format/file last
project -result_file {D:/bartz/Documents/Lattice/TrigTest/TrigTest1/TrigTest1_TrigTest1.edi}

#-- error message log file
project -log_file {TrigTest1_TrigTest1.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run
