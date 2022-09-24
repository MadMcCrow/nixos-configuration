# audio/pipewire.nix
#	set configuration for use with pipewire
{ pkgs, config, lib, ... }: {
  # Pipewire
  config = {
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
