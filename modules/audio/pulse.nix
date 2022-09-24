# audio/pulse.nix
#	set configuration for use with pulseaudio
{ pkgs, config, lib, ... }: {
  # Pulse
  config = {
    sound.enable = true;
    hardware.pulseaudio.enable = true;
  };
}
