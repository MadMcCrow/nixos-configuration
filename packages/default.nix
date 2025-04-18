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

  appendPackage = system : 
    (acc: x:
    let
      pkgs = import (if lib.hasSuffix "darwin" system then nixpkgs-darwin else nixpkgs) {inherit system;};
      inherit (pkgs) callPackage;
      p = callPackage x {  wrapbash = callPackage ./wrapbash.nix { }; };
    in
    acc
    // (lib.optionalAttrs (!p.meta.unsupported) (lib.listToAttrs [
      {
        name = lib.getName p;
        value = p;
      }
    ])));
in
# for all potentially supported platforms 
nixpkgs.lib.genAttrs systems
( system : 
(lib.foldl' (appendPackage system) { } [
  ./bcrypt
  ./darwin-install
  ./termcolors #TODO
  ./luks-enroll
  ./nbl
  ./nixos-gen-setup
  # ./nixos-update # TODO
  ./zfs-fzifdso
  # ./zfs-tzpfms # TODO
]))
