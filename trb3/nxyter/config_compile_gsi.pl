Familyname  => 'LatticeECP3',
Devicename  => 'LFE3-150EA',
Package     => 'FPBGA672',
Speedgrade  => '8',

TOPNAME                      => "trb3_periph_nxyter",
project_path                 => "nxyter",
lm_license_file_for_synplify => "27000\@lxcad01.gsi.de",
lm_license_file_for_par      => "1702\@hadeb05.gsi.de",
lattice_path                 => '/opt/lattice/diamond/3.6_x64',
synplify_path                => '/opt/synplicity/K-2015.09',
#synplify_command             => "/opt/lattice/diamond/3.6_x64/bin/lin64/synpwrap -fg -options",
synplify_command             => "/opt/synplicity/K-2015.09/bin/synplify_premier_dp",
#pinout_file                  => '../nxyter/trb3_periph_nxyter',
nodelist_file                => '../nodes_lxhadeb07.txt',
    
#Include only necessary lpf files
include_TDC                  => 0,
include_GBE                  => 0,

#Report settings
firefox_open                 => 0,
twr_number_of_errors         => 20,
