#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use lib qw(t/lib);

use Algorithm::NCO;
use Algorithm::NCO::Test qw(new_nco);
use Test::Exception;

use Test::More tests => 5;

lives_ok { new_nco(sample_rate => 1, frequency => 1) } "Built NCO with out specifying shape attribute";
is( new_nco(sample_rate => 1, frequency => 1)->shape, 'cosine', "Default shape is cosine");
dies_ok { new_nco(sample_rate => 1, frequency => 1, shape => ' bogus') } "Could not set a bad shape name";

my $TEST_SHAPE1 = 'sine';
my $TEST_SHAPE2 = 'triangle';
my $NCO = new_nco(sample_rate => 1, frequency => 1, shape => $TEST_SHAPE1);
is($NCO->shape, $TEST_SHAPE1, "phase attribute was set properly during construction");
dies_ok { $NCO->shape($TEST_SHAPE2) } "shape attribute is read only";
