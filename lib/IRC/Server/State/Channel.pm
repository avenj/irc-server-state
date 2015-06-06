package IRC::Server::State::Channel;

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
  isa       => CasemapRef,
);

with 'IRC::Server::State::Role::UserCollection';

1;
