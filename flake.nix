# flake.nix
# the flake responsible for all my systems and apps
{
  description = "MadMcCrow Systems configurations";
  # flake inputs :
  inputs = {
    # Linux:
    nixpkgs-latest.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
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

  outputs = { self, nixpkgs, ... }@inputs:
    let
      # shortcut functions :
      nixOSx86 = sysModule:
        nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            inherit (inputs) nixpkgs plasma-manager;
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
            nixpkgs = inputs.nixpkgs-darwin;
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
        trantor = nixOSx86 ./systems/TAF;
        terminus = nixOSx86 ./systems/NUC;
        smyrno = nixOSx86 ./systems/SCP;
      };

      # MacOS
      darwinConfigurations.anacreon = darwinAarch64 ./systems/MBA;

      # support packages :
      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ]
        (system:
          import ./packages { pkgs = nixpkgs.legacyPackages.${system}; });
    };
}
