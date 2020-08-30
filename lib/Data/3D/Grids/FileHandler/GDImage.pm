package Data::3D::Grids::FileHandler::GDImage;
our $VERSION = '0.06';
##~ DIGEST : c58878f424056b06854a92e83ed30aca
use Moo;
extends qw/Data::3D::Grids::FileHandler/;
use Carp qw/confess/;
use GD;

# TODO refactor out into generic GD reader, writer has to be PNG apparently

=head3 read
	Turn an image into a cartesian cube element at some z level, default 0
	TODO :
		custom offsets
=cut

sub read {

    my ( $self, $path, $settings ) = @_;
    $settings ||= {};

    #forget what this does
    GD::Image->trueColor(1);
    my $gdig = GD::Image->new($path)
      or confess "failed to parse img ($path) : $!";
    my ( $gdig_x, $gdig_y ) = $gdig->getBounds();
    my ( $x_cursor, $y_cursor ) = ( 0, 0 );
    while ( $x_cursor < $gdig_x ) {
        while ( $y_cursor < $gdig_y ) {
            my ( $r, $g, $b ) =
              $gdig->rgb( $gdig->getPixel( $x_cursor, $y_cursor ) );
            $self->d3g()->set(
                $x_cursor,
                $y_cursor,
                $settings->{z_level} || 0,
                {
                    r => $r,
                    g => $g,
                    b => $b
                }
            );
            $y_cursor++;
        }
        $y_cursor = 0;
        $x_cursor++;
    }

}

sub write {

    my ( $self, $path, $settings ) = @_;
    confess "Must have an upper x boundary to write an image"
      unless $settings->{to}->{x};
    confess "Must have an upper y boundary to write an image"
      unless $settings->{to}->{y};
    confess "Output file name not defined" unless $path;
    my $particle_defs = {};
    use Data::Dumper;
    my $gdi = GD::Image->new( $settings->{to}->{x}, $settings->{to}->{y} );
    $gdi->trueColor(1);

    # TODO enable colour allocation on demand ?
    # TODO persist ?
    $self->d3g->parse_particles(
        sub {
            my ( $def, $id ) = @_;
            for (qw/r g b /) {
                confess
                  "Cannot translate particle $id - doesn't have a $_ value"
                  unless defined( $def->{$_} );
            }
            my $colour = $gdi->colorAllocate( $def->{r}, $def->{g}, $def->{b} );
            $particle_defs->{$id} = $colour;
            return;
        }
    );
    $self->d3g->parse_cube(
        sub {
            my ( $x, $y, $z, $id ) = @_;
        },
        $settings
    );
    open( my $ofh, '>:raw', $path )
      or die "Failed to open output file [$settings->{ofn}] : $!";
    print $ofh $gdi->png();
    close($ofh);
    return;

}
1;
