# packages/zfs/default.nix
# zfs encryption tools
{ mkDrvAttrs, ... }:
mkDrvAttrs
    [
  ./zfs-fzifdso
  ./zfs-tzpfms
  ]
