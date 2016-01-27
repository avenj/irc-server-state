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

ok $user->state == $st, 'state attached';

cmp_ok $user->casemap, 'eq', 'rfc1459', 'casemap defaults to rfc1459';

cmp_ok $user->nickname, 'eq', 'Foo[213]', 'nickname';

cmp_ok $user->username, 'eq', 'foobar', 'username';
$user->set_username('baz');
cmp_ok $user->username, 'eq', 'baz', 'set_username';

cmp_ok $user->realname, 'eq', 'Washington Irving', 'realname';
$user->set_realname('bar');
cmp_ok $user->realname, 'eq', 'bar', 'set_realname';

cmp_ok $user->hostname, 'eq', 'example.org', 'hostname';
$user->set_hostname('foo.irc');
cmp_ok $user->hostname, 'eq', 'foo.irc', 'set_hostname';

cmp_ok $user->ipaddr, 'eq', '1.2.3.4', 'ipaddr';
ok $user->has_ipaddr, 'has_ipaddr';

cmp_ok $user->peer, 'eq', 'irc.server.org', 'peer';
$user->set_peer('irc2.server.org');
cmp_ok $user->peer, 'eq', 'irc2.server.org', 'set_peer';

cmp_ok $user->lower, 'eq', lc_irc($user->nickname, $user->casemap),
  'lower';

ok !$user->has_id, 'no id by default';
cmp_ok $user->id, 'eq', $user->nickname, 'id defaults to nickname';

ok !$user->has_realhost, 'no realhost by default';
cmp_ok $user->realhost, 'eq', $user->hostname,
  'realhost defaults to hostname';

# FIXME test that meta is coercible
ok $user->meta->is_empty, 'meta defaults to empty hash obj';
$user->meta->set(foo => 1);
ok $user->meta->get('foo') == 1, 'meta hash is mutable';

# FIXME test for required attrs

# FIXME umodes

done_testing
