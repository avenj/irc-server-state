package IRC::Server::State::Channel;

use strictures 2;

use Carp;
use Scalar::Util 'reftype';

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

has state => (
  required  => 1,
  is        => 'ro',
  isa       => InstanceOf['IRC::Server::State'],
  weak_ref  => 1,
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

sub user_list { 
  my ($self) = @_;
  if (my $st = $self->state) {
    # FIXME retrieve $user_obj to get properly-cased ->nickname
  }
  keys %{ $_[0]->_users } 
}

sub _add_user {
  my ($self, $nickname) = @_;
  if (my $st = $self->state) {
    $nickname = lc_irc $nickname, $st->casemap;
    # FIXME add to user's channel list from here
  }
  $self->_users->{$nickname} = +{};
  $nickname
}

sub _del_user {
  my ($self, $actual) = @_;
  delete $self->_users->{$actual}
}

sub _nick_chg {
  my ($self, $old_actual, $new_actual) = @_;
  my $old_rec = delete $self->_users->{$old_actual};
  confess "User not in channel state: '$old_actual'"
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
