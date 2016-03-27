package IRC::Server::State::ModeConfig;

use strictures 2;
use Carp;

use List::Objects::Types -types;
use Types::Standard -types;

use IRC::Toolkit::Modes ();


use Moo;

has param_always => (
  required  => 1,
  is        => 'ro',
  isa       => ImmutableArray,
  coerce    => 1,
);

has param_when_set => (
  required  => 1,
  is        => 'ro',
  isa       => ImmutableArray,
  coerce    => 1,
);

sub BUILD {
  my ($self) = @_;
  my $conflict = $self->param_always->intersection($self->param_when_set);
  unless ($conflict->is_empty) {
    confess "Conflicting modes in param_always/param_when_set: "
      . $conflict->map(sub { "'$_'" })->join(' ')
  }
}

sub mode_to_array {
  my ($self, $mode_string, @params) = @_;
  IRC::Toolkit::Modes::mode_to_array( $mode_string,
    param_always => $self->param_always->unbless,
    param_set    => $self->param_when_set->unbless,
    ( @params ? (params => [@params]) : () )
  )
}

1;
