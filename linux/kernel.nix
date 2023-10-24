# linux/kernel.nix
#	kernel options for nixos
{ pkgs, config, lib, ... }:
let
  # shortcut
  nxs = config.nixos;
  cfg = nxs.kernel;

   mkOptionBase = type: description: default:
      lib.mkOption {inherit type description default;};

  # Kernel
  defaultKernelMods = [
    "nvme"
    "xhci_pci"
    "xhci_hcd"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "dm-snapshot"
  ];
  defaultKernelParams = [ "nohibernate" "quiet" "idle=nomwait" ];
in {
  options.nixos.kernel = with lib.types; {
    # kernel packages to use
    packages = mkOptionBase raw "kernel packages" pkgs.linuxPackages_latest;
    # kernel package for gpus and such
    extraPackages =  mkOptionBase (listOf str) "Extra kernel Packages" [ ];

    # modules to enable:
    modules =  mkOptionBase (listOf str) "modules to enable" [ ];
    params =  mkOptionBase (listOf str) "kernel Params" [ ];
  };

  config = lib.mkIf nxs.enable {
    boot = {
      kernelParams = cfg.params ++ defaultKernelParams;
      kernelPackages = cfg.packages;
      extraModulePackages = map (x:  cfg.packages."${x}") cfg.extraPackages;

      initrd.availableKernelModules = cfg.modules ++ defaultKernelMods;
    };

  };
}
