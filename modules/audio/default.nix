# Audio can be handled with pulseaudio (NixOS default) or pipewire (the new multimedia standard)
{ inputs, lib, config, pkgs, impermanence, ... }:
{
	import = [./pipewire.nix];
}
