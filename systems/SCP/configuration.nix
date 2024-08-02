# SCP
# Samsung Chromebook Pro (Caroline)
# this is an old chromebook running NixOS on top of MrChromebox UEFI
{ ... }: {
  #
  networking.hostName = "smyrno";

  # filesystem :
  nixos.fileSystem.enable = true;
  nixos.fileSystem.boot = "TODO";
  nixos.fileSystem.luks = "TODO";
  nixos.fileSystem.swap = true;

  # enable flatpak software
  nixos.flatpak.enable = true;

  # maybe consider adding swap ?
  system.stateVersion = "24.05";
}
