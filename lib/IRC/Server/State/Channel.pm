package IRC::Server::State::Channel;

use Carp;
use Scalar::Util 'reftype';

use List::Objects::WithUtils;
use Types::Standard      -all;
use List::Objects::Types -all;
use IRC::Server::State::Types -all;

use Moo 2;

has casefold_users => (
  required  => 1,
  is        => 'ro',
  isa       => Bool,
);

has casemap => (
  required  => 1,
  is        => 'ro',
  isa       => ValidCasemap,
);

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


with 'IRC::Server::State::Role::UserCollection';

1;
