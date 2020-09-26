use strict;
use warnings;
use Data::Cartesian::3D::Class::SQLite;
use Data::Cartesian::3D::Class::FileHandler::GDImage;
use Data::Dumper;
main( @ARGV );

sub main {

	my ( $db_path, $img_path ) = @_;
	my $start = int( time );
	$img_path .= '.' . int( time );
	warn $img_path;
	my $dc3  = Data::Cartesian::3D::Class::SQLite->new( {dbfile => $db_path} );
	my $dc3i = Data::Cartesian::3D::Class::FileHandler::GDImage->new( {dc3 => $dc3} );
	$dc3i->write(
		$img_path,
		{
			# 			from => {
			# 				'x' => 3,
			# 				'y' => 3,
			# 				'z' => 3,
			# 			},
			to => {
				'x' => 5,
				'y' => 5,
				'z' => 5,
			}
		}
	);
	$dc3->done();
	print "took " . ( int( time ) - $start ) . " seconds $/";

}
