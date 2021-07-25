# SimVision Command Script (Mon Feb 26 17:08:36 CET 2007)
#
# Version 05.70.s005
#
# You can restore this configuration with:
#
#     ncsim -update -tcl -gui -cdslib /home/tiago/work/hades/trbnet/ssim/cds.lib -logfile ncsim.log -errormax 15 -status worklib.trb_net_old_to_new_testbench:test -input /home/tiago/work/hades/trbnet/ssim/TRB1.tcl
#


#
# preferences
#
preferences set toolbar-CursorControl-WatchList {
  usual
  position -row 0
}
preferences set toolbar-Standard-WatchList {
  usual
  position -row 1
}
preferences set toolbar-Edit-WatchList {
  usual
  shown 0
}
preferences set toolbar-Windows-SrcBrowser {
  usual
  hide icheck
}
preferences set toolbar-Windows-WaveWindow {
  usual
  hide icheck
  position -pos 3
}
preferences set toolbar-Windows-WatchList {
  usual
  hide icheck
  position -pos 2 -anchor w
}
preferences set toolbar-TimeSearch-WatchList {
  usual
  shown 0
}

#
# Simulator
#

database require simulator -hints {
	simulator "ncsim -update -tcl -gui -cdslib /home/tiago/work/hades/trbnet/ssim/cds.lib -logfile ncsim.log -errormax 15 -status worklib.trb_net_old_to_new_testbench:test -input TRB1.tcl"
}

#
# conditions
#
set expression {bus(:uut_lvl2:APL_DATA_OUT[7], :uut_lvl2:APL_DATA_OUT[6], :uut_lvl2:APL_DATA_OUT[5], :uut_lvl2:APL_DATA_OUT[4], :uut_lvl2:APL_DATA_OUT[3], :uut_lvl2:APL_DATA_OUT[2], :uut_lvl2:APL_DATA_OUT[1], :uut_lvl2:APL_DATA_OUT[0])}
if {[catch {condition new -name  DATA_OUT -expr $expression}] != ""} {
    condition set -using DATA_OUT -expr $expression
}

#
# cursors
#
set time 43545000000fs
if {[catch {cursor new -name  TimeA -time $time}] != ""} {
    cursor set -using TimeA -time $time
}
set time 120000000000fs
if {[catch {cursor new -name  TimeB -time $time}] != ""} {
    cursor set -using TimeB -time $time
}
cursor set -using TimeB -marching 1

#
# mmaps
#
mmap new -reuse -name {Boolean as Logic} -contents {
{%c=FALSE -edgepriority 1 -shape low}
{%c=TRUE -edgepriority 1 -shape high}
}
mmap new -reuse -name {Example Map} -contents {
{%b=11???? -bgcolor orange -label REG:%x -linecolor yellow -shape bus}
{%x=1F -bgcolor red -label ERROR -linecolor white -shape EVENT}
{%x=2C -bgcolor red -label ERROR -linecolor white -shape EVENT}
{%x=* -label %x -linecolor gray -shape bus}
}

#
# timeranges
#
timerange new -name LVL1 -start 8890ns -end 10250ns

#
# Design Browser windows
#
if {[catch {window new WatchList -name "Design Browser 1" -geometry 1082x707+1478+267}] != ""} {
    window geometry "Design Browser 1" 1082x707+1478+267
}
window target "Design Browser 1" on
browser using {Design Browser 1}
browser set \
    -scope :uut_lvl2 \
    -showassertions 0 \
    -showfibers 0 \
    -showinouts 0 \
    -showinputs 0 \
    -showinternals 0
browser yview see :uut_lvl2
browser timecontrol set -lock 0

#
# Waveform windows
#
if {[catch {window new WaveWindow -name "Waveform 1" -geometry 1280x963+0+0}] != ""} {
    window geometry "Waveform 1" 1280x963+0+0
}
window target "Waveform 1" on
waveform using {Waveform 1}
waveform sidebar visibility partial
waveform set \
    -primarycursor TimeA \
    -signalnames name \
    -signalwidth 175 \
    -units ns \
    -valuewidth 75
cursor set -using TimeA -time 43,545,000,000fs
waveform baseline set -time 10,250,000,000fs

set id [waveform add -signals [list :uut_lvl1:CLK_EN \
	:uut_lvl1:CLK \
	:uut_lvl1:RESET \
	:uut_lvl1:OLD_T \
	:uut_lvl1:OLD_TS \
	:uut_lvl1:OLD_TD \
	:uut_lvl1:OLD_TB \
	:uut_lvl1:OLD_TE \
	:uut_lvl1:present_state \
	:uut_lvl1:next_state \
	:uut_lvl1:APL_SEND_OUT \
	:uut_lvl1:APL_READ_OUT \
	:uut_lvl1:APL_RUN_IN \
	:uut_lvl1:APL_SEQNR_IN \
	:uut_lvl1:APL_DTYPE_OUT \
	DATA_OUT \
	:uut_lvl2:CLK \
	:uut_lvl2:CLK \
	:uut_lvl2:RESET \
	:uut_lvl2:OLD_T \
	:uut_lvl2:OLD_TS \
	:uut_lvl2:OLD_TD \
	:uut_lvl2:OLD_TB \
	:uut_lvl2:OLD_TE \
	:uut_lvl2:DVAL_i \
	:uut_lvl2:present_state \
	:uut_lvl2:next_state \
	:uut_lvl2:APL_SEND_OUT \
	:uut_lvl2:APL_READ_OUT \
	:uut_lvl2:APL_RUN_IN \
	:uut_lvl2:APL_DTYPE_OUT \
	DATA_OUT ]]

waveform xview limits 0 120000ns
