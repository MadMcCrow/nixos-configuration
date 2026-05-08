{lib , ...} :
with lib;
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

 deviceType = with types; addCheck (nullOr (oneOf [ str path ])) (x: );
in
description : mkOption {
  type = deviceType;
  default = null;
  inherit description;
}
