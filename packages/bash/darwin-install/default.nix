# darwin-install
# basic install/update script written in bash
{
  wrapbash,
  curl,
  nix,
  lib,
  bash,
  ...
}:
wrapbash {
  name = "darwin-install";
  runtimeInputs = [
    nix
    curl
  ];
  meta.platforms = lib.intersectLists bash.meta.platforms lib.platforms.darwin;
}
