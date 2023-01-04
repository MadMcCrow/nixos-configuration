# audio/pulse.nix
#	set configuration for use with pulseaudio
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  aud = config.audio;
  cfg = aud.pulse;
in {
  #interface
  options.audio.pulse.enable = mkEnableOption (mdDoc "audio with pulseaudio");
  # Pulse
  config = mkIf (aud.enable && cfg.enable) {
    sound.enable = true;
    hardware.pulseaudio.enable = true;
  };
}
