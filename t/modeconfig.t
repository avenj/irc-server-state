use Test::More;
use strict; use warnings;

use IRC::Server::State::ModeConfig;


subtest 'attribute validation' => sub {
  eval {; IRC::Server::State::ModeConfig->new };
  like $@, qr/required/, "empty constructor opts dies";

  eval {;
    IRC::Server::State::ModeConfig->new(param_always => ['a','b'])
  };
  like $@, qr/param_when_set/, 'missing param_when_set dies';

  eval {;
    IRC::Server::State::ModeConfig->new(param_when_set => ['a','b'])
  };
  like $@, qr/param_always/, 'missing param_always dies';

  eval {;
    IRC::Server::State::ModeConfig->new(
      param_always => ['a', 'b'],
      param_when_set => ['c','d','a'],
    )
  };
  like $@, qr/conflict.*'a'/i, 'conflicting mode dies';
};

done_testing
