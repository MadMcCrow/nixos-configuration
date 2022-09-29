# audio/default.nix
# 	Audio can be handled with pulseaudio (NixOS default) or pipewire (the new multimedia standard)
# 	todo : make conditional setup with enum
{ inputs, lib, config, pkgs, ... }: {
  imports = [ ./pipewire.nix /pulse.nix ];
}
