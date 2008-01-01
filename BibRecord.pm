package BibRecord;

require 5.004;

use strict;

use Name;

my @BIBs;

my %AUX = (Bar => 1,
           De  => 1,
           Den => 1,
           Der => 1,
           Di  => 1,
           El  => 1,
           Van => 1,
           Von => 1,
           );

sub new
{
    my $type = shift;

    my $key  = shift;
    my $r_type = shift;

    my $self = bless {}, $type;

    $self->{key}  = $key;
    $self->{type} = $r_type;

    push(@BIBs, $self);

    return $self;
}

sub set
{
    my $self = shift;

    my ($key, $value) = @_;

    return unless length($key) && length($value);

    $self->{lc $key} = $value;
}

1;

# Keep these lines at the end of the file!
# Local Variables:
# mode: perl
# End:
