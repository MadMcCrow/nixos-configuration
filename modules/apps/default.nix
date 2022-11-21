# apps/default.nix
# 	all the apps we want on our systems
{ pkgs, config, nixpkgs, lib, unfree, ... }: {
  imports =
    [ ./developmen ./web ./multimedia ./games ./base.nix ./flatpak.nix ];
}
