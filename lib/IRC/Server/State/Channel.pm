package IRC::Server::State::Channel;

use strictures 2;
use Carp;
use Scalar::Util 'blessed', 'weaken';

use List::Objects::WithUtils;

use Types::Standard           -all;
use List::Objects::Types      -all;
use IRC::Server::State::Types -all;

use IRC::Toolkit::Case 'lc_irc';


use Moo;
with 'IRC::Server::State::Role::HasCasemap';


has name => (
  required  => 1,
  is        => 'ro',
  isa       => Str,
);

has lists => (
  # $chan->lists->get('b')->exists($mask)
  lazy      => 1,
  is        => 'ro',
  isa       => TypedHash[HashObj],
  coerce    => 1,
  builder   => sub { hash_of HashObj },
);

has _users => (
  lazy      => 1,
  is        => 'ro',
  isa       => HashObj,
  coerce    => 1,
  builder   => sub { +{} },
);

# FIXME fair bit of code dupe with UserCollection

sub user_list { map {; $_->nickname } values %{ $_[0]->_users } }

sub user_objects { values %{ $_[0]->_users } }

sub _add_user {
  my ($self, $obj) = @_;
  my $lower = lc_irc $obj->nickname, $self->casemap;
  $self->_users->{$lower} = $obj;
  weaken $self->_users->{$lower};
  $lower
}

sub add_user {
  my ($self, $obj) = @_;
  $self->_add_user($obj);
  $obj->_add_channel($self);
  $obj
}

sub add_users {
  my $self = shift;
  $self->add_user($_) for @_;
  1
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

sub _nick_chg {
  my ($self, $old_actual, $new_actual) = @_;
  warn "DEBUG  KNOWN USERS  " . $self->_users->keys->join(',');
  my $old_rec = delete $self->_users->{$old_actual};
  confess "User not in channel (@{[$self->name]}) state: '$old_actual'"
    unless $old_rec;
  $self->_users->{$new_actual} = $old_rec
}

# FIXME more user manip methods

#has modes => (
  # FIXME
#);


has topic => (
  lazy      => 1,
  is        => 'ro',
  isa       => InflatedHash[qw/string ts setter/],
  coerce    => 1,
  builder   => sub {
    +{ string => '', ts => time, setter => '' }
  },
);

sub set_topic {
  my ($self, %params) = @_;
  my $topic = $self->topic;
  for (keys %params) {
    confess "Unknown set_topic option '$_'"
      unless $_ eq 'string' or $_ eq 'ts' or $_ eq 'setter';
    $topic->{$_} = $params{$_}
  }
  $topic
}

has ts => (
  lazy      => 1,
  is        => 'ro',
  isa       => StrictNum,
  builder   => sub { time },
);


1;
