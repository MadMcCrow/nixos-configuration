# discord.nix
#   Get a faster discord thanks to OpenASAR and Vencord
{ lib, pkgs, ... }: {

  # we need this module to work
  imports = [ ./nixpkgs.nix ];

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
  };
}
