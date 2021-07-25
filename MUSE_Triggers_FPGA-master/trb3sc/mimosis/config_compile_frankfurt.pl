TOPNAME                      => "trb3sc_mimosis",
lm_license_file_for_synplify => "27020\@jspc29", #"27000\@lxcad01.gsi.de";
lm_license_file_for_par      => "1702\@hadeb05.gsi.de",
lattice_path                 => '/d/jspc29/lattice/diamond/3.10_x64',
synplify_path                => '/d/jspc29/lattice/synplify/L-2016.09-1/',

nodelist_file                => 'nodelist_frankfurt.txt',


#Include only necessary lpf files
pinout_file                  => 'trb3sc_mimosis', #name of pin-out file, if not equal TOPNAME
include_TDC                  => 0,
include_GBE                  => 1,

#Report settings
firefox_open                 => 0,
twr_number_of_errors         => 20,

