# environments/kodi.nix
# 	Kodi as a desktop environment
{ config, pkgs, lib, ... }:
let
  # gbm is basically forgoing x11/wayland for kodi's render that is only OpenGL :
  # https://github.com/xbmc/xbmc/issues/14876
  kodi = pkgs.kodi-wayland.withPackages (kodiPkgs:
    with kodiPkgs;
    [
      # keymap
      # jellyfin # TODO only when jellyfin is finally setup in nixos
      # youtube
      # invidious (yet another youtube addon)
      # netflix
      # arteplussept
      # vfs-sftp
      # pvr-iptvsimple # fails to build due to inputstream-ffmpeg-direct
      # requests-cache # improve perf
      # steam-controller
      # osmc-skin # kinda looks bad IMHO
      #steam-launcher # require steam installed
    ] ++ (import ./addons { inherit pkgs lib kodiPkgs; }));

in lib.mkIf config.nixos.tv.enable {
  # services.cage.user = "kodi";
  # # services.cage.program = "${kodi}/bin/kodi-standalone";
  # services.cage.enable = true;

  environment.systemPackages = [ kodi ];

  # services.xserver.desktopManager.kodi.enable = true;
  # services.xserver.desktopManager.kodi.package = kodi;

  # Access from other machines
  networking.firewall.allowedTCPPorts = [ 8080 ];
  networking.firewall.allowedUDPPorts = [ 8080 ];

  users.extraUsers.kodi.isNormalUser = true;
  # services.xserver.displayManager.autoLogin.user = "kodi";

  # it's not really unfree, it's cc-by-nc-sa-30.
  packages.unfreePackages = [ "osmc-skin" ];
}
