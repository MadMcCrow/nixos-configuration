# filesystem options
{lib, ... } :
let
  # devices can be specified with :
  # - a path (e.g. /dev/sda1)
  # - a device name (e.g. sda1)
  # - a UUID
  # - a label
  # - a partlabel
  # - a device path with UUID (e.g. /dev/disk/by-uuid/)
  # - a device path with label (e.g. /dev/disk/by-label/)
  # - a device path with partlabel (e.g. /dev/disk/by-partlabel/)

  mkDeviceOption = mkOption
in
{

options.nonOS.fileSystems = with lib; mkOption {
  description = "attrset of file systems to mount";
  type = types.submodule {
       options = {
         # TODO : add type check
        device = mkOption {
           description = "Full name of the user as displayed in UI";
           type = types.emptyOr types.str;
           default = "";
         };
        encrypted = mkEnableOption "enable encryption";
        mountpoint = mkPathOption "mount point for the file system" null;
        };
       };
    };
};
