TOPNAME                      => "trb3_central_gbe",
lm_license_file_for_synplify => "27000\@lxcad01.gsi.de",
lm_license_file_for_par      => "1702\@hadeb05.gsi.de",
lattice_path                 => '/opt/lattice/diamond/3.8_x64/',
synplify_path                => '/opt/synplicity/L-2016.09-1',
#lattice_path                 => '/opt/lattice/diamond/3.2_x64/',
#synplify_path                => '/opt/synplicity/I-2013.09-SP1/',
#synplify_command             => "/opt/lattice/diamond/3.5_x64/bin/lin64/synpwrap -fg -options",
synplify_command             => "/opt/synplicity/L-2016.09-1/bin/synplify_premier_dp",

nodelist_file                => '../nodes_lxhadeb07.txt',

include_TDC                  => 0,
include_GBE                  => 1,


twr_number_of_errors         => 20,
firefox_open                 => 0,

