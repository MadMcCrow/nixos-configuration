# FIDO2 support for ZFS
{
  lib,
  stdenv,
  fetchgit,
  pkg-config,
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
    pkg-config
    shellcheck
    zfs
    libfido2
    gnumake
    mandoc
  ];
  buildInputs = nativeBuildInputs;

  postPatch = ''
    substituteInPlace Makefile  --replace-fail \
    'FZIFDSO_VERSION ?= "$(patsubst v%,%,$(shell git describe || echo 0))"' 'FZIFDSO_VERSION ?= "${version}"'
  '';

  meta = {
    mainProgram = "zfs-fido2-load-key";
    licences = with lib.licenses; [
          bsd0
          mit
        ];
    homepage = "https://git.sr.ht/~nabijaczleweli/fzifdso";
    platforms = ["x86_64-linux"];
  };
}
