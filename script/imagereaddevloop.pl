use strict;
use warnings;
use Data::Cartesian::3D::Class::SQLite;
use Data::Cartesian::3D::Class::FileHandler::GDImage;
use Data::Dumper;
main( @ARGV );

sub main {

	my ( $db_path, $img_path ) = @_;
	my $start = int( time );
	$db_path ||= "./etc/example.sqlite";
	my $newpath = "$db_path." . time;
	`cp $db_path $newpath`;
	my $dc3  = Data::Cartesian::3D::Class::SQLite->new( {dbfile => $newpath} );
	my $dc3i = Data::Cartesian::3D::Class::FileHandler::GDImage->new( {dc3 => $dc3} );
	$dc3i->read( $img_path );
	$dc3->done();
	print "took " . ( int( time ) - $start ) . " seconds $/";

}
