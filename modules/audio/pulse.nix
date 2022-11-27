# audio/pulse.nix
#	set configuration for use with pulseaudio
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let cfg = config.audio.pulse;
in {
  options.audio.pulse.enable = mkOption {
    type = types.bool;
    default = false;
    description = "enable pulseaudio if true";
  };
  # Pulse
  config = mkIf cfg.enable {
    sound.enable = true;
    hardware.pulseaudio.enable = true;
  };
}
