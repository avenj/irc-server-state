package IRC::Server::State::User;

use IRC::Server::State::Types -types;
use Types::Standard      -types;
use List::Objects::Types -types;

use Moo;

has casemap => (
  required  => 1,
  is        => 'ro',
  isa       => CasemapRef,
);


with 'IRC::Server::State::Role::ChannelCollection';

1;
