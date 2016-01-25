package IRC::Server::State::User;

use strictures 2;
use Carp;
use Scalar::Util 'blessed', 'weaken';

use IRC::Server::State::Types -types;
use Types::Standard           -types;
use List::Objects::Types      -types;

use IRC::Toolkit::Case 'lc_irc';


use Moo;
with 'IRC::Server::State::Role::HasCasemap';

has state => (
  required  => 1,
  is        => 'ro',
  isa       => InstanceOf['IRC::Server::State'],
  weak_ref  => 1,
);

has _chans => (
  lazy      => 1,
  is        => 'ro',
  isa       => HashObj,
  coerce    => 1,
  builder   => sub { +{} },
);

sub channel_list { map {; $_->name } values %{ $_[0]->_chans } }

sub channel_objects { values %{ $_[0]->_chans } }

sub on_channel {
  my ($self, $name) = @_;
  $name = $name->name if blessed $name;
  $self->_chans->exists( lc_irc $name, $self->casemap )
}

sub _add_channel {
  my ($self, $obj) = @_;
  my $lower = lc_irc $obj, $self->casemap;
  $self->_chans->{$lower} = $obj;
  weaken $self->_chans->{$lower};
  $lower
}

sub add_channel {
  my ($self, $obj) = @_;
  $self->_add_channel($obj);
  $obj->_add_user($self);
  $obj
}

sub add_channels {
  my $self = shift;
  $self->add_channel($_) for @_;
}

sub del_channel {
  my ($self, $name) = @_;
  $name = $name->name if blessed $name;
  my $obj = $self->_chans->delete( lc_irc $name, $self->casemap )->get(0);
  if (defined $obj) {
    $obj->del_user($self) if $obj->has_user($self);
  } else {
    carp "Attempted to del_channel for nonexistant channel '$name'"
  }
  $obj
}

has $_ => (
  required  => 1,
  is        => 'ro',
  isa       => Str,
  writer    => "set_$_",
) for qw/
  username
  realname
  hostname
/;

has nickname => (
  required  => 1,
  is        => 'ro',
  isa       => Str,
  writer    => '_set_nickname',
);

sub set_nickname {
  my ($self, $new) = @_;
  # maybe just a case-change:
  my $old_lower = lc_irc $self->nickname, $self->casemap;
  my $new_lower = lc_irc $new, $self->casemap;
  $self->_set_nickname($new);
  unless ($old_lower eq $new_lower) {
    $self->state->_chg_user_nick($old_lower)
      if defined $self->state;
    for my $chan ($self->channel_objects) {
      $chan->_nick_chg($old_lower => $new_lower)
    }
  }
  $new
}

has id => (
  lazy      => 1,
  is        => 'ro',
  isa       => Defined,
  writer    => 'set_id',
  predicate => 1,
  builder   => sub { shift->nickname },
);

has realhost => (
  lazy      => 1,
  is        => 'ro',
  isa       => Str,
  writer    => 'set_realhost',
  predicate => 1,
  builder   => sub { shift->hostname },
);

has ipaddr => (
  lazy      => 1,
  is        => 'ro',
  isa       => Str,
  predicate => 1,
  builder   => sub { '255.255.255.255' },
);

has peer => (
  lazy      => 1,
  is        => 'ro',
  isa       => Str,
  writer    => 'set_peer',
  predicate => 1,
  builder   => sub { '' },
);

#has modes => (
  # FIXME
#);

has meta => (
  lazy      => 1,
  is        => 'ro',
  isa       => HashObj,
  coerce    => 1,
  predicate => 1,
  builder   => sub { +{} },
);

1;
