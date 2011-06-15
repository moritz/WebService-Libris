package WebService::Libris;
use Mojo::Base -base;
use Mojo::UserAgent;

use 5.010;
use strict;
use warnings;

my %default_typemap = (
    bib     => 'Book',
    book    => 'Book',
    auth    => 'Author',
    author  => 'Author',
    library => 'Library',
);

has 'id';
has 'type';
has '_dom';

has 'type_map';

=head1 NAME

WebService::Libris - Access book meta data from libris.kb.se

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use WebService::Libris;

    my $book = WebService::Libris->new(
        type => 'book',
        # Libris ID
        id   => '9604288',
    );
    print $book->title;

=head1 DESCRIPTION

The Swedish public libraries and the national library of Sweden have a common
catalogue containing meta data of the books they have available.

This includes many contemporary as well as historical books.

The catalogue is available online at L<http://libris.kb.se>, and can be
queried with a public API.

This module is a wrapper around this API, and uses the RDF responses to extract data from.

=head1 METHODS

=head2 new

=cut

sub new {
    my ($class, %opts) = @_;;
    my $c;
    if ($opts{type}) {
        warn "Type: '$opts{type}'";
        if ($opts{type_map}) {
            $c = $opts{type_map}{lc $opts{type}}
                // $default_typemap{lc $opts{type}};
        } else {
            $c = $default_typemap{lc $opts{type}};
        }
    }
    if ($c) {
        $class = __PACKAGE__ . "::" . $c;
        eval "use $class; 1" or die $@;
        return bless \%opts, $class;
    } else {
        return bless \%opts, $class;
    }
}

=head2 rdf_url

Returns the RDF resource URL for the current object.

=cut

sub rdf_url {
    my $self = shift;
    my ($key, $id) = $self->fragments;
    "http://libris.kb.se/data/$key/$id?format=application%2Frdf%2Bxml";
}

=head2 dom

Returns the L<Mojo::DOM> object from the web services response.
Does a request to the web service if no DOM was stored previously

=cut

sub dom {
    my $self = shift;

    # TODO: add caching options
    $self->_dom(Mojo::UserAgent->new()->get($self->rdf_url)->res->dom) unless $self->_dom;
    $self->_dom;
}

sub fragments {
    die "Must be overridden in subclasses";
}

=head1 AUTHOR

Moritz Lenz, C<< <moritz at faui2k3.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-webservice-libris at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WebService-Libris>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WebService::Libris


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-Libris>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WebService-Libris>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WebService-Libris>

=item * Search CPAN

L<http://search.cpan.org/dist/WebService-Libris/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Moritz Lenz.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut

1; # End of WebService::Libris
