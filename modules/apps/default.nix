# apps/default.nix
# 	all the apps we want on our systems
{config, pkgs}: {
let
  cfg = config.desktopApps;
in {
  options.desktopApps = lib.mkEnableOption "desktop";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
    lapce
    vlc
    firefox-wayland
    neofetch
    mellowplayer
    ];
  };
}
}
