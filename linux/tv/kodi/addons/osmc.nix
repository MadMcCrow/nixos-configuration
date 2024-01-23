# OSMC plugins that actually work in kodi
{ pkgs, lib, kodi, ... }:
let
  # TODO : service.osmc.settings

  subdir = "package/mediacenter-addon-osmc/src";

  mkOsmcAddon = { name } : kodi.buildKodiAddon {
    pname = name;
    namespace  ="script.module.${name}"
    version = "0.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "osmc";
      repo = "osmc";
      rev = "5c6537493df778040cea2c168ed5f4fa42995273";
      sha256 = "sha256-IStT14mEy/ob+sA11oI931ktHwCpWV8T66qyt/Skqvg=";

    };

    dontStrip = false;

    unpackPhase = ''
      ls -la
      cp -R $src/${subdir}/${namespace} ./
      jjhjhj
    '';

    sourceDir = subdir;

    meta = with lib; {
      homepage = "https://github.com/osmc/osmc";
      description = "Kodi osmc addon : ${pname}";
      license = licenses.gpl2;
    };
  };
in [
  mkOsmcAddon
  {
    pame = "osmcsetting.networking";
    version = "0.1.0";
  }
  mkOsmcAddon
  {
    name = "osmccommon";
    version = "0.1.0";
  }
]
