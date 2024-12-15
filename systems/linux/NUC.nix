# NUC
#   this is a 12th gen Intel NUC
#   it's my central Home Cloud
{ nixos-hardware, addModules, ... }:
let
serverDataDir = "/var/www";
in
{
  imports = with nixos-hardware.nixosModules; [
    common-gpu-intel
    common-cpu-intel
  ]++ (addModules ["linux"]);

  config = {

    boot.initrd.luks.devices."cryptserver" = {
      device = "/dev/disk/by-partuuid/71a2031a-c081-4437-87e0-53b1eb749dae";
      allowDiscards = true;
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };

    # STORAGE :
    # Encrypted NUC SSD :
    # fileSystems."${serverDataDir}" = {
    #   device = "/dev/mapper/cryptserver";
    #   encrypted = {
    #     enable = true;
    #     blkDev = "/dev/disk/by-partuuid/71a2031a-c081-4437-87e0-53b1eb749dae";
    #     label = "cryptserver"; # luks device
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
      beep.enable = true;

      # filesystem :
      fileSystems = {
        boot.partuuid = "5bd1959a-7a82-4bad-868a-a601df058489";
        root.partuuid = "9e5262a8-7264-4455-8af8-f00472e8ca03";
        swap.enable = true;
      };

      # sleep at night :
      autowake = {
        # enable = true;
        time.sleep = "21:30";
        time.wakeup = "07:30";
      };
    };
    # Power Management : minimize consumption
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "powersave";
      powertop.enable = true;
      # scsiLinkPolicy = "med_power_with_dipm"; # maybe it isn't worth to deal with this
    };

    services = {
      thermald.enable = true;
      # Use kmscon as the virtual console :
      # kmscon =  {
      #   enable = true;
      #   hwRender = true;
      #   fonts = [
      #     {
      #       name = "Source Code Pro";
      #       package = pkgs.source-code-pro;
      #     }
      #   ];
      #   extraOptions = "--term xterm-256color";
      # };

      # btrfs.autoScrub.fileSystems = [ "${serverDataDir}" ];
    };

    system.stateVersion = "24.05";

    # web = {
    #   enable = false;
    #   # bought and paid for !
    #   domain = "asimov.ovh";
    #   # email for certificates and notifications
    #   adminEmail = "noe.perard+serveradmin@gmail.com";
    #   # auth.subDomain = "kan";
    #   # dns.subDomain = "periphery";
    #   # home.subDomain = "imperium";
    # };
  };
}
