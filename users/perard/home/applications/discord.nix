# discord.nix
#   Get a faster discord thanks to OpenASAR and Vencord
{ lib, pkgs, ... }: {

  config = {
    packages = {
      unfree = [ "discord" ];
      overlays = [
        (self: super: {
          discord = super.discord.override {
            nss = pkgs.nss_latest;
            withOpenASAR = true;
            withVencord = true;
            #  withTTS = true;
          };
        })
      ];
    };

    # TODO: try this
    #programs.discocss.enable = true;

    home.packages = with pkgs; [ discord ];


    home.file.".config/discord/settings.json".text = ''
    {
      "SKIP_HOST_UPDATE": true,
      "DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING": true,
      "MIN_WIDTH": 940,
      "MIN_HEIGHT": 500,
      "openasar": {
        "setup": true,
        "noTyping": true,
        "quickstart": true,
        "css": "
          @import url(\"https://modernx-theme.vercel.app/modernx-discord.theme.source.css\");
          @import url(\"https://discordstyles.github.io/RadialStatus/dist/RadialStatus.css\");
          :root {
              --username-button-width: 128px;
              --username-button-padding: 6px;
              --username-button-right-margin: 12px;
              --username-text-width: 100px;
              --server-icon-size: 32px;
              --server-outer-margin: 12px;
              --server-spacing: 8px;
              --app-info-bar-height: 48px;
          }
          :root {
            --rs-small-spacing: 2px;
            --rs-medium-spacing: 2px;
            --rs-large-spacing: 2px;
            --rs-small-width: 2px;
            --rs-medium-width: 2px;
            --rs-large-width: 2px;
            --rs-avatar-shape: 50%;
            --rs-online-color: #43b581;
            --rs-idle-color: #faa61a;
            --rs-dnd-color: #f04747;
            --rs-offline-color: #636b75;
            --rs-streaming-color: #643da7;
            --rs-invisible-color: #ffffff;
            --rs-phone-color: var(--rs-online-color);
            --rs-phone-visible: block; /* block = visible | none = hidden */
          }
        "
      },
      "chromiumSwitches": {},
      "IS_MAXIMIZED": false,
      "IS_MINIMIZED": false,
      "WINDOW_BOUNDS": {
        "x": 778,
        "y": 426,
        "width": 1280,
        "height": 720
      },
      "trayBalloonShown": true
    }
    '';

    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/discord" = [ "discord.desktop" ];
    };
  };
}
