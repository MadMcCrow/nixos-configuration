{ lib, tomlPath ? "", self, ... }:
with lib;
with builtins; {
  #
  # make a boolean option, with default = true.
  #
  mkDisableOption = d: mkEnableOption d // { default = true; };

  #
  # mkStringOption that requires an input
  #
  mkNonEmptyStrOption = description: default:
    mkOption {
      inherit description default;
      type = types.nonEmptyStr;
    };

    #
    mkStrListOption = description: default:
      mkOption {
        inherit description default;
        type = with types; listOf nonEmptyStr;
      };

  # mkOption that takes a path
  mkPathOption = description: default:
    mkOption {
      inherit description default;
      type = types.nullOr types.path;
    };

  # mkMandatoryOption that tags the type and provides a null default to prevent early crashes
  mkMandatoryOption = { name, type, description } :
    with lib;
    let
      check = x: lib.asserts.assertMsg (x != null) "Mandatory option `${name}` not defined in TOML configuration `${tomlPath}`";
    in
    mkOption {
      inherit description;
      type = with types; addCheck ((nullOr type) // { _mandatory = true; }) check;
      default = null;
    };

  # devices can be specified with :
  # - a path (e.g. /dev/sda1)
  # - a device name (e.g. sda1)
  # - a UUID
  # - a label
  # - a partlabel
  # - a device path with UUID (e.g. /dev/disk/by-uuid/)
  # - a device path with label (e.g. /dev/disk/by-label/)
  # - a device path with partlabel (e.g. /dev/disk/by-partlabel/)
  isDevice = x:
        if x == null then true
        else if isPath x then true
        else if isString x then true
        else false
      ;
  deviceType = with types; addCheck (nullOr (oneOf [ str path ])) isDevice;

  filesystemType = with types; submodule {
    options = {
      device = mkOption {
        description = "the device holding the persist directory";
        type = deviceType;
        default = null;
      };
      mountPoint = mkOption {
        description = "the mount point for the persist directory";
        type = path;
        default = null;
      };
    };
  };

  # use it with __curPos to get an option path that matches the folder hierarchy
  # example usage: nonOS __curPos config { nonConfig = ; nonOptions = ; }
  nonOS = cur: config: { nonConfig, nonOptions ? {}, globals ? {} }: let
    p = splitString "/" (dirOf cur.file);
    globalOption = "_nonOS";
  in {
    options = setAttrByPath p nonOptions // { ${globalOption} = globals; };
    config = nonConfig {
        cfg = attrByPath p (throw "nonOS option not found: ${join "." p}") config;
        globals = config.${globalOption};
      };
  };

  collectOptions = { system ? "x86_64-linux" }:
     let
      evaluated = lib.evalModules {
         modules = (import-tree (self + "/modules")) ++ [
           # Stub out 'pkgs' so modules that reference it don't fail during
           # option collection (we never evaluate config values, only options).
           { _module.args = { pkgs = import <nixpkgs> { inherit system; }; }; }
         ];
       };

      # Recursively walk the evaluated option tree.
      # Each leaf where `_type == "option"` is a declared option;
      # everything else is a sub-tree (attribute set of more options).
      flattenOptions = prefix: tree:
         lib.foldlAttrs (acc: name: value:
           let
             path = if prefix == "" then name else "${prefix}.${name}";
           in
           # A real option node produced by lib.evalModules
           if value ? _type && value._type == "option" then
             acc // { ${path} = value; }
           # A sub-tree — recurse
           else if lib.isAttrs value then
             acc // flattenOptions path value
           else
             acc
         ) {} tree;
     in flattenOptions "" evaluated.options;
}
