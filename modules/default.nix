# default.nix
#	Collection of modules to enable
#	Add your NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
{
  imports = [
    # List your module files here
    ./audio
    ./flatpak.nix
    ./gnome.nix
    ./nix.nix
    ./persist.nix
    ./shell.nix
    ./steam.nix
    ./users.nix
  ];
}
