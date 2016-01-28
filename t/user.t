use Test::More;
use strict; use warnings;

use IRC::Server::State;
use IRC::Toolkit::Case;
use IRC::Toolkit::Modes;

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


cmp_ok $user->umode, 'eq', '+', 'empty default umode (+)';

# add modes (string, no params)
$user->set_mode('+oa');
ok $user->has_mode('o'), 'user set mode +o';
ok $user->has_mode('a'), 'user set mode +a';
cmp_ok $user->umode, 'eq', '+ao', 'umode returns +ao';

# drop modes (string, no params)
# FIXME

# mixed (string, no params)
# FIXME

# add modes (string, params)
# FIXME

# mixed (string, params)
# FIXME

# add modes (mode array, no params)
# FIXME

# drop modes (mode array, no params)
# FIXME

# mixed (mode array, no params)
# FIXME

# add modes (mode array, params)
$user->set_mode(
  mode_to_array(
    '+eS 123',
    param_set => ['S'],
  )
);
# FIXME

# mixed (mode array, params)
# FIXME

# add modes (mode hash, no params)
# FIXME
# drop modes (mode hash, no params)
# FIXME
# mixed (mode hash, no params)
# FIXME
# add_modes (mode hash, params)
# FIXME
# mixed (mode hash, params)
# FIXME

done_testing
