# display-manager.nix
# 	ensure that no matter the desktop environment
{ config, pkgs, lib, ... }:
with builtins;
let
  cfg = config.nixos.desktop.displayManager;

  mkDefaultEnableOption = desc: default:
    (lib.mkEnableOption desc) // {
      inherit default;
    };
  mkEnumOption = desc: values:
    lib.mkOption {
      description = concatStringsSep "," [ desc "one of " (toString values) ];
      type = lib.types.enum values;
      default = elemAt values 0;
    };

  # list of supported dm
  dms = [ "lightdm" "sddm" "gdm" ];

  # TODO : try :
  # ldm-mini;
  # pantheon.elementary-greeter
  # services.xserver.displayManager.lightdm.background =
  # pkgs.nixos-artwork.wallpapers.simple-dark-gray-bottom.gnomeFilePath
  greeter = let
    noto-font = {
      name = "Noto Sans";
      package = pkgs.noto-fonts;
    };
  in {
    slick = {
      # iconTheme can cause issues
      inherit (config.nixos.desktop.gtk) cursorTheme theme;
      font = {
        name = "Noto Sans";
        package = pkgs.noto-fonts;
      };
      enable = true;
    };
  };

  # allow multiple definitions to co-exist
  dmSwitch = set:
    if (any (x: x == cfg.type) dms) && (hasAttr cfg.type set) then
      getAttr cfg.type set
    else
      throw ''
        please define the value for all and only of [ ${
          concatStringsSep " " dms
        } ]
      '';

in {

  options.nixos.desktop.displayManager = {
    enable = mkDefaultEnableOption "diplay manager" true;
    wayland.enable = mkDefaultEnableOption "use Wayland" true;
    type = mkEnumOption "Display manager to use" dms;

  };

  # implementation
  config = lib.mkIf cfg.enable {

    # base packages :
    environment.systemPackages = with pkgs;
      dmSwitch {
        "lightdm" = [ lightdm lightlocker ];
        "gdm" = [ gnome.gdm ];
        "sddm" = [ libsForQt5.sddm ];
      };

    # enable GUI
    services.xserver = {
      enable = true;

      displayManager = dmSwitch {
        "lightdm" = {
          lightdm.enable = true;
          lightdm.greeter.enable = true;
          lightdm.greeters = greeter;
        };
        "gdm" = {
          gdm.enable = true;
          gdm.wayland = cfg.wayland.enable;
        };
        "sddm" = { sddm.enable = true; };
      };
    };

    programs.xwayland.enable = cfg.wayland.enable;

  };

}
