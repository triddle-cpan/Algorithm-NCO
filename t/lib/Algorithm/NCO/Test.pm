package Algorithm::NCO::Test;

use strict;
use warnings;
use v5.10;

use Audio::SndFile;
use Exporter 'import';
use List::Util qw(sum);
use Math::Complex;
use Math::FFT;
use Math::Trig;
use Test::Tolerant;
use Test::More;

BEGIN {
    my $default_tolerance = 1e-3;
    our $TOLERANCE;

    if (exists $ENV{ALGORITHM_NCO_TEST_TOLERANCE}) {
        $TOLERANCE = $ENV{ALGORITHM_NCO_TEST_TOLERANCE};
    } else {
        $TOLERANCE = $default_tolerance;
    }
}

our @EXPORT_OK = qw(
    $TOLERANCE is_tolerance is_error create_real_signal
    create_complex_signal new_nco fft_real fft_complex
    calculate_rms 
    get_square_harmonic_amplitude get_triangle_harmonic_amplitude
    get_saw_harmonic_amplitude
    read_refdata get_refdata_shapes 
);
our @EXPORT = qw( );

our $SAMPLE_COUNT = 8192;
our $FREQUENCY = 1;

sub is_tolerance {
    my ($got, $expected, $msg) = @_;
    our $TOLERANCE;

    $msg .= "; $got = $expected +/- $TOLERANCE";

    my $tol_spec = [$expected, 'plus_or_minus', $TOLERANCE ];
    return is_tol($got, $tol_spec, $msg);
}

sub is_error {
    my ($got, $msg) = @_;
    our $TOLERANCE;

    ok(abs($got) < $TOLERANCE, "$msg; $got < $TOLERANCE");
}

sub create_real_signal {
    my ($shape) = @_;
    my $nco = Algorithm::NCO->new(frequency => $FREQUENCY, sample_rate => $SAMPLE_COUNT, shape => $shape);
    my @signal;

    for (1..$SAMPLE_COUNT) {
        push(@signal, $nco->real);
    }

    return @signal;
}

sub create_complex_signal {
    my ($shape, ) = @_;
    my $nco = Algorithm::NCO->new(frequency => $FREQUENCY, sample_rate => $SAMPLE_COUNT, shape => $shape);
    my @signal;

    for (1..$SAMPLE_COUNT) {
        push(@signal, $nco->complex);
    }

    return @signal;
}

sub new_nco {
    return Algorithm::NCO->new(@_);
}

sub fft_real {
    my (@samples) = @_;
    my $fft = Math::FFT->new(\@samples);
    my @interleaved = @{ $fft->rdft };
    my @spectrum;

    for (my $i = 0; $i < @interleaved; $i += 2) {
        push(@spectrum, Math::Complex->make(
            $interleaved[$i], $interleaved[$i + 1],
        ));
    }

    return map { $_ / @samples * 2 } @spectrum;
}

sub fft_complex {
    my (@samples) = @_;
    my $fft = Math::FFT->new([ map { $_->Re, $_->Im } @samples]);
    my @interleaved = map { $_ / @samples } @{ $fft->cdft };
    my @complex;

    for(my $i = 0; $i < @interleaved; $i += 2) {
        push(@complex, Math::Complex->make($interleaved[$i], $interleaved[$i + 1]));
    }

    return @complex;
}

sub calculate_rms {
    my (@values) = @_;
    my @squares = map { $_ * $_ } @values;
    my $sum = sum(@squares);

    return sqrt($sum / @values);
}

sub get_square_harmonic_amplitude {
    my ($harmonic) = @_;
    #from https://www.allaboutcircuits.com/textbook/alternating-current/chpt-7/square-wave-signals/
    return 4 / pi * (1 / $harmonic);
}

sub get_triangle_harmonic_amplitude {
    my ($harmonic) = @_;
    # from http://www.d.umn.edu/~kulka099/5.pdf
    return 8 / (pi ** 2 * $harmonic ** 2);
}

sub get_saw_harmonic_amplitude {
    my ($harmonic) = @_;
    # from http://pages.uoregon.edu/emi/12.php and http://www.phon.ucl.ac.uk/courses/spsci/acoustics/week1-4.pdf
    return 0 if $harmonic == 0;
    # FIXME What is used to generate this constant?
    return 0.636619787972041 / $harmonic;
}

sub read_refdata {
    my ($shape) = @_;
    my $path = "t/refdata/$shape.wav";
    my $wav = Audio::SndFile->open('<', $path);
    my @samples;

    $wav->subtype eq 'pcm_32' or die "$path: expected single precision float but got " . $wav->subtype;
    $wav->channels == 2 or die "$path: expected 2 channels of data but got " . $wav->channels;
    $wav->samplerate == $SAMPLE_COUNT or die "$path: expected samplerate of $SAMPLE_COUNT but got " . $wav->samplerate;

    while(my @channels = $wav->unpackf_float(1)) {
        push(@samples, Math::Complex->make(@channels));
    }

    @samples == $SAMPLE_COUNT or die "$path: expected $SAMPLE_COUNT samples but got ", scalar(@samples);

    return @samples;
}

sub get_refdata_shapes {
    my $ref_data_dir = 't/refdata/';
    die "Could not open $ref_data_dir: $!" unless opendir(my $dirh, $ref_data_dir);
    my @shape_names;

    while(my $file = readdir($dirh)) {
        next if $file =~ m/^\./;
        next unless $file =~ m/\.wav$/;
        die "regex failure" unless $file =~ m/(\w+)\.wav$/;
        push(@shape_names, $1);
    }

    return sort @shape_names;
}
1;
