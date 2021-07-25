TOPNAME                      => "trb3_periph_blank",
lm_license_file_for_synplify => "27020\@jspc29", #"27000\@lxcad01.gsi.de";
lm_license_file_for_par      => "1702\@jspc29",
lattice_path                 => '/d/jspc29/lattice/diamond/3.9_x64',
synplify_path                => '/d/jspc29/lattice/synplify/M-2017.03/',
#synplify_command             => "/d/jspc29/lattice/diamond/3.6_x64/bin/bin64/synpwrap -fg -options",
#synplify_command             => "/d/jspc29/lattice/synplify/J-2014.09-SP2/bin/synplify_premier_dp",
#synplify_command             => "ssh -p 52238 jmichel\@cerberus \"cd /home/jmichel/git/trb3/blank/workdir; LM_LICENSE_FILE=27000\@lxcad01.gsi.de /opt/synplicity/L-2016.09-1/bin/synplify_premier_dp -batch ../trb3_periph_blank.prj\" #",

nodelist_file                => 'nodes_frankfurt.txt',
pinout_file                  => 'trb3_periph_gpin',

#Include only necessary lpf files
#pinout_file                  => '', #name of pin-out file, if not equal TOPNAME
include_TDC                  => 0,
include_GBE                  => 0,

#Report settings
firefox_open                 => 0,
twr_number_of_errors         => 20,

Familyname  => 'LatticeECP3',
Devicename  => 'LFE3-150EA',
Package     => 'FPBGA672',
Speedgrade  => '8',
