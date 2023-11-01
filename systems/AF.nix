{ pkgs, ... }:
with builtins; {

  platform = "x86_64-linux";

  nixos = {
    enable = true;
    host.name = "nixAF";

    rebuild.genCount = 10;

    # desktop env
    desktop = {
      enable = true;
      gnome.enable = true;
      apps.flatpak.enable = true;
      apps.games.enable = true; # video games, you should try them sometives
    };

    server = {
      enable = true;
      data.path = "/run/server";
    };

    # kernel packages
    kernel.extraPackages =
      [ "asus-wmi-sensors" "asus-ec-sensors" "zenpower" "acpi_call" ];
    kernel.params = [ "pci=noats" "amd_iommu=on" "iommu=pt" ];

    # cpu/gpu
    cpu.vendor = "amd";
    cpu.powermode = "performance";
    gpu.vendor = "amd";

    network.waitForOnline = false;
    network.wakeOnLineInterfaces = [ "enp4s0" ];
  };

  # add steam drive
  fileSystems."/run/media/steam" = {
    device = "nixos-pool/local/steam";
    fsType = "zfs";
    neededForBoot = false;
  };

  # maybe consider adding swap ?
  swapDevices = [ ];
}
