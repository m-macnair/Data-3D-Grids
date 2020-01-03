package Data::3D::Grids::FileHandler;
our $VERSION = '0.06';
##~ DIGEST : 1fa16750a400cad1750e76532435f2fe
# ABSTRACT: Base class for readers/writers of Grids data
use Moo;
use Carp qw/confess/;
INITPARAMS: {
  OBJECTS: {
        has d3g => ( is => 'rw', required => 1 );
    }
}
1;
