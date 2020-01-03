use strict;

package Data::3D::Grids::Role::Core;
our $VERSION = '0.04';
##~ DIGEST : 404e9b89d25c5352212d77b07b187f38
use Moo::Role;
use Carp qw/confess cluck/;
use DBI;

=head3 set
	Set a coordinate to some value
=cut

sub set {

    my ( $self, $x, $y, $z, $to ) = @_;
    $self->_missing( $x, $y, $z );
    my ( $value, $key ) = $self->process_particle($to);
    $self->_set( $x, $y, $z, $value, $key );

}

sub get {

    my ( $self, $x, $y, $z ) = @_;
    $self->missing( $x, $y, $z );
    return $self->get( $x, $y, $z );

}

=head3 define
	pre-declare particles
=cut

sub define_particles {

    my ( $self, $p ) = @_;
    my $stack;
    if ( ref($p) eq 'ARRAY' ) {
        $stack = $p;
    }
    else {
        $stack = [$p];
    }
    for ( @{$stack} ) {
        my ( $particle, $key ) = $self->process_particle($_);
        $self->_get_set_particle( $particle, $key );
    }

}

sub _missing {

    my ( $self, $x, $y, $z ) = @_;
    confess 'Missing $x coordinate' unless defined($x);
    confess 'Missing $y coordinate' unless defined($y);
    confess 'Missing $z coordinate' unless defined($z);

}

=head3 process_particle
	Turn a coordinate's value into something else
=cut

sub process_particle {

    my ( $self, $to ) = @_;
    return $to, undef;

}

sub reverse_particle {

    my ( $self, $value, $key ) = @_;
    return ( $value, $key );

}

sub done {

    #de nada
}

# REPLACE: {
#
# 	sub _set {
# 		cluck( "Back end has not replaced _set" );
# 	}
#
# 	sub _get {
# 		cluck( "Back end has not replaced _get" );
# 	}
#
# 	sub _delete {
# 		cluck( "Back end has not replaced _delete" );
# 	}
#
# =head3
#
# 	predefine a particle or definition - such as when bulk transforming common href structures
#
# =cut
#
# 	sub _define {
# 		confess( "Back end has not replaced _define" );
# 	}
# }
1;
