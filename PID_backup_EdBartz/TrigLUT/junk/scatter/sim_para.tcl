lappend auto_path "D:/Cad/lscc/diamond/3.6_x64/data/script"
package require simulation_generation
set ::bali::simulation::Para(PROJECT) {scatter}
set ::bali::simulation::Para(PROJECTPATH) {D:/bartz/Documents/Lattice/TrigLUT}
set ::bali::simulation::Para(FILELIST) {"D:/bartz/Documents/Lattice/TrigLUT/Source/LeadDelay.v" "D:/bartz/Documents/Lattice/TrigLUT/Source/SR_Latch.v" "D:/bartz/Documents/Lattice/TrigLUT/Source/retrigger.v" "D:/bartz/Documents/Lattice/TrigLUT/Source/SR_Reg.v" "D:/bartz/Documents/Lattice/TrigLUT/TrigLUT/source/Top.v" "D:/bartz/Documents/Lattice/TrigLUT/Source/TrigLUT_tf.v" }
set ::bali::simulation::Para(GLBINCLIST) {}
set ::bali::simulation::Para(INCLIST) {"none" "none" "none" "none" "none" "none"}
set ::bali::simulation::Para(WORKLIBLIST) {"work" "work" "work" "work" "work" "work" }
set ::bali::simulation::Para(COMPLIST) {"VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" }
set ::bali::simulation::Para(SIMLIBLIST) {pmi_work ovi_ecp3 pcsd_work}
set ::bali::simulation::Para(MACROLIST) {}
set ::bali::simulation::Para(SIMULATIONTOPMODULE) {ScatterTrig_tf}
set ::bali::simulation::Para(SIMULATIONINSTANCE) {}
set ::bali::simulation::Para(LANGUAGE) {VERILOG}
set ::bali::simulation::Para(SDFPATH)  {}
set ::bali::simulation::Para(ADDTOPLEVELSIGNALSTOWAVEFORM)  {1}
set ::bali::simulation::Para(RUNSIMULATION)  {1}
set ::bali::simulation::Para(HDLPARAMETERS) {}
set ::bali::simulation::Para(POJO2LIBREFRESH)    {}
set ::bali::simulation::Para(POJO2MODELSIMLIB)   {}
::bali::simulation::ActiveHDL_Run
