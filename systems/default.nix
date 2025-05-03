# systems/default.nix
# support all different systems
# TODO : create a master command to merge between darwinSystem and nixosSystem
{ self, ... }@args:
let
  addModules = list: map (x: self + "/modules/${x}") list;
  addUsers = list: map (x: self + "/users/${x}") list;
  # add functions to args
  importArgs = args // {
    inherit addUsers addModules;
  };
in
{
  nixosConfigurations = import ./linux importArgs;
  darwinConfigurations = import ./macos importArgs;
}
