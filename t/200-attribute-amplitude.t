#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use lib qw(t/lib);

use Algorithm::NCO;
use Algorithm::NCO::Test qw(new_nco);
use Test::Exception;

use Test::More tests => 8;

lives_ok { new_nco(sample_rate => 1, frequency => 1) } "Built NCO with out specifying amplitude attribute";
lives_ok { new_nco(sample_rate => 1, frequency => 1, amplitude => .25) } "Built NCO with specifying a positive amplitude";
lives_ok { new_nco(sample_rate => 1, frequency => 1, amplitude => 0) } "Built NCO with specifying a 0 amplitude";
dies_ok { new_nco(sample_rate => 1, frequency => 1, amplitude => -1) } "Could not build NCO with a negative amplitude";
is( new_nco(sample_rate => 1, frequency => 1)->amplitude, 1, "Default amplitude is 1");

my $TEST_AMPLITUDE1 = .018;
my $TEST_AMPLITUDE2 = .171;
my $NCO = new_nco(sample_rate => 1, frequency => 1, amplitude => $TEST_AMPLITUDE1);
is($NCO->amplitude, $TEST_AMPLITUDE1, "amplitude attribute was set properly during construction");
is($NCO->amplitude($TEST_AMPLITUDE2), $TEST_AMPLITUDE2, "amplitude attribute setter returned correct value");
is($NCO->amplitude, $TEST_AMPLITUDE2, "amplitude attribute getter returned correct value");
