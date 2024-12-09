# home/applications/default.nix
# TODO : make this a shareable module (between users)
{ lib, osConfig, ... }:
let
  graphical = osConfig.services.xserver.enable;
in
{
  imports = lib.lists.optionals graphical [
    ./discord
    ./deezer.nix
    ./firefox.nix
    ./games.nix
    ./multimedia.nix
    ./vscode.nix
  ];
}
