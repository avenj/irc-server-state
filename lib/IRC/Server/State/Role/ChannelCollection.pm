package IRC::Server::State::Role::ChannelCollection;

use Carp;
use List::Objects::Types      -types;
use Types::Standard           -types;

use IRC::Toolkit::Case;

use Moo::Role;

requires qw/
  casemap
/;

has _chans => (
  lazy    => 1,
  is      => 'ro',
  isa     => TypedHash[ InstanceOf['IRC::Server::State::Channel'] ],
  coerce  => 1,
  builder => sub { +{} },
  handles => +{
    find_channels   => 'kv_grep', # FIXME method?
  },
);

sub channel_objects { values %{ $_[0]->_chans } }

sub add_channel {
  my ($self, $obj) = @_;
  $self->_chans->set( lc_irc($obj->name, $self->casemap) => $obj );
  $obj
}

sub get_channel {
  my ($self, $name) = @_;
  $self->_chans->get( lc_irc $name, $self->casemap )
}

sub del_channel {
  my ($self, $name) = @_;
  # FIXME accept name_or_obj
  $self->_chans->delete(lc_irc $name, $self->casemap)->get(0)
}

sub channel_exists {
  my ($self, $name) = @_;
  $self->_chans->exists( lc_irc $name, $self->casemap )
}



1;
