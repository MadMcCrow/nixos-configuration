# os-build.nix
# simple build script application
# use "OS" instead
inputs@{
  self,
  lib,
  makeWrapper,
  lix,
  stdenvNoCC,
  ...
}:
let
  deps = [ lix ];
  nonlib = import (self + "/lib/version.nix") inputs;
in
stdenvNoCC.mkDerivation {
  pname = "os-build";
  inherit (nonlib) version;
  src = self + "/tools/build-os";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 build.sh $out/bin/build.sh
    wrapProgram $out/bin/os-build \
      --prefix PATH : ${lib.makeBinPath deps}
  '';

  meta = {
    mainProgram = "os-build";
    inherit (nonlib) licence;
  };
}
