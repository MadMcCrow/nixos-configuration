# import all our libs
args:
builtins.foldl' (a: b: a // import b args) { } [
  ./systems
  ./options.nix
  ./python.nix
]
