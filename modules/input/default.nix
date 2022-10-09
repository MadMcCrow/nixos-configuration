# default.nix
#	Collection of modules to enable
#	Add your NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
{
  imports = [ ./ratbag.nix ./input-remapper.nix ];
}
