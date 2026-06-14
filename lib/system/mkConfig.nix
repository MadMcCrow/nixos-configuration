# mkConfig.nix
# Arguments for mkSystem.nix and mkAppliance.nix
# This allows to pass common arguments to both functions.
{
  self,
  lib,
  import-tree,
  nixpkgs,
  ...
}@args:
# create the attribute set for "nixpkgs.lib.nixosSystem"
tomlPath:
let
  # read the TOML config file
  tomlConfig = builtins.fromTOML (builtins.readFile tomlPath);
  system = tomlConfig.system or "x86_64-linux";

  # append options, packages and custom lib to the specialArgs set
  specialArgs =
    let
      nonlib = import ../options.nix (args // { inherit tomlPath; });
      pkgs = import nixpkgs { inherit system; };

    in
    args
    // {
      inherit nonlib;
      nonpkgs = import (self + "/packages") (
        pkgs
        // args
        // {
          inherit system lib;
        }
      );
    };

in
{
  inherit system specialArgs;
  modules = [
    (import-tree (self + "/modules"))
    {
      # allow everything to handle errors and warnings ourselves.
      options.nonOS = lib.mkOption {
        type = lib.types.submodule {
          freeformType = lib.types.attrsOf lib.types.anything;
        };
        description = "NonOS configuration root (populated from TOML)";
      };

      # do all the custom parsing there :
      config.nonOS = tomlConfig;
    }
  ];
}
