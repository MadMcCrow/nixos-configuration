# flake.nix
# the flake responsible for all my systems and apps
{
  description = "MadMcCrow Systems configurations";

  # flake inputs :
  inputs = {
    # Linux:
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";
    # impermanence
    impermanence.url = "github:nix-community/impermanence";
    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # plasma
    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    # macOS:
    # nixpkgs
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.05-darwin";
    # nix-darwin
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    # HM for MacOS
    home-manager-darwin.url = "github:nix-community/home-manager/release-23.05";
    home-manager-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # pycnix for python scripts
    # TODO : move secrets to different flake
    pycnix.url = "github:MadMcCrow/pycnix";
  };

  outputs = { self, ... }@inputs:
    let

      # modules shared between linux and MacOS
      baseModules = [ ./nix ./users ];

      # shortcut functions :
      nixOSx86 = sysModule:
        let
          pkgs = inputs.nixpkgs;
          system = "x86_64-linux";
          specialArgs = inputs;
        in pkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = baseModules ++ [
            ./linux
            ./secrets
            inputs.home-manager.nixosModule
            inputs.home-manager.nixosModules.home-manager
            sysModule
          ];
        };

      darwinAarch64 = sysModule:
        inputs.darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = inputs;
          modules = [
            ./darwin
            inputs.home-manager-darwin.darwinModules.home-manager
            sysModule
          ] ++ baseModules;
        };

      shells = [ ./secrets/shell.nix ];

    in {

      #Linux : Nixos
      nixosConfigurations = {
        # AF, my personal Desktop PC
        nixAF = nixOSx86 ./systems/AF.nix;

        # my NUC acting as a headless server
        nixNUC = nixOSx86 ./systems/NUC.nix;
      };

      # MacOS
      darwinConfigurations = {
        # my MacBook Air
        Noes-MacBook-Air = darwinAarch64 ./systems/MBA.nix;
      };

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

      # a shell for every development experiment
      devShells = inputs.nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ] (system: {
        default = let
          pkgs = inputs.nixpkgs.legacyPackages.${system};
          paths = map (x: import x ({ inherit pkgs; } // inputs)) shells;
          # this is sad, for now I just merge build inputs but another solution would be great
          # another solution would be to merge all attributes but this would take too much time for nothing
          # pkgs.buildEnv { name = "nixos-configuration shell";  inherit paths; };
        in pkgs.mkShell {
          buildInputs = builtins.concatLists (map (x: x.buildInputs) paths);
        };
      });

    };
}
