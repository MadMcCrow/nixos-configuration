{
  description = "NonOS is an opinionated OS based on NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:denful/import-tree";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, nixpkgs, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
      systems = [ "x86_64-linux" "aarch64-linux" ];

      flake = let
        nonlib = import ./lib (inputs // { inherit (nixpkgs) lib; });
      in {
        lib = nonlib;
        checks = {
          default_host = nonlib.topLevel (nonlib.mkSystem ./tests/default_host.toml);
        };
      };

      perSystem = { config, system, pkgs, ... }: {
        # For standardised reproducible formatting with `nix fmt`
        formatter = pkgs.nixfmt-rfc-style;

        packages = pkgs.callPackages ./packages (inputs // {
          inherit (inputs.self) lib;
          inherit system;
        });

        apps = {
               os-update = {
                 type = "app";
                 program = "${config.packages.os-update}/bin/os-update";
               };
               os-install = {
                 type = "app";
                 program = "${config.packages.os-install}/bin/os-install";
               };
             };


      };
    });
}
