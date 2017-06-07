#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use Algorithm::NCO;

my $sample_rate = 8000;
my $sample_count = $sample_rate;
my $shape = 'saw';

my $nco_complex = Algorithm::NCO->new(
    sample_rate => $sample_rate, frequency => 1,
    shape => $shape,
);

my $nco_real = Algorithm::NCO->new(
    sample_rate => $sample_rate, frequency => 1,
    shape => $shape,
);

say "real,i,q";

for my $sample (1 .. $sample_count) {
    my $complex = $nco_complex->complex;

    print $nco_real->real, ',';
    print $complex->Re, ',';
    print $complex->Im, "\n";
}
