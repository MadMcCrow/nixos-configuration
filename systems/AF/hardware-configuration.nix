# hardware-configuration.nix
#	It was generated by ‘nixos-generate-config’
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.kernelModules = [ "kvm-amd" "amdgpu" ];
  boot.extraModulePackages = [ ];
  boot.extraModprobeConfig =
    "options zfs l2arc_noprefetch=0 zfs_arc_max=1073741824";
  fileSystems."/" = {
    device = "nixos-pool/local/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "nixos-pool/local/nix";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/nix/persist" = {
    device = "nixos-pool/safe/persist";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/home" = {
    device = "nixos-pool/safe/home";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4A84-7800";
    fsType = "vfat";
  };

  fileSystems."/run/media/steam" = {
    device = "/dev/disk/by-uuid/35d071fc-963c-4025-8581-f023fbd936bd";
    fsType = "f2fs";
    options = [ "defaults" "rw" ];
  };

  # maybe use a bind instead to allow having documents on a separate drive/partition/standard
  fileSystems."/home/perard/Documents" = {
    device = "/dev/disk/by-uuid/03413941-1a7e-4cfb-9965-2d4264c1fdb5";
    fsType = "f2fs";
    options = [ "defaults" "rw" ];
  };

  # maybe consider adding swap ?
  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0f0u3.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp5s0.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  ##hardware.opengl.extraPackages = with pkgs; [ amdvlk ];
}
