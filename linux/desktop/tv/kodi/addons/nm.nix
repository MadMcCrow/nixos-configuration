# nm plugins that allows connect to network
{ pkgs, lib, kodiPkgs, ... }:
kodiPkgs.buildKodiAddon rec {
  # originally made for ubuntu 18, might be deprecated
  version = "18.0";
  pname = "linux.nm";
  namespace = "script.linux.nm";
  buidInputs = with kodiPkgs.kodi.pythonPackages; [ dbus-python ];

  # old github repo (2020)
  src = pkgs.fetchFromGitHub {
    owner = "xptsp";
    repo = "${namespace}";
    rev = "v${version}";
    sha256 = "sha256-PINq/hRMjkgL3Bc8fiQgJN9v87P16tyYRtr0247zf3M=";
  };
}
