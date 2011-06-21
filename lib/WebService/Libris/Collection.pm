package WebService::Libris::Collection;
use Mojo::Base -base;

require WebService::Libris;

has 'type';
has 'ids';
has 'cache';

sub new {
    my ($class, %attrs) = @_;
    bless \%attrs, $class;
}

sub all {
    my $self = shift;
    map WebService::Libris->new(type => $self->type, id => $_, cache => $self->cache),
        @{ $self->ids };
}

sub first {
    my $self = shift;
    return unless @{ $self->ids };
    WebService::Libris->new(
        type    => $self->type,
        id      => $self->ids->[0],
        cache   => $self->cache,
    );
}

sub next {
    my $self = shift;
    if (@{ $self->ids }) {
        return WebService::Libris->new(
            type    => $self->type,
            id      => shift @{ $self->ids },
            cache   => $self->cache,
        )
    } else {
        return;
    }
}

sub elems {
    scalar @{ shift->ids }
}

=head1 NAME

WebService::Libris::Collection - iterable collection of objects

=head1 SYNOPSIS

    use WebService::Libris;
    my $collection = WebService::Libris->search(term => 'blomkvist');
    while (my $book = $collection->next) {
        # do something with $book
    }

=head1 DESCRIPTION

WebService::Libris::Collection objects hold list of objects of subclasses of
L<WebService::Libris>. It is used instead of arrays because it delays requests
to the libris.kb.se web API until an object is actually access.

=head1 METHODS

=head2 first

Returns the first item

=head2 next

Returns the next item, and removes it from the internal list of items, so that
repeated calls to C<next> iterate over the whole collection

=head2 all

Returns a list of all remaining objects in the collection

=head2 elems

Returns the number of remaining objects in the collection

=cut

1;
