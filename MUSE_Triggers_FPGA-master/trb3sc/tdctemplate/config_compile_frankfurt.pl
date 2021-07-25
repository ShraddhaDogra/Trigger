TOPNAME                      => "trb3sc_tdctemplate",
lm_license_file_for_synplify => "27020\@jspc29", #"27000\@lxcad01.gsi.de";
lm_license_file_for_par      => "1702\@hadeb05.gsi.de",
lattice_path                 => '/d/jspc29/lattice/diamond/3.10_x64',
synplify_path                => '/d/jspc29/lattice/synplify/N-2017.09-1/',
nodelist_file                => '../tdctemplate/nodes_tdctemplate.txt',
#Include only necessary lpf files
#pinout_file                  => 'trb3sc_32pin', #name of pin-out file, if not equal TOPNAME
pinout_file                  => 'trb3sc_padiwa', #name of pin-out file, if not equal TOPNAME
include_TDC                  => 1,
include_GBE                  => 0,

#Report settings
firefox_open                 => 0,
twr_number_of_errors         => 20,

