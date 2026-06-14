# os-build.nix
# simple build script application
# use "OS" instead
{
  self,
  lib,
  makeWrapper,
  nonlib,
  lix,
  stdenvNoCC,
  ...
} :
let
  deps = [ lix ];
in
stdenvNoCC.mkDerivation {
  pname = "build-os";
  version = nonlib.version;
  src =  self + "/tools/build-os";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 build.sh $out/bin/build.sh
    wrapProgram $out/bin/os-build \
      --prefix PATH : ${
        lib.makeBinPath deps
      }
  '';

  meta = {
    mainProgram = "os-build";
    licence = lib.licenses.mit;
  };
}
