# systems/default.nix
# build the different systems, MacOS and linux all together
# linux deps :
{ nixpkgs-unstable, nixpkgs, nixos-hardware, home-manager, lanzaboote,
# plasma-manager,
# darwin deps :
darwin, nixpkgs-darwin, home-manager-darwin, ... }:
let
  # shortcut function to help  
  mkLinux = { modules, nixpkgs ? nixpkgs, system ? "x86_64-linux" }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit nixpkgs nixos-hardware; };
      modules = [
        ../platform/linux
        ../users
        lanzaboote.nixosModules.lanzaboote
        home-manager.nixosModule
        home-manager.nixosModules.home-manager
      ] ++ modules;
    };

  # MACOS 
  mkMacOS = { module, nixpkgs ? nixpkgs-darwin, system ? "aarch64-darwin" }:
    darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit nixpkgs; };
      modules = [
        ../platform/darwin
        ../users
        home-manager-darwin.darwinModules.home-manager
        module
      ];
    };
in {
  nixosConfigurations = {
    # NUC
    terminus = mkLinux { modules = [ ./NUC ]; };
    # desktop PC
    trantor = mkLinux {
      nixpkgs = nixpkgs; # unstable crashes the nvidia drivers
      modules = [ ./TAF ];
    };
    # chromebook
    smyrno = mkLinux { module = [ ./SCP ]; };

    # live iso for installation :
    iso = mkLinux {
      nixpkgs = nixpkgs-unstable;
      module = [ ./ISO ];
    };
  };

  darwinConfigurations = {
    # MacBook Air M1
    anacreon = mkMacOS { module = ./MBA; };
  };
}

