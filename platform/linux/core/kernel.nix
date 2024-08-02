# linux/boot.nix
{ config, lib, pkgs, ... }:
let
  # shortcut:
  cfg = config.nixos.boot;
in {
  options.nixos.boot = with lib; {
    # enable faster boot (disable many checks)
    fastBoot = mkEnableOption "Simplify boot process";
    # sleep mode
    sleep = mkEnableOption "allow sleep";
  };

  config = rec {
    # root user
    users.users.root = {
      homeMode = "700"; # home will be erased anyway because on /
      hashedPassword =
        "$y$j9T$W.JAnia2yZEpLY8RwEJ4M0$eS3XjstDqU8/5gRoTHen9RDZg4E1XNKp0ncKxGs0bY.";
    };

    environment.systemPackages = [ pkgs.linux-firmware ];

    # use our other module
    nixos.nix.unfreePackages = [ "linux-firmware" ];

    boot = {
      # Kernel
      kernelParams = [ "nohibernate" "quiet" "idle=nomwait" ];

      # map kernel packages to kernel package in use :
      extraModulePackages = [ config.boot.kernelPackages.acpi_call ];

      # modules :
      initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "xhci_hcd"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "dm-snapshot"
      ];

      plymouth.enable = true; # hide wall-of-text
      supportedFilesystems = [ "ext4" "f2fs" "fat32" "ntfs" ];

      loader = {
        systemd-boot.enable = true; # use gummyboot for faster boot
        efi.canTouchEfiVariables = true; # may not be necessary
        systemd-boot.configurationLimit = 5;
      };

      consoleLogLevel = 3; # avoid useless errors

    };

    security.apparmor.enable = true;

    # Faster boot:
    systemd.services.NetworkManager-wait-online.enable = cfg.fastBoot;
    systemd.services.systemd-fsck.enable = cfg.fastBoot;

    # faster program start
    services.preload.enable = true;

    # enable or disable sleep/suspend
    systemd.targets = {
      sleep.enable = cfg.sleep;
      suspend.enable = cfg.sleep;
      hibernate.enable = cfg.sleep;
      hybrid-sleep.enable = cfg.sleep;
    };
  };
}
