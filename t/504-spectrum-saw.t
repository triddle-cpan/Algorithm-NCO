#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use lib qw(t/lib);

use Algorithm::NCO;
use Algorithm::NCO::Test qw(is_tolerance is_error create_real_signal fft_real read_refdata get_saw_harmonic_amplitude);
use Data::Dumper;
use List::Util qw(min max);
use Math::Complex;

use Test::More tests => 2;

our $SHAPE = 'saw';

subtest "Validate FFT with real numbers" => \&test_real_spectrum, map { $_->Re } read_refdata($SHAPE);
subtest "Validate NCO with real numbers" => \&test_real_spectrum, create_real_signal($SHAPE);

sub test_real_spectrum {
    plan tests => 4099;

    my @samples = @_;
    my @spectrum = fft_real(@samples);

    is_tolerance(min(@samples), -1, "Peak negative amplitude is with in tolerance");
    is_tolerance(max(@samples), 1, "Peak positive amplitude is with in tolerance");

    # 0hz = DC
    for(my $freq = 0; $freq < @spectrum; $freq++) {
        my $magnitude = abs($spectrum[$freq]);

        if ($freq == 1) {
            is_tolerance(arg($spectrum[$freq]), .5 * pi, "freq:$freq Phase of target frequency is with in tolerance");
        }

        is_tolerance($magnitude, get_saw_harmonic_amplitude($freq), "freq:$freq Amplitude of harmonic is with in tolerance");
    }
}
