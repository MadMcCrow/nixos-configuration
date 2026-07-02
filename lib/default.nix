# lib/default.nix
# expose our API
# see flake.nix
{nixpkgs, ...}  @inputs :
{
  buildsystem = import ./buildsystem.nix inputs;
}
