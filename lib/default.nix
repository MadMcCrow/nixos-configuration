# import all our libs
args:
with builtins;
foldl' (x : y: x // (import y args)) {}
[
  ./system
  ./options.nix
  ./version.nix
]
