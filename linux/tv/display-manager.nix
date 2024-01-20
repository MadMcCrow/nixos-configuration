# display-manager.nix
# 	ensure that no matter the desktop environment
# TODO : try :
# greetd
# ldm-mini;
# pantheon.elementary-greeter
# services.xserver.displayManager.lightdm.background =
# pkgs.nixos-artwork.wallpapers.simple-dark-gray-bottom.gnomeFilePath
{ config, pkgs, lib, ... }: {

  # implementation
  config = lib.mkIf config.nixos.tv.enable {

    # another option :
    #services.greetd = {
    #  enable = true;
    #  settings = {
    #    default_session = {
    #      command = "${pkgs.sway}/bin/sway --config ${swayConfig}";
    #    };
    #  };
    #};
    #environment.etc."greetd/environments".text = ''
    #  sway
    #  fish
    #  bash
    #  startxfce4
    #'';

    services.xserver.enable = lib.mkForce true;
    programs.xwayland.enable = true;
    environment.systemPackages = with pkgs; [ lightdm lightlocker ];

    services.xserver.displayManager = {
      gdm.enable = false;
      sddm.enable = false;
      # sddm.settings = { DisplayServer = "wayland"; };

      lightdm = {
        enable = true;
        greeter.enable = true;
        # background = pkgs.nixos-artwork.wallpapers.simple-dark-gray-bottom.gnomeFilePath;
        # TODO: try : lightdm-enso-os-greeter
        greeter.package = lib.mkForce pkgs.lightdm-slick-greeter.xgreeters;
        greeter.name = lib.mkForce "lightdm-slick-greeter";
        greeters.slick = {
          enable = true;
          cursorTheme.package = pkgs.libsForQt5.breeze-icons;
          cursorTheme.name = "Breeze";
          iconTheme.package = pkgs.libsForQt5.breeze-icons;
          iconTheme.name = "Breeze";
          theme.package = pkgs.libsForQt5.breeze-gtk;
          theme.name = "Breeze-Dark";
          font.name = "Noto Sans";
          font.package = pkgs.noto-fonts;
        };
      };
    };
  };
}
