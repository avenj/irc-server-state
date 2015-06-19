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

# add_user
cmp_ok $st->add_user($user), '==', $user, 'add_user returned User obj ok';

# attempting to re-add user croaks
eval {; $st->add_user($user) };
like $@, qr/exist/, 'add_user for existing user croaks ok';

# build_and_add_user  ('Ba[\]r')
$user = $st->build_and_add_user(
  nickname => 'Ba[\]r',
  username => 'barbaz',
  realname => 'Elvis Presly',
  hostname => 'example.org',
);
cmp_ok $user->nickname, 'eq', 'Ba[\]r',
  'build_and_add_user returned User obj ok';

# user_objects
my @user_objs = $st->user_objects;
ok @user_objs == 2, 'user_objects returned 2 items ok';
isa_ok $_, 'IRC::Server::State::User' for @user_objs;

undef $user;

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

# get_user (nickname changed)
$user->set_nickname('Bar[\]r');
$user = $st->get_user('Bar[\]r');
cmp_ok $user->nickname, 'eq', 'Bar[\]r', 'get_user (orig case after chg) ok';
$user = $st->get_user('bar{\]R');
cmp_ok $user->nickname, 'eq', 'Bar[\]r', 'get_user (rfc fold after chg) ok';

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
$st->del_user('bar{|}r');
ok !$st->user_exists('Bar[\]r'),  'del_user (rfc1459 fold) ok';
# del_user (nonexistant user)
ok !$st->del_user('yourdad'),     'del_user (nonexistant user) ok';

# build_channel
my $chan = $st->build_channel(
  name => '#f{oo}'
);
isa_ok $chan, 'IRC::Server::State::Channel',

# add_channel
$st->add_channel($chan->name => $chan);

# build_and_add_channel
$st->build_and_add_channel(
  name => '#Bar[2]'
);

# channel_objects
my @chan_objs = $st->channel_objects;
ok @chan_objs == 2, 'channel_objects returned 2 items ok';
for (@chan_objs) {
  isa_ok $_, 'IRC::Server::State::Channel'
}

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
