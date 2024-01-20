# NUC Cloud config
{ pkgs, ... }:
let

  # where to put the data :
  serverData = "/run/server_data";

in {

  networking.hostName = "nixNUC";

  # our custom modules config :
  nixos.flatpak.enable = true;
  nixos.server.enable = true;
  nixos.tv.enable = true;
  nixos.gpu.vendor = "intel";
  nixos.server.nextcloud.dataPath =  "${serverData}/nextcloud";

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
