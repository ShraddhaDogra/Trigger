#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology LATTICE-ECP3
set_option -part LFE3_150EA
set_option -package FN672C
set_option -speed_grade -8

#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog 2001 standard option
set_option -vlog_std v2001

#map options
set_option -frequency auto
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -disable_io_insertion false
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0
set_option -dup false

set_option -default_enum_encoding default

#simulation options


#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 1
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


#-- add_file options
set_option -include_path {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/project}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/version.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/config.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net_std.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net_components.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trb3/base/trb3_components.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_term_buf.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net_CRC.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net_CRC8.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net_onewire.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_addresses.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_term.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net_sbuf.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net_sbuf5.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net_sbuf6.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_sbuf.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_regIO.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_regio_bus_handler.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_regio_bus_handler_record.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net_priority_encoder.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net_dummy_fifo.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_dummy_fifo.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_term_ibuf.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net_priority_arbiter.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net_pattern_gen.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_obuf_nodata.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_obuf.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_iobuf.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_api_base.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_ibuf.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_io_multiplexer.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_trigger.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_ipudata.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_endpoint_hades_full.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/trb_net16_endpoint_hades_full_handler_record.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/basics/rom_16x8.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/basics/ram.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/basics/pulse_sync.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/basics/state_sync.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/basics/ram_16x8_dp.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/basics/ram_16x16_dp.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/basics/ram_dp.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/basics/signal_sync.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/basics/ram_dp_rw.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/basics/pulse_stretch.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/special/handler_lvl1.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/special/handler_data.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/special/handler_ipu.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/special/handler_trigger_and_data.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/special/trb_net_reset_handler.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/special/fpga_reboot.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/special/spi_slim.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/special/spi_master.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/special/spi_databus_memory.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/special/spi_flash_and_fpga_reload_record.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/special/bus_register_handler.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/lattice_ecp2m_fifo.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/lattice_ecp3_fifo_18x1k.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/lattice_ecp3_fifo_16bit_dualport.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/lattice_ecp3_fifo_16x16_dualport.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/lattice_ecp3_fifo_18x16_dualport.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/spi_dpram_32_to_8.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/trb_net16_fifo_arch.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/trb_net_fifo_16bit_bram_dualport.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/fifo/fifo_36x256_oreg.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/fifo/fifo_36x512_oreg.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/fifo/fifo_36x1k_oreg.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/fifo/fifo_36x2k_oreg.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/fifo/fifo_36x4k_oreg.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/fifo/fifo_36x8k_oreg.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/fifo/fifo_36x16k_oreg.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/fifo/fifo_36x32k_oreg.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/fifo/fifo_18x256_oreg.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/fifo/fifo_18x512_oreg.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/fifo/fifo_18x1k_oreg.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/fifo/fifo_18x2k_oreg.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/fifo/fifo_19x16_obuf.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp3/fifo/fifo_9x2k_oreg.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/lattice/ecp2m/fifo/fifo_var_oreg.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/media_interfaces/ecp3_sfp/sfp_1_200_int.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/media_interfaces/ecp3_sfp/sfp_1_125_int.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/media_interfaces/trb_net16_lsm_sfp.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/media_interfaces/trb_net16_med_ecp3_sfp.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trb3/base/code/trb3_tools.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trb3sc/code/lcd.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trb3sc/code/debuguart.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/special/uart.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/special/uart_rec.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/special/uart_trans.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/special/spi_ltc2600.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trbnet/optical_link/f_divider.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trb3sc/code/load_settings.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trb3sc/code/spi_master_generic.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trb3/base/code/input_to_trigger_logic_record.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trb3/base/code/input_statistics.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/trb3/base/code/sedcheck.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/trb3_periph_blank.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/workdir/pll_in200_out100.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/basic_type_declaration.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/OrAll.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/BackOr5.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/Or8.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/Or18.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/PlaneOr.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/signal_stretch_48.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/signal_stretch.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/And6.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/BackOr3.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/Or_plane_each.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/signal_Delay.vhd}
add_file -verilog {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/PulseStrectch.v}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/BM_Trig_Logic.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/BM_control.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/signal_stretch_many.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/testbench/tb_PulseStretch.vhd}
add_file -verilog {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/Input_Reg.v}
add_file -verilog {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/LeadDelay.v}
add_file -verilog {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/DelayBit.v}
add_file -verilog {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/retrigger.v}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/Source/Veto_OrAll.vhd}
add_file -vhdl -lib "work" {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/project/SmallBM.vhd}

#-- top module name
set_option -top_module trb3_periph_blank

#-- set result format/file last
project -result_file {C:/Users/musefpgawin/Trigger/MUSEtrigger__SmallBMbars_Shraddha/project/trb3_periph_blank/blank_trb3_periph_blank.edi}

#-- error message log file
project -log_file {blank_trb3_periph_blank.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run hdl_info_gen -fileorder
project -run
