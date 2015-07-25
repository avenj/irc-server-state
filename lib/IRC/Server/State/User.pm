package IRC::Server::State::User;

use strictures 2;
use Scalar::Util 'blessed', 'weaken';

use IRC::Server::State::Types -types;
use Types::Standard      -types;
use List::Objects::Types -types;

use IRC::Toolkit::Case 'lc_irc';


use Moo;
with 'IRC::Server::State::Role::HasCasemap';


has _chans => (
  lazy      => 1,
  is        => 'ro',
  isa       => HashObj,
  coerce    => 1,
  builder   => sub { +{} },
);

sub channel_list { 
  my ($self) = @_;
  if (my $st = $self->state) {
    # FIXME retrieve $chan_obj to get $chan_obj->name
  }

  keys %{ $_[0]->_chans } 
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
  # FIXME call _del_channel & delete $self from channel obj if defined
}

has $_ => (
  required  => 1,
  is        => 'ro',
  isa       => Str,
  writer    => "set_$_",
) for qw/
  nickname
  username
  realname
  hostname
/;

around set_nickname => sub {
  my ($orig, $self, $new) = @_;
  # adjust parent state, 
  if (my $st = $self->state) {
    my ($old_actual, $new_actual);
    if ($st->casefold_users) {
      $old_actual = lc_irc $self->nickname, $st->casemap;
      $new_actual = lc_irc $new, $st->casemap;
    } else {
      $old_actual = $self->nickname;
      $new_actual = $new;
    }
    # maybe just a case-change:
    return if $old_actual eq $new_actual;
    delete $st->_users->{$old_actual};
    $st->_users->{$new_actual} = $self;
    for my $channame ($self->channel_list) {
      $st->_chans->{$channame}->_nick_chg($old_actual => $new_actual)
    }
  }
  $self->$orig($new)
};

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
