package IRC::Server::State::Role::HasCasemap;

use strictures 2;

use IRC::Server::State::Types -all;

use Moo::Role;

has casemap => (
  lazy      => 1,
  is        => 'ro',
  isa       => ValidCasemap,
  builder   => sub { 'rfc1459' },
);

1;
