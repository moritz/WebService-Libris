package WebService::Libris::Book;
use Mojo::Base 'WebService::Libris';
use strict;
use warnings;
use 5.010;

sub fragments {
    'bib', shift->id;
}

sub title { shift->dom->at('title' )->text }
sub isbn  { shift->dom->at('isbn10')->text }
sub date  { shift->dom->at('date'  )->text }

sub related_books { shift->collection_from_dom('frbr_related') }
sub held_by       { shift->collection_from_dom('held_by')      }


1;
