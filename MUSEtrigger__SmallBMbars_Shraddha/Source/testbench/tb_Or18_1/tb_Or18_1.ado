setenv SIM_WORKING_FOLDER .
set newDesign 0
if {![file exists "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/testbench/tb_Or18_1/tb_Or18_1.adf"]} { 
	design create tb_Or18_1 "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/testbench"
  set newDesign 1
}
design open "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/testbench/tb_Or18_1"
cd "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/testbench"
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
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/version.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_std.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/config.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_components.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trb3/base/trb3_components.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/lattice_ecp2m_fifo.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/basic_type_declaration.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/BackOr5.v"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/BackOr.v"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/SR_Latch.v"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/T_ff_clr.v"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/SR_Reg.v"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/T_ff_pset.v"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_CRC8.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/pulse_sync.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/state_sync.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/ram_16x8_dp.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/ram_dp.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/ram_dp_rw.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/lattice_ecp3_fifo_16x16_dualport.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/lattice_ecp3_fifo_18x16_dualport.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x256_oreg.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/media_interfaces/ecp3_sfp/sfp_1_125_int.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/optical_link/f_divider.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/leds.v"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/Or8.v"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/project/Or8.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/DelayBit.v"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/LeadDelay.v"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/retrigger.v"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/Input_Reg.v"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/PulseStretch.v"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/Or18.v"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/project/Or18.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/Or6.v"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/ScatterTrig.v"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_18x1k_oreg.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trb3/base/code/input_statistics.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trb3/base/code/input_to_trigger_logic_record.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_9x2k_oreg.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/uart_trans.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/uart_rec.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trb3sc/code/debuguart.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/uart.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/spi_ltc2600.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trb3sc/code/lcd.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trb3/base/code/sedcheck.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/ram.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trb3sc/code/spi_master_generic.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trb3sc/code/load_settings.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/fpga_reboot.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/spi_dpram_32_to_8.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/spi_databus_memory.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/spi_slim.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/spi_master.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_regio_bus_handler.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/spi_flash_and_fpga_reload_record.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_regio_bus_handler_record.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trb3/base/code/trb3_tools.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/handler_ipu.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_18x2k_oreg.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_18x512_oreg.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_18x256_oreg.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x32k_oreg.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x16k_oreg.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x8k_oreg.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x4k_oreg.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x2k_oreg.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x1k_oreg.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x512_oreg.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp2m/fifo/fifo_var_oreg.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/handler_data.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/handler_trigger_and_data.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/bus_register_handler.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/signal_sync.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/pulse_stretch.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/handler_lvl1.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_sbuf6.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_19x16_obuf.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_sbuf5.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_sbuf.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_sbuf.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_priority_encoder.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_priority_arbiter.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_io_multiplexer.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_term_buf.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_onewire.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/rom_16x8.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/ram_16x16_dp.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_addresses.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_pattern_gen.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_regIO.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_ipudata.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_trigger.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_dummy_fifo.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_dummy_fifo.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/lattice_ecp3_fifo_18x1k.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/trb_net16_fifo_arch.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_term.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_api_base.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_obuf_nodata.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_CRC.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_obuf.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_term_ibuf.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_ibuf.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_iobuf.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_endpoint_hades_full.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_endpoint_hades_full_handler_record.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/lattice_ecp3_fifo_16bit_dualport.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/trb_net_fifo_16bit_bram_dualport.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/media_interfaces/ecp3_sfp/sfp_1_200_int.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/media_interfaces/trb_net16_lsm_sfp.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/media_interfaces/trb_net16_med_ecp3_sfp.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/workdir/pll_in200_out100.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/trb_net_reset_handler.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/trb3_periph_blank.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/project/tb_Or8.vhd"
addfile "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/project/tb_Or18.vhd"
vlib "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/testbench/tb_Or18_1/work"
set worklib work
adel -all
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/version.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_std.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/config.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_components.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trb3/base/trb3_components.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/lattice_ecp2m_fifo.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/basic_type_declaration.vhd"
vlog -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/BackOr5.v"
vlog -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/BackOr.v"
vlog -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/SR_Latch.v"
vlog -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/T_ff_clr.v"
vlog -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/SR_Reg.v"
vlog -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/T_ff_pset.v"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_CRC8.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/pulse_sync.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/state_sync.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/ram_16x8_dp.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/ram_dp.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/ram_dp_rw.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/lattice_ecp3_fifo_16x16_dualport.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/lattice_ecp3_fifo_18x16_dualport.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x256_oreg.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/media_interfaces/ecp3_sfp/sfp_1_125_int.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/optical_link/f_divider.vhd"
vlog -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/leds.v"
vlog -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/Or8.v"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/project/Or8.vhd"
vlog -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/DelayBit.v"
vlog -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/LeadDelay.v"
vlog -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/retrigger.v"
vlog -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/Input_Reg.v"
vlog -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/PulseStretch.v"
vlog -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/Or18.v"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/project/Or18.vhd"
vlog -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/Or6.v"
vlog -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/Source/ScatterTrig.v"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_18x1k_oreg.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trb3/base/code/input_statistics.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trb3/base/code/input_to_trigger_logic_record.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_9x2k_oreg.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/uart_trans.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/uart_rec.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trb3sc/code/debuguart.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/uart.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/spi_ltc2600.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trb3sc/code/lcd.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trb3/base/code/sedcheck.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/ram.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trb3sc/code/spi_master_generic.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trb3sc/code/load_settings.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/fpga_reboot.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/spi_dpram_32_to_8.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/spi_databus_memory.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/spi_slim.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/spi_master.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_regio_bus_handler.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/spi_flash_and_fpga_reload_record.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_regio_bus_handler_record.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trb3/base/code/trb3_tools.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/handler_ipu.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_18x2k_oreg.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_18x512_oreg.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_18x256_oreg.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x32k_oreg.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x16k_oreg.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x8k_oreg.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x4k_oreg.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x2k_oreg.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x1k_oreg.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_36x512_oreg.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp2m/fifo/fifo_var_oreg.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/handler_data.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/handler_trigger_and_data.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/bus_register_handler.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/signal_sync.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/pulse_stretch.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/handler_lvl1.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_sbuf6.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/fifo/fifo_19x16_obuf.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_sbuf5.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_sbuf.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_sbuf.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_priority_encoder.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_priority_arbiter.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_io_multiplexer.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_term_buf.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_onewire.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/rom_16x8.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/basics/ram_16x16_dp.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_addresses.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_pattern_gen.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_regIO.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_ipudata.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_trigger.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_dummy_fifo.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_dummy_fifo.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/lattice_ecp3_fifo_18x1k.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/trb_net16_fifo_arch.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_term.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_api_base.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_obuf_nodata.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net_CRC.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_obuf.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_term_ibuf.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_ibuf.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_iobuf.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_endpoint_hades_full.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/trb_net16_endpoint_hades_full_handler_record.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/lattice_ecp3_fifo_16bit_dualport.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/lattice/ecp3/trb_net_fifo_16bit_bram_dualport.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/media_interfaces/ecp3_sfp/sfp_1_200_int.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/media_interfaces/trb_net16_lsm_sfp.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/media_interfaces/trb_net16_med_ecp3_sfp.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/workdir/pll_in200_out100.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trbnet/special/trb_net_reset_handler.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/trb3_periph_blank.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/project/tb_Or8.vhd"
vcom -dbg -work work "C:/Users/ishra/MUSE_Triggers_FPGA/trig_MUSE__Cosmic_Copy/project/tb_Or18.vhd"
entity tb_Or18
vsim  +access +r tb_Or18   -PL pmi_work -L ovi_ecp3 -L pcsd_work
add wave *
run 1000ns
