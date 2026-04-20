# import all our libs
args:
builtins.foldl' (a: b: a // import b args) {} [
  ./python
  ./systems
  ./options.nix
]
