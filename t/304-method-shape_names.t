#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use lib qw(t/lib);

use Algorithm::NCO;
use Algorithm::NCO::Test qw(new_nco);

use Test::More tests => 2;

can_ok(new_nco(frequency => 1, sample_rate => 1), 'shape_names');
my @shapes = new_nco(frequency => 1, sample_rate => 1)->shape_names;

ok(@shapes > 1, "shape_names returned a list with more than 1 thing");
