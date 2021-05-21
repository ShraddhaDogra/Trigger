lappend auto_path "D:/Cad/IScc/diamond/3.2_x64/data/script"
package require simulation_generation
set ::bali::simulation::Para(PROJECT) {trigtest1}
set ::bali::simulation::Para(PROJECTPATH) {C:/Users/bartz/Documents/Lattice/TrigTest}
set ::bali::simulation::Para(FILELIST) {"C:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1/TrigTest1_TrigTest1_vo.vo" "C:/Users/bartz/Documents/Lattice/TrigTest/D:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1_tf.v" }
set ::bali::simulation::Para(GLBINCLIST) {}
set ::bali::simulation::Para(INCLIST) {"none" "none" "none"}
set ::bali::simulation::Para(WORKLIBLIST) {"" "" "" }
set ::bali::simulation::Para(COMPLIST) {"VERILOG" "none" "none" }
set ::bali::simulation::Para(SIMLIBLIST) {pmi_work ovi_ecp3 pcsd_work}
set ::bali::simulation::Para(MACROLIST) {}
set ::bali::simulation::Para(SIMULATIONTOPMODULE) {Top_tf}
set ::bali::simulation::Para(SIMULATIONINSTANCE) {/UUT}
set ::bali::simulation::Para(LANGUAGE) {VERILOG}
set ::bali::simulation::Para(SDFPATH)  {C:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1/TrigTest1_TrigTest1_vo.sdf}
set ::bali::simulation::Para(ADDTOPLEVELSIGNALSTOWAVEFORM)  {1}
set ::bali::simulation::Para(RUNSIMULATION)  {1}
set ::bali::simulation::Para(POJO2LIBREFRESH)    {}
set ::bali::simulation::Para(POJO2MODELSIMLIB)   {}
::bali::simulation::ActiveHDL_Run
