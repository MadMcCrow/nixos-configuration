# OSMC plugins that actually work in kodi
{ pkgs, lib, kodi, ... }:
let
  mkOsmcAddon = { subpath, pname, namespace }: {
    inherit pname namespace;
    src = pkgs.fetchFromGitHub {
      owner = "osmc";
      repo = "osmc";
      rev = "5c6537493df778040cea2c168ed5f4fa42995273";
      sha256 = "";

    };

    unpackPhase = ''
      cp -R $src/${subpath} ./
    '';

    meta = with lib; {
      homepage = "https://github.com/osmc/osmc";
      description = "Kodi osmc addon : ${pname}";
      license = licenses.gpl2;
    };
  };
in [
  mkOsmcAddon
  {
    pname = "osmcsetting.networking";
    namespace = "script.module.osmcsetting.networking";
    subpath = "package/mediacenter-addon-osmc";
  }
]
