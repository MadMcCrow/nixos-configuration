# core/disks/default.nix
# 	Nixos disks and partition setup
{ ... }: {
  imports = [ ./btrfs.nix ./tools.nix ./zfs.nix ./samba.nix ];
}
