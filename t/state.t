use Test::More;
use Test::Memory::Cycle;
use strictures 2;

use IRC::Server::State;

use lib 't/inc';
use ISSHelpers qw/
  user_has_channels
  channel_has_users
/;


my $st = IRC::Server::State->new;

# casemap
cmp_ok $st->casemap, 'eq', 'rfc1459', 'default casemap ok';

# build_user  ('Foo[213]')
my $user = $st->build_user(
  nickname => 'Foo[213]',
  username => 'foobar',
  realname => 'Washington Irving',
  hostname => 'example.org',
);
isa_ok $user, 'IRC::Server::State::User';
cmp_ok $user->casemap, 'eq', $st->casemap, 'User casemap matches State ok';

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

# State->user_objects
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
$user = $st->get_user('Bar[\]r')
  or diag explain $st 
  and fail "failed to get_user from State after set_nickname";
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
cmp_ok $chan->casemap, 'eq', $st->casemap,
  'Channel casemap matches State casemap ok';

# State->channel_objects
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

# these should have a weak cycle ( User -> State -> User )
weakened_memory_cycle_exists $User{Bar}, 'weak cycle exists for User (1)';
weakened_memory_cycle_exists $User{Foo}, 'weak cycle exists for User (2)';
memory_cycle_ok $st, 'no strong cycles in (unlinked) State';

my %Chan;
# build_and_add_channel #B{az}
# build_and_add_channel #quux
$Chan{Baz}  = $st->build_and_add_channel(name => '#B{az}');
$Chan{Quux} = $st->build_and_add_channel(name => '#quux');
weakened_memory_cycle_exists $st, 'weak cycle exists in (unlinked) State';

# Channel->add_users
#  -> #quux  => []
#  -> #B{az} => [ 'Ba[]r', 'Foo' ]
$Chan{Baz}->add_users( $User{Bar}, $User{Foo} );
# Channel->add_user ('Ba[]r' to '#quux')
#  -> #quux  => [ 'Ba[]r' ]
#  -> #B{az} => [ 'Ba[]r', 'Foo' ]
$Chan{Quux}->add_user( $User{Bar} );

weakened_memory_cycle_exists $st, 'weak cycle exists in linked State';
memory_cycle_ok $st, 'no strong cycles in linked State';

# Channel->user_list
is_deeply 
  +{ map {; $_ => 1 } $Chan{Baz}->user_list },
  +{ 'Ba[]r' => 1, 'Foo' => 1 },
  'Channel->user_list ok';

# User->channel_list
is_deeply
  +{ map {; $_ => 1 } $User{Bar}->channel_list },
  +{ '#B{az}' => 1, '#quux' => 1 },
  'User->channel_list ok';

# User->channel_objects
is_deeply
  +{ map {; $_->name => 1 } $User{Bar}->channel_objects },
  +{ '#B{az}' => 1, '#quux' => 1 },
  'User->channel_objects ok';

# Channel->user_objects
is_deeply
  +{ map {; $_->nickname => 1 } $Chan{Baz}->user_objects },
  +{ 'Ba[]r' => 1, 'Foo' => 1 },
  'Channel->user_objects ok';

# user_list after set_nickname (Foo -> foobar -> fOO)
# (also covers channel list interaction wrt nick changes)
#  -> #quux  => [ 'Ba[]r' ]
#  -> #B{az} => [ 'Ba[]r', 'fOO' ]
$User{Foo}->set_nickname('foobar');
channel_has_users $Chan{Baz}, [ qw/Ba[]r foobar/ ],
  'Channel->user_list after set_nickname ok (1)';
$User{Foo}->set_nickname('fOO');
channel_has_users $Chan{Baz}, [ qw/Ba[]r fOO/ ],
  'Channel->user_list after set_nickname ok (2)';

# Channel->del_users  (by name, folded)
# ('Ba[]r', 'fOO' from #B{az})
#   -> #quux  => [ 'Ba[]r' ]
#   -> #B{az} => []
$Chan{Baz}->del_users('ba{}r', 'Foo');
ok !$Chan{Baz}->user_list, 'Channel empty after del_users by name ok';

# Channel->del_users  (by obj)
#   -> #quux  => [ 'Ba[]r' ]
#   -> #B{az} => [ 'Ba[]r', 'fOO' ]
#  =>
#   -> #quux  => [ 'Ba[]r' ]
#   -> #B{az} => [ 'Ba[]r' ]
$Chan{Baz}->add_users( $User{Bar}, $User{Foo} );
channel_has_users $Chan{Baz}, [ 'Ba[]r', 'fOO' ],
  'Channel->user_list after readding users ok';
$Chan{Baz}->del_users( $User{Foo} );
channel_has_users $Chan{Baz}, [ 'Ba[]r' ],
  'Channel->user_list after del_users by obj ok';

channel_has_users $Chan{Quux}, [ 'Ba[]r' ],
  'Channel->user_list consistency check';

user_has_channels $User{Bar}, [ '#quux', '#B{az}' ],
  'User->channel_list (1) after del_users by obj ok';

user_has_channels $User{Foo}, [],
  'User->channel_list (2) after del_users by obj ok';

# Channel->del_user   (by name, folded)
#   -> #quux  => [ 'Ba[]r' ]
#   -> #B{az} => [ 'Ba[]r', 'fOO' ]
#  =>
#   -> #quux  => [ 'Ba[]r' ]
#   -> #B{az} => [ 'Ba[]r' ]
$Chan{Baz}->add_user( $User{Foo} );
user_has_channels $User{Foo}, [ '#B{az}' ];
$Chan{Baz}->del_user( 'Foo' );
channel_has_users $Chan{Baz}, [ 'Ba[]r' ],
  'Channel->user_list after del_user by name ok';
user_has_channels $User{Foo}, [],
  'User->channel_list after del_user by name ok';

# Channel->del_user   (by obj)
#   -> #quux  => [ 'Ba[]r' ]
#   -> #B{az} => [ 'Ba[]r', 'fOO' ]
#  =>
#   -> #quux  => [ 'Ba[]r' ]
#   -> #B{az} => [ 'Ba[]r' ]
$Chan{Baz}->add_user( $User{Foo} );
$Chan{Baz}->del_user( $User{Foo} );
channel_has_users $Chan{Baz}, [ 'Ba[]r' ],
  'Channel->user_list after del_user by obj ok';
user_has_channels $User{Foo}, [];

# User->add_channels
#   -> #quux  => [ 'Ba[]r', 'fOO' ]
#   -> #B{az} => [ 'Ba[]r', 'fOO' ]
$User{Foo}->add_channels( $Chan{Quux}, $Chan{Baz} );
channel_has_users $Chan{Quux}, [qw/Ba[]r fOO/],
  'Channel->user_list after User->add_channels ok';
channel_has_users $Chan{Baz}, [qw/Ba[]r fOO/];
user_has_channels $User{Bar}, ['#quux', '#B{az}'];
user_has_channels $User{Foo}, ['#quux', '#B{az}'];

# User->add_channel
#   -> #quux  => [ 'Ba[]r', 'fOO' ]
#   -> #B{az} => [ 'Ba[]r' ]
#  =>
#   -> #quux  => [ 'Ba[]r', 'fOO' ]
#   -> #B{az} => [ 'Ba[]r', 'fOO' ]
$Chan{Baz}->del_user( $User{Foo} );
$User{Foo}->add_channel( $Chan{Baz} );
channel_has_users $Chan{Quux}, [qw/Ba[]r fOO/],
  'Channel->user_list after User->add_channel ok';
channel_has_users $Chan{Baz}, [qw/Ba[]r fOO/];
user_has_channels $User{Bar}, ['#quux', '#B{az}'];
user_has_channels $User{Foo}, ['#quux', '#B{az}'];

# User->del_channels  (by name)
# User->del_channels  (by obj)
# User->del_channel   (by name)
# User->del_channels  (by obj)

# FIXME deleting channel from state deletes from users
# State->del_channels  (by name)
# State->del_channels  (by obj)
# State->del_channel   (by name)
# State->del_channels  (by obj)

# FIXME deleting user from state deletes from channels

# FIXME should adding a previously nonexistant channel to a User belonging to
#  a State add to State, warn, die?

## strict-rfc1459
# FIXME

## ascii
# FIXME


## exceptions
# bad ->build_user args
# bad ->build_channel args
# FIXME

done_testing
