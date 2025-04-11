# default.nix
{
  callPackage,
  lib,
  system,
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
    // (lib.optionalAttrs (!p.meta.unsupported) (lib.listToAttrs [
      {
        name = lib.getName p;
        value = p;
      }
    ]));
in
lib.foldl' appendPackage { } [
  ./bcrypt
  ./darwin-install
  # ./termcolors #TODO
  ./luks-enroll
  ./nbl
  ./nixos-gen-setup
  # ./nixos-update # TODO
  ./zfs-fzifdso
  # ./zfs-tzpfms # TODO
]
