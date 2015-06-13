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

has users => (
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

sub user_names   { shift->users->keys->all }
sub user_objects { shift->users->values->all }

sub add_user {
  my ($self, $name, $obj) = @_;
  $self->users->set(
    ($self->casefold_users ? lc_irc($name, $self->casemap) : $name)
      => $obj
  )
}

sub get_user {
  my ($self, $name) = @_;
  $self->users->get(
    ($self->casefold_users ? lc_irc($name, $self->casemap) : $name)
  )
}

sub del_user {
  my ($self, $name) = @_;
  $self->users->delete(
    $self->casefold_users ? lc_irc($name, $self->casemap) : $name
  )->get(0)
}

sub user_exists {
  my ($self, $name) = @_;
  $self->users->exists(
    $self->casefold_users ? lc_irc($name, $self->casemap) : $name
  )
}

1;
