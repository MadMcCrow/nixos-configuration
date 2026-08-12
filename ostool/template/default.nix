# provide the template and the updater script as packages
inputs@{
  self,
  writeShellApplication,
  stdenvNoCC,
  npins,
  jq,
  git,
  ...
}:
let
  basename = "os-template";
in
{
  # the template config
  template = stdenvNoCC.mkDerivation {
    name = basename;
    inherit (import (self + /lib/version.nix) inputs) version;
    src = ./src;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      cp -r . $out
    '';
  };
}
