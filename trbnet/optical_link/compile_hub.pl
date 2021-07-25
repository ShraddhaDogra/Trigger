#!/usr/bin/perl
###########################################
# Script file to run the flow
#
###########################################
#
# Command line for synplify_pro
#


use FileHandle;


use Data::Dumper;

use warnings;
use strict;


$ENV{LM_LICENSE_FILE}="1710\@cronos.e12.physik.tu-muenchen.de";

my $synplify_path = '/opt/Synplicity/syn_96L2/synplify_linux/bin/';

$ENV{'SYNPLIFY'}="/opt/Synplicity/syn_96L2/synplify_linux/";
$ENV{'SYN_DISABLE_RAINBOW_DONGLE'}=1;


my $base = "/opt/lattice/ispLEVER7.2/isptools";

my $FAMILYNAME="LatticeSCM";
my $PLD_DEVICE="LFSCM3GA25EP1";
my $PACKAGE="FFBGA1020";

my $TOPNAME="hub";

my $t=time; 

my $fh = new FileHandle(">version.vhd");

die "could not open file" if (! defined $fh);

print $fh <<EOF;

--## attention, automatically generated. Don't change by hand.
library ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;
use ieee.numeric_std.all;

package version is
    
    constant VERSION_NUMBER_TIME  : integer   := $t;

end package version;


EOF

$fh->close;


#set -e
#set -o errexit

system("env| grep LM_");
#$c="/opt/Synplicity/fpga_901/bin/synplify_pro -disable_rainbow_dongle -batch $TOPNAME"."_syn.prj";
#$c="/opt/Synplicity/syn_96L2/synplify_linux/bin/synpwrap_pro.sh -disable_rainbow_dongle -batch $TOPNAME"."_syn.prj";
#execute($c);
#$c="/opt/Synplicity/fpga_89/bin/synplify_pro -disable_rainbow_dongle -batch $TOPNAME"."_syn.prj";
#$c=("( netcat  -w2 -l -u -p 6001 < data_for_synbatch_6001.raw >/dev/null 2>&1)&  /opt/Synplicity/fpga_89/bin/synplify_pro -batch $TOPNAME"."_syn.prj");
#$r=execute($c, "do_not_exit" );

my $c="$synplify_path/synpwrap -Pro -prj $TOPNAME"."_syn.prj";
my $r=execute($c, "do_not_exit" );


chdir "workdir";
$fh = new FileHandle("<$TOPNAME.srr");
my @a = <$fh>;
$fh -> close;

#if ($r) { 
#$c="cat  $TOPNAME.srr";
#system($c);
#exit 129; 
#}

foreach (@a) 
{
    if( /\@E:/ || /\@E\|/ ) 
    {
	$c="cat  $TOPNAME.srr";
	system($c);
        print "bdabdhsadbhjasdhasldhbas";
	exit 129;	
    }
}
#if (0){

#$c=("/opt/lattice/isplever7.0/isptools/ispcpld/bin/checkini -err=automake.err /opt/lattice/isplever7.0/isptools/ispcpld/config/or5s00.ini");


#$c=("/opt/lattice/isplever7.0/isptools/ispcpld/bin/edfin -i hub.edf -jhd hub.jhd -log hub.log -dev orca -lbp \"/opt/lattice/isplever7.0/isptools/ispfpga/data\"");

#$c=("/opt/lattice/isplever7.0//ispfpga/bin/lin/lci2prf  -oc hub.lct -log hub.log ../hub.lpf");

#$c=("export FOUNDRY=\"/opt/lattice/isplever7.0//ispfpga\"");

#$c=("export LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH:/opt/lattice/isplever7.0//ispfpga/bin/lin\"");

$c= qq|$base/ispfpga/bin/lin/edif2ngd  -l "$FAMILYNAME" -d "$PLD_DEVICE" "$TOPNAME.edf" "$TOPNAME.ngo"|;
execute($c);

$c=qq|$base/ispfpga/bin/lin/edfupdate  -t "$TOPNAME.tcy" -w "$TOPNAME.ngo" -m "$TOPNAME.ngo" "$TOPNAME.ngx"|;
execute($c);

$c=qq|$base/ispfpga/bin/lin/ngdbuild  -a "$FAMILYNAME" -d "$PLD_DEVICE" -p "$base/ispfpga/or5s00/data" -dt "$TOPNAME.ngo" "$TOPNAME.ngd"|;
execute($c);

my $tpmap = $TOPNAME . "_map" ;

$c=qq|$base/ispfpga/bin/lin/map  -a "$FAMILYNAME" -p "$PLD_DEVICE" -t "$PACKAGE" -s 5 "$TOPNAME.ngd" -o "$tpmap.ncd"  -mp "$TOPNAME.mrp" "$TOPNAME.lpf"|;
execute($c);

system("rm $TOPNAME.ncd");
#execute($c);

$c=qq|$base/ispfpga/bin/lin/multipar -pr "$TOPNAME.prf" -o "$TOPNAME| . "_mpar.rpt" . qq|" -log "$TOPNAME| . "_mpar.log" . qq|" -p "$TOPNAME.p2t" -f "$TOPNAME.p3t" "$tpmap.ncd" "$TOPNAME.ncd"|;
execute($c);


# TWR Timing Report
#$c=qq|$lattice_path/ispfpga/bin/lin/tg "$TOPNAME.ncd" "$TOPNAME.prf"|;
$c=qq|$base/ispfpga/bin/lin/trce -hld -c -v 5 -o "$TOPNAME.twr.hold"  "$TOPNAME.ncd" "$TOPNAME.prf"|;
execute($c);
$c=qq|$base/ispfpga/bin/lin/trce -c -v 5 -o "$TOPNAME.twr.setup" "$TOPNAME.ncd" "$TOPNAME.prf"|;
execute($c);



$c=("$base/ispfpga/bin/lin/bitgen  -w \"hub.ncd\" -f \"hub.t2b\" \"hub.prf\"");
execute($c);
#$c=(". ~/bin/ispvm17");
#execute($c);

$c=q| perl -ne '$in=1 if(/Report Summary/); print if($in==1); $in=0 if(/All preferences were met./)' | . "$TOPNAME.twr.setup";
execute($c);

chdir "..";

$c=("cat version.vhd | grep VERSION_NUMBER_TIME"); 
execute($c);

$c=q!cat version.vhd | perl -ne '($r)=grep(/VERSION_NUMBER_TIME/, $_); if($r) {($n)=$r=~/(\d+);/; printf("%x\n",$n);} '!;
execute($c);


#$c=(". ~/bin/ispvm17");

#$c=("ispvm -infile hub_1.xcf -outfiletype -stp");
#execute($c);

#$c=("perl -i  -ne 'print unless(/!/)' hub_1.svf");
#execute($c);
#$c=("impact -batch impact_batch_hub.txt");
#execute($c);
#$c=("scp hub_chain.stapl hadaq\@hadeb05:/var/diskless/etrax_fs/");
#execute($c);

#}
#$c=("impact -batch impact_batch_hub.txt");

sub execute {
    my ($c, $op) = @_;
    #print "option: $op \n";

    print "\n\ncommand to execute: $c \n";
    $r=system($c);
    if($r) { 
	print "$!";
	if($op ne "do_not_exit") {
	    exit; 
	}
    }
    
    return $r;

}
