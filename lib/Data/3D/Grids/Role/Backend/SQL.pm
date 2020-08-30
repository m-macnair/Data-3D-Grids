package Data::3D::Grids::Role::Backend::SQL;
our $VERSION = '0.04';
##~ DIGEST : 774d8bdb1da3cb1c114981212ce949d5
use Moo::Role;
use Carp qw/confess/;
OBJECTS: {
    has dbh => ( is => 'rw' );
    has dbh_autocommit =>
      ( is => 'rw', lazy => 1, builder => '_dbh_autocommit' );
    has sql_abstract =>
      ( is => 'rw', lazy => 1, builder => '_build_sql_abstract' );
}
STHS: {
    for my $accessor (
        qw/set get del get_particle set_particle del_particle get_all_particles /
      )
    {
        has "$accessor\_sth" =>
          ( is => 'rw', builder => "_build_$accessor\_sth", lazy => 1 );
    }
}
ACCESSORS: {
    has commit_counter => ( is => 'rw', default => 0 );
    has commit_limit   => ( is => 'rw', default => 1000 );
}
SUBMODIFIERS: {

    # This is the first time I really *get* the value of Moo/se
    around define_particles => sub {
        my ( $orig, $self, $p ) = @_;
        my $old_commit = $self->dbh->{AutoCommit};
        $self->dbh->{AutoCommit} = 0;
        $self->$orig($p);
        $self->commit();
        $self->dbh->{AutoCommit} = $old_commit;
    };
    around set => sub {
        my $orig = shift;
        my $self = shift;
        $self->$orig(@_);
        $self->commit_maybe();
    };
    after done => sub {
        my $self = shift;
        $self->dbh->commit() unless $self->dbh->{AutoCommit};
        $self->commit_counter(0);
    };
}

sub _set {

    my ( $self, $x, $y, $z, $particle, $key ) = @_;
    $self->del_sth->execute( $x, $y, $z );

    # TODO cache  ids
    $self->get_particle_sth->execute($key);
    my $p_row = $self->_get_set_particle( $particle, $key );
    $self->set_sth->execute( $x, $y, $z, $p_row->{id} );

}

=head3 parse_particles
	For all particles, do something - typically translation of some kind
=cut

sub parse_particles {

    my ( $self, $sub ) = @_;
    $self->get_all_particles_sth()->execute();
    while ( my $row = $self->get_all_particles_sth()->fetchrow_hashref() ) {
        last
          if &$sub( $self->reverse_particle( $row->{particle}, $row->{id} ) );
    }

}

=head3 parse_cube
	For a 'from' and a 'to' of grid coordinates, do something on each element, processing to an end if none are given
	Uses SQL abstract in this case because i'm not completely a masochist
=cut

sub parse_cube {

    my ( $self, $sub, $p ) = @_;
    my $where = {};
    for my $coord (qw/x y z /) {
        $where->{$coord}->{'>='} = $p->{from}->{$coord} if $p->{from}->{$coord};
        $where->{$coord}->{'<='} = $p->{to}->{$coord}   if $p->{to}->{$coord};
    }

    # TODO use arrays instead
    my ( $qstring, @params ) =
      $self->sql_abstract->select( 'grids', ['*'], $where );
    my $select_sth = $self->dbh->prepare($qstring);
    $select_sth->execute(@params);
    while ( my $row = $select_sth->fetchrow_hashref() ) {
        last if &$sub( $row->{x}, $row->{y}, $row->{z}, $row->{particle_id} );
    }

}

sub _delete {

}

sub _get_set_particle {

    my ( $self, $particle, $key ) = @_;
    my $p_row = $self->get_particle_sth->fetchrow_hashref();
    unless ($p_row) {
        $self->set_particle_sth->execute( $particle, $key );
        $self->get_particle_sth->execute($key);
        $p_row = $self->get_particle_sth->fetchrow_hashref();
    }
    return $p_row;

}

sub commit_maybe {

    my ($self) = @_;

    if ( $self->dbh_autocommit() == -1 ) {
        my $c = $self->commit_counter();
        $c++;
        if ( $c > $self->commit_limit() ) {

            $self->commit();
        }
        else {
            $self->commit_counter($c);
        }
    }

}

sub commit {

    my ($self) = @_;
    unless ( $self->dbh->{AutoCommit} ) {
        $self->dbh->commit();

    }
    $self->commit_counter(0);

}

sub _dbh_autocommit {
    my ($self) = @_;

#tests indicate getting {AutoCommit} from the dbh object actually adds something close to 20% runtime

    if ( $self->dbh()->{AutoCommit} ) {
        return 1;
    }
    return -1;

}

BUILD: {
  OBJECT: {

        sub _build_sql_abstract {

            require SQL::Abstract;
            return SQL::Abstract->new();

        }
    }
  STHBUILDERS: {
      GRIDS: {

            sub _build_set_sth {

                my ($self) = @_;
                my $sth = $self->dbh->prepare(
                    "insert into grids (x,y,z,particle_id) values (?,?,?,?) ")
                  or die $DBI::errstr;
                return $sth;

            }

            sub _build_get_sth {

                my ($self) = @_;
                my $sth = $self->dbh->prepare(
                    "select * from grids where x = ? and y = ? and z = ?")
                  or die $DBI::errstr;
                return $sth;

            }

            sub _build_del_sth {

                my ($self) = @_;
                my $sth = $self->dbh->prepare(
                    "delete from grids where x = ? and y = ? and z = ?")
                  or die $DBI::errstr;
                return $sth;

            }
        }
      PARTICLES: {

            sub _build_set_particle_sth {

                my ($self) = @_;
                my $sth = $self->dbh->prepare(
                    "insert into particles (particle,key) values (?,?) ")
                  or die $DBI::errstr;
                return $sth;

            }

            sub _build_get_particle_sth {

                my ($self) = @_;
                my $sth =
                  $self->dbh->prepare("select * from particles where key = ?")
                  or die $DBI::errstr;
                return $sth;

            }

            sub _build_del_particle_sth {

                my ($self) = @_;
                my $sth =
                  $self->dbh->prepare("delete from particles where key = ?")
                  or die $DBI::errstr;
                return $sth;

            }

            sub _build_get_all_particles_sth {

                my ($self) = @_;
                my $sth = $self->dbh->prepare("select * from particles")
                  or die $DBI::errstr;
                return $sth;

            }
        }
    }
}
1;
