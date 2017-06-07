#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use lib qw(t/lib);

use Algorithm::NCO;
use Algorithm::NCO::Test qw(new_nco);
use Test::Exception;

use Test::More tests => 11;

my %expected = map { $_ => 1 } qw( cosine saw sine square triangle );
my $nco = new_nco(frequency => 1, sample_rate => 1);
my @shapes = $nco->shape_names;

for my $shape (@shapes) {
    ok(exists $expected{$shape}, "$shape is an expected shape name");
    delete $expected{$shape};
}

ok(keys %expected == 0, "All expected shape names were present");

for my $shape (@shapes) {
    lives_ok{ new_nco(frequency => 1, sample_rate => 1, shape => $shape) } "Built NCO with shape $shape";
}