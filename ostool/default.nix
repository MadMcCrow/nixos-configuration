inputs@{
  lib,
  self,
  stdenvNoCC,
  writeShellScript,
  makeWrapper,
  just,
  nixos-install-tools,
  nom,
  ...
}:
with builtins;
let
  # import our descriptor
  osversion = import (self + /lib/version.nix) inputs;

  # helper packaging function for just recipes
  mkjustpkgs =
    {
      name,
      src,
      envars ? { },
      runtimeInputs,
      datadir ? "/share/ostool",
    }:
    stdenvNoCC.mkDerivation {
      inherit name src;
      inherit (osversion) version;
      dontBuild = true;
      nativeBuildInputs = [ makeWrapper ];
      installPhase = ''
        mkdir -p $out/${datadir}
        cp -r . $out/${datadir}
        mkdir -p $out/bin
        makeWrapper ${lib.getExe just} $out/bin/${name} \
           --add-flags "--working-directory $out/${datadir}"  \
           --add-flags "--justfile $out/${datadir}/.justfile" \
           --prefix PATH : "${lib.makeBinPath runtimeInputs}" \
      ''
      + (concatStringsSep "\\\n" (map (x: ''--set ${x.name} "${x.value}"\'') (attrsToList envars)));

      meta = {
        mainProgram = "${name}";
        inherit (osversion) licence;
      };
    };

  inherit (import ./template inputs) template;
in
{
  init = mkjustpkgs {
    name = "os-init";
    src = ./init;
    runtimeInputs = [
      template
      nixos-install-tools
    ];
    envars = {
      "OS_TEMPLATE" = template;
    };
  };

  install = mkjustpkgs {
    name = "os-install";
    src = ./install;
    runtimeInputs = [
      nom
      nixos-install-tools
    ];
  };

  update = mkjustpkgs {
    name = "os-update";
    src = ./update;
  };
}
