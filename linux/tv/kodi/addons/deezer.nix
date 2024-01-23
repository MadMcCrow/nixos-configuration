# addons/deezer.nix
#   Deezer support for kodi

{ pkgs, lib, kodi, ... }:
kodi.buildKodiAddon rec {
  version = "2.0.5";
  pname = "audio.deezer";
  namespace = "plugin.audio.deezer";

  src = pkgs.fetchFromGitHub {
    owner = "Valentin271";
    repo = "DeezerKodi";
    rev = "v${version}";
    sha256 = "";
  };

  # propagatedBuildInputs = with pkgs.kodiPlugins; [  ];
  meta = with lib; {
    homepage = "https://github.com/Valentin271/DeezerKodi";
    description = "Deezer Kodi addon";
    license = licenses.gpl3;
  };
}
