# flake.nix
# the flake responsible for all my systems and apps
{
  description = "MadMcCrow Systems configurations";

  # flake inputs :
  inputs = {
    # Nixpkgs
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };

    # old version for apps that fails to work properly on unstable
    nixpkgs-stable = { url = "github:nixos/nixpkgs/nixos-23.05"; };

    # Home manager
    home-manager = {
      # use /release-22.11 for stable
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # impermanence
    impermanence.url = "github:nix-community/impermanence";

    # nixpkgs for MacOS
    nixpkgs-darwin = { url = "github:nixos/nixpkgs/nixpkgs-23.05-darwin"; };

    # macOS
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

  };

  outputs = { self, nixpkgs, darwin, home-manager, ... }@inputs:
    let
      # shortcut function :
      nixOSx86 = sysModule :
      let 
        pkgs = nixpkgs;
        system = "x86_64-linux";
        sysArgs = import sysModule {inherit pkgs system;};
      in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = inputs;
          modules = [ ./modules ./users/nixos.nix sysArgs {nix.registry.nixpkgs.flake = nixpkgs;}] ;
        };

      darwinAarch64 = system : 
      darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
          home-manager.darwinModules.home-manager
          ./modules 
          ./users/darwin.nix
          system { darwin.enable = true; darwin.apps.enable = true;}];
      };

    in {

      #Linux : Nixos
      nixosConfigurations = {
        # AF, my personal Desktop PC
        nixAF = nixOSx86  ./systems/AF.nix;

        # my NUC acting as a headless server
        NUC-Cloud = nixOSx86 ./systems/NUC.nix;
      };
      
      # MacOS
      darwinSystems = {
        Noes-MacBook-Air = darwinAarch64 ./systems/MBA.nix;
        };

      overlays = {
        # Overlay useful on Macs with Apple Silicon
        apple-silicon = final: prev:
          (prev.stdenv.system == "aarch64-darwin") {
            # Add access to x86 packages if system is running Apple Silicon
            pkgs-x86 = import inputs.nixpkgs {
              system = "x86_64-darwin";
              inherit (nixpkgs) config;
            };
          };
      };
    };
}

