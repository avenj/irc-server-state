use Test::More;

use strictures 2;

use lib 't/inc';
use ISSHelpers qw/
  user_has_channels
  channel_has_users
/;

{ package
    IRC::Server::State::Channel;
  sub new { bless +{}, shift }
  sub user_list { 'foo', 'bar', 'baz' }
  sub name { '#quux' }
}
{ package
    IRC::Server::State::User;
  sub new { bless +{}, shift }
  sub channel_list { '#quux', '#meh' }
  sub nickname { 'foo' }
}

my $user = IRC::Server::State::User->new;
my $chan = IRC::Server::State::Channel->new;

# default desc
channel_has_users $chan, [qw/bar baz foo/];
user_has_channels $user, ['#meh', '#quux'];

# specified desc
channel_has_users $chan, [qw/bar baz foo/],
  'channel_has_users ok';
user_has_channels $user, ['#meh', '#quux'],
  'user_has_channels ok';

done_testing
