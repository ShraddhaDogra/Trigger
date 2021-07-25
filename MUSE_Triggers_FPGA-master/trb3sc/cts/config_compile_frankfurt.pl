TOPNAME                      => "trb3sc_cts",
lm_license_file_for_synplify => "27020\@jspc29", #"27000\@lxcad01.gsi.de";
lm_license_file_for_par      => "1702\@hadeb05.gsi.de",
lattice_path                 => '/d/jspc29/lattice/diamond/3.9_x64',
synplify_path                => '/d/jspc29/lattice/synplify/K-2015.09/',
#synplify_command             => "/d/jspc29/lattice/diamond/3.5_x64/bin/lin64/synpwrap -fg -options",
#synplify_command             => "/d/jspc29/lattice/synplify/J-2014.09-SP2/bin/synplify_premier_dp",

nodelist_file                => 'nodes_cts_frankfurt.txt',
pinout_file                  => 'trb3sc_hub',


#Include only necessary lpf files
#pinout_file                  => '', #name of pin-out file, if not equal TOPNAME
include_TDC                  => 1,
include_GBE                  => 1,

#Report settings
firefox_open                 => 0,
twr_number_of_errors         => 20,

