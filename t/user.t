use Test::More;
use strict; use warnings;

use IRC::Server::State;
use IRC::Toolkit::Case;

my $st = IRC::Server::State->new;
my $user = $st->build_user(
  nickname => 'Foo[213]',
  username => 'foobar',
  realname => 'Washington Irving',
  hostname => 'example.org',
  ipaddr   => '1.2.3.4',
  peer     => 'irc.server.org',
);

cmp_ok $user->casemap, 'eq', 'rfc1459', 'casemap defaults to rfc1459';

cmp_ok $user->nickname, 'eq', 'Foo[213]',           'nickname';
cmp_ok $user->username, 'eq', 'foobar',             'username';
cmp_ok $user->realname, 'eq', 'Washington Irving',  'realname';
cmp_ok $user->hostname, 'eq', 'example.org',        'hostname';
cmp_ok $user->ipaddr,   'eq', '1.2.3.4',            'ipaddr';
cmp_ok $user->peer,     'eq', 'irc.server.org',     'peer';

cmp_ok $user->lower, 'eq', lc_irc($user->nickname, $user->casemap),
  'lower';

cmp_ok $user->id, 'eq', $user->nickname, 'id defaults to nickname';
cmp_ok $user->realhost, 'eq', $user->hostname,
  'realhost defaults to hostname';

ok $user->meta->is_empty, 'meta defaults to empty hash obj';

done_testing
