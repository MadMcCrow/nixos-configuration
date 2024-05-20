# TAF
#   previously "AF"
#   this is my main desktop PC
{ pkgs, ... }: {

  networking.hostName = "trantor"; # previously "nixAF"
  networking.domain = "foundation";

  # enable desktop environment :
  nixos.desktop.enable = true;

  ## enable flatpak apps
  nixos.flatpak.enable = true;

  nixos.boot.sleep = true;
  nixos.boot.fastBoot = true;

  # use our zfs setup :
  # TODO: make this setup more tweakable
  nixos.zfs.enable = true;

  # add steam drive
  # TODO : CLEAN THIS !
  fileSystems."/run/media/steam" = {
    device = "nixos-pool/local/steam";
    fsType = "zfs";
    neededForBoot = false;
  };

  # cpu and gpu are AMD
  nixos.amd.gpu.enable = true;
  nixos.amd.cpu.enable = true;

  # gamepad, mouse, etc ...
  nixos.hid.logitech.enable = true;
  nixos.hid.valve.enable = true;
  nixos.hid.xbox.enable = true;

  # Power Management :
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

  # gaming :
  programs.gamemode = {
    enable = true;
    settings.general.inhibit_screensaver = 0;
    enableRenice = true;
  };

  system.stateVersion = "23.11";
}
