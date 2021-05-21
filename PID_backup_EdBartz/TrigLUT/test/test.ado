setenv SIM_WORKING_FOLDER .
set newDesign 0
if {![file exists "D:/bartz/Documents/Lattice/TrigLUT/test/test.adf"]} { 
	design create test "D:/bartz/Documents/Lattice/TrigLUT"
  set newDesign 1
}
design open "D:/bartz/Documents/Lattice/TrigLUT/test"
cd "D:/bartz/Documents/Lattice/TrigLUT"
designverincludedir -clear
designverlibrarysim -PL -clear
designverlibrarysim -L -clear
designverlibrarysim -PL pmi_work
designverlibrarysim ovi_ecp3
designverlibrarysim pcsd_work
designverdefinemacro -clear
if {$newDesign == 0} { 
  removefile -Y -D *
}
addfile "D:/bartz/Documents/Lattice/TrigLUT/DelayBit.v"
addfile "D:/bartz/Documents/Lattice/TrigLUT/Source/LeadDelay.v"
addfile "D:/bartz/Documents/Lattice/TrigLUT/Source/retrigger.v"
addfile "D:/bartz/Documents/Lattice/TrigLUT/Input_Reg.v"
addfile "D:/bartz/Documents/Lattice/TrigLUT/TrigLUT/source/Top.v"
addfile "D:/bartz/Documents/Lattice/TrigLUT/Source/TrigLUT_tf.v"
addfile "D:/bartz/Documents/Lattice/TrigLUT/T_ff_clr.v"
addfile "D:/bartz/Documents/Lattice/TrigLUT/T_ff_pset.v"
vlib "D:/bartz/Documents/Lattice/TrigLUT/test/work"
set worklib work
adel -all
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigLUT/DelayBit.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigLUT/Source/LeadDelay.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigLUT/Source/retrigger.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigLUT/Input_Reg.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigLUT/TrigLUT/source/Top.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigLUT/Source/TrigLUT_tf.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigLUT/T_ff_clr.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigLUT/T_ff_pset.v"
module ScatterTrig_tf
vsim  +access +r ScatterTrig_tf   -PL pmi_work -L ovi_ecp3 -L pcsd_work
add wave *
run 1000ns
