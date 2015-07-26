requires "perl"                     => "5.016",
requires "strictures"               => "2";
requires "IRC::Toolkit"             => "0";
requires "List::Objects::Types"     => "1";
requires "List::Objects::WithUtils" => "2";
requires "Module::Runtime"          => "0";
requires "Moo"                      => "2";
requires "Type::Tiny"               => "1";

on 'test' => sub {
  requires "Test::Deep::NoTest"  => "0";
  requires "Test::Memory::Cycle" => "0";
};
