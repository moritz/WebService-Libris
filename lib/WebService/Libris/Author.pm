package WebService::Libris::Author;
use Mojo::Base 'WebService::Libris';
use strict;
use warnings;
use 5.010;

sub fragments {
    'auth', shift->id;
}


1;
