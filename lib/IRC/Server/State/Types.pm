package IRC::Server::State::Types;

use strictures 2;

use Type::Library -base;
use Type::Utils   -all;

use Types::Standard -types;

declare ValidCasemap =>
  as Enum[qw/rfc1459 strict-rfc1459 ascii/];

declare CasemapRef =>
  as ScalarRef,
  where { ValidCasemap->check($$_) };


1;
