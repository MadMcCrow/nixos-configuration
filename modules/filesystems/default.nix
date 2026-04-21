{ disko, ... }:
{
  imports = [
    disko.nixosModules.disko
    ./disko.nix
    ./options.nix
  ];
}
