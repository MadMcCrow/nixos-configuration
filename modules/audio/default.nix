# audio/default.nix
# 	Audio can be handled with pulseaudio (NixOS default) or pipewire (the new multimedia standard)
# 	todo : make conditional setup with enum
{ inputs, lib, config, pkgs, ... }:
with builtins;
with lib;
let
  cfg = config.audio;
  submodules = [ ./pipewire.nix ./pulse.nix ];
in {
  option.audio.enable = mkEnableOption {
    name = mdDoc "audio";
    default = true;
  };
  imports = if cfg.enable then submodules else [ ];
}
