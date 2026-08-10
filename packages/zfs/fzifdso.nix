# FIDO2 support for ZFS
{
  lib,
  stdenv,
  pkg-config,
  shellcheck,
  zfs,
  libfido2,
  gnumake,
  mandoc,
  ...
}:
let
  pname = "fzifdso";
  sources = import ../_npins;
  pin = sources.${pname};
in
stdenv.mkDerivation rec {
  inherit pname;
  inherit (pin) version;

  src = pin;

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
    platforms = [ "x86_64-linux" ];
  };
}
