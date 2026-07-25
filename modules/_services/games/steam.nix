# steam.nix
# All things valve related !
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.nonOS.games.valve.enable = lib.mkEnableOption "valve nix support";

  # config
  config = lib.mkIf config.nonOS.games.valve.enable {
    # depends on the "linux" package !
    _nonOS.unfreePackages = [
      "steam-original"
      "steam"
      "steam-run"
      "steamcmd"
    ];

    # just use nixOS well built module :
    programs.steam = {
      enable = true;
      extraPackages = with pkgs; [
        # tools
        steam-run
        steamcmd
        gamescope
        mangohud
        # libs
        libglvnd
        libgdiplus
        libpng
        extest # steam
        # debugging
        procps
        usbutils
        libcap
        # VR
        openhmd
        openxr-loader
        pango
      ];
      # open-firewall
      remotePlay.openFirewall = true;
      # enable proton-GE
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };

    # env vars for steam and steam VR
    #home.sessionVariables = {
    # STEAM_RUNTIME="1";
    # STEAM_RUNTIME_PREFER_HOST_LIBRARIES="0";
    #};

    # this should be handled by steam nixos module, but there's no way I'm not making sure my games works
    networking.firewall = {
      allowedTCPPorts = [
        27015 # remote play
        27036 # SRCDS Rcon port
      ];
      allowedUDPPorts = [ 27015 ]; # Gameplay traffic
      allowedUDPPortRanges = [
        {
          from = 27031;
          to = 27036;
        }
      ]; # remote play
    };
  };
}
