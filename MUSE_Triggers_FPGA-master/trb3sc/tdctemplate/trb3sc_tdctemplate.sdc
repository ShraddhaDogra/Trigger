define_clock   {CLK_CORE_PCLK} -name {CLK_CORE_PCLK}  -freq 200
define_clock   {pll_in125_out33|CLKOP_inferred_clock} -name {clk_cal} -freq 33
define_clock   {clock_reset_handler|REF_CLK_OUT_inferred_clock} -name {ref_clk} -freq 200
define_clock   {clock_reset_handler|SYS_CLK_OUT_inferred_clock} -name {sys_clk} -freq 100
define_clock   {serdes_sync_0|rx_full_clk_ch0_inferred_clock}  -name {full_rx} -freq 200
define_clock   {System} -name{system} -freq 100	