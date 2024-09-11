# SCP
# Samsung Chromebook Pro (Caroline)
# this is an old chromebook running NixOS on top of MrChromebox UEFI
{ ... }:
{
  #
  networking.hostName = "smyrno";

  # our settings :
  nixos.fileSystem.enable = true;
  nixos.fileSystem.boot = "TODO";
  nixos.fileSystem.luks = "TODO";
  nixos.fileSystem.swap = true;
  nixos.flatpak.enable = true;

  system.stateVersion = "24.05";
}
