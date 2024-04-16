# media.nix
# 	packages to view, listen, etc... to medias
{ pkgs, config, lib, ... }: {
  # for now just add vlc
  home.packages = with pkgs; [ vlc ];
}
