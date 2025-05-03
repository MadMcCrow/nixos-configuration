# Linux specific config for home-manager
{ config, home-manager, ... }:
{
  imports = [
    home-manager.nixosModules.home-manager
    ../shared.nix
  ];

  config = {
    home-manager = {
      useGlobalPkgs = false; # TODO : move to true and remove nixpkgs options from HM
      useUserPackages = true;
      # extraModules = [ plasma-manager.homeManagerModules.plasma-manager ];
    };
  };
}
