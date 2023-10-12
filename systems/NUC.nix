# NUC Cloud config
{ pkgs, ... }:
let
  # todo filter broken
  #intel kernel packages can be broken sometimes
  intelKernelPackages = [
    # "intel-speed-select" # broken
    # "phc-intel" # broken
  ];

  # where to put the data :
  serverData = "/run/server_data";
in {

  platform = "x86_64-linux";

  # our settings
  nixos = {

    # use our 
    enable = true;
    host.name = "nixNUC";

    # let's be generous with ourselves
    rebuild.genCount = 10;

    # desktop env
    desktop = {
      enable = true;
      gnome.enable = true;
      apps.enable = false; # disable system-wide apps
    };

    # server systems
    server = {
      enable = true;
      nextcloud.enable = true;
      data.path = serverData;
    };

    # kernel packages
    kernel.extraKernelPackages = [ "acpi_call" ];

    # cpu/gpu
    cpu.vendor = "intel";
    cpu.powermode = "powersave";
    gpu.vendor = "intel";

  };

  # drive for server databases (Postgre)
  fileSystems."${serverData}" = {
    device = "/dev/sda1";
    fsType = "btrfs";
    neededForBoot = false;
    options = [ "compress=zstd" "noatime" ];
  };
  # scrub
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.interval = "weekly";

  # maybe consider adding swap ?
  swapDevices = [ ];
}
