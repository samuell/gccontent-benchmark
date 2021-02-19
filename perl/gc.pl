#!/usr/bin/perl
use strict;
use warnings;

open(my $fh, '<', "chry_multiplied.fa") or die $!;
my $gc = 0;
my $at = 0;
while (my $line = <$fh>) {
    if ($line  =~ /^>/) {
        next;
    }

    $gc += ($line =~ tr/GC//);
    $at += ($line =~ tr/AT//);
}

my $gc_ration = $gc / ($gc + $at);
print "GC ration (gc/gc+at)): $gc_ration\n";