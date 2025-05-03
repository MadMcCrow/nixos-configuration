# default.nix
{
  nixpkgs,
  nixpkgs-darwin,
  ...
}:
let
  # supported systems
  systems = [
    "x86_64-darwin"
    "aarch64-darwin"
    "x86_64-linux"
    "aarch64-linux"
  ];

  # shortcut
  inherit (nixpkgs) lib;

  # helper function :

  appendPackage =
    system:
    (
      acc: x:
      let
        pkgs = import (if lib.hasSuffix "darwin" system then nixpkgs-darwin else nixpkgs) {
          inherit system;
        };
        ps = pkgs.callPackages x { };
      in
      acc // (lib.filterAttrs (n: p: !p.meta.unsupported) ps)
    );
in
# for all potentially supported platforms
nixpkgs.lib.genAttrs systems (
  system:
  (lib.foldl' (appendPackage system) { } [
    ./python # my python scripts
    #./bash    # my bash scripts
    #./extern  # package not from me
  ])
)
