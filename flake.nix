# flake.nix
# the flake responsible for all my systems and apps
{
  description = "MadMcCrow Systems configurations";

  # flake inputs :
  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    # Linux:
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    ## Secure boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { ... }@inputs:
    {
      # all of our systems
      inherit (import ./systems inputs) nixosConfigurations;
      packages = import ./packages inputs;
    };
}
