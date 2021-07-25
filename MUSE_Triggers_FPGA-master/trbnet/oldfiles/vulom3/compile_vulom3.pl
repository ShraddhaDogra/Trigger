#!/usr/bin/perl
###########################################
# Script file to run the flow
#
###########################################
#
# Command line for synplify_pro
#


use FileHandle;


$ENV{LM_LICENSE_FILE}="1709\@hadeb05";



$PLD_DEVICE="xc4vlx25-10-sf363";
$TOPNAME="vlogic_1";



#set -e
#set -o errexit

system("env| grep LM_");

#$c="/opt/Synplicity/fpga_861/bin/synplify_pro -batch $TOPNAME"."_syn.prj";
#$c="/opt/Synplicity/fpga_8804/bin/synplify_pro -batch $TOPNAME"."_syn.prj";
#$c="/opt/Synplicity/fpga_89/bin/synplify_pro -disable_rainbow_dongle -batch $TOPNAME"."_syn.prj";
$c="/opt/Synplicity/fpga_901/bin/synplify_pro -disable_rainbow_dongle -batch $TOPNAME"."_syn.prj";
#$c=("( netcat  -w2 -l -u -p 6001 < data_for_synbatch_6001.raw >/dev/null 2>&1)&  /opt/Synplicity/fpga_89/bin/synplify_pro -batch $TOPNAME"."_syn.prj");
$r=execute($c, "do_not_exit" );


chdir "workdir";
my $fh = new FileHandle("<trig_box1.srr");
my @a = <$fh>;
$fh -> close;

#if ($r) { 
#$c="cat  $TOPNAME.srr";
#system($c);
#exit 129; 
#}

foreach (@a) 
{
    if(/\@E:/) 
    {
	$c="cat  $TOPNAME.srr";
	system($c);
        print "bdabdhsadbhjasdhasldhbas";
	exit 129;	
    }
}
#
# Command line to synthesize
#

#chdir "..";
#$c="xst -intstyle xflow -ifn $TOPNAME.xst -ofn $TOPNAME.syr";
#execute($c);
#chdir "workdir";

#
# Command line for ngdbuild
#
#$c="ngdbuild -p $PLD_DEVICE -nt timestamp -intstyle xflow -uc ../$TOPNAME.ucf ../$TOPNAME.ngc $TOPNAME.ngd";
$c="ngdbuild -p $PLD_DEVICE -nt timestamp -intstyle xflow -uc ../$TOPNAME.ucf -sd ../ $TOPNAME.edf $TOPNAME.ngd";
execute($c);
#
# Command line for fpgafit
#
$c="map -xe n -logic_opt on -retiming on -timing -power off -equivalent_register_removal on -detail -u -p $PLD_DEVICE -cm speed -pr b -k 4 -c 100 -tx off -intstyle xflow -o $TOPNAME"."_map.ncd $TOPNAME.ngd $TOPNAME.pcf";
execute($c);

#
# Command line for Place & Route
#

$c="par -w -intstyle xflow -pl high -rl high -xe n -t 1 $TOPNAME"."_map.ncd $TOPNAME.ncd $TOPNAME.pcf";
execute($c);

#
# Command line for genarate programming file (.bit)
#


foreach (<$TOPNAME"."_pad.txt>) {
    @a=split (/\s*\|\s*/,$_);
    if( ($a[2] ne "" &&
         $a[2] ne "Signal Name") && 
        $a[13] ne "LOCATED"
        ) 
    {
        print "error, pins were assigned automatically:\n$_\n";
        exit;
    }
}

print "_pad.txt tested for automatically assigned pins\n";

#$c="bitgen -w -intstyle ise -g DebugBitstream:No -g Binary:no -g Gclkdel0:11111 -g Gclkdel1:11111 -g Gclkdel2:11111 -g Gclkdel3:11111 -g ConfigRate:4 -g CclkPin:PullUp -g M0Pin:PullUp -g M1Pin:PullUp -g M2Pin:PullUp -g ProgPin:PullUp -g DonePin:PullUp -g TckPin:PullUp -g TdiPin:PullUp -g TdoPin:PullUp -g TmsPin:PullUp -g UnusedPin:PullDown -g UserID:0xFFFFFFFF -g StartUpClk:CClk -g DONE_cycle:4 -g GTS_cycle:5 -g GSR_cycle:6 -g GWE_cycle:6 -g LCK_cycle:NoWait -g Security:None -g DonePipe:No -g DriveDone:No $TOPNAME"; 
$c="bitgen -intstyle ise -w -g DebugBitstream:No -g Binary:no -g CRC:Enable -g ConfigRate:4 -g CclkPin:PullUp -g M0Pin:PullUp -g M1Pin:PullUp -g M2Pin:PullUp -g ProgPin:PullUp -g DonePin:PullUp -g InitPin:Pullup -g CsPin:Pullup -g DinPin:Pullup -g BusyPin:Pullup -g RdWrPin:Pullup -g TckPin:PullUp -g TdiPin:PullUp -g TdoPin:PullUp -g TmsPin:PullUp -g UnusedPin:PullDown -g UserID:0xFFFFFFFF -g DCMShutdown:Disable -g DisableBandgap:No -g DCIUpdateMode:AsRequired -g StartUpClk:CClk -g DONE_cycle:4 -g GTS_cycle:5 -g GWE_cycle:6 -g LCK_cycle:NoWait -g Security:None -g DonePipe:No -g DriveDone:No -g Encrypt:No $TOPNAME.ncd";

execute($c);
#
# Command line for generate .stapl file
#

$c="XIL_IMPACT_ENV_LPT_COMPATIBILITY_MODE=true impact -batch ../impact_batch_vulom3.txt";

execute($c);


#ssh depc152 'cd ~/files/vhdl/xilinx; . ~/bin/xilinx_setup; XIL_IMPACT_ENV_LPT_COMPATIBILITY_MODE=true impact -batch conf_xilinx_impact.txt '

#
#to download file on ETRAX chip
#

#$c="lftp root:pass@hades18;put RPCBoardContrller;exit";
#execute($c)

chdir "..";

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
