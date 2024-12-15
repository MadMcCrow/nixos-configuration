# systems/default.nix
# support all different systems
args : {
  nixosConfigurations = import ./linux args;
  darwinConfigurations = import ./macos args;
}
