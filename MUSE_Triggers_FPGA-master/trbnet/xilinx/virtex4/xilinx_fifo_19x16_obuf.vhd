--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: xilinx_fifo_19x16_obuf.vhd
-- /___/   /\     Timestamp: Wed Oct 19 15:47:43 2011
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -w -sim -ofmt vhdl /home/marek/trbv2/tmp/_cg/xilinx_fifo_19x16_obuf.ngc /home/marek/trbv2/tmp/_cg/xilinx_fifo_19x16_obuf.vhd 
-- Device	: 4vlx40ff1148-10
-- Input file	: /home/marek/trbv2/tmp/_cg/xilinx_fifo_19x16_obuf.ngc
-- Output file	: /home/marek/trbv2/tmp/_cg/xilinx_fifo_19x16_obuf.vhd
-- # of Entities	: 1
-- Design Name	: xilinx_fifo_19x16_obuf
-- Xilinx	: /opt/xilinx/ISE10.1/ISE
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Development System Reference Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------


-- synthesis translate_off
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity xilinx_fifo_19x16_obuf is
  port (
    prog_full : out STD_LOGIC; 
    rd_en : in STD_LOGIC := 'X'; 
    wr_en : in STD_LOGIC := 'X'; 
    full : out STD_LOGIC; 
    empty : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    rst : in STD_LOGIC := 'X'; 
    prog_full_thresh : in STD_LOGIC_VECTOR ( 3 downto 0 ); 
    dout : out STD_LOGIC_VECTOR ( 18 downto 0 ); 
    din : in STD_LOGIC_VECTOR ( 18 downto 0 ); 
    data_count : out STD_LOGIC_VECTOR ( 3 downto 0 ) 
  );
end xilinx_fifo_19x16_obuf;

architecture STRUCTURE of xilinx_fifo_19x16_obuf is
  signal BU2_N16 : STD_LOGIC; 
  signal BU2_N15 : STD_LOGIC; 
  signal BU2_N141 : STD_LOGIC; 
  signal BU2_N13 : STD_LOGIC; 
  signal BU2_N111 : STD_LOGIC; 
  signal BU2_N9 : STD_LOGIC; 
  signal BU2_N3 : STD_LOGIC; 
  signal BU2_N7 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000092_145 : STD_LOGIC; 
  signal BU2_N51 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_wsts_comp1 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_wsts_c1_dout_i53_142 : STD_LOGIC; 
  signal BU2_N14 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or000079_140 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_wsts_c1_dout_i17_139 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000078_138 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000048_137 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000013_136 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or000062_135 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or000035_134 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux000670_133 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux0006153_132 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux0006138_131 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux000643_130 : STD_LOGIC; 
  signal BU2_N5 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_ram_rd_en_i_128 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_ram_wr_en_i_127 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux0006 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_not0001 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_rd_pntr_wr_inv_pad_0_mand_120 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_rd_pntr_wr_inv_pad_0_mand1 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_wsts_wr_rst_d1_106 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_full_fb_i_105 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_full_comb_104 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_103 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or0000 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_rd_rpntr_Mcount_count6 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_rd_rpntr_Mcount_count3 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_rd_rpntr_Mcount_count9 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count10 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count7 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count4 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count1 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_count_not0001 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_wpntr_Mcount_count9 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_rd_rpntr_Mcount_count : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_wpntr_Mcount_count3 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_wpntr_Mcount_count : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_wpntr_Mcount_count6 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_66 : STD_LOGIC; 
  signal BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_mux0000 : STD_LOGIC; 
  signal BU2_U0_grf_rf_rstblk_wr_rst_comb : STD_LOGIC; 
  signal BU2_U0_grf_rf_rstblk_rd_rst_comb : STD_LOGIC; 
  signal BU2_U0_grf_rf_rstblk_wr_rst_asreg_60 : STD_LOGIC; 
  signal BU2_U0_grf_rf_rstblk_rd_rst_asreg_59 : STD_LOGIC; 
  signal BU2_U0_grf_rf_rstblk_wr_rst_asreg_d2_58 : STD_LOGIC; 
  signal BU2_U0_grf_rf_rstblk_wr_rst_asreg_d1_57 : STD_LOGIC; 
  signal BU2_U0_grf_rf_rstblk_rd_rst_asreg_d2_56 : STD_LOGIC; 
  signal BU2_U0_grf_rf_rstblk_rd_rst_asreg_d1_55 : STD_LOGIC; 
  signal BU2_N1 : STD_LOGIC; 
  signal NLW_VCC_P_UNCONNECTED : STD_LOGIC; 
  signal NLW_GND_G_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_CASCADEOUTA_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_CASCADEOUTB_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_27_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_26_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_25_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_24_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_20_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_19_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_18_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_17_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_16_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_15_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_14_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_13_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_15_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_14_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_13_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOPA_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOPA_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOPA_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOPA_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOPB_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOPB_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOPB_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOPB_0_UNCONNECTED : STD_LOGIC;
 
  signal din_2 : STD_LOGIC_VECTOR ( 18 downto 0 ); 
  signal prog_full_thresh_3 : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal NlwRenamedSig_OI_data_count : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal dout_4 : STD_LOGIC_VECTOR ( 18 downto 0 ); 
  signal BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad : STD_LOGIC_VECTOR ( 4 downto 1 ); 
  signal BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad_add0000 : STD_LOGIC_VECTOR ( 4 downto 1 ); 
  signal BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_lut : STD_LOGIC_VECTOR ( 4 downto 1 ); 
  signal BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_cy : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal BU2_U0_grf_rf_gl0_wr_wpntr_count : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal BU2_U0_grf_rf_gl0_wr_wpntr_count_d2 : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal BU2_U0_grf_rf_gl0_wr_wpntr_count_d1 : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal BU2_U0_grf_rf_gl0_rd_rpntr_count_d1 : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal BU2_U0_grf_rf_gl0_rd_rpntr_count : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal BU2_U0_grf_rf_rstblk_wr_rst_reg : STD_LOGIC_VECTOR ( 1 downto 1 ); 
  signal BU2_U0_grf_rf_rstblk_rd_rst_reg : STD_LOGIC_VECTOR ( 2 downto 2 ); 
  signal BU2_rd_data_count : STD_LOGIC_VECTOR ( 0 downto 0 ); 
begin
  prog_full_thresh_3(3) <= prog_full_thresh(3);
  prog_full_thresh_3(2) <= prog_full_thresh(2);
  prog_full_thresh_3(1) <= prog_full_thresh(1);
  prog_full_thresh_3(0) <= prog_full_thresh(0);
  dout(18) <= dout_4(18);
  dout(17) <= dout_4(17);
  dout(16) <= dout_4(16);
  dout(15) <= dout_4(15);
  dout(14) <= dout_4(14);
  dout(13) <= dout_4(13);
  dout(12) <= dout_4(12);
  dout(11) <= dout_4(11);
  dout(10) <= dout_4(10);
  dout(9) <= dout_4(9);
  dout(8) <= dout_4(8);
  dout(7) <= dout_4(7);
  dout(6) <= dout_4(6);
  dout(5) <= dout_4(5);
  dout(4) <= dout_4(4);
  dout(3) <= dout_4(3);
  dout(2) <= dout_4(2);
  dout(1) <= dout_4(1);
  dout(0) <= dout_4(0);
  din_2(18) <= din(18);
  din_2(17) <= din(17);
  din_2(16) <= din(16);
  din_2(15) <= din(15);
  din_2(14) <= din(14);
  din_2(13) <= din(13);
  din_2(12) <= din(12);
  din_2(11) <= din(11);
  din_2(10) <= din(10);
  din_2(9) <= din(9);
  din_2(8) <= din(8);
  din_2(7) <= din(7);
  din_2(6) <= din(6);
  din_2(5) <= din(5);
  din_2(4) <= din(4);
  din_2(3) <= din(3);
  din_2(2) <= din(2);
  din_2(1) <= din(1);
  din_2(0) <= din(0);
  data_count(3) <= NlwRenamedSig_OI_data_count(3);
  data_count(2) <= NlwRenamedSig_OI_data_count(2);
  data_count(1) <= NlwRenamedSig_OI_data_count(1);
  data_count(0) <= NlwRenamedSig_OI_data_count(0);
  VCC_0 : VCC
    port map (
      P => NLW_VCC_P_UNCONNECTED
    );
  GND_1 : GND
    port map (
      G => NLW_GND_G_UNCONNECTED
    );
  BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or000079 : LUT3_L
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or000035_134,
      I1 => BU2_N111,
      I2 => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or000062_135,
      LO => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or000079_140
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux0006153 : LUT4_L
    generic map(
      INIT => X"0900"
    )
    port map (
      I0 => prog_full_thresh_3(2),
      I1 => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad(3),
      I2 => BU2_N9,
      I3 => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux0006138_131,
      LO => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux0006153_132
    );
  BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or00003168_SW0 : LUT4_L
    generic map(
      INIT => X"6FF6"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(0),
      I1 => BU2_U0_grf_rf_gl0_wr_wpntr_count_d2(0),
      I2 => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(1),
      I3 => BU2_U0_grf_rf_gl0_wr_wpntr_count_d2(1),
      LO => BU2_N3
    );
  BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000092 : LUT4_L
    generic map(
      INIT => X"0080"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000078_138,
      I1 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000048_137,
      I2 => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      I3 => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count,
      LO => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000092_145
    );
  BU2_U0_grf_rf_gl0_wr_gwss_wsts_c1_dout_i53 : LUT4_L
    generic map(
      INIT => X"9009"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(3),
      I1 => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(3),
      I2 => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(2),
      I3 => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(2),
      LO => BU2_U0_grf_rf_gl0_wr_gwss_wsts_c1_dout_i53_142
    );
  BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP : RAMB16
    generic map(
      DOA_REG => 0,
      DOB_REG => 0,
      INIT_A => X"000000000",
      INIT_B => X"000000000",
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      SRVAL_A => X"000000000",
      INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_FILE => "NONE",
      INVERT_CLK_DOA_REG => FALSE,
      INVERT_CLK_DOB_REG => FALSE,
      RAM_EXTENSION_A => "NONE",
      RAM_EXTENSION_B => "NONE",
      READ_WIDTH_A => 36,
      READ_WIDTH_B => 36,
      SIM_COLLISION_CHECK => "NONE",
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      WRITE_MODE_A => "WRITE_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      WRITE_WIDTH_A => 36,
      WRITE_WIDTH_B => 36,
      SRVAL_B => X"000000000"
    )
    port map (
      CASCADEINA => BU2_rd_data_count(0),
      CASCADEINB => BU2_rd_data_count(0),
      CLKA => clk,
      CLKB => clk,
      ENA => BU2_N1,
      REGCEA => BU2_rd_data_count(0),
      REGCEB => BU2_rd_data_count(0),
      ENB => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count,
      SSRA => BU2_rd_data_count(0),
      SSRB => BU2_rd_data_count(0),
      CASCADEOUTA => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_CASCADEOUTA_UNCONNECTED,
      CASCADEOUTB => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_CASCADEOUTB_UNCONNECTED,
      ADDRA(14) => BU2_rd_data_count(0),
      ADDRA(13) => BU2_rd_data_count(0),
      ADDRA(12) => BU2_rd_data_count(0),
      ADDRA(11) => BU2_rd_data_count(0),
      ADDRA(10) => BU2_rd_data_count(0),
      ADDRA(9) => BU2_rd_data_count(0),
      ADDRA(8) => BU2_U0_grf_rf_gl0_wr_wpntr_count_d2(3),
      ADDRA(7) => BU2_U0_grf_rf_gl0_wr_wpntr_count_d2(2),
      ADDRA(6) => BU2_U0_grf_rf_gl0_wr_wpntr_count_d2(1),
      ADDRA(5) => BU2_U0_grf_rf_gl0_wr_wpntr_count_d2(0),
      ADDRA(4) => BU2_rd_data_count(0),
      ADDRA(3) => BU2_rd_data_count(0),
      ADDRA(2) => BU2_rd_data_count(0),
      ADDRA(1) => BU2_rd_data_count(0),
      ADDRA(0) => BU2_rd_data_count(0),
      ADDRB(14) => BU2_rd_data_count(0),
      ADDRB(13) => BU2_rd_data_count(0),
      ADDRB(12) => BU2_rd_data_count(0),
      ADDRB(11) => BU2_rd_data_count(0),
      ADDRB(10) => BU2_rd_data_count(0),
      ADDRB(9) => BU2_rd_data_count(0),
      ADDRB(8) => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(3),
      ADDRB(7) => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(2),
      ADDRB(6) => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(1),
      ADDRB(5) => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(0),
      ADDRB(4) => BU2_rd_data_count(0),
      ADDRB(3) => BU2_rd_data_count(0),
      ADDRB(2) => BU2_rd_data_count(0),
      ADDRB(1) => BU2_rd_data_count(0),
      ADDRB(0) => BU2_rd_data_count(0),
      DIA(31) => BU2_rd_data_count(0),
      DIA(30) => BU2_rd_data_count(0),
      DIA(29) => BU2_rd_data_count(0),
      DIA(28) => BU2_rd_data_count(0),
      DIA(27) => din_2(18),
      DIA(26) => din_2(17),
      DIA(25) => din_2(16),
      DIA(24) => din_2(15),
      DIA(23) => BU2_rd_data_count(0),
      DIA(22) => BU2_rd_data_count(0),
      DIA(21) => BU2_rd_data_count(0),
      DIA(20) => din_2(14),
      DIA(19) => din_2(13),
      DIA(18) => din_2(12),
      DIA(17) => din_2(11),
      DIA(16) => din_2(10),
      DIA(15) => BU2_rd_data_count(0),
      DIA(14) => BU2_rd_data_count(0),
      DIA(13) => BU2_rd_data_count(0),
      DIA(12) => din_2(9),
      DIA(11) => din_2(8),
      DIA(10) => din_2(7),
      DIA(9) => din_2(6),
      DIA(8) => din_2(5),
      DIA(7) => BU2_rd_data_count(0),
      DIA(6) => BU2_rd_data_count(0),
      DIA(5) => BU2_rd_data_count(0),
      DIA(4) => din_2(4),
      DIA(3) => din_2(3),
      DIA(2) => din_2(2),
      DIA(1) => din_2(1),
      DIA(0) => din_2(0),
      DIB(31) => BU2_rd_data_count(0),
      DIB(30) => BU2_rd_data_count(0),
      DIB(29) => BU2_rd_data_count(0),
      DIB(28) => BU2_rd_data_count(0),
      DIB(27) => BU2_rd_data_count(0),
      DIB(26) => BU2_rd_data_count(0),
      DIB(25) => BU2_rd_data_count(0),
      DIB(24) => BU2_rd_data_count(0),
      DIB(23) => BU2_rd_data_count(0),
      DIB(22) => BU2_rd_data_count(0),
      DIB(21) => BU2_rd_data_count(0),
      DIB(20) => BU2_rd_data_count(0),
      DIB(19) => BU2_rd_data_count(0),
      DIB(18) => BU2_rd_data_count(0),
      DIB(17) => BU2_rd_data_count(0),
      DIB(16) => BU2_rd_data_count(0),
      DIB(15) => BU2_rd_data_count(0),
      DIB(14) => BU2_rd_data_count(0),
      DIB(13) => BU2_rd_data_count(0),
      DIB(12) => BU2_rd_data_count(0),
      DIB(11) => BU2_rd_data_count(0),
      DIB(10) => BU2_rd_data_count(0),
      DIB(9) => BU2_rd_data_count(0),
      DIB(8) => BU2_rd_data_count(0),
      DIB(7) => BU2_rd_data_count(0),
      DIB(6) => BU2_rd_data_count(0),
      DIB(5) => BU2_rd_data_count(0),
      DIB(4) => BU2_rd_data_count(0),
      DIB(3) => BU2_rd_data_count(0),
      DIB(2) => BU2_rd_data_count(0),
      DIB(1) => BU2_rd_data_count(0),
      DIB(0) => BU2_rd_data_count(0),
      DIPA(3) => BU2_rd_data_count(0),
      DIPA(2) => BU2_rd_data_count(0),
      DIPA(1) => BU2_rd_data_count(0),
      DIPA(0) => BU2_rd_data_count(0),
      DIPB(3) => BU2_rd_data_count(0),
      DIPB(2) => BU2_rd_data_count(0),
      DIPB(1) => BU2_rd_data_count(0),
      DIPB(0) => BU2_rd_data_count(0),
      WEA(3) => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      WEA(2) => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      WEA(1) => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      WEA(0) => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      WEB(3) => BU2_rd_data_count(0),
      WEB(2) => BU2_rd_data_count(0),
      WEB(1) => BU2_rd_data_count(0),
      WEB(0) => BU2_rd_data_count(0),
      DOA(31) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_31_UNCONNECTED,
      DOA(30) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_30_UNCONNECTED,
      DOA(29) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_29_UNCONNECTED,
      DOA(28) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_28_UNCONNECTED,
      DOA(27) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_27_UNCONNECTED,
      DOA(26) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_26_UNCONNECTED,
      DOA(25) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_25_UNCONNECTED,
      DOA(24) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_24_UNCONNECTED,
      DOA(23) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_23_UNCONNECTED,
      DOA(22) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_22_UNCONNECTED,
      DOA(21) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_21_UNCONNECTED,
      DOA(20) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_20_UNCONNECTED,
      DOA(19) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_19_UNCONNECTED,
      DOA(18) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_18_UNCONNECTED,
      DOA(17) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_17_UNCONNECTED,
      DOA(16) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_16_UNCONNECTED,
      DOA(15) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_15_UNCONNECTED,
      DOA(14) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_14_UNCONNECTED,
      DOA(13) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_13_UNCONNECTED,
      DOA(12) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_12_UNCONNECTED,
      DOA(11) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_11_UNCONNECTED,
      DOA(10) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_10_UNCONNECTED,
      DOA(9) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_9_UNCONNECTED,
      DOA(8) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_8_UNCONNECTED,
      DOA(7) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_7_UNCONNECTED,
      DOA(6) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_6_UNCONNECTED,
      DOA(5) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_5_UNCONNECTED,
      DOA(4) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_4_UNCONNECTED,
      DOA(3) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_3_UNCONNECTED,
      DOA(2) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_2_UNCONNECTED,
      DOA(1) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_1_UNCONNECTED,
      DOA(0) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOA_0_UNCONNECTED,
      DOB(31) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_31_UNCONNECTED,
      DOB(30) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_30_UNCONNECTED,
      DOB(29) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_29_UNCONNECTED,
      DOB(28) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_28_UNCONNECTED,
      DOB(27) => dout_4(18),
      DOB(26) => dout_4(17),
      DOB(25) => dout_4(16),
      DOB(24) => dout_4(15),
      DOB(23) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_23_UNCONNECTED,
      DOB(22) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_22_UNCONNECTED,
      DOB(21) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_21_UNCONNECTED,
      DOB(20) => dout_4(14),
      DOB(19) => dout_4(13),
      DOB(18) => dout_4(12),
      DOB(17) => dout_4(11),
      DOB(16) => dout_4(10),
      DOB(15) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_15_UNCONNECTED,
      DOB(14) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_14_UNCONNECTED,
      DOB(13) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_13_UNCONNECTED,
      DOB(12) => dout_4(9),
      DOB(11) => dout_4(8),
      DOB(10) => dout_4(7),
      DOB(9) => dout_4(6),
      DOB(8) => dout_4(5),
      DOB(7) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_7_UNCONNECTED,
      DOB(6) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_6_UNCONNECTED,
      DOB(5) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOB_5_UNCONNECTED,
      DOB(4) => dout_4(4),
      DOB(3) => dout_4(3),
      DOB(2) => dout_4(2),
      DOB(1) => dout_4(1),
      DOB(0) => dout_4(0),
      DOPA(3) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOPA_3_UNCONNECTED,
      DOPA(2) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOPA_2_UNCONNECTED,
      DOPA(1) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOPA_1_UNCONNECTED,
      DOPA(0) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOPA_0_UNCONNECTED,
      DOPB(3) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOPB_3_UNCONNECTED,
      DOPB(2) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOPB_2_UNCONNECTED,
      DOPB(1) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOPB_1_UNCONNECTED,
      DOPB(0) => 
NLW_BU2_U0_grf_rf_mem_gbm_gbmg_gbmga_ngecc_bmg_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_ram_SDP_SINGLE_PRIM_SDP_DOPB_0_UNCONNECTED
    );
  BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count_xor_0_11_INV_0 : INV
    port map (
      I => NlwRenamedSig_OI_data_count(0),
      O => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count1
    );
  BU2_U0_grf_rf_gl0_rd_rpntr_Mcount_count_xor_0_11_INV_0 : INV
    port map (
      I => BU2_U0_grf_rf_gl0_rd_rpntr_count(0),
      O => BU2_U0_grf_rf_gl0_rd_rpntr_Mcount_count
    );
  BU2_U0_grf_rf_gl0_wr_wpntr_Mcount_count_xor_0_11_INV_0 : INV
    port map (
      I => BU2_U0_grf_rf_gl0_wr_wpntr_count(0),
      O => BU2_U0_grf_rf_gl0_wr_wpntr_Mcount_count
    );
  BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_full_comb_G : LUT4
    generic map(
      INIT => X"AF23"
    )
    port map (
      I0 => BU2_N14,
      I1 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_wr_rst_d1_106,
      I2 => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count,
      I3 => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      O => BU2_N16
    );
  BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_full_comb_F : LUT4
    generic map(
      INIT => X"C040"
    )
    port map (
      I0 => rd_en,
      I1 => wr_en,
      I2 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_comp1,
      I3 => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_66,
      O => BU2_N15
    );
  BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_full_comb : MUXF5
    port map (
      I0 => BU2_N15,
      I1 => BU2_N16,
      S => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_full_fb_i_105,
      O => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_full_comb_104
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux000670_G : LUT4
    generic map(
      INIT => X"F371"
    )
    port map (
      I0 => prog_full_thresh_3(2),
      I1 => prog_full_thresh_3(3),
      I2 => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad(4),
      I3 => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad(3),
      O => BU2_N141
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux000670_F : LUT4
    generic map(
      INIT => X"08AE"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad(4),
      I1 => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad(3),
      I2 => prog_full_thresh_3(2),
      I3 => prog_full_thresh_3(3),
      O => BU2_N13
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux000670 : MUXF5
    port map (
      I0 => BU2_N13,
      I1 => BU2_N141,
      S => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux000643_130,
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux000670_133
    );
  BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count_xor_2_111 : LUT4
    generic map(
      INIT => X"73EF"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_66,
      I1 => NlwRenamedSig_OI_data_count(0),
      I2 => rd_en,
      I3 => NlwRenamedSig_OI_data_count(1),
      O => BU2_N5
    );
  BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or000079_SW0 : LUT4
    generic map(
      INIT => X"C431"
    )
    port map (
      I0 => wr_en,
      I1 => BU2_U0_grf_rf_gl0_wr_wpntr_count_d2(0),
      I2 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_full_fb_i_105,
      I3 => BU2_U0_grf_rf_gl0_rd_rpntr_count(0),
      O => BU2_N111
    );
  BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count_xor_1_11 : LUT4
    generic map(
      INIT => X"6966"
    )
    port map (
      I0 => NlwRenamedSig_OI_data_count(0),
      I1 => NlwRenamedSig_OI_data_count(1),
      I2 => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_66,
      I3 => rd_en,
      O => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count4
    );
  BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_count_not00011 : LUT4
    generic map(
      INIT => X"6530"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_full_fb_i_105,
      I1 => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_66,
      I2 => rd_en,
      I3 => wr_en,
      O => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_count_not0001
    );
  BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000018_SW0 : LUT4
    generic map(
      INIT => X"FF75"
    )
    port map (
      I0 => rd_en,
      I1 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_full_fb_i_105,
      I2 => wr_en,
      I3 => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_66,
      O => BU2_N51
    );
  BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count_xor_2_12 : LUT4
    generic map(
      INIT => X"DB24"
    )
    port map (
      I0 => NlwRenamedSig_OI_data_count(0),
      I1 => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count,
      I2 => NlwRenamedSig_OI_data_count(1),
      I3 => NlwRenamedSig_OI_data_count(2),
      O => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count7
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_lut_4_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(3),
      I1 => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(3),
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_lut(4)
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux0006153_SW0 : LUT4
    generic map(
      INIT => X"7BDE"
    )
    port map (
      I0 => prog_full_thresh_3(1),
      I1 => prog_full_thresh_3(0),
      I2 => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad(2),
      I3 => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad(1),
      O => BU2_N9
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_lut_3_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(2),
      I1 => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(2),
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_lut(3)
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_lut_2_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(1),
      I1 => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(1),
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_lut(2)
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_lut_1_Q : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(0),
      I1 => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(0),
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_lut(1)
    );
  BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or00003168 : LUT4
    generic map(
      INIT => X"FFF6"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_wpntr_count_d2(3),
      I1 => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(3),
      I2 => BU2_N7,
      I3 => BU2_N3,
      O => BU2_N14
    );
  BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or00003168_SW1 : LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_wpntr_count_d2(2),
      I1 => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(2),
      O => BU2_N7
    );
  BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or0000104 : LUT4
    generic map(
      INIT => X"FF8C"
    )
    port map (
      I0 => BU2_N51,
      I1 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000013_136,
      I2 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_comp1,
      I3 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000092_145,
      O => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or0000
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_wr_pntr_plus1_pad_0_and000011 : LUT2
    generic map(
      INIT => X"D"
    )
    port map (
      I0 => rd_en,
      I1 => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_66,
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_rd_pntr_wr_inv_pad_0_mand_120
    );
  BU2_U0_grf_rf_gl0_wr_gwss_wsts_c1_dout_i55 : LUT4
    generic map(
      INIT => X"9000"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(1),
      I1 => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(1),
      I2 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_c1_dout_i17_139,
      I3 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_c1_dout_i53_142,
      O => BU2_U0_grf_rf_gl0_wr_gwss_wsts_comp1
    );
  BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or000089 : LUT4
    generic map(
      INIT => X"FAF2"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_66,
      I1 => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      I2 => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or000079_140,
      I3 => BU2_N14,
      O => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_mux0000
    );
  BU2_U0_grf_rf_gl0_rd_ram_rd_en_i1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => rd_en,
      I1 => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_66,
      O => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count
    );
  BU2_U0_grf_rf_gl0_wr_gwss_wsts_c1_dout_i17 : LUT2
    generic map(
      INIT => X"9"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(0),
      I1 => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(0),
      O => BU2_U0_grf_rf_gl0_wr_gwss_wsts_c1_dout_i17_139
    );
  BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000078 : LUT4
    generic map(
      INIT => X"9009"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_wpntr_count(2),
      I1 => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(2),
      I2 => BU2_U0_grf_rf_gl0_wr_wpntr_count(1),
      I3 => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(1),
      O => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000078_138
    );
  BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000048 : LUT4
    generic map(
      INIT => X"9009"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_wpntr_count(3),
      I1 => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(3),
      I2 => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(0),
      I3 => BU2_U0_grf_rf_gl0_wr_wpntr_count(0),
      O => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000048_137
    );
  BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000013 : LUT3
    generic map(
      INIT => X"A2"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_103,
      I1 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_wr_rst_d1_106,
      I2 => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      O => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or000013_136
    );
  BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or000062 : LUT4
    generic map(
      INIT => X"9009"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_rd_rpntr_count(1),
      I1 => BU2_U0_grf_rf_gl0_wr_wpntr_count_d2(1),
      I2 => BU2_U0_grf_rf_gl0_rd_rpntr_count(3),
      I3 => BU2_U0_grf_rf_gl0_wr_wpntr_count_d2(3),
      O => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or000062_135
    );
  BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or000035 : LUT3
    generic map(
      INIT => X"82"
    )
    port map (
      I0 => rd_en,
      I1 => BU2_U0_grf_rf_gl0_rd_rpntr_count(2),
      I2 => BU2_U0_grf_rf_gl0_wr_wpntr_count_d2(2),
      O => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_or000035_134
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux0006177 : LUT3
    generic map(
      INIT => X"54"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_wr_rst_d1_106,
      I1 => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux0006153_132,
      I2 => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux000670_133,
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux0006
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux0006138 : LUT4
    generic map(
      INIT => X"A251"
    )
    port map (
      I0 => prog_full_thresh_3(3),
      I1 => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_ram_rd_en_i_128,
      I2 => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_ram_wr_en_i_127,
      I3 => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad(4),
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux0006138_131
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux000643 : LUT4
    generic map(
      INIT => X"7510"
    )
    port map (
      I0 => prog_full_thresh_3(1),
      I1 => prog_full_thresh_3(0),
      I2 => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad(1),
      I3 => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad(2),
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux000643_130
    );
  BU2_U0_grf_rf_gl0_wr_ram_wr_en_i1 : LUT2
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => wr_en,
      I1 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_full_fb_i_105,
      O => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001
    );
  BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count_xor_3_11 : LUT4
    generic map(
      INIT => X"AA96"
    )
    port map (
      I0 => NlwRenamedSig_OI_data_count(3),
      I1 => NlwRenamedSig_OI_data_count(2),
      I2 => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count,
      I3 => BU2_N5,
      O => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count10
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_not00011 : LUT2
    generic map(
      INIT => X"D"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_103,
      I1 => BU2_U0_grf_rf_gl0_wr_gwss_wsts_wr_rst_d1_106,
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_not0001
    );
  BU2_U0_grf_rf_gl0_rd_rpntr_Mcount_count_xor_3_11 : LUT4
    generic map(
      INIT => X"6AAA"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_rd_rpntr_count(3),
      I1 => BU2_U0_grf_rf_gl0_rd_rpntr_count(1),
      I2 => BU2_U0_grf_rf_gl0_rd_rpntr_count(0),
      I3 => BU2_U0_grf_rf_gl0_rd_rpntr_count(2),
      O => BU2_U0_grf_rf_gl0_rd_rpntr_Mcount_count9
    );
  BU2_U0_grf_rf_gl0_wr_wpntr_Mcount_count_xor_3_11 : LUT4
    generic map(
      INIT => X"6AAA"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_wpntr_count(3),
      I1 => BU2_U0_grf_rf_gl0_wr_wpntr_count(0),
      I2 => BU2_U0_grf_rf_gl0_wr_wpntr_count(2),
      I3 => BU2_U0_grf_rf_gl0_wr_wpntr_count(1),
      O => BU2_U0_grf_rf_gl0_wr_wpntr_Mcount_count9
    );
  BU2_U0_grf_rf_gl0_rd_rpntr_Mcount_count_xor_2_11 : LUT3
    generic map(
      INIT => X"6A"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_rd_rpntr_count(2),
      I1 => BU2_U0_grf_rf_gl0_rd_rpntr_count(1),
      I2 => BU2_U0_grf_rf_gl0_rd_rpntr_count(0),
      O => BU2_U0_grf_rf_gl0_rd_rpntr_Mcount_count6
    );
  BU2_U0_grf_rf_gl0_wr_wpntr_Mcount_count_xor_2_11 : LUT3
    generic map(
      INIT => X"6A"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_wpntr_count(2),
      I1 => BU2_U0_grf_rf_gl0_wr_wpntr_count(1),
      I2 => BU2_U0_grf_rf_gl0_wr_wpntr_count(0),
      O => BU2_U0_grf_rf_gl0_wr_wpntr_Mcount_count6
    );
  BU2_U0_grf_rf_gl0_rd_rpntr_Mcount_count_xor_1_11 : LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_rd_rpntr_count(1),
      I1 => BU2_U0_grf_rf_gl0_rd_rpntr_count(0),
      O => BU2_U0_grf_rf_gl0_rd_rpntr_Mcount_count3
    );
  BU2_U0_grf_rf_gl0_wr_wpntr_Mcount_count_xor_1_11 : LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_wpntr_count(1),
      I1 => BU2_U0_grf_rf_gl0_wr_wpntr_count(0),
      O => BU2_U0_grf_rf_gl0_wr_wpntr_Mcount_count3
    );
  BU2_U0_grf_rf_rstblk_rd_rst_comb1 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => BU2_U0_grf_rf_rstblk_rd_rst_asreg_d2_56,
      I1 => BU2_U0_grf_rf_rstblk_rd_rst_asreg_59,
      O => BU2_U0_grf_rf_rstblk_rd_rst_comb
    );
  BU2_U0_grf_rf_rstblk_wr_rst_comb1 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => BU2_U0_grf_rf_rstblk_wr_rst_asreg_d2_58,
      I1 => BU2_U0_grf_rf_rstblk_wr_rst_asreg_60,
      O => BU2_U0_grf_rf_rstblk_wr_rst_comb
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_ram_rd_en_i : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CLR => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      D => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count,
      Q => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_ram_rd_en_i_128
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_ram_wr_en_i : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CLR => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      D => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      Q => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_ram_wr_en_i_127
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i : FDPE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_not0001,
      D => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_prog_full_i_mux0006,
      PRE => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      Q => prog_full
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad_1 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CLR => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      D => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad_add0000(1),
      Q => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad(1)
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad_2 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CLR => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      D => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad_add0000(2),
      Q => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad(2)
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad_3 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CLR => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      D => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad_add0000(3),
      Q => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad(3)
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad_4 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CLR => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      D => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad_add0000(4),
      Q => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad(4)
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_rd_pntr_wr_inv_pad_0_mand : MULT_AND
    port map (
      I0 => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      I1 => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_rd_pntr_wr_inv_pad_0_mand_120,
      LO => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_rd_pntr_wr_inv_pad_0_mand1
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_cy_0_Q : MUXCY
    port map (
      CI => BU2_N1,
      DI => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_rd_pntr_wr_inv_pad_0_mand1,
      S => BU2_rd_data_count(0),
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_cy(0)
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_cy_1_Q : MUXCY
    port map (
      CI => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_cy(0),
      DI => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(0),
      S => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_lut(1),
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_cy(1)
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_xor_1_Q : XORCY
    port map (
      CI => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_cy(0),
      LI => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_lut(1),
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad_add0000(1)
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_cy_2_Q : MUXCY
    port map (
      CI => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_cy(1),
      DI => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(1),
      S => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_lut(2),
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_cy(2)
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_xor_2_Q : XORCY
    port map (
      CI => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_cy(1),
      LI => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_lut(2),
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad_add0000(2)
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_cy_3_Q : MUXCY
    port map (
      CI => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_cy(2),
      DI => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(2),
      S => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_lut(3),
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_cy(3)
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_xor_3_Q : XORCY
    port map (
      CI => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_cy(2),
      LI => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_lut(3),
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad_add0000(3)
    );
  BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_xor_4_Q : XORCY
    port map (
      CI => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_cy(3),
      LI => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_Madd_diff_pntr_pad_add0000_lut(4),
      O => BU2_U0_grf_rf_gl0_wr_gwss_gpf_wrpf_diff_pntr_pad_add0000(4)
    );
  BU2_U0_grf_rf_gl0_wr_gwss_wsts_wr_rst_d1 : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => BU2_rd_data_count(0),
      PRE => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      Q => BU2_U0_grf_rf_gl0_wr_gwss_wsts_wr_rst_d1_106
    );
  BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_full_fb_i : FDP
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_full_comb_104,
      PRE => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      Q => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_full_fb_i_105
    );
  BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_full_i : FDP
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_full_comb_104,
      PRE => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      Q => full
    );
  BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb : FDP
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_or0000,
      PRE => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      Q => BU2_U0_grf_rf_gl0_wr_gwss_wsts_ram_afull_fb_103
    );
  BU2_U0_grf_rf_gl0_rd_rpntr_count_2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count,
      CLR => BU2_U0_grf_rf_rstblk_rd_rst_reg(2),
      D => BU2_U0_grf_rf_gl0_rd_rpntr_Mcount_count6,
      Q => BU2_U0_grf_rf_gl0_rd_rpntr_count(2)
    );
  BU2_U0_grf_rf_gl0_rd_rpntr_count_1 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count,
      CLR => BU2_U0_grf_rf_rstblk_rd_rst_reg(2),
      D => BU2_U0_grf_rf_gl0_rd_rpntr_Mcount_count3,
      Q => BU2_U0_grf_rf_gl0_rd_rpntr_count(1)
    );
  BU2_U0_grf_rf_gl0_rd_rpntr_count_3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count,
      CLR => BU2_U0_grf_rf_rstblk_rd_rst_reg(2),
      D => BU2_U0_grf_rf_gl0_rd_rpntr_Mcount_count9,
      Q => BU2_U0_grf_rf_gl0_rd_rpntr_count(3)
    );
  BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_count_3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_count_not0001,
      CLR => BU2_U0_grf_rf_rstblk_rd_rst_reg(2),
      D => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count10,
      Q => NlwRenamedSig_OI_data_count(3)
    );
  BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_count_2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_count_not0001,
      CLR => BU2_U0_grf_rf_rstblk_rd_rst_reg(2),
      D => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count7,
      Q => NlwRenamedSig_OI_data_count(2)
    );
  BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_count_1 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_count_not0001,
      CLR => BU2_U0_grf_rf_rstblk_rd_rst_reg(2),
      D => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count4,
      Q => NlwRenamedSig_OI_data_count(1)
    );
  BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_count_0 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_count_not0001,
      CLR => BU2_U0_grf_rf_rstblk_rd_rst_reg(2),
      D => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count1,
      Q => NlwRenamedSig_OI_data_count(0)
    );
  BU2_U0_grf_rf_gl0_wr_wpntr_count_3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      CLR => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      D => BU2_U0_grf_rf_gl0_wr_wpntr_Mcount_count9,
      Q => BU2_U0_grf_rf_gl0_wr_wpntr_count(3)
    );
  BU2_U0_grf_rf_gl0_rd_rpntr_count_0 : FDPE
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count,
      D => BU2_U0_grf_rf_gl0_rd_rpntr_Mcount_count,
      PRE => BU2_U0_grf_rf_rstblk_rd_rst_reg(2),
      Q => BU2_U0_grf_rf_gl0_rd_rpntr_count(0)
    );
  BU2_U0_grf_rf_gl0_wr_wpntr_count_1 : FDPE
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      D => BU2_U0_grf_rf_gl0_wr_wpntr_Mcount_count3,
      PRE => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      Q => BU2_U0_grf_rf_gl0_wr_wpntr_count(1)
    );
  BU2_U0_grf_rf_gl0_wr_wpntr_count_0 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      CLR => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      D => BU2_U0_grf_rf_gl0_wr_wpntr_Mcount_count,
      Q => BU2_U0_grf_rf_gl0_wr_wpntr_count(0)
    );
  BU2_U0_grf_rf_gl0_wr_wpntr_count_2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      CLR => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      D => BU2_U0_grf_rf_gl0_wr_wpntr_Mcount_count6,
      Q => BU2_U0_grf_rf_gl0_wr_wpntr_count(2)
    );
  BU2_U0_grf_rf_gl0_wr_wpntr_count_d1_0 : FDPE
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      D => BU2_U0_grf_rf_gl0_wr_wpntr_count(0),
      PRE => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      Q => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(0)
    );
  BU2_U0_grf_rf_gl0_wr_wpntr_count_d1_1 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      CLR => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      D => BU2_U0_grf_rf_gl0_wr_wpntr_count(1),
      Q => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(1)
    );
  BU2_U0_grf_rf_gl0_wr_wpntr_count_d1_2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      CLR => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      D => BU2_U0_grf_rf_gl0_wr_wpntr_count(2),
      Q => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(2)
    );
  BU2_U0_grf_rf_gl0_wr_wpntr_count_d1_3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      CLR => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      D => BU2_U0_grf_rf_gl0_wr_wpntr_count(3),
      Q => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(3)
    );
  BU2_U0_grf_rf_gl0_wr_wpntr_count_d2_3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      CLR => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      D => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(3),
      Q => BU2_U0_grf_rf_gl0_wr_wpntr_count_d2(3)
    );
  BU2_U0_grf_rf_gl0_wr_wpntr_count_d2_2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      CLR => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      D => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(2),
      Q => BU2_U0_grf_rf_gl0_wr_wpntr_count_d2(2)
    );
  BU2_U0_grf_rf_gl0_wr_wpntr_count_d2_1 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      CLR => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      D => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(1),
      Q => BU2_U0_grf_rf_gl0_wr_wpntr_count_d2(1)
    );
  BU2_U0_grf_rf_gl0_wr_wpntr_count_d2_0 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_wr_wpntr_count_not0001,
      CLR => BU2_U0_grf_rf_rstblk_wr_rst_reg(1),
      D => BU2_U0_grf_rf_gl0_wr_wpntr_count_d1(0),
      Q => BU2_U0_grf_rf_gl0_wr_wpntr_count_d2(0)
    );
  BU2_U0_grf_rf_gl0_rd_rpntr_count_d1_3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count,
      CLR => BU2_U0_grf_rf_rstblk_rd_rst_reg(2),
      D => BU2_U0_grf_rf_gl0_rd_rpntr_count(3),
      Q => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(3)
    );
  BU2_U0_grf_rf_gl0_rd_rpntr_count_d1_2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count,
      CLR => BU2_U0_grf_rf_rstblk_rd_rst_reg(2),
      D => BU2_U0_grf_rf_gl0_rd_rpntr_count(2),
      Q => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(2)
    );
  BU2_U0_grf_rf_gl0_rd_rpntr_count_d1_1 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count,
      CLR => BU2_U0_grf_rf_rstblk_rd_rst_reg(2),
      D => BU2_U0_grf_rf_gl0_rd_rpntr_count(1),
      Q => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(1)
    );
  BU2_U0_grf_rf_gl0_rd_rpntr_count_d1_0 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_gl0_rd_grss_gdc_dc_dc_Mcount_count,
      CLR => BU2_U0_grf_rf_rstblk_rd_rst_reg(2),
      D => BU2_U0_grf_rf_gl0_rd_rpntr_count(0),
      Q => BU2_U0_grf_rf_gl0_rd_rpntr_count_d1(0)
    );
  BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_i : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_mux0000,
      PRE => BU2_U0_grf_rf_rstblk_rd_rst_reg(2),
      Q => empty
    );
  BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_mux0000,
      PRE => BU2_U0_grf_rf_rstblk_rd_rst_reg(2),
      Q => BU2_U0_grf_rf_gl0_rd_grss_rsts_ram_empty_fb_i_66
    );
  BU2_U0_grf_rf_rstblk_wr_rst_reg_1 : FDP
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_rd_data_count(0),
      PRE => BU2_U0_grf_rf_rstblk_wr_rst_comb,
      Q => BU2_U0_grf_rf_rstblk_wr_rst_reg(1)
    );
  BU2_U0_grf_rf_rstblk_rd_rst_reg_2 : FDP
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_rd_data_count(0),
      PRE => BU2_U0_grf_rf_rstblk_rd_rst_comb,
      Q => BU2_U0_grf_rf_rstblk_rd_rst_reg(2)
    );
  BU2_U0_grf_rf_rstblk_rd_rst_asreg : FDPE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_rstblk_rd_rst_asreg_d1_55,
      D => BU2_rd_data_count(0),
      PRE => rst,
      Q => BU2_U0_grf_rf_rstblk_rd_rst_asreg_59
    );
  BU2_U0_grf_rf_rstblk_wr_rst_asreg_d1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_grf_rf_rstblk_wr_rst_asreg_60,
      Q => BU2_U0_grf_rf_rstblk_wr_rst_asreg_d1_57
    );
  BU2_U0_grf_rf_rstblk_wr_rst_asreg : FDPE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => BU2_U0_grf_rf_rstblk_wr_rst_asreg_d1_57,
      D => BU2_rd_data_count(0),
      PRE => rst,
      Q => BU2_U0_grf_rf_rstblk_wr_rst_asreg_60
    );
  BU2_U0_grf_rf_rstblk_rd_rst_asreg_d1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_grf_rf_rstblk_rd_rst_asreg_59,
      Q => BU2_U0_grf_rf_rstblk_rd_rst_asreg_d1_55
    );
  BU2_U0_grf_rf_rstblk_wr_rst_asreg_d2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_grf_rf_rstblk_wr_rst_asreg_d1_57,
      Q => BU2_U0_grf_rf_rstblk_wr_rst_asreg_d2_58
    );
  BU2_U0_grf_rf_rstblk_rd_rst_asreg_d2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => BU2_U0_grf_rf_rstblk_rd_rst_asreg_d1_55,
      Q => BU2_U0_grf_rf_rstblk_rd_rst_asreg_d2_56
    );
  BU2_XST_VCC : VCC
    port map (
      P => BU2_N1
    );
  BU2_XST_GND : GND
    port map (
      G => BU2_rd_data_count(0)
    );

end STRUCTURE;

-- synthesis translate_on
