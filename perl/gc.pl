#!/usr/bin/perl
use strict;
use warnings;

open(my $fh, '<', "chry_multiplied.fa") or die $!;
my $gc = 0;
my $at = 0;
while (<$fh>) {
    next if ($_ =~ /^>/);

    $gc += ($_ =~ tr/GC//);
    $at += ($_ =~ tr/AT//);
}

my $gc_ration = $gc / ($gc + $at);
print "GC ration (gc/gc+at)): $gc_ration\n";