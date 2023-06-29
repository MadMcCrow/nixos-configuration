# flatpak.nix
# 	Flatpak support for nixos
{ pkgs, config, lib, impermanence, ... }:
with builtins;
with lib;
let
  nos = config.nixos;
  cfg = nos.flatpak;
  dsk = config.desktop;
   # only enable if we harve a desktop environment
  hasDesktop = dsk.gnome.enable || dsk.kde.enable;
in {
  # interface
  options.nixos.flatpak.enable = mkEnableOption (mdDoc "flatpak") // {
    default = false;
  };
  # import thanks to specialArgs
  imports = [ impermanence.nixosModules.impermanence ];
  # configs
  config = lib.mkIf (nos.enable && cfg.enable && hasDesktop) {
  
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
