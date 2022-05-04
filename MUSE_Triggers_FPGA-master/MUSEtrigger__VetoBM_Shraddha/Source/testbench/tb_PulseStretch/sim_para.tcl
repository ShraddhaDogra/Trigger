lappend auto_path "C:/lscc/diamond/diamond/3.10_x64/data/script"
package require simulation_generation
set ::bali::simulation::Para(PROJECT) {tb_PulseStretch}
set ::bali::simulation::Para(PROJECTPATH) {C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/testbench}
set ::bali::simulation::Para(FILELIST) {"C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/version.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_std.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/config.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_components.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trb3/base/trb3_components.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/lattice_ecp2m_fifo.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/basic_type_declaration.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_CRC8.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/pulse_sync.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/state_sync.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/ram_16x8_dp.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/ram_dp.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/ram_dp_rw.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/lattice_ecp3_fifo_16x16_dualport.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/lattice_ecp3_fifo_18x16_dualport.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x256_oreg.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/media_interfaces/ecp3_sfp/sfp_1_125_int.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/optical_link/f_divider.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/signal_stretch.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/BM_Trig_Logic.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/Veto_Logic.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/BM_control.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/Veto_BM.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_18x1k_oreg.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trb3/base/code/input_statistics.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trb3/base/code/input_to_trigger_logic_record.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_9x2k_oreg.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/uart_trans.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/uart_rec.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trb3sc/code/debuguart.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/uart.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/spi_ltc2600.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trb3sc/code/lcd.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trb3/base/code/sedcheck.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/ram.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trb3sc/code/spi_master_generic.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trb3sc/code/load_settings.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/fpga_reboot.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/spi_dpram_32_to_8.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/spi_databus_memory.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/spi_slim.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/spi_master.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_regio_bus_handler.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/spi_flash_and_fpga_reload_record.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_regio_bus_handler_record.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trb3/base/code/trb3_tools.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/handler_ipu.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_18x2k_oreg.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_18x512_oreg.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_18x256_oreg.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x32k_oreg.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x16k_oreg.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x8k_oreg.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x4k_oreg.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x2k_oreg.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x1k_oreg.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x512_oreg.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp2m/fifo/fifo_var_oreg.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/handler_data.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/handler_trigger_and_data.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/bus_register_handler.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/signal_sync.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/pulse_stretch.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/handler_lvl1.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_sbuf6.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_19x16_obuf.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_sbuf5.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_sbuf.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_sbuf.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_priority_encoder.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_priority_arbiter.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_io_multiplexer.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_term_buf.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_onewire.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/rom_16x8.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/ram_16x16_dp.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_addresses.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_pattern_gen.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_regIO.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_ipudata.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_trigger.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_dummy_fifo.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_dummy_fifo.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/lattice_ecp3_fifo_18x1k.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/trb_net16_fifo_arch.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_term.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_api_base.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_obuf_nodata.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_CRC.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_obuf.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_term_ibuf.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_ibuf.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_iobuf.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_endpoint_hades_full.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_endpoint_hades_full_handler_record.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/lattice_ecp3_fifo_16bit_dualport.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/trb_net_fifo_16bit_bram_dualport.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/media_interfaces/ecp3_sfp/sfp_1_200_int.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/media_interfaces/trb_net16_lsm_sfp.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/media_interfaces/trb_net16_med_ecp3_sfp.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/workdir/pll_in200_out100.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/trb_net_reset_handler.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/trb3_periph_blank.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/OrAll.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/BackOr5.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/Or8.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/Or18.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/And6.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/PlaneOr.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/signal_stretch_48.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/BackOr3.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/Or_plane_each.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/signal_Delay.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/testbench/tb_VetoLogic.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/testbench/tb_BMLogic.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/testbench/tb_VetoBM.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/DelayBit.v" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/LeadDelay.v" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/retrigger.v" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/Input_Reg.v" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/PulseStrectch.v" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/testbench/tb_PulseStretch.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/Source/signal_stretch_many.vhd" "C:/Users/ishra/MUSE_Triggers_FPGA/MUSEtrigger__VetoBM_Shraddha/project/retrigger.v" }
set ::bali::simulation::Para(GLBINCLIST) {}
set ::bali::simulation::Para(INCLIST) {"none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none"}
set ::bali::simulation::Para(WORKLIBLIST) {"work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" }
set ::bali::simulation::Para(COMPLIST) {"VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VHDL" "VHDL" "VERILOG" }
set ::bali::simulation::Para(SIMLIBLIST) {pmi_work ovi_ecp3 pcsd_work}
set ::bali::simulation::Para(MACROLIST) {}
set ::bali::simulation::Para(SIMULATIONTOPMODULE) {tb_PulseStretch}
set ::bali::simulation::Para(SIMULATIONINSTANCE) {}
set ::bali::simulation::Para(LANGUAGE) {VHDL}
set ::bali::simulation::Para(SDFPATH)  {}
set ::bali::simulation::Para(ADDTOPLEVELSIGNALSTOWAVEFORM)  {1}
set ::bali::simulation::Para(RUNSIMULATION)  {1}
set ::bali::simulation::Para(HDLPARAMETERS) {}
set ::bali::simulation::Para(POJO2LIBREFRESH)    {}
set ::bali::simulation::Para(POJO2MODELSIMLIB)   {}
::bali::simulation::ActiveHDL_Run
