{ lib, pkgs, ... }: {

  packages = {
    unfree = [ "discord" ];
    overlays = [
      (self: super: {
        discord = super.discord.override {
          nss = pkgs.nss_latest;
          withOpenASAR = true;
          #  withTTS = true;
        };
      })
    ];
  };

  # try this
  programs.discocss.enable = true;

  home.packages = with pkgs; [ discord nss_latest ];

  # home.file.".config/discord/settings.json".text = ''
  #   {
  #   "SKIP_HOST_UPDATE": true,
  #   "openasar": {
  #     "setup": true
  #   },
  #   "IS_MAXIMIZED": false,
  #   "IS_MINIMIZED": false,
  #   "trayBalloonShown": true
  # }
  # '';
}
