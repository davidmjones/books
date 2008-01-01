package DVD;

require 5.004;

use Exporter;

@ISA = qw(Exporter);

@EXPORT = ();

@EXPORT_OK = qw(null nonnull);

%EXPORT_TAGS = (ALL => [@EXPORT_OK]);

use strict;

use IO::Stream;

use HBP::BreakLine;
HBP::BreakLine->set_text_prefix("  ");

my @DVDs;

sub nonnull(;$)
{
    my $object = @_ ? shift : $_;

    return defined $object && $object =~ /\S/;
}

sub null(;$)
{
    my $object = @_ ? shift : $_;

    return not nonnull $object;
}

sub add_period(;$)
{
    my $string = @_ ? shift : $_;

    ## Not quite right: should distinguish between } and \}

    $string .= "." unless $string =~ /[\.!?][\'\}]*$/;

    return $string;
}

sub output_line($)
{
    my $line = shift;

    return unless nonnull $line;

    print scalar breakline add_period $line;

    print "\n";
}

sub new
{
    my $type = shift;
    my $self = bless { @_ }, $type;

    $self->{T} ||= [];
    $self->{R} ||= [];

    push(@DVDs, $self);

    return $self;
}

sub set
{
    my $self = shift;

    my ($key, $value, $lineno) = @_;

    return unless length($key) && length($value);

    if ($key =~ /^[Aait]$/) {
        push(@{ $self->{$key} }, $value);
    } else {
        if (exists $self->{$key}) {
            warn "Field %$key multiply defined", 
                 defined $lineno ? " at line $lineno" : "",
                 "\n";
        }
        $self->{$key} = $value;
    }
}

sub empty
{
    my $dvd = shift;

    return not (exists $dvd->{T});
}

sub count_disks
{
    my $class = shift;

    my $total_disks = 0;
    my $total_sets  = 0;

    my %profile = ();

    foreach my $dvd (@DVDs) {
        next if $dvd->empty();

        my $numdisks = $dvd->{d} || 1;

        $total_sets++;
        $total_disks += $numdisks;

        $profile{ $numdisks }++;
    }

    return ($total_sets, $total_disks, %profile);
}

sub read_db
{
    my $class = shift;

    my $file = shift;

    my $current;

    my $db = new IO::Stream $file, "r" or die "Can't open $file\n";

    local($_);

    while (defined ($_ = $db->read_continued_line())) {

        # Skip comments

        /^%%/ and next;

        # Skip empty fields

        /^%\w$/ and next;

        # Start a new record if necessary

        /^%/ and do {
            $current = new DVD unless defined $current;
        }; 

        # Read a field

        /^%(\w) / and do {
            $current->set($1, $', $db->lineno);
            next;
        };

        # A blank line terminates the current record

        /^\s*$/ and do {
            undef $current;
            next;
        };

        die "Bad line: [$_]";
    }

#    $db->close();
}

sub output
{
    my ($sets, $disks, %profile) = DVD->count_disks();

    print "\\footnotetext[1]{$sets sets/$disks disks}\n\n";

    for (sort { $a <=> $b } keys %profile) {
        my $num = $profile{$_};
        printf "%%%%  %5d %2d disk set%s = %4d\n", $num, $_,
                $num > 1 ? "s" : " ", $num * $_;
    }
    print "\n";

    print "\\begin{enumerate}\n\n";

    for (@DVDs) {
        $_->output_item();
    }

    print "\\end{enumerate}\n";
}

sub bibsort
{
    @DVDs = sort { $a->sort_key() cmp $b->sort_key() } @DVDs;
}

sub purify(;$)
{
    my $string = @_ ? shift : $_;

##      $string =~ s/\\noop\{([^{}]*)\}/$1/g;

    $string =~ s/\\noop\{([^{}]*)\}//g;

    $string =~ s/\\[Cvruck]\b//g;

    $string =~ s/\\track//g;

    $string =~ s/\\emph//g;

    $string =~ tr/a-zA-Z0-9 //cd;

    $string =~ s/\s+/ /;

    $string =~ s/^ | $//g;

    return lc $string;
}

##  Note cleverness with $_ to enable things like
##
##      for (@list) {
##          format_name;
##      }
##
##  to work.

sub format_name(;$)
{
    local ($_) = shift @_ if (@_);

    s/([^,]*), ([^()]*[^ ()])/$2 $1/;

#    s/([^,]*), (.*)/$2 $1/;

    s/^The\b/the/;

    return $_;
}

sub cmp_names($$)
{
    my ($first, $second) = @_;

    for ($first, $second) {
        s/(.*) (\b\S+)$/$2, $1/;
    }

    return $first cmp $second;
}

sub sort_key
{
    my $self = shift;

    return $self->{key} if defined $self->{key};

    my $year    = $self->{Y} || '0000';
    my $month   = month_to_number($self->{M});

    my $title   = purify $self->title;
    my $series  = purify $self->series_and_volume;

    my $date    = purify "$year$month";

    my $artist  = $self->{E} || $title;

    my @artists = @{ $self->{A} };

    if (@artists) {
#        for (@artists[1..$#artists]) {
#            format_name;
#        }

#        $artist = purify join(" and ", map { $Equiv{$_} || $_ } @artists);

        $artist = join(" and ", @artists);
    }

    $artist = $self->{sA} if nonnull $self->{sA};

    $artist = purify $artist;

#    my $key = sprintf("%-100s %-32s %s%s", $artist, $date, $title, $series);

    my $key = sprintf("%-100s %-200s%s %-32s", $artist, $title, $series, $date);

    return $self->{key} = $key;
}

my %months = (jan => '01',
              feb => '02',
              mar => '03',
              apr => '04',
              may => '05',
              jun => '06',
              jul => '07',
              aug => '08',
              sep => '09',
              oct => '10',
              nov => '11',
              dec => '12',
              win => '01',
              spr => '03',
              sum => '06',
              fal => '09',
              );

sub month_to_number
{
    my $month = shift;

    return "00" unless defined $month && length $month;

    my $mon = lc substr($month, 0, 3);

    return $months{$mon} || "00";
}

sub format_list(@)
{
    my @list =  @_;

    my $list = shift @list;

    if (@list) {
        for (@list) {
            format_name;
        }

        my $last = pop @list;

        $list = join(", ", $list, @list);

        $list .= " and $last";
    }

    return $list;
}

sub format_artists(@)
{
    my @artists = @_;

    return format_list @artists;
}

sub format_performers(@)
{
    my @performers = @_;

    $performers[0] = format_name $performers[0];

    my $performer = format_list @performers;

    $performer =~ s/^the\b/The/;

    return $performer;
}

sub title
{
    my $self = shift;

    return $self->{_title} if exists $self->{_title};

    my $title  = $self->{T};
    my $series = $self->{S};
    my $volume = $self->{V};

    my @tracks    = @{ $self->{t} };

    if (nonnull $title && nonnull $volume && null $series) {
        $title .= ", Volume~$volume";
    }

    if (@tracks) {
        if (nonnull $title) {
            $title .= ' \\: ';
        }

        if (@tracks == 1) {
            $title .= shift @tracks;
        } else {
            $title .= '\\track ' . join(' \; \track ', @tracks);
        }
    }

    return $self->{_title} = $title;
}

sub series_and_volume
{
    my $self = shift;

    return $self->{_series} if exists $self->{_series};

    my $title  = $self->{T};
    my $series = $self->{S};
    my $volume = $self->{V};

    my $full_series;

    if (nonnull $title && nonnull $volume && null $series) {
        $volume = undef;
    }

    if (defined $volume) {
        $full_series = "Volume~$volume";
    }

    if (defined $series) {
        $full_series .= " of \\emph{$series}";
    }

    return $self->{_series} = $full_series;
}

sub output_item
{
    my $self = shift;

    next if $self->empty();

    my $artist    = format_artists    @{ $self->{A} };

    my $performer = format_performers @{ $self->{a} };

    my $editor    = $self->{E};
    my $publisher = $self->{P};
    my $year      = $self->{Y};
    my $month     = $self->{M};
    my $isbn      = $self->{I};
    my $number    = $self->{N};
    my $remark    = $self->{R};
    my $volume    = $self->{V};
    my $numdisks  = $self->{d};
    my $comment = $self->{C};
    my $orchestra = $self->{o};

    my $title     = $self->title;
    my $series    = $self->series_and_volume;

    print "\\cd\\relax\n";

    ##  print "%%  Sort key: ", $self->sort_key(), "\n";

    output_line "\\artist{$artist}"      if nonnull $artist;

    output_line "\\artist{$editor}, ed." if nonnull $editor;

    output_line "\\cdtitle{$title}"      if nonnull $title;

    output_line $series;

    output_line $performer;

    output_line $orchestra;

    output_line "$conductor, cond." if nonnull $conductor;

    print $publisher if nonnull $publisher;

    print ", " if (defined $publisher and defined $year);

    print "$month " if defined $month;

    $year =~ s/\\noop\{[a-z]\}//;

    print $year if defined $year;
        
    if (defined $number) {
        print " \\cdnum", $numdisks > 1 ? "[$numdisks]" : "", "{$number}";
    } elsif (defined $isbn) {
        print " ($isbn)";
    }

    print ".\n" if (defined $publisher or defined $year or defined $number);

    output_line $remark;

##      print "ISBN $isbn.\n" if defined $isbn;

    print "\n";
}

1;

# Keep these lines at the end of the file!
# Local Variables:
# mode: perl
# End:
