use Test::More;
use Test::TypeTiny;
use strictures 2;

use IRC::Server::State::Types -types;

should_pass 'rfc1459', ValidCasemap;
should_pass 'ascii',   ValidCasemap;
should_pass 'strict-rfc1459', ValidCasemap;
should_fail 'foo', ValidCasemap;
should_fail '', ValidCasemap;

my $case;
should_pass \($case = 'rfc1459'), CasemapRef;
should_pass \($case = 'ascii'), CasemapRef;
should_pass \($case = 'strict-rfc1459'), CasemapRef;
should_fail 'rfc1459', CasemapRef;
should_fail \($case = 'foo'), CasemapRef;

done_testing
