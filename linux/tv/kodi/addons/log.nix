# Log viewer for kodi !
{ pkgs, lib, kodi, ... }:
kodi.buildKodiAddon {
  pname = "script.logviewer";
  namespace = "script.logviewer";
  version = "2.1.6";

  src = pkgs.fetchFromGitHub {
    owner = "i96751414";
    repo = "script.logviewer";
    rev = "2a3dfd02403dbd81a1be9dac1614780849708d8c";
    sha256 = "sha256-a3+VywsIaox4+ljyU3nm5CkcFh6GUqQuINB1A7Jsqm0=";
  };

  # propagatedBuildInputs = with pkgs.kodiPlugins; [  ];
  meta = with lib; {
    homepage = "https://github.com/i96751414/script.logviewer";
    description = "Kodi Log addon";
    license = licenses.gpl2;
  };
}
