# addons/amazon.nix
# amazon prime support for kodi
{ pkgs, lib, kodi, ... }:
kodi.buildKodiAddon { }
# Amazon prime is this :
# but there hasn't been a release in 4 month (repo is still active)
# kodiprime = pkgs.kodiPlugins.buildKodiAddon {
#   pname = "prime";
#   namespace = "repository.sandmann79-py3";
#   version = "1.0.4";
#
#   src = fetchFromGitHub {
#     owner = "Sandmann79";
#     repo = "xbmc";
#     rev = "v1.0.4";
#     sha256 = "";
#   };
#   propagatedBuildInputs = with pkgs.kodiPlugins; [
#     signals
#     inputstream-adaptive
#     inputstreamhelper
#     requests
#     myconnpy
#   ];
#   meta = with lib; {
#     homepage = https://github.com/Sandmann79/xbmc;
#     description = "PrimeVideo VOD Services Add-on";
#     license = licenses.gpl3;
#   };
# };
