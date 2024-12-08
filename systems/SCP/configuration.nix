# SCP
# Samsung Chromebook Pro (Caroline)
# this is an old chromebook running NixOS on top of MrChromebox UEFI
{ _ }:
{
  #
  networking.hostName = "smyrno";

  # our settings :
  nixos.fileSystem = {
    enable = true;
    boot = "TODO";
    luks = "TODO";
    swap = true;
  };

  nixos.flatpak.enable = true;

  system.stateVersion = "24.05";
}
