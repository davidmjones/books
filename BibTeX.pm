package BibTeX;

require 5.004;

use strict;

use Name;

my %STRING = (jan => "January",
              feb => "February",
              mar => "March",
              apr => "April",
              may => "May",
              jun => "June",
              jul => "July",
              aug => "August",
              sep => "September",
              oct => "October",
              nov => "November",
              dec => "December",
               );

my $PREAMBLE;

sub read_db
{
    my $pkg = shift;

    my $file = shift;

    local $/ = '';

    local *BIBFILE;

    open(BIBFILE, $file);

    ## Assumes entries come "one per paragraph", but that's fine for now.

    while (<BIBFILE>) {
        chomp;

        $_ = fix_spaces($_);

        while (s/^\@\s*string\s*\{\s*(\S+?)\s*=\s*//i)  {
            $STRING{lc $1} = read_value();
            s/^ *\} *//;
        };

        while (s/^\@\s*preamble\s*//i)  {
            $PREAMBLE .= read_value();
        };

        s/^@\s*// and read_record(); }

    close(BIBFILE);
}

sub read_record
{
    s/(\w+)\s*//;

    my $type = lc $1;

    $_ = read_balanced_string();

    s/(\S+?)\s*,\s*//x or do{
        warn "Bad format(1): [$_]\n";
        next;
    };

    my $key = $1;

    my $current = new BIB $key, $type;

    while (s/^\s* ([\w\-]+) \s* = \s*//x) {
        $current->set($1, read_value());
        s/^\s*$// and next;
        s/^\s*,\s*//  or warn "Expected comma on line $.: [$_]\n";
    }
}

sub read_value
{
    my $string = read_token();

    while (s/^ ?\# ?//) {
        $string .= read_token();
    }

    return $string;
}

sub read_token
{
    s/^\s*//;

    /^\{/          and return read_balanced_string();

    /^"/           and return read_quoted_string();

    s/^(\d+)//     and return $1;

    s/^([\w\-]+)// and do {
        return $STRING{lc $1} if defined $STRING{lc $1};
        warn "Unknown string $1";
        return $1;
    };

    die "Bad format(2): $_";
}

sub read_quoted_string
{
    return undef unless s/^\"//;

    my $result = "";

    while (/\"/) {
        $result .= $`;
        $_ = $';
        last unless $result =~ /\\$/;
        $result .= '"';
    }

    return $result;
}

sub read_balanced_string
{
    return undef unless /^[\{\(]/;

    my ($open, $close);
    
    s/^([\{\(])// and do {
        $open = $1;
        if ($open eq '{') {
            $close = '}';
        } else {
            $close = ')';
        }
    };

    my $count = 1;

    my $result = "";

    while ($count > 0 && /[$open$close]/) {
        $result .= $`;
        if ($& eq $open) {
            $count++;
        } else {
            $count--;
        }
        if ($count) {
            $result .= $&;
        }
        $_ = $';
    }

    return $result;
}

###########################################################################

sub process
{
    for (@BIBs) {
        $_->process_item_2();
    }
}

sub process_item_2
{
    my $self = shift;

    my %value = %{ $self };

    print "citekey: $value{key}\n";

    my @names = parse_names($value{author});

    for (@names) {
        printf "    F[%s] V[%s] L[%s] J[%s]\n", @{ $_ };
    }

    print "\n";
}

sub process_item
{
    my $self = shift;

    my %value = %{ $self };

    print "citekey: $value{key}\n";
    print "type: $value{type}\n";

    my @authors = split(/ and /, $value{author});

    foreach my $author (@authors) {
        my $name = new Name $author;
        printf "Author: F[%s] V[%s] L[%s] J[%s]\n", $name->first(),
        $name->von(), $name->last(), $name->jr();
    }

    delete @value{'key', 'type', 'author'};

    while (my ($key, $value) = each %value) {
        print "$key: $value\n";
    }

    print "\n";
}

sub parse_names
{
    my @tokens = tokenize_string(shift);

    for (@tokens) {
        print "    [$_]\n";
    }

    print "\n";

    my @names = ();

    my @name = shift @tokens;

    my $commas = 0;

    push(@tokens, "and");

    for (@tokens) {
        /^and$/i and do {
            push(@names, [parse_name($commas, @name)]);
            $commas = 0;
            @name = ();
            next;
        };

        push(@name, $_);

        $commas++ if /^, ?$/;
    }

    return @names;
}

sub parse_name
{
    my ($commas, @tokens) = @_;

    if ($commas > 2) {
        warn "Too many commas in name ", join(" ", @tokens), "\n";
    }

    my ($first, $von, $last, $jr);

    $commas == 2 and do {

        my $token;

        while (is_particle($token = shift @tokens)) {
            $von .= $token;
        }

        while ($token !~ /^, ?/) {
            $last .= $token;
            $token = shift @tokens;
        }

        while ($token !~ /^, ?/) {
            $jr .= $token;
            $token = shift @tokens;
        }

        $first = join(" ", @tokens);

        return ($first, $von, $last, $jr);
    };

    $commas == 1 and do {

        my $token;

        while (is_particle($token = shift @tokens)) {
            $von .= $token;
        }

        while ($token !~ /^, ?/) {
            $last .= $token;
            $token = shift @tokens;
        }

        $first = join(" ", @tokens);

        return ($first, $von, $last, $jr);
    };

    my $token;

    my @first;

    while ($token = shift @tokens) {
        last if is_particle($token);
        push(@first, $token);
    }

    my @von;

    while (is_particle($token)) {
        push(@von, $token);
        $token = shift @tokens;
    }

    my @last;

    if (length($token)) {
        push(@last, $token);
    }

    if (@tokens) {
        push(@last, @tokens);
    }

    if (!@last) {
        if (@von) {
            push(@last, pop @von);
        } elsif (@first) {
            push(@last, pop @first);
        }
    }

    $first = join(" ", @first);

    $von = join(" ", @von);

    $last = join(" ", @last);

    return ($first, $von, $last, $jr);
}

sub tokenize_string
{
    local($_) = fix_spaces(shift);

    # By putting a sentinel space at the end of the string, we avoid
    # having to special-case the last token.

    $_ .= " ";

    my @tokens;

    my $token;

    while (/ |, ?|\{/) {

        my $delim = $&;

        $delim eq '{' and do {
            $token .= $`;
            $_ = "$delim$'";
            $token .= "{" . read_balanced_string() . "}";
            next;
        };

        push(@tokens, $token . $`);

        $_ = $';

        $delim =~ /,/ and push(@tokens, $delim);

        $token = "";
    }

    return @tokens;
}

sub fix_spaces
{
    my $string = shift;

    $string =~ s/[\n\t ]+/ /g;
    $string =~ s/^ //;
    $string =~ s/ $//;

    return $string;
}

##  sub bibsort
##  {
##      @BIBs = sort { $a->sort_key() cmp $b->sort_key() } @BIBs;
##  }

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

    my $value = length($string) && (defined($AUX{$string}) || is_lowercase($string));

    return $value;
}

sub purify
{
    my $string = shift;

    $string =~ s/\\\w+//g;

    $string =~ tr/a-zA-Z0-9 //cd;

    $string =~ s/^\s+//;

    return $string;
}

1;

# Keep these lines at the end of the file!
# Local Variables:
# mode: perl
# End:
