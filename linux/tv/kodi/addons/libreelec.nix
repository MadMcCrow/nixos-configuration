# addons/libreelec.nix
# system settings for kodi from libreelec
{ pkgs, lib, kodi, ... }:
let
  # version of libreElec
  version = "11.0.0";

  # Buss
  dbussy = pkgs.python3Packages.buildPythonApplication rec {
    pname = "DBussy";
    version = "1.3";
    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "1a3l427ibwck9zzzy1sp10hmjgminya08i4r9j4559qzy7lxghs1";
    };
    # postPatch = ''
    #   cat setup.py
    #   substituteInPlace setup.py \
    #     --replace 'click>=7.0,<8.0' 'click' \
    #     --replace 'termcolor>=1.1.0,<2.0.0' 'termcolor'
    # '';
    # nativeBuildInputs = with python3Packages; [
    #];
    # propagatedBuildInputs = with python3Packages; [
    #];
    doCheck = false;
    meta = with lib; {
      homepage = "https://gitlab.com/ldo/dbussy";
      license = licenses.lgpl21;
      description = "Yet another Python binding for accessing D-Bus";
    };

  };
in kodi.buildKodiAddon {
  inherit version;
  pname = "libreelec.settings";
  namespace = "service.libreelec.settings";

  # TODO : replace fan-art
  # TODO : replace root password -> major security flaw
  postPatch = ''
    substituteInPlace ./Makefile \
      --replace 'DISTRONAME := LibreELEC' 'DISTRONAME := NixOS' \
      --replace 'ADDON_VERSION := 0.0.0' 'ADDON_VERSION := ${version}' \
      --replace 'SHELL := /bin/bash' 'SHELL := ${lib.getExe pkgs.bash}'
      make all
  '';

  runtimeDependency = [ dbussy ];
  buildInputs = [ dbussy ];

  src = pkgs.fetchFromGitHub {
    owner = "LibreELEC";
    repo = "service.libreelec.settings";
    rev = "5dbc28515314715f1aec2f91c04364c87c24bb50";
    sha256 = "sha256-Htq17TBKW5MwkYIx7m07IMLSPLtO95pdb0/piBl94n8=";
  };

  # propagatedBuildInputs = with pkgs.kodiPlugins; [  ];
  meta = with lib; {
    homepage = "https://github.com/LibreELEC/service.libreelec.settings";
    description = "LibreElec Settings addon";
    license = licenses.gpl2;
  };
}
