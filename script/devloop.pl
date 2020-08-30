use strict;
use warnings;
use Data::Cartesian::3D::Class::SQLite;
use Data::Dumper;
main(@ARGV);

sub main {

    my ($path) = @_;
    my $start = int(time);
    $path ||= "./etc/example.sqlite";
    my $newpath = "$path." . time;
    `cp $path $newpath`;
    my $dc3 = Data::Cartesian::3D::Class::SQLite->new( { dbfile => $newpath } );
    my $def = {};
    for ( 1 ... 5 ) {
        $def->{$_} = {
            foo => int( rand(40) ),
            bar => int( rand(60) ),
        };
    }
    $dc3->define_particles( [ values( %{$def} ) ] );
    for ( my $x = 0 ; $x < 4 ; $x++ ) {
        for ( my $y = 0 ; $y < 4 ; $y++ ) {
            for ( my $z = 0 ; $z < 4 ; $z++ ) {
                my $id = int( rand(4) ) + 1;
                $dc3->set( $x, $y, $z, $def->{$id} );
            }
        }
    }
    $dc3->done();
    print "took " . ( int(time) - $start ) . " seconds $/";

}
