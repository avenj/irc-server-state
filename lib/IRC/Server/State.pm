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

around del_user => sub {
  my ($orig, $self, $name) = @_;
  my $user_obj = $self->$orig($name) // return undef;
  my @removed;
  $user_obj->channels->kv_map(sub {
    my ($chan_name, $chan_obj) = @_;
    push @removed, $chan_name
      if $chan_obj->del_user($name);
  });
  \@removed
};

around del_channel => sub {
  my ($orig, $self, $name) = @_;
  my $chan_obj = $self->$orig($name);
  my @removed;
  $chan_obj->users->kv_map(sub {
    my ($user_name, $user_obj) = @_;
    push @removed, $user_name
      if $user_obj->del_channel($name);
  });
  \@removed
};



has peers => (
  # IRC::Server::Tree ?
  #  needs reworked anyway ...
  #  possibly something MXR::DependsOn-based
  #  TypedHash[ ConsumerOf['MooX::Role::DependsOn'] ] ?
  #  possibly Peer should be a consumer of DependsOn instead,
  #  +{ $name => $obj }
);


print <<'_END'

FIXME

::State::Channel
 has modes    (hash_of Str keyed on mode)
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
