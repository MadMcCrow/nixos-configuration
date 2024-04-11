# desktop/apps/flatpak.nix
# TODO : get rid of impermanence module and link it ourselves
{ pkgs, config, lib, impermanence, ... }:
let cfg = config.nixos.flatpak;
in {
  # interface
  options.nixos.flatpak.enable = lib.mkEnableOption "flatpak apps";
  imports = [ impermanence.nixosModules.impermanence ];

  #config
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libportal
      libportal-gtk3
      packagekit
    ];

    services.packagekit.enable = true;

    # xdg portal is required for flatpak
    xdg.portal = {
      enable = true;
      config.common.default = lib.mkDefault "xapp"; # default to Xapp
      extraPortals = lib.mkDefault
        (with pkgs; [ xdg-desktop-portal-wlr xdg-desktop-portal-xapp ]);
    };

    services.flatpak.enable = true;
    # bind mounted from /persist/flatpak/var/lib/flatpak to /var/lib/flatpak
    environment.persistence."/nix/persist" = {
      directories = [ "/var/lib/flatpak" ];
    };
  };
}
