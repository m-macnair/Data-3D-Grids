package Data::3D::Grids::SQLiteJSON;
our $VERSION = '0.04';
##~ DIGEST : 8fcdeea9e457bc04c532400ef3c4ef0a
use Moo;
use Carp qw/confess/;
use DBI;
with qw/
  Data::3D::Grids::Role::Core
  Data::3D::Grids::Role::Backend::SQL
  Data::3D::Grids::Role::Transformer::JSON
  /;
CONFIGS: {
	has dbfile => ( is => 'rw' );
	has dsn    => ( is => 'rw' );
}

sub BUILD {

	my ( $self, $args ) = @_;
	my $dbh;
	if ( $args->{dsn} ) {
		$dbh = DBI->connect( $args->{dsn} );
	} else {
		confess( "No dbfile or dsn provided - no connection!" )
		  unless $args->{dbfile};
		my $pre_exists = -f $args->{dbfile};
		$dbh = DBI->connect( "dbi:SQLite:dbname=$args->{dbfile}", "", "" );
		if ( $pre_exists ) {

			#de nada
		} else {
			$self->_init_sqliteschema( $dbh );
		}
	}
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	$self->dbh( $dbh );

}

sub _init_sqliteschema {

	my ( $self, $dbh ) = @_;
	$dbh->do( "CREATE TABLE grids ( id INTEGER PRIMARY KEY, x INTEGER , y INTEGER, z INTEGER, particle_id INTEGER );" ) or die $DBI::errstr;
	$dbh->do( "	CREATE TABLE particles ( id INTEGER PRIMARY KEY, key BLOB, particle TEXT );" )                          or die $DBI::errstr;
	$dbh->do( "CREATE INDEX x_index on grids(x);" )                                                                     or die $DBI::errstr;
	$dbh->do( "CREATE INDEX y_index on grids(y);" )                                                                     or die $DBI::errstr;
	$dbh->do( "CREATE INDEX z_index on grids(z);" )                                                                     or die $DBI::errstr;
	$dbh->do( "CREATE INDEX key_index on particles(key);" )                                                             or die $DBI::errstr;
	$dbh->commit() unless $dbh->{AutoCommit};

}
1;
