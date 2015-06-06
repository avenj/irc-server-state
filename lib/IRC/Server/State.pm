package IRC::Server::State;

use List::Objects::Types -all;
use Types::Standard -all;
use IRC::Server::State::Types -all;

use IRC::Toolkit::Case;

use Moo 2;

has casefold_users => (
  lazy    => 1,
  is      => 'ro',
  isa     => Bool,
  builder => sub { 1 },
);

has casemap => (
  lazy    => 1,
  is      => 'ro',
  isa     => ValidCasemap,
  builder => sub { 'rfc1459' },
);


with 'IRC::Server::State::Role::UserCollection';
with 'IRC::Server::State::Role::ChannelCollection';

# FIXME override del_user / del_channel to iterate & delete all relevant
#  ->del_user should remove user from all channels in $user_obj->channels
#  ->del_channel should remove channel from all users in $chan_obj->users


has peers => (
  # IRC::Server::Tree ?
  #  needs reworked anyway ...
  #  possibly something MXR::DependsOn-based
  #  TypedHash[ ConsumerOf['MooX::Role::DependsOn'] ] ?
  #  possibly Peer should be a consumer of DependsOn instead,
  #  +{ $name => $obj }
);


print <<'_END'

::State
 has casemap
 has channels (hash_of Channel keyed on casefolded channame)
 has users    (hash_of User keyed on casefolded nick or TS6 ID)
 has network  (IRC::Server::Tree::Network?)

::State::Channel
 has casemap  (ScalarRef to $state->casemap ?)
 has users    (hash_of weak ref to User keyed on casefolded nick or TS6 ID)
 has modes    (hash_of Str keyed on mode)
 has topic    (Dict ?)
 has lists    (hash_of TypedHash[Int] +{ b => +{ $item => 1 } })

::State::User
 has casemap
 has nickname (Str)
 has username (Str)
 has hostmask (Str)
 has realhost (Str)
 has ipaddr   (Str)
 has modes    (



_END
unless caller; 1;

# vim: ts=2 sw=2 et sts=2 ft=perl
