setenv SIM_WORKING_FOLDER .
set newDesign 0
if {![file exists "D:/bartz/Documents/Lattice/TrigLUT/Scattertest/Scattertest.adf"]} { 
	design create Scattertest "D:/bartz/Documents/Lattice/TrigLUT"
  set newDesign 1
}
design open "D:/bartz/Documents/Lattice/TrigLUT/Scattertest"
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
addfile "D:/bartz/Documents/Lattice/TrigLUT/Source/Delay_buf.v"
addfile "D:/bartz/Documents/Lattice/TrigLUT/Source/Stretcher.v"
addfile "D:/bartz/Documents/Lattice/TrigLUT/Source/LeadDelay.v"
addfile "D:/bartz/Documents/Lattice/TrigLUT/Source/SR_Latch.v"
addfile "D:/bartz/Documents/Lattice/TrigLUT/Source/retrigger.v"
addfile "D:/bartz/Documents/Lattice/TrigLUT/Source/SR_Reg.v"
addfile "D:/bartz/Documents/Lattice/TrigLUT/TrigLUT/source/Top.v"
addfile "D:/bartz/Documents/Lattice/TrigLUT/Source/TrigLUT_tf.v"
vlib "D:/bartz/Documents/Lattice/TrigLUT/Scattertest/work"
set worklib work
adel -all
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigLUT/Source/Delay_buf.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigLUT/Source/Stretcher.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigLUT/Source/LeadDelay.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigLUT/Source/SR_Latch.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigLUT/Source/retrigger.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigLUT/Source/SR_Reg.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigLUT/TrigLUT/source/Top.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigLUT/Source/TrigLUT_tf.v"
module ScatterTrig_tf
vsim  +access +r ScatterTrig_tf   -PL pmi_work -L ovi_ecp3 -L pcsd_work
add wave *
run 1000ns
