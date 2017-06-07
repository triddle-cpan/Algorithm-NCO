#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use lib qw(t/lib);

use Algorithm::NCO;
use Algorithm::NCO::Test qw(new_nco);
use Test::Exception;

use Test::More tests => 7;

lives_ok { new_nco(sample_rate => 1, frequency => 1.2) } "Built NCO with positive frequency";
# yes 0 frequency is valid
lives_ok { new_nco(sample_rate => 1, frequency => 0) } "Built NCO with 0 frequency";
# negative frequencies are valid too
lives_ok { new_nco(sample_rate => 1, frequency => -8) } "Built NCO with negative frequency";
dies_ok { new_nco(sample_rate => 1) } "Could not build NCO with out frequency attribute";

my $TEST_FREQ1 = 99;
my $TEST_FREQ2 = 156;
my $NCO = new_nco(sample_rate => 1, frequency => $TEST_FREQ1);
is($NCO->frequency, $TEST_FREQ1, "frequency attribute accessor works after construction");
is($NCO->frequency($TEST_FREQ2), $TEST_FREQ2, "frequency setter returned correct value when setting");
is($NCO->frequency, $TEST_FREQ2, "frequency attribute accessor works after using setter");
