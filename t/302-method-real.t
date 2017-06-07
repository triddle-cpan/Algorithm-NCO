#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use lib qw(t/lib);

use Algorithm::NCO;
use Algorithm::NCO::Test qw(new_nco);
use Scalar::Util qw(looks_like_number);
use Test::Exception;

use Test::More tests => 3;

my $nco = new_nco(frequency => 1, sample_rate => 1);
can_ok($nco, 'real');
ok(defined $nco->real, "real method returns a defined value");
ok(looks_like_number($nco->real), "real method returns a number");
