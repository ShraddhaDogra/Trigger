setenv SIM_WORKING_FOLDER .
set newDesign 0
if {![file exists "C:/Users/bartz/Documents/Lattice/TrigTest/trigtest1/trigtest1.adf"]} { 
	design create trigtest1 "C:/Users/bartz/Documents/Lattice/TrigTest"
  set newDesign 1
}
design open "C:/Users/bartz/Documents/Lattice/TrigTest/trigtest1"
cd "C:/Users/bartz/Documents/Lattice/TrigTest"
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
addfile "C:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1/TrigTest1_TrigTest1_vo.vo"
addfile "C:/Users/bartz/Documents/Lattice/TrigTest/D:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1_tf.v"
addfile -sdf "C:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1/TrigTest1_TrigTest1_vo.sdf"
	vlib "C:/Users/bartz/Documents/Lattice/TrigTest/trigtest1/work"
set worklib work
adel -all
vlog -dbg "C:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1/TrigTest1_TrigTest1_vo.vo"
vlog -dbg "C:/Users/bartz/Documents/Lattice/TrigTest/D:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1_tf.v"
module Top_tf
designsdffile "C:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1/TrigTest1_TrigTest1_vo.sdf" /Top_tf/UUT -sdfmax -load yes
designsimaddoptions +transport_path_delays +transport_int_delays
vsim +access +r Top_tf -sdfmax /Top_tf/UUT="C:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1/TrigTest1_TrigTest1_vo.sdf"  -PL pmi_work -L ovi_ecp3 -L pcsd_work  +transport_path_delays +transport_int_delays
add wave *
run 1000ns
