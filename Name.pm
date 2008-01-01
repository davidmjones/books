package Name;

require 5.004;

use strict;

my %IS_AUX = (Bar => 1,
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

    my $name = shift;

    my ($first, $von, $last, $jr) = parse_name($name);

    my $self = bless {
        first => $first,
        last  => $last,
        von   => $von,
        jr    => $jr
        };

    return bless $self, $type;
}

sub is_uppercase
{
    my $string = purify(shift);

    return $string =~ /^[A-Z]/;
}

sub is_lowercase
{
    my $string = purify(shift);

    return $string =~ /^[a-z]/;
}

sub is_particle
{
    my $string = shift;

    return defined $IS_AUX{$string};
}

sub purify
{
    my $string = shift;

    $string =~ s/\\\w+//g;

    $string =~ tr/a-z0-9 //cd;

    $string =~ s/^\s+//;

    return $string;
}

sub first
{
    my $self = shift;

    return $self->{first};
}

sub last
{
    my $self = shift;

    return $self->{last};
}

sub von
{
    my $self = shift;

    return $self->{von};
}

sub jr
{
    my $self = shift;

    return $self->{jr};
}

1;

# Keep these lines at the end of the file!
# Local Variables:
# mode: perl
# End:
