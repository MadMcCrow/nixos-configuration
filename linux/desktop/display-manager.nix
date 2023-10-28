# display-manager.nix
# 	ensure that no matter the desktop environment
# TODO : try :
# ldm-mini;
# pantheon.elementary-greeter
# services.xserver.displayManager.lightdm.background =
# pkgs.nixos-artwork.wallpapers.simple-dark-gray-bottom.gnomeFilePath
{ config, pkgs, lib, ... }:
with builtins;
let
  # shortcuts :
  dsk = config.nixos.desktop;
  cfg = dsk.displayManager;
  dmtype = cfg.type;
  # list of supported dm
  dms = [ "lightdm" "sddm" "gdm" ];
in {

  options.nixos.desktop.displayManager = {
    enable = lib.mkEnableOption "diplay manager" // { default = true; };
    wayland.enable = lib.mkEnableOption "Wayland for DM" // { default = true; };
    type = lib.mkOption {
      description = "one of ${concatStringsSep "," dms}";
      type = lib.types.enum dms;
      default = elemAt dms 0;
    };
  };

  # implementation
  config =
    # assert lib.assertMsg (any (x: x == dmtype) dms) ''
    #   please set config.nixos.desktop.displayManager.type to one of : [ ${
    #     concatStringsSep " " dms
    #   } ]
    # '';
    lib.mkIf (dsk.enable && cfg.enable) {
      services.xserver.enable = true;
      programs.xwayland.enable = cfg.wayland.enable;
      environment.systemPackages = with pkgs;
        (lib.lists.optional (dmtype == "gdm") gnome.gdm)
        ++ (lib.lists.optional (dmtype == "sddm") libsForQt5.sddm)
        ++ (lib.lists.optionals (dmtype == "lightdm") [ lightdm lightlocker ]);

      services.xserver.displayManager = lib.mkMerge [
        (lib.optionalAttrs (dmtype == "gdm") {
          gdm.enable = true;
          gdm.wayland = cfg.wayland.enable;
        })
        (lib.optionalAttrs (dmtype == "sddm") {
          sddm.enable = true;
          sddm.settings = mkIf cfg.wayland.enable { DisplayServer = "wayland"; };
        })
        (lib.optionalAttrs (dmtype == "lightdm") {
          lightdm.enable = true;
          lightdm.greeter.enable = true;
          lightdm.greeters.slick = {
            enable = true;
            cursorTheme = dsk.gtk.cursorTheme;
            theme = dsk.gtk.theme;
            font = {
              name = "Noto Sans";
              package = pkgs.noto-fonts;
            };
          };
        })
      ];
    };
}
