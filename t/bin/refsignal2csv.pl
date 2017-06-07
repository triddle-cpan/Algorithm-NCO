#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use Audio::SndFile;

my $input = Audio::SndFile->open('<', shift(@ARGV));

say "i,q";

while(1) {
    my @values = $input->unpackf_float(1);
    last unless @values;

    say join(',', @values);
}
