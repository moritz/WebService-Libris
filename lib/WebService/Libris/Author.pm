package WebService::Libris::Author;
use Mojo::Base 'WebService::Libris';
use strict;
use warnings;
use 5.010;

sub fragments {
    'auth', shift->id;
}

sub _description {
    my $self = shift;
    my $url = join '/', $self->fragments;
    $self->dom->at(qq{description[about\$="$url"]}) // Mojo::DOM->new;
}

sub birthyear {
    my $d = shift->_description->at('birthyear');
    $d && $d->text
}

sub libris_key {
    my $d = shift->_description->at('key');
    $d && $d->text
}

sub same_as {
    my $self = shift;
    my $sd = $self->_description->at('sameas');
    if ($sd) {
        return $sd->attrs->{'rdf:resource'};
    }
    return;
}

sub names {
    map $_->text, shift->_description->find('name')->each;
}

1; 
