# desktop/apps/flatpak.nix
# TODO : get rid of impermanence module and link it ourselves
{ pkgs, config, lib, impermanence, ... }:
let
  #config interface
  dsk = config.nixos.desktop;
  cfg = dsk.apps.flatpak;
in {
  # interface
  options.nixos.desktop.apps.flatpak = {
    enable = lib.mkEnableOption "flatpak apps";
  };
  #
  imports = [ impermanence.nixosModules.impermanence ];
  #config
  config = lib.mkIf (dsk.enable && cfg.enable) {
    environment.systemPackages = with pkgs; [ libportal libportal-gtk3 packagekit ];
    xdg.portal.enable = true;
    services.packagekit.enable = true;
    services.flatpak.enable = true;
    # bind mounted from /persist/flatpak/var/lib/flatpak to /var/lib/flatpak
    environment.persistence."/nix/persist" = {
      directories = [ "/var/lib/flatpak" ];
    };
  };
}
