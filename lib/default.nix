# lib/default.nix
# import all custom made libraries :
{ lib, ... } @args :
builtins.foldl' lib (map (x: import x args) [
  ./options.nix
])
