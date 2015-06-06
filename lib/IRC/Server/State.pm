package IRC::Server::State;

use List::Objects::Types -all;
use Types::Standard -all;
use IRC::Server::State::Types -all;

use IRC::Toolkit::Case;

use Moo 2;

has casefold_users => (
  lazy    => 1,
  is      => 'ro',
  isa     => Bool,
  builder => sub { 1 },
);

has casemap => (
  lazy    => 1,
  is      => 'ro',
  isa     => ValidCasemap,
  builder => sub { 'rfc1459' },
);

has channels => (
  lazy    => 1,
  is      => 'ro',
  isa     => TypedHash[ InstanceOf['IRC::Server::State::Channel'] ],
  coerce  => 1,
  builder => sub { +{} },
  handles => +{
    clear_channels  => 'clear',
    find_channels   => 'kv_grep', # FIXME method?
  },
);

sub add_channel {
  my ($self, $name, $obj) = @_;
  $self->channels->set( lc_irc($name, $self->casemap) => $obj );
}

sub get_channel {
  my ($self, $name) = @_;
  $self->channels->get( lc_irc $name, $self->casemap )
}

sub del_channel {
  my ($self, $name) = @_;
  # FIXME iterate deleted object's ->users list,
  #  remove this channel from each user's ->channels list
  #  return list of 
  $self->channels->delete( lc_irc $name, $self->casemap )
}

sub channel_exists {
  my ($self, $name) = @_;
  $self->channels->exists( lc_irc $name, $self->casemap )
}


# FIXME Role::UserCollection, Role::ChannelCollection
#  User & State consume ChannelCollection
#  Channel & State consume UserCollection
has users => (
  lazy    => 1,
  is      => 'ro',
  isa     => TypedHash[ InstanceOf['IRC::Server::State::User'] ],
  coerce  => 1,
  builder => sub { +{} },
  # hash_of User, keyed on nick or TS6 ID
  # 
  handles => +{
    clear_users => 'clear',
    find_users  => 'kv_grep',  # FIXME method?
  },
);

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
  # FIXME iterate channels in deleted user obj's ->channels list,
  #  delete from each channel also
  #  return list of deleted channels
  $self->users->delete( 
    $self->casefold_users ? lc_irc($name, $self->casemap) : $name
  )
}

sub user_exists {
  my ($self, $name) = @_;
  $self->users->exists( 
    $self->casefold_users ? lc_irc($name, $self->casemap) : $name
  )
}

has peers => (
  # IRC::Server::Tree ?
  #  needs reworked anyway ...
  #  possibly something MXR::DependsOn-based
  #  TypedHash[ ConsumerOf['MooX::Role::DependsOn'] ] ?
  #  possibly Peer should be a consumer of DependsOn instead,
  #  +{ $name => $obj }
);


print <<'_END'

::State
 has casemap
 has channels (hash_of Channel keyed on casefolded channame)
 has users    (hash_of User keyed on casefolded nick or TS6 ID)
 has network  (IRC::Server::Tree::Network?)

::State::Channel
 has casemap  (ScalarRef to $state->casemap ?)
 has users    (hash_of weak ref to User keyed on casefolded nick or TS6 ID)
 has modes    (hash_of Str keyed on mode)
 has topic    (Dict ?)
 has lists    (hash_of TypedHash[Int] +{ b => +{ $item => 1 } })

::State::User
 has casemap
 has nickname (Str)
 has username (Str)
 has hostmask (Str)
 has realhost (Str)
 has ipaddr   (Str)
 has modes    (



_END
unless caller; 1;

# vim: ts=2 sw=2 et sts=2 ft=perl
