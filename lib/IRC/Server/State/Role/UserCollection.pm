package IRC::Server::State::Role::UserCollection;

use strictures 2;

use Scalar::Util 'blessed';
use Carp;

use List::Objects::Types      -types;
use Types::Standard           -types;

use IRC::Toolkit::Case;


use Moo::Role;
requires 'casemap';


has _users => (
  lazy    => 1,
  is      => 'ro',
  isa     => TypedHash[ InstanceOf['IRC::Server::State::User'] ],
  coerce  => 1,
  builder => sub { +{} },
  handles => +{
    find_users  => 'kv_grep',  # FIXME method?
  },
);

sub user_objects { values %{ $_[0]->_users } }

sub add_user {
  my ($self, $obj) = @_;
  my $lower = lc_irc $obj->nickname, $self->casemap;
  carp "Re-adding existing user: ".$obj->nickname
    if $self->_users->exists($lower);
  $self->_users->set( $lower => $obj );
  $obj
}

sub add_users {
  ...
  # FIXME
}

sub get_user {
  my ($self, $name) = @_;
  $self->_users->get( lc_irc $name, $self->casemap )
}

sub del_user {
  my ($self, $name) = @_;
  $name = $name->nickname if blessed $name;
  $self->_users->delete( lc_irc $name, $self->casemap )->get(0)
}

sub del_users {
  my $self = shift;
  my @removed;
  for my $user (@_) {
   if (my $obj = $self->del_user($user)) {
     push @removed, $obj
   }
  }
  \@removed
}

sub _chg_user_nick {
  my ($self, $old_lower) = @_;
  my $obj;
  unless ($obj = $self->_users->delete($old_lower)->get(0)) {
    confess "BUG; cannot _chg_user_nick for nonexistant user '$old_lower'";
  }
  $self->add_user($obj)
}

sub user_exists {
  my ($self, $name) = @_;
  $name = $name->nickname if blessed $name;
  $self->_users->exists( lc_irc $name, $self->casemap )
}

1;
