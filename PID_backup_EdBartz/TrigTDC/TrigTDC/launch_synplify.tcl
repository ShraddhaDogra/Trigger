#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file D:/bartz/Documents/Lattice/TrigTDC/TrigTDC/launch_synplify.tcl
#-- Written on Fri Dec  2 13:53:07 2016

project -close
set filename "D:/bartz/Documents/Lattice/TrigTDC/TrigTDC/TrigTDC_syn.prj"
if ([file exists "$filename"]) {
	project -load "$filename"
	project_file -remove *
} else {
	project -new "$filename"
}
set create_new 0

#device options
set_option -technology LATTICE-ECP3
set_option -part LFE3_150EA
set_option -package FN672C
set_option -speed_grade -8

if {$create_new == 1} {
#-- add synthesis options
	set_option -symbolic_fsm_compiler true
	set_option -resource_sharing true
	set_option -vlog_std v2001
	set_option -frequency auto
	set_option -maxfan 1000
	set_option -auto_constrain_io 0
	set_option -disable_io_insertion false
	set_option -retiming false; set_option -pipe true
	set_option -force_gsr false
	set_option -compiler_compatible 0
	set_option -dup false
	
	set_option -default_enum_encoding default
	
	
	
	set_option -write_apr_constraint 1
	set_option -fix_gated_and_generated_clocks 1
	set_option -update_models_cp 0
	set_option -resolve_multiple_driver 1
	
	
}
#-- add_file options
set_option -include_path "D:/bartz/Documents/Lattice/TrigTDC"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/TrigTDC_tf.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/leds.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/TriggerTDC.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Cpll0.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Cpll1.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Cpll2.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Cpll3.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/FineTimeBit.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Cpll.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/InputBit.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Cpll4.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/Input_Reg.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/sync_cntr.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/hit_cntr.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/Teststate.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/readoutfifo.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/timestatics.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/Ch48.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/Mux16x32.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/Mux3x32.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/Ch48_test.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/wcomp.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/ClockGen.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/TriggerTDCTop.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/comnet.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/Shift40.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/TrigTDC_comcheck_tf.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/Register.v"
add_file -verilog "D:/bartz/Documents/Lattice/TrigTDC/Source/ComTrans.v"
#-- top module name
set_option -top_module {TriggerTDCTop}
project -result_file {D:/bartz/Documents/Lattice/TrigTDC/TrigTDC/TrigTDC.edi}
project -save "$filename"
