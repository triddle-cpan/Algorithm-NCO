#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use lib qw(t/lib);

use Algorithm::NCO;
use Algorithm::NCO::Test qw(is_tolerance create_real_signal create_complex_signal read_refdata get_refdata_shapes);
use Math::Complex;

use Test::More tests => 122880;

for my $shape (get_refdata_shapes()) {
    my @ref_complex = read_refdata($shape);
    my @ref_real = map { $_->Re } @ref_complex;
    my @test_complex = create_complex_signal($shape);
    my @test_real = create_real_signal($shape);

    for (my $i = 0; $i < @ref_complex; $i++) {
        my $ref_magnitude = abs($ref_complex[$i]);
        my $test_magnitude = abs($test_complex[$i]);
        my $ref_phase = arg($ref_complex[$i]);
        my $test_phase = arg($test_complex[$i]);

        is_tolerance($test_real[$i], $ref_real[$i], "shape:$shape sample:$i magnitude of real number is with in tolerance");
        is_tolerance($test_magnitude, $ref_magnitude, "shape:$shape sample:$i magnitude of complex number is with in tolerance");
        is_tolerance($test_phase, $ref_phase, "shape:$shape sample:$i phase of complex number is with in tolerance");
    }
}
