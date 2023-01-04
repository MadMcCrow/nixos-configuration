# audio/pipewire.nix
#	set configuration for use with pipewire
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  aud = config.audio;
  cfg = aud.pipewire;
in {
  #interface
  options.audio.pipewire.enable = mkEnableOption (mdDoc "audio with pipewire")
    // {
      default = true;
    };
  # pipewire
  config = mkIf (aud.enable && cfg.enable) {
    sound.enable = false; # disabled for pipewire
    hardware.pulseaudio.enable = false; # disabled for pipewire
    security.rtkit.enable = true; # rtkit is optional but recommended
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
