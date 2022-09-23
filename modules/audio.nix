# Audio can be handled with pulseaudio (NixOS default) or pipewire (the new multimedia standard)
{ pkgs, config, lib, ... }:
with lib;
with builtins; {
  options.sys.audio = {
    server = mkOption {
      type = types.enum [ "pulse" "pipewire" ];
      default = "pipewire";
      description = "Audio server";
    };
  };

  # Pipewire
  config = mkIf (config.sys.audio.server == "pipewire") {
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

  # Pulseaudio
  config = mkIf (cfg.server == "pulse") {
    sound.enable = true;
    hardware.pulseaudio.enable = true;
    hardware.pulseaudio.support32Bit = true;
    hardware.pulseaudio.package = pkgs.pulseaudioFull;
  };
}
