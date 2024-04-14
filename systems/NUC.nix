# NUC
#   this is a 12th gen Intel NUC
#   it's my central Home Cloud
{ pkgs, ... }:
let serverData = "/run/server_data";
in {

  networking.hostName = "Foundation"; # "Terminus/Foundation";

  # our custom modules config :
  nixos.flatpak.enable = true;
  nixos.server.enable = true;
  nixos.desktop.enable = true;

  nixos.gpu.vendor = "intel";
  nixos.server.containers.nextcloud.datadir = "${serverData}/nextcloud";

  # drive for server databases (Postgre)
  fileSystems."${serverData}" = {
    device = "/dev/sda1";
    fsType = "btrfs";
    neededForBoot = false;
    options = [ "compress=zstd" "noatime" ];
  };
  # scrub
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "${serverData}" ];
  };

  # maybe consider adding swap ?
  swapDevices = [ ];
}
