package IRC::Server::State;

use Carp;

use Module::Runtime 'use_module';

use List::Objects::Types -all;
use Types::Standard -all;
use IRC::Server::State::Types -all;

use IRC::Toolkit::Case;

use Moo 2;

with 
     'IRC::Server::State::Role::HasCasemap',
     'IRC::Server::State::Role::UserCollection',
     'IRC::Server::State::Role::ChannelCollection',
;

has user_class => (
  lazy      => 1,
  is        => 'ro',
  isa       => Str,
  builder   => sub { 'IRC::Server::State::User' },
);

sub build_user {
  my $self = shift;
  use_module( $self->user_class )->new(
    state   => $self,
    casemap => $self->casemap,
    @_
  )
}

sub build_and_add_user {
  my $self = shift;
  $self->add_user( $self->build_user(@_) )
}

around del_user => sub {
  my ($orig, $self, $name) = @_;
  my $uobj = $self->$orig($name) // return undef;
  my $actual_name = lc_irc($name, $self->casemap);
  for my $channame ($uobj->channel_list) {
    $self->_chans->{$channame}->_del_user($actual_name) # FIXME
  }
  $uobj
};


has channel_class => (
  lazy      => 1,
  is        => 'ro',
  isa       => Str,
  builder   => sub { 'IRC::Server::State::Channel' },
);

sub build_channel {
  my $self = shift;
  use_module( $self->channel_class )->new(
    state   => $self,
    casemap => $self->casemap,
    @_
  )
}

sub build_and_add_channel {
  my $self = shift;
  $self->add_channel( $self->build_channel(@_) )
}

around del_channel => sub {
  my ($orig, $self, $name) = @_;
  my $chobj = $self->$orig($name) // return undef;
  my $actual_name = lc_irc $name, $self->casemap;
  for my $nickname ($chobj->user_list) {
    $self->_users->{$nickname}->_del_channel($actual_name)
  }
  $chobj
};


#has _peers => (
  # IRC::Server::Tree ?
  #  needs reworked anyway ...
  #  possibly something MXR::DependsOn-based
  #  TypedHash[ ConsumerOf['MooX::Role::DependsOn'] ] ?
  #  possibly Peer should be a consumer of DependsOn instead,
  #  +{ $name => $obj }
#);
1;

# vim: ts=2 sw=2 et sts=2 ft=perl
