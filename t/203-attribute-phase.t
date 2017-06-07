#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use lib qw(t/lib);

use Algorithm::NCO;
use Algorithm::NCO::Test qw(new_nco);
use Test::Exception;

use Test::More tests => 5;

lives_ok { new_nco(sample_rate => 1, frequency => 1) } "Built NCO with out specifying phase attribute";
is( new_nco(sample_rate => 1, frequency => 1)->phase, 0, "Default phase is 0");

my $TEST_PHASE1 = .018;
my $TEST_PHASE2 = .171;
my $NCO = new_nco(sample_rate => 1, frequency => 1, phase => $TEST_PHASE1);
is($NCO->phase, $TEST_PHASE1, "phase attribute was set properly during construction");
is($NCO->phase($TEST_PHASE2), $TEST_PHASE2, "phase attribute setter returned correct value");
is($NCO->phase, $TEST_PHASE2, "phase attribute getter returned correct value");
