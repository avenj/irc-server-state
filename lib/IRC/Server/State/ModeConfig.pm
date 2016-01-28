package IRC::Server::State::ModeConfig;

use strictures 2;
use Carp;

use Types::Standard -types;

use IRC::Toolkit::Modes ();


use Moo;

has param_always => (
  required  => 1,
  is        => 'ro',
  isa       => ArrayRef,
);

has param_when_set => (
  required  => 1,
  is        => 'ro',
  isa       => ArrayRef,
);

sub mode_to_array {
  my ($self, $mode_string, @params) = @_;
  IRC::Toolkit::Modes::mode_to_array( $mode_string,
    param_always => $self->param_always,
    param_set    => $self->param_when_set,
    ( @params ? (params => [@params]) : () )
  )
}

1;
