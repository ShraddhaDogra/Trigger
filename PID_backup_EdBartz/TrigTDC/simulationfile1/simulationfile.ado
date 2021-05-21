setenv SIM_WORKING_FOLDER .
set newDesign 0
if {![file exists "D:/bartz/Documents/Lattice/TrigTDC/simulationfile/simulationfile.adf"]} { 
	design create simulationfile "D:/bartz/Documents/Lattice/TrigTDC"
  set newDesign 1
}
design open "D:/bartz/Documents/Lattice/TrigTDC/simulationfile"
cd "D:/bartz/Documents/Lattice/TrigTDC"
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
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/SR_Latch.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/T_ff_clr.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/SR_Reg.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/T_ff_pset.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/leds.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/Or8.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/Or18.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/DelayBit.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/LeadDelay.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/retrigger.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/Input_Reg.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/PulseStretch.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/BackOr5.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/BackOr.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/ScatterTrig.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/TrigTDC_tf.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/mypll1.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/Source/TriggerTDC.v"
addfile "D:/bartz/Documents/Lattice/TrigTDC/test1.v"
vlib "D:/bartz/Documents/Lattice/TrigTDC/simulationfile/work"
set worklib work
adel -all
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/SR_Latch.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/T_ff_clr.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/SR_Reg.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/T_ff_pset.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/leds.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/Or8.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/Or18.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/DelayBit.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/LeadDelay.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/retrigger.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/Input_Reg.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/PulseStretch.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/BackOr5.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/BackOr.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/ScatterTrig.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/TrigTDC_tf.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/mypll1.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/Source/TriggerTDC.v"
vlog -dbg -work work "D:/bartz/Documents/Lattice/TrigTDC/test1.v"
module SR_Latch
vsim  +access +r SR_Latch   -PL pmi_work -L ovi_ecp3 -L pcsd_work
add wave *
run 1000ns
