# flatpak.nix
# 	Flatpak support for nixos
{ pkgs, config, lib, impermanence, ... }:
with builtins;
with lib;
let
  nos = config.nixos;
  cfg = nos.flatpak;
in {
  # interface
  options.nixos.flatpak.enable = mkEnableOption (mdDoc "flatpak") // {
    default = true;
  };
  # import thanks to specialArgs
  imports = [ impermanence.nixosModules.impermanence ];
  # configs
  config = lib.mkIf (nos.enable && cfg.enable) {
    services.flatpak.enable = true;
    xdg.portal = {
      enable = true;
      # you might want to only enable one or the other
      # extraPortals = with pkgs; [
      #  xdg-desktop-portal-gtk
      #  xdg-desktop-portal-kde
      #];
    };

    environment.systemPackages = with pkgs; [
      libportal
      libportal-gtk3
      packagekit
    ];

    # enable package kit
    services.packagekit.enable = true;

    # this folder is where the files will be stored (don't put it in tmpfs/zfs clean partition)
    # bind mounted from /persist/flatpak/var/lib/flatpak to /var/lib/flatpak
    environment.persistence."/nix/persist" = {
      directories = [ "/var/lib/flatpak" ];
    };
  };
}
