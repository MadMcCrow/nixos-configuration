# desktop/audio.nix
# Linux audio config
{ lib, config, ... }:
let
  # shortcut
  cfg = config.nixos.audio;
in {
  # audio options :
  options.nixos.audio = {
    enable = lib.mkEnableOption "audio support" // { default = true; };
    usePipewire = lib.mkEnableOption "pipewire for audio" // {
      default = true;
    };
    # TODO :
    mkChromecast = lib.mkEnableOption "Chromecast for desktop linux";
  };

  # implementation :
  config = lib.mkIf (cfg.enable) {
    # required by pulseaudio and recommended for pipewire
    security.rtkit.enable = true;

    # disabled for pipewire
    sound.enable = !cfg.usePipewire;

    # disable pipewire if using pulseaudio
    hardware.pulseaudio.enable = cfg.enable && !cfg.usePipewire;

    # pipewire service
    services.pipewire = lib.mkIf cfg.usePipewire {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}