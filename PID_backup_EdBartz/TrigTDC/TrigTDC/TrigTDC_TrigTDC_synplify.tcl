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
set_option -resolve_multiple_driver 1


#-- add_file options
set_option -include_path {D:/bartz/Documents/Lattice/TrigTDC}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Ch48.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/ClockGen.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/comnet.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/ComTrans.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/DeBounce_v.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/FineTimeBit.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/hit_cntr.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Input_Reg.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/InputBit.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Lanalyzer.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/leds.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Ltch8.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Ltch32.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Ltch33.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Ltch40.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Ltch42.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Mux3x32.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Mux16x32.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Register.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/SFineTimeBit.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Shift33.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Shift40.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Shift42.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Shiftout32.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/StrSt.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/sync_cntr.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Teststate.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/timestatics.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/TriggerTDC.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/TriggerTDCTop.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/wcomp.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Cpll0.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Cpll1.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Cpll2.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Cpll3.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Cpll.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Cpll4.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/readoutfifo.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/LA_FIFO.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/Lanalyzer0.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/SFineTimeBit0.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/SFineTimeBit1.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/SFineTimeBit2.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/SFineTimeBit3.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/SFineTimeBit4.v}
add_file -verilog {D:/bartz/Documents/Lattice/TrigTDC/Source/SFineTimeBit5.v}

#-- top module name
set_option -top_module TriggerTDCTop

#-- set result format/file last
project -result_file {D:/bartz/Documents/Lattice/TrigTDC/TrigTDC/TrigTDC_TrigTDC.edi}

#-- error message log file
project -log_file {TrigTDC_TrigTDC.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run
