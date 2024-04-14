# flake.nix
# the flake responsible for all my systems and apps
{
  description = "MadMcCrow Systems configurations";
  # flake inputs :
  inputs = {
    # Linux:
    nixpkgs-latest.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    impermanence.url = "github:nix-community/impermanence";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # plasma-manager.url = "github:pjones/plasma-manager";
    # plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    # plasma-manager.inputs.home-manager.follows = "home-manager";

    # macOS:
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager-darwin.url = "github:nix-community/home-manager/release-23.11";
    home-manager-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs = { self, ... }@inputs:
    let
      # shortcut functions :
      nixOSx86 = sysModule:
        inputs.nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            inherit (inputs) impermanence nixpkgs plasma-manager;
            pkgs-latest = import inputs.nixpkgs-latest { inherit system; };
          };
          modules = [
            ./platform/linux
            ./users
            inputs.home-manager.nixosModule
            inputs.home-manager.nixosModules.home-manager
            sysModule
          ];
        };

      darwinAarch64 = sysModule:
        inputs.darwin.lib.darwinSystem rec {
          system = "aarch64-darwin";
          specialArgs = {
            inherit (inputs) impermanence nixpkgs;
            pkgs-latest = import inputs.nixpkgs-latest { inherit system; };
          };
          modules = [
            ./platform/darwin
            ./users
            inputs.home-manager-darwin.darwinModules.home-manager
            sysModule
          ];
        };

    in {

      #Linux : Nixos
      nixosConfigurations = {
        Trantor    = nixOSx86 ./systems/TAF.nix;
        Foundation = nixOSx86 ./systems/NUC.nix;
        Smyrno     = nixOSx86 ./systems/SCP.nix;
      };
      # MacOS
      darwinConfigurations = {
        Anacreon = darwinAarch64 ./systems/MBA.nix;
      };

      # TODO : move to darwin platform only !
      overlays = {
        # Overlay useful on Macs with Apple Silicon
        apple-silicon = final: prev:
          (prev.stdenv.system == "aarch64-darwin") {
            # Add access to x86 packages if system is running Apple Silicon
            pkgs-x86 = import inputs.nixpkgs {
              system = "x86_64-darwin";
              inherit (inputs.nixpkgs) config;
            };
          };
      };
    };
}
