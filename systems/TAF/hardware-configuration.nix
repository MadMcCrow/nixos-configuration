# hardware-configuration.nix
# hardware specific stuff :
{ pkgs, config, ... }: {

  boot.extraModulePackages = with config.boot.kernelPackages; [
    # asus motherboard
    asus-wmi-sensors
    asus-ec-sensors
    nct6687d # https://github.com/Fred78290/nct6687d
    # ACPI
    # acpi_call
  ];
  # LTS version :
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6; # lts
  boot.kernelParams =
    [ "nohibernate" "quiet" "idle=nomwait" "usbcore.autosuspend=-1" ];
  boot.blacklistedKernelModules = [ "xhci_hcd" ];

  fileSystems."/run/media/steam" = {
    device = "nixos-pool/local/steam";
    fsType = "zfs";
    neededForBoot = false;
  };
}
