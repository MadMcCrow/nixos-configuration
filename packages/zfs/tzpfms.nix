# TPM2 support for ZFS
# TODO : try build
{
  lib,
  stdenv,
  fetchgit,
  pkg-config,
  shellcheck,
  zfs,
  gnumake,
  mandoc,
  ...
}:
let
pname = "tzpfms";
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
    gnumake
    mandoc
  ];

  buildInputs = nativeBuildInputs;

  meta = {
    mainProgram = "zfs-tpm2-load-key";
    licences = with lib.licenses; [
      bsd0
      mit
    ];
    homepage = "https://git.sr.ht/~nabijaczleweli/tzpfms";
    platforms = [ "x86_64-linux" ];
  };
}
