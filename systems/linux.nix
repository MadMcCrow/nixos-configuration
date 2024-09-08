# functions to make linux systems
# TODO :
# move this to be one with the platform code
{
  nixpkgs,
  nixpkgs-unstable,
  nixos-hardware,
  lanzaboote,
  home-manager,
  ...
}:
{
  # helper function 
  mkLinux =
    {
      modules,
      system ? "x86_64-linux",
    }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit nixpkgs nixpkgs-unstable nixos-hardware;
      };
      modules = [
        ../platform/linux
        ../users
        lanzaboote.nixosModules.lanzaboote
        home-manager.nixosModule
        home-manager.nixosModules.home-manager
      ] ++ modules;
    };
}
