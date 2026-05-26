package ISBN v1.0.0;

use warnings;

use v5.26;

use integer;

use Carp;

use base qw(Exporter);

our %EXPORT_TAGS = (all => [ qw(
    check_sbn
    check_isbn
    isbn10_to_13
    format_isbn13
) ]);

our @EXPORT_OK = $EXPORT_TAGS{all}->@*;
our @EXPORT    = $EXPORT_TAGS{all}->@*;

sub check_sbn {
    my $sbn = shift;

    $sbn =~ s{-}{}g;

    if (length($sbn) == 9) {
        return check_isbn10("0$sbn");
    }

    return;
}

sub check_isbn {
    my $isbn = shift;

    $isbn =~ s{-}{}g;

    return unless $isbn =~ m{^[\dX]+$};

    if (length($isbn) == 10) {
        return check_isbn10($isbn);
    }

    if (length($isbn) == 13) {
        return check_isbn13($isbn);
    }

    return;

#    croak qq{Invalid ISBN length (must be 10 or 13)};
}

sub check_isbn10 {
    my $isbn = shift;

    my @digits = split '', $isbn;

    my $old_check_digit = pop @digits;

    $old_check_digit = 10 if lc($old_check_digit) eq 'x';

    my $new_check_digit = check_digit_10(@digits);

    return $old_check_digit == $new_check_digit;
}

sub check_isbn13 {
    my $isbn = shift;

    my @digits = split '', $isbn;

    my $old_check_digit = pop @digits;

    $old_check_digit = 10 if lc($old_check_digit) eq 'x';

    my $new_check_digit = check_digit_13(@digits);

    return $old_check_digit == $new_check_digit;
}

sub check_digit_10 {
    my @digits = @_;

    my $sum = 0;

    for (my $i = 0; $i < @digits; $i++) {
        $sum += (10 - $i) * $digits[$i];
    }

    my $check_digit = 11 - ($sum % 11);

    $check_digit = 0 if $check_digit == 11;

    return $check_digit;
}

sub check_digit_13 {
    my @digits = @_;

    my @weights = (1, 3) x 6;

    my $sum = 0;

    for (my $i = 0; $i < @digits; $i++) {
        $sum += $weights[$i] * $digits[$i];
    }

    my $check_digit = 10 - ($sum % 10);

    $check_digit = 0 if $check_digit == 10;

    return $check_digit;
}

sub isbn10_to_13 {
    my $isbn10 = shift;

    $isbn10 =~ s{-}{}g;

    if (length($isbn10) != 10) {
        croak qq{Invalid ISBN10 (length): $isbn10};
    }

    my @digits = split '', $isbn10;

    pop @digits;

    unshift @digits, 9, 7, 8;

    push @digits, check_digit_13(@digits);

    return format_isbn13(@digits);
}

sub format_isbn13 {
    my @digits = @_;

    splice @digits, 12, 0, '-';
    splice @digits,  8, 0, '-';
    splice @digits,  4, 0, '-';
    splice @digits,  3, 0, '-';

    return join("", @digits);
}

1;

__END__
