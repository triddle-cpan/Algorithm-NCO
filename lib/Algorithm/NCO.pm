package Algorithm::NCO;

our $VERSION = '0.0.1_01';

# TODO
# * Allow generation of more than one sample per
#   method invocation and use the opportunity to
#   increase performance
# * Tests
# * Allow low level parts to be used independently and in
#   an efficient way

use Carp qw(croak);
use Moo;
# FIXME most of the time isnum() should probably be isfloat()
use Scalar::Util::Numeric qw(isnum isint);
use Math::Trig;
use Math::Complex;

# FIXME get rid of RAD
use constant RAD => 2 * pi;

BEGIN {
    use Module::Loader;
    my $loader = Module::Loader->new;

    # Handle the creation of the _rad_wrap() method
    # conditionally. _rad_wrap() takes a value of 0 to N
    # radians and returns the part of the number that is
    # less than 1 radian; in effect it "wraps" a number over
    # so it doesn't grow unbounded over time.
    #
    # Initial testing demonstrates that Math::Trig::rad2rad()
    # is ~ 25% slower than a function calling POSIX::fmod()
    # on my fairly modern 64bit Intel box running Linux.
    # If the POSIX fmod() function is available use that
    # or the Math::Trig rad2rad() function instead

    if (eval { $loader->load('POSIX') }, ! $@) {
        *_rad_wrap = sub { return POSIX::fmod($_[0], 2 * pi) }
    } else {
        *_rad_wrap = \&Math::Trig::rad2rad;
    }
}

# number of samples to generate per second of data
has sample_rate => ( is => 'ro', required => 1, isa => \&_validate_positive_integer );
# desired frequency of the output
# both 0 and negative frequency values are supported
has frequency => ( is => 'rw', required => 1, isa => \&_validate_number );
# value to scale the output by
has amplitude => ( is => 'rw', required => 1, default => sub { 1 }, isa => \&_validate_positive_or_zero );
# the phase accumulator
has phase => ( is => 'rw', required => 1, default => sub { 0 }, isa => \&_validate_phase );
# name of the desired output waveform shape or user defined code ref
has shape => ( is => 'ro', required => 1, default => sub { 'cosine' }, isa => \&_validate_shape );
# reference to function for the phase to amplitude converter
has _generator => ( is => 'lazy', isa => \&_validate_coderef );

# returns either the user defined phase to amplitude
# converter or the PAC that implements the named shape
sub _build__generator {
    my ($self) = @_;
    my $shape = $self->shape;

    if (ref($shape) eq 'CODE') {
        return $shape;
    }

    my $generator = $self->_create_generator_table->{$shape};
    die "expected to find a code reference for generated name '$shape'" unless defined $generator;

    return $generator;
}

sub _validate_coderef {
    my ($value) = @_;

    die "must be a code reference" unless ref($value) eq 'CODE';
}

sub _validate_number {
    my ($value) = @_;

    die "must be defined" unless defined $value;
    die "must be a number" unless isnum($value);
}

sub _validate_positive_or_zero {
    my ($value) = @_;

    return if $value == 0;
    _validate_positive_number($value);
}

sub _validate_positive_number {
    my ($value) = @_;

    _validate_number($value);
    die "must be a positive number" unless $value > 0;
}

sub _validate_positive_integer {
    my ($value) = @_;

    die "must be a positive integer" unless isint($value) == 1 && $value > 0;
}

sub _validate_radian {
    my ($value) = @_;

    die "must be defined" unless defined $value;
    die "must be a number" unless isnum($value);
    die "must be between 0 and 2pi" unless $value >= 0 && $value <= RAD;
}

sub _validate_phase {
    my ($value) = @_;

    die "must be defined" unless defined $value;
    # when running with negative frequencies
    # this can become a negative radian
    # FIXME is that supposed to happen? Why
    # wouldn't the right thing be to wrap around
    # and wind up at the top end of a single radian?
    _validate_radian(abs($value));
}

sub _validate_shape {
    my ($value) = @_;
    my $table = _create_generator_table();

    die "must be defined" unless defined $value;

    return if ref($value) eq 'CODE';

    unless (defined $table->{$value}) {
        my $names = join(' ', shape_names());
        die "invalid name '$value'; try one of $names";
    }
}

# returns the value that is added to the phase accumulator
# for every sample
sub phase_step {
    my ($self) = @_;
    return RAD * ($self->frequency / $self->sample_rate);
}

# adjust the phase accumulator and
# wrap if neccassary
sub adjust_phase {
    my ($self, $delta) = @_;
    my $phase = $self->phase;

    croak "must specify a delta" unless defined $delta;

    # add the delta to the accumulator and wrap it
    return $self->phase(_rad_wrap($phase + $delta));
}

# return a single real value and advance the state
# of the NCO
sub real {
    my ($self) = @_;

    my $sample = $self->_generator->($self->phase);
    $self->adjust_phase($self->phase_step);

    return $sample * $self->amplitude;
}

# return a single complex value and
# advance the state of the NCO
sub complex {
    my ($self) = @_;

    my $i_phase = $self->phase;
    my $q_phase = _rad_wrap($i_phase + .25 * RAD);

    my $amplitude = $self->amplitude;
    my $sample = cplx(
        $self->_generator->($i_phase) * $amplitude,
        $self->_generator->($q_phase) * $amplitude,
    );

    $self->adjust_phase($self->phase_step);

    return $sample;
}

sub quadrature {
    my ($self, $count) = @_;
    my $phase = $self->phase;
    my $amplitude = $self->amplitude;
    my $phase_step = $self->phase_step;
    my @samples;

    $count = 1 unless defined $count;

    for(my $i = 0; $i < $count; $i++) {
        my $i_phase = $phase;
        my $q_phase = _rad_wrap($i_phase + .25 * RAD);

        push(@samples,
            $self->_generator->($i_phase) * $amplitude,
            $self->_generator->($q_phase) * $amplitude,
        );

        $phase = _rad_wrap($phase + $phase_step);
    }

    $self->phase($phase);

    return @samples;
}

# create a list of valid names that can be specified
# for the shape attribute
sub shape_names {
    return sort keys %{ _create_generator_table() };
}

# create a hash reference to a dispatch table
# of phase to amplitude conversion function references
sub _create_generator_table {
    return {
        sine      =>  \&_pac_sine,
        cosine    =>  \&_pac_cosine,
        square    =>  \&_pac_square,
        triangle  =>  \&_pac_triangle,
        saw       =>  \&_pac_saw,
    };
}

# phase to amplitude conversion functions
# see https://commons.wikimedia.org/wiki/File:Waveforms.svg

sub _pac_saw {
    my ($phase) = @_;
    # rotate forward half a phase so the saw starts
    # drawing at 0 with phase 0
    $phase = _rad_wrap($phase + .5 * RAD);
    return ($phase / (RAD)) * 2 - 1;
}

sub _pac_sine {
    my ($phase) = @_;
    return sin($phase);
}

sub _pac_cosine {
    my ($phase) = @_;
    return cos($phase);
}

# A triangle wave moves in
# a straight line
# FIXME there has got to be a
# better way
sub _pac_triangle {
    my ($phase) = @_;

    # rotate forward 90 degrees so the
    # triangle starts at 0 with phase 0
    $phase = _rad_wrap($phase + .25 * RAD);

    # convert from radians
    $phase /= RAD;

    if ($phase < .5) {
        # first half increases in amplitude
        return -1 + 4 * $phase;
    } else {
        # second half decreases in amplitude
        return 1 - 4 * ($phase - .5);
    }
}

# square wave is +1 for the first half of the cycle
# and then -1 for the second half
sub _pac_square {
    my ($phase) = @_;

    if ($phase < pi) {
        return 1;
    }

    return -1;
}

1;