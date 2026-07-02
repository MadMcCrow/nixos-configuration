# modules.nix
# use import-tree magic to make our custom TOML parser
{
  self,
  lib,
  import-tree,
  nixpkgs,
  ...
} :
let
  # convert a nonOS module path to a nixos module
  toNixosModule = path:
    { config, lib, pkgs, ... }@args:
    let
      relative = lib.removeSuffix ".nix" (
        lib.removePrefix (toString ./modules + "/") (toString path)
      );
      optPath = lib.splitString "/" relative;
      cfg     = lib.attrByPath optPath { } config;
      leaf    = import path;
      result  = if builtins.isFunction leaf then leaf (args // { inherit cfg; }) else leaf;
    in {
      _file   = path;
      imports = result.imports or [ ];
      options = lib.setAttrByPath optPath result.options;
      config  = result.config;
    };

in paths : (import-tree paths).map toNixosModule
