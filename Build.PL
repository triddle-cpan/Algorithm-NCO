#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use Module::Build;

my $build = Module::Build->new(
    module_name => 'Algorithm::NCO',
    dist_abstract => 'Pure Perl numerically controlled oscillator',
    dist_author => 'Tyler Riddle <triddle@cpan.org>',
    license => 'perl',
    requires => {
        'perl' => '5.10',
        'Module::Loader' => 0,
        'Moo' => 0,
        'Scalar::Util::Numeric' => 0,
    },
    test_requires => {
        'Audio::SndFile' => 0,
        'Math::FFT' => 0,
        'Scalar::Util' => 0,
        'Statistics::Basic' => 0,
        'Test::Exception' => 0,
        'Test::More' => 0,
    },
);

$build->create_build_script;
