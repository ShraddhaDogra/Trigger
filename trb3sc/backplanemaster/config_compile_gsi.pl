TOPNAME                      => "trb3sc_master",
lm_license_file_for_synplify => "27000\@lxcad01.gsi.de",
lm_license_file_for_par      => "1702\@hadeb05.gsi.de",
lattice_path                 => '/opt/lattice/diamond/3.6_x64/',
synplify_path                => '/opt/synplicity/J-2014.09-SP2',
#synplify_command             => "/opt/lattice/diamond/3.4_x64/bin/lin64/synpwrap -fg -options",
synplify_command             => "/opt/synplicity/K-2015.09/bin/synplify_premier_dp",

nodelist_file                => 'nodelist_gsi_template.txt',

firefox_open                 => 0,

include_GBE                  => 1,

#Report settings
firefox_open                 => 0,
twr_number_of_errors         => 20,