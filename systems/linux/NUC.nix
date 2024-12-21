# NUC
#   this is a 12th gen Intel NUC
#   it's my central Home Cloud
{
  lib,
  config,
  nixos-hardware,
  addModules,
  pkgs,
  ...
}:
let
  serverData = {
    uuid = "71a2031a-c081-4437-87e0-53b1eb749dae";
    name = "cryptserver";
    mountPoint = "/var/www";
  };
in
{
  imports =
    with nixos-hardware.nixosModules;
    [
      common-gpu-intel
      common-cpu-intel
    ]
    ++ (addModules [
      "linux"
      # "web"
    ]);

  config = {

    boot.initrd.luks.devices."${serverData.name}" = {
      device = "/dev/disk/by-partuuid/${serverData.uuid}";
      allowDiscards = true;
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };

    # Encrypted NUC SSD :
    # fileSystems."${serverData.mountPoint}" = {
    #   device = "/dev/mapper/${serverData.name}";
    #   encrypted = {
    #     enable = true;
    #     blkDev = "/dev/disk/by-partuuid/${serverData.uuid}";
    #     label = serverData.name; # luks device
    #   };
    #   fsType = "btrfs";
    #   neededForBoot = true;
    #   options = [
    #     "compress=zstd:6"
    #     "noatime"
    #   ];
    # };

    networking.hostName = "terminus";

    # our config :
    nixos = {
      # make a sound when ready
      # beep.enable = true;
      # sleep at night :
      # autowake = {
      #   # enable = true;
      #   time.sleep = "21:30";
      #   time.wakeup = "07:30";
      # };
      secureboot.enable = false;
      french.enable = false;
    };
    # Power Management : minimize consumption
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "powersave";
      powertop.enable = true;
      # scsiLinkPolicy = "med_power_with_dipm"; # maybe it isn't worth to deal with this
    };

    # enable extra layer of security on server
    security.apparmor.enable = true;

    services = {
      thermald.enable = true;
      # Use kmscon as the virtual console :
      kmscon =  {
         enable = true;
         hwRender = true;
         fonts = [
           {
             name = "Source Code Pro";
             package = pkgs.source-code-pro;
           }
         ];
         extraOptions = "--term xterm-256color";
      };

      btrfs.autoScrub.fileSystems = [ "${serverData.mountPoint}" ];
    };

    system.stateVersion = "24.05";

    # web = {
    #   enable = false;
    #   # bought and paid for !
    #   domain = "asimov.ovh";
    #   # email for certificates and notifications
    #   adminEmail = "noe.perard+serveradmin@gmail.com";
    #   #   # auth.subDomain = "kan";
    #   #   # dns.subDomain = "periphery";
    #   #   # home.subDomain = "imperium";
    # };
  };
}
