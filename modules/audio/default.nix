# Audio can be handled with pulseaudio (NixOS default) or pipewire (the new multimedia standard)
{ pkgs, config, lib, ... }:
{
	import = [./pipewire.nix];
}
