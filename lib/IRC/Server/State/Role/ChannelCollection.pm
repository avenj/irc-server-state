package IRC::Server::State::Role::ChannelCollection;

use Carp;
use List::Objects::Types      -types;
use Types::Standard           -types;

use IRC::Toolkit::Case;

use Moo::Role;

requires qw/
  casemap
/;

has channels => (
  lazy    => 1,
  is      => 'ro',
  isa     => TypedHash[ InstanceOf['IRC::Server::State::Channel'] ],
  coerce  => 1,
  builder => sub { +{} },
  handles => +{
    find_channels   => 'kv_grep', # FIXME method?
  },
);

sub channel_names   { shift->channels->keys->all }
sub channel_objects { shift->channels->values->all }

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
  $self->channels->delete(lc_irc $name, $self->casemap)->get(0)
}

sub channel_exists {
  my ($self, $name) = @_;
  $self->channels->exists( lc_irc $name, $self->casemap )
}



1;
