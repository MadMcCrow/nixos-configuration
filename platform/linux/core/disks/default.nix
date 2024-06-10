# core/disks/default.nix
# 	Nixos disks and partition setup
{ ... }: {
  imports = [ ./tools.nix ./samba.nix ];
}
