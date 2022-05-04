
#Begin clock constraint
define_clock -name {pll_in200_out100|CLKOP_inferred_clock} {n:pll_in200_out100|CLKOP_inferred_clock} -period 12.562 -clockgroup Autoconstr_clkgroup_0 -rise 0.000 -fall 6.281 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {trb3_periph_blank|CLK_PCLK_RIGHT} {p:trb3_periph_blank|CLK_PCLK_RIGHT} -period 0.980 -clockgroup Autoconstr_clkgroup_1 -rise 0.000 -fall 0.490 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {sfp_1_200_int_work_trb3_periph_blank_trb3_periph_blank_arch_0layer0|rx_half_clk_ch1_inferred_clock} {n:sfp_1_200_int_work_trb3_periph_blank_trb3_periph_blank_arch_0layer0|rx_half_clk_ch1_inferred_clock} -period 4.087 -clockgroup Autoconstr_clkgroup_2 -rise 0.000 -fall 2.043 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {pll_in200_out100|CLKOK_inferred_clock} {n:pll_in200_out100|CLKOK_inferred_clock} -period 3.329 -clockgroup Autoconstr_clkgroup_3 -rise 0.000 -fall 1.664 -route 0.000 
#End clock constraint
