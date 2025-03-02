# home/applications/default.nix
# TODO : make this a shareable module (between users)
{ lib, osConfig, ... }:
{
  imports = lib.optionals osConfig.services.xserver.enable [
    ./discord
    ./firefox.nix
    ./multimedia.nix
    ./vscode.nix
  ];
}
