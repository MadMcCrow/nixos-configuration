# environments/kodi.nix
# 	Kodi as a desktop environment
{ config, pkgs, lib, ... }:
let
  # for steam link support  : redo this :
  # https://gitlab.com/grimlokason/osmc-steamlink
  # with this :
  # https://github.com/teeedubb/teeedubb-xbmc-repo/tree/master/script.steam.launcher

  # gbm is basically forgoing x11/wayland for kodi's render that is only OpenGL :
  # https://github.com/xbmc/xbmc/issues/14876
  pkg = pkgs.kodi-gbm;

  # another option is to use :
  #  services.cage.user = "kodi";
  #  services.cage.program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
  #  services.cage.enable = true;

  # for youtube we can either use youtube or invidious.

in lib.mkIf config.nixos.tv.enable {
  services.xserver.desktopManager.kodi.enable = true;
  services.xserver.desktopManager.kodi.package = pkg.withPackages (kodi:
    with kodi;
    [
      # keymap
      # jellyfin # TODO only when jellyfin is finally setup in nixos
      #youtube
      #netflix
      # arteplussept
      # vfs-sftp
      # pvr-iptvsimple # fails to build due to inputstream-ffmpeg-direct
      requests-cache # improve perf
      steam-controller
      # osmc-skin # kinda looks bad IMHO
      #steam-launcher # require steam installed
    ] ++ (import ./addons { inherit pkgs lib kodi; }));

  # Access from other machines
  networking.firewall.allowedTCPPorts = [ 8080 ];
  networking.firewall.allowedUDPPorts = [ 8080 ];

  users.extraUsers.kodi.isNormalUser = true;

  # request autologin
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "kodi";

  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-wlr
    xdg-desktop-portal-xapp
  ];
  xdg.portal.config.common.default = [ "xapp" ];

  # it's not really unfree, it's cc-by-nc-sa-30.
  packages.unfreePackages = [ "osmc-skin" ];
}
