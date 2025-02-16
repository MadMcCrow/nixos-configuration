# TPM2 support for ZFS
{
  lib,
  stdenv,
  fetchgit,
  pkgconf,
  shellcheck,
  zfs,
  gnumake,
  mandoc,
  ...
}:
stdenv.mkDerivation rec {
  pname = "fzidso";
  version = "v0.4.0";
  src = fetchgit {
    url = "https://git.sr.ht/~nabijaczleweli/tzpfms";
    rev = version;
    hash = "sha256-pXQzbKq4DiL0WtxeuoMF1EtzRFpR6fVzDR+ubQD8IEI=";
  };
  nativeBuildInputs = [
    pkgconf
    shellcheck
    zfs.dev
    gnumake
    mandoc
  ];
  buildInputs = [ zfs.dev ];
  meta = {
    mainProgram = "zfs-tpm2-load-key";
    licences = with lib.licenses; [
      bsd0
      mit
    ];
    homepage = "https://git.sr.ht/~nabijaczleweli/tzpfms";
  };
}
