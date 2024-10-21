# desktop/audio.nix
# Linux audio config
{
  pkgs,
  lib,
  config,
  ...
}:
let
  # shortcut
  cfg = config.nixos.audio;
in
{
  # audio options :
  options.nixos.audio = with lib; {
    enable = mkEnableOption "audio support" // {
      default = config.nixos.desktop.enable;
    };
    usePipewire = mkEnableOption "pipewire for audio" // {
      default = true;
    };
  };

  # implementation :
  config = lib.mkIf cfg.enable {
    # required by pulseaudio and recommended for pipewire
    security.rtkit.enable = true;

    # disable pipewire if using pulseaudio
    hardware.pulseaudio.enable = cfg.enable && !cfg.usePipewire;

    # pipewire service
    services.pipewire = lib.mkIf cfg.usePipewire {
      enable = true;

      # use latest pipewire
      package = pkgs.pipewire;

      # use pipewire for all audio streams
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
