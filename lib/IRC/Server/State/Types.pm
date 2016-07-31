package IRC::Server::State::Types;

use strictures 2;

use Type::Library -base;
use Type::Utils   -all;

use Types::Standard -types;

declare ValidCasemap =>
  as Enum[qw/rfc1459 strict-rfc1459 ascii/];

declare ModeCfg =>
  as InstanceOf['IRC::Server::State::ModeConfig'];

declare IRCUser =>
  as InstanceOf['IRC::Server::State::User'];

declare IRCChan =>
  as InstanceOf['IRC::Server::State::Channel'];

1;
