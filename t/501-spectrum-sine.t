#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use lib qw(t/lib);

use Algorithm::NCO;
use Algorithm::NCO::Test qw(is_tolerance create_real_signal fft_real read_refdata);
use Data::Dumper;
use Math::Complex;

use Test::More tests => 2;

our $SHAPE = 'sine';

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
            is_tolerance($magnitude, 1, "freq:$freq Amplitude of target frequency is with in tolerance");
            is_tolerance(arg($spectrum[$freq]), .5 * pi, "freq:$freq Phase of target frequency is with in tolerance");
        } else {
            is_tolerance($magnitude, 0, "freq:$freq Amplitude of non-target frequency is with in tolerance");
        }
    }
}
