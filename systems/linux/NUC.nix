# NUC
#   this is a 12th gen Intel NUC
#   it's my central Home Cloud
{
  config,
  nixos-hardware,
  addModules,
  pkgs,
  ...
}:
{
  imports =
    with nixos-hardware.nixosModules;
    [
      common-gpu-intel
      common-cpu-intel
    ]
    ++ (addModules [
      "home/linux"
      "tv"
      "desktop"
    ]);

  config = {

  # this device is used on a TV hence the "situation room"
  # not perfect but could be easily renamed
  networking.hostName = "situation-room";

    # Power Management : minimize consumption
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "performance";
    };

    # enable extra layer of security
    security.apparmor.enable = true;

    # fixed revision
    system.stateVersion = "24.11";

    # we use waydroid on nixOS instead of Android X86
    tv.waydroid.enable = true;

  };
}
