# lib/default.nix
# expose our API
# see flake.nix
inputs@{nixpkgs, ...} :
{
  buildsystem = import ./buildsystem.nix inputs;

} // (import ./version.nix inputs)
