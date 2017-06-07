#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use lib qw(t/lib);

use Algorithm::NCO;
use Algorithm::NCO::Test qw(new_nco);
use Test::Exception;

use Test::More tests => 6;

lives_ok { new_nco(sample_rate => 1, frequency => 1) } "Built NCO with positive integer sample rate";
dies_ok { new_nco(sample_rate => 0, frequency => 1) } "Could not build NCO with 0 sample rate";
dies_ok { new_nco(sample_rate => -1, frequency => 1) } "Could not build NCO with negative sample rate";
dies_ok { new_nco(sample_rate => 1.2, frequency => 1) } "Could not build NCO with floating point sample rate";
dies_ok { new_nco(frequency => 1) } "Could not build NCO with out sample_rate attribute";

my $TEST_SAMPLE_RATE = 150;
my $NCO = Algorithm::NCO->new(sample_rate => $TEST_SAMPLE_RATE, frequency => 1);
is($NCO->sample_rate, $TEST_SAMPLE_RATE, "sample_rate attribute accessor works");
