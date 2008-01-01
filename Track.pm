package Track;

require 5.004;

use strict;

use CD.pm qw(:ALL);

@ISA = qw(CD);

sub index_tracks
{
    my $self = shift;

    my @tracks  = @{ $self->{t} };

    push @tracks, @{ $self->{i} };

    push @tracks, split / \\and /, $self->{T};

    foreach my $track (@tracks) {
        my ($composer, $titles) = ($track =~ /\\C\{(.*?)\} (.*)$/);

        foreach my $artist (split / and /, $composer) {

            $artist = $Equiv{$artist} || $artist;

            $artist =~ s/(.*) (\b\S+)$/$2, $1/;

            foreach my $title (split / \\and /, $titles) {
                push @{ $Index{$artist} }, [$title, $self];

##                  new CD unnumbered => 1,
##                         A    => [$artist],
##                         T    => $title,
##                         xref => $self;
            }
        }
    }

    my @artists    = @{ $self->{a} };

    my @conductors = split / and /, $self->{C};

    for my $artist (@artists, @conductors) {
        $artist =~ s/\s+\(.*\)$//;

        $artist = $Equiv{$artist} || $artist;

        unless ($artist =~ s/The +(.*)/$1, The/i || $artist =~ /,/) {
            $artist =~ s/(.*) (\S+)$/$2, $1/;
        }

        push @{ $Artist{$artist} }, $self;
    }
}

sub output_index
{
    my $class = shift;

    print "\\begin{theindex}{Index of Composers}\n\n";

    foreach my $composer (sort keys %Index) {
        output_line "\\item \\artist{$composer}";

        foreach my $track (sort { $a->[0] cmp $b->[0] } @{ $Index{$composer} }) {
            my ($title, $cd) = @{ $track };
            my $refno = $cd->{_refno};

            output_line "\\emph{$title}, $refno.";
        }

        print "\n";
    }

    print "\\end{theindex}\n\n";
}

sub output_artist_index
{
    my $class = shift;

    print "\\begin{theindex}{Index of Artists}\n\n";

    my @artists = map { $_->[1] }
        sort { $a->[0] cmp $b->[0] }
        map { [lc purify($_), $_] }
        keys %Artist;

    foreach my $artist (@artists) {
        output_line "\\item \\artist{$artist}.";

        my $refnos = join ", ", map { $_->{_refno} } @{ $Artist{$artist} };

        output_line $refnos, ".";

        print "\n";
    }

    print "\\end{theindex}\n";
}

sub output_item
{
    my $self = shift;

    next if $self->empty();

    if ($self->{unnumbered}) {
        print "\\cd*\\relax\n";

        my $artist = format_artists @{ $self->{A} };
        my $title  = $self->{T};

        output_line "\\artist{$artist}" if nonnull $artist;
        output_line "\\cdtitle{$title}" if nonnull $title;
        output_line "\\emph{See}~" . $self->{xref}->{_refno};

        print "\n";

        return;
    }

    my $artist    = format_artists    @{ $self->{A} };

    my $performer = format_performers @{ $self->{a} };

    my $editor    = $self->{E};
    my $title     = $self->{T};
    my @tracks    = @{ $self->{t} };
    my $publisher = $self->{P};
    my $year      = $self->{Y};
    my $month     = $self->{M};
    my $isbn      = $self->{I};
    my $number    = $self->{N};
    my $remark    = $self->{R};
    my $series    = $self->{S};
    my $volume    = $self->{V};
    my $numdisks  = $self->{d};
    my $conductor = $self->{C};
    my $orchestra = $self->{o};

    if (nonnull $title) {
        if (@tracks) {
            $title .= ' \\: \\track ' . join(' \; \track ', @tracks);
        }
    } elsif (@tracks) {
        $title = '\\track ' . join(' \; \track ', @tracks);
    }

    print "\\cd\\relax\n";

    output_line "\\artist{$artist}" if nonnull $artist;

    output_line "\\artist{$editor}, ed." if nonnull $editor;

    output_line "\\cdtitle{$title}" if nonnull $title;

    if (defined $series) {
        if (defined $volume) {
            output_line "Volume~$volume of \\emph{$series}";
        } else {
            output_line $series;
        }
    } elsif (defined $volume) {
        output_line "Volume~$volume";
    }

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
