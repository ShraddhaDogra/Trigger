
# NC-Sim Command File
# TOOL:	ncsim	05.70-s005
#
#
# You can restore this configuration with:
#
#     ncsim -update -tcl -gui -cdslib /home/tiago/work/hades/trbnet/ssim/cds.lib -logfile ncsim.log -errormax 15 -status worklib.trb_net_old_to_new_testbench:test -input /home/tiago/work/hades/trbnet/ssim/TRB1.tcl
#

set tcl_prompt1 {puts -nonewline "ncsim> "}
set tcl_prompt2 {puts -nonewline "> "}
set vlog_format %h
set vhdl_format %v
set real_precision 6
set display_unit auto
set time_unit module
set assert_report_level note
set assert_stop_level error
set autoscope yes
set assert_1164_warnings yes
set pack_assert_off {}
set severity_pack_assert_off {note warning}
set assert_output_stop_level failed
set tcl_debug_level 0
set relax_path_name 0
set vhdl_vcdmap XX01ZX01X
set intovf_severity_level ERROR
set probe_screen_format 0
set rangecnst_severity_level ERROR 
set textio_severity_level ERROR
alias . run
alias quit exit
database -open -shm -into waves.shm waves -default
probe -create -database waves :uut_lvl1:CLK_EN :uut_lvl1:CLK :uut_lvl1:RESET :uut_lvl1:OLD_T :uut_lvl1:OLD_TS :uut_lvl1:OLD_TD :uut_lvl1:OLD_TB :uut_lvl1:OLD_TE :uut_lvl1:APL_DATA_IN :uut_lvl1:APL_DATA_OUT :uut_lvl1:APL_DATAREADY_IN :uut_lvl1:APL_DTYPE_OUT :uut_lvl1:APL_ERROR_PATTERN_OUT :uut_lvl1:APL_FIFO_FULL_IN :uut_lvl1:APL_READ_OUT :uut_lvl1:APL_RUN_IN :uut_lvl1:APL_SEND_OUT :uut_lvl1:APL_SEQNR_IN :uut_lvl1:APL_SHORT_TRANSFER_OUT :uut_lvl1:APL_TARGET_ADDRESS_OUT :uut_lvl1:APL_TYP_IN :uut_lvl1:APL_WRITE_OUT :uut_lvl1:do_send_cnt :uut_lvl1:DVAL_i :uut_lvl1:next_state :uut_lvl1:present_state :uut_lvl1:TRIGCODE_i :uut_lvl1:TRIGGER_LEVEL :uut_lvl1:TRIGTAG_i :uut_lvl1:TRIGTAG_ii :uut_lvl1:TRIGTAG_MISMATCH_reg
probe -create -database waves :uut_lvl2:CLK :uut_lvl2:RESET :uut_lvl2:OLD_T :uut_lvl2:OLD_TS :uut_lvl2:OLD_TD :uut_lvl2:OLD_TB :uut_lvl2:OLD_TE :uut_lvl2:DVAL_i :uut_lvl2:present_state :uut_lvl2:next_state :uut_lvl2:APL_SEND_OUT :uut_lvl2:APL_READ_OUT :uut_lvl2:APL_RUN_IN :uut_lvl2:APL_DTYPE_OUT :uut_lvl2:APL_DATA_OUT

simvision -input /home/tiago/work/hades/trbnet/testbench/trb_net_old_to_new_testbench.tcl.sv
