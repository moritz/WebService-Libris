use 5.010;
use Test::More tests => 6;
use lib 'blib', 'lib';
use WebService::Libris;
use utf8;
binmode STDOUT, ':encoding(UTF-8)';

ok my $book = WebService::Libris->new(
    type        => 'bib',
    id          => '9604288',
    cache_dir   => 't/data/',

), 'Can get a book by id';

is $book->title, 'Låt den rätte komma in : [skräckroman]', 'title';
is $book->language, 'sv', 'language';
is $book->isbn, '9170370192', 'ISBN';
is join(', ', $book->authors_text),
    'Ajvide Lindqvist, John, 1968-, John Ajvide Lindqvist',
    'Authors (text)';

is join(',', $book->authors_ids), '246603', 'author ids';
