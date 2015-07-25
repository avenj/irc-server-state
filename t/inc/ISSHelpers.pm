package
  ISSHelpers;

use Carp 'confess';
use strictures 2;
use Scalar::Util 'blessed', 'reftype';

use Test::Deep::NoTest qw/
  cmp_deeply
  cmp_details
  deep_diag
/;

use parent 'Exporter';

our @EXPORT = our @EXPORT_OK = qw/
  user_has_channels
  channel_has_users
/;


my $Test = Test::Builder->new;


sub channel_has_users ($$;$) {
  my ($chan, $nicklist, $desc) = @_;

  confess "Expected IRC::Server::State::Channel but got '$chan'"
    unless blessed $chan and $chan->isa('IRC::Server::State::Channel');
  confess "Expected ARRAY of nicknames but got '$nicklist'"
    unless reftype $nicklist eq 'ARRAY';
  $desc = $chan->name . ' has users ' . join ', ', @$nicklist
    unless defined $desc;

  my ($ok, $stack) = cmp_details
    +{ map {; $_ => 1 } $chan->user_list },
    +{ map {; $_ => 1 } @$nicklist };

  unless ( $Test->ok($ok, $desc) && return 1 ) {
    my $cname = $chan->name;
    my $ulist = join ', ', @$nicklist; 
    my $actual_list = join ', ', $chan->user_list;
    $Test->diag(
      deep_diag($stack), "\n",
      "Expected channel '$cname' to contain nicks '$ulist'\n",
      "Got: '$actual_list'\n"
    )
  }
  ()
}

sub user_has_channels ($$;$) {
  my ($user, $chanlist, $desc) = @_;

  confess "Expected IRC::Server::State::User but got '$user'"
    unless blessed $user and $user->isa('IRC::Server::State::User');
  confess "Expected ARRAY of channel names but got '$chanlist'"
    unless reftype $chanlist eq 'ARRAY';
  $desc = $user->nickname . ' has channels ' . join ', ', @$chanlist
    unless defined $desc;

  my ($ok, $stack) = cmp_details
    +{ map {; $_ => 1 } $user->channel_list },
    +{ map {; $_ => 1 } @$chanlist };

  unless ( $Test->ok($ok, $desc) && return 1 ) {
    my $nick  = $user->nickname;
    my $clist = join ', ', @$chanlist;
    my $actual_list = join ', ', $user->channel_list;
    $Test->diag(
      deep_diag($stack), "\n",
      "Expected user '$nick' to contain channels '$clist'\n",
      "Got: '$actual_list'\n"
    )
  }
  ()
}


1;
