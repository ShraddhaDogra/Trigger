#!/usr/bin/perl
use strict;
#use warnings;
use 5.010;
use Chart::Gnuplot;
use Graphics::GnuplotIF;
use Getopt::Long;
use Data::Dumper qw(Dumper);

my $sourcedata = "ReleaseNotes.tex";
my $outfile = "ReleaseNotesEdited.tex";
my $skip = 1;

open(DATA, "< $sourcedata") || die $!;
open(FILE, "> $outfile") || die $!;

print FILE "% Automatically generated by the scprip trb3/tdc_releases/export_table.pl\n\n\n";

while(my $file = <DATA>)
{
    my @buffer = split(/\s+/, $file);
    
    $skip = 1 if ($buffer[0] eq '\end{document}');

    next if (($buffer[0] ne '\begin{center}') && $skip);
    $skip = 0;
    print FILE "@buffer\n";
}
close(DATA);
close(FILE);
