package WebService::Libris::Collection;
use Mojo::Base -base;

require WebService::Libris;

has 'type';
has 'ids';

sub new {
    my ($class, %attrs) = @_;
    bless \%attrs, $class;
}

sub all {
    my $self = shift;
    map WebService::Libris->new(type => $self->type, id => $_),
        @{ $self->ids };
}

sub first {
    my $self = shift;
    return unless @{ $self->ids };
    WebService::Libris->new(
        type => $self->type,
        id   => $self->ids->[0],
    );

}

sub next {
    my $self = shift;
    if (@{ $self->ids }) {
        return WebService::Libris->new(
            type => $self->type,
            id => shift @{ $self->ids },
        )
    } else {
        return;
    }
}

1;
