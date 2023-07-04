# flatpak.nix
# 	Flatpak support for nixos
{ pkgs, config, lib, impermanence, ... }:
with builtins;
with lib;
let
  # config shortcuts
  nos = config.nixos;
  dsk = nos.desktop;
  cfg = dsk.flatpak;  
   # only enable if we harve a desktop environment
  hasDesktop = dsk.gnome.enable || dsk.kde.enable;
  enable = all (x : x.enable) [nos dsk cfg];
in {
  # interface
  options.nixos.desktop.flatpak.enable = mkEnableOption (mdDoc "flatpak") // {
    default = hasDesktop;
  };
  # import thanks to specialArgs
  imports = [ impermanence.nixosModules.impermanence ];
  # configs
  config = lib.mkIf (enable && hasDesktop) {
  
    xdg.portal.enable = true;

    # enable package kit
    services.packagekit.enable = true;
    # enable flatpak
    services.flatpak.enable = true;

    environment.systemPackages = with pkgs; [
      libportal
      libportal-gtk3
      packagekit
    ];

    # this folder is where the files will be stored (don't put it in tmpfs/zfs clean partition)
    # bind mounted from /persist/flatpak/var/lib/flatpak to /var/lib/flatpak
    environment.persistence."/nix/persist" = {
      directories = [ "/var/lib/flatpak" ];
    };
  };
}
