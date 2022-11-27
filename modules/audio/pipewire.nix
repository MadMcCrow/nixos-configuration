# audio/pipewire.nix
#	set configuration for use with pipewire
# audio/pulse.nix
#	set configuration for use with pulseaudio
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let cfg = config.audio.pipewire;
in {
  options.audio.pipewire.enable = mkOption {
    type = types.bool;
    default = true;
    description = "enable pipewire if true";
  };
  # pipewire
  config = mkIf cfg.enable {
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
