# FIDO2 support for ZFS
{
  lib,
  stdenv,
  fetchgit,
  pkgconf,
  shellcheck,
  zfs,
  libfido2,
  gnumake,
  mandoc,
  ...
}:
stdenv.mkDerivation rec {
  pname = "fzifdso";
  version = "v0.4.0";
  src = fetchgit {
    url = "https://git.sr.ht/~nabijaczleweli/fzifdso";
    rev = version;
    hash = "sha256-UNvQCGBYH94VMLZ25z8g/iW9r1x4MdjThe+tMbg1qZk=";
  };
  nativeBuildInputs = [
    pkgconf
    shellcheck
    zfs.dev
    libfido2.dev
    gnumake
    mandoc
  ];
  buildInputs = [
    zfs.dev
    libfido2.dev
  ];
  meta = {
    mainProgram = "zfs-fido2-load-key";
  };
}
