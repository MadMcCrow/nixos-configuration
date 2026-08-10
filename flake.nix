{
  description = "NonOS is an opinionated OS based on NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    import-tree.url = "github:denful/import-tree";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
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

  outputs =
    inputs@{
      flake-parts,
      self,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }: {
        # this is done to avoid spamming until things are stabilized
        systems = [
          "x86_64-linux"
          "aarch64-darwin"
        ]; # lib.systems.flakeExposed;

        imports = [ treefmt-nix.flakeModule ];

        flake =
          let
            args = inputs // {
              inherit lib;
            };
          in
          {
            # expose functions
            lib = import ./lib/systems.nix args;
            # expose modules
            nixosModules = import ./lib/modules.nix args;
            # check hosts
            nixosConfigurations = import ./lib/configurations.nix args;
          };

        perSystem =
          args@{
            pkgs,
            lib,
            ...
          }:
          with pkgs;
          let
            fmtEval = (treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build;
          in
          {
            # For standardised reproducible formatting with `nix fmt`
            formatter = fmtEval.wrapper;

            treefmt = import ./treefmt.nix args;

            # import everything in the `packages` folder, based on its path
            packages = lib.optionalAttrs pkgs.stdenv.isLinux (import (self + "/packages") (inputs // args));
            devShells = import ./devshells (inputs // args);

            checks = {
              formatting = fmtEval.check self;
              # tests = import ./tests (inputs //{ inherit pkgs lib;});
            };
          };
      }
    );
}
