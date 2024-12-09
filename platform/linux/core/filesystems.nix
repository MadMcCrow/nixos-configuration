# filesystems/root.nix
# default root configuration.
# root on tmpfs uses around 11MB, what takes space is mostly /tmp.
# to avoid this issue, we have a filesystem dedicated to /tmp
# /var can also take a lot of space so we could move it to another filesystem
# we just focus on var/log because that could be useful to keep
# what's left is less than 1MB. 
# that's not the most optimized RAM setup, but I think all my machines can support losing that space.
# TLDR :
#   here's the layout :
#     - / -> tmpfs
#     - /var/log  -> btrfs, CoW disabled (no checksum)
#     - /nix      -> btrfs
#     - /tmp      -> btrfs, clean on boot, CoW disabled (no checksum)
#     - /home     -> btrfs
#
{
  lib,
  config,
  pkgs,
  ...
}:
let
  # shortcut
  cfg = config.nixos.fileSystems;
in
{
  # interface
  options.nixos.fileSystems = with lib; {
    # enable option
    enable = mkEnableOption "use default filesystems module";
    # allow fully encrypted root :
    luks = {
      enable = mkEnableOption "use encryption for installation" // {
        default = cfg.luks.device != "";
      };
      device = mkOption {
        description = "encrypted block device receiving nixos";
        type = types.str;
      };
    };
    # do you enable swap
    swap = mkEnableOption "enable swap partition";
    # 
    boot = mkOption {
      description = "vfat /boot drive partition (for bootloader)";
      type = types.str;
    };

    volumeGroup = mkOption {
      description = "lvm volume group for nixos";
      type = types.str;
      default = "vg_nixos";
    };

    # size of tmpfs for root
    tmpfsSize = mkOption {
      description = "Size of tmpfs for root";
      type = types.str;
      default = "2G";
    };
    # interface
    secureboot = {
      enable = mkEnableOption ''secureboot for unlocking the luks device'' // {
        default = cfg.luks.enable;
      };
      install = mkEnableOption ''
        enable secure boot.
        Only set to false when you've completed the necessary steps !
        Please follow https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
        You can then use luks devices passwordless :
        `sudo systemd-cryptenroll /dev/$DISK --tpm2-device=auto --tpm2-pcrs=0+2+7`
        see https://www.reddit.com/r/NixOS/comments/xrgszw/nixos_full_disk_encryption_with_tpm_and_secure/ 
        for details !
      '';
    };
  };

  # implementation
  config = lib.mkIf cfg.enable {

    fileSystems = {
      # /boot
      # Boot is always an Fat32 partition like old times
      "/boot" = {
        device = cfg.boot;
        fsType = "vfat";
      };

      # /
      #   root is always tmpfs
      "/" = {
        device = "none";
        fsType = "tmpfs";
        options = [
          "defaults"
          "size=${cfg.tmpfsSize}"
          "mode=755"
        ];
      };

      # /nix
      #   Nix store and files
      #   more compression added to save space
      "/nix" = {
        device = "/dev/${cfg.volumeGroup}/nixos";
        fsType = "btrfs";
        options = [
          "subvol=/nix"
          "lazytime"
          "noatime"
          "compress=zstd:5"
        ];
      };

      # /var/log
      # Logs and variable for running software
      # Limit disk usage with more compression
      # maybe move to /nix/persist ?
      "/var/log" = {
        device = "/dev/${cfg.volumeGroup}/nixos";
        fsType = "btrfs";
        options = [
          "subvol=/log"
          "compress=zstd:6" # higher level, default is 3
        ];
      };

      # /tmp : cleared on boot, but on physical disk to avoid filling up ram
      "/tmp" = {
        device = "/dev/${cfg.volumeGroup}/nixos";
        fsType = "btrfs";
        options = [
          "subvol=/tmp"
          "lazytime"
          "noatime"
          "nodatacow" # no compression, but cleared on boot
        ];
      };

      "/etc/secureboot" = lib.mkIf cfg.secureboot.enable {
        device = "/nix/persist/secureboot";
        options = [ "bind" ];
        neededForBoot = true;
      };

      # /home
      #   TODO : maybe worth having setup elsewhere ?
      "/home" = {
        device = "/dev/${cfg.volumeGroup}/nixos";
        fsType = "btrfs";
        options = [
          "subvol=/home"
          "lazytime"
          "noatime"
          "compress=zstd"
        ];
      };
    };

    boot = rec {

      # support for luks at boot
      initrd = {
        inherit (config.boot) supportedFilesystems;
        luks.devices = lib.mkIf cfg.luks.enable {
          # support encryption and decryption at boot
          cryptroot = {
            inherit (cfg.luks) device;
            allowDiscards = true;
          };
        };
      };
      # support only what's necessary during the boot process
      supportedFilesystems = [
        "btrfs"
        "fat32"
      ];

      # clear tmp on boot
      tmp.cleanOnBoot = true;
      # choose correct bootloader :
      #   Lanzaboote currently replaces the systemd-boot module.
      loader.systemd-boot = {
        # enable if we're not using lanzaboote
        enable = lib.mkForce (!lanzaboote.enable);
        editor = false; # safety !
      };
      lanzaboote = {
        enable = cfg.secureboot.enable && !cfg.secureboot.install;
        pkiBundle = "/etc/secureboot";
      };
      # clean boot process
      plymouth.enable = true; # hide wall-of-text
      consoleLogLevel = 3; # avoid useless errors
    };

    # some swap hardware :
    swapDevices = lib.lists.optionals cfg.swap [
      {
        label = "swap";
        device = lib.mkForce "/dev/${cfg.volumeGroup}/swap";
        randomEncryption = lib.mkIf (!cfg.luks.enable) {
          enable = true;
          allowDiscards = true;
        };
      }
    ];

    # thin provisioning for lvm
    services.lvm.boot.thin.enable = true;
    # scrub-ba-dub-dub
    services.btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [
        "/nix"
        "/var/log"
        "/home" # maybe remove this when we move home
      ];
    };

    environment.systemPackages = lib.lists.optionals cfg.secureboot.enable [ pkgs.sbctl ];

    # disable the sudo warnings about calling sudo (it will get wiped every reboot)
    security.sudo.extraConfig = "Defaults        lecture = never";

    # enable or disable sleep/suspend
    systemd.targets = lib.mkIf false {
      sleep.enable = cfg.sleep;
      suspend.enable = cfg.sleep;
      hibernate.enable = cfg.sleep;
      hybrid-sleep.enable = cfg.sleep;
    };

  };

}
