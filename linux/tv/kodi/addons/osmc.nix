# OSMC plugins that actually work in kodi
{ pkgs, lib, kodiPkgs, ... }:
let
  # where are the osmc addons in the osmc repo
  subdir = "package/mediacenter-addon-osmc/src";

  # simplify declaration
  mkOsmcAddon = sub: name:
    kodiPkgs.buildKodiAddon rec {
      pname = name;
      namespace = "${sub}.${name}";
      version = "0.1.0";
      unpackPhase = ''
        cp -R $src/${subdir}/${namespace}/* ./
        ls -la
      '';
      src = pkgs.fetchFromGitHub {
        owner = "osmc";
        repo = "osmc";
        rev = "5c6537493df778040cea2c168ed5f4fa42995273";
        sha256 = "sha256-IStT14mEy/ob+sA11oI931ktHwCpWV8T66qyt/Skqvg=";
      };
      # not sure about that
      # sourceDir = subdir;
      meta = with lib; {
        homepage = "https://github.com/osmc/osmc";
        description = "Kodi osmc addon : ${pname}";
        license = licenses.gpl2;
      };
    };
in [
  (mkOsmcAddon "service" "osmc.settings")
  (mkOsmcAddon "script" "module.osmccommon")
  (mkOsmcAddon "script" "module.xmltodict")
  (mkOsmcAddon "script" "module.osmcsetting.networking")
  (mkOsmcAddon "script" "module.osmcsetting.logging")
  (mkOsmcAddon "script" "module.osmcsetting.services")
  (mkOsmcAddon "script" "module.osmcsetting.updates")
  (mkOsmcAddon "script" "module.osmcsetting.apfstore")
  (mkOsmcAddon "script" "module.osmcsetting.remotes")
]
