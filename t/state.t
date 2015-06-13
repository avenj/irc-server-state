use Test::More;

use IRC::Server::State;

## rfc1459, casefold_users => 1
my $st = IRC::Server::State->new;

# casemap & casefold_users
cmp_ok $st->casemap, 'eq', 'rfc1459', 'default casemap ok';
ok $st->casefold_users,               'default casefold_users ok';

# build_user  ('Foo[213]')
my $user = $st->build_user(
  nickname => 'Foo[213]',
  username => 'foobar',
  realname => 'Washington Irving',
  hostname => 'example.org',
);
isa_ok $user, 'IRC::Server::State::User';

# add_user
$st->add_user($user->nickname => $user);

# build_and_add_user  ('Ba[\]r')
$st->build_and_add_user(
  nickname => 'Ba[\]r',
  username => 'barbaz',
  realname => 'Elvis Presly',
  hostname => 'example.org',
);

# get_user (original case)
$user = $st->get_user('Foo[213]');
cmp_ok $user->nickname, 'eq', 'Foo[213]', 'get_user (original case) ok 1';
$user = $st->get_user('Ba[\]r');
cmp_ok $user->nickname, 'eq', 'Ba[\]r',   'get_user (original case ok 2';

# get_user (case-folded)
$user = $st->get_user('foo[213]');
cmp_ok $user->nickname, 'eq', 'Foo[213]', 'get_user (rfc1459 fold) ok 1';
$user = $st->get_user('FOO{213}');
cmp_ok $user->nickname, 'eq', 'Foo[213]', 'get_user (rfc1459 fold) ok 2';
$user = $st->get_user('ba{|}r');
cmp_ok $user->nickname, 'eq', 'Ba[\]r',   'get_user (rfc1459 fold) ok 3';

# get_user (nonexistant user)
ok !$st->get_user('foobar'), 'get_user (nonexistant user) ok';

# user_exists (original case)
ok $st->user_exists('Foo[213]'), 'user_exists (original case) ok';
# user_exists (case-folded)
ok $st->user_exists('fOO{213}'), 'user_exists (rfc1459 fold) ok';
# user_exists (nonexistant user)
ok !$st->user_exists('yourdad'), 'user_exists (nonexistant user) ok';

# del_user (original case)
$st->del_user('Foo[213]');
ok !$st->user_exists('Foo[213]'), 'del_user (original case) ok';
# del_user (case-folded)
$st->del_user('ba{|}r');
ok !$st->user_exists('Ba[\]r'),   'del_user (rfc1459 fold) ok';
# del_user (nonexistant user)
ok !$st->del_user('yourdad'), 'del_user (nonexistant user) ok';


# build_channel
# add_channel
# build_and_add_channel


# channel/user interaction;
#   add some users & channels, 'join' users to selected channels
#   $st->del_user should remove user from all applicable channels' ->users
#    (and return the list of removed channel objects)
#   $st->del_channel should remove channel from applicable users' ->channels
#    (and return the list of removed user objects)


## rfc1459, casefold_users => 0

## strict-rfc1459, casefold_users => 1

## ascii, casefold_users => 1


## exceptions
# bad ->build_user args
# bad ->build_channel args
# FIXME

done_testing
