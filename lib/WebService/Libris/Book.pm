package WebService::Libris::Book;
use Mojo::Base 'WebService::Libris';
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

1;
