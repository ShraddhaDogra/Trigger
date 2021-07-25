# Synplicity, Inc. constraint file
# /home/marek/vulom3/vlogic_1.sdc
# Written on Mon Apr 28 11:36:24 2008
# by Synplify Pro, Version 9.0.1 Scope Editor

#
# Collections
#

#
# Clocks
#

define_clock   {p:vlogic_1|CKFPL} -name {p:vlogic_1|CKFPL}  -freq 110 -clockgroup Autoconstr_clkgroup_1 -rise 0 -fall 5 -route 0
define_clock   {n:beam_ramp|clk_10Hz} -name {n:beam_ramp|clk_10Hz}  -period 1000 -clockgroup Autoconstr_clkgroup_3 -rise 0 -fall 0.5 -route 0
define_clock   {n:CLKDV_BUFG_INST|CLKDV_OUT} -name {n:CLKDV_BUFG_INST|CLKDV_OUT}  -freq 55 -clockgroup Autoconstr_clkgroup_1 -rise 0 -fall 10 -route 0
define_clock   {n:CLKFX_BUFG_INST|CLKFX_OUT} -name {n:CLKFX_BUFG_INST|CLKFX_OUT}  -freq 330 -clockgroup Autoconstr_clkgroup_1 -rise 0 -fall 1.5 -route 0

#
# Clock to Clock
#

#
# Inputs/Outputs
#

#
# Registers
#

#
# Multi-Cycle Paths
#

#
# False Paths
#

#
# Max Delay Paths
#

#
# Attributes
#

#
# I/O Standards
#

#
# Compile Points
#

#
# Other
#
