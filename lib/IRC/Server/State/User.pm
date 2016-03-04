package IRC::Server::State::User;

use strictures 2;

use Carp          'cluck', 'carp', 'confess';
use Scalar::Util  'blessed', 'weaken', 'reftype';

use IRC::Server::State::Types -types;
use Types::Standard           -types;
use List::Objects::Types      -types;

use IRC::Toolkit::Case 'lc_irc';

use IRC::Server::State::ModeConfig;

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

# FIXME fair bit of code dupe with ChannelCollection

sub channel_list { map {; $_->name } values %{ $_[0]->_chans } }

sub channel_objects { values %{ $_[0]->_chans } }

sub on_channel {
  my ($self, $name) = @_;
  $name = $name->name if blessed $name;
  $self->_chans->exists( lc_irc $name, $self->casemap )
}

sub _add_channel {
  my ($self, $obj) = @_;
  my $lower = lc_irc $obj->name, $self->casemap;
  $self->_chans->set($lower => $obj);
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

sub del_channels {
  my $self = shift;
  my @removed;
  for my $chan (@_) {
    if (my $obj = $self->del_channel($chan)) {
      push @removed, $obj
    }
  }
  \@removed
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

sub full {
  # FIXME maybe an attr with triggers? see IRC::Server::Pluggable::IRC::User
  my ($self) = @_;
  $self->nickname .'!'. $self->username .'@'. $self->hostname
}

sub lower {
  my ($self) = @_;
  lc_irc $self->nickname, $self->casemap
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

has meta => (
  lazy      => 1,
  is        => 'ro',
  isa       => HashObj,
  coerce    => 1,
  predicate => 1,
  builder   => sub { +{} },
);

has _umode => (
  lazy      => 1,
  is        => 'ro',
  isa       => HashObj,
  coerce    => 1,
  predicate => 1,
  builder   => sub { +{} },
);

has mode_config => (
  lazy      => 1,
  is        => 'ro',
  isa       => ModeConfig,
  builder   => sub {
    IRC::Server::State::ModeConfig->new(
      param_always    => [],
      param_when_set  => [],
    )
  },
);

sub mode {
  my ($self, %param) = @_;
  return '+' if $self->_umode->is_empty;
  my $str = '+';
  my @params;
  $self->_umode->kv_sort->visit(sub {
    my ($mode, $param) = @$_;
    $str .= $mode;
    push @params, $param if length $param;
  });
  join ' ', $str, ( $param{show_params} ? @params : () )
}

sub set_mode {
  my ($self, $mode) = @_;
  if (ref $mode) {
    if (blessed $mode) {
      $mode = $mode->isa('IRC::Mode::Set') ? $mode->mode_array
        : $mode->isa('IRC::Mode::Single') ? [ [@$mode] ]
        : confess "Do not know how to set_mode via '$mode'";
    }
    return reftype $mode eq 'ARRAY' ? $self->_set_mode_array($mode)
         : reftype $mode eq 'HASH'  ? $self->_set_mode_hash($mode)
         : confess "Expected mode string, ARRAY, or HASH, but got '$mode'"
  }
  # else a stringy mode presumably
  $self->_set_mode_array( 
    mode_to_array( $mode,
      param_always   => $self->mode_config->param_always,
      param_when_set => $self->mode_config->param_when_set
    )
  )
}

sub _set_mode_array {
  my ($self, $mode) = @_;
  for my $mset (@$mode) {
    my ($flag, $mode, $param) = @$mset;
    if ($flag eq '+') {
      $self->_umode->set($mode => $param // '')
    } elsif ($flag eq '-') {
      $self->_umode->delete($mode)
    } else {
      confess "Bad mode flag '$flag'"
    }
  }
  # FIXME return actual set of changes from _set_mode_array/_set_mode_hash,
  #  skipping previously set (or previously unset) modes ?
  #  would simplify life for higher-level layers directing output at clients,
  #  but also requires checking param_always/param_when_set modes (+ is always
  #  valid)
  1
}

sub _set_mode_hash {
  my ($self, $mode) = @_;
  # takes hash produced by IRC::Toolkit::Modes::mode_to_hash ->
  unless (exists $mode->{add} || exists $mode->{del}) {
    cluck "Expected 'add' and/or 'del' keys in mode hash, doing nothing";
    return
  }
  if (exists $mode->{add}) {
    $self->_umode->set($_ => $mode->{add}->{$_}) for keys %{ $mode->{add} }
  }
  if (exists $mode->{del}) {
    $self->_umode->delete(keys %{ $mode->{del} })
  }
  1
}

sub has_mode {
  my ($self, $mode) = @_;
  $self->_umode->exists($mode)
}

sub params_for_mode {
  my ($self, $mode) = @_;
  $self->_umode->get($mode)
}

sub mode_array {
  my ($self) = @_;
  # same format as mode_to_array (well, except this is a lowu array) ->
  $self->_umode->kv->map(sub {
    my ($mode, $param) = @$_;
    [ '+', $mode, ( length $param ? $param : () ) ]
  })
}

sub mode_hash {
  # FIXME should we return same format as mode_to_hash ? (perhaps optionally)
  shift->_umode->copy
}

1;
