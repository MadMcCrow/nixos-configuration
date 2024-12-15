# discord.nix
#   Get a faster discord thanks to OpenASAR and Vencord
{ lib, pkgs, ... }:
{
  config = {
    packages = {
      unfree = [ "discord" ];
      overlays = [
        (_: super: {
          discord = super.discord.override {
            nss = pkgs.nss_latest;
            withOpenASAR = true;
            withVencord = true;
            withTTS = false;
          };
        })
      ];
    };

    # TODO: try this
    #programs.discocss.enable = true;

    home.packages = with pkgs; [ discord ];

    home.file.".config/discord/settings.json".text = builtins.toJSON {
      SKIP_HOST_UPDATE = true;
      DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING =
        true;
      MIN_WIDTH = 940;
      MIN_HEIGHT = 500;
      openasar = {
        setup = true;
        noTyping = true;
        quickstart = true;
        css = lib.strings.stringAsChars (x: if x == "/n" then "//n" else x) (
          builtins.readFile ./Material-Discord.theme.css
        );
      };
      chromiumSwitches = { };
      IS_MAXIMIZED = false;
      IS_MINIMIZED = false;
      WINDOW_BOUNDS = {
        x = 778;
        y = 426;
        width = 1280;
        height = 720;
      };
      trayBalloonShown = true;
    };
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/discord" = [ "discord.desktop" ];
    };
  };
}
