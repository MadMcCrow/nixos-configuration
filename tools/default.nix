inputs@{
  pkgs,
  system,
  self, ...
} :
let
 mkjustpkgs =name: dir: stdenvNoCC.mkDerivation {
   inherit name;
   version = import (self)

   # everything just needs at runtime
   src = self + "/tools/just";   # contains justfile + templates/

   dontBuild = true;
   nativeBuildInputs = [ makeWrapper ];

   installPhase = ''
     mkdir -p $out/share/ostool
     cp -r . $out/share/ostool

     mkdir -p $out/bin
     makeWrapper ${lib.getExe just} $out/bin/os-just \
       --add-flags "--justfile $out/share/ostool/justfile" \
       --add-flags "--working-directory $out/share/ostool" \
       --set OS_TEMPLATE "$out/share/ostool/templates"
   '';

   meta.mainProgram = "os-just";
 }
in
{
init = {
  type = "app";
  program = "${pkgs.writeShellScript "install" "${pkgs.just}/bin/just -f ${./justfile} install \"$@\""}";
};