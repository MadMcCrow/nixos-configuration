# lib/default.nix
# import all custom made libraries :
{ lib, ... } :
let
# lib modules
mods = [
  ./options.nix
];
# our concatenated library :
extralib = builtins.foldl' (x : y : x // import y ({inherit lib;} // x)) {} mods;
in
# append to default lib :
lib // extralib
