# TPM2 support for ZFS
{
  stdenv,
  fetchgit,
  pkgconf,
  shellcheck,
  zfs,
  make,
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
    make
    mandoc
  ];
  buildInputs = [ zfs.dev ];
  meta = {
    mainProgram = "zfs-tpm2-load-key";
    licences = with pkgs.lib.licenses; [
      bsd0
      mit
    ];
    homepage = "https://git.sr.ht/~nabijaczleweli/tzpfms";
  };
}
