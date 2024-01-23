# linux/root.nix
#	root zfs setup for my linux machines
# implements the "erase your darling philosophy"
{ pkgs, config, lib, ... }:
let

  cfg = config.nixos.boot;

  # ZKernel is the kernel that is compatible with ZFS :
  zKernel = pkgs.zfs.latestCompatibleLinuxPackages;

  # ZFS
  sysPool = "nixos-pool";

  # rollback command
  zRollbackCommand = let
    ds = "local/root";
    sn = "blank";
  in "zfs rollback -r ${sysPool}/${ds}@${sn}";

  # the filesystem architecture :
  zFileSystems = let
    mkZFS = name: device: neededForBoot: {
      inherit name;
      value = {
        inherit device neededForBoot;
        mountPoint = name;
        fsType = "zfs";
      };
    };
  in builtins.listToAttrs [
    (mkZFS "/" "${sysPool}/local/root" true)
    (mkZFS "/nix" "${sysPool}/local/nix" true)
    (mkZFS "/nix/persist" "${sysPool}/safe/persist" true)
    (mkZFS "/home" "${sysPool}/safe/home" false)
  ];

  #modprope
  zfsModProbConfig = "options zfs l2arc_noprefetch=0 zfs_arc_max=1073741824";

in {
  options.nixos.boot = {
    # kernel package for gpus and such
    extraPackages = lib.mkOption {
      description = "Extra kernel Packages to add in boot.extraModulePackages";
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = {
    # root user
    users.users.root = {
      homeMode = "700"; # home will be erased anyway because on /
      hashedPassword =
        "$y$j9T$W.JAnia2yZEpLY8RwEJ4M0$eS3XjstDqU8/5gRoTHen9RDZg4E1XNKp0ncKxGs0bY.";
    };

    # we try to always have boot as 8001-EF00
    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-uuid/8001-EF00";
        fsType = "vfat";
      };
    } // zFileSystems;

    # zfs service:
    services.zfs.trim.enable = true;
    services.zfs.autoScrub.enable = true;

    boot = {
      # Kernel
      kernelParams = [ "nohibernate" "quiet" "idle=nomwait" ];
      # force use zfs compatible kernel :
      kernelPackages = lib.mkForce zKernel;
      extraModulePackages =
        map (x: zKernel."${x}") (cfg.extraPackages ++ [ "acpi_call" ]);
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
      # ZFS :
      supportedFilesystems = [ "zfs" ];
      initrd.supportedFilesystems = [ "zfs" ];
      initrd.postDeviceCommands = lib.mkAfter zRollbackCommand;
      extraModprobeConfig = lib.mkAfter zfsModProbConfig;
      # import zfs pools at boot
      zfs.forceImportRoot = true;
      zfs.forceImportAll = true; # maybe not necessary
      zfs.enableUnstable = false;
      loader = {
        systemd-boot.enable = true; # use gummyboot for faster boot
        efi.canTouchEfiVariables = true; # may not be necessary
      };
    };
  };
}
