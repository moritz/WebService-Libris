package WebService::Libris::Library;
use Mojo::Base 'WebService::Libris';
use strict;
use warnings;
use 5.010;

__PACKAGE__->_make_text_accessor(qw/name lat long homepage/);

sub fragments {
    'library', shift->id;
}


1;
