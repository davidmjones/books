package BIB;

require 5.004;

use strict;

use vars qw(@ISA @EXPORT);

my @BIBs;

my %STRING = (jan => "January",
              feb => "February",
              mar => "March",
              apr => "April",
              may => "May",
              jun => "June",
              jul => "July",
              aug => "August",
              sep => "September",
            "oct" => "October",
              nov => "November",
              dec => "December",
               );

my $PREAMBLE;

sub new
{
    my $type = shift;
    my $self = bless {}, $type;

    push(@BIBs, $self);

    return $self;
}

sub set
{
    my $self = shift;

    my ($key, $value) = @_;

    return unless length($key) && length($value);

    $self->{$key} = $value;
}

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

        s/[\n\t ]+/ /g;
        s/ $//;
        s/^ //;

        while (s/^\@string\{\s*(\S+?)\s*=\s*//i)  {
            $STRING{lc $1} = read_value();
            s/^ *\} *//;
        };

        next unless s/^@\s*(\w+)\s*//;

        my $type = lc $1;

        $_ = read_balanced_string();

        s/(\S+?)\s*,\s*//x or do{
            warn "Bad format(1): [$_]\n";
            next;
        };

        my $key = $1;

        print "$key [$type]\n";

        while (s/^\s* ([\w\-]+) \s* = \s*//x) {
            print "    $1: ", read_value(), "\n";
            s/^\s*$// and next;
            s/^\s*,\s*//  or warn "Expected comma on line $.: [$_]\n";
        }

        print "\n";
    }

    close(BIBFILE);
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

sub output
{
    print "\\begin{enumerate}\n\n";

    for (@BIBs) {
        $_->output_item();
    }

    print "\\end{enumerate}\n";
}

sub output_as_html
{
    for (@BIBs) {
        $_->output_item_as_html();
    }
}

sub bibsort
{
    @BIBs = sort { $a->sort_key() cmp $b->sort_key() } @BIBs;
}

sub sort_key
{
    my $self = shift;

    return $self->{key} if defined $self->{key};

    my $year   = $self->{Y} || 0;
    my $title  = $self->{T};

    my $artist = $title;

    my @artists = @{ $self->{A} };

    if (@artists) {
        for (@artists[1..$#artists]) {
            s/([^,]*), (.*)/$2 $1/;
        }
        $artist    = join(" and ", @artists);
    }

    my $key = sprintf("%-100s %-16s %s", $artist, $year, $title);

    return $self->{key} = $key;
}

sub output_item
{
    my $self = shift;

    return unless defined $self->{T};

    my @artists = @{ $self->{A} };

    my $artist = shift @artists;

    if (@artists) {
        for (@artists) {
            s/([^,]*), (.*)/$2 $1/;
        }

        my $last = pop @artists;

        $artist = join(", ", $artist, @artists);

        $artist .= " and $last";
    }

    my $title     = $self->{T};
    my $publisher = $self->{P};
    my $year      = $self->{Y};
    my $isbn      = $self->{I};
    my $number    = $self->{N};
    my $remark    = $self->{R};

    print "\\item\\relax\n";

    if (defined $artist) {
        print "\\textsc{$artist}";
        print "." unless $artist =~ /\.$/;
        print "\n";
    }

    $title .= "." unless $title =~ /[\.!?]$/;

    print "\\emph{$title}\n";

    print $publisher if defined $publisher;

    if (defined $publisher and defined $year) {
        print ", ";
    }

    $year =~ s/\\noop\{[a-z]\}//;

    print $year if defined $year;
        
    if (defined $publisher or defined $year) {
        print ".\n";
    }

    if (defined $number) {
        $number .= "." unless $number =~ /[\.!?]$/;
        print $number, "\n";
    }

    if (defined $remark) {
        $remark .= "." unless $remark =~ /[\.!?]$/;
        print $remark, "\n";
    }

    print "ISBN $isbn.\n" if defined $isbn;

    print "\n";
}

sub output_item_as_html
{
    my $self = shift;

    return unless defined $self->{T};

    my @artists = @{ $self->{A} };

    foreach my $artist (@artists) {
        $artist = tex_to_html($artist);
    }

    my $artist = shift @artists;

    if (@artists) {
        for (@artists) {
            s/([^,]*), (.*)/$2 $1/;
        }

        my $last = pop @artists;

        $artist = join(", ", $artist, @artists);

        $artist .= " and $last";
    }

    my $title     = tex_to_html($self->{T});
    my $publisher = tex_to_html($self->{P});
    my $year      = $self->{Y};
    my $isbn      = $self->{I};
    my $number    = tex_to_html($self->{N});
    my $remark    = tex_to_html($self->{R});

    print "<p>\n";

    if (defined $artist) {
        print $artist;
        print "." unless $artist =~ /\.$/;
        print "\n";
    }

    print "<cite>$title</cite>";
    print "." unless $title =~ /[\.!?]$/;
    print "\n";

    print $publisher if defined $publisher;

    if (defined $publisher and defined $year) {
        print ", ";
    }

    $year =~ s/\\noop\{[a-z]\}//;

    print $year if defined $year;
        
    if (defined $publisher or defined $year) {
        print ".\n";
    }

    if (defined $number) {
        $number .= "." unless $number =~ /[\.!?]$/;
        print $number, "\n";
    }

    if (defined $remark) {
        $remark .= "." unless $remark =~ /[\.!?]$/;
        print $remark, "\n";
    }

    print "ISBN $isbn.\n" if defined $isbn;

    print "\n";
}

1;

# Keep these lines at the end of the file!
# Local Variables:
# mode: perl
# End:
