package Mojolicious::Plugin::DumpyLog;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
    my ( $self, $app, $opts ) = @_;
    logger_methods: {
        do { my $method = $_;
        $app->helper( $method => sub {
            my ( $c, @args ) = @_;

            my $dump = pop @args if ref $args[ -1 ];
            my $name = ref $c eq 'Mojolicious::Controller' ? ref $c->app : ref $c;

            $app->log->$method( $name .' - '. join ', ', grep { defined } @args );
            $app->log->$method( $c->dumper( $dump ) ) if $dump;
        } ) } for qw/debug error fatal info log warn/; # proxy over the base logger methods
    };
}

# ABSTRACT: Automatically runs Data::Dumper against the last element in the list passed to any ->log->method() if it's a ref.
1;

=head1 SYNOPSIS

    package App;
    use Mojo::Base 'Mojolicious';

    sub startup {
        my $self = shift;

        $self->plugin( 'Mojolicious::Plugin::DumpyLog' );
        # ...
    }

then

    package App::Example;
    use Mojo::Base 'Mojolicious::Controller';

    sub test {
        my $self = shift;
        my %foo = ( bar => 'baz' );
        $self->debug( "foo", "bar", "baz", \%foo );
        $self->render( json => [] );
    }

=cut
