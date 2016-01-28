package IRC::Server::State::Types;

use strictures 2;

use Type::Library -base;
use Type::Utils   -all;

use Types::Standard -types;

declare ValidCasemap =>
  as Enum[qw/rfc1459 strict-rfc1459 ascii/];

declare ModeConfig =>
  as InstanceOf['IRC::Server::State::ModeConfig'];

1;
