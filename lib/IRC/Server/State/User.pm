package IRC::Server::State::User;

use IRC::Server::State::Types -types;
use Types::Standard      -types;
use List::Objects::Types -types;

use IRC::Toolkit::Case 'lc_irc';

use Moo;

has state => (
  required  => 1,
  is        => 'ro',
  isa       => InstanceOf['IRC::Server::State'],
  weak_ref  => 1,
);

has nickname => (
  required  => 1,
  is        => 'ro',
  isa       => Str,
  writer    => '_set_nickname',
);

has _chans => (
  lazy      => 1,
  is        => 'ro',
  isa       => HashObj,
  coerce    => 1,
  builder   => sub { +{} },
);

sub channel_list { keys %{ $self->_chans } }

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

around _set_nickname => sub {
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
