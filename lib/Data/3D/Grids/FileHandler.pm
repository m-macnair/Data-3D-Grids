package Data::3D::Grids::FileHandler;
our $VERSION = '0.07';
##~ DIGEST : 99b4c4d700a88017b8862bc71a209e0e
# ABSTRACT: Base class for readers/writers of Grids data
use Moo;
use Carp qw/confess/;
INITPARAMS: {
	OBJECTS: {
		has d3g => ( is => 'rw', required => 1 );
	}
}
1;
