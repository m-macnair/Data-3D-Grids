#ABSTRACT: Handle key functions and record overwrite candidates
package Data::3D::Grids::Role::Core;

our $VERSION = '0.05';
##~ DIGEST : 1afe90e159c3ccc4534ee0a8fa74a5eb
use Moo::Role;
use Carp qw/confess cluck/;
use DBI;
use strict;
use warnings;

=head3 set
	Set a coordinate to some value
=cut

sub set {

	my ( $self, $x, $y, $z, $to ) = @_;
	$self->_missing( $x, $y, $z );
	my ( $value, $key ) = $self->process_particle( $to );
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
	if ( ref( $p ) eq 'ARRAY' ) {
		$stack = $p;
	} else {
		$stack = [$p];
	}
	for ( @{$stack} ) {
		my ( $particle, $key ) = $self->process_particle( $_ );
		$self->_get_set_particle( $particle, $key );
	}

}

sub _missing {

	my ( $self, $x, $y, $z ) = @_;
	confess 'Missing $x coordinate' unless defined( $x );
	confess 'Missing $y coordinate' unless defined( $y );
	confess 'Missing $z coordinate' unless defined( $z );

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

1;
