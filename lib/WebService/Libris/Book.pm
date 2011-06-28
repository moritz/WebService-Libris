package WebService::Libris::Book;
use Mojo::Base 'WebService::Libris';
use WebService::Libris::Utils qw/marc_lang_code_to_iso/;
use strict;
use warnings;
use 5.010;

__PACKAGE__->_make_text_accessor(qw/title date publisher/, ['isbn', 'isbn10']);

sub fragments {
    'bib', shift->id;
}

sub related_books { shift->list_from_dom('frbr_related') }
sub held_by       { shift->list_from_dom('held_by')      }
sub authors_obj   { shift->list_from_dom('creator')      }

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

sub isbns {
    my $self = shift;
    map $_->text, $self->dom->find('isbn10')->each;
}

sub authors_ids {
    my $self = shift;
    my %seen;
    my @ids = sort
              grep { !$seen{$_}++ }
              map { (split '/', $_)[-1] }
              grep $_,
              map { $_->attrs->{'rdf:resource'} }
              $self->dom->find('creator')->each;
    return @ids;
}

sub language_marc {
    my $self = shift;

    my @l = $self->dom->find('language')->each;
    @l = grep $_, map $_->attrs->{'rdf:resource'}, @l;
    return undef unless @l;

    @l = map { m{http://purl.org/NET/marccodes/languages/(\w{3})(?:\#lang)?} && "$1" } @l;
    # somehow the last language code seems to be more reliable than the first
    # one - no idea why
    return $l[-1] if @l;
    undef;
}

sub language {
    my $self = shift;
    my $marc_lang = $self->language_marc;
    return undef unless defined $marc_lang;
    return marc_lang_code_to_iso($marc_lang);
}

=head1 NAME

WebService::Libris::Book - represents a Book in the libris.kb.se webservice

=head1 SYNOPSIS

    use WebService::Libris;
    for my $b (WebService::Libris->search(term => 'Rothfuss')) {
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

returns the first ISBN

=head2 isbn

returns a list of all ISBNs associated with the current book

=head2 publisher

returns the name of the publisher

=head2 related_books

returns a list of related books

=head2 held_by

returns a list of libraries that hold this book

=head2 authors_obj

returns a list of L<WebService::Libris::Author> objects which are listed
as I<creator> of this book.

=head2 authors_text

returns a list of creators of this book, as extracted from the response.
This often contains duplicates, or slightly different versions of the
same author name, so should be used with care.

=head2 language

Some of the book records include a "MARC" language code (same as the
Library of Congress uses). This methods tries to extract this code, and returns
the equivalent ISO 639 language code (two letters) if the translation is known,
and the marc code otherwise, or undef if no language code was found in the
record.

=head2 language_marc

Returns the language in the three-letter "MARC" code, or undef if no such
code is found.

=cut

1;
