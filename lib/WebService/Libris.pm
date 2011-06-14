package WebService::Libris;
use Mojo::Base -base;

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
has 'what';

has 'type_map';

=head1 NAME

WebService::Libris - Access book meta data from libris.kb.se

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use WebService::Libris;

    my $book = WebService::Libris->new(
        what => 'book',
        # Libris ID
        id   => '9604288',
    );
    print $book->title;


=head1 METHODS

=head2 new

=cut

sub new {
    my ($class, %opts) = @_;;
    if ($opts{type}) {
        if ($opts{type_map}) {
            $class = $opts{type_map}{$opts{type}}
                // $default_typemap{$opts{type}};
        } else {
            $class = $default_typemap{$opts{type}};
        }
    }
    if ($class) {
        return bless \%opts;
    } else {
        die "Don't know what do with type '$opts{type}'\n";
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

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of WebService::Libris
