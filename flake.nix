# flake.nix
{
  description = "NonOS is an opinionated OS based on NixOS";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # automatic imports :
    import-tree.url = "github:denful/import-tree";

    # additional hardware-specific modules for linux
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # lanzaboote: secure boot for NixOS
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # disko: disk partitioning for NixOS
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # pyproject-nix: build python tools for OS commands
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # uv2nix: faster python package builds
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # pyproject-build-systems: wraps uv2nix and pyproject-nix together
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];


      mapOutputs = with nixpkgs.lib;
        func:
        genAttrs systems (system:
          func (inputs // {
            inherit inputs;
            inherit system;
            pkgs = inputs.nixpkgs.legacyPackages.${system};
            inherit (nixpkgs) lib;
          }));

    in rec {
      lib = mapOutputs ( import ./lib );

      checks = mapOutputs ({ system, ... }: {
        test-host = (lib.${system}.mkSystem
          ./tests/default_host.toml).config.system.build.toplevel;
      });

      packages = mapOutputs ({pkgs,...} @args : pkgs.callPackages ./packages args);
      apps = mapOutputs ({ system, ... }: {
        os-update = {
          type = "app";
          program = "${packages.${system}.os-update}/bin/os-update";
        };
      });
    };
}
