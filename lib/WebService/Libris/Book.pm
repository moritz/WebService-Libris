package WebService::Libris::Book;
use Mojo::Base 'WebService::Libris';
use WebService::Libris::Utils qw/marc_lang_code_to_iso/;
use strict;
use warnings;
use 5.010;

__PACKAGE__->_make_text_accessor(qw/title date/, ['isbn', 'isbn10']);

sub fragments {
    'bib', shift->id;
}

sub related_books { shift->collection_from_dom('frbr_related') }
sub held_by       { shift->collection_from_dom('held_by')      }
sub authors_obj   { shift->collection_from_dom('creator')      }
sub authors_text  {
    my $self = shift;
    my @authors = grep length, map $_->text, $self->dom->find('creator')->each;
    # XXX: come up with something better
    if (wantarray) {
        return @authors;
    } elsif (@authors == 1) {
        return $authors[0]
    } else {
        return join ", ", @authors;
    }
}

sub language {
    my $self = shift;
    my $l = $self->dom->at('language');
    return unless $l;
    $l = $l->attrs->{'rdf:resource'};
    if ($l =~ m{http://purl.org/NET/marccodes/languages/(\w{3})(?:\#lang)?}) {
        return marc_lang_code_to_iso($1);
    } else {
        return;
    }
}

=head1 NAME

WebService::Libris::Book - represents a Book in the libris.kb.se webservice

=head1 SYNOPSIS

    use WebService::Libris;
    for my $b (WebService::Libris->search(term => 'Rothfuss')->all) {
        # $b is a WebService::Libris::Book object here
        say $b->title;
        say $b->isbn;
    }

=head1 DESCRIPTION

C<WebService::Libris::Book> is a subclass of C<WebService::Libris> and
inherits all its methods.

All of the following methods return undef or the empty list if the information is not available.

=head1 METHODS

=head2 title

returns the title of the book

=head2 date

returns the publication date as a string (often just a year)

=head2 isbn

returns the ISBN

=head2 related_books

returns a collection of related books

=head2 held_by

returns a collection of libraries that hold this book

=head2 authors_obj

returns a collection of L<WebService::Libris::Author> objects which are listed
as I<creator> of this book.

=head2 authors_text

returns a list of creators of this book, as extracted from the response.
This often contains duplicates, or slightly different versions of the
same author name, so should be used with care.

=cut

1;
