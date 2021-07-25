TOPNAME                      => "trb3sc_tdctemplate",
lm_license_file_for_synplify => "1702\@hadeb05.gsi.de", #"27000\@lxcad01.gsi.de";
lm_license_file_for_par      => "1702\@hadeb05.gsi.de",
lattice_path                 => '/d/jspc29/lattice/diamond/3.6_x64',
synplify_path                => '/d/jspc29/lattice/synplify/K-2015.09/',
synplify_command             => "/d/jspc29/lattice/diamond/3.6_x64/bin/lin64/synpwrap -fg -options",
#synplify_command             => "/d/jspc29/lattice/synplify/J-2014.09-SP2/bin/synplify_premier_dp",
#synplify_command             => "ssh -p 59222 jmichel\@cerberus \"cd /home/jmichel/git/trb3sc/tdctemplate/workdir; LM_LICENSE_FILE=27000\@lxcad01.gsi.de /opt/synplicity/K-2015.09/bin/synplify_premier_dp -batch ../trb3sc_tdctemplate.prj\" #",

nodelist_file                => 'nodes_frankfurt.txt',

#Include only necessary lpf files
#pinout_file                  => '', #name of pin-out file, if not equal TOPNAME
include_TDC                  => 1,
include_GBE                  => 0,

#Report settings
firefox_open                 => 0,
twr_number_of_errors         => 20,

