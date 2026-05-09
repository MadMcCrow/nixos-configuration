{ lib, tomlPath ? "", ... }:
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
  nonOS = cur: config: { nonConfig, nonOptions }: let
    p = splitString "/" (dirOf cur.file);
  in {
    options = setAttrByPath p nonOptions;
    config = nonConfig (attrByPath p (throw "nonOS option not found: ${join "." p}") config);
  };
}
