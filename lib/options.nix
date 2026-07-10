{
  lib,
  tomlPath ? "",
  self,
  import-tree,
  ...
}@args:
with lib;
with builtins;
{
  #
  # make a boolean option, with default = true.
  #
  mkDisableOption = d: mkEnableOption d // { default = true; };

  #
  # mkStringOption that requires an input
  #
  mkNonEmptyStrOption =
    description: default:
    mkOption {
      inherit description default;
      type = types.nonEmptyStr;
    };

  #
  mkStrListOption =
    description: default:
    mkOption {
      inherit description default;
      type = with types; listOf nonEmptyStr;
    };

  # mkOption that takes a path
  mkPathOption =
    description: default:
    mkOption {
      inherit description default;
      type = types.nullOr types.path;
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
  isDevice =
    x:
    if x == null then
      true
    else if isPath x then
      true
    else if isString x then
      true
    else
      false;
  deviceType =
    with types;
    addCheck (nullOr (oneOf [
      str
      path
    ])) isDevice;

  filesystemType =
    with types;
    submodule {
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
}
