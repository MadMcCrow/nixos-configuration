inputs@{
  pkgs,
  self,
  stdenvNoCC,
  writeShellScript,
  just,
  ...
}:
let
  mkjustpkgs =
    name: src:
    let
      datadir = "/share/ostool";
    in
    stdenvNoCC.mkDerivation {
      inherit name src;
      inherit (import (self + /lib/version.nix) inputs) version;
      dontBuild = true;
      nativeBuildInputs = [ makeWrapper ];
      installPhase = ''
        mkdir -p $out/${datadir}
        cp -r . $out/${datadir}
        mkdir -p $out/bin
        makeWrapper ${lib.getExe just} $out/bin/${name} \
           --add-flags "--working-directory $out/${datadir}"   \
           --add-flags "--justfile $out/${datadir}/.justfile"
      '';
      meta.mainProgram = "${name}";
    };
in
{
  init = mkjustpkgs "os-init" ./init;
  install = mkjustpkgs "os-install" ./install;
  update = mkjustpkgs "os-update" ./update;
}
