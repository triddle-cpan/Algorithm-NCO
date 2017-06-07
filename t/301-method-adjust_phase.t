#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use lib qw(t/lib);

use Algorithm::NCO;
use Algorithm::NCO::Test qw(new_nco);
use Math::Trig;
use Scalar::Util qw(looks_like_number);
use Test::Exception;

use Test::More tests => 3;

my $nco = new_nco(frequency => 1, sample_rate => 1);
can_ok($nco, 'adjust_phase');
dies_ok { $nco->adjust_phase } "adjust_phase requires an argument";

$nco->phase(0);
$nco->adjust_phase(pi);
is($nco->phase, pi, "Successfully adjusted phase");
