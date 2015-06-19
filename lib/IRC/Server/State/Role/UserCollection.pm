package IRC::Server::State::Role::UserCollection;

use Carp;
use List::Objects::Types      -types;
use Types::Standard           -types;

use IRC::Toolkit::Case;

use Moo::Role;

requires qw/
  casemap
  casefold_users
/;

has _users => (
  lazy    => 1,
  is      => 'ro',
  isa     => TypedHash[ InstanceOf['IRC::Server::State::User'] ],
  coerce  => 1,
  builder => sub { +{} },
  # hash_of User, keyed on nick or TS6 ID
  #
  handles => +{
    find_users  => 'kv_grep',  # FIXME method?
  },
);

sub user_objects { values %{ $_[0]->_users } }

sub add_user {
  my ($self, $obj) = @_;
  my $lower = $self->casefold_users ?
    lc_irc($obj->nickname, $self->casemap) : $obj->nickname;
  croak "Attempted to re-add existing user: ".$obj->nickname
    if $self->_users->exists($lower);
  $self->_users->set( $lower => $obj );
  $obj
}

sub get_user {
  my ($self, $name) = @_;
  $self->_users->get(
    ($self->casefold_users ? lc_irc($name, $self->casemap) : $name)
  )
}

sub del_user {
  my ($self, $name) = @_;
  # FIXME accept name_or_obj
  $self->_users->delete(
    $self->casefold_users ? lc_irc($name, $self->casemap) : $name
  )->get(0)
}

sub chg_user_nick {
  my ($self, $old, $new) = @_;
  my $obj = $self->del_user($old)
    || confess "Cannot chg_user_nick for nonexistant user '$old'";
  $self->add_user($new => $obj)
}

sub user_exists {
  my ($self, $name) = @_;
  $self->_users->exists(
    $self->casefold_users ? lc_irc($name, $self->casemap) : $name
  )
}

1;
