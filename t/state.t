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

# user_objects
# FIXME

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
isa_ok $chan, 'IRC::Server::State::Channel';

# add_channel
cmp_ok $st->add_channel($chan), '==', $chan,
  'add_channel returned Channel obj ok';

# attempting to re-add channel croaks
eval {; $st->add_channel($chan) };
like $@, qr/exist/, 'attempting to add existing channel croaks ok';

# build_and_add_channel
$chan = $st->build_and_add_channel(
  name => '#Bar[2]'
);
cmp_ok $chan->name, 'eq', '#Bar[2]', 
  'build_and_add_channel returned Channel obj ok';

# channel_objects
my @chan_objs = $st->channel_objects;
ok @chan_objs == 2, 'channel_objects returned 2 items ok';
for (@chan_objs) {
  isa_ok $_, 'IRC::Server::State::Channel'
}

undef $chan;

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
ok !$st->get_channel('#yourdad'),    'get_channel (nonexistant channel) ok';

# channel_exists (original case)
ok $st->channel_exists('#f{oo}'), 'channel_exists (original case) ok';
# channel_exists (case-folded)
ok $st->channel_exists('#F[oo]'), 'channel_exists (rfc1459 folded) ok';
# channel_exists (nonexistant channel)
ok !$st->channel_exists('#baz'),  'channel_exists (nonexistant channel) ok';

# channel_objects
# FIXME

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


ok !$st->channel_objects,  'channel_objects empty after deletions';
ok !$st->user_objects,     'user_objects empty after deletions';


## channel/user interaction
# $chan_baz->add_user($user_bar)
#  -> adds to user's channel_list
# $chan_baz->add_user($user_foo)
# $chan_baz->del_user($user_foo)
#  -> deletes from user's channel_list
# $chan_baz->has_user($user_foo)
# user deletion from state (removed from all channels)
# channel deletion from state (removed from all users)

my %User;
# build_and_add_user Ba[]r
# build_and_add_user Foo
$User{Bar} = $st->build_and_add_user(
  nickname => 'Ba[]r',
  username => 'barbaz',
  realname => 'Elvis Presly',
  hostname => 'example.org',
);
$User{Foo} = $st->build_and_add_user(
  nickname => 'Foo',
  username => 'foo',
  realname => 'Washington Irving',
  hostname => 'cpan.org'
);

my %Chan;
# build_and_add_channel #B{az}
# build_and_add_channel #quux
$Chan{Baz}  = $st->build_and_add_channel(name => '#B{az}');
$Chan{Quux} = $st->build_and_add_channel(name => '#quux');

# add_users ('Ba[]r' and 'Foo' to '#B{az}')
$Chan{Baz}->add_users( $User{Bar}, $User{Foo} );
# add_user ('Ba[]r' to '#quux')
$Chan{Quux}->add_user( $User{Bar} );

# user_list
is_deeply 
  +{ map {; $_ => 1 } $Chan{Baz}->user_list },
  +{ 'Ba[]r' => 1, 'Foo' => 1 },
  'Channel->user_list ok';

# channel_list
is_deeply
  +{ map {; $_ => 1 } $User{Bar}->channel_list },
  +{ '#B{az}' => 1, '#quux' => 1 },
  'User->channel_list ok';

# FIXME user_list after nickname change

# del_users
# del_user
# user_list after user deletion

# del_channels
# del_channel
# channel_list after channel deletion

# FIXME $user_obj->add_channel(s) ?

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
