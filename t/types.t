use Test::More;
use Test::TypeTiny;
use strictures 2;

use IRC::Server::State::Types -types;

# ValidCasemap
should_pass 'rfc1459', ValidCasemap;
should_pass 'ascii',   ValidCasemap;
should_pass 'strict-rfc1459', ValidCasemap;
should_fail 'foo', ValidCasemap;
should_fail '', ValidCasemap;

# ModeConfig

# IRCUser

# IRCChan

done_testing
