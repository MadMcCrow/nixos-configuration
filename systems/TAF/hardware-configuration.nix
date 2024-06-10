# hardware-configuration.nix
# hardware specific stuff :
{ lib, config, pkgs-latest, ... }: {
  boot.extraModulePackages = with config.boot.kernelPackages; [
    # asus motherboard
    asus-wmi-sensors
    asus-ec-sensors
    nct6687d # https://github.com/Fred78290/nct6687d
    # ACPI
    acpi_call
  ];

  boot.kernelParams = [ "amd_iommu=on" "iommu=pt" "usbcore.autosuspend=-1" ];
  boot.blacklistedKernelModules = [ "xhci_hcd" ];

  ## TODO : This is machine specific and should be brought back from core!
  nixos.network.wakeOnLineInterfaces = [ "enp4s0" ];

  ## ZFS - ERASE YOUR DARLINGS

  # use latest zfs
  boot.zfs.package = pkgs-latest.zfs;
  boot.kernelPackages =
    lib.mkForce pkgs-latest.zfs.latestCompatibleLinuxPackages;

  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];

  # append zfs rollback command :
  boot.initrd.postDeviceCommands =
    lib.mkAfter "zfs rollback -r nixos-pool/local/root@blank";

  # append zfs options :
  boot.extraModprobeConfig =
    lib.mkAfter "options zfs l2arc_noprefetch=0 zfs_arc_max=1073741824";

  # import zfs pools at boot
  boot.zfs = {
    forceImportRoot = false; # if it does not work, switch to false
    forceImportAll = false;
    allowHibernation = true;
  };

  # add subvolumes to fileSystems:
  fileSystems = let
    mkZFS = name: device: neededForBoot: {
      inherit name;
      value = {
        inherit device neededForBoot;
        mountPoint = name;
        fsType = "zfs";
      };
    };
  in (builtins.listToAttrs [
    (mkZFS "/" "nixos-pool/local/root" true)
    (mkZFS "/nix" "nixos-pool/local/nix" true)
    (mkZFS "/nix/persist" "nixos-pool/safe/persist" true)
    (mkZFS "/home" "nixos-pool/safe/home" false)
  ]) // {
    "/boot" = {
      device = "/dev/disk/by-uuid/8001-EF00";
      fsType = "vfat";
    };
  };

  # some swap hardware :
  swapDevices = [{
    device = "/dev/disk/by-partuuid/509f2c99-0e63-4af1-90fb-5ff8d76efb67";
    randomEncryption.enable = true;
    randomEncryption.allowDiscards = true; # less secure but better for the SSD
  }];
}
