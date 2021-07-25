TOPNAME                      => "trb3sc_adc",
lm_license_file_for_synplify => "27020\@jspc29", #"27000\@lxcad01.gsi.de";
lm_license_file_for_par      => "1702\@hadeb05.gsi.de",
lattice_path                 => '/d/jspc29/lattice/diamond/3.7_x64',
synplify_path                => '/d/jspc29/lattice/synplify/L-2016.03/',
# synplify_path                => '/d/jspc29/lattice/synplify/J-2015.03-SP1/',
# synplify_path                => '/d/jspc29/lattice/synplify/I-2013.09-SP1/',
# synplify_command             => "/d/jspc29/lattice/diamond/3.5_x64/bin/lin64/synpwrap -fg -options",
# synplify_binary              => "/d/jspc29/lattice/synplify/I-2013.09-SP1/bin/synplify_pro",
#synplify_command             => "/d/jspc29/lattice/synplify/J-2014.09-SP2/bin/synplify_premier_dp",
# synplify_command             => "ssh -p 52238 jmichel\@cerberus \"cd /home/jmichel/git/trb3sc/adcaddon; LM_LICENSE_FILE=27000\@lxcad01.gsi.de /opt/synplicity/I-2013.09-SP1/bin/synplify_premier_dp -batch trb3sc_adc.prj\" #",

nodelist_file                => 'nodes_frankfurt_adcaddon.txt',


#Include only necessary lpf files
#pinout_file                  => '', #name of pin-out file, if not equal TOPNAME
include_TDC                  => 0,
include_GBE                  => 0,

#Report settings
firefox_open                 => 0,
twr_number_of_errors         => 20,

