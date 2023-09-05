# flake.nix
# the flake responsible for all my systems and apps
{
  description = "MadMcCrow Systems configurations";

  # flake inputs :
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";

    # impermanence
    impermanence.url = "github:nix-community/impermanence";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # macOS
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.05-darwin";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager-darwin.url = "github:nix-community/home-manager/release-23.05";
    home-manager-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # Agenix for secrets
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "darwin";

    # pycnix for python scripts
    pycnix.url = "github:MadMcCrow/pycnix";
    pycnix.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = { self,  ... }@inputs:
    let

      # modules shared between linux and MacOS
      baseModules = [ ./platform ./users ./secrets ];

      # shortcut functions :
      nixOSx86 = sysModule :
        let
          pkgs = inputs.nixpkgs;
          system = "x86_64-linux";
          specialArgs = inputs;
        in pkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = baseModules ++ [
            ./linux
            inputs.agenix.nixosModules.default
            inputs.home-manager.nixosModule
            inputs.home-manager.nixosModules.home-manager
            (import sysModule {inherit pkgs;})
          ];
        };

      darwinAarch64 =  sysModule :
        let
          system = "aarch64-darwin";
        in inputs.darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            ./darwin
            inputs.agenix.darwinModules.default
            inputs.home-manager-darwin.darwinModules.home-manager
            sysModule ] ++ baseModules ++ [{platform = "aarch64-darwin";}];
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
      darwinSystems = {
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
      devShells = inputs.nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin"]  (
      system: 
      {
        default = let
          pkgs = inputs.nixpkgs.legacyPackages.${system};
          paths = map (x : import x ({inherit pkgs;} // inputs) ) shells;
        in
          # this is sad, for now I just merge build inputs but another solution would be great
          # pkgs.buildEnv { name = "nixos-configuration shell";  inherit paths; };
          pkgs.mkShell {buildInputs = builtins.concatLists (map  (x: x.buildInputs) paths) ;};
      }
      );
      
    };
}
