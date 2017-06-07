#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use lib qw(t/lib);

use Algorithm::NCO;
use Algorithm::NCO::Test qw(is_tolerance is_error create_real_signal fft_real read_refdata get_triangle_harmonic_amplitude);
use Data::Dumper;
use Math::Complex;

use Test::More tests => 2;

our $SHAPE = 'triangle';

subtest "Validate FFT with real numbers" => \&test_real_spectrum, map { $_->Re } read_refdata($SHAPE);
subtest "Validate NCO with real numbers" => \&test_real_spectrum, create_real_signal($SHAPE);

sub test_real_spectrum {
    plan tests => 4097;

    my @samples = @_;
    my @spectrum = fft_real(@samples);

    # 0hz = DC
    for(my $freq = 0; $freq < @spectrum; $freq++) {
        my $magnitude = abs($spectrum[$freq]);

        if ($freq == 1) {
            is_tolerance(arg($spectrum[$freq]), .5 * pi, "freq:$freq Phase of target frequency is with in tolerance");
        }

        if ($freq %2 == 0) {
            is_error($spectrum[$freq], "freq:$freq Amplitude of non-harmonic frequency was in tolerance");
        } else {
            is_tolerance($magnitude, get_triangle_harmonic_amplitude($freq), "freq:$freq Amplitude of harmonic is with in tolerance");
        }
    }
}
