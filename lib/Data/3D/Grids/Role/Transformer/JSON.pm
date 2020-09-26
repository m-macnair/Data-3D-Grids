use strict;

package Data::3D::Grids::Role::Transformer::JSON;
our $VERSION = '0.05';
##~ DIGEST : a8732797ec826b86fd358d9675c89a91
use Moo::Role;
use Carp qw/confess/;
use JSON;
use Digest::MD5 qw(md5);
OBJECTS: {
	has json => ( is => 'rw' );
}
after BUILD => sub {
	my ( $self, $args ) = @_;
	my $json;
	if ( $args->{json} ) {
		$json = $args->{json};
	} else {
		$json = JSON->new();
	}

	# this has to be done otherwise a build method would make sense
	$json->canonical( 1 );
	$self->json( $json );
};

=head3 process_particle
	Turn a coordinate's value into something else
=cut

around process_particle => sub {
	shift;

	#we don't care about the original - trying this out
	my $self = shift;
	my ( $to ) = @_;
	confess( "Value sent to process_particle is not a reference and can't be transformed into json" ) unless ref( $to );
	my $jsonstr = $self->json->encode( $to );
	my $md5     = md5( $jsonstr );
	return ( $jsonstr, $md5 );
};
around reverse_particle => sub {
	shift;

	#still don't care about the original
	my $self = shift;
	my ( $value, $key ) = @_;
	my $def = $self->json->decode( $value );
	return ( $def, $key );
};
1;
