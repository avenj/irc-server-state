package IRC::Server::State::User;

use IRC::Server::State::Types -types;
use Types::Standard      -types;
use List::Objects::Types -types;

use Moo;

has casemap => (
  required  => 1,
  is        => 'ro',
  isa       => ValidCasemap,
);


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

with 'IRC::Server::State::Role::ChannelCollection';

1;
