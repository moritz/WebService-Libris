use 5.010;
package WebService::Libris::FileCache;
use Mojo::Base -base;
use Mojo::DOM;

has 'directory';

sub new {
    my $class = shift;
    bless {@_}, $class;
}

sub _filename {
    my ($self, $key) = @_;
    $key =~ s{/}{_}g;
    $self->directory . $key . '.xml'
}

sub get {
    my ($self, $key) = @_;
    my $filename = $self->_filename($key);
    open my $h, '<', $filename;
    return unless $h;
    Mojo::DOM->new(xml => 1, charset => 'UTF-8')->parse(do { local $/; <$h> });
}

sub set {
    my ($self, $key, $value) = @_;
    my $filename = $self->_filename($key);
    open my $h, '>', $filename or die "Can't open file '$filename' for writing: $!";
    print { $h } $value->to_xml;
    close $h;
    $value;
}


1;
