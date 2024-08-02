# hardware-configuration.nix
# hardware specific stuff :
{ nixos-hardware, ... }: {

  imports = with nixos-hardware.nixosModules;
    [
      asus-rog-strix-x570e # its a B450itx, but it's roughly the same hardware
    ];

  fileSystems."/run/media/steam" = {
    device = "nixos-pool/local/steam";
    fsType = "zfs";
    neededForBoot = false;
  };
}
