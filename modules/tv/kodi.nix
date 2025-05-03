# kodi.nix
# add Kodi interface
{
  pkgs,
  lib,
  config,
  ...
}:
let
  # username for kodi
  kodiUser = "kodi";
  # shortcut
  cfg = config.tv.kodi;
in
{
  # interface
  options.tv.kodi = with lib; {
    enable = mkEnableOption "Kodi TV interface";
  };

  # implementation
  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      desktopManager = {
        kodi = {
          enable = true;
          package = pkgs.kodi-gbm; # GBM support HDR and what's not !
        };
      };
      displayManager = {
        autoLogin.user = kodiUser;
        lightdm.greeter.enable = false;
      };
    };

    # Define a user account
    users.extraUsers."${kodiUser}".isNormalUser = true;

    # services.cage = {
    #   enable = true;
    #   user = "kodi";
    #   program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
    # };
  };
}
