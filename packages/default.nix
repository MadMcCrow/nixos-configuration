# packages/default.nix
{ lib, callPackage, ... } @args :
with builtins;
let
  # helper to import derivations
  mkDrvAttrs = l : listToAttrs (
    map
      (
        x:
        let
          drv = callPackage x args;
        in
        {
          name = lib.getName drv;
          value = drv;
        }
      ) l);
  importArgs = x : args // x // {inherit mkDrvAttrs; };
  callAllPackages = l : lib.foldl (x: y: x // (import y (importArgs x) )) {}  l;
in
callAllPackages [
   ./applications
   ./plasma
   ./zfs
   ./system
]
