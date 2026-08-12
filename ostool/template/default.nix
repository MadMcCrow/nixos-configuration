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
  # update script, packaged, use in shell
  update-template = writeShellApplication {
    name = "${basename}-update";
    runtimeInputs = [
      npins
      jq
      git
    ];
    text = builtins.readFile ./update.sh;
  };
}
