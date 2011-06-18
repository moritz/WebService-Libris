package WebService::Libris;
use Mojo::Base -base;
use Mojo::UserAgent;
use Mojo::URL;
use WebService::Libris::Collection;

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

Note that this low version number actually reflects the immaturity of this
module - no unit tests yet :(

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use WebService::Libris;
    use 5.010;
    binmode STDOUT, ':encoding(UTF-8)';

    my $book = WebService::Libris->new(
        type => 'book',
        # Libris ID
        id   => '9604288',
    );
    print $book->title;

    my $books = WebService::Libris->search(
        term    => 'Astrid Lindgren',
        page    => 1,
    );
    while (my $b = $books->next) {
        say $b->title;
        say '  isbn: ', $b->isbn;
        say '  date: ', $b->date;
    }

=head1 DESCRIPTION

The Swedish public libraries and the national library of Sweden have a common
catalogue containing meta data of the books they have available.

This includes many contemporary as well as historical books.

The catalogue is available online at L<http://libris.kb.se>, and can be
queried with a public API.

This module is a wrapper around two of their APIs (xsearch and RDF responses).

=head1 METHODS

=head2 new

    my $obj = WebService::Libris->new(
        type => 'author',
        id   => '246603',
    );

Creates an object of the C<WebService::Libris> class or a subclass thereof
(denoted by C<type> in the argument list). C<type> can currently be one of
(synonyms on one line)

    auth author
    bib book
    library

The C<id> argument is mandatory, and must contain the Libris ID of the object
you want to retrieve. If you don't know the Libris ID, use one of the
C<search> functions instead.

=head2 direct_search

    my $hashref = WebService::Libris->direct_search(
        term    => 'Your Searchterms Here',
        page    => 1,   # page size is 200
        full    => 1,   # return all available information
    );

Returns a hashref directly from the JSON response of the xsearch API
described at L<http://librishelp.libris.kb.se/help/xsearch_eng.jsp?open=tech>.

This is more efficient than a C<< WebService::Libris->search >> call, because
it does only one query (whereas C<< ->search >> does one additional request
per result object), but it's not as convenient, and does not allow browsing of
related entities (such as authors and libraries).

=head2 search

    my $collection = WebService::Libris->search(
        term    => 'Your Search Term Here',
        page    => 1,
    );
    while (my $book = $collection->next) {
        say $book->title;
    }

Searches the xsearch API for arbitrary search terms, and returns a
C<WebService::Libris::Collection> of books.

See the C<direct_search> method above for a short discussion.

=head2 search_for_isbn

    my $book = WebService::ISBN->search_for_isbn('9170370192');

Looks up a book by ISBN

=head1 Less interesting methods

The following methods aren't usually useful for the casual user, more
for those who want to extend or subclass this module.

=head2 rdf_url

Returns the RDF resource URL for the current object. Mostly useful for internal purposes.

=head2 dom

Returns the L<Mojo::DOM> object from the web services response.
Does a request to the web service if no DOM was stored previously.

Only useful for you if you want to extract more data from a response
than the object itself provides.

=head2 id

Returns the libris ID of the object. Only makes sense for subclasses.

=head2 type

Returns the short type name (C<bib>, C<auth>, C<library>). Only makes sense
for subclasses.

=head2 fragments

Must be overridden in a subclass to return a list of
the last two junks of the RDF resource URL, that is the short
type name and the libris ID.

=head1 AUTHOR

Moritz Lenz, C<< <moritz at faui2k3.org> >>

=head1 BUGS

Please report any bugs or feature requests at
L<https://github.com/moritz/WebService-Libris/issues>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WebService::Libris

You can also look for information at:

=over 4

=item * Bug tracker:

L<https://github.com/moritz/WebService-Libris/issues>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WebService-Libris>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WebService-Libris>

=item * Search CPAN

L<http://search.cpan.org/dist/WebService-Libris/>

=back

=head1 BUGS AND LIMITATIONS

Nearly no error checking is done. So beware!

=head1 ACKNOWLEDGEMENTS

Thanks go to the Kungliga biblioteket (National Library of Sweden) for
providing the libris.kb.se service and API.

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Moritz Lenz.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut

sub new {
    my ($class, %opts) = @_;;
    my $c;
    if ($opts{type}) {
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


sub rdf_url {
    my $self = shift;
    my ($key, $id) = $self->fragments;
    "http://libris.kb.se/data/$key/$id?format=application%2Frdf%2Bxml";
}

sub dom {
    my $self = shift;

    # TODO: add caching options
    $self->_dom(Mojo::UserAgent->new()->get($self->rdf_url)->res->dom) unless $self->_dom;
    $self->_dom;
}

sub direct_search {
    my ($self, %opts) = @_;
    my $terms = $opts{term} // die "Search term missing";
    my $page  = $opts{page} // 1;
    my %q = (
        query   => $terms,
        n       => 200,     # max. number of results
        start   => 1 + 200 * ($page - 1),
        format  => 'json',
    );
    $q{format_level} = 'full' if $opts{full};
    my $url = Mojo::URL->new('http://libris.kb.se/xsearch');
    $url->query(%q);
    my $res = Mojo::UserAgent->new()->get($url)->res;
    $res->json;
}

sub search {
    my ($self, %opts) = @_;
    my $json = $self->direct_search(%opts);
    my @ids = map { (split '/',  $_->{identifier})[-1] }
                  @{ $json->{xsearch}{list} };
    WebService::Libris::Collection->new(
        type    => 'bib',
        ids     => \@ids,
    );
}

sub search_for_isbn {
    my ($self, $isbn) = @_;
    my $res = Mojo::UserAgent->new->max_redirects(1)
              ->get("http://libris.kb.se/hitlist?q=linkisxn:$isbn");
    my $url = $res->res->headers->location;
    return unless $url;
    my ($type, $libris_id) = (split '/', $url)[-2, -1];
    $self->new(type => $type, id => $libris_id);
}

sub fragments {
    die "Must be overridden in subclasses";
}

sub collection_from_dom {
    my ($self, $search_for) = @_;
    my $key;
    my @ids;
    my $idx = 1;
    $self->dom->find($search_for)->each(sub {
        my $d = shift;
        my $resource_url = $d->attrs->{'rdf:resource'};
        return unless $resource_url;
        my ($k, $id) = $self->fragment_from_resource_url($resource_url);
        if ($idx == 1) {
            $key = $k;
        } elsif ($k ne $k) {
            die "Resource links differ in type ($key vs. $k), can't handle that yet";
        }
        push @ids, $id;
        $idx++;
    });
    WebService::Libris::Collection->new(
        type    => $key,
        ids     => \@ids,
    );
}

sub fragment_from_resource_url {
    my ($self, $url) = @_;
    (split '/', $url)[-2, -1];
}

sub _make_text_accessor {
    my $package = shift;
    for (@_) {
        my ($name, $look_for);
        if (ref($_) eq 'ARRAY') {
            ($name, $look_for) = @$_;
        } else {
            $name     = $_;
            $look_for = $_;
        }
        no strict 'refs';
        *{"${package}::$name"} = sub {
            my $thing;
            ($thing = shift->dom->at($look_for)) && $thing->text;
        };
    }
}


1; # End of WebService::Libris
