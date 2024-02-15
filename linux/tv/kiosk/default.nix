# kiosk.nix
# 	Gnome shell as a kiosk for Nixos
{ config, pkgs, lib, ... }:
let
  tv = config.nixos.tv;
  cfg = tv.kiosk;

  gnome-kiosk = import ./session.nix {
    inherit pkgs;
    kioskApp = cfg.app;
    sessionName = "gnome-kiosk";
  };
in {

  imports = [ ./dconf.nix ];

  options.nixos.tv.kiosk = {
    enable = lib.mkEnableOption "Kiosk mode" // { default = true; };
    app = lib.mkOption {
      description = "app to go full screen in kiosk";
      type = lib.types.package;
      default = pkgs.xterm;
    };
  };

  config = lib.mkIf (tv.enable && cfg.enable) {

    # probably not necessary :
    # Create `/usr/share/xsessions/kiosk.desktop`
    # services.xserver.displayManager.session = [
    #            {
    #              manage = "desktop";
    #              name = "kiosk";
    #              start = ''exec gnome-shell --mode=kiosk'';
    #            }
    #          ];
    #       }

    # gnome packages for this kiosk mode :
    environment.systemPackages = [ gnome-kiosk ]
      ++ (with pkgs.gnome; [ gnome-session gnome-shell ])
      ++ (with pkgs.gnomeExtensions; [ zen ]);

    services.xserver.enable = true;
    # services.xserver.displayManager.autoLogin.enable = true;
    # GDM is our login manager :

    # services.xserver.displayManager.gdm.enable = true;
    # services.xserver.displayManager.gdm.wayland = true;
    services.xserver.displayManager.sessionPackages = [ gnome-kiosk ];

    #services.xserver.desktopManager.gnome.enable = true;

    # services.xserver.displayManager.gdm.autoLogin.delay = 3;
    # services.gnome.core-os-services.enable = true;
    # services.gnome.core-shell.enable = true;
    # services.gnome.core-utilities.enable = false;
    # services.gnome.tracker-miners.enable = false;
    # services.gnome.tracker.enable = false;
  };
}
