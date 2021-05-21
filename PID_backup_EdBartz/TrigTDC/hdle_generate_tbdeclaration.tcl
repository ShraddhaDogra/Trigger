lappend auto_path "D:/Cad/IScc/diamond/3.2_x64/data/script"
package require tbdeclaration_generation

set ::bali::Para(MODNAME) Top
set ::bali::Para(PACKAGE) {"D:/Cad/IScc/diamond/3.2_x64/cae_library/vhdl_packages/vdbs"}
set ::bali::Para(PRIMITIVEFILE) {"D:/Cad/IScc/diamond/3.2_x64/cae_library/synthesis/verilog/ecp3.v"}
set ::bali::Para(TFT) {"D:/Cad/IScc/diamond/3.2_x64/data/templates/tfi_f.tft"}
set ::bali::Para(FILELIST) {"C:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1/source/Delay_buf.v=work" "C:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1/source/Mand3.v=work" "C:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1/source/Mand4.v=work" "C:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1/source/Mand5.v=work" "C:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1/source/Stretcher.v=work" "C:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1/source/Top.v=work" }
set ::bali::Para(INCLUDEPATH) {"C:/Users/bartz/Documents/Lattice/TrigTest/TrigTest1/source" }
puts "set parameters done"
::bali::GenerateTbDeclaration
