# default.nix
{
  callPackage,
  lib,
  ...
}:
let
  # helper function :
  wrapbash = callPackage ./wrapbash.nix { };
  appendPackage =
    acc: x:
    let
      p = callPackage x { inherit wrapbash; };
    in
    acc
    // (lib.listToAttrs [
      {
        name = lib.getName p;
        value = p;
      }
    ]);
in
lib.foldl' appendPackage { } [
  ./bcrypt
  ./darwin-install
  ./termcolors
  ./luks-enroll
  ./nbl
  ./nixos-gen-setup
  # ./nixos-update # TODO
  ./zfs-fzifdso
  ./zfs-tzpfms
]
