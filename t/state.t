use Test::More;
use strictures 2;
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
cmp_ok $user->casemap, 'eq', 'rfc1459', 'casemap passed to User obj ok';

# add_user
$st->add_user($user->nickname => $user);

# build_and_add_user  ('Ba[\]r')
$st->build_and_add_user(
  nickname => 'Ba[\]r',
  username => 'barbaz',
  realname => 'Elvis Presly',
  hostname => 'example.org',
);

# user_names
# FIXME
# user_objects
# FIXME

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
ok !$st->get_user('foobar'),              'get_user (nonexistant user) ok';

# user_exists (original case)
ok $st->user_exists('Foo[213]'), 'user_exists (original case) ok';
# user_exists (case-folded)
ok $st->user_exists('fOO{213}'), 'user_exists (rfc1459 fold) ok';
# user_exists (nonexistant user)
ok !$st->user_exists('yourdad'), 'user_exists (nonexistant user) ok';

# find_users
# FIXME

# del_user (original case)
$st->del_user('Foo[213]');
ok !$st->user_exists('Foo[213]'), 'del_user (original case) ok';
# del_user (case-folded)
$st->del_user('ba{|}r');
ok !$st->user_exists('Ba[\]r'),   'del_user (rfc1459 fold) ok';
# del_user (nonexistant user)
ok !$st->del_user('yourdad'),     'del_user (nonexistant user) ok';

# users->is_empty
ok $st->users->is_empty, 'users hash is empty ok';

# build_channel
my $chan = $st->build_channel(
  name => '#f{oo}'
);
isa_ok $chan, 'IRC::Server::State::Channel',
ok $chan->casefold_users, 'casefold_users passed to Channel obj ok';
cmp_ok $chan->casemap, 'eq', 'rfc1459', 'casemap passed to Channel obj ok';

# add_channel
$st->add_channel($chan->name => $chan);

# build_and_add_channel
$st->build_and_add_channel(
  name => '#Bar[2]'
);

# channel_names
# FIXME
# channel_objects
# FIXME

# get_channel (original case)
$chan = $st->get_channel('#f{oo}');
cmp_ok $chan->name, 'eq', '#f{oo}',  'get_channel (original case) ok 1';
$chan = $st->get_channel('#Bar[2]');
cmp_ok $chan->name, 'eq', '#Bar[2]', 'get_channel (original case) ok 2';

# get_channel (case-folded)
$chan = $st->get_channel('#F[oo]');
cmp_ok $chan->name, 'eq', '#f{oo}',  'get_channel (rfc1459 folded) ok 1';
$chan = $st->get_channel('#bar{2}');
cmp_ok $chan->name, 'eq', '#Bar[2]', 'get_channel (rfc1459 folded) ok 2';

# get_channel (nonexistant channel)
ok !$st->get_channel('#yourdad'),     'get_channel (nonexistant channel) ok';

# channel_exists (original case)
ok $st->channel_exists('#f{oo}'), 'channel_exists (original case) ok';
# channel_exists (case-folded)
ok $st->channel_exists('#F[oo]'), 'channel_exists (rfc1459 folded) ok';
# channel_exists (nonexistant channel)
ok !$st->channel_exists('#baz'),  'channel_exists (nonexistant channel) ok';

# find_channels
# FIXME

# del_channel (original case)
$st->del_channel('#f{oo}');
ok !$st->channel_exists('#f{oo}'),  'del_channel (original case) ok';
# del_channel (case-folded)
$st->del_channel('#bar{2}');
ok !$st->channel_exists('#Bar[2]'), 'del_channel (rfc1459 folded) ok';
# del_channel (nonexistant channel)
ok !$st->del_channel('#baz'),       'del_channel (nonexistant channel) ok';

# channels->is_empty
ok $st->channels->is_empty, 'channels hash empty ok';

# FIXME
# channel/user interaction;
#   add some users & channels, 'join' users to selected channels
#   $st->del_user should remove user from all applicable channels' ->users
#    (and return the list of removed channel objects)
#   $st->del_channel should remove channel from applicable users' ->channels
#    (and return the list of removed user objects)


## rfc1459, casefold_users => 0  (TS6 IDs)
# FIXME

## strict-rfc1459, casefold_users => 1
# FIXME

## ascii, casefold_users => 1


## exceptions
# bad ->build_user args
# bad ->build_channel args
# FIXME

done_testing
