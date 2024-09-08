{ pkgs, ... }:
{
  home.packages = with pkgs; [ vesktop ];
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/discord" = [ "discord.desktop" ];
  };
}
